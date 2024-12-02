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
