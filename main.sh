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
        printf "\nMusic Pack Information"
        echo "---"
        echo "Name: $(jq -r '.name' $fileDirect)"
        echo "Author: $(jq -r '.author' $fileDirect)"
        echo "Date: $(jq -r '.date' $fileDirect)"
        echo "---"
        
        printf "\n Is this the correct pack? (Y/n): "
        read userChoice
        
        if [ $userChoice = "n" ] || [ $userChoice = "N" ]; then
            echo "Program will exit"
            exit 0;
        fi

}

# - - - - - - - - - - - - - - - -
# Main Program Start
# - - - - - - - - - - - - - - - -

file=""

file_check
file_selection_menu
user_file_check $file
