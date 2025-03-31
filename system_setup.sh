#!/bin/bash

# list of arch packages
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
)

# list of void packages
void_apps=(
    #list here
)

# list of packages that failed to install
failed=()

# determine package manager
read -rp "install packages with your package manager? (pacman/xbps/skip) " pm

# update repo and install packages
case "$pm" in
    "pacman")
        sudo pacman -Syu
        for i in "${arch_apps[@]}"; do
            echo -e "\nattempting to install $i ..."
            sudo pacman -S $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "xbps")
        sudo xbps-install -Su
        for i in "${void_apps[@]}"; do
            echo -e "\nattempting to install $i ..."
            sudo xbps-install -S $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    *)
        echo "skipping package installation"
esac

# display list of failed installs
echo -e "\nthese programs couldn't be installed through the package manager:"
for i in "${failed[@]}"; do
    echo -e "$i"
done

# install starship prompt
echo ""
read -rp "install starship prompt? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh
else
    echo "skipping starship prompt"
fi

# install nerdfont
echo ""
read -rp "install nerdfont? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME/Downloads
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraMono.zip
    unzip FiraMono.zip
    mv FiraMonoNerdFont-Regular.otf ~/.local/share/fonts
else
    echo "skipping nerdfont"
fi

# clone dotfiles repo and set them up
echo ""
read -rp "clone your dotfiles repo? [y/n]: " answer
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

# create workspace directory
echo ""
read -rp "create github workspace directory structure? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME
    mkdir -p workspace/github.com/stevenkelso/
else
    echo "skipping github workspace directory structure"
fi

echo "#######################"
echo "system install complete"
echo "#######################"
