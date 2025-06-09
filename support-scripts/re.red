Red [
	Comment: {
		Initial thought from 12.05.2017 mail; see also "ddd"-s after it
		Update 30.01.2022
	}
]
context [
	spec: clear []
	group: 	[#"(" collect some [not #")" [#"|" keep ('|) | keep skip]] ")" ]
	class: 	[
		"[[:" copy cl to ":]]" 3 skip keep (bind to-word cl self);switch cl ["alpha" ['alpha] "alnum" ['alnum] "digit" ['digit]])
		| "\d" keep ('digit)
		| "\w" keep ('alpha)
		| "\s" keep ('ws)
	]
	lower: 			charset [#"a" - #"z" #"ß" - #"ö" #"ø" - #"ÿ"]
	upper: 			charset [#"A" - #"Z" #"À" - #"Ö" #"Ø" - #"Þ"]
	alpha: 			union lower upper
	digit: 			charset "0123456789"
	number:			[some digit]
	alnum:			union alpha digit
	ws: 			charset reduce [space tab cr lf]
	punctuation:	charset [#"," #";" #"!" #"^"" #"'"] ;"
	meta: 			[#"\" #"^^" #"$"  #"." #"|" #"?" #"*" #"+" #"(" #")" #"[" #"^{"]
	metaset: 		charset meta
	literal: 		charset compose [not (meta)]
	escaped:		[#"\" keep metaset]
	anychar:		union metaset union alnum union ws punctuation
	char: 			[#"." keep ('anychar) | keep literal]

	sequence: [
		  escaped
		| group
		| class 
		| char
	]
	to-int: func [char [char! string!]][to-integer to-string char]
	multiplier: [
		  "{,"  copy n2 number #"^}"  keep (reduce [0  to-int n2])
		| #"^{" copy n1 number 
		  [
		    ",}"					  keep (reduce [to-int n1 seq 'any])
		  | #"," copy n2 number #"^}" keep (reduce [to-int n1 to-int n2])
		  | #"^}"					  keep (to-int n1)
		  ]
		| #"?" 						  keep ('opt)
		| #"+" 						  keep ('some)
		| #"*" 						  keep ('any)
	]
	
	build: func [inner /local out s e][
		out: clear []
		parse inner rule: [
			any [ 
				collect set seq sequence 
				[
				  collect set mlt multiplier 
				  (append out first mlt append/only out seq)
				| (append out seq)
				]
			]
		]
		out
	]

	finish: func [starting inner ending][
		middle: build inner
		append spec switch starting [strict [middle] loose [compose/deep [thru [(middle)]]]]
		append spec switch ending [strict ['end] loose [[thru end]]]
	]

	set 're func [string rex /case /local inner ending s][
		spec: 	clear []
		inner: 	clear ""
		parse rex [
			["^^" (starting: 'strict) | (starting: 'loose)]
			copy inner to [
				  "$" s: if (s/-2 <> #"\")	(ending: 'strict) 
				| end 	(ending: 'loose)
			] 
			(finish starting inner ending)
		]
		;print mold spec
		either case [parse/case string spec][parse string spec]
	]
	;set '~ make op! func [str rex][re str rex]
]
