#!/bin/bash
# -----------------------------------
# Script: main.sh
# Description: Iterates through all files in a specified directory
#              and concatenates their contents into a single Markdown or text file.
#              Skips files in specified ignore folders.
# Usage: ./main.sh /path/to/source_directory /path/to/output.md [IGNORE_PATHS...]
# Example: ./main.sh ./documents combined.md env cache tmp
# -----------------------------------

usage() {
    echo "Usage: $0 SOURCE_DIRECTORY OUTPUT_FILE [IGNORE_PATHS...]"
    echo "Example: $0 ./documents combined.md env cache tmp"
    exit 1
}

if [ "$#" -lt 2 ]; then
    echo "Error: Insufficient number of arguments."
    usage
fi

SOURCE_DIR="$1"
OUTPUT_FILE="$2"
shift 2
IGNORE_PATHS=("$@")

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist or is not a directory."
    exit 1
fi

OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
OUTPUT_FILENAME=$(basename "$OUTPUT_FILE")

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create directory '$OUTPUT_DIR'."
        exit 1
    fi
fi

# Create temp file
TEMP_OUTPUT=$(mktemp) || { echo "Error: Failed to create a temporary file."; exit 1; }

# Cleanup function to remove temp file on exit or interruption
cleanup() {
    rm -f "$TEMP_OUTPUT"
    exit
}

# Trap signals to ensure cleanup is performed
trap cleanup INT TERM EXIT

echo "# This file contains concatenated content from all files in the directory '$SOURCE_DIR', excluding specified folders." > "$TEMP_OUTPUT"

# Build find command with ignore paths
FIND_CMD=(find "$SOURCE_DIR" -type f ! -path "*/.*")
for ignore in "${IGNORE_PATHS[@]}"; do
    FIND_CMD+=(! -path "*/$ignore/*" ! -path "*/$ignore")
done

"${FIND_CMD[@]}" | while IFS= read -r file; do
    echo "Processing '$file'..."

    RELATIVE_PATH="${file#$SOURCE_DIR/}"

    echo -e "\n# File: $RELATIVE_PATH" >> "$TEMP_OUTPUT"

    cat "$file" >> "$TEMP_OUTPUT"

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
