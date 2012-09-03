; grayatrox's script debugger. v0.1.0 (according to github)
; Inspiration: Didn't want to debug my own code
; I have commented most of my code, the stuff I haven't should be self explanitory.
; This script should be easliy customised to add your own debugging functions into, and although I haven't tested it, most of the vairables might be available too.
; As always thanks to the people on IRC and forums such as Nameless Talisman,and GeekDude. (again without knowing what the hell I was doing)
; Stuff I stole from the foums will be found next to the code.

/* Function list and description & Vague example
DebugWindow := new([WindowTitle=""Debug Window"", type= 1, x=""center"",y=""center"",h=190,w=470]) - Creates a new debug window. Type 1 is for the defualt debug dialogue, and type 2 is for a textbox
DebugWindow.help() - This dialogue (using its own debug window 0.o)
DebugWindow.add(string [, UseLineBreak=1]) - Adds the string to the debug window (useLinebreak is currently untested)
DebugWindow.close() - Closes the debug window never to be seen again
DebugWindow.hide() - Hides the debug window
DebugWindow.show() - Shows the debug window
DebugWindow.instanceID() - Returns the instanceId so you can manually edit the controls within the debug window
DebugWindow.clear() - Clears all the text within the debug window, to start fresh
DebugWindow.on() - Turns on all future debugging windows for this debug instance
DebugWindow.off() - Turns off all future debugging windows for this debug instance

; n consideration - modal dialoug
demo(){
	debugWindow := new debugWindow() ; create a debug window with default settings
	debugWindow3 := new debugWindow("Debug Window 2",1,0,0,400,400) ; create type 1 debug window at top left of screen and 400w&h
	debugWindow2 := new debugWindow("Debug Window 2",2) ;create a type 2 (msgbox) debug window
	debugWindow.add("This is a test") ; Insert "this is a test" to the first debug window
	t:=5
	Loop %t% 
	{
		debugWindow.add("The show will continue in: " t-A_index) ; Same as last add command, but inside a loop.
		debugWindow3.add("The show will continue in: " t-A_index) ; Same as last add command, but inside a loop.
		sleep 1000
	}
	debugWindow.hide() ; hide the first debug window
	debugWindow3.clear()
	debugWindow2.add("This is also a test") ;display "this is also a test" a dialogue with the option to continue running the script
	debugWindow3.close()
	debugWindow.add("And Another") ;we now add more text to the first debug window
	debugWindow.show()
	debugWindow.help()
	debugWindow.close() ; We are finished using this debugwindow, so we clear it from memory.
	
	WinWaitClose,Help Window
	debugWindow2.Add("I am just going to turn off this debug window for a sec...")
	debugWindow2.Off()
	
	Loop ; an infinite loop just becuase
	{
		Tooltip, Infinite Loop at index %A_index% (Don't stress yet)
		if (A_index >= 10) {
			debugWindow2.add("Oh Look! We are inside an infinite loop, and it's not the end of the world!`n(Click No, otherwise it will be)")
			Msgbox Lol! Whoops. I forgot to turn on debugging. Hang on a sec.
			debugWindow2.On()
			debugWindow2.add("You will have to go back and check the code on line 55 to see what I said, but you should trust me and click no.")
			ExitApp ; If you were silly and clicked yes becuase that's how you roll, I'll kill it for you. 
		}
		sleep 500
	}
	; I really hope you are reading through this befoe you run the demo, because who knows, I maybe REALLY EVIL! :} 
	;                                                  (Also just a friendly reminder to that not everyone has good intentions)
}
*/
class debugWindow {
	__New(title = "Debug Window", type=1, x="center",y="center",h=190,w=470) { ;Note: if you fill in the h&w params, you must also fill in the ones before it. 
		Global
		this.debug := true
		this.type := type
		this.title := title
		initialText := "`n         grayatrox's debug console`n         For Help, call thisObject.help()`n"
		instanceID += 1
		
		Guipositioning := ((x == "center")?():(" x" x))
		Guipositioning .= ((y == "center")?():(" y" y))
		Guipositioning .= " h" h " w" w
		
		controlPosition := "w" w-17 " h" h-12
		
		textBreak := "`n"
		loop 60
		textBreak .= "- "
		textBreak .= "`n`n"
		
		; setup the debug options
		if (this.type == 1){ ; The default debugwindow
			Gui, DebugWindow%instanceID%:Add, Edit, %controlPosition% vdebug%instanceID% hwndOutputVar readonly,%initialtext%%textBreak%
			Gui, DebugWindow%instanceID%:Show,%Guipositioning%,%title%
			this.guiInstance := instanceID
			this.text :=  initialtext textBreak
			this.hwnd := OutputVar
		} else if (this.type != 2) { ; anything else that finds its way into the type var
			Msgbox, Debug type: %type% is not a valid type!
		}
		;  type 2 is a messagebox, We don't need to set anything up for it.
	}
	close() { ; Destroy hte gui
		guiInstance := this.guiInstance
		if (this.type == 1)
		Gui, DebugWindow%guiInstance%:Destroy
	}
	hide() { ; Hide the gui
		guiInstance := this.guiInstance
		if (this.type == 1)
		Gui, DebugWindow%guiInstance%:Hide
	}
	show() { ; Show the gui
		guiInstance := this.guiInstance
		if (this.type == 1)
		Gui, DebugWindow%guiInstance%:Show
	}
	add(string, lb="1"){ ;add text to the gui
		guiInstance := this.guiInstance
		title := this.title
		global textBreak
		if (this.debug) {
			if (this.type == 1 && this.debug){
				this.text .=  string "`n" ((lb)?(textBreak):())
				text := this.text
				GuiControl,DebugWindow%guiInstance%:,debug%guiInstance%, %text%
				hwnd := this.hwnd
				SendMessage, 0x0115, 7, 0,, ahk_id %hwnd% ;WM_VSCROLL  ;http://www.autohotkey.com/community/viewtopic.php?t=56717 (scroll to bottom of editbox)
				Return %ErrorLevel%
			} else if (this.type == 2){
				MsgBox, 4356, %Title%, Debug Message: %String%`nDo you wish to continue?
				IfMsgBox No
				{
					Msgbox,,%Title%,The DebugScript will now close %A_ScriptName%.
					ExitAPP
				}
			}
		}
	}
	clear(){ ;remove text currently in the gui
		guiInstance := this.guiInstance
		global textBreak,initialText
		if (this.type == 1 && this.debug){
		this.text :=  initialText textBreak
		text := this.text
			GuiControl,DebugWindow%guiInstance%:,debug%guiInstance%, %text%
			Return %ErrorLevel%
		}
	}
	instanceID(){
		guiInstance := this.guiInstance
		if (this.type == 1)
		return %guiInstance%
		
	}
	On(){
		this.show()
		this.debug := true
	}
	Off(){
		this.hide()
		this.debug := false
	}
	help() { ; Dispite what you might think, the functionlist is derived from here.
		helpText := "DebugWindow := new([WindowTitle=""Debug Window"", type= 1, x=""center"",y=""center"",h=190,w=470]) - Creates a new debug `n" a_tab " window. Type 1 is for the defualt debug dialogue, and type 2 is for a textbox`n`n"
		helpText .= "DebugWindow.help() - This dialogue (using its own debug window 0.o)`n`n"
		helpText .= "DebugWindow.add(string [, UseLineBreak=1]) - Adds the string to the debug window (useLinebreak is currently untested)`n`n"
		helpText .= "DebugWindow.close() - Closes the debug window never to be seen again`n`n"
		helpText .= "DebugWindow.hide() - Hides the debug window`n`n"
		helpText .= "DebugWindow.show() - Shows the debug window`n`n"
		helpText .= "DebugWindow.instanceID() - Returns the instanceId so you can manually edit the controls within the debug window`n`n"
		helpText .= "DebugWindow.clear() - Clears all the text within the debug window, to start fresh`n`n"
		helpText .= "DebugWindow.on() - Turns on all future debugging windows for this debug instance`n`n"
		helpText .= "DebugWindow.off() - Turns off all future debugging windows for this debug instance`n`n"
		
		helpWindow := new debugWindow("Help Window",1,"center","center",390,670)
		helpWindow.add(helptext)
	}	
}
