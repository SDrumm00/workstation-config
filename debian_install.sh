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
## System Upgrade

# Check if there are any upgradable packages
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
# Install Nerd Fonts - IBMPlexMono system wide
# Define the directory where you want to clone the repo
echo "######### Installing Custom Fonts #########"

CLONE_DIR="$USER_HOME/tmp/nerd-fonts"

# Ensure the directory exists, clone the repository, and perform sparse checkout in a single step
sudo -u "$SUDO_USER" git clone --depth 1 --filter=blob:none --sparse https://github.com/ryanoasis/nerd-fonts.git "$CLONE_DIR" &&
cd "$CLONE_DIR" &&
sudo -u "$SUDO_USER" git sparse-checkout init --cone &&
sudo -u "$SUDO_USER" git sparse-checkout set patched-fonts/IBMPlexMono

# Install the fonts
# Create installation directory if it doesn't exist
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.local/share/fonts/" &&
sudo -u "$SUDO_USER" ./install.sh -S IBMPlexMono

echo "######### Custom Fonts Installed #########"

#########################################
# Make directories for custom config files
echo "######### Load Custom Configs #########"

# Get the home directory of the current user under sudo context
USER_HOME=$(eval echo ~$SUDO_USER)

# Check if we got a valid home directory path
if [ -z "$USER_HOME" ]; then
    echo "Home directory not found."
    exit 1
fi

# i3 config file
I3_CONFIG_DIR="$USER_HOME/.config/i3"

# Check if directory exists, create it if it doesn't
if [ ! -d "$I3_CONFIG_DIR" ]; then
    echo "Creating directory $I3_CONFIG_DIR"
    sudo -u "$SUDO_USER" mkdir -p "$I3_CONFIG_DIR"
else
    echo "Directory $I3_CONFIG_DIR already exists, skipping creation."
fi

# Copy configuration file
echo "Copying i3 config file..."
cp "$USER_HOME/tmp/workstation-config/i3/config" "$I3_CONFIG_DIR/"
if [ $? -ne 0 ]; then
   echo "Error copying i3 configuration file."
   exit 1
fi

echo "i3 configuration file copied successfully."

# Wallpapers
WALLPAPER_DIR="$USER_HOME/Pictures/Wallpapers"
WALLPAPER_FILE="$USER_HOME/tmp/workstation-config/wallpapers/Wallpaper-254.png"

# Check if the directory exists, create it if it doesn't
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Creating directory $WALLPAPER_DIR"
    sudo -u "$SUDO_USER" mkdir -p "$WALLPAPER_DIR"
else
    echo "Directory $WALLPAPER_DIR already exists, skipping creation."
fi

# Copy wallpaper file
echo "Copying wallpaper file..."
cp "$WALLPAPER_FILE" "$WALLPAPER_DIR/"
if [ $? -ne 0 ]; then
    echo "Error copying wallpaper file."
    exit 1
fi

echo "Wallpaper copied successfully! You can find it at $WALLPAPER_DIR/"

# Picom config file
PICOM_CONFIG_DIR="$USER_HOME/.config/picom"
PICOM_CONF_FILE="$PICOM_CONFIG_DIR/picom.conf"
SOURCE_CONF_FILE="$USER_HOME/tmp/workstation-config/picom/picom.conf"

# Ensure the target directory exists
if [ ! -d "$PICOM_CONFIG_DIR" ]; then
    echo "Creating directory $PICOM_CONFIG_DIR"
    mkdir -p "$PICOM_CONFIG_DIR" || { echo "Error creating directory $PICOM_CONFIG_DIR."; exit 1; }
fi

# Set permissions on target directory
sudo chown -R "$SUDO_USER:$SUDO_USER" "$PICOM_CONFIG_DIR"

# Check if the picom.conf file already exists
if [ ! -f "$PICOM_CONF_FILE" ]; then
    echo "Copying picom config file..."
    sudo -u "$SUDO_USER" cp "$SOURCE_CONF_FILE" "$PICOM_CONFIG_DIR" || { echo "Error copying picom config file."; exit 1; }
    echo "Picom config file copied successfully! You can find it at $PICOM_CONFIG_DIR"
else
    echo "Picom config file already exists at $PICOM_CONFIG_DIR. Skipping copy."
fi

# Alacritty config file
ALACRITTY_CONFIG_DIR="$USER_HOME/.config/alacritty"
ALACRITTY_CONF_FILE="$ALACRITTY_CONFIG_DIR/alacritty.toml"
SOURCE_CONF_FILE="$USER_HOME/tmp/workstation-config/alacritty/alacritty.toml"

# Ensure the target directory exists
if [ ! -d "$ALACRITTY_CONFIG_DIR" ]; then
    echo "Creating directory $ALACRITTY_CONFIG_DIR"
    sudo -u "$SUDO_USER" mkdir -p "$ALACRITTY_CONFIG_DIR" || { echo "Error creating directory $ALACRITTY_CONFIG_DIR."; exit 1; }
fi

# Set permissions on the target directory
sudo chown -R "$SUDO_USER:$SUDO_USER" "$ALACRITTY_CONFIG_DIR"

# Check if the alacritty.toml file already exists
if [ ! -f "$ALACRITTY_CONF_FILE" ]; then
    echo "Copying alacritty.toml file..."
    sudo -u "$SUDO_USER" cp "$SOURCE_CONF_FILE" "$ALACRITTY_CONFIG_DIR" || { echo "Error copying alacritty.toml file."; exit 1; }
    echo "Alacritty.toml file copied successfully! You can find it at $ALACRITTY_CONFIG_DIR"
else
    echo "Alacritty.toml file already exists at $ALACRITTY_CONFIG_DIR... Skipping copy."
fi

echo "######### Custom Configs Loaded #########"

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
# make sure to do checks such as the directory already exists therefore skip this step
# install zsh
# install a login manager and customize it
# install all my apps from my main machine