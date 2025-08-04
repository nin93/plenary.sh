#!/bin/env -S bash

PROGRAM='record-tags'

function usage {
	cat << EOF
Usage: $PROGRAM [...OPTIONS] [TRACKLIST_DIR]

Map the mp3 metadata values for a list of mp3 files. Track number is read from files
if the filename starts with a number. 

When TRACKLIST_DIR is omitted the list is retrieved from the current working directory,
if it is - then stdin is read.

OPTIONS
  -a, --artist    set the metadata values for artist, composer, performer
  -r, --album     set the metadata value for the album title
  -g, --genre     set the metadata value for the genre
  -y, --year      set the metadata value for the release year
  -p, --artwork   set the artwork for this album
  -h, --help      print this help message
EOF
}

function die {
  echo "$*" >&2
  usage >&2

  exit 1
} 

function get_files {
	if [[ "$1" != '-' ]]; then
		find "$1" -maxdepth 1 -type f -iregex ".*\.mp3"
	else
		cat -
	fi
}

function main() {
  if ! options=$(getopt -o "a:r:g:y:p:h" -l "artist:,album:,genre:,year:,artwork:help" -- "$@"); then
    die
  fi

  eval set -- $options

  while [ $# -gt 0 ]; do
		case "$1" in
			-a|--artist)
				local artist="$2"; shift 2;;
			-r|--album)
				local album="$2"; shift 2;;
			-g|--genre)
				local genre="$2"; shift 2;;
			-y|--year)
				local year="$2"; shift 2;;
			-p|--artwork)
				local artwork="$2"; shift 2;;
			-h|--help)
				usage; exit 0;;
			--)
				shift; break;;
      -*)
      	die "$PROGRAM: error - unrecognized option $1";;
		esac
	done

	local base_ffmpeg_opts=("-y")

	if [[ -n "$artwork" ]]; then
		base_ffmpeg_opts+=("-i '$artwork' -c copy -map 0:0 -map 1:0")
	else
		base_ffmpeg_opts+=("-c copy -map 0:0")
	fi

	if [[ -n "$artist" ]]; then
		base_ffmpeg_opts+=(
			"-metadata album_artist='$artist'"
			"-metadata performer='$artist'"
			"-metadata composer='$artist'"
			"-metadata artist='$artist'"
		)
	fi

	if [[ -n "$album" ]]; then
		base_ffmpeg_opts+=("-metadata album='$album'")
	fi

	if [[ -n "$genre" ]]; then
		base_ffmpeg_opts+=("-metadata genre='$genre'")
	fi

	if [[ -n "$year" ]]; then
		base_ffmpeg_opts+=("-metadata date=$year")
	fi

	track_list="${1:-.}"

	get_files "$track_list" | while read file; do
		local track="${file##*/}"

		local index="$(echo $track | sed -E 's|[NA]*([0-9]*)\s*.*|\1|')"
		local title="$(echo $track | sed -E 's|[NA]*[0-9]*\s*[-_\.]*\s*(.*)[.].*|\1|')"

		local ftemp="$(mktemp .tags-XXXXXXXX.mp3)"

		local ffmpeg_opts=(
			"-i '$file'"
			"${base_ffmpeg_opts[@]}"
		)

		if [[ -n "$title" ]]; then
			ffmpeg_opts+=("-metadata title='$title'")
		fi

		if [[ -n "$index" ]]; then
			ffmpeg_opts+=("-metadata track=$index")
		fi

		eval ffmpeg "${ffmpeg_opts[@]}" "$ftemp" >/dev/null 2>&1 \
			&& mv "$ftemp" "$file"
	done
}

main "$@"
