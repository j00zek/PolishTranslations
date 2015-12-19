# -*- coding: utf-8 -*-

# UserSkin, based on AtileHD concept by schomi & plnick
#
# maintainer: j00zek
#

#This plugin is free software, you are allowed to
#modify it (if you keep the license),
#but you are not allowed to distribute/publish
#it without source code (this version and your modifications).
#This means you also have to distribute
#source code of your modifications.

from __init__ import *

from Components.ActionMap import ActionMap

from Components.config import *
from Components.Label import Label
from Components.Pixmap import Pixmap
from Components.Sources.List import List
from Plugins.Plugin import PluginDescriptor
from Screens.MessageBox import MessageBox
from Screens.Screen import Screen
from Tools.Directories import resolveFilename, pathExists
from Tools.LoadPixmap import LoadPixmap
#from Tools import Notifications
#import shutil
#import re
        
def Plugins(**kwargs):
    return [PluginDescriptor(name="Aktualizator tłumaczeń", description="Bo Polacy nie gęsi i swój język mają ;)", where = PluginDescriptor.WHERE_PLUGINMENU, fnc=main,icon="logo.png")]

def main(session, **kwargs):
    from myComponents import j00zekTUMenu
    session.open(j00zekTUMenu, MenuFolder = '%sscripts' % PluginPath, MenuFile = '_GetTranslations', MenuTitle = "Aktualizacja tłumaczeń")
