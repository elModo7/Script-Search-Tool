; This is a really old script from when I started learning AutoHotkey, most of the code is in Spanglish.
; I shall update some of it and make it cleaner/clearer but, I use it everyday and it works really well as it is so it is unlikely that it happens.
;~ Params:
;~ -recreate ; recreates the DB
; 21/09/2025 - Addres RichEdit code from https://github.com/Ixiko/AHK-CodeSearch
#NoEnv
; #Warn
#SingleInstance force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
global showFileProgress := 1 ; Shows current file being indexed, 0=faster index; 1=show feedback
OnExit, GuiClose
Global 0, 1, 2, 3
Global contentSearch := 0
Global silentErrors := 0 ; Do not show errors
SetTimer, checkInput, 100 ; Checks input changes
Global recreate
    Loop, %0%  ; For each parameter:
    {
        param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
         if(param = "-recreate")
         {
            recreate := 1
         }
    }   
#Include <common_init>
; ======================================================================================================================
; Includes
; ======================================================================================================================
#Include <Class_SQLiteDB>
#Include <SciteOutPut>
#Include <adjHdrs>
#Include <Util>
#Include <AHK>
#Include <CSS>
#Include <JS>
#Include <HTML>
#Include <Python>
#Include <class_RichCode>
; ======================================================================================================================
; Start & GUI
; ======================================================================================================================
CBBSQL := "SELECT * FROM AHKIndex"
DBFileName := A_ScriptDir . "\res\bbdd\index.db"
Title := "File Indexer v" version " elModo7 / VictorDevLog " A_YYYY

; richedit settings
  Settings3 :=
  ( LTrim Join Comments
  {
  ; When True, this setting may conflict with other instances of CQT
  "GlobalRun"         : False,

  ; Script options
  "AhkPath"           : A_AhkPath,
  "Params"            : "",

  ; Editor (colors are 0xBBGGRR)
  "FGColor"           : 0xEDEDCD,
  "BGColor"           : 0x3F3F3F,
  "GuiBGColor1"      	: "555453",
  "GuiBGColor2"      	: "D8D7D6",
  "TabSize"           : 4,
  "Font" : {
      "Typeface"        : "Consolas",
      "Size"            : 11,
      "Bold"            : False
          },

  "Gutter" : {
      "Width"        	  : 75,
      "FGColor"     	  : 0x9FAFAF,
      "BGColor"     	  : 0x262626
  },

  ; Highlighter (colors are 0xRRGGBB)
  "UseHighlighter": True,
  "Highlighter": "HighlightAHK",
  "HighlightDelay": 200, ; Delay until the user is finished typing
  "Colors": {
      "Comments":     0x7F9F7F,
      "Functions":    0x7CC8CF,
      "Keywords":     0xE4EDED,
      "Multiline":    0x7F9F7F,
      "Numbers":      0xF79B57,
      "Punctuation":  0x97C0EB,
      "Strings":      0xCC9893,
      "A_Builtins":   0xF79B57,
      "Commands":     0xCDBFA3,
      "Directives":   0x7CC8CF,
      "Flow":         0xE4EDED,
      "KeyNames":     0xCB8DD9
  },

  ; Auto-Indenter
  "Indent": "`t",

  ; Pastebin
  "DefaultName": A_UserName,
  "DefaultDesc": "Pasted with CodeQuickTester",

  ; AutoComplete
  "UseAutoComplete": True,
  "ACListRebuildDelay": 500 ; Delay until the user is finished typing
}
)

;~ If FileExist(DBFileName) {
   ;~ SB_SetText("Deleting " . DBFileName)
   ;~ FileDelete, %DBFileName%
;~ }
Gui, +LastFound +OwnDialogs +Disabled
Gui, Margin, 10, 10
if (contentIndexed) {
   Gui, Add, CheckBox, x+0 ym w120 h23 vcontentSearch gcontentSearchToggled, Content Search
   Gui, Add, Edit, x140 ym w640 vSQL Sort,
} else {
   Gui, Add, Edit, x+0 ym w780 vSQL Sort,
}
GuiControlGet, P, Pos, SQL
GuiControl, Move, TX, h%PH%0
;~ Gui, Add, Button, ym w80 hp vRun gRunSQL Default, Buscar
;~ Gui, Add, Text, xm h20 w100 0x200, Table name:
;~ Gui, Add, Edit, x+0 yp w150 hp vTable, AHKIndex
;~ Gui, Add, Button, Section x+10 yp wp hp gGetTable, Get _Table
;~ Gui, Add, Button, x+10 yp wp hp gGetRecordSet, Get _RecordSet
Gui, Add, GroupBox, xm w780 h330, Results
Gui, Add, ListView, xp+10 yp+18 w760 h300 gLista vResultsLV +LV0x00010000
Gui, Add, StatusBar,

RCPos 	:= "x8 y380 w780 h300"
RC    	:= new RichCode(Settings3, RCPos, 1)
hTP   	:= RC.hwnd
hGtr  	:= RC.gutter.hwnd
DocObj  := RC.GetTomObject("IID_ITextDocument")
;~ RC.AddMargins(5, 5, 5, 5)
RC.ShowScrollBar(0, False)

Gui, Show, , %Title%
Menu, MyContextMenu, Add, Run, ContextMenu
Menu, MyContextMenu, Add, Edit, ContextMenu
Menu, MyContextMenu, Add, Open path, ContextMenu
Menu, MyContextMenu, Default, Run

if (recreate)
{
   recreate()
} else {
   SB_SetText("SQLiteDB new")
   DB := new SQLiteDB
   SB_SetText("OpenDB")
   If !DB.OpenDB(DBFileName) {
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
      ExitApp
   }
   SB_SetText("Ready")
}

; ======================================================================================================================
; End of query using Query()
; ======================================================================================================================
Gui, -Disabled
GuiControl, Focus, SQL
Return
; ======================================================================================================================
; Gui Subs
; ======================================================================================================================

recreate() {
   global
   Gui, +LastFound +OwnDialogs +Disabled
   DB.CloseDB(DBFileName)
   FileDelete, % DBFileName
   SB_SetText("SQLiteDB new")
   DB := new SQLiteDB
   SB_SetText("OpenDB")
   If !DB.OpenDB(DBFileName) {
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
      ExitApp
   }
   SB_SetText("Exec: CREATE TABLE")
   if (contentIndexed) {
      SQL := "CREATE TABLE AHKIndex (Id, Name, Path, Content, PRIMARY KEY(Id ASC));"
   } else {
      SQL := "CREATE TABLE AHKIndex (Id, Name, Path, PRIMARY KEY(Id ASC));"
   }
   If !DB.Exec(SQL)
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   SB_SetText("Recreating Database...")
   Start := A_TickCount
   cuenta := 1
   
   Loop Files, %indexPath%*.*, FDR
   {
      if A_LoopFileExt in %fileExtensions%
      {
         DB.Exec("BEGIN TRANSACTION;")
         SQLStr := ""
         StringReplace, ruta, % A_LoopFileFullPath, %indexPath%
         StringReplace, safeFileName, A_LoopFileName, ', '', All
         StringReplace, ruta, ruta, ', '', All
         if (contentIndexed) {
            if (A_LoopFileExt == "ahk") {
               FileRead, content, % A_LoopFileFullPath
               StringReplace, content, content, ', '', All
               _SQL := "INSERT INTO AHKIndex VALUES(`'" cuenta "`', `'" safeFileName "`', `'" ruta "`', `'" content "`');"
            } 
            else 
               _SQL := "INSERT INTO AHKIndex VALUES(`'" cuenta "`', `'" safeFileName "`', `'" ruta "`', `'`');"
         } else 
            _SQL := "INSERT INTO AHKIndex VALUES(`'" cuenta "`', `'" safeFileName "`', `'" ruta "`');"
         if (showFileProgress)
            SB_SetText(ruta)
         SQLStr .= _SQL
         DB.Exec(SQLStr)
         if (DB.ErrorMsg && !silentErrors)
            MsgBox % _SQL "`n" DB.ErrorMsg
         DB.Exec("COMMIT TRANSACTION;")
         if (DB.ErrorMsg && !silentErrors)
            MsgBox % _SQL "`n" DB.ErrorMsg
         cuenta++
      }
   }
   Loop Files, %indexPath%*.*, DR
   {
      DB.Exec("BEGIN TRANSACTION;")
      SQLStr := ""
      StringReplace, ruta, % A_LoopFileFullPath, %indexPath%
      StringReplace, safeFileName, A_LoopFileName, ', '', All
      StringReplace, ruta, ruta, ', '', All
      if (contentIndexed) {
         _SQL := "INSERT INTO AHKIndex VALUES(`'" cuenta "`', `'" safeFileName "`', `'" ruta "`', `'`');"
      } else 
         _SQL := "INSERT INTO AHKIndex VALUES(`'" cuenta "`', `'" safeFileName "`', `'" ruta "`'); "
      if (showFileProgress)
         SB_SetText(ruta)
      SQLStr .= _SQL
      DB.Exec(SQLStr)
      if (DB.ErrorMsg && !silentErrors)
         MsgBox % _SQL "`n" DB.ErrorMsg
      DB.Exec("COMMIT TRANSACTION;")
      if (DB.ErrorMsg && !silentErrors)
         MsgBox % _SQL "`n" DB.ErrorMsg
      cuenta++
   }
   SQLStr := ""
   SB_SetText("Database recreated in " . (A_TickCount - Start) . " ms")
   Sleep, 1000
   Gui, -Disabled
}

GuiContextMenu:
if A_GuiControl <> ResultsLV
    return
Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextMenu:
FocusedRowNumber := LV_GetNext(0, "F")  ; Find the focused row.
if not FocusedRowNumber  ; No row is focused.
    return
LV_GetText(FileName, FocusedRowNumber, 2)
LV_GetText(FilePath, FocusedRowNumber, 3)
StringReplace, carpeta, FilePath, %FileName%
carpeta := indexPath carpeta
fichero := indexPath FilePath
;~ MsgBox, % FileName "`n" FilePath "`n" carpeta "`n" fichero

IfInString A_ThisMenuItem, Open path
{
   Run, explorer.exe /select`,"%fichero%"
}
else IfInString A_ThisMenuItem, Edit
{
   Run, % defaultEditor " """ fichero """"
}
else IfInString A_ThisMenuItem, Run
{
   SetWorkingDir, % carpeta
   Run, % fichero
   SetWorkingDir, % A_ScriptDir
}
if ErrorLevel
    MsgBox Could not perform requested action on "%FileName%".
return
Lista:
if (A_GuiEvent = "DoubleClick")
{
   LV_GetText(FileName, A_EventInfo, 2)
   LV_GetText(FilePath, A_EventInfo, 3)
   StringReplace, carpeta, FilePath, %FileName%
   fileSplit := StrSplit(FileName, ".")
   carpeta := indexPath carpeta
   SetWorkingDir, % carpeta
   fileExtension := fileSplit[fileSplit.length()]
   if (fileExtension == "ahk" ||fileExtension == "txt") {
      if (FileExist(FileName)) {
         RC.Value := FileOpen(FileName, "r").Read()
         RC.UpdateGutter()
      } else if (fileExtension == "ahk" && contentIndexed) {
         LV_GetText(fileId, A_EventInfo, 1)
         RC.Value := getFileContentById(fileId)
         RC.UpdateGutter()
      }
   } else {
      Run, % """" FileName """"
   }
   SetWorkingDir, % A_ScriptDir
   ;~ MsgBox, % FileName "`n" FilePath "`n" carpeta "`n" fichero
}
return
GuiClose:
GuiEscape:
If !DB.CloseDB()
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
Gui, Destroy
ExitApp
; ======================================================================================================================
; Other Subs
; ======================================================================================================================
; "One step" query using GetTable()
; ======================================================================================================================
GetTable:
Gui, Submit, NoHide
Result := ""
SQL := "SELECT * FROM " . Table . ";"
SB_SetText("GetTable: " . SQL)
Start := A_TickCount
If !DB.GetTable(SQL, Result)
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
SB_SetText("GetTable: " . SQL . " done in " . (A_TickCount - Start) . " ms")
ShowTable(Result)
Return
; ======================================================================================================================
; Show results for prepared query using Query()
; ======================================================================================================================
GetRecordSet:
Gui, Submit, NoHide
SQL := "SELECT * FROM " . Table . ";"
SB_SetText("Query: " . SQL)
RecordSet := ""
Start := A_TickCount
If !DB.Query(SQL, RecordSet)
   MsgBox, 16, SQLite Error: Query, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
ShowRecordSet(RecordSet)
RecordSet.Free()
SB_SetText("Query: " . SQL . " done in " . (A_TickCount - Start) . " ms")
Return
; ======================================================================================================================
; Execute SQL statement using Exec() / GetTable()
; ======================================================================================================================
RunSQL:
SetTimer, RunSQL, Off
SB_SetText("Searching...")
Gui, +OwnDialogs
GuiControlGet, SQL
If SQL Is Space
{
   SQL := "%"
}
if (contentSearch)
   SQL = SELECT Id, Name, Path FROM AHKIndex WHERE PATH LIKE '`%%SQL%`%' OR Content LIKE '`%%SQL%`%'
else
   SQL = SELECT Id, Name, Path FROM AHKIndex WHERE PATH LIKE '`%%SQL%`%'
If !InStr("`n" . CBBSQL . "`n", "`n" . SQL . "`n") {
   ;~ GuiControl, , SQL, %SQL%
   CBBSQL .= "`n" . SQL
}
If (SubStr(SQL, 0) <> ";")
   SQL .= ";"
Result := ""
If RegExMatch(SQL, "i)^\s*SELECT\s") {
   ;~ SB_SetText("GetTable: " . SQL)
   If !DB.GetTable(SQL, Result)
      MsgBox, 16, SQLite Error: GetTable, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   Else
      ShowTable(Result)
   ;~ SB_SetText("GetTable: " . SQL . " done!")
} Else {
   SB_SetText("Exec: " . SQL)
   If !DB.Exec(SQL)
      MsgBox, 16, SQLite Error: Exec, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
}
SB_SetText("Ready")
Return

getFileContentById(fileId) {
   global
   Gui, +OwnDialogs
   if (fileId)
      SQL = SELECT Content FROM AHKIndex WHERE Id = '%fileId%'
   If !InStr("`n" . CBBSQL . "`n", "`n" . SQL . "`n") {
      CBBSQL .= "`n" . SQL
   }
   If (SubStr(SQL, 0) <> ";")
      SQL .= ";"
   Result := ""
   If RegExMatch(SQL, "i)^\s*SELECT\s") {
      If !DB.GetTable(SQL, Result)
         MsgBox, 16, SQLite Error: GetTable, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   } Else {
      SB_SetText("Exec: " . SQL)
      If !DB.Exec(SQL)
         MsgBox, 16, SQLite Error: Exec, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   }
   return Result.Rows[1][1]
}

contentSearchToggled:
   contentSearch := !contentSearch
   gosub, RunSQL
return
; ======================================================================================================================
; Exec() callback function sample
; ======================================================================================================================
SQLiteExecCallBack(DB, ColumnCount, ColumnValues, ColumnNames) {
   This := Object(DB)
   MsgBox, 0, %A_ThisFunc%
      , % "SQLite version: " . This.Version . "`n"
      . "SQL statement: " . StrGet(A_EventInfo) . "`n"
      . "Number of columns: " . ColumnCount . "`n" 
      . "Name of first column: " . StrGet(NumGet(ColumnNames + 0, "UInt"), "UTF-8") . "`n" 
      . "Value of first column: " . StrGet(NumGet(ColumnValues + 0, "UInt"), "UTF-8")
   Return 0
}
; ======================================================================================================================
; Show results
; ======================================================================================================================
ShowTable(Table) {
   Global
   Local ColCount, RowCount, Row
   GuiControl, -ReDraw, ResultsLV
   LV_Delete()
   ColCount := LV_GetCount("Column")
   Loop, %ColCount%
      LV_DeleteCol(1)
   If (Table.HasNames) {
      Loop, % Table.ColumnCount
         LV_InsertCol(A_Index,"", Table.ColumnNames[A_Index])
      If (Table.HasRows) {
         Loop, % Table.RowCount {
            RowCount := LV_Add("", "")
            Table.Next(Row)
            Loop, % Table.ColumnCount
               LV_Modify(RowCount, "Col" . A_Index, Row[A_Index])
         }
      }
      Loop, % Table.ColumnCount
         LV_ModifyCol(A_Index, "AutoHdr")
   }
   GuiControl, +ReDraw, ResultsLV
}
; ----------------------------------------------------------------------------------------------------------------------
ShowRecordSet(RecordSet) {
   Global
   Local ColCount, RowCount, Row, RC
   GuiControl, -ReDraw, ResultsLV
   LV_Delete()
   ColCount := LV_GetCount("Column")
   Loop, %ColCount%
      LV_DeleteCol(1)
   If (RecordSet.HasNames) {
      Loop, % RecordSet.ColumnCount
         LV_InsertCol(A_Index,"", RecordSet.ColumnNames[A_Index])
   }
   If (RecordSet.HasRows) {
      If (RecordSet.Next(Row) < 1) {
         MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
         Return
      }
      Loop {
         RowCount := LV_Add("", "")
         Loop, % RecordSet.ColumnCount
            LV_Modify(RowCount, "Col" . A_Index, Row[A_Index])
            RC := RecordSet.Next(Row)
      } Until (RC < 1)
   }
   If (RC = 0)
      MsgBox, 16, %A_ThisFunc%, % "Msg:`t" . RecordSet.ErrorMsg . "`nCode:`t" . RecordSet.ErrorCode
   Loop, % RecordSet.ColumnCount
      LV_ModifyCol(A_Index, "AutoHdr")
   GuiControl, +ReDraw, ResultsLV
}

aboutGuiEscape:
aboutGuiClose:
   AboutGuiClose()
return

GetHex(hwnd)                                                                 	{
   return Format("0x{:x}", hwnd)
}

GetDec(hwnd)                                                                 	{
   return Format("{:u}", hwnd)
}

RCHandler(p1,p2,p3,p4)              	{
	If dbg
		GuiControl,, Debug2,  % "GCE: " p1 " | GE: " p2 " | AEI: " p3 "`nCL: " p4
}

checkInput:
   GuiControlGet, queryField,, SQL
   if(queryField != oldSearchField)
   {
      oldSearchField := queryField
      SetTimer, RunSQL, 500
   }
return