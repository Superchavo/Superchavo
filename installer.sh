#!/data/data/com.termux/files/usr/bin/bash

# Clear screen for maximum visual impact
clear

# Color Palette (ANSI Escape Codes)
CYAN='\033[1;36m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
NC='\033[0m' # Reset Color

# Awesome Dual-Tone ASCII Art
echo -e "${CYAN}    _   __         _  ____                ____           __        ____         "
echo -e "   / | / /__  ___ | |/ / /__________ _   /  _/___  _____/ /_____ _/ / /__  _____"
echo -e "  /  |/ / _ \/ _ \|   / __/ ___/ __ \`/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/"
echo -e "${BLUE} / /|  /  __/  __/   / /_/ /  / /_/ /  _/ // / / (__  ) /_/ /_/ / / /  __/ /    "
echo -e "/_/ |_/\___/\___/_/|_\__/_/   \__,_/  /___/_/ /_/____/\__/\__,_/_/_/\___/_/     ${NC}"
echo -e "${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"

echo -e "${YELLOW}[⚡] Preparation:${NC} Initializing installer components..."
sleep 1

# Paso 1: Asegurar que el directorio de fuentes exista
mkdir -p $PREFIX/etc/apt/sources.list.d

# Paso 2: Escribir la línea del repositorio ignorando firmas con trusted=yes
echo -e "${YELLOW}[⚙] Configuration:${NC} Writing repository info to sources.list.d..."
echo "deb [trusted=yes arch=all] https://superchavo.github.io/NeeXtraRepo neextra xtreleases" > $PREFIX/etc/apt/sources.list.d/neextra.list
sleep 1

# Paso 3: Actualizar las listas de paquetes de forma directa
echo -e "\n${CYAN}[🚀] Syncing:${NC} Fetching package lists from NeeXtraRepo mirrors...\n"
apt update

echo -e "\n${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}[✓] SUCCESS:${NC} ${CYAN}NeeXtraRepo${NC} has been successfully injected into your system!"
echo -e "${YELLOW}[👉] Action:${NC} Run '${GREEN}apt install <package_name>${NC}' to deploy your custom tools.\n"
