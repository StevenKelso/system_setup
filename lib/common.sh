#!/bin/bash
# lib/common.sh — shared helpers and distro-agnostic setup steps
# Sourced by setup.sh after a distro file has been sourced.

failed_apps=()

#--- Helpers ---#

confirm() {
    echo -e "\n#======================================#"
    read -rp "$1 [y/n]: " answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# Called by distro-specific install helpers to record failures uniformly.
record_failure() {
    failed_apps+=("$1")
}

#--- Shared Setup Steps ---#

# Install the Starship prompt (distro-agnostic, installs via curl).
run_starship() {
    if confirm "Install starship prompt?"; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo "Skipping starship prompt."
    fi
}

# Clone dotfiles repo and apply via stow.
run_dotfiles() {
    cd "$HOME"
    mkdir -p "$HOME"/{Pictures,Downloads,Documents,repos/stevenkelso}

    if confirm "Clone your dotfiles repo and set up symlinks?"; then
        cd "$HOME/repos/stevenkelso"
        git clone https://github.com/StevenKelso/dotfiles
        cd "$HOME/repos/stevenkelso/dotfiles"

        # Remove files/dirs that stow will replace
        [ -f "$HOME/.bashrc" ]         && rm "$HOME/.bashrc"
        [ -d "$HOME/.config/hypr/" ]   && rm -rf "$HOME/.config/hypr/"
        [ -d "$HOME/.config/kitty/" ]  && rm -rf "$HOME/.config/kitty/"

        stow -t "$HOME" .
        echo "Dotfiles applied. Restart your shell to load the new config."
    else
        echo "Skipping dotfiles."
    fi
}

# Print summary of any packages that failed to install.
print_summary() {
    echo -e "\n#=======================#"
    echo "#  system setup complete #"
    echo "#=======================#"

    if (( ${#failed_apps[@]} > 0 )); then
        echo -e "\n========================================="
        echo "The following packages failed to install:"
        echo "========================================="
        for pkg in "${failed_apps[@]}"; do
            echo "  - $pkg"
        done
    else
        echo -e "\nAll selected packages installed successfully."
    fi
}
