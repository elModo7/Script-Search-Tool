;#Include %A_LineFile%\..\Util.ahk

HighlightIni(Settings, ByRef Code) {
	; Thank you to the Rouge project for compiling these keyword lists
	; https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/javascript.rb
	static Sections := "[A-Za-z0-9_\-]+"
	static Keys 	:= "[A-Za-z0-9_\-]+"
	static Values 	:= ".*?(?=\r\n|\n|$)"

	static Needle       := "
						( LTrim Join Comments
						  ODims)
						  (;[^\n]*)                   ; Comments
						  |\[(" Sections ")\]         ; Sections
						  |(" Keys ")=                ; Keys
						  |=(""?"(" Values ")""?)     ; Values
						  |([+*!~&\/\\<>^|=?:@;
					      ,().```%{}\[\]\-]+)         ; Punctuation
						)"


	GenHighlighterCache(Settings)
	Map := Settings.Cache.ColorMap

	Pos := 1
	while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
	{
		RTF .= "\cf" Map.Plain " "
		RTF .= EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))

		; Flat block of if statements for performance
		if (Match.Value(1) != "")
			RTF .= "\cf" Map.Comments
		else if (Match.Value(2) != "")
			RTF .= "\cf" Map.Multiline
		else if (Match.Value(3) != "")
			RTF .= "\cf" Map.Punctuation
		else if (Match.Value(4) != "")
			RTF .= "\cf" Map.Numbers
		else if (Match.Value(5) != "")
			RTF .= "\cf" Map.Strings
		else if (Match.Value(6) != "")
			RTF .= "\cf" Map.Constants
		else if (Match.Value(7) != "")
			RTF .= "\cf" Map.Keywords
		else if (Match.Value(8) != "")
			RTF .= "\cf" Map.Declarations
		else if (Match.Value(9) != "")
			RTF .= "\cf" Map.Builtins
		else if (Match.Value(10) != "")
			RTF .= "\cf" Map.Functions
		else
			RTF .= "\cf" Map.Plain

		RTF .= " " EscapeRTF(Match.Value())
		Pos := FoundPos + Match.Len()
	}

	return Settings.Cache.RTFHeader . RTF
	. "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
