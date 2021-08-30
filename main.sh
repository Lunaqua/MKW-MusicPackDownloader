#!/bin/bash

# Exit conditions
	# 0 - Script executed correctly.
    # 1 - Entered file does not exist.
	# 2 - Required file not found.
	# 3 - No json files.
    # 4 - Invalid JSON File

# This script will download and construct a mario kart wii music pack.
# Requirements are set in README.MD.

function file_check {

#Check for required files

if ! hash "wget" 2>/dev/null; then
	echo "wget not found";
	exit 2;
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
    mkdir My\ Stuff
    mkdir logs

}

function deinit {
# Cleanup
    rm -rf downloads
    rm -rf conversion
    rm -rf My\ Stuff

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
        # "game"            - Name of game if applicable (optional)
        # "length"          - Length of track (optional)
        # "link"            - Link to track (if download-type is 1, song ID)
        # "loop"            - Loop point in samples
        # "volume"          - Volume increase of track in dB
        # "speed"           - Speed increase (defaults to 1.10x)
        
    # Obtain all information needed.

courseName="$(jq -r '.Tracks | .['$loop'].Track' $dictionary)"
fileName="$(jq -r '.Tracks | .['$loop'].Filename' $dictionary)"
channels="$(jq -r '.Tracks | .['$loop'].Tracks' $dictionary)"
title="$(jq -r '.tracks | .['$loop'].title' $fileDirect)"
enabled="$(jq -r '.tracks | .['$loop'].enabled' $fileDirect)"
downloadType="$(jq -r '.tracks | .['$loop'].downloadtype' $fileDirect)"
game="$(jq -r '.tracks | .['$loop'].game' $fileDirect)"
length="$(jq -r '.tracks | .['$loop'].length' $fileDirect)"
link="$(jq -r '.tracks | .['$loop'].link' $fileDirect)"
loop="$(jq -r '.tracks | .['$loop'].loop' $fileDirect)"
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
        wget "$link" -O ./downloads/output_$loop -o ./logs/log_$loop.txt
        ;;
        
        1)
        wget "https://smashcustommusic.net/brstm/$link" -O ./downloads/output_$loop$extension -o ./logs/log_$loop.txt
        ;;
        
        2)
        yt-dlp "$link" -f 251 -o ./downloads/output_$loop.webm > /logs/log_$loop.txt
        ;;
        
        *)
        echo "Invalid Download Method"
        exit 4;
        ;;
    esac
}

# - - - - - - - - - - - - - - - -
# Main Program Start
# - - - - - - - - - - - - - - - -

file=""
extension=".brstm"
dictionary="trackListing.json"
loop=0

file_check
file_selection_menu
user_file_check $file
printf "\n -- beginning download and construction process -- "
init

json_process
#if test $? -eq 1; then
#    echo "do next loop number"
#fi

downloader_chooser
#deinit

exit 0;
