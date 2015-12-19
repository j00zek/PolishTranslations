# @j00zek 2015 dla Graterlia
#
#$2 = sciezka do aktualnej skorki

addon=$1
myPath=`dirname $0`
myConfig=`echo $addon|cut -d '.' -f1`
addonConfig=''
url="https://raw.githubusercontent.com/j00zek/PolishTranslations/master/$addon"

[ -e /tmp/$addon ] && rm -rf /tmp/$addon
[ -e /tmp/paths.conf ] && rm -rf /tmp/paths.conf
[ -e /tmp/.reboot ] && rm -rf /tmp/.reboot

echo "Pobieram plik konfiguracyjny..."
curl -kLs https://raw.githubusercontent.com/j00zek/PolishTranslations/master/paths.conf -o /tmp/paths.conf
if [ $? -gt 0 ]; then
  echo "Błąd pobierania pliku konfiguracyjnego, koniec :("
  exit 0
fi

if [ -f /tmp/paths.conf ];then
  addonConfig=`grep "$myConfig=" < /tmp/paths.conf| cut -d '=' -f2`
fi
if [ -z $addonConfig ];then
  echo "Brak konfiguracji dla $myConfig, wyszukiwanie po nazwie..."
  findPath=`echo $myPath|sed 's;^\(.*/Plugins\).*;\1;'`
  foundN=`find $findPath -name $myConfig||head -1`
  if [ -z $foundN ];then
    echo "Nie znaleziono konfiguracji dla $myConfig, koniec :("
    exit 0
  fi
fi

echo "Pobieram $addon..."
curl -kLs $url -o /tmp/$addon
if [ $? -gt 0 ]; then
  echo "Błąd pobierania pliku, koniec :("
  exit 0
fi

echo "Kompiluję $myConfig.mo..."
chmod 775 $myPath/msgfmt.py
$myPath/msgfmt.py /tmp/$addon
if [ $? -gt 0 ]; then
  echo "Błąd podczas kompilacji, koniec :("
  exit 0
fi
mv -f /tmp/$myConfig.mo $addonConfig
rm -rf /tmp/$addon
rm -rf /tmp/paths.conf
echo
echo "$addon zainstalowany poprawnie, zrestartuj teraz system."
touch /tmp/.rebootGUI
