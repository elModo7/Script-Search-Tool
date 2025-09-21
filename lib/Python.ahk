;#Include %A_LineFile%\..\Util.ahk

HighlightPython(Settings, ByRef Code) {
	; Thank you to the Rouge project for compiling these keyword lists
	; https://github.com/jneen/rouge/blob/master/lib/rouge/lexers/javascript.rb
	static Keywords     := "and|as|assert|async|await|break|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import"
						.  "|in|is|lambda|None|nonlocal|not|or|pass|raise|return|True|try|while|with|yield"
	static Declarations := "var"  ; Python doesn't have explicit variable declarations like JavaScript
	static Constants    := "True|False|None"
	static Builtins     := "abs|all|any|bin|callable|chr|classmethod|compile|complex|delattr|dict|dir|divmod|enumerate|eval|exec|filter|float|format|frozenset|getattr|globals|hasattr|"
						.  "hash|help|hex|id|input|int|isinstance|issubclass|iter|len|list|locals|map|max|memoryview|min|next|object|oct|open|ord|pow|print|property|range|repr|reversed|round|"
						.  "set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|vars|zip"
	static Needle       := "
						   ( LTrim Join Comments
					        	ODims)
					        	(#[^\n]+)                  ; Comments
					        	|('[^']*')                 ; Single-quoted strings
					        	|(""[^""]*"")              ; Double-quoted strings
					        	|([+*!~&\/\\<>^|=?:@;
					        		,().```%{}\[\]\-]+)    ; Punctuation
					        	|\b(0x[0-9a-fA-F]+|[0-9]+) ; Numbers
					        	|\b(" Constants ")\b       ; Constants
					        	|\b(" Keywords ")\b        ; Keywords
					        	|\b(" Declarations ")\b    ; Declarations
					        	|\b(" Builtins ")\b        ; Builtins
					        	|(([a-zA-Z_][a-zA-Z0-9_]*)(?=\())  ; Functions/Identifiers
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
