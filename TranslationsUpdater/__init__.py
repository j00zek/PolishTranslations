#!/bin/sh
#@j00zek 08-09-2017
wersja=14

PluginName = 'TranslationsUpdater'
PluginGroup = 'Extensions'

#Plugin Paths
from Tools.Directories import resolveFilename, SCOPE_PLUGINS
PluginFolder = PluginName
PluginPath = resolveFilename(SCOPE_PLUGINS, '%s/%s/' %(PluginGroup,PluginFolder))
