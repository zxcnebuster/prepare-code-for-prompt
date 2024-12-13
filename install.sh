#!/bin/bash
# -----------------------------------
# Script: main.sh
# Description: Iterates through all files in a specified directory
#              and concatenates their contents into a single Markdown or text file.
#              Supports excluding and including specific paths, folders, and directories.
# Usage: ./main.sh [OPTIONS] SOURCE_DIRECTORY OUTPUT_FILE
# Options:
#   -e EXCLUDE_PATHS...    Specify paths, folders, or directories to exclude.
#   -i INCLUDE_PATHS...    Specify paths, folders, or directories to include, overriding exclusions.
# Example:
#   ./main.sh -e env cache tmp -i important_dir ./documents combined.md
# -----------------------------------

set -euo pipefail

EXCLUDE_PATHS=()
INCLUDE_PATHS=()
POSITIONAL_ARGS=()

usage() {
    echo "Usage: $0 [OPTIONS] SOURCE_DIRECTORY OUTPUT_FILE"
    echo ""
    echo "Options:"
    echo "  -e EXCLUDE_PATHS...    Specify paths, folders, or directories to exclude."
    echo "  -i INCLUDE_PATHS...    Specify paths, folders, or directories to include, overriding exclusions."
    echo ""
    echo "Example:"
    echo "  $0 -e env cache tmp -i important_dir ./documents combined.md"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -e|--exclude)
            shift
            # collect all exclude paths until the next option or end of arguments
            while [[ "$#" -gt 0 && ! "$1" =~ ^- ]]; do
                EXCLUDE_PATHS+=("$1")
                shift
            done
            ;;
        -i|--include)
            shift
            # collect all include paths until the next option or end of arguments
            while [[ "$#" -gt 0 && ! "$1" =~ ^- ]]; do
                INCLUDE_PATHS+=("$1")
                shift
            done
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

if [ "${#POSITIONAL_ARGS[@]}" -lt 2 ]; then
    echo "Error: Insufficient number of arguments."
    usage
fi

SOURCE_DIR="${POSITIONAL_ARGS[0]}"
OUTPUT_FILE="${POSITIONAL_ARGS[1]}"


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

# create a temporary file for concatenation
TEMP_OUTPUT=$(mktemp) || { echo "Error: Failed to create a temporary file."; exit 1; }

# cleanup function to remove temporary file on exit or interruption
cleanup() {
    rm -f "$TEMP_OUTPUT"
    exit
}

# trap signals to ensure cleanup is performed
trap cleanup INT TERM EXIT

# initialize the temporary output file with a header
echo "# This file contains concatenated content from all files in the directory '$SOURCE_DIR'." > "$TEMP_OUTPUT"

FIND_CMD=(find "$SOURCE_DIR" -type f ! -path "*/.*")

# add exclude paths to the find command
for exclude in "${EXCLUDE_PATHS[@]}"; do
    FIND_CMD+=(! -path "*/$exclude/*" ! -path "*/$exclude")
done

# if include paths are specified, modify the find command to include them
if [ "${#INCLUDE_PATHS[@]}" -gt 0 ]; then
    INCLUDE_EXPR=""
    for include in "${INCLUDE_PATHS[@]}"; do
        INCLUDE_EXPR+=" -o -path \"*/$include/*\" -o -path \"*/$include\""
    done
    # remove the first ' -o ' for proper syntax
    INCLUDE_EXPR=${INCLUDE_EXPR# -o }
    FIND_CMD+=\( -path "*/.*" -prune \) -o \( "$INCLUDE_EXPR" -o -type f \)
fi

"${FIND_CMD[@]}" | while IFS= read -r file; do
    INCLUDE_FLAG=false
    for include in "${INCLUDE_PATHS[@]}"; do
        if [[ "$file" == */"$include"/* || "$file" == */"$include" ]]; then
            INCLUDE_FLAG=true
            break
        fi
    done

    if [ "${#INCLUDE_PATHS[@]}" -gt 0 ] && [ "$INCLUDE_FLAG" = false ]; then
        SKIP=false
        for exclude in "${EXCLUDE_PATHS[@]}"; do
            if [[ "$file" == */"$exclude"/* || "$file" == */"$exclude" ]]; then
                SKIP=true
                break
            fi
        done
        if [ "$SKIP" = true ]; then
            continue
        fi
    fi

    echo "Processing '$file'..."

    RELATIVE_PATH="${file#$SOURCE_DIR/}"

    echo -e "\n# File: $RELATIVE_PATH\n" >> "$TEMP_OUTPUT"
    cat "$file" >> "$TEMP_OUTPUT"
    echo -e "\n" >> "$TEMP_OUTPUT"
done

# remove the trap as processing is done
trap - INT TERM EXIT

if [ -e "$OUTPUT_FILE" ]; then
    read -p "Output file '$OUTPUT_FILE' already exists. Overwrite? (y/n): " choice
    case "$choice" in
        y|Y )
            mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to move temporary file to '$OUTPUT_FILE'."
                exit 1
            fi
            ;;
        * )
            rm -f "$TEMP_OUTPUT"
            echo "Operation canceled."
            exit 1
            ;;
    esac
else
    mv "$TEMP_OUTPUT" "$OUTPUT_FILE"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to move temporary file to '$OUTPUT_FILE'."
        exit 1
    fi
fi

echo "All files have been concatenated into '$OUTPUT_FILE'."
