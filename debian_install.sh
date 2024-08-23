#!/bin/bash

#########################################
# Author: Scott Drumm
# Create Date: 20240810
#
# Description:
# This script is designed with Debian in mind. It will take an existing minimal installation of Debian and perform all
# of the following:
#
# 1) Upgrade the system
# 2) Install all the required applications
# 3) Install any custom fonts
# 4) Git Clone any custom configs from my repo
#    - located on my github at https://github.com/SDrumm00/workstation-config
# 5) Clean itself up and remove any tmp files
#########################################

# Exit immediately if any command returns a non-zero status.
set -e 

# Check if the script is being run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script needs to be run with sudo."
    exit 1
fi

# Determine the non-root user who invoked the script
ORIGINAL_USER="$SUDO_USER"
USER_HOME="$(eval echo ~$ORIGINAL_USER)"

# Verify USER_HOME is set correctly
if [ ! -d "$USER_HOME" ]; then
    echo "Error: USER_HOME ($USER_HOME) is not a valid directory. Ensure the script is run with sudo from a valid user."
    exit 1
fi

#########################################
# System Upgrade
#########################################

echo "######### Checking System Upgrade #########"

# Update the package index to get the latest information
if ! apt-get update -qq; then
    echo "Error updating package list!"
    exit 1
fi

# Check for upgradable packages
UPGRADEABLE_PACKAGES=$(apt list --upgradable 2>/dev/null | grep -E 'upgradable from' || true)

if [ -n "$UPGRADEABLE_PACKAGES" ]; then
    echo "Updates are available. Proceeding with system upgrade..."
    # Perform system upgrade
    if ! apt-get upgrade -y; then
        echo "Failed to upgrade the system."
        exit 1
    fi
else
    echo "######### No Upgrades Available #########"
fi

#########################################
# Software Installation
#########################################

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

echo "######### Updating Package List #########"
# Update package list
if ! apt-get update -qq; then
    echo "Error updating package list!"
    exit 1
fi

echo "######### Package List Updated #########"

echo "######### Installing Packages #########"
# Install packages.
for package in "${PACKAGES_TO_INSTALL[@]}"; do
   if dpkg -l | grep -qw "$package"; then
       echo "$package is already installed. Skipping..."
   else
       echo "Installing $package..."
       if ! apt-get install -y "$package" ; then
           echo "Failed to install $package"
           exit 1
       fi
   fi
done

echo "######### Installation Complete #########"

#########################################
# Install Custom Fonts
#########################################

echo "######### Installing Custom Fonts #########"

# Define the clone directory
CLONE_DIR="$USER_HOME/tmp/nerd-fonts"

# Check if the directory exists and has any files in it
if [ -d "$CLONE_DIR" ] && [ "$(ls -A "$CLONE_DIR")" ]; then
    echo "Directory $CLONE_DIR exists and is not empty. Cleaning out directory..."
    rm -rf "$CLONE_DIR" || { echo "Error cleaning out directory $CLONE_DIR."; exit 1; }
fi

# Clone the repository and perform sparse checkout
echo "Cloning Nerd Fonts repository..."
git clone --depth 1 --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git "$CLONE_DIR" &&
cd "$CLONE_DIR" &&
git sparse-checkout init --cone &&
git sparse-checkout set patched-fonts/IBMPlexMono || { echo "Error during git operations."; exit 1; }

# Create the fonts directory if it doesn't exist
FONTS_DIR="$USER_HOME/.local/share/fonts/"
echo "Creating fonts directory if it doesn't exist..."
mkdir -p "$FONTS_DIR" || { echo "Error creating fonts directory $FONTS_DIR."; exit 1; }

# Install the fonts
echo "Installing fonts..."
sudo ./install.sh -S IBMPlexMono || { echo "Error installing fonts."; exit 1; }

echo "######### Custom Fonts Installed #########"

#########################################
# Load Custom Configs
#########################################

echo "######### Load Custom Configs #########"

# i3 config file
# Define the path for the i3 config directory and file
I3_CONFIG_DIR="$USER_HOME/.config/i3"
I3_CONFIG_FILE="$I3_CONFIG_DIR/config"
SOURCE_FILE="$USER_HOME/tmp/workstation-config/i3/config"

# Check if the directory exists, create it if it doesn't
if [ ! -d "$I3_CONFIG_DIR" ]; then
    echo "Creating directory $I3_CONFIG_DIR"
    mkdir -p "$I3_CONFIG_DIR" || { echo "Error creating directory $I3_CONFIG_DIR."; exit 1; }
fi

# Check if the target file exists
if [ -f "$I3_CONFIG_FILE" ]; then
    echo "Target file $I3_CONFIG_FILE exists and will be overwritten."
else
    echo "Target file $I3_CONFIG_FILE does not exist. Copying source file to target."
fi

# Prompt user for confirmation
read -p "Proceed with overwriting the existing file? (Y/N): " USER_INPUT

# Convert user input to lowercase
USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')

# Check user input and proceed or exit
if [[ "$USER_INPUT" == "y" || "$USER_INPUT" == "yes" ]]; then
    # Copy the configuration file, overwriting if the target file exists
    echo "Overwriting i3 config file..."
    cp -f "$SOURCE_FILE" "$I3_CONFIG_FILE" || { echo "Error copying i3 configuration file."; exit 1; }
    echo "i3 config file operation completed!"
else
    echo "Skipping i3 copy operation."
fi

# Wallpapers
# Define the paths for the wallpaper directory and file
WALLPAPER_DIR="$USER_HOME/Pictures/Wallpapers"
WALLPAPER_FILE="$USER_HOME/tmp/workstation-config/wallpapers/Wallpaper-254.png"

# Check if the directory exists, create it if it doesn't
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Creating directory $WALLPAPER_DIR"
    mkdir -p "$WALLPAPER_DIR" || { echo "Error creating directory $WALLPAPER_DIR."; exit 1; }
fi

# Check if the source wallpaper file exists
if [ -f "$WALLPAPER_FILE" ]; then
    echo "Source wallpaper file $WALLPAPER_FILE exists."
else
    echo "Warning: Source wallpaper file $WALLPAPER_FILE does not exist."
fi

# Prompt user for confirmation
read -p "Proceed with overwriting the wallpaper file? (Y/N): " USER_INPUT

# Convert user input to lowercase
USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')

# Check user input and proceed or skip the file copy
if [[ "$USER_INPUT" == "y" || "$USER_INPUT" == "yes" ]]; then
    # Copy the wallpaper file
    echo "Overwriting wallpaper file..."
    cp -f "$WALLPAPER_FILE" "$WALLPAPER_DIR/" || { echo "Error copying wallpaper file."; exit 1; }
    echo "Wallpaper copied successfully! You can find it at $WALLPAPER_DIR/"
else
    echo "Skipping wallpaper operation."
fi

# Picom config file
# Define the paths for the Picom config directory and files
PICOM_CONFIG_DIR="$USER_HOME/.config/picom"
PICOM_CONF_FILE="$PICOM_CONFIG_DIR/picom.conf"
SOURCE_CONF_FILE="$USER_HOME/tmp/workstation-config/picom/picom.conf"

# Ensure the target directory exists
if [ ! -d "$PICOM_CONFIG_DIR" ]; then
    echo "Creating directory $PICOM_CONFIG_DIR"
    mkdir -p "$PICOM_CONFIG_DIR" || { echo "Error creating directory $PICOM_CONFIG_DIR."; exit 1; }
fi

# Set permissions on target directory
chown -R "$ORIGINAL_USER:$ORIGINAL_USER" "$PICOM_CONFIG_DIR"

# Check if the picom.conf file exists
if [ -f "$PICOM_CONF_FILE" ]; then
    echo "Picom config file $PICOM_CONF_FILE already exists."
else
    echo "Picom config file $PICOM_CONF_FILE does not exist."
fi

# Prompt user for confirmation
read -p "Proceed with overwriting the Picom config file? (Y/N): " USER_INPUT

# Convert user input to lowercase
USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')

# Check user input and proceed or skip the file copy
if [[ "$USER_INPUT" == "y" || "$USER_INPUT" == "yes" ]]; then
    # Copy the Picom config file
    echo "Overwriting Picom config file..."
    cp -f "$SOURCE_CONF_FILE" "$PICOM_CONF_FILE" || { echo "Error copying Picom config file."; exit 1; }
    echo "Picom config file copied successfully! You can find it at $PICOM_CONFIG_DIR"
else
    echo "Skipping Picom config file operation."
fi

# Alacritty config file
# Define the paths for the Alacritty config directory and files
ALACRITTY_CONFIG_DIR="$USER_HOME/.config/alacritty"
ALACRITTY_CONF_FILE="$ALACRITTY_CONFIG_DIR/alacritty.toml"
SOURCE_CONF_FILE="$USER_HOME/tmp/workstation-config/alacritty/alacritty.toml"

# Ensure the target directory exists
if [ ! -d "$ALACRITTY_CONFIG_DIR" ]; then
    echo "Creating directory $ALACRITTY_CONFIG_DIR"
    mkdir -p "$ALACRITTY_CONFIG_DIR" || { echo "Error creating directory $ALACRITTY_CONFIG_DIR."; exit 1; }
fi

# Set permissions on the target directory
chown -R "$ORIGINAL_USER:$ORIGINAL_USER" "$ALACRITTY_CONFIG_DIR"

# Check if the alacritty.toml file exists
if [ -f "$ALACRITTY_CONF_FILE" ]; then
    echo "Alacritty.toml file $ALACRITTY_CONF_FILE already exists."
else
    echo "Alacritty.toml file $ALACRITTY_CONF_FILE does not exist."
fi

# Prompt user for confirmation
read -p "Proceed with overwriting the alacritty.toml file? (Y/N): " USER_INPUT

# Convert user input to lowercase
USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')

# Check user input and proceed or skip the file copy
if [[ "$USER_INPUT" == "y" || "$USER_INPUT" == "yes" ]]; then
    # Copy the alacritty.toml file
    echo "Overwriting alacritty.toml file..."
    cp -f "$SOURCE_CONF_FILE" "$ALACRITTY_CONF_FILE" || { echo "Error copying alacritty.toml file."; exit 1; }
    echo "Alacritty.toml file copied successfully! You can find it at $ALACRITTY_CONFIG_DIR"
else
    echo "Skipping alacritty.toml file operation."
fi

echo "######### Custom Configs Loaded #########"

#########################################
# PERMISSIONS
#########################################
# Some directory permissions were set to root and need set back to the non-root user
# Define directories to adjust permissions
DIRECTORIES=(
    "$USER_HOME/.local"
    "$USER_HOME/.config"
    "$USER_HOME/Pictures"
)

# Function to set ownership and permissions
set_permissions() {
    local dir="$1"

    # Check if the directory exists
    if [ -d "$dir" ]; then
        echo "Setting ownership for directory: $dir"
        
        # Attempt to change ownership
        if ! sudo chown -R "$USER:$USER" "$dir"; then
            echo "Error: Failed to change ownership for $dir"
            exit 1
        fi

        # Ensure permissions are set correctly
        echo "Setting permissions for directory: $dir"
        if ! chmod -R u+rwX,g+rwX,o+rX "$dir"; then
            echo "Error: Failed to set permissions for $dir"
            exit 1
        fi

        echo "Permissions set for $dir"
    else
        echo "Directory $dir does not exist. Skipping..."
    fi
}

# Loop through directories and set permissions
for dir in "${DIRECTORIES[@]}"; do
    set_permissions "$dir"
done

echo "Permissions have been set successfully."

# Optional: Output directory ownership and permissions for verification
echo "Verifying directory ownership and permissions:"
for dir in "${DIRECTORIES[@]}"; do
    echo "Directory: $dir"
    ls -ld "$dir"
done

echo "Script completed."

#########################################
# CLEANUP
#########################################

echo "######### CLEANUP #########"
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
# permissions on .local, Pictures and .config are all under root and need changed back to user
# install zsh
# install a login manager and customize it
# install all my apps from my main machine