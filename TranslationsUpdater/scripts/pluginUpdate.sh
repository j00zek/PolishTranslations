#
myPath=`dirname $0`
[ -e /tmp/PolishTranslations.tar.gz ] && rm -rf /tmp/PolishTranslations.tar.gz
[ -e /tmp/.rebootGUI ] && rm -rf /tmp/.rebootGUI

rm -rf /tmp/j00zek-PolishTranslations-* 2>/dev/null
sudo rm -rf /tmp/j00zek-PolishTranslations-* 2>/dev/null

curl --help 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo "Wymagany program 'curl' jest niezainstalowany. Próbuję instalacji poprzez OPKG."
  echo
  opkg install curl 

  curl --help 1>/dev/null 2>&1
  if [ $? -gt 0 ]; then
    echo
    echo "Wymagany program 'curl' jest niedostępny w OPKG. Zainstaluj go najpierw samodzielnie."
    exit 0
  fi
fi

echo "Sprawdzam tryb instalacji..."
if `opkg list-installed 2>/dev/null | tr '[:upper:]' '[:lower:]'| grep -q 'polishtranslations'`;then
  echo "Aktualizator tłumaczeń jest kontrolowany przez OPKG. Proszę użyć OPKG do aktualizacji wtyczki."
  exit 0
fi

echo "Sprawdzam połączenie z serwerem..."
ping -c 1 github.com 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo "Serwer github jest niedostępny, aktualizacja niemożliwa!!!"
  exit 0
fi

echo "Pobieram najświerzsze archiwum..."
$myPath/pyCurl https://api.github.com/repos/j00zek/PolishTranslations/tarball/master /tmp/PolishTranslations.tar.gz

if [ ! -e /tmp/PolishTranslations.tar.gz ]; then
  echo "_(No archive downloaded, check your curl version)"
  exit 0
fi

echo "Rozpakowuję archiwum..."
#cd /tmp
tar -zxf /tmp/PolishTranslations.tar.gz -C /tmp
if [ $? -gt 0 ]; then
  echo "_(Archive unpacked improperly)"
  exit 0
fi

if [ ! -e /tmp/j00zek-PolishTranslations-* ]; then
  echo "_(Archive downloaded improperly)"
  exit 0
fi
rm -rf /tmp/PolishTranslations.tar.gz

version=`ls /tmp/ | grep j00zek-PolishTranslations-`

echo "Instaluję nową wersję wtyczki..."
if [ ! -e /DuckboxDisk ]; then
  cp -a /tmp/$version/TranslationsUpdater/* /usr/lib/enigma2/python/Plugins/Extensions/TranslationsUpdater/
else
  echo
  echo "github is always up-2-date"
fi

if [ $? -gt 0 ]; then
  echo
  echo "Błąd instalacji!!!"
else
  echo
  echo "_(Success: Restart system to use new plugin version)"
fi

touch /tmp/.rebootGUI
exit 0
