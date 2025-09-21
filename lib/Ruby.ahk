;#Include %A_LineFile%\..\Util.ahk

HighlightRuby(Settings, ByRef Code) {

	static Keywords 	:= "alias|and|BEGIN|begin|break|case|class|def|defined?|do|else|elsif|END|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield"
	static Constants    := "true|false|nil"

	static Needle   	:= "
						   ( LTrim Join Comments
						   ODims)
						   (#[^\n]*)                          ; Kommentare
						   |('[^']*')                         ; Einfache Zeichenketten
						   |(\"[^\"]*\")                      ; Doppelte Zeichenketten
						   |([+*!~&\/\\<>^|=?:@;
						   	,().```%{}\[\]\-]+)               ; Interpunktion
						   |\b(0x[0-9a-fA-F]+|[0-9]+)         ; Zahlen
						   |\b(" Constants ")\b               ; Konstanten
						   |\b(" Keywords ")\b                ; Schlüsselwörter
						   |(([a-zA-Z_][a-zA-Z0-9_]*)(?=\())  ; Funktionen/Bezeichner
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
