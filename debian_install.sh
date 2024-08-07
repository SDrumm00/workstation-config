#!/bin/bash

 # Exit immediately if any command returns a non-zero status.
set -e 

#########################################
## Software Installation Step
# Define the list of packages to install.
PACKAGES_TO_INSTALL=(
  "xorg"
  "firefox-esr"
  "i3"
  "alacritty"
  "feh"
  "picom"
  "redshift"
  "git"
  "wget"
  "curl"
  "i3lock"
  "i3lock-fancy"
  "i3status"
  "dmenu"
  "btop"
  "neofetch"
  "x11-xserver-utils" # xrandr
)

echo "Installing $PACKAGES_TO_INSTALL..."

# Update package list
if ! apt-get update -qq; then
    echo "Error updating package list!"
    exit 1
fi

# Install packages.
for package in "${PACKAGES_TO_INSTALL[@]}"; do
   if ! apt-get install -y "$package" ; then
       echo "Failed to install $package: $(apt-get config | grep 'APT::Error::Status')"
       exit 1
   fi
done

echo "Software installation complete!"

#########################################
## System Upgrade
echo "Performing system upgrade..."

if ! apt-get update && apt-get upgrade -y; then
    echo "Failed to upgrade the system."
    exit 1
fi

echo "System upgrade complete!"

#########################################
## Make directories for custom config files
echo "Creating directories for custom configs..."

# Get the home directory of the current user under sudo context
USER_HOME=$(eval echo ~$SUDO_USER)

# Check if we got a valid home directory path
if [ -z "$USER_HOME" ]; then
    echo "Home directory not found."
    exit 1
fi

#########################################
# Install Nerd Fonts - Fira Code system wide
# Define the directory where you want to clone the repo
CLONE_DIR="$USER_HOME/tmp/nerd-fonts"

# Ensure the directory exists and is empty
sudo -u "$SUDO_USER" mkdir -p "$CLONE_DIR"

# fetch the fonts
git clone --depth 1 --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git "$CLONE_DIR"
cd "$CLONE_DIR"

# Perform sparse checkout to fetch only the necessary fonts
git sparse-checkout init --cone
git sparse-checkout set patched-fonts/IBMPlexMono

# create installation directories
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.local/share/fonts/"

# install the fonts
# https://github.com/ryanoasis/nerd-fonts/blob/master/install.sh
./install.sh -S IBMPlexMono # -S argument is for systemwide installation

echo "Nerd Fonts - IBMPlexMono installed successfully in /root/.local/share/fonts/NerdFonts"

#########################################
# Copy files from cloned repo into target directories.
echo "Copying custom config files..."

# i3 config file
# Make dir
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.config/i3"

# copy files
cp $USER_HOME/tmp/workstation-config/i3/config "$USER_HOME/.config/i3/"
if [ $? -ne 0 ]; then
   echo "Error copying bash configuration file."
   exit 1
fi

echo "i3 config copied successfully! You can find it at $USER_HOME/.config/i3/config"

# Wallpapers
# Make dir
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/Pictures/Wallpapers"

# Copy files
cp $USER_HOME/tmp/workstation-config/wallpapers/Wallpaper-254.png "$USER_HOME/Pictures/Wallpapers/Wallpaper-254.png"
if [ $? -ne 0 ]; then
   echo "Error copying wallpaper file."
   exit 1
fi

echo "Wallpapers copied successfully! You can find it at $USER_HOME/Pictures/Wallpapers/"

# Picom config file
# Check if target directory exists, create if it doesn't
PICOM_CONFIG_DIR="$USER_HOME/.config/picom"
if [ ! -d "$PICOM_CONFIG_DIR" ]; then
    mkdir -p "$PICOM_CONFIG_DIR"
    if [ $? -ne 0 ]; then
        echo "Error creating directory $PICOM_CONFIG_DIR."
        exit 1
    fi
fi

# Check if the picom.conf file already exists
if [ ! -f "$PICOM_CONFIG_DIR/picom.conf" ]; then
    # Copy files
    sudo -u "$SUDO_USER" cp "$USER_HOME/tmp/workstation-config/picom/picom.conf" "$PICOM_CONFIG_DIR"
    if [ $? -ne 0 ]; then
       echo "Error copying picom conf file."
       exit 1
    fi
    echo "Picom config file copied successfully! You can find it at $PICOM_CONFIG_DIR"
else
    echo "Picom config file already exists at $PICOM_CONFIG_DIR. Skipping copy."
fi

#########################################
## Clean up temporary directory on successful completion

# Define a function to clean up temporary directory and contents
cleanup_tmp_directory() {
    if [ -d "$USER_HOME/tmp" ]; then
        rm -rf "$USER_HOME/tmp"
        echo "tmp directory removed."
    else
        echo "tmp directory does not exist."
    fi
}

# Register the cleanup function to be called on EXIT
trap cleanup_tmp_directory EXIT

# TODO
# need to configure permissions on the directory the fonts were copied to "tmp/nerd-fonts"
# still need to configure the fonts
# make sure to do checks such as the directory already exists therefore skip this step
# install zsh