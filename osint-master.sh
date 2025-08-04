#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Verifica Termux
check_termux() {
    if [ ! -d "/data/data/com.termux/files/usr" ]; then
        echo -e "${RED}[!] ERRO: Execute no Termux.${NC}"
        exit 1
    fi
}

# Instala dependências
install_deps() {
    echo -e "${YELLOW}[*] Verificando dependências...${NC}"
    pkg update -y
    pkg install -y git python3 nmap whois curl || {
        echo -e "${RED}[!] Falha ao instalar dependências.${NC}"
        exit 1
    }
    # Instala theHarvester se não existir
    if [ ! -d "theHarvester" ]; then
        git clone https://github.com/laramies/theHarvester.git
        pip install -r theHarvester/requirements.txt
    fi
    echo -e "${GREEN}[+] Dependências OK!${NC}"
}

# WHOIS Lookup
whois_lookup() {
    read -p "Digite o domínio (ex: google.com): " domain
    [ -z "$domain" ] && {
        echo -e "${RED}[!] Domínio inválido.${NC}"
        return
    }
    echo -e "${CYAN}[+] WHOIS $domain:${NC}"
    whois "$domain" | grep -Ei "Registrar|Date|Name Server|Admin"
}

# IP Público
check_ip() {
    echo -e "${CYAN}[+] Seu IP:$(curl -s ifconfig.me)${NC}"
}

# Busca e-mails
email_finder() {
    read -p "Domínio para buscar e-mails (ex: example.com): " domain
    [ -z "$domain" ] && {
        echo -e "${RED}[!] Domínio inválido.${NC}"
        return
    }
    echo -e "${CYAN}[+] Buscando e-mails em $domain...${NC}"
    python3 theHarvester/theHarvester.py -d "$domain" -b google
}

# Scanner de Portas
port_scan() {
    read -p "IP/Domínio para scan (ex: 192.168.1.1): " target
    [ -z "$target" ] && {
        echo -e "${RED}[!] Alvo inválido.${NC}"
        return
    }
    echo -e "${CYAN}[+] Scan em $target...${NC}"
    nmap -T4 -F "$target"
}

# Ajuda
show_help() {
    echo -e "${BLUE}"
    echo "   ___  _____ _  _ ___ _   _ "
    echo "  / _ \|  ___| || |_ _| \ | |"
    echo " | | | | |_  | || || ||  \| |"
    echo " | |_| |  _| |__   _| || |\  |"
    echo "  \___/|_|     |_| |___|_| \_|"
    echo -e "${NC}"
    echo -e "${CYAN}          OSINT Master - Termux Edition${NC}"
    echo -e "${YELLOW}==============================================${NC}"
    echo -e "${GREEN}[1]${NC} Consulta WHOIS"
    echo -e "${GREEN}[2]${NC} Verificar IP Público"
    echo -e "${GREEN}[3]${NC} Buscar E-mails"
    echo -e "${GREEN}[4]${NC} Scanner de Portas"
    echo -e "${GREEN}[5]${NC} Ajuda"
    echo -e "${GREEN}[0]${NC} Sair"
    echo -e "${YELLOW}==============================================${NC}"
}

# Menu
main_menu() {
    while true; do
        clear
        show_help
        read -p "Escolha: " opt
        case $opt in
            1) whois_lookup ;;
            2) check_ip ;;
            3) email_finder ;;
            4) port_scan ;;
            5) show_help ;;
            0) echo -e "${RED}[*] Saindo...${NC}"; exit 0 ;;
            *) echo -e "${RED}[!] Opção inválida!${NC}"; sleep 1 ;;
        esac
        echo -e "${YELLOW}\nPressione ENTER...${NC}"
        read -n 1 -s
    done
}

# Início
check_termux
install_deps
main_menu