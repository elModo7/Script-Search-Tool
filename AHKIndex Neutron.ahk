; This script recycles a lot from when I started learning AutoHotkey since it's based on the old version instead of being rewritten.
; Most of the code is in Spanglish, I shall update some of it and make it cleaner/clearer but, I use it everyday and it works really well as it is so it is unlikely that it happens.
;~ Params:
;~ -recreate ; recreates the DB
#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
SetBatchLines, -1
#Include <Neutron>
#Include <common_init>
neutron := new NeutronWindow()
neutron.Load("res/gui/ahk_index.html")
neutron.Gui("+LabelNeutron")
neutron.doc.getElementById("windowTitle").innerHTML := "File Indexer v" version " elModo7 / VictorDevLog " A_YYYY
neutron.Show("w1200 h600")
SetTimer, checkInput, 100 ; Checks input changes
Global silentErrors := 0 ; Do not show errors
global showFileProgress := 1 ; Shows current file being indexed, 0=faster index; 1=show feedback
OnExit, GuiClose
Global 0, 1, 2, 3
Global recreate
Loop, %0%
{
  param := %A_Index%
   if(param = "-recreate")
   {
      recreate := 1
   }
}
#Include <Class_SQLiteDB>
CBBSQL := "SELECT * FROM AHKIndex"
DBFileName := A_ScriptDir . "\res\bbdd\index.db"
Title := "AHK Searcher"

if (recreate) {
   recreate()
} else {
   DB := new SQLiteDB
   If !DB.OpenDB(DBFileName) {
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
      ExitApp
   }
}
Return

recreate() {
   global
   DB.CloseDB(DBFileName)
   FileDelete, % DBFileName
   neutron.wnd.showLoading("SQLiteDB new")
   DB := new SQLiteDB

   neutron.wnd.setLoadingText("OpenDB")
   If !DB.OpenDB(DBFileName) {
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
      ExitApp
   }
   neutron.wnd.showLoading("SQLiteDB new")
   neutron.wnd.setLoadingText("Exec: CREATE TABLE")
   if (contentIndexed) {
      SQL := "CREATE TABLE AHKIndex (Id, Name, Path, Content, PRIMARY KEY(Id ASC));"
   } else {
      SQL := "CREATE TABLE AHKIndex (Id, Name, Path, PRIMARY KEY(Id ASC));"
   }
   If !DB.Exec(SQL)
      MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
   neutron.wnd.setLoadingText("Recreating Database...")
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
            neutron.wnd.setLoadingText(ruta)
         SQLStr .= _SQL
         DB.Exec(SQLStr)
         DB.Exec("COMMIT TRANSACTION;")
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
         neutron.wnd.setLoadingText(ruta)
      SQLStr .= _SQL
      DB.Exec(SQLStr)
      DB.Exec("COMMIT TRANSACTION;")
      cuenta++
   }
   SQLStr := ""
   neutron.wnd.setLoadingText("Database recreated in " . (A_TickCount - Start) . " ms")
   sleep, 1000
   neutron.wnd.hideLoading()
}

checkInput:
SQL := neutron.qs("#inputBusqueda").value
if(SQL != campoBusquedaOld)
{
	campoBusquedaOld := SQL
	SetTimer, RunSQL, 500
}
return

FileInstall, res/gui/ahk_index.html, ahk_index.html
FileInstall, res/gui/bootstrap.min.css, bootstrap.min.css
FileInstall, res/gui/bootstrap.min.js, bootstrap.min.js
FileInstall, res/gui/jquery.min.js, jquery.min.js

NeutronClose:
GuiClose:
GuiEscape:
If !DB.CloseDB()
   MsgBox, 16, SQLite Error, % "Msg:`t" . DB.ErrorMsg . "`nCode:`t" . DB.ErrorCode
Gui, Destroy
ExitApp

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

RunSQL:
SetTimer, RunSQL, Off
If SQL Is Space
{
   SQL := "%"
}
SQL = SELECT * FROM AHKIndex WHERE PATH LIKE '`%%SQL%`%'
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
Return

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

ejecutarAccion(event, command, path)
{
   global
   fullPath := indexPath path
   SplitPath, fullPath, fichero, carpeta
   If(command = "Open path")
   {
      Run, explorer.exe /select`,"%fullPath%"
   }
   else If(command = "Edit")
   {
      Run, % defaultEditor " """ fullPath """"
   }
   else If(command = "Run")
   {
      SetWorkingDir, % carpeta
      Run, % fichero
      SetWorkingDir, % A_ScriptDir
   }
}

ShowTable(Table) {
	Global
	Local ColCount, RowCount, Row
	htmlTabla := ""
	for k, v in Table.Rows
	{
txt :=
(
"<tr><th>" v[1] "</th><td>" v[2] "</td><td>" v[3] "</td></tr>"
)
		htmlTabla := htmlTabla txt
	}
	neutron.doc.getElementById("tableBody").innerHTML := htmlTabla
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