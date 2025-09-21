; This are functions that I have just added so that this old script is more "user friendly"
; It's common to the old and new indexer
#Include <aboutScreen>
version := "1.0"
FileCreateDir, % A_Temp "\File_Indexer"
FileInstall, res/ico/refresh.ico, % A_Temp "\File_Indexer\refresh.ico" 
FileInstall, res/ico/cut_visibility.ico, % A_Temp "\File_Indexer\cut_visibility.ico" 
FileInstall, res/ico/info.ico, % A_Temp "\File_Indexer\info.ico" 
FileInstall, res/ico/close3.ico, % A_Temp "\File_Indexer\close3.ico" 

Menu, Tray, NoStandard
Menu, Tray, Tip, File Indexer %version% 
Menu, Tray, Add, Reindex, recreate
Menu tray, Icon, Reindex, % A_Temp "\File_Indexer\refresh.ico"
Menu, Tray, Add, Clear config, clearConfig
Menu tray, Icon, Clear config, % A_Temp "\File_Indexer\cut_visibility.ico"
Menu, Tray, Add,
Menu, Tray, Add, About, showAbout
Menu tray, Icon, About, % A_Temp "\File_Indexer\info.ico"
Menu, Tray, Add, Exit, GuiClose
Menu tray, Icon, Exit, % A_Temp "\File_Indexer\close3.ico"

createSampleConfigIfNotExist()
loadConfig()

loadConfig() {
	global
	IniRead, config, config.ini, configuration
	Loop, Parse, config, `n
	{
		subtring1 := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1)
		subtring2 := SubStr(A_LoopField, InStr(A_LoopField, "=")+1, StrLen(A_LoopField))
		%subtring1% := subtring2
	}
}

createSampleConfigIfNotExist() {
	global recreate, extensions, indexPath
	if (!FileExist("config.ini")) {
		MsgBox 0x30, Empty Config, Default config file not found!`n`nLet's create config.ini
		FileSelectFolder, indexPath,,, Select the path that you want to index
		if (!ErrorLevel && indexPath != "") {
			indexPath .= "\"
			InputBox, extensions, Extensions, Input the extensions you want to index. Use comma separated values to add more than one`n`nExample: ahk`,exe`,7z`,zip`,rar`,pdf`,txt`,html`,mhtml`,dll,,,,,,,,ahk`,exe`,7z`,zip`,rar`,pdf`,txt`,html`,mhtml`,dll
			MsgBox 0x24, Index Content, Do you want to index the content of the ahk files for deep searching?
			IfMsgBox Yes, {
				contentIndexed := 1
			} Else IfMsgBox No, {
				contentIndexed := 0
			}
			if (!ErrorLevel && extensions != "") {
				StringReplace, extensions, extensions, %A_Space%,, All
				recreate := true
				sampleConfig :=
				(LTrim
				"[configuration]
				indexPath=" indexPath "
				fileExtensions=" extensions "
				defaultEditor=C:\Windows\notepad.exe
				contentIndexed=" contentIndexed
				)
				FileAppend, %sampleConfig%, config.ini
			} else {
				showError("There was an error processing the extensions", true)
			}
		} else {
			showError("There was an error selecting the folder to index.", true)
		}
	}
}

showError(msg, isFatal := false) {
	if (isFatal) {
		MsgBox 0x10, Error, % msg "`n`n The app will now close."
		ExitApp
	} else {
		MsgBox 0x10, Error, % msg
	}
}

clearConfig() {
	MsgBox 0x34, Delete config?, Are you sure you want to delete your existing configuration?
	IfMsgBox Yes, {
		FileDelete, config.ini
		Reload
	}	
}

showAbout() {
	global version
	showAboutScreen("File Indexer v" version, "A tool to quickly search for specific type of files in a set of folders.`nI normally use it to faster locate my AutoHotkey scripts.")
}