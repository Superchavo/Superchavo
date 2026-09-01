#!/bin/bash
set -euo pipefail

echo -e "\033[1;36m   _   __         _  ____                ____           __        ____\033[0m"
echo -e "\033[1;36m  / | / /__  ___ | |/ / /__________ _   /  _/___  _____/ /_____ _/ / /__  _____\033[0m"
echo -e "\033[1;36m /  |/ / _ \/ _ \|   / __/ ___/ __ \`/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/\033[0m"
echo -e "\033[1;36m/ /|  /  __/  __/   / /_/ /  / /_/ /  _/ // / / (__  ) /_/ /_/ / / /  __/ /\033[0m"
echo -e "\033[1;36m/_/ |_/\___/\___/_/|_\__/_/   \__,_/  /___/_/ /_/____/\__/\__,_/_/_/\___/_/\033[0m"
echo -e "\033[1;33m────────────────────────────────────────────────────────────────────────────────\033[0m"

echo -e "\033[1;32m[■] Init: Setting up NeeXtraRepo environment...\033[0m"
REPO_DIR="$HOME/Superchavo/NeeXtraRepo"
if [ ! -d "$REPO_DIR" ]; then
    mkdir -p "$HOME/Superchavo"
    git clone https://github.com/superchavo/Superchavo.git "$HOME/Superchavo"
fi
cd "$REPO_DIR"

echo -e "\033[1;32m[↓] Download: Fetching security keyring...\033[0m"
if [ -f "NeextraKey.gpg" ]; then
    mkdir -p "$PREFIX/etc/apt/trusted.gpg.d"
    cp NeextraKey.gpg "$PREFIX/etc/apt/trusted.gpg.d/neextrarepo.gpg"
fi

echo -e "\033[1;32m[◈] Package: Finding and installing latest keyring from pool...\033[0m"
latest_deb=$(find pool/ -name "neextra-keyring_*_all.deb" | sort -V | tail -n 1 || true)
if [ -n "$latest_deb" ]; then
    dpkg -i "$latest_deb"
else
    echo -e "\033[1;33m[!] Warning: No local keyring deb found, rebuilding repository...\033[0m"
    ./update_repo.sh
    latest_deb=$(find pool/ -name "neextra-keyring_*_all.deb" | sort -V | tail -n 1)
    dpkg -i "$latest_deb"
fi

echo -e "\033[1;32m[⚙] Config: Registering repository source...\033[0m"
mkdir -p "$PREFIX/etc/apt/sources.list.d"
echo "deb [signed-by=$PREFIX/etc/apt/trusted.gpg.d/neextrarepo.gpg] https://superchavo.is-a.dev/NeeXtraRepo neextra neextra" > "$PREFIX/etc/apt/sources.list.d/neextra.list"

echo -e "\033[1;32m[▲] Sync: Updating package index and upgrading system...\033[0m"
apt update

echo -e "\n\033[1;32m--- NeeXtraRepo successfully installed and configured! ---\033[0m"
