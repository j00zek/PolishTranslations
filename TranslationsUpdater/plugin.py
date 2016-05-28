# -*- coding: utf-8 -*-
#
# maintainer: j00zek 2016
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
from enigma import eTimer
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
        
def Plugins(**kwargs):
    return [PluginDescriptor(name="Aktualizator tłumaczeń", description="Bo Polacy nie gęsi i swój język mają ;)", where = PluginDescriptor.WHERE_PLUGINMENU, fnc=main,icon="logo.png"),
            PluginDescriptor(where = PluginDescriptor.WHERE_SESSIONSTART, fnc = sessionstart)]

def main(session, **kwargs):
    from myComponents import j00zekTUMenu
    session.open(j00zekTUMenu, MenuFolder = '%sscripts' % PluginPath, MenuFile = '_GetTranslations', MenuTitle = "Aktualizacja tłumaczeń")

def sessionstart(reason, **kwargs):
        session = kwargs["session"]
        AutoUpdate(session)

class AutoUpdate(Screen):
    def __init__(self, session):
        self.session = session
        Screen.__init__(self, session)
        AutoUpdate.AutoUpdateTimer = eTimer()
        AutoUpdate.AutoUpdateTimer.callback.append(self.checkANDrefresh)
        AutoUpdate.AutoUpdateTimer.start(1000*60*60*24)
        #AutoUpdate.AutoUpdateTimer.start(1000*15) #tylko dla testow dev.

    def checkANDrefresh(self):
        from Tools.Directories import SCOPE_PLUGINS, resolveFilename
        from os import path as os_path
        from Components.Console import Console
        AutoUpdateScript = resolveFilename(SCOPE_PLUGINS, 'Extensions/TranslationsUpdater/scripts/AutoUpdate.sh')
        if os_path.exists(AutoUpdateScript):
          with open("/proc/sys/vm/drop_caches", "w") as f: f.write("1\n")
          Console().ePopen(AutoUpdateScript,self.checkANDrefreshCB)
        return

    def checkANDrefreshCB(self, ConsoleOutput=None, ExitCode=None, retUnknown=None):
        if ExitCode is not None and ExitCode == 99 and ConsoleOutput is not None:
            #print "Files updated, reboot needed"
            from Screens.Standby import inStandby
            if inStandby is None:
                def ExitRet(ret):
                    if ret:
                        from enigma import quitMainloop
                        quitMainloop(3)
                    return
                
                from Screens.MessageBox import MessageBox
                self.session.openWithCallback(ExitRet, MessageBox, "Zaktualizowano tłumaczenia\nZrestartować system?", timeout=10, default=False)
