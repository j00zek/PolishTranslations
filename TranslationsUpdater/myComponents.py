# -*- coding: utf-8 -*-
# @j00zek 2014/2015 dla Graterlia

from enigma import eConsoleAppContainer, eTimer
from Screens.Screen import Screen
from Components.ActionMap import ActionMap
from Components.MenuList import MenuList
from Components.ScrollLabel import ScrollLabel
from __init__ import *
#
from Components.Pixmap import Pixmap
from enigma import ePicLoad, ePoint, getDesktop, eTimer, ePixmap
from os import system as os_system, popen as os_popen, path
#from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
from Screens.MessageBox import MessageBox
from Screens.ChoiceBox import ChoiceBox

def substring_2_translate(text):
    to_translate = text.split('_(', 2)
    text = to_translate[1]
    to_translate = text.split(')', 2)
    text = to_translate[0]
    return text

def lastChance(text):
    NonStandardTranslations=[(('Dec','Grud'))]
    for tr in NonStandardTranslations:
        text=text.replace(tr[0],tr[1])
    return text

def __(txt):
    if txt.find('_(') == -1:
        txt = _(txt)
    else:
        index = 0
        while txt.find('_(') != -1:
            tmptxt = substring_2_translate(txt)
            translated_tmptxt = _(tmptxt)
            if translated_tmptxt == tmptxt:
                translated_tmptxt = lastChance(tmptxt)
            txt = txt.replace('_(' + tmptxt + ')', translated_tmptxt)
            index += 1
            if index == 10:
                break

    return txt

class j00zekTUConsole(Screen):
    #TODO move this to skin.xml
    skin = """
        <screen position="center,center" size="550,450" title="Command execution..." >
            <widget name="text" position="0,0" size="550,450" font="Console;14" />
        </screen>"""
        
    def __init__(self, session, title = "j00zekTUConsole", cmdlist = None, finishedCallback = None, closeOnSuccess = False):
        Screen.__init__(self, session)

        self.finishedCallback = finishedCallback
        self.closeOnSuccess = closeOnSuccess
        self.errorOcurred = False

        self["text"] = ScrollLabel("")
        self["actions"] = ActionMap(["WizardActions", "DirectionActions"], 
        {
            "ok": self.cancel,
            "back": self.cancel,
            "up": self["text"].pageUp,
            "down": self["text"].pageDown
        }, -1)
        
        self.cmdlist = cmdlist
        self.newtitle = title
        
        self.onShown.append(self.updateTitle)
        
        self.container = eConsoleAppContainer()
        self.run = 0
        self.container.appClosed.append(self.runFinished)
        self.container.dataAvail.append(self.dataAvail)
        self.onLayoutFinish.append(self.startRun) # dont start before gui is finished

    def updateTitle(self):
        self.setTitle(self.newtitle)

    def startRun(self):
        self["text"].setText("" + "\n\n")
        print "TranslatedConsole: executing in run", self.run, " the command:", self.cmdlist[self.run]
        if self.container.execute(self.cmdlist[self.run]): #start of container application failed...
            self.runFinished(-1) # so we must call runFinished manual

    def runFinished(self, retval):
        if retval:
            self.errorOcurred = True
        self.run += 1
        if self.run != len(self.cmdlist):
            if self.container.execute(self.cmdlist[self.run]): #start of container application failed...
                self.runFinished(-1) # so we must call runFinished manual
        else:
            #lastpage = self["text"].isAtLastPage()
            #str = self["text"].getText()
            #str += _("\nUse up/down arrows to scroll text. OK closes window");
            #self["text"].setText(str)
            #if lastpage:
            self["text"].lastPage()
            if self.finishedCallback is not None:
                self.finishedCallback()
            if not self.errorOcurred and self.closeOnSuccess:
                self.cancel()

    def cancel(self):
        if self.run == len(self.cmdlist):
            self.close()
            self.container.appClosed.remove(self.runFinished)
            self.container.dataAvail.remove(self.dataAvail)

    def dataAvail(self, str):
        #lastpage = self["text"].isAtLastPage()
        self["text"].setText(self["text"].getText() + __(str))
        #if lastpage:
        self["text"].lastPage()

############################################

class j00zekTUMenu(Screen,):
    def __init__(self, session, MenuFolder = "" , MenuFile = '_MenuItems', MenuTitle = 'j00zekTUMenu'):
        
        self.myList = []
        self.list = []
        self.myPath = MenuFolder
        self.MenuFile = "/tmp/%s" % (MenuFile)
        self.SkryptOpcji = ""
        self.PIC = ""
        picHeight = 0
        self.MenuTitle = MenuTitle

        skin  = """<screen name="j00zekTUMenu" position="center,center" size="470,410" title="j00zekTUMenu" >\n"""
        skin += """<eLabel text="Plik" position="10,0" size="150,30" font="Regular;18" foregroundColor="#6DABBF" valign="center" halign="center" />"""
        skin += """<eLabel text="z dnia" position="145,0" size="460,30" font="Regular;18" foregroundColor="#6DABBF" valign="center" halign="center" />"""
        skin += """<widget name="list" position="5,30" font="Regular;20" size="460,340" scrollbarMode="showOnDemand" />\n"""
        skin += """<eLabel text="Tłumaczenia: Mariusz1970" position="0,350" size="460,30" font="Regular;24" foregroundColor="yellow" valign="center" halign="center" />"""
        skin += """<eLabel text="Wtyczka: (c)2015 j00zek" position="0,380" size="460,30" font="Regular;24" foregroundColor="yellow" valign="center" halign="center" />"""
        skin += """</screen>"""

        self.skin = skin
        self.session = session
        Screen.__init__(self, session)

        self["list"] = MenuList(self.list)
        
        self["actions"] = ActionMap(["OkCancelActions"], {"ok": self.run, "cancel": self.close}, -1)

        self.onLayoutFinish.append(self.onStart)
        self.visible = True
        self.setTitle("Pobieranie danych...")

    def onStart(self):
        self.hideOSDTimer = eTimer()
        self.hideOSDTimer.callback.append(self.delayedStart)
        self.hideOSDTimer.start(500, True) # singleshot
        
    def delayedStart(self):
        self.system( "%s/_MenuGenerator.sh %s" % (self.myPath, self.myPath) )
        self.setTitle(self.MenuTitle)
        self.reloadLIST()
    
    def YESNO(self, decyzja):
        if decyzja is False:
            return
        self.system("%s"  %  self.SkryptOpcji)

    def system(self,komenda):
        with open("/proc/sys/vm/drop_caches", "w") as f: f.write("1\n")
        os_system(komenda)
      
    def run(self):
        selecteditem = self["list"].getCurrent()
        if selecteditem is not None:
            for opcja in self.myList:
                if opcja[0] == selecteditem:
                    self.SkryptOpcji = opcja[2]
                    if opcja[1] == "CONSOLE":
                        self.session.openWithCallback(self.endrun ,j00zekTUConsole, title = "%s" % selecteditem, cmdlist = [ ('%s' %  self.SkryptOpcji) ])
                    if opcja[1] == "YESNO":
                        self.session.openWithCallback(self.YESNO ,MessageBox,_("Execute %s?") % selecteditem, MessageBox.TYPE_YESNO)
                    if opcja[1] == "SILENT":
                        self.system("%s"  %  self.SkryptOpcji)
                        self.endrun()
                    elif opcja[1] == "RUN":
                        self.system("%s"  %  self.SkryptOpcji)
                        self.session.openWithCallback(self.endrun,MessageBox,_("%s executed!") %( selecteditem ), MessageBox.TYPE_INFO, timeout=5)
                    elif opcja[1] == "MSG":
                        msgline = ""
                        popenret = os_popen( self.SkryptOpcji)
                        for readline in popenret.readlines():
                            msgline += readline
                        self.session.openWithCallback(self.endrun,MessageBox, "%s" %( msgline ), MessageBox.TYPE_INFO, timeout=15)
                            

    def endrun(self, ret =0):
        #odświerzamy menu
        with open("/proc/sys/vm/drop_caches", "w") as f: f.write("1\n")
        self.system( "%s/_MenuGenerator.sh %s %s" % (self.myPath, self.myPath, SkinPath) )
        self.reloadLIST()
        #self.onStart()
        return
    
    def SkryptOpcjiWithFullPAth(self, txt):
        if not txt.startswith('/'):
            return ('%s/%s') %(self.myPath,txt)
        else:
            return txt
            
    def reloadLIST(self):
        #czyścimy listę w ten dziwny sposób, aby GUI działało, bo nie zmienimy obiektów ;)
        while len(self.list) > 0:
            del self.myList[-1]
            del self.list[-1]
        if path.exists(self.MenuFile) is True:
            self["list"].hide()
            with open (self.MenuFile, "r") as myMenufile:
                for MenuItem in myMenufile:
                    MenuItem = MenuItem.rstrip('\n') 
                    if not MenuItem or MenuItem[0] == '#': #omijamy komentarze
                        continue
                    #interesują nas tylko pozycje menu
                    if MenuItem[0:5] == "ITEM|":
                        #teraz bierzemy pod uwage tylko te linie co mają odpowiednią ilość |
                        #print MenuItem
                        skladniki = MenuItem.replace("ITEM|","").split('|')
                        if len(skladniki) == 3:
                            (NazwaOpcji, TypOpcji, SkryptOpcji) = skladniki
                            if NazwaOpcji != "":
                                NazwaOpcji = __(NazwaOpcji)
                                #NazwaOpcji = NazwaOpcji.replace(NazwaOpcji[:3],_(NazwaOpcji[:3]))
                                
                            self.myList.append( (NazwaOpcji, TypOpcji, self.SkryptOpcjiWithFullPAth(SkryptOpcji)) )
                            self.list.append( NazwaOpcji )
                myMenufile.close()
            myIdx = self["list"].getSelectionIndex()
            if myIdx > len(self.list) -1:
                self["list"].moveToIndex(len(self.list) -1)
            self["list"].show()
