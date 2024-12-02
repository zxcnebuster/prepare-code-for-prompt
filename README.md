# Concatenate Files Script

This repository contains `concatenate_files.sh`, a script that iterates through all files in a specified directory and concatenates their contents into a single Markdown or text file. It skips files in the `env` folder.

## Installation

To install the script either clone repository via

To install the script, run the following command:

```bash
./concatenate_files.sh /path/to/source_directory /path/to/output.md
```

Once installed, the script can also be used globally from anywhere on your computer as `concatenate_files`:

```bash
concatenate_files /path/to/source_directory /path/to/output.md
```

## Installation

To install the script globally, simply run it once. The script will copy itself to `/usr/local/bin/` and make it executable. Note that this requires sudo privileges.

## Contributing

Contributions are welcome! If you have any suggestions or improvements, feel free to open an issue or submit a pull request.
