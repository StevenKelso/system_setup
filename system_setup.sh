#!/bin/bash

#--- list of arch packages ---#
arch_apps=(
    "aws-cli-v2"
    "bat"
    "btop"
    "bind" # package containing "dig and nslookup"
    "cups"
    "discord"
    "docker"
    "dunst"
    "eza"
    "fd"
    "firefox"
    "fzf"
    "gammastep"
    "git"
    "github-cli"
    "gnu-netcat"
    "grim"
    "hplip"
    "hyprland"
    "hyprlock"
    "hyprpaper"
    "jq"
    "k9s"
    "keepassxc"
    "kitty"
    "lazygit"
    "make"
    "man-db"
    "man-pages"
    "mtr"
    "neovim"
    "nmap"
    "otf-firamono-nerd"
    "python-pip"
    "qemu-full"
    "ripgrep"
    "rofi"
    "rsync"
    "slurp"
    "stow"
    "system-config-printer"
    "tcpdump"
    "tldr"
    "tmux"
    "udiskie"
    "unzip"
    "virt-manager"
    "waybar"
    "yazi"
    "yq"
)


#--- list of packages that failed to install ---#
failed=()


#--- update repo and install packages ---#
echo ""
read -rp "install packages? [y/n]: " answer
echo "------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    sudo pacman -Syu
    for i in "${arch_apps[@]}"; do
        echo -e "\nattempting to install $i ..."
        sudo pacman -S --noconfirm $i
        if [ $? -ne 0 ]; then
            failed=("${failed[@]}" "$i")
        fi
    done
else
    echo "skipping package install"
fi


#--- install starship prompt ---#
echo ""
read -rp "install starship prompt? [y/n]: " answer
echo "-------------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh
else
    echo "skipping starship prompt"
fi


#--- install tmux package manager ---#
echo ""
read -rp "install tmux package manager? [y/n]: " answer
echo "------------------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "skipping tmux package manager"
fi


#--- clone dotfiles repo and set them up ---#
echo ""
read -rp "clone your dotfiles repo? [y/n]: " answer
echo "--------------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\ncontinuing..."
    cd $HOME
    rm $HOME/.bashrc
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    stow .
else
    echo "skipping dotfiles"
fi


#--- create workspace directory ---#
echo ""
read -rp "create github workspace directory structure? [y/n]: " answer
echo "---------------------------------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME
    mkdir -p workspace/github.com/stevenkelso/
else
    echo "skipping github workspace directory structure"
fi

#--- source .bashrc and .tmux.conf ---#
echo ""
echo "sourcing .bashrc and .tmux.conf"
echo "-------------------------------"
source $HOME/.bashrc
source $HOME/.tmux.conf

#--- set up docker ---#
echo ""
echo -rp "set up docker? [y/n]:" answer
echo "---------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    newgrp docker
    sudo usermod -aG docker $USER
    sudo systemctl start docker.service
    sudo systemctl enable docker.service
else
    echo "skipping docker setup"
fi

#--- set up virtualization ---#
echo ""
echo -rp "set up virtualization? [y/n]:" answer
echo "--------------------------"
if [[ "$answer" =~ ^[Yy]$ ]]; then
    newgrp libvirt
    sudo usermod -aG libvirt $USER
    sudo systemctl start libvirtd.service
    sudo systemctl enable libvirtd.service
else
    echo "skipping virtualization setup"
fi

#--- display list of failed installs ---#
echo ""
echo "these programs couldn't be installed through the package manager:"
echo "-----------------------------------------------------------------"
for i in "${failed[@]}"; do
    echo -e "$i"
done


echo ""
echo "#########################"
echo "# system setup complete #"
echo "#########################"
