#!/bin/bash

FILEPATH=$(ls cloudprint/optional/apkbin/app/CloudPrint2/com.*.apk)
FILENAME=CloudPrint2.apk
INDIR=cloudprint
NAME=gapps-cloudprint
VER=arm-arm64-klmn

DATE=$(date +%F-%H-%M)
BASEDIR=$(pwd)

echo "" >> build.log
echo "Updating "$INDIR" on $DATE for kitkat, lollipop, marshmallow, and nougat" >> build.log
echo "Google CloudPrint add-on for 4.4.4+ (arm/arm64)" >> build.log

DIR=$(dirname "${FILEPATH}")
FILE=${FILEPATH##*/}
NOEXT=${FILE%\.*}

cd "$DIR"

if ! [ $FILE == "" ]; then
  rm "$FILENAME"
  mv "$FILE" "$FILENAME"
fi

VERSION=$(echo "$FILE" | cut -d "_" -f 2)
APIVER=$(echo "$FILE" | cut -d "_" -f 3)

cd "$BASEDIR"

echo "Version: $VERSION" >> build.log
echo "API: $APIVER" >> build.log
echo "" >> build.log

./makezipsign.sh "$INDIR" "$NAME" "$VER"
