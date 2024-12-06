# Concatenate Files Script

This repository contains `main.sh`, a script that iterates through all files in a specified directory and concatenates their contents into a single Markdown or text file. You can specify files or folders to ignore during the concatenation process.

## Installation

To install the script, you can either clone the repository or download it as a ZIP file.

After downloading, navigate to the repository folder, and run the following commands in your terminal:

```bash
chmod +x ./install.sh
./install.sh
```

Once installed, the script can be used globally from anywhere on your computer with the command:

```bash
prepare_for_prompt /path/to/source_directory /path/to/output.md [IGNORE_PATHS...]
```

## Example usage

prepare_for_prompt ./documents combined.md env cache tmp

This command concatenates all files in the ./documents directory into combined.md, ignoring any files or folders within env, cache, and tmp directories.

### Global Installation

To install the script globally, simply run it once. The script will copy itself to `/usr/local/bin/` and make it executable. Note that this action requires sudo privileges.

## Contributing

Contributions are welcome! If you have any suggestions or improvements, feel free to open an issue or submit a pull request.
