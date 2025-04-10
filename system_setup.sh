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
    "lazygit"
    "man-db"
    "man-pages"
    "yazi"
    "cups"
    "system-config-printer"
)

# list of void packages
void_apps=(
    "git"
    "github-cli"
    "stow"
    "firefox"
    "keepassxc"
    "kitty"
    "neovim"
    "tmux"
    "eza"
    "fzf"
    "ripgrep"
    "make"
    "btop"
    "unzip"
    "lazygit"
    "yazi"
    "cups"
    "avahi"
)

opensuse_apps=(
    "git"
    "stow"
    "firefox"
    "keepassxc"
    "kitty"
    "neovim"
    "tmux"
    "yazi"
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

# list of packages that failed to install
failed=()

# determine package manager
read -rp "install packages with your package manager? (pacman/xbps/zypper/skip) " pm

# update repo and install packages
case "$pm" in
    "pacman")
        sudo pacman -Syu
        for i in "${arch_apps[@]}"; do
            echo -e "\nattempting to install $i ..."
            sudo pacman -S --noconfirm $i
            if [ $? -ne 0 ]; then
                failed=("${failed[@]}" "$i")
            fi
        done
        ;;
    "xbps")
        sudo xbps-install -Su
        for i in "${void_apps[@]}"; do
            echo -e "\nattempting to install $i ..."
            sudo xbps-install $i -y
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

# install tmux package manager
echo ""
read -rp "install tmux package manager? [y/n]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    cd $HOME
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "skipping tmux package manager"
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
echo "system setup complete"
echo "#######################"
