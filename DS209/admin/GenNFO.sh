#!/opt/bin/bash

#Usage
# GenNFO.sh [-n]  "Nom du film" "Fichier_video_avec_extension"
# -n : Verbose output / No file modification

NULL_OUPUT=0
while getopts n OPTION
do
  case $OPTION in
  n)
    NULL_OUPUT=1
    echo "** Script execute en mode verbose/no output **"
    shift
    ;;
  esac
done
                  
MOVIE_NAME="$1"
VIDEO_FILENAME="$2"


#Requete HTML
SEARCH_STRG=`echo "$MOVIE_NAME" |sed 's/ /%20/g'`
if [ $NULL_OUPUT -eq 1 ]
then
  echo "Film : \"$1\""
  echo "Fichier video : \"$2\""
  echo ""
  echo "Search strg = \"$SEARCH_STRG\""
  echo ""
fi
REQ="http://api.allocine.fr/xml/search?q=${SEARCH_STRG}&partner=1&count=1&json=1"

#Get Allocine ID
RECUP_BRUTE=`curl -L -s --max-time 10 $REQ `
#ID_ALLOCINE=`echo $RECUP_BRUTE  | grep -m 1 "/api.allocine.fr/xml/movie?code=" | sed 's/.*\/api\.allocine\.fr\/xml\/movie\?code=//g' | sed 's/\.<\/atom.*//g'`
ID_ALLOCINE=`echo $RECUP_BRUTE  | grep -m 1 "code" | sed 's/{\"feed\":{\"movie\":\[{\"code\"://g' | sed 's/,.*//g'`

if [ $NULL_OUPUT -eq 1 ]
then
  echo "Recup brute : \"$RECUP_BRUTE\""
  echo "ID Allocine = \"$ID_ALLOCINE\""
fi

#Fichier destination
NO_EXT=${VIDEO_FILENAME%.*}
if [ -e "$NO_EXT.nfo" ]
then
  echo "Fichier existant : renommage"
  CURRENT_DATE=`date +%Y%m%d_%H%M%S`
  if [ $NULL_OUPUT -eq 0 ]
  then
    mv "$NO_EXT.nfo" "$NO_EXT.$CURRENT_DATE.nfo"
  fi
fi

TMP_OUT=tmp.nfo
TMP_OUT2=tmp2.nfo

echo "<movie>" >> $TMP_OUT
echo "<title>$MOVIE_NAME</title>" >> $TMP_OUT
echo "<id moviedb=\"allocine\">$ID_ALLOCINE</id>" >> $TMP_OUT
echo "</movie>" >> $TMP_OUT

if [ $NULL_OUPUT -eq 0 ]
then
  iconv -s -f ASCII -t UTF-8  $TMP_OUT >> "$NO_EXT.nfo"
  rm -f $TMP_OUT

  echo "Fichier \"$NO_EXT.nfo\" généré :"
  cat "$NO_EXT.nfo"
else
  iconv -s -f ASCII -t UTF-8  $TMP_OUT >> $TMP_OUT2
  echo ""
  echo "Simulation de résultat :"
  cat "$TMP_OUT2"
  
  rm -f $TMP_OUT
  rm -f $TMP_OUT2
fi
  

echo "---"
echo "Check URL : http://www.allocine.fr/film/fichefilm_gen_cfilm="$ID_ALLOCINE".html"
if [ $NULL_OUPUT -eq 1 ]
then
  echo "--- TMP Récuperation brute ---"
  echo "$RECUP_BRUTE"
fi
