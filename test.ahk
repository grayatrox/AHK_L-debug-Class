#include F:\AHK projects\StreamRipper\lib\debugWindow.ahk
#include F:\AHK projects\StreamRipper\lib\StdoutToVar.ahk
#Persistent



OnExit, ExitSub

;StdoutToVar.ahk ;http://www.autohotkey.com/community/viewtopic.php?p=550661#p550661
;#Include HttpQueryInfo.ahk  ;http://www.autohotkey.com/community/viewtopic.php?p=532283#p532283

FileEncoding, CP850

; Props go to Talisman, Nameless, and the other regulars on IRC for help here and there :D
debugWindow := new debugWindow("DebugWindow",1,10,10,400)
debugWindow.OFf()

defaultSave := "G:\streamripper"
defaultRipper := a_scriptdir "\lib\streamripper\streamripper.exe"
defaultListenKey := ""
defaultStartup := true
defaultDebug := false
defaultPremium := false

IniRead, RipperLoc, lib\settings.ini, Settings, RipperLoc, %defaultRipper%
IniRead, SaveLoc, lib\settings.ini, Settings, SaveLoc, %defaultSave%
IniRead, ListenKey, lib\settings.ini, Settings, ListenKey, %defaultListenKey%
IniRead, startup, lib\settings.ini, Settings, startup, %defaultStartup%
IniRead, debug, lib\settings.ini, Settings, debug, %defaultDebug%
IniRead, premium, lib\settings.ini, Settings, premium, %defaultPremium%

debugWindow.Add("defaultRipper: " defaultRipper "`ndefaultSave: " defaultSave "`ndefaultListenKey: " defaultListenKey "`ndefaultStartup :" defaultStartup "`ndefaultDebug: " defaultDebug "`ndefaultPremium: " defaultPremium)
debugWindow.Add("RipperLoc: " RipperLoc "`nSaveLoc: " defaultSave "`nListenKey: " ListenKey "`nStartup :" Startup "`nDebug: " Debug "`nPremium: " Premium)
debugWindow.On()

GuiControl,Settings:,SaveLoc, %SaveLoc%
GuiControl,Settings:,RipperLoc, %RipperLoc%
if(ListenKey == "ERROR")
	ListenKey := ""
GuiControl,Settings:,ListenKey, %ListenKey%
GuiControl,Settings:,startup, %startup%
GuiControl,Settings:,debug, %debug%
GuiControl,Settings:,premium, %premium%

streamripper.loc := RipperLoc
streamripper.save := SaveLoc


loaded:= true
streamripper := {}

playlist =
(
www.google.com
)

streams := {}

Loop, parse, playlist,`n,`r
{
	stream := {}
	stream.id := A_index
	stream.url := A_LoopField
	stream.process := new cli("ping.exe www.google.com")
	streams.Insert(stream)
	tabs .= stream.url "|"
}
Gui, Main:Add, Progress, w465 h20 vProgress
Gui,Main:Add,Tab2,w485,%tabs%
Gui,Debug:Add,Tab2,w485,%tabs%

for each, tab in streams
{
	tabID := tab.id
	Gui, Main:Tab,%tabID%,1
	Gui, Main:Add, Text, w465 h125 vstream%tabID%,
	Gui, Debug:Tab,%tabID%,1
	Gui, Debug:Add, Edit, w465 h185 vdebug%tabID% readonly
}
Gui, Main:Tab
Gui, Main:Add, CheckBox, y+77 x10 gdebug vdebug checked%debug%, Debug Window
Gui, Main:Add, Button,y+-17 x+355 gMainGuiClose,Exit
Gui,Main:Show,, Streaming
if (debug)
	Gui,Debug:Show,x5 y5, Stream Debug
;Progress, b w200,,%A_Space%
index := 0
SetTimer, update, -200
return

MainGuiClose:
ExitApp

LoadDefaults:
GuiControl,Settings:,SaveLoc, %defaultSave%
GuiControl,Settings:,RipperLoc, %defaultRipper%
GuiControl,Settings:,ListenKey, %defaultListenKey%
GuiControl,Settings:,startup, %defaultStartup%
GuiControl,Settings:,debug, %defaultDebug%
GuiControl,Settings:,premium, %defaultPremium%
return

SaveBrowse:
GuiControlGet, InputVar,Settings:, SaveLoc
FileSelectFolder, SaveLoc,, 3, Select Save Location
if(!FileExist(SaveLoc)) {
	Msgbox Invalid Save Location`nThere have been no changes made.
	return
}
GuiControl,Settings:, SaveLoc, %SaveLoc%
Return

BrowseRipper:
GuiControlGet, InputVar,Settings:, RipperLoc

if(!FileExist(InputVar))
	StartingFolder := A_ProgramFiles ((A_Is64bitOS)?(" (x86)"):())
else
	SplitPath, InputVar,,StartingFolder
FileSelectFile, RipperLoc, 1, %StartingFolder%, Find streamripper.exe,streamripper.exe
if(!FileExist(RipperLoc))
	RipperLoc := InputVar

; and now one last time
if(!FileExist(RipperLoc))
	goto BrowseRipper

GuiControl,Settings:, RipperLoc, %RipperLoc%
return




debug:
	debug := !debug
	if (debug) {
		Gui,Debug:Show,x5 y5, Debug
		return
	}
DebugGuiClose:
Gui, Debug:Cancel
debug := false
return

update:
newStreams :={}
index := ((index >= 100)?(0):( index + 20))
;Progress, %index%,,%last_line%
GuiControl,Main:, Progress, %index%  
for each, item in streams
{	
	item.data .= item.process.stdout()
	id := item.id
	GuiControl,Main:, stream%id%, %data%
	if (item.data != item.olddata) {
		data := item.data
		item.olddata := item.data
		newStreams.Insert(item)
	}
	sleep 100
}
streams:=newStreams
SetTimer, update, -100
return

ExitSub:
exitReason := ((exitReason)?(exitReason):(A_ExitReason))
if exitReason not in Logoff,Shutdown,Reload,Error
{
    MsgBox, 4, , Are you sure you want to exit?
    IfMsgBox, No
        return
}

for each, stream in streams
	stream.process.close()

for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
{
	if (inStr(process.Name, "streamripper.exe"))
		{
			pid := process.ProcessId
			Process, Close, %pid%
		}
}
ExitApp 
