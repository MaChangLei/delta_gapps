#!/bin/bash

APKLIST=$(find chrome-lollipop-arm/optional/apkbin -name com.*.apk | sort)
FILENAME=GoogleChrome.apk
INDIR=chrome-lollipop-arm
NAME=gapps-chrome
VER=arm-lm

DATE=$(date +%F-%H-%M)
BASEDIR=$(pwd)

function tout {
  tee /dev/tty >> "$BASEDIR"/build.log
}

echo "" | tout
echo "Updating "$INDIR" on $DATE for lollipop and marshmallow" | tout
echo "Google Chrome add-on for 5.0.2+ (arm) (replaces stock web browser)" | tout
echo "" | tout

for FILEPATH in $APKLIST ; do

  DIR=$(dirname "${FILEPATH}")
  FILE=${FILEPATH##*/}
  NOEXT=${FILE%\.*}

  VERSION=${FILE%_min*}
  VERSION=${VERSION#*_}
  APIVER=$(echo ${FILE#*_min} | cut -d "_" -f 1)

  cd "$BASEDIR"
  cd "$DIR"

  echo "Extracting libraries from apk"
  if [ -e "$FILENAME" ]; then
    unzip -o "$FILENAME" lib/* -d ./
    mv lib lib.old
  fi
  unzip -o "$FILE" lib/* -d ./

  if [ ! -d lib/armeabi-v7a ] && [ ! -d lib/armeabi ] ; then
    echo "Libraries are not for arm"
  else
    if [ -d lib.old/armeabi-v7a ] ; then
      mkdir ./lib.old/arm
      cp -a ./lib.old/armeabi-v7a/* ./lib.old/arm/
      rm -rf  ./lib.old/armeabi-v7a
    else
      mkdir ./lib.old/arm
      cp -a ./lib.old/armeabi/* ./lib.old/arm/
      rm -rf ./lib.old/armeabi
    fi

    if [ -d lib/armeabi-v7a ] ; then
      mkdir ./lib/arm
      cp -a ./lib/armeabi-v7a/* ./lib/arm/
      #echo "Deleting lib directory inside apk file"
      zip "$FILE" -d ./lib/armeabi-v7a/*
      #echo "Inserting decompressed libraries inside apk file"
      zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi-v7a/
      rm -rf  ./lib/armeabi-v7a
    else
      mkdir ./lib/arm
      cp -a ./lib/armeabi/* ./lib/arm/
      #echo "Deleting lib directory inside apk file"
      zip "$FILE" -d ./lib/armeabi/*
      #echo "Inserting decompressed libraries inside apk file"
      zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi/
      rm -rf ./lib/armeabi
    fi

    echo "Aligning apk and libraries for 32bit systems"
    zipalign -f -p 4 "$FILE" "$NOEXT"-aligned.apk
    rm "$FILE"
    mv "$NOEXT"-aligned.apk "$FILENAME"

    echo "Libraries aligned."
  fi

  echo "Version: $VERSION" | tout
  echo "minAPI/DPI: $APIVER" | tout

  if [ -d lib ] && [ -d lib.old ]; then
    diff -rq lib.old lib | grep Only | tout
  fi

  echo "" | tout
  echo "Removing extracted files."

  if [ -d lib ]; then
    rm -rf lib
  fi

  if [ -d lib.old ]; then
    rm -rf lib.old
  fi
done

cd "$BASEDIR"
./makezipsign.sh "$INDIR" "$NAME" "$VER"
