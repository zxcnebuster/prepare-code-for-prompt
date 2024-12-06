SCRIPT_NAME="prepare_for_prompt"
SCRIPT_PATH="/usr/local/bin/$SCRIPT_NAME"
SOURCE_SCRIPT="./main.sh"

# Check if the source script exists
if [[ ! -f "$SOURCE_SCRIPT" ]]; then
    echo "Error: Source script '$SOURCE_SCRIPT' does not exist."
    exit 1
fi

# Copy the script to /usr/local/bin and make it executable
# Requires sudo privileges
sudo cp "$SOURCE_SCRIPT" "$SCRIPT_PATH"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to copy the script to $SCRIPT_PATH."
    exit 1
fi

sudo chmod +x "$SCRIPT_PATH"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to make the script executable."
    exit 1
fi

# Inform the user that the script is now globally available
echo "The script has been installed as '$SCRIPT_NAME' and can be run from anywhere on your computer."
