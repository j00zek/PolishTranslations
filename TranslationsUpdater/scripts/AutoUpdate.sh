#!/bin/sh 
# @j00zek 2016/2020
#
myPath=`dirname $0`

if [ -e /usr/local/e2/etc/enigma2/settings ];then
  settingsFile='/usr/local/e2/etc/enigma2/settings'
  ENIGMA2_PATH='/usr/local/e2/share/enigma2/po/pl/LC_MESSAGES'
  PLUGINS_PATH='/usr/local/e2/lib/enigma2/python/Plugins'
else
  settingsFile='/etc/enigma2/settings'
  ENIGMA2_PATH='/usr/share/enigma2/po/'
  PLUGINS_PATH='/usr/lib/enigma2/python/Plugins'
fi

RaportIkoniec()
{
[ -z "$1" ] && echo "Błąd, koniec" || echo "$1"
exit 0
}
if ! `grep -q 'config.plugins.TranslationsUpdater.AutoUpdate=true' <$settingsFile`;then
  RaportIkoniec "AutoUpdate wyłączony. :("
fi

#pobieranie dostępnych tłumaczeń
$myPath/pyCurl 'https://raw.githubusercontent.com/j00zek/PolishTranslations/master/Menu.conf' '/tmp/PolishTranslations.menu'
DownloadableTranslations=`cat /tmp/PolishTranslations.menu|sed -e 's;^\(.*\)|\(.*\)|\(.*\)|\(.*\);\2|\1|\3|\4;'|sort -bfir|grep -v "^#"`
[ $? -gt 0 ] && RaportIkoniec "Błąd pobierania tłumaczeń :("

#sprawdzanie, czy jest coś do aktualizacji
IFS=$'\n'
for ArchiveName in $DownloadableTranslations
do
  #echo "$ArchiveName"
  mydata=`echo "$ArchiveName"|cut -f1`
  WebTranslationdataEPOC=`date --date="$mydata" +%s`
  addonLink=`echo $ArchiveName|cut -d$'\t' -f3|sed 's/\.po//'`
  #echo "$addonLink=$WebTranslationdataEPOC($mydata)"
  if [ "$addonLink" == "enigma2" ];then
    findPath=$ENIGMA2_PATH
  else
    findPath=$PLUGINS_PATH
  fi
  if `find $findPath -name $addonLink.mo|grep -q -m1 "$addonLink.mo"`;then
    #znajdujemy jakiekolwiek tłumaczenie i zamieniamy ścieżkę na pl
    addonConfig=`find $findPath -name $addonLink.mo|grep -m1 "/pl/"`
    [ -z $addonConfig ] && addonConfig=`find $findPath -name $addonLink.mo|grep -m1 "/en/"|sed 's;/en/;/pl/;'`
    [ -z $addonConfig ] && addonConfig=`find $findPath -name $addonLink.mo|grep -m1 "/de/"|sed 's;/de/;/pl/;'`
    [ -z $addonConfig ] && addonConfig=`find $findPath -name $addonLink.mo|grep -m1 "/ru/"|sed 's;/ru/;/pl/;'`
    #echo $addonConfig
    [ -z $addonConfig ] && continue # opuszczamy reszte, jesli nie znalezlismy
    if [ -f $addonConfig ];then
      if [ $WebTranslationdataEPOC -gt `stat -c %Y $addonConfig` ];then
        echo "Aktualizuję $addonLink=$WebTranslationdataEPOC($mydata)"
        $myPath/getPO.sh $addonLink.po $addonConfig
      fi
    else
      echo "instaluje nowe polskie tłumaczenie $addonLink"
      $myPath/getPO.sh $addonLink.po $addonConfig
    fi
  fi
done
if [ -f /tmp/.rebootGUI ];then
  rm -f /tmp/.rebootGUI
  exit 99
fi
exit 0