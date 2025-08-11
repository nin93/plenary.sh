#!/bin/env -S bash

function usage {
	cat <<-EOF
		Usage: $PROGRAM [OPTIONS]

		Scripts installer.

		OPTIONS
		  -b, --binpath          set the installation path for scripts, default: ~/bin
		      --keep-extension   keep .sh extension for installed scripts
		  -f, --force            overwrite existing files
		  -v, --verbose          print verbose output
		  -h, --help             print this help message
	EOF
}

function die {
	echo "$*" >&2
	usage >&2

	exit 1
}

function main {
	if ! options=$(getopt -o "hb:fv" -l "help,binpath:,keep-extension,force,verbose" -- "$@"); then
		die
	fi

	eval set -- $options

	while [ $# -gt 0 ]; do
		case $1 in
		-h | --help)
			usage
			exit 0
			;;

		-b | --binpath)
			local OPT_BINPATH=$2
			shift 2
			;;

		--keep-extension)
			local OPT_KEEP_EXT=y
			shift
			;;

		-v | --verbose)
			local OPT_VERBOSE=y
			shift
			;;

		-f | --force)
			local OPT_FORCE=y
			shift
			;;

		--)
			shift
			break
			;;

		-*)
			die "$0: error - unrecognized option $1"
			;;

		*)
			break
			;;
		esac
	done

	binpath="${OPT_BINPATH:-${HOME}/bin/}"

	find "$(dirname "$0")/src" -type f -name '*.sh' -print0 | while read -d $'\0' filename; do
		local out_filename="${filename##*/}"

		if ! [[ "$OPT_KEEP_EXT" == 'y' ]]; then
			out_filename="${out_filename%.sh}"
		fi

		fullpath="$(realpath "$binpath/$out_filename")"

		if [[ -f "$fullpath" ]] && [[ -z "$OPT_FORCE" ]]; then
			echo "'$fullpath' already exists but --force was not specified."
		else
			if [[ -n "$OPT_VERBOSE" ]]; then
				echo "install \"$filename\" \"$fullpath\" -m 755"
			fi

			install "$filename" "$fullpath" -m 755
		fi
	done
}

main "$@"
