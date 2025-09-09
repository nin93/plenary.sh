#!/bin/env -S bash

function usage {
	cat <<-EOF
		Usage: $PROGRAM [OPTIONS]

		Scripts installer.

		OPTIONS
		  -b, --binpath          set the installation path for scripts, default: ~/bin
		      --keep-extension   keep .sh extension for installed scripts
		  -f, --force            overwrite existing files
		  -i, --interactive      use fzf to select files to install
		  -v, --verbose          print verbose output
		  -h, --help             print this help message
	EOF
}

function die {
	echo "$*" >&2
	usage >&2

	exit 1
}

function installable_files {
	local files="$(find "$(dirname "$1")/src" -type f -name '*.sh')"

	echo "$files"
}

function main {
	if ! options=$(getopt -o "hb:fvi" -l "help,binpath:,keep-extension,force,verbose,interactive" -- "$@"); then
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

		-i | --interactive)
			local OPT_INTERACTIVE=y
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

	# use eval to expand `~` from `OPT_BINPATH`
	eval binpath="${OPT_BINPATH:-${HOME}/bin/}"

	local installable="$(installable_files "$0")"

	local files="$({
		if [[ "$OPT_INTERACTIVE" == 'y' ]]; then
			echo "$installable" | fzf -m
		else
			echo "$installable"
		fi
	})"

	echo "$files" | while read -d $'\n' filename; do
		local out_filename="${filename##*/}"

		if ! [[ "$OPT_KEEP_EXT" == 'y' ]]; then
			out_filename="${out_filename%.sh}"
		fi

		fullpath="$(realpath "${binpath}/${out_filename}")"

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
