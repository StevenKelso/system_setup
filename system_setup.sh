#!/bin/bash

#--- list of arch packages ---#
arch_apps=(
    "git"
    "github-cli"
    "stow"
    "firefox"
    "keepassxc"
    "kitty"
    "neovim"
    "tmux"
    "hyprland"
    "hyprpaper"
    "hyprlock"
    "waybar"
    "rofi-wayland"
    "eza"
    "fzf"
    "ripgrep"
    "make"
    "btop"
    "unzip"
    "lazygit"
    "man-db"
    "man-pages"
    "cups"
    "system-config-printer"
    "hplip"
    "traceroute"
    "mtr"
    "nmap"
    "bind" # the package that contains "dig and nslookup"
    "gnu-netcat"
    "gammastep"
    "tcpdump"
    "wireshark-qt"
    "dunst"
    "grim"
    "slurp"
    "rsync"
    "fd"
    "udiskie"
    "otf-firamono-nerd"
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
