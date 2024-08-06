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

mkdir -p "$HOME/tmp"
mkdir -p "$HOME/.config/i3"

# Additional configuration files will be placed here:
 echo ""
echo "tmp: $HOME/tmp"
echo "i3: $HOME/.config/i3/"

echo "All directories created successfully."

#########################################
# Clone workstation-config git repo.
git clone https://github.com/SDrumm00/workstation-config.git $HOME/tmp
if [ $? -ne 0 ]; then
    echo "Failed to clone workstation-config repository!"
    exit 1
fi

echo "Workstation config cloned successfully! You can find it at $HOME/tmp"

#########################################
# Copy files from cloned repo into target directories.
echo "Copying custom config files..."

# Copy i3 file.
cp $HOME/tmp/i3/config "$HOME/.config/i3/"
if [ $? -ne 0 ]; then
   echo "Error copying bash configuration file."
   exit 1
fi

echo "i3 config copied successfully! You can find it at $HOME/.config/i3/config"