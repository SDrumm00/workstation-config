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

echo "Installation complete!"

#########################################
## Make directories for custom config files
echo "Creating directories for custom configs..."

# Get the home directory of the current user under sudo context
USER_HOME="$HOME"

# Check if we got a valid home directory path
if [ -z "$USER_HOME" ]; then
    echo "Home directory not found."
    exit 1
fi

# Create directories under the user's home directory using sudo
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/tmp"
sudo -u "$SUDO_USER" mkdir -p "$USER_HOME/.config/i3"

echo "Directories created successfully under $USER_HOME."

#########################################
# Copy files from cloned repo into target directories.
echo "Copying custom config files..."

# Example: Copy i3 config file (adjust paths as needed)
cp "$USER_HOME/tmp/i3/config" "$USER_HOME/.config/i3/"
if [ $? -ne 0 ]; then
   echo "Error copying i3 configuration file."
   exit 1
fi

echo "i3 config copied successfully! You can find it at $USER_HOME/.config/i3/config"
#########################################
# Copy files from cloned repo into target directories.
echo "Copying custom config files..."

# Copy i3 file.
cp $USER_HOME/tmp/i3/config "$USER_HOME/.config/i3/"
if [ $? -ne 0 ]; then
   echo "Error copying bash configuration file."
   exit 1
fi

echo "i3 config copied successfully! You can find it at $USER_HOME/.config/i3/config"