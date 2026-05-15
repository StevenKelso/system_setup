# system_setup

A modular post-install setup script for Linux. Installs packages, sets up dotfiles, and configures services — with a confirmation prompt at every step so you can selectively run only the steps you want to run.

## Supported Distros

| Distro | Package Manager | Init System |
|--------|----------------|-------------|
| Arch   | pacman         | systemd     |

> Void and Artix support may be added in the future.

## Installation

Clone the repo to wherever you keep your projects:

```bash
git clone https://github.com/StevenKelso/system_setup
cd system_setup/
chmod +x setup.sh
```

## Usage

Run the setup.sh script.

```bash
./setup.sh
```

You'll be prompted to select your distro, then walked through each setup step one at a time.

## What It Sets Up

Each of the following is a separate yes/no prompt, so you can just skip anything you don't need:

- **Packages** — full package list for the selected distro
- **Starship** — installs the [Starship](https://starship.rs) prompt via the official installer
- **Dotfiles** — clones your dotfiles repo and applies symlinks via `stow`
- **Docker** — installs Docker and enables the daemon
- **Virtualization** — installs QEMU + virt-manager and enables libvirtd

At the end, a summary lists any packages that failed to install.

## Project Structure

```
setup/
├── setup.sh            # entry point
├── lib/
│   └── common.sh       # distro-agnostic steps and shared helpers
└── distros/            # distro-specific packages and service setup
    └── arch.sh
```

## Adding a New Distro

1. Create `distros/<distro>.sh` and implement these functions:
   - `run_package_install`
   - `run_docker`
   - `run_virt`
2. Add the distro name to `SUPPORTED_DISTROS` in `setup.sh`
3. Add a matching `case` entry to source your new file
