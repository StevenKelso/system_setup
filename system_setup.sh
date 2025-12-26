#!/bin/bash

#===================================#
# Title: system_installer.sh        #
# Author: StevenKelso               #
#===================================#

#--- list of arch packages ---#
arch_apps=(
    "aws-cli-v2"
    "bat"
    "btop"
    "bind" # package containing "dig and nslookup"
    "brightnessctl"
    "discord"
    "dunst"
    "eza"
    "fd"
    "firefox"
    "freerdp"
    "fzf"
    "gammastep"
    "git"
    "github-cli"
    "grim"
    "hyprland"
    "hyprlock"
    "hyprpaper"
    "jq"
    "imagemagick"
    "keepassxc"
    "kitty"
    "make"
    "man-db"
    "man-pages"
    "mtr"
    "neovim"
    "nmap"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "openbsd-netcat"
    "otf-firamono-nerd"
    "pavucontrol"
    "perl-image-exiftool"
    "pipewire"
    "pipewire-pulse"
    "pipewire-alsa"
    "python-pip"
    "remmina"
    "ripgrep"
    "rofi"
    "rsync"
    "slurp"
    "stow"
    "tcpdump"
    "tldr"
    "traceroute"
    "udiskie"
    "unzip"
    "waybar"
    "wireplumber"
    "wl-clipboard"
    "yazi"
    "yq"
    "zathura"
    "zathura-pdf-poppler"
)

docker_apps=("docker")

virt_apps=("qemu-full" "virt-manager")

print_apps=("cups" "hplip" "python-pyqt5" "system-config-printer")

failed_apps=()


# confirm helper
confirm() {
    echo -e "\n#======================================#"
    read -rp "$1 [y/n]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}


# pacman install helper
install_pacman_packages() {
    local pkgs=("$@")
    for pkg in "${pkgs[@]}"; do
        echo -e "\nattempting to install $pkg ..."
        if ! sudo pacman -S --needed --noconfirm "$pkg"; then
            failed_apps+=("$pkg")
        fi
    done
}


# welcome text
echo "#=================================#"
echo "Welcome to the System Setup script!"
echo "#=================================#"


# update repo and install packages
if confirm "update repo and install packages?"; then
    sudo pacman -Syu --noconfirm
    install_pacman_packages "${arch_apps[@]}"
else
    echo "skipping package install"
fi


# install starship prompt
if confirm "install starship prompt?"; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "skipping starship prompt"
fi


# set up directories
cd "$HOME"
mkdir -p "$HOME"/{Pictures,Downloads,Documents,trad}


# clone dotfiles repo and set them up
if confirm "clone your dotfiles repo and set up directories?"; then
    cd "$HOME"
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    if [ -f "$HOME/.bashrc" ]; then
        rm "$HOME/.bashrc"
    fi
    if [ -d "$HOME/.config/hypr/" ]; then
        rm -rf "$HOME/.config/hypr/"
    fi
    if [ -d "$HOME/.config/kitty/" ]; then
        rm -rf "$HOME/.config/kitty/"
    fi
    stow -t "$HOME" .
    echo "dotfiles applied, restart your shell to load new config"
else
    echo "skipping dotfiles"
fi


# set up yay AUR helper
if confirm "set up yay AUR helper?"; then
    echo -e "\ncontinuing..."
    cd "$HOME"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    yay -Y --gendb

    # set up brave browser
    if confirm "install brave browser?"; then
        yay -S --needed brave-bin
    else
        echo "skipping brave browser"
    fi

    # set up vscodium
    if confirm "install vscodium?"; then
        yay -S --needed vscodium-bin
    else
        echo "skipping vscodium"
    fi
else
    echo "skipping yay setup"
fi


# set up docker
if confirm "set up docker?"; then
    install_pacman_packages "${docker_apps[@]}"
    sudo usermod -aG docker "$USER"
    sudo systemctl enable --now docker.service
else
    echo "skipping docker setup"
fi


# set up virtualization
if confirm "set up virtualization?"; then
    install_pacman_packages "${virt_apps[@]}"
    sudo usermod -aG libvirt "$USER"
    sudo systemctl enable --now libvirtd.service
else
    echo "skipping virtualization setup"
fi


# set up printing
if confirm "set up printing?"; then
    install_pacman_packages "${print_apps[@]}"
    sudo systemctl enable --now cups.service
else
    echo "skipping printing setup"
fi


# display list of failed installs
if (( ${#failed_apps[@]} > 0 )); then
    echo -e "\n========================================="
    echo "The following packages failed to install:"
    echo "========================================="
    for i in "${failed_apps[@]}"; do
        echo -e "$i"
    done
else
    echo -e "\n============================================"
    echo "All selected packages installed successfully"
    echo "============================================"
fi


echo -e "\n#=======================#"
echo "# system setup complete #"
echo "#=======================#"
