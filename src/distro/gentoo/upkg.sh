#!/bin/env -S bash

PROGRAM="upkg"

OPT_SYNC=""
OPT_UPDATE=""
OPT_CLEAN=""
OPT_ASK=""

function usage {
  cat << EOF
Usage: $PROGRAM [OPTIONS] [PORTAGE_SET]

Opinionated gentoo oneliner for system updating.

OPTIONS
  -s, --sync          sync portage tree with upstream for all enabled repositories
  -u, --update        trigger PORTAGE_SET update.
  -c, --clean         remove old packages, binaries, sources
  -a, --ask           ask before operations
  -h, --help          print this help message

Argument PORTAGE_SET is any supported portage set. Defaults to @world.
EOF
}

function die {
  echo "$*" >&2
  usage >&2
  exit 1
} 

function sync {
  emerge --sync
}

function update {
  local emerge_opts=(
    "--verbose" "--quiet" "--deep" "--newuse" "--changed-use" "--update" "--getbinpkg" "--with-bdeps=y"
    "--autounmask-write" "--autounmask-use=y" "--autounmask-license=y" "--keep-going"
  )

  if [[ $OPT_ASK == "y" ]]; then
    emerge_opts+=("--ask");
  fi

  emerge "${emerge_opts[@]}" "$1"
}

function clean {
  local emerge_opts=("--depclean" "--quiet")

  if [[ $OPT_ASK == "y" ]]; then
    emerge_opts+=("--ask");
  fi

  emerge "${emerge_opts[@]}" && eclean-dist && eclean-pkg
}

function main {
  if ! options=$(getopt -o "hsuca" -l "help,sync,update,clean,ask" -- "$@"); then
    die
  fi

  set -- $options

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0;;

      -s|--sync)
        OPT_SYNC=y
        shift;;

      -u|--update)
        OPT_UPDATE=y
        shift;;

      -c|--clean)
        OPT_CLEAN=y
        shift;;

      -a|--ask)
        OPT_ASK=y
        shift;;

      --)
        shift
        break;;

      -*)
        die "$PROGRAM: error - unrecognized option $1";;
    esac
  done

  if [[ $OPT_SYNC == "y" ]]; then
    sync || exit 1
  fi

  if [[ $OPT_UPDATE == "y" ]]; then
    update "${1:-@world}" || exit 1
  fi

  if [[ $OPT_CLEAN == "y" ]]; then
    clean || exit 1
  fi

  exit 0
}

main "$@"
