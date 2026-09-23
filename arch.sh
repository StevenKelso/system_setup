#!/bin/bash

pkgs=(
    # -- system --
    "awww"
    "brightnessctl"
    "fuse2"
    "fuse3"
    "man-db"
    "man-pages"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "ttf-iosevka-nerd"
    "udiskie"
    "unzip"
    "wl-clipboard"
    "xwayland-satellite"

    # -- media --
    "imagemagick"
    "imv"
    "pavucontrol"
    "perl-image-exiftool"
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "wireplumber"

    # -- networking --
    "bind"
    "mtr"
    "openbsd-netcat"

    # -- programming / dependencies --
    "argparse"
    "git"
    "go"
    "jq"
    "luarocks"
    "make"
    "npm"
    "python"
    "tree-sitter-cli"

    # -- workflow --
    "bat"
    "eza"
    "fd"
    "fzf"
    "grim"
    "ironbar"
    "mako"
    "neovim"
    "niri"
    "keepassxc"
    "kitty"
    "ripgrep"
    "rofi"
    "satty"
    "slurp"
    "swayidle"
    "swaylock"
    "starship"
    "stow"
    "tldr"
    "wlsunset"
)
amd_pkgs=("mesa" "vulkan-radeon" "xf86-video-amdgpu" "xf86-video-ati")
intel_pkgs=("mesa" "vulkan-intel" "intel-media-driver" "libva-intel-driver")
nvidia_pkgs=("dkms" "libva-nvidia-driver" "nvidia-open-dkms")
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

    echo -e "\nInstall graphics packages? "
    read -rp "[amd/intel/nvidia/none]: " gpu_answer
    case "$gpu_answer" in
        amd)
            for pkg in "${amd_pkgs[@]}"; do
                echo -e "\nAttempting to install: $pkg ..."
                if ! sudo pacman -S --noconfirm "$pkg"; then
                    failed_pkgs+=("$pkg")
                fi
            done
            ;;
        intel)
            for pkg in "${intel_pkgs[@]}"; do
                echo -e "\nAttempting to install: $pkg ..."
                if ! sudo pacman -S --noconfirm "$pkg"; then
                    failed_pkgs+=("$pkg")
                fi
            done
            ;;
        nvidia)
            for pkg in "${nvidia_pkgs[@]}"; do
                echo -e "\nAttempting to install: $pkg ..."
                if ! sudo pacman -S --noconfirm "$pkg"; then
                    failed_pkgs+=("$pkg")
                fi
            done
            ;;
        *)
            echo "Skipping graphics packages."
            ;;
    esac
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
