#!/sbin/sh

APKFILE="GoogleDrive.apk"
APKPATH="/tmp/apkbin/app/GoogleDrive"
SYSPATH="app"

LCD=$(grep ro.sf.lcd_density /system/build.prop | cut -d "=" -f 2);

if [ "$LCD" == 480 ]; then
  echo "LCD 480 detected."
  if grep ro.build.version.release /system/build.prop | grep 4.4.; then
    echo kk
    cd "$APKPATH"
    /tmp/unzip -o "$APKFILE" lib/* -d ./
    mkdir -p ./lib/arm64
    mv ./lib/arm64-v8a/* ./lib/arm64/
    rmdir ./lib/arm64-v8a
    /tmp/zip "$APKFILE" -d ./lib/arm64-v8a/*
    /tmp/zipalign -f 4 "$APKFILE" aligned.apk
    mv aligned.apk "$APKFILE"
    cp -a /tmp/addon/kk/* /system/
    cp -f "$APKPATH"/"$APKFILE" /system/"$SYSPATH"/
    cp -a "$APKPATH"/lib/arm64/* /system/lib64/
  elif grep ro.build.version.release /system/build.prop | grep -qE '5.0.|5.1.'; then
    echo lp
    cd "$APKPATH"
    /tmp/unzip -o "$APKFILE" lib/* -d ./
    mkdir -p ./lib/arm64
    mv ./lib/arm64-v8a/* ./lib/arm64/
    rmdir ./lib/arm64-v8a
    /tmp/zip "$APKFILE" -d ./lib/arm64-v8a/*
    /tmp/zipalign -f 4 "$APKFILE" aligned.apk
    mv aligned.apk "$APKFILE"
    cp -a /tmp/addon/lp/* /system/
    cp -a /tmp/apkbin/* /system/
  else
    echo mm
    cp -a /tmp/addon/lp/* /system/
    cp -a /tmp/apkbin/* /system/
    sed -i '/GoogleDrive\/lib/ d' /system/addon.d/75-gapps-drive.sh
  fi
fi
rm -f "$APKPATH"/"$APKFILE"
