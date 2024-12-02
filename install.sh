
# Make the script accessible as a command from anywhere
SCRIPT_NAME="concatenate_files"
SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"

# Copy the script to /usr/local/bin and make it executable
# Note: Requires sudo privileges, as /usr/local/bin is a system directory
# TODO: Improve the installation process, maybe prompt the user before proceeding
sudo cp "$0" "$SCRIPT_PATH"
sudo chmod +x "$SCRIPT_PATH"

# Inform the user that the script is now globally available
echo "The script has been installed as '$SCRIPT_NAME' and can be run from anywhere on your computer."