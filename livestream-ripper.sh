#!/bin/bash
#Version 1.0.3
#A script to record a livestream using streamlink

help="
Flag usage:
[-h] [-l YTLINK]
[-q NUMBER] [-f FILENAME] [-r]

Flag description
'-h' Display help text.
'-l' Youtube livestream link.
'-q' Playlist number.
'-f' Name of your output file (sans file format).
'-r' Lists the playlist numbers to use with '-q'. Must be used alongside '-l'.

"
#defines getformats function before the flag definition so it can be used in -r
function getformats() {
  #read -p "Enter YT link: " LINK
  if [[ -z "$LINK" ]];
then
      echo "No link, please use -h for help."
      exit 1
else
      /usr/bin/youtube-dl --list-formats $LINK
fi
}

#flag definitions
while getopts hl:q:f:r option
 do
  case "${option}"
    in
        h) echo "$help"
           exit;;
        l) LINK=${OPTARG};;
        q) RES=${OPTARG};;
        f) FILENAME=${OPTARG};;
        r) getformats
           exit 1;;
        \?) echo "Invalid flag: -"$OPTARG". Use '-h' for help." >&2
    esac
  done
shift $((OPTIND -1))

#Other function definitions
function getplaylist() {
  if [[ -z "$RES" || -z "$LINK" ]];
then
      echo "Error you must include a link and a playlist number. Please use -r to find your playlist number."
      exit 1
else
      PLAYLIST=$(/usr/bin/youtube-dl -f $RES -g $LINK) #change back to /usr/bin
fi
}

function startrip() {
  getplaylist
  if [[ -z "$PLAYLIST" || -z "$FILENAME"  ]];
  then
        echo "Missing playlist or filename. Use -h for help."
        exit 1
  else
        /usr/bin/screen -d -m -S "livestream-rip" /usr/bin/streamlink $PLAYLIST best -o "$FILENAME".mp4
  fi
}
# Make sure user gave usable INPUT
if [[ -z "$PLAYLIST" && -z "$FILENAME" && -z "$RES" ]]; then
	echo "No file inputs given."
	echo "$help"
	exit 1
fi

#Check if main vars are empty so main function can be run
if [[ -z "$FILENAME" || -z "$RES" || -z "$LINK" ]]; then
  #echo $FILENAME $RES $LINK
	echo "Missing file inputs or non given."
	echo "$help"
	exit 1

else
  startrip
fi
