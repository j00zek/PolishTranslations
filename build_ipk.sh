#!/bin/sh
. /DuckboxDisk/j00zek-NP/activePaths.config

myDir=`dirname $0`
PluginName='TranslationsUpdater'
PluginPath="/usr/lib/enigma2/python/Plugins/Extensions/$PluginName"
PluginGITpath="$myDir/$PluginName"
wersja=`grep 'wersja=' <$myDir/$PluginName/__init__.py|cut -d '=' -f2`

$build_ipk_package "$PluginName" "$PluginPath" "$PluginGITpath" "$wersja" "enigma2-plugin-extensions--j00zeks-"

exit 0
