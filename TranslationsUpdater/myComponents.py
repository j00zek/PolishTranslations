# -*- coding: utf-8 -*-
# @j00zek 2015

from __init__ import *

from Components.ActionMap import ActionMap
from Components.config import *
from Components.MenuList import MenuList
from Components.ScrollLabel import ScrollLabel
from Components.Sources.StaticText import StaticText

from enigma import eConsoleAppContainer, eTimer

from Screens.ChoiceBox import ChoiceBox
from Screens.MessageBox import MessageBox
from Screens.Screen import Screen
#
from os import system as os_system, popen as os_popen, path as os_path

config.plugins.TranslationsUpdater = ConfigSubsection()
config.plugins.TranslationsUpdater.SortowaniePoDacie = ConfigYesNo(default = False)
config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych = ConfigYesNo(default = False)
config.plugins.TranslationsUpdater.AutoUpdate = ConfigYesNo(default = False)
config.plugins.TranslationsUpdater.UsunPlikiTMP = ConfigYesNo(default = True)


def substring_2_translate(text):
    to_translate = text.split('_(', 2)
    text = to_translate[1]
    to_translate = text.split(')', 2)
    text = to_translate[0]
    return text

def lastChance(text):
    NonStandardTranslations=[('Jan','Styczeń '),('Feb','Luty'),('Mar','Marzec'),('Apr','Kwiecień'),('May','Maj'), \
      ('Jun','Czerwiec'),('Jul','Lipiec'),('Aug','Sierpień'),('Sep','Wrzesień'),('Oct','Październik'),('Nov','Listopad'),('Dec','Grudzień')]
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

class translatedConsole(Screen):
    #TODO move this to skin.xml
    skin = """
        <screen position="center,center" size="550,450" title="Instalacja..." >
            <widget name="text" position="0,0" size="550,450" font="Console;14" />
        </screen>"""
        
    def __init__(self, session, title = "translatedConsole", cmdlist = None, finishedCallback = None, closeOnSuccess = False):
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
        self.newtitle = title.replace('\t',' ').replace('  ',' ').strip()
        
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
        from Screens.MessageBox import MessageBox
          
        def rebootQuestionAnswered(ret):
            if ret:
                from enigma import quitMainloop
                quitMainloop(3)
            try: self.close()
            except: pass
            return
        def doReboot(ret):
            self.session.openWithCallback(rebootQuestionAnswered, MessageBox,"Restart GUI now?",  type = MessageBox.TYPE_YESNO, timeout = 10, default = False)
            
        if self.run == len(self.cmdlist):
            self.container.appClosed.remove(self.runFinished)
            self.container.dataAvail.remove(self.dataAvail)
            if os_path.exists("/tmp/.rebootGUI"):
                self.session.openWithCallback(doReboot,MessageBox, 'LICENCJA: Wszystkie tłumaczenia są autorstwem kolegów Mariusz1970P i Century.\n\nMożesz z nich korzystać jedynie za pośrednictwem wtyczki "Aktualizator tłumaczeń".\nUszanuj pracę autorów i poświęcony czas i nie wykorzystuj ich bezpośrednio w swoich wtyczkach, czy paczkach.', MessageBox.TYPE_INFO, timeout=15)
            else:
                self.close()

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

        skin  = """
        <screen name="j00zekTUMenu" position="center,center" size="520,520" title="j00zekTUMenu" >
        <widget name="list" position="5,30" font="Regular;20" size="510,350" scrollbarMode="showOnDemand" />
        <eLabel text="Tłumaczenia: Mariusz1970, Century" position="0,390" size="520,30" font="Regular;22" foregroundColor="yellow" valign="center" halign="center" />
        <eLabel text="Wtyczka: (c)2015,2016 j00zek" position="0,420" size="520,30" font="Regular;22" foregroundColor="yellow" valign="center" halign="center" />
        <eLabel position="  5,455" size="253, 30" zPosition="-10" backgroundColor="#20b81c46" />
        <eLabel position="262,455" size="253, 30" zPosition="-10" backgroundColor="#20009f3c" />
        <eLabel position="  5,490" size="253, 30" zPosition="-10" backgroundColor="#209ca81b" />
        
        <widget source="key_red"    render="Label" position="  5,455" size="253,30" zPosition="1" font="Regular;20" valign="center" halign="center" transparent="1" />
        <widget source="key_green"  render="Label" position="262,455" size="253,30" zPosition="1" font="Regular;20" valign="center" halign="center" transparent="1" />
        <widget source="key_yellow" render="Label" position="  5,490" size="253,30" zPosition="1" font="Regular;20" valign="center" halign="center" transparent="1" />
        
        <widget source="Header1" render="Label" position=" 10,0" size="150,30" font="Regular;18" foregroundColor="#6DABBF" valign="center" halign="center" />
        <widget source="Header2" render="Label" position="145,0" size="460,30" font="Regular;18" foregroundColor="#6DABBF" valign="center" halign="center" />

        </screen>"""

        self.skin = skin
        self.session = session
        Screen.__init__(self, session)

        self["list"] = MenuList(self.list)
        
        self["actions"] = ActionMap(["OkCancelActions", "ColorActions"],
            {"ok": self.run,
            "cancel": self.close,
            "red": self.ZmienSortowanie,
            "green": self.ZmienUkrywanieNiezainstalowanych,
            "yellow": self.ZmienAutoUpdate,
            }, -1)

        self.onLayoutFinish.append(self.onStart)
        self.visible = True
        self.setTitle("Pobieranie danych...")
        self["key_red"] = StaticText("")
        self["key_green"] = StaticText("")
        self["key_yellow"] = StaticText("")
        self["Header1"] = StaticText("")
        self["Header2"] = StaticText("")
      
    def onStart(self):
        self.system( "rm -f /tmp/PolishTranslations.list" )
        self.updateDataTimer = eTimer()
        self.updateDataTimer.callback.append(self.updateData)
        self.updateDataTimer.start(500, True) # singleshot
        
    def updateData(self):
        self.setButtons(czysc=True)
        self.setTitle("Pobieranie danych...")
        self.system( "%s/_MenuGenerator.sh %s" % (self.myPath, self.myPath) )
        self.setTitle(self.MenuTitle)
        self.clearLIST()
        self.reloadLIST()
        self.setButtons()
    
    def ZmienAutoUpdate(self):
        config.plugins.TranslationsUpdater.AutoUpdate.value = not config.plugins.TranslationsUpdater.AutoUpdate.value
        config.plugins.TranslationsUpdater.AutoUpdate.save()
        configfile.save()
        self.setButtons()
      
    def ZmienSortowanie(self):
        config.plugins.TranslationsUpdater.SortowaniePoDacie.value = not config.plugins.TranslationsUpdater.SortowaniePoDacie.value
        config.plugins.TranslationsUpdater.SortowaniePoDacie.save()
        configfile.save()
        self.setButtons(czysc=True)
        self.clearLIST()
        self.updateDataTimer.start(100, True) # singleshot
        
    def ZmienUkrywanieNiezainstalowanych(self):
        config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych.value = not config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych.value
        config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych.save()
        configfile.save()
        self.setButtons(czysc=True)
        self.clearLIST()
        self.updateDataTimer.start(100, True) # singleshot
  
    def setButtons(self, czysc=False):
        if czysc == True:
            self["key_red"].setText("")
            self["key_green"].setText("")
            self["Header1"].setText("")
            self["Header2"].setText("")
            return
        if config.plugins.TranslationsUpdater.SortowaniePoDacie.value == True:
            self["key_red"].setText("Posortuj po nazwie")
            self["Header1"].setText("Z dnia")
            self["Header2"].setText("Plik")
        else:
            self["key_red"].setText("Posortuj po dacie")
            self["Header1"].setText("Plik")
            self["Header2"].setText("z dnia")
            
        if config.plugins.TranslationsUpdater.UkrywanieNiezainstalowanych.value == True:
            self["key_green"].setText("Pokaż wszystkie")
        else:
            self["key_green"].setText("Ukryj niezainstalowane")
            
        if config.plugins.TranslationsUpdater.AutoUpdate.value == True:
            self["key_yellow"].setText("Wył. AutoAktualizację")
        else:
            self["key_yellow"].setText("Wł. AutoAktualizację")
            
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
                        self.session.openWithCallback(self.endrun ,translatedConsole, title = "%s" % selecteditem, cmdlist = [ ('chmod 775 %s 2>/dev/null' %  self.SkryptOpcji),('%s' %  self.SkryptOpcji) ])
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
                            
    def endConsole(self, ret =0, wymusUpdate=False):
        self.session.openWithCallback(self.endrun,MessageBox, 'LICENCJA: Wszystkie tłumaczenia są autorstwem kolegi Mariusz1970P.\nMożesz z nich korzystać jedynie za pośrednictwem wtyczki "Aktualizator tłumaczeń".\nUszanuj jego pracę i poświęcony czas i nie wykorzystuj ich bezpośrednio w swoich wtyczkach, czy paczkach.', MessageBox.TYPE_INFO, timeout=15)

    def endrun(self, ret =0, wymusUpdate=False):
        #odświerzamy menu
        if not os_path.exists(self.MenuFile) or wymusUpdate == True:
            with open("/proc/sys/vm/drop_caches", "w") as f: f.write("1\n")
            self.system( "%s/_MenuGenerator.sh %s" % (self.myPath, self.myPath) )
        self.clearLIST()
        self.reloadLIST()

    def SkryptOpcjiWithFullPAth(self, txt):
        if not txt.startswith('/'):
            return ('%s/%s') %(self.myPath,txt)
        else:
            return txt
            
    def clearLIST(self):
        #czyścimy listę w ten dziwny sposób, aby GUI działało, bo nie zmienimy obiektów ;)
        while len(self.list) > 0:
            del self.myList[-1]
            del self.list[-1]
        self["list"].hide()
        self["list"].show()

    def reloadLIST(self):
        if os_path.exists(self.MenuFile) is True:
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
