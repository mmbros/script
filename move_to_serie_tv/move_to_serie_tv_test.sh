#!/bin/bash

CURRENT_DIR=`pwd`

# test
DIR_DEST="./dst/serie_tv"
DIR_SOURCE="./src"

rm -r $DIR_DEST
rm -r $DIR_SOURCE

mkdir -p $DIR_DEST
mkdir -p $DIR_SOURCE

cd $DIR_SOURCE
# touch "[DLMux 720p - H264 - Ita Mp3] The Blacklist S03e01 - L'allevatore di troll.by.IperB.mkv"
# touch "[DLMux 720p - H264 - Ita Mp3] The Blacklist S03e02 - Marvin Gerard.by.IperB.mkv"
# touch "person.of.interest.501.mkv"
# touch "person.of.interest.S5E01.mkv"
# touch "Person.Of.Interest.S5E01.mkv"
# touch "Person of Interest.S05E01.mkv"
# touch "person of interest.5x01.mkv"
touch "Il.Trono.Di.Spade.6x02.Uomini.Di.Ferro.720p.DLMux.ITA.ENG.Subs.H.264-BlackBit.mkv"

cd $CURRENT_DIR

./move_to_serie_tv.sh -d "$DIR_DEST" -s "$DIR_SOURCE"
