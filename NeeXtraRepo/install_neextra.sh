#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

clear

CYAN='\033[1;36m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
NC='\033[0m'

echo -e "${CYAN}    _   __         _  ____                ____           __        ____         "
echo -e "   / | / /__  ___ | |/ / /__________ _   /  _/___  _____/ /_____ _/ / /__  _____"
echo -e "  /  |/ / _ \/ _ \|   / __/ ___/ __ \`/   / // __ \/ ___/ __/ __ \`/ / / _ \/ ___/"
echo -e "${BLUE} / /|  /  __/  __/   / /_/ /  / /_/ /  _/ // / / (__  ) /_/ /_/ / / /  __/ /    "
echo -e "/_/ |_/\___/\___/_/|_\__/_/   \__,_/  /___/_/ /_/____/\__/\__,_/_/_/\___/_/     ${NC}"
echo -e "${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"

echo -e "${YELLOW}[■] Init:${NC} Setting up NeeXtraRepo environment..."

KEYRING_URL="https://github.com/Superchavo/Superchavo/raw/refs/heads/main/NeeXtraRepo/pool/neextra-keyring_1.0.3_all.deb"
TEMP_DEB=$(mktemp --suffix=.deb)

echo -e "${YELLOW}[↓] Download:${NC} Fetching security keyring..."
if ! wget -qO "$TEMP_DEB" "$KEYRING_URL"; then
    echo -e "${RED}[✕] Error:${NC} Failed to download neextra-keyring package."
    rm -f "$TEMP_DEB"
    exit 1
fi

echo -e "${YELLOW}[◈] Package:${NC} Installing keyring to secure repository..."
dpkg -i "$TEMP_DEB" > /dev/null 2>&1 || apt --fix-broken install -y > /dev/null 2>&1
rm -f "$TEMP_DEB"

mkdir -p "$PREFIX/etc/apt/sources.list.d"
echo -e "${YELLOW}[⚙] Config:${NC} Registering repository source..."
echo "deb [signed-by=$PREFIX/etc/apt/keyrings/NeextraKey.gpg] https://superchavo.is-a.dev/NeeXtraRepo/ ./" > "$PREFIX/etc/apt/sources.list.d/neextra.list"

echo -e "\n${CYAN}[▲] Sync:${NC} Updating package index...\n"
apt update

CLI_PATH="$PREFIX/bin/neextraapps"
cat << 'CLI_EOF' > "$CLI_PATH"
#!/data/data/com.termux/files/usr/bin/bash
while true; do
    clear
    echo -e "\033[1;36mNeextra Apps\033[0m"
    echo -e "\033[1;35m───────────────────────────────────────────────────────────────────────────────────────────────\033[0m"
    echo -e "\033[1;33m[Available Packages]\033[0m"
    echo -e "\033[1;35m───────────────────────────────────────────────────────────────────────────────────────────────\033[0m"
    
    RAW_DATA=$(curl -s https://superchavo.is-a.dev/NeeXtraRepo/Packages)
    
    valid_packages=()
    current_pkg=""
    current_ver=""
    current_desc=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^Package:\ (.*) ]]; then
            current_pkg="${BASH_REMATCH[1]}"
            valid_packages+=("$current_pkg")
        elif [[ "$line" =~ ^Version:\ (.*) ]]; then
            current_ver="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Description:\ (.*) ]]; then
            current_desc="${BASH_REMATCH[1]}"
            echo -e " \033[1;32m•\033[0m \033[1m$current_pkg\033[0m (\033[36m$current_ver\033[0m) - $current_desc"
        fi
    done <<< "$RAW_DATA"

    echo -e "\033[1;35m───────────────────────────────────────────────────────────────────────────────────────────────\033[0m"
    echo -e " Type \033[1;31mExit\033[0m to quit."
    echo -e "\033[1;35m───────────────────────────────────────────────────────────────────────────────────────────────\033[0m"
    
    read -p "Which one you want to select? (App name) : " app_input
    
    if [[ "$app_input" =~ ^[Ee][Xx][Ii][Tt]$ ]]; then
        echo "Exiting..."
        break
    elif [ -n "$app_input" ]; then
        # Verificar si el paquete está dentro de la lista válida del repo
        found=0
        for p in "${valid_packages[@]}"; do
            if [ "$p" == "$app_input" ]; then
                found=1
                break
            fi
        done

        if [ $found -eq 1 ]; then
            echo -e "\033[1;36m[◆] Installing '$app_input'...\033[0m"
            if apt install "$app_input"; then
                echo -e "\033[1;32m[✔] Package '$app_input' installed successfully.\033[0m"
            else
                echo -e "\033[1;31m[✕] App install aborted\033[0m"
            fi
        else
            echo -e "\033[1;31m[✕] This app dosent exist on the repo\033[0m"
        fi
        read -p "Press Enter to continue..."
    fi
done
CLI_EOF
chmod +x "$CLI_PATH"

GUI_PATH="$PREFIX/bin/neextraappsgui"
cat << 'GUI_EOF' > "$GUI_PATH"
#!/data/data/com.termux/files/usr/bin/bash

if ! python3 -c "import tkinter" &> /dev/null; then
    echo "[!] Installing python and tkinter for X11 GUI..."
    apt install -y python python-tkinter > /dev/null 2>&1
fi

python3 - << 'PY_SCRIPT'
import tkinter as tk
from tkinter import messagebox, ttk
import urllib.request
import subprocess

class NeeXtraGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("NeeXtraRepo GUI")
        self.root.geometry("600x450")
        self.root.configure(bg="#1e1e2e")

        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Treeview", background="#2a2b3c", foreground="white", fieldbackground="#2a2b3c", font=('Arial', 10))
        style.configure("Treeview.Heading", background="#45475a", foreground="white", font=('Arial', 10, 'bold'))

        title_label = tk.Label(root, text="NeeXtraRepo - App Store", font=("Arial", 16, "bold"), fg="#89b4fa", bg="#1e1e2e")
        title_label.pack(pady=10)

        self.tree = ttk.Treeview(root, columns=("Package", "Version", "Description"), show="headings", height=12)
        self.tree.heading("Package", text="Package Name")
        self.tree.heading("Version", text="Version")
        self.tree.heading("Description", text="Description")
        
        self.tree.column("Package", width=130, anchor="w")
        self.tree.column("Version", width=90, anchor="center")
        self.tree.column("Description", width=340, anchor="w")
        
        self.tree.pack(padx=15, pady=5, fill=tk.BOTH, expand=True)

        btn_frame = tk.Frame(root, bg="#1e1e2e")
        btn_frame.pack(pady=15)

        install_btn = tk.Button(btn_frame, text="Install Selected", command=self.install_pkg, bg="#a6e3a1", fg="#11111b", font=('Arial', 10, 'bold'), padx=10, relief="flat")
        install_btn.pack(side=tk.LEFT, padx=10)

        refresh_btn = tk.Button(btn_frame, text="Refresh List", command=self.load_packages, bg="#fab387", fg="#11111b", font=('Arial', 10, 'bold'), padx=10, relief="flat")
        refresh_btn.pack(side=tk.LEFT, padx=10)

        close_btn = tk.Button(btn_frame, text="Exit", command=root.destroy, bg="#f38ba8", fg="#11111b", font=('Arial', 10, 'bold'), padx=10, relief="flat")
        close_btn.pack(side=tk.LEFT, padx=10)

        self.load_packages()

    def load_packages(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        try:
            req = urllib.request.urlopen("https://superchavo.is-a.dev/NeeXtraRepo/Packages")
            data = req.read().decode('utf-8')
            
            pkg, ver, desc = "", "", ""
            for line in data.splitlines():
                if line.startswith("Package: "):
                    pkg = line.replace("Package: ", "").strip()
                elif line.startswith("Version: "):
                    ver = line.replace("Version: ", "").strip()
                elif line.startswith("Description: "):
                    desc = line.replace("Description: ", "").strip()
                    self.tree.insert("", tk.END, values=(pkg, ver, desc))
        except Exception as e:
            messagebox.showerror("Error", f"Could not fetch packages: {e}")

    def install_pkg(self):
        selected = self.tree.selection()
        if not selected:
            messagebox.showwarning("Warning", "Please select a package from the list first.")
            return
        item = self.tree.item(selected[0])
        pkg_name = item['values'][0]
        
        if messagebox.askyesno("Confirm", f"Do you want to install '{pkg_name}'?"):
            self.root.destroy()
            res = subprocess.run(["apt", "install", pkg_name])
            if res.returncode != 0:
                print("App install aborted")
        else:
            print("App install aborted")

if __name__ == "__main__":
    root = tk.Tk()
    app = NeeXtraGUI(root)
    root.mainloop()
PY_SCRIPT
GUI_EOF
chmod +x "$GUI_PATH"

echo -e "\n${PURPLE}────────────────────────────────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}[✔] SUCCESS:${NC} NeeXtraRepo is fully configured and secured!"
echo -e "${YELLOW}[▶] Actions:${NC}"
echo -e " - CLI interactive mode: Type '${GREEN}neextraapps${NC}'"
echo -e " - X11 Window GUI mode:  Type '${GREEN}neextraappsgui${NC}' (requires Termux-X11 running)\n"
