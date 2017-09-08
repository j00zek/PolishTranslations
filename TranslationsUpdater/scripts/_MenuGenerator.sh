#!/bin/sh 
# @j00zek 2015/2016 dla Graterlia
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

#DownloadableArchives=`curl -kLs https://github.com/j00zek/PolishTranslations|sed '/<div class="file-wrap">/,$!d'|tr -d '\n'`
DownloadableArchives=`curl -kLs https://github.com/j00zek/PolishTranslations|tr -d '\n'|sed 's/<tr class="js-navigation-item">/\nNEWjITEM/g'|grep 'NEWjITEM'|grep 'blob/master'|grep '\.po"'`
echo "$DownloadableArchives" > /tmp/DownloadableArchives.log
#sed 's|NEWjITEM.*blob/master||g'`
if [ -e $settingsFile ];then
  if `grep -q 'config.plugins.TranslationsUpdater.SortowaniePoDacie=true' <$settingsFile`;then
    ByDate=1
  else
    ByDate=0
  fi
else
    ByDate=1
fi

if [ $ByDate -eq 1 ];then
  DownloadableArchives=`echo "$DownloadableArchives"|sed -e 's;^.*\/blob\/master\/\(.*\.po\)" class.*datetime="\(.*\)T.*$;\2\t\1;'|sort -bfir`
else
  DownloadableArchives=`echo "$DownloadableArchives"|sed -e 's;^.*\/blob\/master\/\(.*\.po\)" class.*datetime="\(.*\)T.*$;\1\t\2;'|sort -bfi`
fi

if [ -e $settingsFile ] && [ `grep -c 'config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych=true' <$settingsFile` -gt 0 ];then
  UkryjNiezainstalowane=1
else
  UkryjNiezainstalowane=0
fi

if [ $? -gt 0 ]; then
  echo "ITEM|Błąd pobierania tłumaczeń|DONOTHING|">>/tmp/_GetTranslations
  exit 0
fi
##echo $DownloadableArchives>/tmp/getTranslations.log

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
  echo "'$item'">>/tmp/getTranslations.log
  addonName=`echo $item|cut -d$'\t' -f1|cut -d$'.' -f1`
  NameLen=${#addonName}
  #echo $addonName $NameLen
  [ $NameLen -gt $maxLenght ] && maxLenght=$NameLen
done
echo "MAXLENGHT = $maxLenght"

for ArchiveName in $DownloadableArchives
do
  if `echo $ArchiveName|grep -q 'enigma2.po'`;then
    dodajDoListy=1
  elif [ $UkryjNiezainstalowane -ne 1 ];then
    dodajDoListy=1
  else
    if [ $ByDate -eq 1 ];then #data na początku
      addonLink=`echo $ArchiveName|cut -d$'\t' -f2|sed 's/\.po//'`
    else
      addonLink=`echo $ArchiveName|cut -d$'\t' -f1|sed 's/\.po//'`
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
      addonLink=`echo $ArchiveName|cut -d$'\t' -f2`
      addonName=`echo $ArchiveName|cut -d$'\t' -f1`
      addonDate=`echo $ArchiveName|cut -d$'\t' -f2|cut -d$'.' -f1`
    
      DateABBR=`echo $addonName|cut -d$'\t' -f2|sed 's/^...\(.\).*/\1/'`
      if [ $DateABBR == ' 1' ];then
        #echo "Month abbreviation found probably, let's try translate it"
        addonName=`echo $addonName|sed 's/^\(...\)/_(\1)/'`
      fi
    else
      addonLink=`echo $ArchiveName|cut -d$'\t' -f1`
      addonName=`echo $ArchiveName|cut -d$'\t' -f1|cut -d$'.' -f1`
      addonDate=`echo $ArchiveName|cut -d$'\t' -f2`
    
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
    echo -e "ITEM|$addonName\t$extraTAB $addonDate|CONSOLE|getPO.sh $addonLink">>/tmp/_GetTranslations
  fi
done

#aktualizacja wtyczki, jesli potrzebna
wersjaCurrent=`grep "^wersja" < $myPath/../__init__.py|cut -d '=' -f2`
wersjaOnline=`curl -kLs https://raw.githubusercontent.com/j00zek/PolishTranslations/master/TranslationsUpdater/__init__.py|grep "^wersja"|cut -d '=' -f2`
[ $? -gt 0 ] && exit 0
if [ $wersjaOnline -gt $wersjaCurrent ];then
  echo -e "ITEM|>>> Aktualizuj wtyczkę <<<|CONSOLE|pluginUpdate.sh">>/tmp/_GetTranslations
fi