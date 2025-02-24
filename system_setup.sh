#!/bin/bash

# list of arch packages
arch_apps=(
    # list here
)

# list of opensuse packages
opensuse_apps=(
"git"
"stow"
"firefox"
"keepassxc"
"kitty"
"neovim"
"tmux"
"ranger"
"rofi-wayland"
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
"make"
"mozilla-openh264"
)

# list of void packages
void_apps=(
    #list here
)

# list of packages that failed to install
failed=()

# determine package manager
read -rp "What is your package manager? (pacman/zypper/xbps) " pm

# update repo and install packages
case "$pm" in
    "pacman")
        sudo pacman -Syu
        for i in "${arch_apps[@]}"; do
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
        for i in "${opensuse_apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo zypper install -y $i
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "xbps")
        sudo xbps-install -Su
        for i in "${void_apps[@]}"; do
            echo -e "\nAttempting to install $i ..."
            sudo xbps-install -S $i -y
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    *)
        echo "Skipping package installation"
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
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraMono.zip
    unzip FiraMono.zip
    mv FiraMonoNerdFont-Regular.otf ~/.local/share/fonts
else
    echo "Skipping nerdfont"
fi

# clone dotfiles repo and set them up
echo ""
read -rp "Do you want to clone your dotfiles repo? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo -e "\nContinuing..."
    cd $HOME
    rm $HOME/.bashrc
    git clone https://github.com/StevenKelso/dotfiles
    cd dotfiles
    stow .
else
    echo "Skipping dotfiles"
fi

# create workspace directory
cd $HOME
mkdir -p workspace/github.com/stevenkelso/
