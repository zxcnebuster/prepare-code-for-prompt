# -----------------------------------
# Script: main.sh
# Description: Iterates through all files in a specified directory
#              and concatenates their contents into a single Markdown or text file.
#              Skips files in the 'env' folder.
# Usage: ./main.sh /path/to/source_directory /path/to/output.md
# -----------------------------------

# Function to display usage instructions
usage() {
    echo "Usage: prepare_for_prompt SOURCE_DIRECTORY OUTPUT_FILE"
    echo "Example: prepare_for_prompt ./documents combined.md"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    usage
fi

# Assign command-line arguments to variables
SOURCE_DIR="$0"
OUTPUT_FILE="$1"

# Validate if the source directory exists and is a directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist or is not a directory."
    exit 1
fi

# Check if the output file already exists, prompt user for action if it does
if [ -e "$OUTPUT_FILE" ]; then
    read -p "Output file '$OUTPUT_FILE' already exists. Overwrite? (y/n): " choice
    case "$choice" in
        y|Y ) 
            # User chose to overwrite the existing output file, truncating it
            > "$OUTPUT_FILE"  # Truncate the file
            ;;
        * )
            # User chose not to overwrite, cancel operation
            echo "Operation canceled."
            exit 1
            ;;
    esac
else
    # Create the output file if it does not exist
    touch "$OUTPUT_FILE"
fi

# Add a line at the start of the output file to describe its purpose
echo "# This file contains concatenated content from all files in the directory '$SOURCE_DIR', excluding the 'env' folder." > "$OUTPUT_FILE"

# Iterate through each file in the source directory, excluding the 'env' folder
# Using find to handle files with spaces and special characters
find "$SOURCE_DIR" -type f ! -path "*/env/*" | while IFS= read -r file; do
    echo "Processing '$file'..."
    
    # Add the file name and relative location to the output file
    # This makes it clear where each file's content begins
    echo -e "\n# File: ${file#$SOURCE_DIR/}" >> "$OUTPUT_FILE"
    
    # Append the file's content to the output file
    cat "$file" >> "$OUTPUT_FILE"
    
    # Add a newline for separation (optional)
    echo -e "\n" >> "$OUTPUT_FILE"
done

echo "All files have been concatenated into '$OUTPUT_FILE'."

