#!/bin/bash

# test
#DIR_DEST="./dst/serie_tv"
#DIR_SOURCE="./src"

# prod
DIR_DEST="$HOME/mm/video/serie_tv"
DIR_SOURCE="$HOME/tor"
VERBOSE=0

# nome del file di configurazione che contiene le serie da gestire
CONFIGFILE=move_to_serie_tv.config

# se diverso da 0 considera la prima linea (non di commento) come intestazione, e la salta.
# se uguale a 0, considera anche la prima linea
SKIPHEADER=1

# gli array che contengono i dati letti dal config file
declare -a AMATCH
declare -a AFOLDER

# definisce i colori dell'output
HI=`tput setaf 2`
NC=`tput sgr0` # reset


# find src -type f -name \*.mkv
#find -L $DIR_SOURCE -type f \( -name "*.mkv" -o -name "*.avi" -o -name "*.srt" \)

# ***************************************************


# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-s SOURCE_DIR] [-d DEST_DIR]
Sposta i file video di una Serie TV.

    -h|--help               display this help and exit
		-v|--verbose            verbose mode
    -s|--source SOURCE_DIR  base source folder
    -d|--dest DEST_DIR      base destination folder
EOF
}


# parse command line. see http://mywiki.wooledge.org/BashFAQ/035
while :; do
    case $1 in
# HELP
        -h|-\?|--help)   # Call a "show_help" function to display a synopsis, then exit.
            show_help
            exit
            ;;
# VERBOSE
        -v|--verbose)   # set verbose mode
            VERBOSE=1
            ;;
# SOURCE
        -s|--source)       # Takes an option argument, with default
            if [ -n "$2" ]; then
                DIR_SOURCE=$2
                shift
						else
						    printf 'ERROR: "--source" requires a non-empty option argument.\n' >&2
							  exit 1
            fi
            ;;
				--source=?*)
	          DIR_SOURCE=${1#*=} # Delete everything up to "=" and assign the remainder.
	          ;;
        --source=)         # Handle the case of an empty --file=
	          printf 'ERROR: "--source" requires a non-empty option argument.\n' >&2
	          exit 1
	          ;;
# DEST
			  -d|--dest)       # Takes an option argument, with default
	          if [ -n "$2" ]; then
	              DIR_DEST=$2
	              shift
						else
						    printf 'ERROR: "--dest" requires a non-empty option argument.\n' >&2
							  exit 1
	          fi
	          ;;
        --dest=?*)
	          DIR_DEST=${1#*=} # Delete everything up to "=" and assign the remainder.
	          ;;
        --dest=)         # Handle the case of an empty --file=
	          printf 'ERROR: "--dest" requires a non-empty option argument.\n' >&2
	          exit 1
	          ;;
# ELSE
			 -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

# echo DIR_SOURCE = $DIR_SOURCE
# echo DIR_DEST = $DIR_DEST





# log arg1 arg2 ...
log(){
	echo $*
}

# log arg1 arg2 ...
logcall(){
  if [ $VERBOSE -gt 0 ] ; then
	  echo "${HI}CALL${NC} $*"
	fi
}

# normalize_filename path -> _RET
normalize_filename(){
	local fullpath="$1"
	local fname=$(basename "$fullpath")
	local fnamenew

	# check rename "[info] name.ext" -> "name [info].ext"
	if [[ $fname =~ ^\[(.*)\][[:space:]]+(.*)\.(.*)$ ]]
	then
		fnamenew="${BASH_REMATCH[2]} [${BASH_REMATCH[1]}].${BASH_REMATCH[3]}"
		log "${HI}WILL_RENAME${NC} \"$fname\" -> \"$fnamenew\""
#1		_RET=$(dirname "$fullpath")/$fnamenew
		_RET="$fnamenew"
	else
#1		_RET="$fullpath"
		_RET="$fname"
	fi
}

# check_or_make_dir folder
check_or_make_dir(){
	local DIRECTORY="$1"

	logcall check_or_make_dir "$1"

	if [ ! -d "$DIRECTORY" ]; then
		log "${HI}MKDIR${NC} \"$DIRECTORY\""
		mkdir -p "$DIRECTORY"
	fi
}

# get_season fname -> _RET
get_season(){
	local fname="$1"

	logcall get_season "$1"

	if [[ $fname =~ [\ \.][sS]([0-9])[eE][0-9]{1,2} ]]       # SxEyy -> S0x
	then
		_RET="S0${BASH_REMATCH[1]}"
	elif [[ $fname =~ [\ \.][sS]([0-9]{2})[eE][0-9]{1,2} ]]  # SxxEyy -> Sxx
	then
		_RET="S${BASH_REMATCH[1]}"
	elif [[ $fname =~ [\ \.]([0-9])[xX][0-9]{1,2} ]]         # aXbb -> S0a
	then
		_RET="S0${BASH_REMATCH[1]}"
	elif [[ $fname =~ [\ \.]([0-9])[0-9]{2} ]]               # abb -> S0a
	then
		_RET="S0${BASH_REMATCH[1]}"
	else
		_RET="SXY"
	fi

	logcall get_season "$fname" "->" "$_RET"
}


# move_file srcfile destfile
move_file(){
	local src="$1"
	local dest="$2"

	logcall move_file "$1" "$2"

	local fulldest="$DIR_DEST/$dest"
	local destdir=$(dirname "$fulldest")

	check_or_make_dir "$destdir"

	log "${HI}MOVE${NC} \"$src\" -> \"$dest\""
	mv "$src" "$fulldest"
}


# legge il file di configurazione e popola gli array AMATCH, AFOLDER
function readconfig {
  COUNT=0
  while read line; do
    # skip comment
    if [[ $line =~ ^\ *# ]] ;
    then
      # echo "COMMENT LINE: $line" ;
      :
    elif [[ $line =~ ^\ *$ ]] ;
    then
      # echo "EMPTY LINE: $line" ;
      :
    elif [ $SKIPHEADER -gt 0 ] ;
    then
      # echo "FIRST LINE: $line" ;
      SKIPHEADER=0 ;
    elif [[ $line =~ ^(.*)\;(.*)$ ]] ;
    then
      # echo "LINE: $line"
      # echo "  match: ${BASH_REMATCH[1]}"
      # echo "  folder: ${BASH_REMATCH[2]}"
      AMATCH[$COUNT]=${BASH_REMATCH[1]}
      AFOLDER[$COUNT]=${BASH_REMATCH[2]}
      COUNT=$(( $COUNT + 1 ))
    else
      # echo "SHORTCUT LINE: $line"
      AMATCH[$COUNT]=$line
      AFOLDER[$COUNT]=$line
      COUNT=$(( $COUNT + 1 ))
    fi

  done < $CONFIGFILE
}

function printconfig {
  len=${#AFOLDER[@]}
  idx=0
  while [ $idx -lt $len ]
  do
    echo "AMATCH_[$idx]: ${AMATCH[idx]}"
    echo "AFOLDER[$idx]: ${AFOLDER[idx]}"
    idx=$(( $idx + 1 ))
  done
}

# handle_file_config srcpath
handle_file_config(){
	local srcpath="$1"

	# log "###" HANDLE $1
	logcall handle_file_config "$1"

	normalize_filename "$srcpath"
	local destname="$_RET"

	get_season "$destname"
	local season="$_RET"

	local destdir=""

	local len=${#AFOLDER[@]}
  local idx=0
  while [ $idx -lt $len ]
  do
		# echo "check $idx: ${AMATCH[idx]}"
		if [[ "$destname" =~ ^${AMATCH[idx]} ]] ; then
			# echo "MATCHED $destname -> ${AMATCH[idx]}"
			destdir=${AFOLDER[idx]}
			#echo "MOVE" "$srcpath" " -> " "$destdir/$season/$destname"
			move_file "$srcpath" "$destdir/$season/$destname"
			break
		fi

    idx=$(( $idx + 1 ))
  done

}


function main {
	# Looping through files with spaces in the names?
	# http://unix.stackexchange.com/questions/9496/looping-through-files-with-spaces-in-the-names
	OIFS="$IFS"
	IFS=$'\n'

	for fullpath in `find -L $DIR_SOURCE -type f \( -iname "*.mkv" -o -iname "*.avi" -o -iname "*.srt" \)`
	do
		#handle_file "$fullpath"
		handle_file_config "$fullpath"
	done

	IFS="$OIFS"
}

# RUN
readconfig
# printconfig
# TEST: handle_file_config "Marco_Polo.S01E10.mkv"
main
