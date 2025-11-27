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
    "wireshark-qt"
    "wl-clipboard"
    "yazi"
    "zathura"
    "zathura-pdf-poppler"
)


# list of packages that failed to install
failed=()


# update repo and install packages
echo "#=================================#"
echo "Welcome to the System Setup script!"
echo -e "#=================================#\n"
read -rp "install packages? [y/n]: " answer
echo "------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    for i in "${arch_apps[@]}"; do
        echo -e "\nattempting to install $i ..."
        sudo pacman -S --noconfirm "$i"
        if [ $? -ne 0 ]; then
            failed+=("$i")
        fi
    done
else
    echo "skipping package install"
fi


# install starship prompt
echo -e "\n#=============================#"
read -rp "install starship prompt? [y/n]: " answer
echo "#=============================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "skipping starship prompt"
fi


# clone dotfiles repo and set them up
echo -e "\n#==============================#"
read -rp "clone your dotfiles repo? [y/n]: " answer
echo "#==============================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\ncontinuing..."
    cd $HOME
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    if [ -f $HOME/.bashrc ]; then
        rm $HOME/.bashrc
    fi
    if [ -d $HOME/.config/hypr/ ]; then
        rm -rf $HOME/.config/hypr/
    fi
    if [ -d $HOME/.config/kitty/ ]; then
        rm -rf $HOME/.config/kitty/
    fi
    stow .
    echo "dotfiles applied. restart your shell to load new config"
else
    echo "skipping dotfiles"
fi


# create directories
echo -e "\n#==========================#"
read -rp "create directories? [y/n]: " answer
echo "#============================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME
    mkdir -p workspace/github.com/stevenkelso/
    if [ ! -d "$HOME/Pictures" ]; then
        mkdir -p "$HOME/Pictures"
    fi
    if [ ! -d "$HOME/Downloads" ]; then
        mkdir -p "$HOME/Downloads"
    fi
    if [ ! -d "$HOME/Documents" ]; then
        mkdir -p "$HOME/Documents"
    fi
else
    echo "skipping creation of directories"
fi


# set up docker
docker_apps=(
    "docker"
)
echo -e "\n#=======================#"
read -rp "set up docker? [y/n]:" answer
echo "#===================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    for i in "${docker_apps[@]}"; do
        echo -e "\nattempting to install $i ..."
        sudo pacman -S --noconfirm "$i"
        if [ $? -ne 0 ]; then
            failed+=("$i")
        fi
    done
    sudo usermod -aG docker $USER
    sudo systemctl enable --now docker.service
else
    echo "skipping docker setup"
fi


# set up virtualization
virt_apps=(
    "qemu-full"
    "virt-manager"
)
echo -e "\n#=======================#"
read -rp "set up virtualization? [y/n]:" answer
echo "#========================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    for i in "${virt_apps[@]}"; do
        echo -e "\nattempting to install $i ..."
        sudo pacman -S --noconfirm "$i"
        if [ $? -ne 0 ]; then
            failed+=("$i")
        fi
    done
    sudo usermod -aG libvirt $USER
    sudo systemctl enable --now libvirtd.service
else
    echo "skipping virtualization setup"
fi


# set up printing
print_apps=(
    "cups"
    "hplip"
    "python-pyqt5"
    "system-config-printer"
)
echo -e "\n#=====================#"
read -rp "set up printing? [y/n]:" answer
echo "#======================#"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    for i in "${print_apps[@]}"; do
        echo -e "\nattempting to install $i ..."
        sudo pacman -S --noconfirm "$i"
        if [ $? -ne 0 ]; then
            failed+=("$i")
        fi
    done
    sudo systemctl enable --now cups.service
else
    echo "skipping printing setup"
fi


# display list of failed installs
echo -e "\n#===============================================================#"
echo "these programs couldn't be installed through the package manager:"
echo "#===============================================================#"
for i in "${failed[@]}"; do
    echo -e "$i"
done


echo -e "\n#=======================#"
echo "# system setup complete #"
echo "#=======================#"
