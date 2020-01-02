# @j00zek 2018
#
#$2 = sciezka do aktualnej skorki

addon=$1
myPath=`dirname $0`
myConfig=`echo $addon|cut -d '.' -f1`
addonConfig=$2
url="https://raw.githubusercontent.com/j00zek/PolishTranslations/master/translations/$addon"

[ -e /tmp/$addon ] && rm -rf /tmp/$addon
[ -e /tmp/paths.conf ] && rm -rf /tmp/paths.conf
[ -e /tmp/.rebootGUI ] && rm -rf /tmp/.rebootGUI

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
$myPath/pyCurl $url /tmp/$addon
if [ $? -gt 0 ] || [ ! -s /tmp/$addon ]; then
  echo "Błąd pobierania pliku, koniec :("
  exit 0
fi

echo "Kompiluję $myConfig.mo..."
chmod 775 $myPath/msgfmt.py
$myPath/msgfmt.py /tmp/$addon
if [ $? -gt 0 ]; then
  echo "Błąd podczas kompilacji tłumaczenia, koniec :("
  exit 0
fi
echo "Ścieżka instalacji $myConfig.mo = $addonConfig"

mkdir -p `dirname $addonConfig`
sync
#echo "mv -f /tmp/$myConfig.mo $addonConfig"
mv -f "/tmp/$myConfig.mo" "$addonConfig"
touch $addonConfig.aqq
#cp -f "/tmp/$myConfig.mo" "$addonConfig"
rm -rf /tmp/$addon
rm -rf /tmp/paths.conf
if [ `echo $addon|grep -c 'enigma2'` -eq 1 ];then
  opkg update 1 > /dev/null 2>&1
  if [ `opkg list-installed 2>&1|grep -c 'enigma2-locale-pl'` -eq 1 ];then
    echo
    echo "WYKRYTO zainstalowane standardowe tłumaczenie enigmy. Zaleca się jego odinstalowanie, aby system nie nadpisywał go przy aktualizacji!!!."
    echo
    echo "Tłumaczenie dla enigma2 zainstalowane. zrestartuj teraz system."
  else
    echo
    echo "Tłumaczenie dla enigma2 zainstalowane. zrestartuj teraz system."
  fi
  echo
else
  echo
  echo "$addon zainstalowany poprawnie, zrestartuj teraz system."
  echo
fi
#echo "LICENCJA: Wszystkie tłumaczenia są autorstwem kolegi Mariusz1970P. Możesz z nich korzystać jedynie za pośrednictwem wtyczki Aktualizator tłumaczeń."
#echo "Uszanuj jego pracę i poświęcony czas i nie wykorzystuj ich bezpośrednio w swoich wtyczkach, czy paczkach."
#echo
touch /tmp/.rebootGUI
