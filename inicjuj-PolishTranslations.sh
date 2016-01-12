# @j00zek 15.12.2015
#This script downloads TranslationsUpdater from github and installs all necessary components
#
if `grep -q 'osd.language=pl_PL' </etc/enigma2/settings`; then
  isInstalled="jest już zainstalowany"
  installedCorrectly="zainstalowany poprawnie"
  installingPackages="Instalacja niezbędnych pakietów..."
  curlError="Wymagany program 'curl' jest niezainstalowany. Zainstaluj go ręcznie."
  inetCheck="Sprawdzanie połączenia..."
  githubError="Serwer github jest niedostępny, instalacja niemożliwa!!!"
  download="Pobieranie ostatniej wersji wtyczki..."
  downloadError="Archiwum pobrane niepoprawnie"
  curlIncorrect="Brak archiwum, sprawdź swoją wersję programu curl"
  unpacking="Wypakowywanie archiwum..."
  unpackError="Archiwum wypakowane niepoprawnie"
  archiveIncorrect="Archiwum pobrane niepoprawnie"
  cleaning="Czyszczenie katalogu TranslationsUpdater-a"
  creating="Tworzenie katalogu TranslationsUpdater"
  installing="Instalacja nowej wersji..."
  success="Sukces: Zrestartuj GUI ręcznie, aby aktywować nową wersję wtyczki"
else
  isInstalled="already installed"
  installedCorrectly="installed correctly"
  installingPackages="Installing necessary packages..."
  curlError="Required program 'curl' is not available. Please install it manually."
  inetCheck="Checking internet connection..."
  githubError="github server unavailable, update impossible!!!"
  download="Downloading latest plugin version..."
  downloadError="Archive downloaded improperly"
  curlIncorrect="No archive downloaded, check your curl version"
  unpacking="Unpacking new version..."
  unpackError="Archive unpacked improperly"
  archiveIncorrect="Archive downloaded improperly"
  cleaning="Cleaning existing folder"
  creating="Creating TranslationsUpdater folder"
  installing="Installing new version..."
  success="Success: Restart GUI manually to use new plugin version"
fi
echo "$installingPackages"

curl --help 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo
  echo "$curlError"
  exit 0
fi

echo "$inetCheck"
ping -c 1 github.com 1>/dev/null 2>&1
if [ $? -gt 0 ]; then
  echo "$githubError"
  exit 0
fi

echo "$download"
curl -kLs https://api.github.com/repos/j00zek/PolishTranslations/tarball/master -o /tmp/PolishTranslations.tar.gz
if [ $? -gt 0 ]; then
  echo "$downloadError"
  exit 0
fi

if [ ! -e /tmp/PolishTranslations.tar.gz ]; then
  echo "$curlIncorrect"
  exit 0
fi

echo "$unpacking"
#cd /tmp
tar -zxf /tmp/PolishTranslations.tar.gz -C /tmp
if [ $? -gt 0 ]; then
  echo "$unpackError"
  exit 0
fi

if [ ! -e /tmp/j00zek-PolishTranslations-* ]; then
  echo "$archiveIncorrect"
  exit 0
fi
rm -rf /tmp/PolishTranslations.tar.gz


if [ -e /usr/lib/enigma2/python/Plugins/Extensions/TranslationsUpdater ];then
 echo "$cleaning"
 rm -rf /usr/lib/enigma2/python/Plugins/Extensions/TranslationsUpdater/*
else
 echo "$creating"
 mkdir -p /usr/lib/enigma2/python/Plugins/Extensions/TranslationsUpdater/
fi

echo "$installing"
if [ -e /DuckboxDisk ]; then
  echo
  echo "github is always up-2-date, no sync required"
  exit 0
else
  cp -a /tmp/j00zek-PolishTranslations-*/TranslationsUpdater/* /usr/lib/enigma2/python/Plugins/Extensions/TranslationsUpdater/
  rm -rf /tmp/j00zek-PolishTranslations-* 2>/dev/null
  echo
  echo "$success"
fi

exit 0
