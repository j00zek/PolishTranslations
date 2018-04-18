# @j00zek 2018
#
#$2 = sciezka do aktualnej skorki

addon=$1
myPath=`dirname $0`
myConfig=`echo $addon|cut -d '.' -f1`
addonConfig=$2
url="https://raw.githubusercontent.com/j00zek/PolishTranslations/master/$addon"

[ -e /tmp/$addon ] && rm -rf /tmp/$addon
[ -e /tmp/paths.conf ] && rm -rf /tmp/paths.conf
[ -e /tmp/.rebootGUI ] && rm -rf /tmp/.rebootGUI

if [ -z $addonConfig ]; then
  echo "Pobieram plik konfiguracyjny..."
  curl -kLs https://raw.githubusercontent.com/j00zek/PolishTranslations/master/paths.conf -o /tmp/paths.conf
  if [ $? -gt 0 ]; then
    echo "Błąd pobierania pliku konfiguracyjnego, koniec :("
    exit 0
  fi
  if [ ! -f /tmp/paths.conf ]; then
    echo "Błąd pobierania pliku konfiguracyjnego, koniec :("
    exit 0
  else
    addonConfig=`grep "^$myConfig=" < /tmp/paths.conf| cut -d '=' -f2|tr -d '\n'`
    echo "Konfiguracja dla $myConfig : $addonConfig"
  fi
fi

if [ -z $addonConfig ];then
  findPath=`echo $myPath|sed 's;^\(.*/Plugins\).*;\1;'`
  echo "Brak konfiguracji dla $myConfig, wyszukiwanie po nazwie..."
  #znajdujemy jakiekolwiek tłumaczenie i zamieniamy ścieżkę na pl
  addonConfig=`find $findPath -name $myConfig.mo|grep -m1 "/pl/"`
  [ -z $addonConfig ] && addonConfig=`find $findPath -name $myConfig.mo|grep -m1 "/en/"|sed 's;/en/;/pl/;'`
  [ -z $addonConfig ] && addonConfig=`find $findPath -name $myConfig.mo|grep -m1 "/de/"|sed 's;/de/;/pl/;'`
  [ -z $addonConfig ] && addonConfig=`find $findPath -name $myConfig.mo|grep -m1 "/ru/"|sed 's;/ru/;/pl/;'`
  #echo $addonConfig
  if [ -z $addonConfig ]; then
    echo "Wygląda na to, że $myConfig nie jest zainstalowany, koniec :("
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
echo `dirname $addonConfig`
mkdir -p `dirname $addonConfig`
sync
echo "mv -f /tmp/$myConfig.mo $addonConfig" >/tmp/aqq
mv -f "/tmp/$myConfig.mo" "$addonConfig"
touch $addonConfig.aqq
#cp -f "/tmp/$myConfig.mo" "$addonConfig"
rm -rf /tmp/$addon
rm -rf /tmp/paths.conf
echo
echo "$addon zainstalowany poprawnie, zrestartuj teraz system."
echo
#echo "LICENCJA: Wszystkie tłumaczenia są autorstwem kolegi Mariusz1970P. Możesz z nich korzystać jedynie za pośrednictwem wtyczki Aktualizator tłumaczeń."
#echo "Uszanuj jego pracę i poświęcony czas i nie wykorzystuj ich bezpośrednio w swoich wtyczkach, czy paczkach."
#echo
touch /tmp/.rebootGUI
