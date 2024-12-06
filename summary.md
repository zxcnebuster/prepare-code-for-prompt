# This file contains concatenated content from all files in the directory '.', excluding the 'env' folder.

# File: main.sh
#!/bin/bash
# -----------------------------------
# Script: main.sh
# Description: Iterates through all files in a specified directory
#              and concatenates their contents into a single Markdown or text file.
#              Skips files in the 'env' folder.
# Usage: ./main.sh /path/to/source_directory /path/to/output.md
# -----------------------------------

# display usage instructions
usage() {
    echo "Usage: main.sh SOURCE_DIRECTORY OUTPUT_FILE"
    echo "Example: main.sh ./documents combined.md"
    exit 1
}

# check arguments num
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

SOURCE_DIR="$1"
OUTPUT_FILE="$2"

# validate source directory 
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist or is not a directory."
    exit 1
fi

OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
OUTPUT_FILENAME=$(basename "$OUTPUT_FILE")

# create output directory if it does not exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create directory '$OUTPUT_DIR'."
        exit 1
    fi
fi

# create temp file
TEMP_OUTPUT=$(mktemp) || { echo "Error: Failed to create a temporary file."; exit 1; }

# cleanup function to remove temp file on exit or interruption
cleanup() {
    rm -f "$TEMP_OUTPUT"
    exit
}

# trap signals to ensure cleanup is performed
trap cleanup INT TERM EXIT

echo "# This file contains concatenated content from all files in the directory '$SOURCE_DIR', excluding the 'env' folder." > "$TEMP_OUTPUT"

# iterate through each file in the source directory, excluding the 'env' folder
find "$SOURCE_DIR" -type f ! -path "*/env/*" ! -path "*/.*" | while IFS= read -r file; do
    echo "Processing '$file'..."
    
    # Get the relative path of the file for the header
    RELATIVE_PATH="${file#$SOURCE_DIR/}"
    
    # Add a header for the current file
    echo -e "\n# File: $RELATIVE_PATH" >> "$TEMP_OUTPUT"
    
    # Append the file's content to the temporary output file
    cat "$file" >> "$TEMP_OUTPUT"
    
    # Add a newline for separation
    echo -e "\n" >> "$TEMP_OUTPUT"
done

# Remove the trap as processing is done
trap - INT TERM EXIT

# Check if the output file already exists, prompt user for action if it does
if [ -e "$OUTPUT_FILE" ]; then
    read -p "Output file '$OUTPUT_FILE' already exists. Overwrite? (y/n): " choice
    case "$choice" in
        y|Y ) 
            # Move the temporary file to the output file
            mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to move temporary file to '$OUTPUT_FILE'."
                exit 1
            fi
            ;;
        * )
            # User chose not to overwrite, remove the temporary file and cancel operation
            rm -f "$TEMP_OUTPUT"
            echo "Operation canceled."
            exit 1
            ;;
    esac
else
    # Move the temporary file to the output file
    mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to move temporary file to '$OUTPUT_FILE'."
        exit 1
    fi
fi

echo "All files have been concatenated into '$OUTPUT_FILE'."



# File: install.sh
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



# File: README.md
# Concatenate Files Script

This repository contains `concatenate_files.sh`, a script that iterates through all files in a specified directory and concatenates their contents into a single Markdown or text file. Files located in the `env` folder are automatically skipped.

## Installation

To install the script, you can either clone the repository or download it as a ZIP file.

After downloading, navigate to the repository folder, and run the following commands in your terminal:

```bash
chmod +x ./install.sh
./install.sh
```

Once installed, the script can be used globally from anywhere on your computer with the command:

```bash
prepare_for_prompt /path/to/source_directory /path/to/output.md
```

### Global Installation

To install the script globally, simply run it once. The script will copy itself to `/usr/local/bin/` and make it executable. Note that this action requires sudo privileges.

## Contributing

Contributions are welcome! If you have any suggestions or improvements, feel free to open an issue or submit a pull request.


