#!/bin/bash

pkgs=(
    "argparse"
    "awww"
    "bat"
    "bind"
    "brightnessctl"
    "eza"
    "fd"
    "fuse2"
    "fuse3"
    "fzf"
    "git"
    "go"
    "grim"
    "imagemagick"
    "imv"
    "ironbar"
    "jq"
    "keepassxc"
    "kitty"
    "luarocks"
    "make"
    "mako"
    "man-db"
    "man-pages"
    "mtr"
    "neovim"
    "niri"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "npm"
    "openbsd-netcat"
    "pavucontrol"
    "perl-image-exiftool"
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "python"
    "ripgrep"
    "rofi"
    "satty"
    "slurp"
    "starship"
    "stow"
    "swayidle"
    "swaylock"
    "tldr"
    "ttf-iosevka-nerd"
    "tree-sitter-cli"
    "udiskie"
    "unzip"
    "wireplumber"
    "wl-clipboard"
    "wlsunset"
    "xwayland-satellite"
    "yazi"
)
docker_pkgs=("docker")
virt_pkgs=("dnsmasq" "qemu-full" "virt-manager")
aur_pkgs=("brave-bin")
failed_pkgs=()


echo "#=================================#"
echo "Welcome to the System Setup script!"
echo "Selected distro: Arch"
echo "#=================================#"


echo -e "\nInstall standard packages? "
read -rp "[y/n]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    sudo pacman -Syu --noconfirm
    for pkg in "${pkgs[@]}"; do
        echo -e "\nAttempting to install: $pkg ..."
        if ! sudo pacman -S --noconfirm "$pkg"; then
            failed_pkgs+=("$pkg")
        fi
    done
else
    echo "Skipping standard packages"
fi


echo -e "\nInstall docker packages? "
read -rp "[y/n]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    for pkg in "${docker_pkgs[@]}"; do
        echo -e "\nAttempting to install: $pkg ..."
        if ! sudo pacman -S --noconfirm "$pkg"; then
            failed_pkgs+=("$pkg")
        fi
    done
    sudo systemctl enable --now docker.service
else
    echo "Skipping docker packages"
fi


echo -e "\nInstall virtualization packages? "
read -rp "[y/n]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    for pkg in "${virt_pkgs[@]}"; do
        echo -e "\nAttempting to install: $pkg ..."
        if ! sudo pacman -S --noconfirm "$pkg"; then
            failed_pkgs+=("$pkg")
        fi
    done
    sudo usermod -aG libvirt "$USER"
    sudo systemctl enable --now libvirtd.service
else
    echo "Skipping virtualization packages"
fi


echo -e "\nInstall paru as AUR helper? "
read -rp "[y/n]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo -e "\nInstalling prerequisites for building paru..."
    sudo pacman -S --noconfirm --needed base-devel git

    echo -e "\nInstalling paru..."
    build_dir=$(mktemp -d)
    if git clone https://aur.archlinux.org/paru.git "$build_dir/paru" && (cd "$build_dir/paru" && makepkg -si --noconfirm); then
        echo "paru installed successfully"
    else
        echo "Failed to install paru"
    fi
    rm -rf "$build_dir"

    echo -e "\n#=================================#"
    echo -e "\nInstall AUR packages? "
    read -rp "[y/n]: " answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        for pkg in "${aur_pkgs[@]}"; do
            echo -e "\nAttempting to install: $pkg ..."
            if ! paru -S --noconfirm "$pkg"; then
                failed_pkgs+=("$pkg")
            fi
        done
    else
        echo "Skipping AUR packages"
    fi
else
    echo "Skipping AUR helper"
fi


echo -e "\nSet up dotfiles? "
read -rp "[y/n]: " answer
if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    cd "$HOME"
    mkdir -p "$HOME"/{Pictures,Downloads,Documents,repos/stevenkelso}
    cd "$HOME/repos/stevenkelso/"
    git clone https://github.com/StevenKelso/dotfiles
    cd "$HOME/repos/stevenkelso/dotfiles"
    [ -f "$HOME/.bashrc" ]         && rm "$HOME/.bashrc"
    [ -d "$HOME/.config/kitty/" ]  && rm -rf "$HOME/.config/kitty/"
    [ -d "$HOME/.config/mako/" ]  && rm -rf "$HOME/.config/mako/"
    [ -d "$HOME/.config/niri/" ]  && rm -rf "$HOME/.config/niri/"
    stow -t "$HOME" .
else
    echo "Skipping dotfiles setup"
fi


echo -e "\nSystem setup complete!"
echo "Restart your system for your dotfiles to take effect."
if (( ${#failed_pkgs[@]} > 0 )); then
    echo -e "\nThe following packages failed to install:"
    for pkg in "${failed_pkgs[@]}"; do
        echo "  - $pkg"
    done
fi
