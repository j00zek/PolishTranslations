#!/bin/sh 
# @j00zek 2018
#
#Plik do pobierania listy elementów z github
###########################################################################################################

curl -kLs https://github.com/j00zek/PolishTranslations -o /tmp/PolishTranslations.web
sed '/<table class=".*js-navigation-container.*"/,$!d' < /tmp/PolishTranslations.web > /tmp/PolishTranslations.table
sed -i '/<div id="readme" class=".*">/,$d' /tmp/PolishTranslations.table
cat /tmp/PolishTranslations.table|tr -d '\n'|sed 's/<tr class=/\nTRclass/g'|grep 'TRclass'|grep '\.po"' > /tmp/PolishTranslations.listtmp
cat /tmp/PolishTranslations.listtmp| \
sed -e 's;^.*\/blob\/master\/;;'| \
sed -e 's;">.*<td class="age">;|datetime=Brak InfoT0";'| \
sed -e 's;datetime=.*datetime=";datetime=;'| \
sed -e 's;T[0-9].*$;;'|sed -e 's;datetime=;;' > /tmp/PolishTranslations.list
exit 0