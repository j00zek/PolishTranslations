#!/bin/sh 
# @j00zek 2015-2018
#
#Plik do generowania menu
#musi znajdować się w katalogu menu i jest zawsze uruchamiany przy wyborzez ikonki
#jeśli chcemy, aby menu było statyczne, to na początku wpisujemy exit 0
#Jeśli menu ma byc dynamiczne to tutaj je sobie tworzymy przed każdym wejściem do niego
#
#struktura prosta jak budowa cepa,
#pierwsza linia zawiera nazwę menu
#MENU|<NAZWA Menu>
#
#kolejne linie zawierają poszczególne pozycje według schematu:
#ITEM|<Nazwa opcji>|Typ opcji [CONSOLE|MSG|RUN|SILENT|YESNO|APPLET]|<nazwa skryptu do uruchomienia>
#
#CONSOLE wyświetla okno konsoli i wszystko co się w nim dzieje
#MSG uruchamia w tle skrypt i wyświetla wiadomość zawierającą to co zwróci skrypt
#RUN uruchamia skrypt w tle i potwierdza jego wykonanie
#SILENT uruchamia skrypt w tle
#YESNO pyta sie czy uruchomic skrypt
#
###########################################################################################################
DEBUG=1

if [ -z $1 ];then
  myPath=`dirname $0`
else
  myPath=$1
fi

[ -e /tmp/PolishTranslations.menu ] && rm -f /tmp/PolishTranslations.menu

#ustawienia
[ -e /usr/local/e2/etc/enigma2/settings ] && settingsFile='/usr/local/e2/etc/enigma2/settings' || settingsFile='/etc/enigma2/settings'
UkryjNiezainstalowane=0
ByDate=1
KasujTMP=1
if [ -e $settingsFile ];then
	[ `grep -c 'config.plugins.TranslationsUpdater.SortowaniePoDacie=true' <$settingsFile` -gt 0 ] || ByDate=0
	[ `grep -c 'config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych=true' <$settingsFile` -gt 0 ] && UkryjNiezainstalowane=1
	[ `grep -c 'config.plugins.TranslationsUpdater.UsunPlikiTMP=false' <$settingsFile` -gt 0 ] && KasujTMP=0
fi

# start
[ $DEBUG -eq 1 ] && echo "----- START -----" > /tmp/PolishTranslations.log
[ $DEBUG -eq 1 ] && echo "Sorty by Date=$ByDate" >> /tmp/PolishTranslations.log
[ $DEBUG -eq 1 ] && echo "Ukrywanie niezainstalowanych=$UkryjNiezainstalowane" >> /tmp/PolishTranslations.log

#pobieranie i sortowanie listy z github
$myPath/pyCurl 'https://raw.githubusercontent.com/j00zek/PolishTranslations/master/Menu.conf' '/tmp/PolishTranslations.menu'
sync

if [ $ByDate -eq 1 ];then
  cat /tmp/PolishTranslations.menu|sed -e 's;^\(.*\)|\(.*\)|\(.*\)|\(.*\);\2 \1|\3|\4;'|sort -bfir|grep -v "^#" > /tmp/PolishTranslations.list
else
  cat /tmp/PolishTranslations.menu|sed -e 's;^\(.*\)|\(.*\)|\(.*\)|\(.*\);\1 \2|\3|\4;'|sort -bfi |grep -v "^#" > /tmp/PolishTranslations.list
fi
[ $DEBUG -eq 1 ] && cat /tmp/PolishTranslations.list >> /tmp/PolishTranslations.log

#Tworzenie Menu
echo "MENU|Aktualizuj tłumaczenia:">/tmp/_GetTranslations
if [ ! -s /tmp/PolishTranslations.list ];then
  echo "ITEM|Nie znaleziono tłumaczeń|DONOTHING|">>/tmp/_GetTranslations
  exit 0
fi

while read ArchiveName
do
  if `echo $ArchiveName|grep -q 'enigma2.po'`;then
    dodajDoListy=1
  elif [ $UkryjNiezainstalowane -ne 1 ];then
    dodajDoListy=1
  else
      addonNameToSearch=`echo $ArchiveName|cut -d$'|' -f2|sed 's/\.po/.mo/'`
    #echo $addonNameToSearch
    findPath=`echo $myPath|sed 's;^\(.*/Plugins\).*;\1;'`
    if `find $findPath -name $addonNameToSearch|grep -q -m1 "$addonNameToSearch"`;then
      dodajDoListy=1
    else
      dodajDoListy=0
    fi
  fi
  if [ $dodajDoListy -eq 1 ];then
	addonName=`echo "$ArchiveName"|cut -d$'|' -f1`
    addonFileName=`echo $ArchiveName|cut -d$'|' -f2`
    addonDestination=`echo $ArchiveName|cut -d$'|' -f3`
    [ $DEBUG -eq 1 ] && echo "addonName=$addonName, addonFileName=$addonFileName , addonDestination=$addonDestination" >> /tmp/PolishTranslations.log
    echo -e "ITEM|$addonName|CONSOLE|getPO.sh $addonFileName $addonDestination">>/tmp/_GetTranslations
  fi
done </tmp/PolishTranslations.list

opkg update 1 > /dev/null 2>&1
if [ `opkg list-installed 2>&1|grep -c 'enigma2-locale-pl'` -eq 1 ];then
  echo -e "ITEM|> Odinstaluj standardowe tłumaczenie enigmy <|CONSOLE|opkg remove enigma2-locale-pl">>/tmp/_GetTranslations
fi

#aktualizacja wtyczki, jesli potrzebna
if [ -e $myPath/../__init__.py ];then
	$myPath/pyCurl 'https://raw.githubusercontent.com/j00zek/PolishTranslations/master/TranslationsUpdater/__init__.py' '/tmp/init.tmp'
	wersjaCurrent=`grep "^wersja" < $myPath/../__init__.py|cut -d '=' -f2`
	wersjaOnline=`cat /tmp/init.tmp|grep "^wersja"|cut -d '=' -f2`
	if [ $wersjaOnline -gt $wersjaCurrent ];then
		echo -e "ITEM|>>> Aktualizuj wtyczkę <<<|CONSOLE|pluginUpdate.sh">>/tmp/_GetTranslations
	fi
fi

#czyszczenie po sobie
if [ $KasujTMP -eq 1 ];then
  for plik in /tmp/PolishTranslations.menu /tmp/PolishTranslations.web /tmp/PolishTranslations.table /tmp/init.tmp
  do
	[ -e $plik ] && rm -f $plik
  done
fi
