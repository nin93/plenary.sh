#!/bin/env -S bash

function usage {
	cat <<-EOF
		Usage: $PROGRAM [...OPTIONS]

		Scripts installer.

		OPTIONS
		  -b, --binpath          set the installation path for scripts, default: ~/bin
		      --keep-extension   keep .sh extension for installed scripts
		  -h, --help             print this help message
	EOF
}

function die {
	echo "$*" >&2
	usage >&2

	exit 1
}

function main {
	if ! options=$(getopt -o "b:" -l "binpath:,keep-extension" -- "$@"); then
		die
	fi

	eval set -- $options

	while [ $# -gt 0 ]; do
		case $1 in
		-b | --binpath)
			local binpath=$2
			shift 2
			;;

		--keep-extension)
			local keep_extension=y
			shift 2
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

	binpath="${binpath:-${HOME}/bin/}"

	find "$(dirname "$0")/src" -type f -name '*.sh' -print0 | while read -d $'\0' filename; do
		local out_filename="${filename##*/}"

		if ! [[ $keep_extension == 'y' ]]; then
			out_filename="${out_filename%.sh}"
		fi

		# Respect `~` expansion
		eval fullpath=$(echo "$binpath/$out_filename")

		install "$filename" "$fullpath" -m 755
	done
}

main "$@"
