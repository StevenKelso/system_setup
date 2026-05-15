#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/common.sh"

#--- Distro Selection ---#

SUPPORTED_DISTROS=("arch")

select_distro_interactive() {
    echo "" >&2
    echo "Select a distro to set up:" >&2
    local i=1
    for d in "${SUPPORTED_DISTROS[@]}"; do
        echo "  $i) $d" >&2
        (( i++ ))
    done
    echo "" >&2
    read -rp "Enter number or distro name: " choice <&2

    # Accept either a number or a name
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        local idx=$(( choice - 1 ))
        if (( idx >= 0 && idx < ${#SUPPORTED_DISTROS[@]} )); then
            echo "${SUPPORTED_DISTROS[$idx]}"
        else
            echo "Error: Invalid selection '$choice'." >&2
            exit 1
        fi
    else
        echo "$choice"
    fi
}

DISTRO=$(select_distro_interactive)

case "$DISTRO" in
    arch)
        source "$SCRIPT_DIR/distros/arch.sh"
        ;;
    *)
        echo "Error: Unsupported distro: '$DISTRO'"
        echo "Supported distros: ${SUPPORTED_DISTROS[*]}"
        exit 1
        ;;
esac

#--- Main ---#
echo "#=================================#"
echo "Welcome to the System Setup script!"
echo "Selected distro: $DISTRO"
echo "#=================================#"

run_package_install
run_starship
run_dotfiles
run_docker
run_virt
print_summary
