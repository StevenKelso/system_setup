#!/bin/bash

# list of packages to be installed
apps=(
"git"
"stow"
"firefox"
"keepassxc"
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
"eza"
"fzf"
"ripgrep"
)

# list of packages that failed to install
failed=()

# determine package manager
read -rp "What is your package manager? (pacman/zypper/xbps) " pm

# update repo and install packages
case "$pm" in
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
        sudo zypper refresh
        sudo zypper dup
        for i in "${apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo zypper install -y $i
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
    *)
        echo "Not a valid package manager"
esac

# display list of failed installs
echo -e "\nThese programs couldn't be installed through the package manager:"
for i in "${failed[@]}"; do
    echo -e "$i"
done

# install starship prompt
echo ""
read -rp "Do you want to install the starship prompt? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Skipping starship prompt"
fi

# install nerdfont
echo ""
read -rp "Do you want to install a nerdfont? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME/Downloads
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraMono.zip
    unzip FiraMono.zip
    mv FiraMonoNerdFont-Regular.otf ~/.local/share/fonts
else
    echo "Skipping nerdfont"
fi

# optionally clone dotfiles repo and set them up
echo ""
read -rp "Do you want to clone your dotfiles repo? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\nContinuing..."
    cd $HOME
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    stow .
else
    echo "Skipping dotfiles"
fi
