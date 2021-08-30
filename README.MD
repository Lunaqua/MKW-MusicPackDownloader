# Mario Kart Wii - Music Pack Downloader

## What is this?

This is a bash script created for the purpose of downloading and constucting Mario Kart Wii music packs. 

It does this by processing a json file containing information on the music pack; including track listing, and loop information. 

## Why would you do this?

Music packs are usually annoying to download, as they are large, and downloads are only usually found in yt descriptions. 

Download links can also often go missing, and making updates requires another large download. 

This script attempts to fix this by making downloading music packs reliant on a text file, and multiple websites. 

### Additional info

Many MKWii mods nowadays contain an automatic brsar patcher meaning a patched revokart.brsar is often not needed. 

However, if using this pack standalone, or alongside a mod that doesn't automatically patch revokart, you will need to obtain a copy of revokart and patch it yourself. 

This script does not obtain or patch it for you. 

## How to use

### Requirements and Dependencies

This script requires a few programs in order to work. 
	
	ffmpeg - Required for brstm conversion. 
	openrevolution (Must be compiled) - Required for brstm conversion. 
	wget - Required for downloading of files. 
	yt-dlp - Required for downloading from youtube. 
	jq - Required for interpreting json files. 
    
### Usage

Run the script using "bash main.sh" or "./main.sh".
It will allow you select the different JSON files you have available.
An example file is included for testing purposes.

Follow the on-screen prompts and wait until all files are downloaded and converted.
If everything goes okay, the pack will available in "My Stuff"

## Making a pack

### Creating a JSON

The only part of a pack that the end-user needs is a single JSON file.
This small guide will quickly show you how to make one.

The "example.json" file located in the "JSON" directory, can be used as an example and a template.

Start the JSON by creating the file and entering the initial information. This is the name, author and version of your pack for example.

Here are the keys accepted.

      "header"    - This is required to be set to "MKWMP-HEADER" for the JSON to work within the program.
      "mkversion" - This specifies the version of the program this file is for use with. This is required. (Currently v1.0.0)
      "name"      - The name of your pack.
      "author"    - Who you are.
      "date"      - The date the pack was authored.
      "version"   - The version of this pack.
    
This information will be displayed to the end-user.

#### Entering Track information

The "tracks" array must contain 31 entries for the JSON to be valid. Not all of these have to be enabled.
The order of your tracks is decided by the order of the tracks in "trackListing.json", so check that for the order.

Each key can contain the following information.

Required keys are marked with *, and are required unless "enabled" is set to 0. "enabled" is always required.

      "course-name"     - This key is optional, and simply can be used as a comment or guide to track order.
    * "enabled"         - Enables the track (1 or 0)
    * "downloadtype"   - Can be:
        0 - Standard file download using wget.
        1 - Download from Smashcustommusic.net
        2 - Download from YouTube.
        
    * "title"           - Name of track.
      "game"            - Name of game if applicable (optional)
      "length"          - Length of track (optional)
    * "link"            - Link to track (if download-type is 1, set to song ID)
    * "loop"            - Loop point in samples (obtain using audacity or equiv. tool)
    * "volume"          - Volume increase of track in dB
      "speed"           - Speed increase (defaults to 1.10x) (limited to range from 0.5 to 2.0)
    
Do this for all 31 tracks in the game, and you will have a complete music pack.

## Todo

- Creation of multi-channel brstms
- Support for other music files (winning tune, track intro)
- Creation of "fast" brstms with pitch-bend
- Possible download from other websites.
- Creation of "fast" brstm from seperate music file
- Better file browser.



