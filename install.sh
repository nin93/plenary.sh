#!/bin/env -S bash

function die {
  echo "$*" >&2;
  exit 2;
} 

function main {
  if ! options=$(getopt -u -o "b:" -l "binpath:,keep-extension" -- "$@"); then
    die
  fi

  set -- $options

  while [ $# -gt 0 ]; do
    case $1 in
      -b|--binpath)
        local binpath=$2
        shift
        ;;
      --keep-extension)
        local keep_extension=y
        shift
        ;;
      (--)
        shift
        break
        ;;
      (-*)
        die "$0: error - unrecognized option $1"
        ;;
      (*)
        break
        ;;
    esac

    shift
  done
  
  binpath="${binpath:-/usr/local/bin/}"

  find "$(dirname "$0")/src" -type f -name '*.sh' -print0 | while read -d $'\0' filename; do
    local out_filename="${filename##*/}";

    if ! [[ $keep_extension == 'y' ]]; then
      out_filename="${out_filename%.sh}"
    fi

    # Respect `~` expansion
    eval fullpath=$(echo "$binpath/$out_filename")

    install "$filename" "$fullpath" -m 755
  done
}

main $@
