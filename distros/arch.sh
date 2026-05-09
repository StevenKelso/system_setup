#!/bin/bash
# distros/arch.sh — Arch Linux specific packages and setup steps.
# Sourced by setup.sh; relies on helpers defined in lib/common.sh.

#--- Package Lists ---#

arch_apps=(
    # shell / CLI tools
    "bat"
    "cloc"
    "eza"
    "fd"
    "fzf"
    "jq"
    "openbsd-netcat"
    "ripgrep"
    "stow"
    "tldr"
    "unzip"

    # development
    "argparse"
    "git"
    "github-cli"
    "go"
    "luarocks"
    "make"
    "neovim"
    "python"
    "rust"
    "tree-sitter-cli"
    "uv"

    # system / hardware
    "brightnessctl"
    "fuse2"
    "man-db"
    "man-pages"
    "udiskie"

    # fonts
    "noto-fonts-cjk"
    "noto-fonts-emoji"
    "ttf-iosevka-nerd"

    # Wayland / desktop
    "dunst"
    "hypridle"
    "hyprland"
    "hyprlock"
    "hyprpaper"
    "hyprshot"
    "hyprsunset"
    "keepassxc"
    "kitty"
    "rofi"
    "satty"
    "waybar"
    "wl-clipboard"

    # audio (pipewire stack)
    "pavucontrol"
    "pipewire"
    "pipewire-pulse"
    "pipewire-alsa"
    "wireplumber"

    # network
    "bind"
    "mtr"
    "nmap"
    "tcpdump"
    "traceroute"
    "wireshark-qt"

    # media / files
    "firefox"
    "imagemagick"
    "imv"
    "perl-image-exiftool"
    "yazi"

    # remote desktop / screen tools
    "freerdp"
    "remmina"
)

arch_docker_apps=("docker")

arch_virt_apps=("dnsmasq" "qemu-full" "virt-manager")

#--- Helpers ---#

_install_pacman_packages() {
    local pkgs=("$@")
    for pkg in "${pkgs[@]}"; do
        echo -e "\nAttempting to install: $pkg ..."
        if ! sudo pacman -S --needed --noconfirm "$pkg"; then
            record_failure "$pkg"
        fi
    done
}

#--- Distro Interface (called by setup.sh) ---#

run_package_install() {
    if confirm "Update repos and install packages?"; then
        sudo pacman -Syu --noconfirm
        _install_pacman_packages "${arch_apps[@]}"
    else
        echo "Skipping package install."
    fi
}

run_docker() {
    if confirm "Set up Docker?"; then
        _install_pacman_packages "${arch_docker_apps[@]}"
        sudo usermod -aG docker "$USER"
        sudo systemctl enable --now docker.service
    else
        echo "Skipping Docker setup."
    fi
}

run_virt() {
    if confirm "Set up virtualization (QEMU + virt-manager)?"; then
        _install_pacman_packages "${arch_virt_apps[@]}"
        sudo usermod -aG libvirt "$USER"
        sudo systemctl enable --now libvirtd.service
    else
        echo "Skipping virtualization setup."
    fi
}
