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

#curl -s --ftp-pasv $addons 1>/dev/null 2>&1
#[ $? -gt 0 ] && addons="$addons/"
if [ -z $1 ];then
  myPath=`dirname $0`
else
  myPath=$1
fi

[ -e /tmp/paths.conf ] && rm -rf /tmp/paths.conf
#[ -e /tmp/.rebootGUI ] && rm -rf /tmp/.rebootGUI
[ -e /usr/local/e2/etc/enigma2/settings ] && settingsFile='/usr/local/e2/etc/enigma2/settings' || settingsFile='/etc/enigma2/settings'

[ $DEBUG -eq 1 ] && echo "----- START -----" > /tmp/PolishTranslations.log
if [ ! -f /tmp/PolishTranslations.list ];then
  [ $DEBUG -eq 1 ] && echo "Brak /tmp/PolishTranslations.list, pobieram" >> /tmp/PolishTranslations.log
  $myPath/getList.sh
else
  [ $DEBUG -eq 1 ] && echo "/tmp/PolishTranslations.list juz pobrana" >> /tmp/PolishTranslations.log
fi
if [ -e $settingsFile ];then
  if `grep -q 'config.plugins.TranslationsUpdater.SortowaniePoDacie=true' <$settingsFile`;then
    ByDate=1
  else
    ByDate=0
  fi
else
    ByDate=1
fi

[ $DEBUG -eq 1 ] && echo "ByDate=$ByDate" >> /tmp/PolishTranslations.log

if [ $ByDate -eq 1 ];then
  DownloadableArchives=`cat /tmp/PolishTranslations.list|sed -e 's;^\(.*\)|\(.*\)$;\2|\1;'|sort -bfir`
else
  DownloadableArchives=`cat /tmp/PolishTranslations.list|sed -e 's;^\(.*\)|\(.*\)$;\1|\2;'|sort -bfi`
fi
[ $DEBUG -eq 1 ] && echo "$DownloadableArchives" >> /tmp/PolishTranslations.log

if [ -e $settingsFile ] && [ `grep -c 'config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych=true' <$settingsFile` -gt 0 ];then
  UkryjNiezainstalowane=1
else
  UkryjNiezainstalowane=0
fi

if [ $? -gt 0 ]; then
  echo "ITEM|Błąd pobierania tłumaczeń|DONOTHING|">>/tmp/_GetTranslations
  exit 0
fi

echo "MENU|Aktualizuj tłumaczenia:">/tmp/_GetTranslations
if [ -z "$DownloadableArchives" ];then
  echo "ITEM|Nie znaleziono tłumaczeń|DONOTHING|">>/tmp/_GetTranslations
  exit 0
fi

#coby ładnie się kolumienki zgadzały ;)
maxLenght=0
IFS=$'\n'
[ -e /tmp/getTranslations.log ] && rm -f /tmp/getTranslations.log
for item in $DownloadableArchives
do
  #echo "'$item'">>/tmp/getTranslations.log
  addonName=`echo $item|cut -d$'|' -f1|cut -d$'.' -f1`
  NameLen=${#addonName}
  #echo $addonName $NameLen
  [ $NameLen -gt $maxLenght ] && maxLenght=$NameLen
done
echo "MAXLENGHT = $maxLenght" >>/tmp/

for ArchiveName in $DownloadableArchives
do
  if `echo $ArchiveName|grep -q 'enigma2.po'`;then
    dodajDoListy=1
  elif [ $UkryjNiezainstalowane -ne 1 ];then
    dodajDoListy=1
  else
    if [ $ByDate -eq 1 ];then #data na początku
      addonLink=`echo $ArchiveName|cut -d$'|' -f2|sed 's/\.po//'`
    else
      addonLink=`echo $ArchiveName|cut -d$'|' -f1|sed 's/\.po//'`
    fi
    echo $addonLink
    findPath=`echo $myPath|sed 's;^\(.*/Plugins\).*;\1;'`
    if `find $findPath -name $addonLink.mo|grep -q -m1 "$addonLink.mo"`;then
      dodajDoListy=1
    else
      dodajDoListy=0
    fi
  fi
  if [ $dodajDoListy -eq 1 ];then
    if [ $ByDate -eq 1 ];then #data na początku
      addonLink=`echo $ArchiveName|cut -d$'|' -f2`
      addonName=`echo $ArchiveName|cut -d$'|' -f1`
      addonDate=`echo $ArchiveName|cut -d$'|' -f2|cut -d$'.' -f1`
    
      DateABBR=`echo $addonName|cut -d$'\t' -f2|sed 's/^...\(.\).*/\1/'`
      if [ $DateABBR == ' 1' ];then
        #echo "Month abbreviation found probably, let's try translate it"
        addonName=`echo $addonName|sed 's/^\(...\)/_(\1)/'`
      fi
    else
      addonLink=`echo $ArchiveName|cut -d$'|' -f1`
      addonName=`echo $ArchiveName|cut -d$'|' -f1|cut -d$'.' -f1`
      addonDate=`echo $ArchiveName|cut -d$'|' -f2`
    
      DateABBR=`echo $addonDate|cut -d$'\t' -f2|sed 's/^...\(.\).*/\1/'`
      if [ $DateABBR == ' ' ];then
        #echo "Month abbreviation found probably, let's try translate it"
        addonDate=`echo $addonDate|sed 's/^\(...\)/_(\1)/'`
      fi
    fi
    NameLen=${#addonName}
    LenDiff=$(( maxLenght - NameLen ))
    [ $LenDiff -gt 4 ] && extraTAB='\t' || extraTAB=''
    #echo "$ArchiveName > $addonLink"
    [ $DEBUG -eq 1 ] && echo "addonLink=$addonLink" >> /tmp/PolishTranslations.log
    [ $DEBUG -eq 1 ] && echo "addonName=$addonName" >> /tmp/PolishTranslations.log
    [ $DEBUG -eq 1 ] && echo "addonDate=$addonDate" >> /tmp/PolishTranslations.log
    echo -e "ITEM|$addonName\t$extraTAB $addonDate|CONSOLE|getPO.sh $addonLink">>/tmp/_GetTranslations
  fi
done

opkg update 1 > /dev/null 2>&1
if [ `opkg list-installed 2>&1|grep -c 'enigma2-locale-pl'` -eq 1 ];then
  echo -e "ITEM|> Odinstaluj standardowe tłumaczenie enigmy <|CONSOLE|opkg remove enigma2-locale-pl">>/tmp/_GetTranslations
fi

if `grep -q 'config.plugins.TranslationsUpdater.UsunPlikiTMP=true' <$settingsFile`;then
  rm -f /tmp/PolishTranslations.web
  rm -f /tmp/PolishTranslations.table
  #rm -f /tmp/PolishTranslations.list
fi

#aktualizacja wtyczki, jesli potrzebna
wersjaCurrent=`grep "^wersja" < $myPath/../__init__.py|cut -d '=' -f2`
wersjaOnline=`curl -kLs https://raw.githubusercontent.com/j00zek/PolishTranslations/master/TranslationsUpdater/__init__.py|grep "^wersja"|cut -d '=' -f2`
[ $? -gt 0 ] && exit 0
if [ $wersjaOnline -gt $wersjaCurrent ];then
  echo -e "ITEM|>>> Aktualizuj wtyczkę <<<|CONSOLE|pluginUpdate.sh">>/tmp/_GetTranslations
fi
