#!/sbin/sh

APKFILE="PrebuiltGmsCore.apk"
APKPATH="/tmp/gms/priv-app/PrebuiltGmsCore"

LCD=$(grep ro.sf.lcd_density /system/build.prop | cut -d "=" -f 2);

if [ "$LCD" == 480 ]; then
  echo "LCD 480 detected."
  cp -a /tmp/gms/* /system/
fi
rm -rf /tmp/gms
