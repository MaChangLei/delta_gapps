#!/bin/bash

APKLIST=$(find gapps-base-arm-810/optional/gms -name com.*.apk | sort)
FILENAME=PrebuiltGmsCore.apk
APKPATH=$(find gapps-base-arm-810/system/priv-app/Phonesky -name com.*.apk | sort)
APKNAME=Phonesky.apk
INDIR=gapps-base-arm-810

DATE=$(date +%F-%H-%M)
BASEDIR=$(pwd)

function tout {
  tee /dev/tty >> "$BASEDIR"/build.log
}

echo "" | tout
echo "Updating "$INDIR" on $DATE for oreo" | tout
echo "Oreo Base Gapps package for 8.1.0 (arm)" | tout
echo "" | tout

if [ ! "$APKPATH" == "" ]; then
  DIR=$(dirname "${APKPATH}")
  FILE=${APKPATH##*/}
  NOEXT=${FILE%\.*}

  cd "$DIR"

  if [ ! "$FILE" == "" ]; then

    VERSION=${FILE%_min*}
    VERSION=${VERSION#*_}
    APIVER=$(echo ${FILE#*_min} | cut -d "_" -f 1)

    echo "Extracting libraries from apk"
    if [ -e "$APKNAME" ]; then
      unzip -o "$APKNAME" lib/* -d ./
      mv lib lib.old
    fi
    unzip -o "$FILE" lib/* -d ./

    if [ ! -d lib/armeabi-v7a ] && [ ! -d lib/armeabi ] ; then
      echo "Libraries are not for arm"
    else
      if [ -d lib.old/armeabi-v7a ] ; then
        mkdir ./lib.old/arm
        mv ./lib.old/armeabi-v7a/* ./lib.old/arm/
        rmdir ./lib.old/armeabi-v7a
      else
        mkdir ./lib.old/arm
        mv ./lib.old/armeabi/* ./lib.old/arm/
        rmdir ./lib.old/armeabi
      fi

      if [ -d lib/armeabi-v7a ] ; then
        #echo "Deleting lib directory inside apk file"
        zip "$FILE" -d ./lib/armeabi-v7a/*
        #echo "Inserting decompressed libraries inside apk file"
        zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi-v7a/
        mkdir ./lib/arm
        mv ./lib/armeabi-v7a/* ./lib/arm/
        rmdir ./lib/armeabi-v7a
      else
        #echo "Deleting lib directory inside apk file"
        zip "$FILE" -d ./lib/armeabi/*
        #echo "Inserting decompressed libraries inside apk file"
        zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi/
        mkdir ./lib/arm
        mv ./lib/armeabi/* ./lib/arm/
        rmdir ./lib/armeabi
      fi

      echo "Aligning apk and libraries for 32bit systems"
      zipalign -f -p 4 "$FILE" "$NOEXT"-aligned.apk
      rm "$FILE"
      mv "$NOEXT"-aligned.apk "$APKNAME"
      echo "Libraries aligned."
    fi

    echo "Updating Google Play Store" | tout
    echo "Version: $VERSION" | tout
    echo "minAPI/DPI: $APIVER" | tout
    echo "" | tout

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

  fi
  cd "$BASEDIR"
fi

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
      mv ./lib.old/armeabi-v7a/* ./lib.old/arm/
      rmdir ./lib.old/armeabi-v7a
    else
      mkdir ./lib.old/arm
      mv ./lib.old/armeabi/* ./lib.old/arm/
      rmdir ./lib.old/armeabi
    fi

    if [ -d lib/armeabi-v7a ] ; then
      #echo "Deleting lib directory inside apk file"
      zip "$FILE" -d ./lib/armeabi-v7a/*
      #echo "Inserting decompressed libraries inside apk file"
      zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi-v7a/
      mkdir ./lib/arm
      mv ./lib/armeabi-v7a/* ./lib/arm/
      rmdir ./lib/armeabi-v7a
    else
      #echo "Deleting lib directory inside apk file"
      zip "$FILE" -d ./lib/armeabi/*
      #echo "Inserting decompressed libraries inside apk file"
      zip -r -D -Z store -b ./ "$FILE" ./lib/armeabi/
      mkdir ./lib/arm
      mv ./lib/armeabi/* ./lib/arm/
      rmdir ./lib/armeabi
    fi

    echo "Aligning apk and libraries for 32bit systems"
    zipalign -f -p 4 "$FILE" "$NOEXT"-aligned.apk
    rm "$FILE"
    mv "$NOEXT"-aligned.apk "$FILENAME"

    echo "Libraries aligned."
  fi

  echo "Updating Google Play Services" | tout
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
./makezipsign.sh "$INDIR"
