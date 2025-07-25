#! /bin/bash

function sync {
  emerge --sync
}

function update {
  emerge \
    --verbose --quiet --deep --newuse --changed-use --update --usepkg --with-bdeps=y \
    --autounmask-write --autounmask-use=y --autounmask-license=y --keep-going \
    @world
}

function clean {
  emerge --depclean --quiet && eclean-dist && eclean-pkg
}

function main {
  while getopts ":usc" opt; do
    case $opt in
      s)
        SYNC=true
        ;;
      u)
        UPDATE=true
        ;;
      c)
        CLEAN=true
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        ;;
    esac
  done

  if [[ -n "$SYNC" ]]; then
    sync || exit 1
  fi

  if [[ -n "$UPDATE" ]]; then
    update || exit 1
  fi

  if [[ -n "$CLEAN" ]]; then
    clean || exit 1
  fi

  exit 0
}

main $@
