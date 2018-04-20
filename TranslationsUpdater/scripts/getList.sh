#!/bin/sh 
# @j00zek 2018
#
#Plik do pobierania listy elementów z github
###########################################################################################################

curl -kLs https://github.com/j00zek/PolishTranslations -o /tmp/PolishTranslations.web
sed '/<table class=".*js-navigation-container.*"/,$!d' < /tmp/PolishTranslations.web > /tmp/PolishTranslations.table
sed -i '/<div id="readme" class=".*">/,$d' /tmp/PolishTranslations.table
cat /tmp/PolishTranslations.table|tr -d '\n'|sed 's/<tr class=/\nTRclass/g'|grep 'TRclass'|grep '\.po"' > /tmp/PolishTranslations.list
exit 0