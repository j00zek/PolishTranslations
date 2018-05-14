#!/bin/sh
#@j00zek 14-05-2018
wersja=19

PluginName = 'TranslationsUpdater'
PluginGroup = 'Extensions'

#Plugin Paths
from Tools.Directories import resolveFilename, SCOPE_PLUGINS
PluginFolder = PluginName
PluginPath = resolveFilename(SCOPE_PLUGINS, '%s/%s/' %(PluginGroup,PluginFolder))
