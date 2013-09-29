#!/bin/sh

EXTENSION_VIDEO="mkv"
EXTENSION_SUBS="srt"

PATTERN_VIDEO_SEASON=".*\.S\([0-9]*\)E.*"
PATTERN_VIDEO_EPISODE=".*\.S[0-9]*E\([0-9]*\)\..*"

# Defintion des patterns de sous titres
# Variabilisation : 
#   %%S2%% = Saison sur 2 digits
#   %%S1%% = Saison sur 1 digit
#   %%E2%% = Episode sur 2 digits
#   %%E1%% = Episode sur 1 digit
PATTERN_SUBS_1=".S%%S2%%E%%E2%%."
PATTERN_SUBS_2=".S%%S1%%E%%E1%%."
PATTERN_SUBS_3=".S%%S2%%xE%%E2%%."
PATTERN_SUBS_4=".S%%S1%%xE%%E1%%."
PATTERN_SUBS_5=".%%S1%%x%%E1%%."
PATTERN_SUBS_6=".%%S1%%x%%E2%%."
PATTERN_SUBS_7=".%%S1%%%%E2%%."
PATTERN_SUBS_8=".s%%S2%%e%%E2%%."

PATTERNS_SUBS_ALL="$PATTERN_SUBS_1 $PATTERN_SUBS_2 $PATTERN_SUBS_3 $PATTERN_SUBS_4 $PATTERN_SUBS_5 $PATTERN_SUBS_6 $PATTERN_SUBS_7 $PATTERN_SUBS_8"


## Looking for *.EXTENSION_VIDEO
## If found.EXTENSION_SUBS does not exist, we look according to the patterns

find . -name "*.$EXTENSION_VIDEO" -maxdepth 1  | while read video_file
do
	unext_video=${video_file%.*}
	sub_file=${unext_video}.${EXTENSION_SUBS}
	##echo "SUB FILE : $sub_file"
	if [ -f "$sub_file" ]
	then
		echo "Subtitle file already exists : $sub_file"
	else
		echo "Looking for a subtitle file matching $video_file"
		# Decoding video file tags
		SEASON=`echo "$video_file" | sed "s|$PATTERN_VIDEO_SEASON|\1|"`
		EPISODE=`echo "$video_file" | sed "s|$PATTERN_VIDEO_EPISODE|\1|"`
		echo " * Decoding : SEASON=$SEASON - EPISODE=$EPISODE"
		
		## Preparing replacements
		DIGIT_1=${SEASON:0:1}
		#echo " ** Digit 1 = $DIGIT_1"
		if [ $DIGIT_1 -eq 0 ]
		then
			SEASON_1_DIGIT=${SEASON:1}
			#echo " ** Season on 1 digit = $SEASON_1_DIGIT"
		else
			SEASON_1_DIGIT=$SEASON
		fi
		DIGIT_1=${EPISODE:0:1}
		#echo " ** Digit 1 = $DIGIT_1"
		if [ $DIGIT_1 -eq 0 ]
		then
			EPISODE_1_DIGIT=${EPISODE:1}
			#echo " ** Season on 1 digit = $SEASON_1_DIGIT"
		else
			EPISODE_1_DIGIT=$EPISODE
		fi
		# Going through the patterns
		FOUND_SUBS=0
		for pattern in $PATTERNS_SUBS_ALL
		do
			#echo " ** Trying with pattern : $pattern"
			pattern_mod=`echo $pattern | sed "s|%%S2%%|$SEASON|"`
			pattern_mod=`echo $pattern_mod | sed "s|%%S1%%|$SEASON_1_DIGIT|"`
			pattern_mod=`echo $pattern_mod | sed "s|%%E2%%|$EPISODE|"`
			pattern_mod=`echo $pattern_mod | sed "s|%%E1%%|$EPISODE_1_DIGIT|"`
			#echo " ** Pattern mod = $pattern_mod"
			## Count matching files
			COUNT_POTENTIAL_SUBS=`find . -name "*$pattern_mod*$EXTENSION_SUBS" -maxdepth 1 | wc -l `
			#echo "Nb Found = $COUNT_POTENTIAL_SUBS"
			if [ $COUNT_POTENTIAL_SUBS -eq 1 ] && [ $FOUND_SUBS -eq 0 ]
			then
				FOUND_SUBS=1
				SRT_FILE=`find . -name "*$pattern_mod*$EXTENSION_SUBS" -maxdepth 1`
				echo " * SRT found (with pattern $pattern_mod) : $SRT_FILE"
				echo " ** Renaming \"$SRT_FILE\" ==> \"$sub_file\""
				mv "$SRT_FILE" "$sub_file"
			fi
		done
		if [ $FOUND_SUBS -eq 0 ]
		then
			echo " *#* No Subtitle file found for $video_file"
		fi
	fi
done
