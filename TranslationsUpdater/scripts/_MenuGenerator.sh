#!/bin/sh 
# @j00zek 2015 dla Graterlia
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
#curl -s --ftp-pasv $addons 1>/dev/null 2>%1
#[ $? -gt 0 ] && addons="$addons/"
DownloadableArchives=`curl -kLs https://github.com/j00zek/PolishTranslations| egrep -o '\/blob\/master\/[^ ]*\.po|is="time-ago">.*<\/time>'|tr -d '\n'| sed 's;/blob/master/;\n;g'|grep '.po'|sed 's;^\(.*\.po\)is=.*">\(.*\)</.*;\1\t\2;'|sort`

echo "MENU|Aktualizuj tłumaczenia:">/tmp/_GetTranslations
if [ -z "$DownloadableArchives" ];then
  echo "ITEM|Nie znaleziono tłumaczeń|DONOTHING|">>/tmp/_GetTranslations
  exit 0
fi

#coby ładnie się kolumienki zgadzały ;)
maxLenght=0
for ArchiveName in $DownloadableArchives
do
  addonName=`echo $ArchiveName|cut -d$'\t' -f1|cut -d$'.' -f1`
  NameLen=${#addonName}
  [ $NameLen -gt $maxLenght ] && maxLenght=$NameLen
done
echo "MAXLENGHT = $maxLenght"

IFS=$'\n'
for ArchiveName in $DownloadableArchives
do
  addonLink=`echo $ArchiveName|cut -d$'\t' -f1`
  addonName=`echo $ArchiveName|cut -d$'\t' -f1|cut -d$'.' -f1`
  addonDate=`echo $ArchiveName|cut -d$'\t' -f2`
  DateABBR=`echo $addonDate|cut -d$'\t' -f2|sed 's/^...\(.\).*/\1/'`
  if [ $DateABBR == ' ' ];then
    echo "Month abbreviation found probably, let's try translate it"
    addonDate=`echo $addonDate|sed 's/^\(...\)/_(\1)/'`
  fi
  NameLen=${#addonName}
  LenDiff=$(( maxLenght - NameLen ))
  [ $LenDiff -gt 3 ] && extraTAB='\t' || extraTAB=''
  #echo "$ArchiveName > $addonLink"
  echo -e "ITEM|$addonName\t$extraTAB $addonDate|CONSOLE|getPO.sh $addonLink">>/tmp/_GetTranslations
done
