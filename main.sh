#!/bin/bash

# Exit conditions
	# 0 - Script executed correctly.
    # 1 - Entered file does not exist.
	# 2 - Required file not found.
	# 3 - No json files.
    # 4 - Invalid JSON File

# This script will download and construct a mario kart wii music pack.
# Requirements are set in README.MD.

function argu_check {
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--curl") set -- "$@" "-c" ;;
    "--log") set -- "$@" "-l" ;;
    "--test") set -- "$@" "-t" ;;
    *)        set -- "$@" "$arg"
  esac
done

while getopts 'chlt:' OPTION; do
    case "$OPTION" in
        h)
            echo "Usage: main.sh [options...]"
            echo "  -c, --curl            Enforce the use of curl"
            echo "  -t, --test            Test mode, download one song from a pack"
            echo "  -l, --log             Enable saving of logs"
            echo "  -h, --help            Show this help and exit"
            exit 0;
            ;;
            
        c)
            __DOWNLOAD__="curl"
            ;;
            
        t)
            trackNumber=$OPTARG
            ;;
            
        l)
            keepLogs=true
        ;;
    esac
done
}

function file_check {

#Check for required files

if ! hash "wget" 2>/dev/null; then
	echo "wget not found, using curl";
	__DOWNLOAD__="curl"
	if ! hash "curl" 2>/dev/null; then
        echo "curl not found";
        exit 2;
    fi
fi

if ! hash "ffmpeg" 2>/dev/null; then
	echo "ffmpeg not found";
	exit 2;
fi

if ! hash "brstm_converter" 2>/dev/null; then
	echo "openrevolution not found";
	exit 2;
fi

if ! hash "yt-dlp" 2>/dev/null; then
	echo "yt-dlp not found";
	exit 2;
fi

if ! hash "jq" 2>/dev/null; then
	echo "jq not found";
	exit 2;
fi

if test -z "$(ls ./JSON/)"; then
    echo "No JSON files found";
    exit 3;
fi

}

function file_selection_menu {
file=""
# Allows for the selection of json files


printf "\n"
    # Lists files wth no file extension.
dir ./JSON/ -1 | grep .json | sed s/.json//g

printf "\nEnter name of pack:";
read file
file=$file".json"

# Test for file's existence.
if ! test -f "./JSON/$file"; then
    echo "File not found"
    exit 1;
fi

# Checks to see if JSON is valid for program.
header="$(jq -r '.header' "./JSON/$file")"

if test $header != "MKWMP-HEADER"; then
    echo "Invalid JSON"
    exit 4;
fi

header="$(jq -r '.mkversion' "./JSON/$file")"

if test $header != "v1.1.0"; then
    echo "Invalid JSON"
    exit 4;
fi

}

function user_file_check {
# Checks to see if the selected pack is the one the user wants

fileDirect="./JSON/$1"
        printf "\nMusic Pack Information\n"
        echo "---"
        echo "Name: $(jq -r '.name' $fileDirect)"
        echo "Author: $(jq -r '.author' $fileDirect)"
        echo "Date: $(jq -r '.date' $fileDirect)"
        echo "Version: $(jq -r '.version' $fileDirect)"
        echo "---"
        
        userChoice="Y"
        printf "\n Is this the correct pack? (Y/n): "
        read userChoice
        
        if [ $userChoice = "n" ] || [ $userChoice = "N" ]; then
            echo "Program will exit"
            exit 0;
        fi

}

function init {
# Simple function to initialise required folders
    mkdir downloads
    mkdir conversion
    mkdir packs
    mkdir logs
    mkdir ./packs/"$(jq -r '.name' $fileDirect)"

}

function deinit {
# Cleanup
    rm -r downloads
    rm -r conversion
    case $keepLogs in
  (false)    rm -r logs;;
    esac

}

function json_process {
# This function process the json file to calculate certain parameters.
    # Firstly, the number of tracks filled is calculated, this will ensure that the JSON is complete.
    
numOfTracks="$(jq -r '[.tracks | keys] | flatten | length' $fileDirect)"
if ! test $numOfTracks -eq 31; then
    echo "Number of tracks incorrect"
    exit 4;
fi

    # JSON Key Parameters
        # "course-name"     - Optional, acts as a guide to the track listing
        # "enabled"         - Enables the track (1 or 0, if 0, all other keys are optional)
        # "downloadtype"   - Can be:
            # 0 - Standard wget download
            # 1 - smashcustommusic download (No conversion)
            # 2 - youtube download (via yt-dlp)
        
        # "title"           - Name of track.
        # "game"            - Name of game if applicable (optional) // Artist (Optional)
        # "length"          - Length of track (optional)
        # "link"            - Link to track (if download-type is 1, song ID)
        # "startLoop"      - Loop point in samples
        # "endLoop"        - End loop point (end of file) in samples
        # "volume"          - Volume increase of track in dB
        # "speed"           - Speed increase (defaults to 1.10x)
        
    # Obtain all information needed.

enabled="$(jq -r '.tracks | .['$loop'].enabled' $fileDirect)"
courseName="$(jq -r '.Tracks | .['$loop'].Track' $dictionary)"
fileName="$(jq -r '.Tracks | .['$loop'].Filename' $dictionary)"
channels="$(jq -r '.Tracks | .['$loop'].Tracks' $dictionary)"
title="$(jq -r '.tracks | .['$loop'].title' $fileDirect)"
downloadType="$(jq -r '.tracks | .['$loop'].downloadtype' $fileDirect)"
game="$(jq -r '.tracks | .['$loop'].game' $fileDirect)"
length="$(jq -r '.tracks | .['$loop'].length' $fileDirect)"
link="$(jq -r '.tracks | .['$loop'].link' $fileDirect)"
trackLoop="$(jq -r '.tracks | .['$loop'].startLoop' $fileDirect)"
endLoop="$(jq -r '.tracks | .['$loop'].endLoop' $fileDirect)"
volume="$(jq -r '.tracks | .['$loop'].volume' $fileDirect)"
speed="$(jq -r '.tracks | .['$loop'].speed' $fileDirect)"

if test $enabled = "1"; then
    printf "\n\n"
    echo " -- "
    echo "Course Name: $courseName"
    echo "Title: $title"
    echo "Game: $game"
    echo "Length: $length"
    echo " -- "
fi

if test $enabled = "0"; then
        return 1
    fi

}

function downloader_chooser {
# This function decides which download method is used, and downloads the file.
    
    case $downloadType in
        0)
        if test $__DOWNLOAD__ = "curl"; then
            curl "$link" -o ./downloads/output_$loop -s
        else
            wget "$link" -O ./downloads/output_$loop -o ./logs/log_$loop.txt
        fi
        ;;
        
        1)
        if test $__DOWNLOAD__ = "curl"; then
            curl "https://smashcustommusic.net/brstm/$link" -o ./conversion/output_$loop$extension -s
        else
            wget "https://smashcustommusic.net/brstm/$link" -O ./conversion/output_$loop$extension -o ./logs/log_$loop.txt
        fi
        ;;
        
        2)
        yt-dlp "$link" -f 251 -o ./downloads/output_$loop > ./logs/log_$loop.txt
        ;;
        
        *)
        echo "Invalid Download Method"
        exit 4;
        ;;
    esac
}

function track_processor {
# This function produces the brstms from the supplied information.

packName="$(jq -r '.name' $fileDirect)"

if ! test $downloadType = "1"; then
    ffmpeg -i "./downloads/output_$loop" "./downloads/output_$loop.wav" > ./logs/log_file_convert_$loop.txt 2>&1
    brstm_converter "./downloads/output_$loop.wav" -o "./conversion/output_$loop$extension" -l $trackLoop > ./logs/log_convert_$loop.txt
fi
    brstm_converter "./conversion/output_$loop$extension" -o "./packs/$packName/$fileName"n"$extension" --ffmpeg "-af volume=$volume'dB'" --extend $endLoop > ./logs/log_volume_$loop.txt 2>&1
    if test $speed = "null"; then
        speed=1.10
    fi
    brstm_converter "./packs/$packName/$fileName"n"$extension" -o "./packs/$packName/$fileName"f"$extension" --ffmpeg "-filter:a "rubberband=pitch=1.05,rubberband=tempo=$speed,rubberband=pitchq=quality"" > ./logs/log_speed_$loop.txt 2>&1
}

# - - - - - - - - - - - - - - - -
# Main Program Start
# - - - - - - - - - - - - - - - -

file=""
extension=".brstm"
dictionary="trackListing.json"
loop=0
__DOWNLOAD__="wget"
keepLogs=false

trackNumber=-1
argu_check $@
file_check
file_selection_menu
user_file_check $file
printf "\n -- beginning download and construction process -- "
init
echo "$(test -z $trackNumber)"

if ! test $trackNumber = -1; then
    loop=$trackNumber
    json_process
    downloader_chooser
    track_processor
else
    #For loop for performing the download and construction on each line of the json.
    for loop in {0..30}
    do
    json_process

    if test $? -eq 1; then
        continue
    fi

    downloader_chooser
    track_processor
    loop=$loop+1
    done
fi

deinit

echo "Download Complete"
exit 0;
