#!/sbin/sh

APKFILE="GooglePlus.apk"
APKPATH="/tmp/apkbin/app/GooglePlus"

LCD=$(grep ro.sf.lcd_density /system/build.prop | cut -d "=" -f 2);

if [ ! "$LCD" == 120 ] && [ ! "$LCD" == 160 ] && [ ! "$LCD" == 213 ] && [ ! "$LCD" == 240 ] && [ ! "$LCD" == 320 ] && [ ! "$LCD" == 480 ]; then
  echo "Installing default."
  if grep ro.build.version.release /system/build.prop | grep -qE '5.0.|5.1.'; then
    echo lp
    cd "$APKPATH"
    /tmp/unzip -o "$APKFILE" lib/* -d ./
    mkdir -p ./lib/arm
    mv ./lib/armeabi-v7a/* ./lib/arm/
    rmdir ./lib/armeabi-v7a
    /tmp/zip "$APKFILE" -d ./lib/armeabi-v7a/*
    /tmp/zipalign -f 4 "$APKFILE" aligned.apk
    mv aligned.apk "$APKFILE"
    cp -a /tmp/apkbin/* /system/
  else
    echo mm
    cp -a /tmp/apkbin/* /system/
    sed -i '/GooglePlus\/lib/ d' /system/addon.d/76-gapps-plus.sh
  fi
fi
rm -f "$APKPATH"/"$APKFILE"
