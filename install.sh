#!/bin/bash

confirm_start() {
    while true; do
        read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
        case $yn in
            [Yy]* )
                echo "Installation started."
                break
                ;;
            [Nn]* ) 
                exit
                break
                ;;
            * ) echo "Please answer yes or no."
                ;;
        esac
    done
}

install_pacman() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed base-devel git
    (cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si)
    echo "paru installed"
}

copy_sources() {
    echo "copy sources from git repos"
    git_repos=(
        "dotfiles https://gitlab.com/stephan-raabe/dotfiles.git"
        "fish https://github.com/tonybeyond/nixos_config.git"
        "mynvim https://github.com/tonybeyond/nvim.git"
        "polybar_git1 https://github.com/jdpedersen1/polybar.git"
        "polybar_git2 https://github.com/thelinuxfraud/qtile.git"
    )

    for repo in "${git_repos[@]}"; do
        repo_name=$(echo "$repo" | cut -d' ' -f1)
        repo_url=$(echo "$repo" | cut -d' ' -f2)
        git clone "$repo_url" "~/dotfiles/$repo_name"
    done
}

install_packages() {
    declare -a packages_pacman=(
        "nodejs" "qtile" "neofetch" "tmux" "exa" "ranger" "fish" "open-vm-tools"
        "alacritty" "scrot" "nitrogen" "picom" "starship" "slock" "neovim" "rofi"
        "dunst" "ueberzug" "mpv" "xfce4-power-manager" "python-pip" "thunar"
        "mousepad" "ttf-font-awesome" "ttf-fira-sans" "ttf-fira-code" "ttf-firacode-nerd"
        "figlet" "cmatrix" "lxappearance" "polybar" "breeze" "breeze-gtk" "rofi-calc"
        "vlc" "python-psutil" "python-rich" "python-click"
    )

    declare -a packages_paru=(
        "brave-bin" "pfetch" "bibata-cursor-theme" "shell-color-scripts" "preload"
    )

    install_packages_pacman "${packages_pacman[@]}"
    install_packages_paru "${packages_paru[@]}"
}

install_packages_pacman() {
    local to_install=()
    for pkg in "$@"; do
        pacman -Qs --color always "${pkg}" | grep "local" | grep "${pkg}" && continue
        to_install+=("${pkg}")
    done

    if [[ "${to_install[@]}" == "" ]]; then
        return
    fi

    sudo pacman --noconfirm -S "${to_install[@]}"
}

install_packages_paru() {
    local to_install=()
    for pkg in "$@"; do
        paru -Qs --color always "${pkg}" | grep "local" | grep "${pkg}" && continue
        to_install+=("${pkg}")
    done

    if [[ "${to_install[@]}" == "" ]]; then
        if [[ "${to_install[@]}" == "" ]]; then
            return
        fi
        paru --noconfirm -S "${to_install[@]}"
    fi
}

install_pywal() {
    if [ ! -f /usr/bin/wal ]; then
        paru --noconfirm -S pywal
    else
        echo "pywal already installed."
    fi
}

enable_services() {
    sudo systemctl enable preload
}

create_config_folder() {
    if [ ! -d ~/.config ]; then
        mkdir ~/.config
        echo ".config folder created."
    else
        echo ".config folder already exists."
    fi
}

install_symbolic_links() {
    symbolic_links=(
        "~/.config/qtile ~/dotfiles/qtile/ ~/.config"
        # Add other symbolic link installations as needed...
    )

    for link in "${symbolic_links[@]}"; do
        symlink=$(echo "$link" | cut -d' ' -f1)
        linksource=$(echo "$link" | cut -d' ' -f2)
        linktarget=$(echo "$link" | cut -d' ' -f3)

        if [ -L "${symlink}" ]; then
            echo "Link ${symlink} exists already."
        else
            if [ -d ${symlink} ]; then
                echo "Directory ${symlink}/ exists."
            else
                if [ -f ${symlink} ]; then
                    echo "File ${symlink} exists."
                else
                    ln -s ${linksource} ${linktarget} 
                    echo "Link ${linksource} -> ${linktarget} created."
                fi
            fi
        fi
    done
}

install_bashrc() {
    while true; do
        read -p "Do you want to replace the existing .bashrc file? (Yy/Nn): " yn
        case $yn in
            [Yy]* )
                rm ~/.bashrc
                echo ".bashrc removed"
                break;;
            [Nn]* ) 
                echo "Replacement of .bashrc skipped."
                break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    ln -s ~/dotfiles/.bashrc ~/.bashrc
}

# Add functions for theme installation, wallpaper installation, etc.

confirm_start
install_pacman
copy_sources
install_packages
install_pywal
enable_services
create_config_folder
install_symbolic_links
install_bashrc

# Install Theme, Icons and Cursor
# Add theme installation steps as needed...

# Install wallpapers
# Add wallpaper installation steps as needed...

# Init pywal
wal -i ~/dotfiles/default.jpg
echo "pywal initiated."

# DONE
clear
echo "DONE!"
echo "don't forget to check qtile/autostart.sh and picom configs, as well as the neofetch entry in .bashrc"
