#!/bin/bash

FILEPATH=$(find clock/optional/apkbin/app/GoogleDeskClock -name com.*.apk | sort)
FILENAME=GoogleDeskClock.apk
INDIR=clock
NAME=gapps-deskclock
VER=arm-arm64-klmn

DATE=$(date +%F-%H-%M)
BASEDIR=$(pwd)

function tout {
  tee /dev/tty >> "$BASEDIR"/build.log
}

echo "" | tout
echo "Updating "$INDIR" on $DATE for kitkat, lollipop, marshmallow, and nougat" | tout
echo "Google Clock add-on for 4.4.4+ (arm/arm64) (replaces stock deskclock)" | tout
echo "" | tout

if [ ! "$FILEPATH" == "" ]; then
  DIR=$(dirname "${FILEPATH}")
  FILE=${FILEPATH##*/}
  NOEXT=${FILE%\.*}

  cd "$DIR"

  if [ ! "$FILE" == "" ]; then
    rm "$FILENAME"
    mv "$FILE" "$FILENAME"

    VERSION=${FILE%_min*}
    VERSION=${VERSION#*_}
    APIVER=$(echo ${FILE#*_min} | cut -d "_" -f 1)

    cd "$BASEDIR"

    echo "Version: $VERSION" | tout
    echo "minAPI/DPI: $APIVER" | tout
    echo "" | tout
  fi
fi

./makezipsign.sh "$INDIR" "$NAME" "$VER"
