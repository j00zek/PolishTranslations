#!/bin/sh
myDir=`dirname $0`
PluginName='TranslationsUpdater'
PluginPath="/usr/lib/enigma2/python/Plugins/Extensions/$PluginName"
PluginGITpath="$myDir/$PluginName"
wersja=`grep 'wersja=' <$myDir/$PluginName/__init__.py|cut -d '=' -f2`

$myDir/../IPKs-storage/build_ipk_package.sh "$PluginName" "$PluginPath" "$PluginGITpath" "$wersja" "enigma2-plugin-extensions--j00zeks-"

if ! `grep -q "$myDir/build_ipk.sh" <$myDir/../IPKs-storage/build_ipk_packages.sh`;then
  echo "$myDir/build_ipk.sh">>$myDir/../IPKs-storage/build_ipk_packages.sh
fi
exit 0
