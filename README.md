# plenary-sh

A collection of scripts I don't want to write twice.

## Installation

```sh
# install printing every file installed.
./install.sh -v

# install specifiyng a bin path, default is `$HOME/bin`.
# ensure bin path is available in your `$PATH`.
./install --binpath=/path/to/bin

# overwrite already existing files.
./install -f
```

### Complete options list

Here's the full list of installation options

```text
OPTIONS
  -b, --binpath          set the installation path for scripts, default: ~/bin
      --keep-extension   keep .sh extension for installed scripts
  -f, --force            overwrite existing files
  -v, --verbose          print verbose output
  -h, --help             print this help message
```
