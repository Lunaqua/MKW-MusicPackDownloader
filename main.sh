#!/bin/bash

# Exit conditions
	# 0 - Script executed correctly.
	# 2 - Required file not found.
	# 3 - No json files.

# This script will download the construct a mario kart wii music pack.
# Requirements are set in README.MD.

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
