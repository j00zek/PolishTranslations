#
[ -e /tmp/PolishTranslations.tar.gz ] && rm -rf /tmp/PolishTranslations.tar.gz
[ -e /tmp/.rebootGUI ] && rm -rf /tmp/.rebootGUI

rm -rf /tmp/j00zek-PolishTranslations-* 2>/dev/null
sudo rm -rf /tmp/j00zek-PolishTranslations-* 2>/dev/null

curl --help 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo "_(Required program 'curl' is not installed. Trying to install it via OPKG.)"
  echo
  opkg install curl 

  curl --help 1>/dev/null 2>&1
  if [ $? -gt 0 ]; then
    echo
    echo "_(Required program 'curl' is not available. Please install it first manually.)"
    exit 0
  fi
fi

echo "Sprawdzam tryb instalacji..."
if `opkg list-installed 2>/dev/null | tr '[:upper:]' '[:lower:]'| grep -q 'polishtranslations'`;then
  echo "_(UserSkin controlled by OPKG. Please use it for updates.)"
  exit 0
fi

echo "Sprawdzam połączenie z serwerem..."
ping -c 1 github.com 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo "_(github server unavailable, update impossible)!!!"
  exit 0
fi

echo "Pobieram najświerzsze archiwum..."
curl -kLs https://api.github.com/repos/j00zek/PolishTranslations/tarball/master -o /tmp/PolishTranslations.tar.gz
if [ $? -gt 0 ]; then
  echo "_(Archive downloaded improperly)"
  exit 0
fi

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
