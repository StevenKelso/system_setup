#!/bin/bash

# ---- list of packages to be installed ----
apps=(
"git"
"stow"
"firefox"
"keepass-xc"
"kitty"
"neovim"
"tmux"
"ranger"
"wofi"
"hyprland"
"hyprlock"
"hyprcursor"
"hyprpaper"
"waybar"
"go"
"python3"
"luarocks"
"eza"
"bat"
"fzf"
"ripgrep"
)

# ---- list of packages that failed to install ----
failed=()

# ---- determine package manager ----
pm=""

if command -v apt >/dev/null; then
    pm="apt"
elif command -v dnf >/dev/null; then
    pm="dnf"
elif command -v pacman >/dev/null; then
    pm="pacman"
elif command -v zypper >/dev/null; then
    pm="zypper"
elif command -v xbps >/dev/null; then
    pm="xbps"
else
    echo "ERROR: Can't determine package manager"
fi

# ---- update repo and install packages ----
case "$pm" in
    "apt")
        sudo apt update
        sudo apt upgrade
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo apt install $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "dnf")
        sudo dnf upgrade -y
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo dnf install $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "pacman")
        sudo pacman -Syu
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo pacman -S $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "zypper")
        sudo zypper update -y
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo zypper install $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "xbps")
        sudo xbps-install -Su
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo xbps-install -S $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
esac

# ---- display list of failed installs ----
echo -e "\nThe following programs were unable to be installed:"
for i in "${failed[@]}"; do
    echo -e "$i"
done

# ---- optionally clone dotfiles repo and set them up ----
echo ""
read -rp "Do you want to clone your dotfiles repo? [y/n]: " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\nContinuing..."
    cd $HOME
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    stow .
else
    echo -e "\nOperation canceled."
fi
