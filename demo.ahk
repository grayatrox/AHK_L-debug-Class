#include %A_ScriptDir%\scriptDebugger.ahk ; This is required until I can figure out how to get the class to be recognised in the stdlib

demo()
Return

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
			debugWindow2.add("You will have to go back and check the code on line 34 to see what I said, but you should trust me and click no.")
			ExitApp ; If you were silly and clicked yes becuase that's how you roll, I'll kill it for you. 
		}
		sleep 500
	}
	; I really hope you are reading through this befoe you run the demo, because who knows, I maybe REALLY EVIL! :} 
	;                                                  (Also just a friendly reminder to that not everyone has good intentions)
}