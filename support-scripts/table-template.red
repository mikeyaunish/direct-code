Red [
	title: "table-template"
	author: {@toomasv  custom fork by: @mikeyaunish}
	file: %table-template.red
	url: https://github.com/mikeyaunish/table-template
	version: 0.123
	date: 14-JUN-2026
]
#include %table-template-support-scripts/style.red
#include %table-template-support-scripts/re.red
#include %table-template-support-scripts/to-valid-types.red
#include %table-template-support-scripts/table-template-support-scripts.red
#include %table-template-support-scripts/requesters.red
#include %table-template-support-scripts/request-array.red


tbl: [
	type: 'panel
	size: 317x217
	color: silver
	flags: [scrollable all-over]
	version: 0.123
	identifier: "table-template"
	scroller: 			make map! 1
	index: 				make map! 2
	pos: 				make block! 1
	table-data: 		make block! 1
	default-row-index: 	make block! 1
	row-index: 			make block! 1
	default-col-index: 	make block! 1
	col-index: 			make block! 1
	full-height-col:	0
	on-border?:         0x0
	tbl-editor:			copy []
	
	marks: 				make block! 1
	anchor: 			make block! 1
	active:             make block! 1
	extra?:             #(false)
	extend?:            #(false)
	same-offset?:       #(false)
	dummy: 			copy 	""
	total: 			0x0

	frozen: 		0x0
	freeze-point: 	0x0

	current: 		0x0
	top:		 	0x0
	grid: 			0x0
	grid-size: 		0x0

	grid-offset: 	0x0
	last-page: 		0x0
	default-box: 	100x25
	box: 			100x25

	tolerance: 		20x5

	indices:       make map! 2
	filtered:      make map! 2
	frozen-cols:   make block! 20
	frozen-rows:   make block! 20

	draw-block:     make block! 1000
	filter-cmd:     make block! 10
	selected-data:  make block! 10000
	selected-range: make block! 10
	sizes:         	make map! 2
	sizes/x:       	make map! []
	sizes/y:       	make map! []
	frozen-nums:   	make map! 2
	frozen-nums/x: 	frozen-cols
	frozen-nums/y: 	frozen-rows

	col-type:  make map! 5

	colors:    make map! 100
	defaults:  make map! 10
	auto-col?: #(false)
	auto-row?: #(false)

	sheet?:    #(false)

	auto-y:    0
	auto-x:    0

	no-over: 	#(false)
	true-char:  #"^(2714)"
	false-char: #"^(274C)"

	names: make map! 10
	big-last: 		0
	big-length:     0
	big-size:       0
	prev-length: 	0
	prev-lengths: make block! 100

	virtual-rows: make map! 10
	virtual-cols: make map! 10

	digit: charset "0123456789"
	int: [some digit]
	ws: charset " ^-"
	
	starting?: yes
	scroller-width: 17
	usable-grid: 0x0
	max-grid: 0x0
	data-fit: make map! [x: #(none) y: #(none)]
		
	edit-mode?: #(false)
	vid-state: make map! 1
	change-state: 'before
	
	read-only-cols: []
	read-only-rows: []
	
	vid-overlays: #[]
	code-overlays: #[]

	overlay-config: make map! 10
	vid-lib: make map! 10
	code-lib: make map! 10
	vid-widgets: copy []		
	cell-state: []
	cells-selected: [] 
	vid-draw: make map! 10 []
	vid-renderer: make map! 10
	vid-targets: copy []
	freeform-vid: [ 'cell-button ] ;-- VID objects that allow freeform vid code entry within virtual-cols
	auto-incr: copy []
	col-names: copy []
	col-align: make map! 10
	user-get-cell-error: copy []
	cell-queue: make block! 50
	changed?: #(false)
	name: copy ""
	
	menu: [
		"Cell" [
			"Freeze"   			freeze-cell
			"Unfreeze" 			unfreeze-cell
			"Edit"     			edit-cell
			"Multi-line Edit  Shift+F2"   edit-cell-multi-line
		]
		"Row" [
			"Actions" [
				"Select"     select-row
				"Hide"       hide-row
				"Unhide"     unhide-row
				"Remove"     remove-row
				"Restore"    restore-row
				"Delete"     delete-row
				"Insert Data Row"  insert-row
				"Append Data Row"  append-row
				"Insert Virtual" insert-virtual-row
				"Append Virtual" append-virtual-row
			]
			"Freeze"         freeze-row
			"Unfreeze"       unfreeze-row
			"Default height" default-height
			"Move" [
				"Top"        move-row-top
				"Up"         move-row-up
				"Down"       move-row-down
				"Bottom"     move-row-bottom
				"By ..."     move-row-by
				"To ..."     move-row-to
			]
			"Find ..."       find-in-row
			"Data Access" [
				"Read-Only" set-row-read-only
				"Read-Write" set-row-read-write
			]			
		]
		"Column" [
			"Actions" [
				"Select"        			select-col
				"Default width" 			default-width
				"Full height"   			full-height
				"Hide"          			hide-col
				"Unhide"        			unhide-col
				;-- "Remove"        			remove-col	
				;-- "Restore"       			restore-col	;-- destroys virtual-cols
				"Delete"        			delete-col
				"Insert Data Column"  		insert-col
				"Append Data Column"       	append-col
				"__________________________"
				"Insert Virtual Column"		insert-virtual-col
				"Append Virtual Column"		append-virtual-col
				"__________________________"
				"Insert Pre-Built Column" 	insert-pre-built-col 
				"Append Pre-Built Column" 	append-pre-built-col
				
			]
			"Overlay" [
				"Apply Repeating VID" 			set-overlay-vid
				"Apply Repeating Code   Shift+F3" set-overlay-code
				"Edit Overlay                      Alt+F2" 		edit-overlay
				"Remove Overlay" 			remove-overlay
			]
			"Set Column Names" 	set-column-names			
			"Sort"   [
				"Loaded" [
					"Up"   sort-loaded-up
					"Down" sort-loaded-down
				]
				"Up"   sort-up
				"Down" sort-down
			]
		
			"Unsort"        unsort
			"Filter ..."    filter
			"Unfilter"      unfilter
			"Freeze"        freeze-col
			"Unfreeze"      unfreeze-col
			"Move" [
				"First"         move-col-first
				"Left"          move-col-left
				"Right"         move-col-right
				"Last"          move-col-last
				"By ..."        move-col-by
				"To ..."        move-col-to
			]
			"Find ..."      find-in-col
			"Edit ..."      edit-column
			"Type"   [ 
				"block!"   block!				
				"char!"    char!
				"date!"    date!
				"float!"   float!
				"image!"   image!				
				"integer!" integer!
				"logic!"   logic!
				"money!"   money!
				"percent!" percent!
				"string!"  string!
				"time!"    time!
				"tuple!"   tuple!
				"------"
				"Load"     load
				"Draw"     draw
				"Do"       do
				"Icon"     icon
			]
			"Alignment" [
				"Left"		set-align-left
				"Center"	set-align-center
				"Right"		set-align-right
			]
			"Data Access" [
				"Read-Only" set-col-read-only
				"Read-Write" set-col-read-write
			]
			"Default"  [
				"Value or Code"  set-default
				"Auto Increment" set-default-auto-incr
				"Remove" 		 remove-default
			]
		]
		"Table" [
			"Unhide"    [
				"All"    unhide-all
				"Row"    unhide-row
				"Column" unhide-col
			]
			"Default height" 	remove-full-height
			"Open ..."    		open-table
			"Open big ..." 		open-big
			"Save"        		save-table
			"Save as ..." 		save-table-as
			"Use state ..." 	use-state
			"Save state as ..." save-state
			"Clear color" 		clear-color
			"Select named range" []
			"Forget names" 		forget-names
			"Refresh View"		refresh-view
			"Information" [
				"Print Table Data"    print-data
				"Table Configuration" print-table-config
				"Print Code Overlays" print-code-overlays
				
			]
		]
		"Selection" [
			"Copy"      copy-selected
			"Cut"       cut-selected
			"Paste"     paste-selected
			;"Transpose" transpose
			"Color" [
				"Set Color" 	color-selected
				"Remove Color"  remove-color-selected
			]
			"Set Name"  name-selected
		]
	]
	actors: [
		
		do-safe-actor: function [ 
			cell [string!]
			act [word!]
		][
			if value? cw: to-word cell [ do-actor (get cw) none act ]
		]
	
		do-vid-click: function [] [
			do-actor -target-vid-object- none 'click
		]

		do-vid-down: function [ cell [string!]] [
			do-safe-actor cell 'down
		]

		
		toggle-check: function [ cell [string!]] [
			obj: get to-word cell
			obj/data: complement to-logic obj/data
			do-actor obj none 'change
		]
		
		set-vid-focus: function [ cell [string!]] [
			set-focus (get to-word cell)
		]
		
		toggle-vid-data: function [ cell [string!]] [
			data-path: to-path  reduce [ to-word cell 'data ] 
			set data-path complement to-logic (get data-path) 
		]
			
		is-within-view?: function [ 
			face [object! ]
			step [pair!]
		][
			abs-row: face/pos/y + face/current/y - face/frozen/y
			new-pos: min (abs-row + step/y) face/total/y
			in-view-pair: in-view face
			return either between? new-pos in-view-pair [
				true 
			][
				false
			]
		]

		in-view: function [ 
			face [object!] 
			"Returns a pair the indicates rows in view. Format: <row-star>x<row-end>"
		][ 
			start-row: face/current/y + 1
			return as-pair start-row ( start-row + face/usable-grid/y - 1 - (length? face/frozen-rows ))
		]		
		
		to-valid-key: function [ 
			key 
			flags
		][
			if not char? key [ return none ]
			if find charset [#" " - #"~"] key [
				if find flags 'shift [
					if fnd: system/words/select rejoin [ "`~1!2@3#4$5%6^^7&8*9(0)-_=+[{]}\|;:,<.>/?" {'"}]  key [
						return fnd
					]
				]
				return key
			]
		]
				
		on-create: func [face [object!] event [event! none!]][] ;-- placeholder to allow init changes
		on-resize: func [face [object!] event [event! none!]][] ;-- placeholder 
		on-resizing: func [face [object!] event [event! none!]][] ;-- placeholder to allow init changes
		
		set-border: function [face [object!] ofs [pair!] dim [word!]][
			ofs: ofs/:dim
			cum: 0     ;accumulator
			repeat i face/frozen/:dim [
				cum: cum + get-size face dim face/frozen-nums/:dim/:i
				if 2 >= absolute cum - ofs [return i]
			]
			cur: face/current/:dim
			fro: face/frozen/:dim
			repeat i face/grid/:dim [
				run: cur + i
				cum: cum + get-size face dim face/index/:dim/:run
				if 2 >= absolute cum - ofs [return fro + i]
			]
			0
		]

		on-border: function [face [object!] ofs [pair!]][
			border: 0x0
			border/x: set-border face ofs 'x
			border/y: set-border face ofs 'y
			either border = 0x0 [false][border]
		]

		set-usable: function [ 
			{Sets usable-grid and data-fit to reflect current table state. Includes frozen rows}
			face [ object! ]	
		][
			grid-size: face/size - face/scroller-width
			foreach dim [ x y ][
				sz: 0		
				repeat ndx face/frozen/:dim [	;-- collect frozen sizes first
					sz: to-integer (sz + get-size face dim face/index/:dim/:ndx)
				]
				cur: face/current/:dim
				i: k: 0 
				over-run: #(false)
				if 0 < steps: face/total/:dim - cur [
					repeat i steps [
						j: cur + i	
						sz: to-integer (sz + get-size face dim face/index/:dim/:j)
						if sz >= grid-size/:dim [
							over-run: #(true)
							either sz = grid-size/:dim [
								dta-fit: 'perfect
							][
								dta-fit: 'outside
								i: i - 1
							]
							break
						]
					]
				]
				face/data-fit/:dim: either over-run [ dta-fit ] [ 'inside ]
				face/usable-grid/:dim: i + face/frozen/:dim
			]
			
		]

		set-grid: function [face [object!]][
			foreach dim [x y][
				cur: face/current/:dim
				i: sz: 0
				if 0 < steps: face/total/:dim - cur [
					repeat i steps [
						j: cur + i
						sz: to-integer (sz + get-size face dim face/index/:dim/:j)
						if sz >= face/grid-size/:dim [
							face/grid-offset/:dim: sz - to-integer face/grid-size/:dim
							break
						]
					]
				]
				face/grid/:dim: i
			]
			set-usable face
			face/max-grid: max face/max-grid face/grid 
		]

		set-freeze-point: func [face [object!]][
			face/freeze-point: 0x0
			if face/frozen/y > 0 [face/freeze-point/y: face/draw/(face/frozen/y)/1/7/y]
			if face/frozen/x > 0 [face/freeze-point/x: face/draw/1/(face/frozen/x)/7/x]
			face/grid-size: face/size - face/freeze-point - face/scroller-width
			face/freeze-point
		]

		set-freeze-point2: func [face [object!] /local i][
			face/freeze-point: 0x0
			if face/frozen/y > 0 [
				repeat i face/frozen/y [
					face/freeze-point/y: face/freeze-point/y + get-size face 'y face/frozen-rows/:i
				]
			]
			if face/frozen/x > 0 [
				repeat i face/frozen/x [
					face/freeze-point/x: face/freeze-point/x + get-size face 'x face/frozen-cols/:i
				]
			]
			face/grid-size: face/size - face/freeze-point - face/scroller-width
			face/freeze-point
		]

		set-grid-offset: func [face [object!] /local end][
			end: get-cell-offset/end face face/frozen + face/grid
			face/grid-offset: end - face/size
		]

		get-header-height: function [ face [object!] ] [
			accum: 0
			foreach row face/frozen-rows [
				amt: either val: face/sizes/y/:row [ val ] [ face/default-box/y ]
				accum: accum + amt 
			]
			return accum
		]


		get-col-label: function [ face [object!] col [integer!] ][
			either fnd: find face/col-names col [
				return first back fnd
			][
				either (face/frozen-rows = [1])[
					lbl: copy face/table-data/1/:col
					return replace/all lbl "^/" " "
				][
					return none
				]
			]
		]		
		
		set-last-page: function [ face [object!] ][ ;-- get size of last page minus frozen rows
			pg-size: face/size - (to-pair reduce [ 0 (get-header-height face) ]) - face/scroller-width
			foreach dim [x y][
				t: face/total/:dim
				j: sz: 0
				while [
					all [
						r: face/index/:dim/(t - j)
						sz: sz + s: get-size face dim r
						sz <= pg-size/:dim 
					]
				][
					j: j + 1
				]
				face/last-page/:dim: j
			]
		]

		set-default-height: function [face [object!] event [event!]][
			dr: get-draw-row face event
			r:  get-data-row face dr
			if sz: face/sizes/y/:r [
				remove/key face/sizes/y r
				if dr <= face/frozen/y [
					df: face/box/y - sz
					face/freeze-point/y: to-integer face/freeze-point/y + df
				]
				fill face
				set-grid face
				show-marks face
			]
		]

		set-table-default-height: func [face [object!]][
			face/full-height-col: 0
			clear face/sizes/y
			face/freeze-point/y: to-integer face/box/y
			fill face
			set-grid face
			show-marks face
		]

		set-default-width: function [face [object!] event [event! none!]][
			dc: get-draw-col face event
			c:  get-data-col face dc
			if sz: face/sizes/x/:c [
				remove/key face/sizes/x c
				if dc <= face/frozen/x [
					df: face/box/x - sz
					face/freeze-point/x: face/freeze-point/x + df
				]
				fill face
				set-grid face
				show-marks face
			]
		]

		set-full-height: func [face [object!] event [event! none!] /local found][
			face/full-height-col: get-col-number face event
			fill face
			set-grid face
			adjust-scroller face
			show-marks face
			if found: find face/menu/"Column" "Full height" [change/part found ["Normal height" remove-full-height] 2]
		]

		remove-full-height: func [face [object!] /local found][
			set-table-default-height face
			if found: find face/menu/"Column" "Normal height" [change/part found ["Full height" full-height] 2]
		]

		set-default: function [face [object!] event [event! integer!] /auto-incr /delete ][
			col: get-col-number face event
			col-type: face/col-type/:col
			
			if delete [
				either face/defaults/:col [
					if find face/defaults/:col "auto-increment" [
						fnd-ndx: second find-in-array-at/with-index face/auto-incr 1 col
						remove (skip face/auto-incr fnd-ndx)
						remove find face/read-only-cols col 
					]
					remove/key face/defaults col	
					status-msg rejoin [ "Default value for Column " col " with the Heading " mold user-get-col-header face col  " has been removed."]
				][
					status-msg rejoin [ "There is NOT a default setting for column " col " with the Heading " mold user-get-col-header face col " . No action taken."]					
				]
				exit		
			] 
			if not col-type [
				request-message "Before setting a default value for a column it is suggested that you set the 'Column Type' using the Menu: 'Column/Type'"
				exit
			]
			
			msg: {To set the default value for this column: Enter a number, a QUOTED string or some Red code. To Delete the default, remove ALL content below and click "OK".}
			
			either auto-incr [
				if col-type <> 'integer! [
					request-message "The Column Type for this column needs to be set to integer before Auto Increment can be activated. Do this by selecting the Menu: 'Column/Type/Integer!'"
					exit
				]
				val: rejoin [ "auto-increment " mold face/table-data/1/:col " " col ]
				auto-increment/init face/table-data/1/:col col
				upsert face/read-only-cols col	
			][
				val: either val: face/defaults/:col [
					request-multiline-text/preload msg val 
				][
					request-multiline-text msg
				]	
			]
			if none? val [ exit ]
			either all [
				not auto-incr
				empty? val
			][
				if face/defaults/:col [
					remove/key face/defaults col	
					remove find face/read-only-cols col 
				]
				
				msg-add: ""
				if fnd: find-in-array-at/with-index face/auto-incr 1 col [
					remove (skip face/auto-incr (fnd/2 - 1))
					msg-add: " Along with the auto-increment settings."
				]
				status-msg rejoin [ "Default value for column " col " removed." msg-add ]				
			][
				face/defaults/:col: val
			]
		]
		
		set-access: function [
			{modifies access to row or col. Defaults to read-write}
			face [object!] 
			event [event! integer!]
			/col
			/row
			/read-only
		][
			either integer? event [
				col-num: row-num: event 
			][
				col-num: get-col-number face event
				row-num: get-row-number face event 	
			] 
			either read-only [
				if col [
					upsert face/read-only-cols col-num 
				]
				if row [
					upsert face/read-only-rows row-num
				]
			][
				if col [
					remove/part find face/read-only-cols col-num 1						
				]
				if row [
					remove/part find face/read-only-rows row-num 1						
				]
			]
		]
		
		set-cell-align: function [face [object!] cell [block!] col-num [integer!] p0 [pair!] p1 [pair!] ][
			cell/11/2: either align-type: face/col-align/:col-num [
				switch align-type [
					right [
						as-pair (p0/x + ( p1/x - p0/x - pick get-text-size to-string cell/11/3 1 )) (p0/y + 2 )
					]
					center [
						as-pair (p0/x + (( p1/x - p0/x - pick get-text-size to-string cell/11/3 1 ) / 2) ) (p0/y + 2)
					]
				]
			][
				4x2  +  p0 ;-- default cell-align = 'left
			]
		]

		; ACCESSING

		get-draw-address: function [face [object!] event [event! none!]][
			if all [
				col: get-draw-col face event
				row: get-draw-row face event
			][as-pair col row]
		]

		get-cell-offset: function [face [object!] cell [pair!] /start /end][
			if all [block? row: face/draw/(cell/y) s: row/(cell/x)] [
				case [
					start [s/6]
					end   [s/7]
					true  [copy/part at s 6 2]
				]
			]
		]

		get-draw-col: function [face [object!] event [event! none!]][
			if block? row: face/draw/1 [
				ofs: event/offset/x
				repeat i length? row [
					case [
						face/total/x < get-index face i 'x [break]
						row/:i/7/x > ofs [
							col: i
							break
						]
					]
				]
				col
			]
		]

		get-draw-row: function [face [object!] event [event! none!]][
			rows: face/draw
			row: face/total/y - face/current/y + face/frozen/y
			ofs: event/offset/y
			repeat i row [
				if rows/:i/1/7/y > ofs [row: i break] ; box's end/y is greater than mouse's offset/y
			]
			row
		]

		get-col-number: function [face [object!] event [event! none!]][
			col: get-draw-col face event
			get-data-col face col
		]

		get-row-number: function [face [object!] event [event! none!]][
			row: get-draw-row face event
			get-data-row face row
		]

		get-data-address: function [
			face [object!] 
			event [event! pair!]
			/both {include draw-address as well}
		][
			cell: either event? event [cell: get-draw-address face event][event]
			out: get-logic-address face cell
			return either both [
				reduce [ out cell ]
			][
				out	
			]
			
		]

		get-logic-address: func [face [object!] draw-cell [pair! none!]][
			if none? draw-cell [ return none! ]
			as-pair get-data-col face draw-cell/x  get-data-row face draw-cell/y
		]

		get-data-col: function [face [object!] draw-col [integer!]][
			either draw-col <= face/frozen/x [
				face/frozen-cols/:draw-col
			][
				face/col-index/(draw-col - face/frozen/x + face/current/x)
			]
		]

		get-data-row: function [face [object!] draw-row [integer!]][
			either draw-row <= face/frozen/y [
				face/frozen-rows/:draw-row
			][
				face/row-index/(draw-row - face/frozen/y + face/current/y)
			]
		]

		get-data-index: func [face [object!] num [integer!] "Draw-index" dim [word!] "Dimension: ['x | 'y]"][
			either dim = 'x [get-data-col face num][get-data-row face num]
		]

		get-index-address: func [face [object!] draw-cell [pair!]][
			as-pair get-index-col face draw-cell/x  get-index-row face draw-cell/y
		]

		get-index: func [face [object!] num [integer!] "Draw-index" dim [word!] "Dimension: ['x | 'y]"][
			either dim = 'x [get-index-col face num][get-index-row face num]
		]

		get-index-col: function [face [object!] draw-col [integer!]][
			either draw-col <= face/frozen/x [
				index? find face/col-index face/frozen-cols/:draw-col
			][
				draw-col - face/frozen/x + face/current/x
			]
		]

		get-index-row: function [face [object!] draw-row [integer!]][
			either draw-row <= face/frozen/y [
				index? find face/row-index face/frozen-rows/:draw-row
			][
				draw-row - face/frozen/y + face/current/y
			]
		]

		get-size: func [face [object!] dim [word!] idx [integer!]][
			to-integer any [face/sizes/:dim/:idx face/box/:dim]
		]
		
		get-color: func [face [object!] row [integer!] col [integer!] frozen? [logic!]][
			virt?: negative? pick face/col-index ( col + face/current/x )
			case [
				frozen? [
					either virt? [221.206.206][ silver ]
				] 
				odd? row [
					either virt? [ 238.230.230 ][ white ]
				] 
				'else [
					either virt? [ 230.222.222 ] [ snow ]
				]
			]
		]
		

		; INITIATION

		init-data: func [face [object!] spec [pair!] /local row][
			face/table-data: make block! spec/y
			loop spec/y [
				row: make block! spec/x
				loop spec/x [append row none ]
				append/only face/table-data row
			]
		]

		set-table-template-data: func [face [object!] spec [file! url! block! pair! none!] /local row][
			switch type?/word spec [
				file!  [
					face/table-data: switch/default suffix? spec [
						%.csv [load-csv read spec]
						%.red [at load spec 3]
					][load spec]
				]
				url!   [face/table-data: either face/options/delimiter [
					load-csv/with read-thru spec face/options/delimiter
				][
					load-csv read-thru spec
				]]
				block! [face/table-data: spec]
				pair!  [
					face/total: spec
					init-data face face/total
				]
				none! [
					face/total: to-pair face/size / face/box
					init-data face face/total
				]
			]
		]

		init-grid: func [face [object!] /only][
			face/total/y: length? face/table-data
			face/total/x: length? any [ first face/table-data [] ]
			if face/options/auto-col [face/total/x: face/total/x + 1]
			if face/options/auto-row [face/total/y: face/total/y + 1]
			face/grid-size: face/size - face/scroller-width
			clear face/sizes/x
			clear face/sizes/y
			clear face/frozen-rows
			clear face/frozen-cols
			clear face/read-only-cols
			clear face/read-only-rows
		]
		
		clear-table-state: function [ face [object!]][
		    clear face/frozen-rows
		    clear face/frozen-cols
		    face/top: 0x1
		    face/current: 0x1
		    clear face/sizes/x
		    clear face/sizes/y
		    face/box: 100x25
		    clear face/row-index 
		    clear face/col-index
		    face/auto-col?: #(false)
		    face/auto-row?: #(false)
		    clear face/col-type
		    clear face/cells-selected
		    face/anchor: 1x1
		    face/active: 1x1
		    clear face/names

		    clear face/read-only-rows
		    clear face/read-only-cols
		    clear face/auto-incr
		    clear face/col-names
			
			clear face/filtered/x
			clear face/filtered/y
			
			clear face/default-row-index
			clear face/vid-state
			clear face/vid-overlays
			clear face/code-overlays
			clear face/auto-incr
			clear face/virtual-cols
			clear face/defaults
			clear face/col-align
			clear face/vid-targets 
			clear face/colors
		]

		init-indices: func [face [object!] /only /local i][
			;Prepare indices
			face/indices/x: make map! min 10 face/total/x                         ;Room for index for each column
			face/indices/y: make map! min 10 face/total/y                         ;Room for index for some rows     @@ May be on request?
			either face/default-row-index <> [] [
				clear-table-state face 
			][
				face/filtered/y:
					copy face/row-index:                                         ;Active row-index
					copy face/default-row-index: make block! face/total/y        ;Room for row numbers
			]
			either face/default-col-index <> [] [
				clear face/filtered/x
				clear face/col-index
				clear face/default-col-index
			][
				face/filtered/x:
					copy face/col-index:
					copy face/default-col-index: make block! face/total/x ;Active col-index and room for col numbers
			]
			face/auto-x: make integer! face/auto-col?: to-logic face/options/auto-col
			face/auto-y: make integer! face/auto-row?: to-logic face/options/auto-row
			repeat i face/total/y [append face/default-row-index i - face/auto-y]   ;Default is just simple sequence in initial order
			if face/auto-col? [
				face/indices/x/0: copy face/default-row-index                  ;Default is for first (auto-col) column
			]
			repeat i face/total/x [append face/default-col-index i - face/auto-x]
			if face/auto-row? [
				face/indices/y/0: copy face/default-col-index                  ;Default is for first (auto-row) row
			]
			either only [
				clear face/row-index
				clear face/col-index
			][
				append clear face/row-index face/default-row-index               ;Set default as active index
				append clear face/col-index face/default-col-index
			]
			face/index/x: face/col-index
			face/index/y: face/row-index

			unless only [
				set-last-page face
				adjust-scroller face
			]
			set-vid-lib face
			set-vid-draw face
			set-code-lib face
			set-vid-renderer face 
			 
			face/vid-widgets: collect [ foreach [k v] face/vid-lib [ keep k ] ]
			make-overlay-config face
		]

		init-fill: function [face [object!] /only ][
			clear face/draw-block
			repeat i face/grid/y [
				row: make block! face/grid/x
				repeat j face/grid/x  [
					s: (as-pair j i) - 1 * face/box
					text: form case [
						all [face/auto-col? j = 1] [either face/sheet? or not face/auto-row? [i][i - 1]]
						all [face/auto-row? i = 1] [either face/sheet? or not face/auto-col? [j][j - 1]]
						true [any [face/table-data/:i/(face/col-index/:j) face/dummy]]
					]
					;Cell structure
					cell: make block! 11    ;each column has the following 11 elements
					color: pick [white snow] odd? i
					repend cell [
						'line-width 1
						'fill-pen color
						'box s s + face/box
						'clip s + 1 s + face/box - 1
						reduce [
							'text s + 4x2  text
						]
					]
					append/only row cell
				]
				append/only face/draw-block row
			]
			face/draw: face/draw-block
			;Initialize marks
			face/marks: insert tail face/draw [pen 0.0.255 line-width 2.8 fill-pen 0.0.0.220]
			unless only [
				mark-active face 1x1
				set-grid-offset face
			]
		]

		init: func [
			{V2}
			face [object!]
			/with block-data [block!]
		][
			if with [
				data: face/table-data: block-data
				clear-table-state face  
			]
			face/freeze-point: face/frozen: face/top: face/current: 0x0
			face/cells-selected: copy []
			face/scroller/x/position: face/scroller/y/position: 1
			if not empty? face/table-data [
				init-grid face
				init-indices face
				init-fill face
			]
		]

		; FILLING

		fix-cell-outside: func [face [object!] cell [block!] dim [word!]][
			cell/6/:dim: cell/7/:dim: cell/9/:dim: cell/10/:dim: cell/11/2/:dim: to-integer face/size/:dim
			remove/part skip cell 11 length? cell 
		]

		get-row-height: function [ face [object!] data-y [integer!] frozen-y? [logic!]][
			either all [
				face/full-height-col > 0
				not frozen-y?
				not face/sizes/y/:data-y
			][
				d: form any [face/table-data/:data-y/(face/full-height-col) face/dummy]
				n: 0 parse d [any [lf (n: n + 1) | skip]]
				either n > 0 [face/sizes/y/:data-y: n + 1 * 16][get-size face 'y data-y]
			][
				get-size face 'y data-y
			]
		]

		get-icon: function [lib name /type typ][
			base: https://raw.githubusercontent.com/google/material-design-icons/master/png/
			mi-lib: ""
			either typ [mi-lib: copy typ if typ = "outline" [append mi-lib "d"]][typ: "baseline"]
			load to-url rejoin [base lib "/" name "/materialicons" mi-lib "/24dp/1x/" typ "_" name "_black_24dp.png"]
		]

		fill-cell: function [
			face    [object! ]
			cell    [block!  ]
			data-y  [integer!]
			index-y [integer!]
			index-x [integer!]
			draw-y  [integer!]
			draw-x  [integer!]
			frozen? [logic!  ]
			p0      [pair!   ]
			p1      [pair!   ]
			/extern col-num row-num 
		][

			if index-x <= face/total/x [
				data-x: face/col-index/:index-x
				if face/code-overlays/:data-x [
					if data-y > to-valid-integer get-max face/frozen-rows [
						do-code-overlay face data-x data-y
					]
				]
			]
			either index-x <= face/total/x [
				data-x: face/col-index/:index-x
				cell/4:  any [
					face/colors/(as-pair data-x data-y)
					get-color face draw-y draw-x frozen?
				]
				cell/9:  (cell/6: p0) + 1
				cell/10: (cell/7: p1) - 1
				type: face/col-type/:data-x ; Check whether it is set
				either frozen? [
					cell/11/1: 'text
					cell/11/2:  4x2  +  p0
					cell/11/3: form case [
						all [data-y > 0 data-x > 0][any [face/table-data/:data-y/:data-x face/dummy]]
						data-x = 0 [either face/sheet? [index-y][data-y]]
						data-y = 0 [either face/sheet? [index-x][data-x]]
						all [v: face/virtual-rows/:data-y v: v/data/:data-x] [form v]
						all [v: face/virtual-cols/:data-x v: v/data/:data-y] [form v]
						true [face/dummy]
					]
					set-cell-align face cell data-x p0 p1
					
					if any [ face/vid-overlays/:data-x face/code-overlays/:data-x ] [
						remove/part skip cell 11 100 
						append cell compose/only [
							pen 221.221.0
							line-width 2 
							line (as-pair (p0/x + 2) 2) (as-pair (p1/x - 2) 2) 
							pen black
						]
					]					
					
				][
					switch/default type [; AND whether it is specific
						draw [
							cell/11/1: 'translate
							cell/11/2: cell/9       ; Start of cell
							cell/11/3: copy/deep face/table-data/:data-y/:data-x ; draw-block
						]
						image! [
							switch type?/word face/table-data/:data-y/:data-x [
								word! image! [
									cell/11/1: 'image
									cell/11/2: face/table-data/:data-y/:data-x
									cell/11/3: cell/9
								]
								file! url! [
									cell/11/1: 'image
									cell/11/2: load face/table-data/:data-y/:data-x
									cell/11/3: cell/9
								]
							]
						]
						icon [
							either all [
								1 < length? ico-data: split face/table-data/:data-y/:data-x #"/"
								image? ico: get-icon/type ico-data/1 ico-data/2 ico-data/3
							][
								cell/11/1: 'image
								cell/11/2: ico
								cell/11/3: cell/9
							][
								cell/11/1: 'text
								cell/11/2: cell/9
								cell/11/3: face/dummy
							]
						]
					][	;-- default for switch
						case [
							face/vid-overlays/:data-x [
								either draw-vid: face/vid-draw/( to-word face/vid-overlays/:data-x/id) [
									do bind drawing: load mold/only draw-vid 'p0
								][
									cell/11/1: 'text
									cell/11/2: cell/9
									cell/11/3: face/dummy							
								]
							]
							true [
								cell/11/1: 'text
								cell/11/2:  4x2  +  p0	;-- default left-align
								cell/11/3: form case [
									all [data-y > 0 data-x > 0][
										switch/default type [
											do [
												do face/table-data/:data-y/:data-x
											]
											logic! [
												form face/table-data/:data-y/:data-x
											]
										][
											any [face/table-data/:data-y/:data-x face/dummy]
										]
									]
									data-x = 0 [either face/sheet? [index-y][data-y]]
									data-y = 0 [either face/sheet? [index-x][data-x]]
									true [
										cell/4: get-color face draw-y draw-x frozen?
										case [
											all [v: face/virtual-rows/:data-y v: v/data/:data-x] [
												form v
											]
											all [v: face/virtual-cols/:data-x (not v/type = "vid-repeating") v: v/data/:data-y ]	[
													form v
												]
											all [v: face/virtual-cols/:data-x v/type = "vid-repeating" ] [
												either data-y = 1 [
													v/data/:data-y
												][
													"" ;-- return empty string because VID object will display here 
												]
											]
											true [face/dummy]
										]
									]
								]
								set-cell-align face cell data-x p0 p1
							]
						]
					]
				]
			][
				fix-cell-outside face cell 'x
			]
		]

		do-cell-queue: function [ face ] [
			foreach [ draw-row draw-col action value col-num ] face/cell-queue [
				cell: face/draw/(draw-row)/(draw-col)
				either action = 'color [
					cell/4: value
				][
					cell/11/3: to-valid-string value
				]
				set-cell-align face cell col-num cell/6 cell/7
			]	
		]
		
		do-code-overlay: function [
			face
			data-x 
			data-y
			/extern 
				row-num col-num table-obj
				set-this-cell set-cell-color ;-- NOT used on VID Overlays
				set-cell set-cells 
				get-cell get-cells get-this-cell get-this-row get-col-header
				get-table-data set-table-data  
				first-row? last-row? mid-row? 
				total-this-col 
		][
			
			if is-filtered? face [ exit ]
			if find face/frozen-rows data-y [ exit ] ;-- ignore frozen rows
			col-num: data-x
			row-num: data-y
			
			set-cell-color: func [ 
				{Change color of current cell. ONLY available in the Code Overlay context. Operates on both Data and Virtual cells}
				color-val [tuple!]
			] compose [	user-set-cell/color face col-num row-num color-val ]

			set-this-cell: function [
				{Sets the value of the current cell. ONLY available in the Code Overlay context. Operates on both Data and Virtual columns}
				val
			] compose [ user-set-cell face col-num row-num val ]
							
			
			set-cell: function [
				{Sets the value of the current cell. ONLY available in the Code Overlay context. Operates on both Data and Virtual columns}
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
				val [any-type!]
				/refresh
			] compose [ user-set-cell/:refresh table-obj col-id row-num val ]

			set-cells: function [
				{Modify the table data. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				val [any-type!] {The data for the single cell or a block if setting an entire row}
				/row {Will modify an entire row, datatypes must match row}
				/refresh {refresh the view after data modified} 
			] compose [ table-obj/actors/set-data/:row/:refresh table-obj col-id row-id val ]
			
			get-cell: function [
				{Returns the value of the column given. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells}
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
			] compose [ get-data table-obj col-id row-num ]

			get-cells: function [
				{Returns the table data at the specified column and row. Only available in the Code and VID Overlay context. Will not work with Virtual Columns}
			    col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
			    row-id [integer!] {The row number that displays visually in the table}
			    /row {returns entire row of data}
			    /rel {Returns cell data using a relative position. Exclusive of /next-row /prev-row}  
			    	rel-col [integer!] 
			    	rel-row [integer!]
			    /next-row {returns the next row of data relative to row-id}
			    /prev-row {returns the previous row of data relative to row-id}
			    /extern face
			][
			    apply :get-data [
			        face col-id row-id
			        /row row
			        /rel rel 
			        	rel-col rel-row
			        /next-row next-row
			        /prev-row prev-row
			    ]
			]

			get-this-cell: function [
				{Returns the value of the current Data cell. ONLY available in the Code Overlay context. Operates ONLY on Data cells}
			] compose [ user-get-cell table-obj col-num row-num ]
				
			get-this-row: function [
				{Returns the value of the entire current row. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells}
			] compose [ get-row table-obj row-num ]

			get-col-header: function [
				{Returns the value of a given column header}
				col-id [integer!]
			] compose [ 
				user-get-col-header table-obj col-id
			]			
			
			get-table-data: function [
				{Returns the table data at the col and row given. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				/row {Will return an entire row of data as a block} 				
			] compose [
				table-obj/actors/get-data/:row table-obj col-id row-id 
			]

			set-table-data: function [ ;-- deprecated, use set-cells instead for consistency
				{Modify the table data. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				val [any-type!] {The data for the single cell or a block if setting an entire row}
				/row {Will modify an entire row, datatypes must match row}
				/refresh {refresh the view after data modified} 
			] compose [ table-obj/actors/set-data/:row/:refresh table-obj col-id row-id val ]			
			
			first-row?: function [
				{Returns TRUE if the current row is the FIRST data row past the header row. Only available and useful in the Code and VID Overlay context} 
				/extern face row-num
			][
				return either (first skip face/row-index face/frozen/y ) = row-num [ true ][ false ]
			]

			last-row?: function [
				{Returns TRUE if the current row is the LAST data row. Only available and useful in the Code and VID Overlay context} 				
				/extern face row-num
			] [
				return either (last face/row-index) = row-num [ true ][ false ]
			]
			
			total-this-col: function [
				/extern face row-num col-num
			][
				if last-row? [
					middle: copy/part at face/row-index 2 (length? face/row-index ) - 2
					total: 0 
					foreach row-ndx middle [
						total: total + face/table-data/:row-ndx/:col-num 
					]
					set-this-cell total
					set-cell-color yellow
				]				
			]
		
			mid-row?: function [
				{Returns TRUE if the current row NOT a first or last row. Only available and useful in the Code and VID Overlay context} 								
				/extern face row-num 
			][
				return either any [
					(first skip face/row-index face/frozen/y ) = row-num
					(last face/row-index) = row-num 					
				][
					false
				][
					true 
				]
			]	
			
			if error? err: try/all [
                do bind load/all (copy face/code-overlays/:data-x/code) face/actors
                true ;-- makes try happy
            ][ 
                status-msg [ newline "********** code-overlay ERROR on column number:" col-num " row number:" row-num "***************************************************************" ]
                status-msg "********** -START overlay script- ******************************************************************" 
                status-msg face/code-overlays/:data-x/code 
            	status-msg [ "********** -END overlay script- ********************************************************************" newline ]
                status-msg err
                status-msg [ "*****************************************************************************************************" newline ]
            ]
		]

		set-vid-overlay-context: function [
			{Sets functions available in a VID Overlay Context}
			face
			data-x
			data-y
			/extern 
				row-num col-num table-obj
				set-cell set-cells 
				get-cell get-cells get-this-cell get-this-row get-col-header
				get-table-data set-table-data  
				first-row? last-row? mid-row? 
		][
			col-num: data-x
			row-num: data-y

			set-cell: function [
				{Sets the value of the current cell. ONLY available in the Code Overlay context. Operates on both Data and Virtual columns}
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
				val [any-type!]
				/refresh
			] compose [ user-set-cell/:refresh table-obj col-id row-num val ]

			set-cells: function [
				{Modify the table data. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				val [any-type!] {The data for the single cell or a block if setting an entire row}
				/row {Will modify an entire row, datatypes must match row}
				/refresh {refresh the view after data modified} 
			] compose [ table-obj/actors/set-data/:row/:refresh table-obj col-id row-id val ]
			
			get-cell: function [
				{Returns the value of the column given. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells}
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
			;-- ] compose [ user-get-cell table-obj col-id row-num ]
			] compose [ get-data table-obj col-id row-num ]

			get-cells: function [
				{Returns the table data at the specified column and row. Only available in the Code and VID Overlay context. Will not work with Virtual Columns}
			    col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
			    row-id [integer!] {The row number that displays visually in the table}
			    /row {returns entire row of data}
			    /rel {Returns cell data using a relative position. Exclusive of /next-row /prev-row}  
			    	rel-col [integer!] 
			    	rel-row [integer!]
			    /next-row {returns the next row of data relative to row-id}
			    /prev-row {returns the previous row of data relative to row-id}
			    /extern face
			][
			    apply :get-data [
			        face col-id row-id
			        /row row
			        /rel rel 
			        	rel-col rel-row
			        /next-row next-row
			        /prev-row prev-row
			    ]
			]

			get-this-cell: function [
				{Returns the value of the current Data cell. ONLY available in the Code Overlay context. Operates ONLY on Data cells}
			] compose [ user-get-cell table-obj col-num row-num ]
				
			get-this-row: function [
				{Returns the value of the entire current row. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells}
			] compose [ get-row table-obj row-num ]

			get-col-header: function [
				{Returns the value of a given column header}
				col-id [integer!]
			] compose [ 
				user-get-col-header table-obj col-id
			]			
			
			get-table-data: function [
				{Returns the table data at the col and row given. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				/row {Will return an entire row of data as a block} 				
			] compose [
				table-obj/actors/get-data/:row table-obj col-id row-id 
			]

			set-table-data: function [ ;-- deprecated, use set-cells instead for consistency
				{Modify the table data. ONLY available in the Code and VID Overlay context. Operates ONLY on Data cells} 
				col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name} 
				row-id [integer!] 
				val [any-type!] {The data for the single cell or a block if setting an entire row}
				/row {Will modify an entire row, datatypes must match row}
				/refresh {refresh the view after data modified} 
			] compose [ table-obj/actors/set-data/:row/:refresh table-obj col-id row-id val ]			
			
			first-row?: function [
				{Returns TRUE if the current row is the FIRST data row past the header row. Only available and useful in the Code and VID Overlay context} 
				/extern face row-num
			][
				return either (first skip face/row-index face/frozen/y ) = row-num [ true ][ false ]
			]

			last-row?: function [
				{Returns TRUE if the current row is the LAST data row. Only available and useful in the Code and VID Overlay context} 				
				/extern face row-num
			] [
				return either (last face/row-index) = row-num [ true ][ false ]
			]
		
			mid-row?: function [
				{Returns TRUE if the current row NOT a first or last row. Only available and useful in the Code and VID Overlay context} 								
				/extern face row-num 
			][
				return either any [
					(first skip face/row-index face/frozen/y ) = row-num
					(last face/row-index) = row-num 					
				][
					false
				][
					true 
				]
			]					
		] ;-- ******************  END set-vid-overlay-context *******************************************************************************		
		
		user-get-col-header: func [
			{Returns the value of a given column header}
			face [object!]
			col [integer!]
		][
			get-data-at face col 1 
		]
		
		get-data-at: func [
			face [object!]
			col [integer!]
			row [integer!]
		][
			either col < 0 [
				get-virt-data-at face col row 
			][
				face/table-data/:row/:col 	
			]
		]
		
		get-virt-data-at: func [
			face [object!]
			col [integer!]
			row [integer!]
		][
			face/virtual-cols/:col/data/:row
		]
		
		
		user-set-cell: function [
			{Sets data and virtual cells. When setting virtual the setting is queued to be run later by 'do-cell-queue}
			face [object!]
			col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
			row-id [integer!]
			val [any-type!]
			/color {uses 'val as tuple value}
			/refresh {refresh view after data has been set}
		][
			draw-clue-ndx: draw-len: ((length? face/draw) - 2) ;-- Will be 'box when initial draw is done.
			
			virt-col?: #(false)
			raw-col-id: col-id
			col-id: col-id-to-num face col-id "user-set-cell"
			either virt-col?: negative? col-id [
				col-ndx: negate col-id 
			][
				col-ndx: index? find face/col-index col-id
			]
			data-row: pick face/row-index row-id
			
			if (draw-row: data-row - face/current/y + (length? face/frozen-rows)) < 1 [ exit ] 
			
			if all [ ;-- check for draw-row beyond the draw block size
				face/draw/:draw-clue-ndx = 'box ;-- Inital draw has been completed
				draw-row > (draw-clue-ndx - 7)
			][ 
				exit
			]
			draw-col: col-ndx - face/current/x + (length? face/frozen-cols)
			
			cell: attempt [ face/draw/:draw-row/:draw-col ]
			if color [
				real-draw-row: (index? find face/row-index row-id) - face/current/y + 1
				append face/cell-queue reduce [ real-draw-row draw-col 'color val draw-col ]
				exit
			]
			either virt-col? [
				append face/cell-queue reduce [ row-id (negate col-id) 'value val (negate col-id) ]
			][
				set-data/:refresh/index face col-id row-id val 	
			]
		]

		col-id-to-num: function [ 
			{returns the true column number of the col-id indicated. Virtual cols are negative values}
			face [object!] 
			col-id [integer! string!] 
			caller-id [string!]
		][
			if string? col-id [
				either face/col-names = [][
					if (face/user-get-cell-error =  new-err: reduce [ col-id ]) [ exit ]
					face/user-get-cell-error: new-err 
					request-message rejoin [ {The "} caller-id {" function needs column names to be defined.^/Please use the Menu: "Column/Set Column Names" to define the columns. Once this is done you can use the "} caller-id {" function.}]
					return none
				][
					if not col-id: system/words/select face/col-names col-id [
						request-message rejoin [ {The } mold caller-id { function was unable to find the column named: } mold col-id {. The column name may need to be set using the Menu: "Column/Set Column Names".} ]
						return none
					]
				]			
			]
			either positive? col-id [
				return col-id	
			][
				either fnd: find face/col-index col-id [
					return first fnd
				][
					request-message rejoin [ {The } mold caller-id { function was unable to find the column named: } mold col-id {. The column name may need to be set using the Menu: "Column/Set Column Names".} ]
					return none
				]
			]		
			
		]
	
		col-name-to-num: function [ face [object!] name [string!] caller-id [string!]][
			either face/col-names = [][
				if (face/user-get-cell-error =  new-err: reduce [ name ]) [ exit ]
				face/user-get-cell-error: new-err 
				request-message rejoin [ {The "} caller-id {" function needs column names to be defined.^/Please use the Menu: "Column/Set Column Names" to define the columns. Once this is done you can use the "} caller-id {" function.}]
				return none
			][
				if not col-num: system/words/select face/col-names name [
					request-message rejoin [ {The } mold caller-id { function was unable to find the column named: } mold name {. The column name may need to be set using the Menu: "Column/Set Column Names".} ]
					return none
				]
			]			
			return col-num
		]
		
		clear-data: function [ 
			{Clears specified data from the table}
			face [object!]
			col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
			row-id [integer!]
			/row {Clear entire row, ignores col-id}
			/refresh {refresh view after data has been modified}
		][
			either row [
				clear-row: copy []
				loop (length? face/table-data/1)[append/only clear-row "" ]
				set-data/row face col-id row-id clear-row
			][
				set-data face col-id row-id ""
			]
			if refresh [ face/actors/refresh-view face ]
		]
		
		append-data-row: function [ 
			{Appends a row of data at the end of existing data}
			face [object!]
			val [block!] {block of values that matches the row of data}
			/refresh {refresh view after data has been modified}
		][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before adding a row of data."
				exit
			]
			append-row face
			set-data/row/:refresh/index face 0 (last face/row-index) val
		]
		
		insert-data-row: function [ 
			{Inserts a row of data at the row specified}
			face [object!]
			row-id [integer!]
			val [any-type!]
			/refresh {refresh view after data has been modified}
		][
			insert-row face row-id
			set-data/row/:refresh face 0 row-id val
		]

		set-data: function [ 
			{sets table data and refreshes table display. By default uses visible/drawn row and column NOT data index numbers}
			face [object!]
			col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
			row-id [integer!] {The data row number}
			val [any-type!]
			/row {'val block contains full row of pre-formatted data}
			/refresh {refresh view after data has been modified}
			/index {col-id and row-id are the data index position. If col-id is a string! then it resolves accordingly}
		][
			either index [
				row-ndx: row-id
			][
				row-ndx: get-data-row face row-id 
				
			]
			either row [
				face/table-data/:row-ndx: val
			][
				either string? col-id [
					if not col-id: col-name-to-num face col-id "set-data" [ exit ]
				][
					if not index [
						col-id: get-data-col face col-id 
					]
				]
				face/user-get-cell-error: copy []
				either col-type: face/col-type/:col-id [
					col-type: to-string col-type
					remove back tail col-type
				][
					col-type: "string"
				]
				face/table-data/:row-ndx/:col-id: cast-to-datatype col-type val
			]
			if refresh [ refresh-view face ]
			trigger-on-changed face
		]
		
		load-table-data: function [ table-filename [file!] ][
			return load/as table-filename 'redbin
		]

		request-table: function [
			face [object!] {table-template object}
			message [string!]
			table-id [object! string!]
			col-list [block!] {Series of column numbers to include in table}
			/size req-size
			/offset offset-val
			/full {return full data and index}
		][ 
			req-blk: copy []
			if string? table-id [
				table-name: copy table-id			
				table-id: [ table-data: ""]
				table-id/table-data: get-data-from/all-data table-name 0 
			]
			foreach row (skip table-id/table-data 1)[
				row-collect: copy []
				foreach col-num col-list [
					append row-collect trim (to-valid-string pick row col-num)	
				]
				append row-collect pick row 1
				append/only req-blk ( copy row-collect)	
			]
			rq-size: either size [ req-size ] [ 300x200 ]
			set [ req-blk select-blk ] array-to-text-table req-blk
			either offset [
				req-res: request-list-enhanced/fixed-font/size/offset message req-blk rq-size offset-val
			][
				req-res: request-list-enhanced/fixed-font/size message req-blk rq-size
			] 
			if req-res [
				req-res: find-in-array-at select-blk 1 req-res 
				if not full [ req-res: last req-res ] 
				return req-res
			]
			return none
		]
		
		
		get-data-from: function [
			{returns a row of data from another table}
			table-name [string!] {Name of a current VID table-template object or name of a .redtbl file}
			id [integer!] {the id number to return. If 0 then the header row}
			/all-data {return the entire table-data}
		][
			
			either all [
				value? (tbl-wrd: to-word table-name)
				object? (obj: get tbl-wrd)
			][
				tbl-data: get in obj 'table-data	;-- VID table object
				if tbl-data = [] [	;-- empty object means the data hasn't been loaded for this face yet
					redbin: load-table-data (to-file rejoin [ table-name ".redtbl"])
					set to-path reduce [ (to-word table-name ) 'table-data ] tbl-data: redbin/table-data 
				]				
			][
				set (to-word table-name) load-table-data (to-file rejoin [ table-name ".redtbl"])
				tbl-data: get to-path reduce [ to-word table-name 'table-data ]				
			]
			
			return either all-data [
				tbl-data
			][
				either id = 0 [
					tbl-data/1
				][
					find-in-array-at tbl-data 1 id 		
				]
				
			]
		]
		
		get-data: function [ 
			{Returns the specific data from a table}
			face [object!] {table object}
			col-id [integer! string!] {A col-id of string! will attempt to match a currently configured column name}
			row-id [integer!] {The row number that displays visually in the table}
			/row {returns entire row of data}
			/rel {Returns cell data using a relative position. Exclusive of /next-row /prev-row} 
				rel-col [integer!]
				rel-row [integer!]
			/next-row {returns the next rows data relative to row-id}
			/prev-row {returns the previous rows data relative to row-id}
		][
			either rel [orig-rel: true ][ rel-col: rel-row: 0 ]
			orig-col-id: col-id
			orig-row-id: row-id
			if next-row [ 
				rel-row: +1
				rel-col: 0
				orig-rel: false
				rel: true
			]
			if prev-row [
				rel-row: -1
				rel-col: 0
				orig-rel: false
				rel: true
			]
			if string? col-id [
				if not col-id: col-name-to-num face col-id "set-data" [ exit ]
			]			
			either row-ndx: find face/row-index row-id [
				row-skip: ( (index? row-ndx) + rel-row - 1)	
			][
				row-skip: row-id
				row-id: none
			]
			
			either col-ndx: find face/col-index col-id [
				col-skip: ( (index? col-ndx) + rel-col - 1)	
			][
				col-skip: col-id
				col-id: none
			]			
			if any [
				row-skip < 0
				row-skip > (length? face/row-index)
			][
				row-id: none
			]
			if any [
				col-skip < 0
				col-skip > (length? face/col-index)
			][
				orig-col-id: col-id
				col-id: none
			]
			;row-id: first skip face/row-index ( (index? find face/row-index row-id) + rel-row - 1)
			;col-id: first skip face/col-index ( (index? find face/col-index col-id) + rel-col - 1)
			refinements: copy ""
			if not row-id [
				refinements: collect [
			        if row [keep "/row"  ]
			        if next-row [keep "/next-row" ]
			        if prev-row [keep "/prev-row" ]
			        if orig-rel [
			        	keep "/rel" 
			        	keep rel-col
			        	keep rel-row
			        ]
			    ]
				status-msg rejoin [ 
					"***************** ERROR WITH THE 'get-data' FUNCTION ***********************" 	newline
					"*** row number of: " row-skip " is not contained within the row-index" 		newline
					"*** called with: col-id = " mold orig-col-id " row-id = " mold orig-row-id 	newline
					"*** refinements: " refinements 												newline
					"********************************************************************************"  newline
				]
				;cause-error 'validation 'out-of-range [row-id length? face/row-index]
				return none
			]
			row-id: first skip face/row-index row-skip
						
			if not col-id [
				refinements: collect [
			        if row [keep "/row"  ]
			        if next-row [keep "/next-row" ]
			        if prev-row [keep "/prev-row" ]
			        if orig-rel [
			        	keep "/rel" 
			        	keep rel-col
			        	keep rel-row
			        ]
			    ]				
				status-msg rejoin [ 
					"***************** ERROR WITH THE 'get-data' FUNCTION ***********************" 	newline
					"*** invalid col-id provided. col-id = " col-skip 								newline
					"*** called with: col-id = " mold orig-col-id " row-id = " mold orig-row-id 	newline
					"*** refinements: " refinements 												newline
					"********************************************************************************"  newline
				]
				
				return none
			]
			col-id: first skip face/col-index col-skip
			
			either row [
				return face/table-data/:row-id
			][
				face/user-get-cell-error: copy []
				either col-type: face/col-type/:col-id [
					col-type: to-string col-type
					remove back tail col-type
				][
					col-type: "string"
				]
				return cast-to-datatype col-type face/table-data/:row-id/:col-id
			]
		]
		
		user-get-cell: func [ 
			face [object!]
			col [integer! string!]
			row [integer!]
		][
			if string? col [
				either face/col-names = [][
					if (face/user-get-cell-error =  new-err: reduce [ col ]) [ exit ]
					face/user-get-cell-error: new-err 
					request-message {The "get-cell" function needs column names to be defined.^/Please use the Menu: "Column/Set Column Names" to define the columns. Once this is done you can use the "get-cell" function.}
					exit
				][
					if not col: system/words/select face/col-names col [
						col: none	
					]
				]
			]
			face/user-get-cell-error: copy []
			either col-type: face/col-type/:col [
				col-type: to-string col-type
				remove back tail col-type
			][
				col-type: "string"
			]
			return either col [
				cast-to-datatype col-type face/table-data/:row/:col 			
			][
				cast-to-datatype col-type ""
			]
		]
		
		set-column-names: function [ 
			face [object!]
			/only {resequence the col-names only}
		][
			field-block: copy []	
			foreach col-num face/col-index [
				either col-num > 0 [
					if not face/table-data/1/:col-num  [
						request-message rejoin [ "Column number: " col-num " does not contain a header value. Please enter a header value before setting the column names." ]
						exit
					]
					append/only field-block reduce [ col-num face/table-data/1/:col-num ]
				][
					if not face/virtual-cols/:col-num/data/1 [
						request-message rejoin [ "Virtual Column number: " col-num " does not contain a header value. Please enter a header value before setting the column names." ]
						exit
					]
					append/only field-block reduce [ col-num face/virtual-cols/:col-num/data/1 ]
				]
			]
			
			input-block: either face/col-names = [] [
				to-kebab-names copy/deep field-block
			][
				collect [
					foreach entry field-block [
						col-num: entry/1
						col-header: entry/2
						either fnd: find face/col-names col-num [
							keep to-valid-string pick face/col-names ((index? fnd) - 1)
						][
							keep to-kebab-names reduce [ entry ]
						]
					]
				]
			]
			if only [ 
				old-names: copy face/col-names
				clear face/col-names
				foreach blk field-block [
					if find old-names blk/1 [
						append face/col-names reduce [ 
							pick old-names ((index? (find old-names blk/1)) - 1)
							blk/1
						]
					]
				]
				exit 
			]
			if req-res: request-col-names "Enter the PERMANENT column name for each column" field-block input-block [
				face/col-names: collect [
					fb-len: length? field-block
					repeat index fb-len [
						keep reduce [  req-res/:index field-block/:index/1 ]
					]
				]
			]
			trigger-on-changed face
		]
		
		find-tab-index: function [ data	needle][
			repeat i (length? data) [
				if ((skip data/:i 2) = needle) [ return i ]
			]
			return none
		]
			
		set-code-lib: function [ face [object!]][
			face/code-lib: make map! 10
			face/code-lib/cell-New-Code-Overlay: make object! [	
				id: "cell-New-Code-Overlay"
			    code: {}
			]					
			face/code-lib/cell-code-example: make object! [	
				id: "cell-code-example"
			    code: {if row-num = 2 [ ^/^-print "--------------------------------------------------------------------------------------"^/^-print [ "Code Example at Column Heading:" mold get-col-header col-num  ]^/^-print   "Right Click on the column and select the Menu: Column/Overlay/Edit Overaly (Alt + F2)," ^/^-print   "to edit this example code." ^/^-print "--------------------------------------------------------------------------------------"^/^-set-cell-color green ^/^-set-this-cell rejoin  [  "COL (" col-num ") ROW (" row-num ")"]^/^-print [ ">>get-cell 2" newline "==" get-cell 2 ]^/^-print [ {>>get-cell "id"} newline "==" get-cell "id" ]^/]}
			]			
			face/code-lib/cells-to-red-yellow-green: make object! [	
				id: "cells-to-red-yellow-green"
			    code: {int: to-valid-integer get-this-cell^/case [ ^/^-int < 25 [ set-cell-color green ]^/^-all [ int >= 25 int <= 50 ] [ set-cell-color yellow ]^/^-int > 50 [ set-cell-color red ]^/]}
			    datatype: "integer"
			]
		]

		set-vid-renderer: function [ 
			face [object!]
			;- variables available to vid-renderer context
			;- ------------------------------------------------
			;-           data-addr = data address pair!
			;- 		  draw-addr    = draw address pair!
			;- -target-vid-object- = name of object created. Used for manipulation after rendering
			;-        vid-obj-data = data of the vid object
			;-          -vid-code- = code needed for virtual col cell ONLY
			;- --------------------------------------------
			;- target index  description
			;-        -----  -----------
			;-          1		top left corner
			;-          2		size
			;-          3		un-rendered? / starts as true 	
			;-          4		renderer name
			;- 	     5      data address 
			;- 	     6      draw address 
			;- --------------------------------------------
			
		][

			;-- START data-request-date *******************************************************************************
			face/vid-renderer/data-request-date: [
				render: [
					style data-request-date: button "..." 80x20 
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr
						]
						extra [ 
							data-addr: 0x0
							draw-addr: 0x0
						]
						on-click [
							if result: request-date [
								table-obj/actors/set-data/refresh/index table-obj face/extra/data-addr/x face/extra/data-addr/y result
							]
						]
						
					at (as-pair (target/1/x + target/2/x - 24) (target/1/y + 3 ) ) 
						-target-vid-object-: data-request-date 19x18 "..."
						
						extra [ 
							tab-key-to-key-down: #(true)
							data-addr: 0x0
							draw-addr: 0x0
						]
				]
				restore: [
					vid-obj-data: to-valid-integer table-obj/table-data/(data-addr/y)/(data-addr/x)
				]
			]	
			;-- END data-request-date ******************************************************************************* 
			
			
			;-- START DATA-TABLE-LINK *******************************************************************************
			face/vid-renderer/data-table-link: [
				render: [
					style data-table-link: button "..." 80x20 ;-- 94x22
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr
							if value? 'table-stack-tab-panel [
								face/menu: compose/deep [
							    	"Goto Linked Table"  goto-linked-table
									"Goto Linked Row"	 goto-linked-row
								]					    
							]
							set 'data-table-link-menu function [ face event ][
								switch event/picked [
									goto-linked-table [ 
										link-detail: load table-obj/vid-overlays/(face/extra/data-addr/x)/code/1 
										either value? 'table-stack-tab-panel [
											if fnd: face/parent/actors/find-tab-index table-stack-tab-panel/data link-detail/data/1 [
												table-stack-tab-panel/selected: fnd
											]
										][
											face/parent/actors/status-msg "This feature is only available from within table-stack"
										]
									]
									goto-linked-row [
										link-detail: load table-obj/vid-overlays/(face/extra/data-addr/x)/code/1
										dta: face/parent/table-data/(face/extra/data-addr/y)/(face/extra/data-addr/x)
									]
								]
							]		
						]
						extra [ 
							data-addr: 0x0
							draw-addr: 0x0
						]
						on-menu [data-table-link-menu face event]
						on-click [
							vid-code-blk: load table-obj/vid-overlays/(face/extra/data-addr/x)/code/1
							if result: table-obj/actors/request-table table-obj vid-code-blk/data/2 vid-code-blk/data/1 vid-code-blk/data/3 [
								table-obj/actors/set-data/index/refresh table-obj face/extra/data-addr/x face/extra/data-addr/y result
							]
						]
						
					at (as-pair (target/1/x + target/2/x - 24) (target/1/y + 3 ) ) 
						-target-vid-object-: data-table-link 19x18 "..."
						
						extra [ 
							tab-key-to-key-down: #(true)
							data-addr: 0x0
							draw-addr: 0x0
						]
				]
				restore: [
					vid-obj-data: to-valid-integer table-obj/table-data/(data-addr/y)/(data-addr/x)
				]
			]	
			;-- END DATA-TABLE-LINK ******************************************************************************* 		
			
			face/vid-renderer/data-drop-list: [
				render: [
					style data-drop-list: drop-list 94x24
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr
							either all [ 
								table-obj/table-data/(data-addr/y)/(data-addr/x)
								fnd: find face/data table-obj/table-data/(data-addr/y)/(data-addr/x) 
							][
								face/selected: index? fnd 
							][
								face/selected: 0
							]
							
							face/menu: compose/deep [
							    "Drop Down List"
								    [	
								    	"Update List from Column Data"  repop-drop-list
										"Edit List" 				    manual-drop-list
								    ]
							]					    
							set 'data-drop-list-menu function [ face event ][
								switch event/picked [
									manual-drop-list [ 
										table-obj/actors/edit-drop-list-data face event 
									]
									repop-drop-list [
										table-obj/actors/repop-drop-list-data face event 
									]
								]
							]		
						]
						extra [ 
							tab-key-to-key-down: #(true)
							disable-wheel: true
							roll-back: 0 
							data-addr: 0x0
							draw-addr: 0x0
						]
						on-menu [data-drop-list-menu face event]
						on-change [
							either face/extra/roll-back = 0 [
								data-addr: face/extra/data-addr
								table-obj/actors/update-vid-cell table-obj to-string pick face/data face/selected face/extra/data-addr face/extra/draw-addr
							][
								face/selected: face/selected + face/extra/roll-back
								face/extra/roll-back: 0		
							]
						]
						on-down [
							table-obj/actors/mark-active table-obj face/extra/draw-addr
							set-focus face
							return 'done
						]

						on-key-down [
							if any [
								event/key = 'left 
								event/key = 'right
								event/key = #"^-" 
							][	
								either event/key = 'left [ face/extra/roll-back: 1 ] [ face/extra/roll-back: -1]
								set-focus table-obj
								if event/key = #"^-" [
									dir: either find event/flags 'shift [ 'left ] [ 'right ]
									table-obj/actors/hot-keys/feed table-obj #(none) dir
									return 'done 
								]
								return event
							]
							if 	event/key <> #"^M" [ return 'done ]
							set-focus table-obj
							return event
						]
					at (target/1 + 3x0 ) -target-vid-object-: data-drop-list (target/2 + -6x-2 )
						data [(vid-obj-data)]
						extra [ 
							tab-key-to-key-down: #(true)
							roll-back: 0 
							data-addr: 0x0
							draw-addr: 0x0
							disable-wheel: true
						]
				]
				restore: [
					overlay-code: load table-obj/vid-overlays/(data-addr/x)/code/1
					vid-obj-data: copy overlay-code/data
				]
			]
			
			face/vid-renderer/data-checkbox-for-logic: [
				render: [
					style data-checkbox-for-logic: check 94x21 "true"
						extra [ 
							data-addr: 0x0 
							draw-addr: 0x0
						]
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr							
							face/data: to-valid-logic table-obj/table-data/(data-addr/y)/(data-addr/x)
							face/text: form face/data
						] 
						on-change [
							face/text: form face/data
							table-obj/actors/update-vid-cell table-obj to-valid-logic face/data face/extra/data-addr face/extra/draw-addr
						]
						on-down [ 
							table-obj/actors/mark-active table-obj face/extra/draw-addr
							set-focus face
							return 'done							
						]
					at (target/1 + 7x2 ) -target-vid-object-: data-checkbox-for-logic (vid-obj-data) (as-pair (target/2/x + -11) 20)
						extra [ 
							data-addr: 0x0 
							draw-addr: 0x0
						]
				]
				restore: [
					vid-obj-data: to-valid-logic table-obj/table-data/(data-addr/y)/(data-addr/x)
				]
			]
				
			face/vid-renderer/cell-checkbox-for-row-selection: [
				render: [
					style cell-checkbox-for-row-selection: check 94x21 "true"
						extra [ 
							data-addr: 0x0 
							draw-addr: 0x0
						]
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr							
							either find table-obj/vid-state vid-name: to-lit-word rejoin [ "cell" face/extra/data-addr ][
								face/data: table-obj/vid-state/:vid-name 
								face/text: form to-valid-logic face/data
							][
								face/data: false
								face/text: "false"
							]
							face/menu: compose/deep [
							    "Set Checkmarks"
								    [	
								    	"All (Filtered) On"  select-checks-all
								    	"All (Filtered) Off" deselect-checks-all
								    	"Every Row On"		 select-checks-every
								    	"Every Row Off" 	 deselect-checks-every
								    ]
								"Selected Rows" 
									[
										"Export to Clipboard" export-checks-to-clip
									]
							]
							cell-check-menu: function [ face event ] [
								switch event/picked [
									select-checks-all      	[table-obj/actors/set-checkmarks/set-all face event none ]
									deselect-checks-all    	[table-obj/actors/set-checkmarks/set-all/off face event none ]
									select-checks-every		[table-obj/actors/set-checkmarks/set-all/every face event none ]
									deselect-checks-every 	[table-obj/actors/set-checkmarks/set-all/off/every face event none ]
									export-checks-to-clip	[table-obj/actors/export-checks-to-clip face event ]
								]
							]														
						] 
						on-menu [cell-check-menu face event]						
						on-change [
							vid-name: to-lit-word rejoin [ "cell" face/extra/data-addr ]
							put table-obj/vid-state vid-name face/data 
							face/text: form face/data
							table-obj/actors/update-vid-cell table-obj to-valid-logic face/data face/extra/data-addr face/extra/draw-addr
						]
						on-down [ 
							table-obj/actors/mark-active table-obj face/extra/draw-addr
							set-focus face
							return 'done							
						]
					at (target/1 + 7x2 ) -target-vid-object-: cell-checkbox-for-row-selection (vid-obj-data) (as-pair (target/2/x + -11) 20)
				]
				restore: [
					vid-obj-data: to-valid-logic table-obj/table-data/(data-addr/y)/(data-addr/x)
				]
			]
			
			face/vid-renderer/cell-button: [
				render: [
					style cell-button: button 90x21 left "cell-button" font-name "Segoe UI" font-size 9
						extra [ 
							data-addr: 0x0 
							draw-addr: 0x0
						]
						on-created [
							face/extra/data-addr: data-addr
							face/extra/draw-addr: draw-addr
							face/text: rejoin [ "  " face/text ]
						]	
						on-down [ 
							table-obj/actors/mark-active table-obj face/extra/draw-addr
							set-focus face
							return 'done							
						]																
					at (target/1 + 5x2 ) -target-vid-object-: (bind load/all -vid-code- table-obj/actors) (as-pair (target/2/x + -11) 21)
					
				]
				restore: [
					-vid-code-: table-obj/virtual-cols/(data-addr/x)/code/2/1
				]
			]								
			
		]


		set-vid-draw: function [ 
			face [object!]
		][
			face/vid-draw: make map! 10
			
			;- Available Variables in draw context
			;-------------------------------------
			;- face   = table-obj
			;- cell   = existing cell drawing
			;- p0     = top-left   ie: 200x25
			;- p1     = btm-right  ie: 300x50
			;- data-y = row num
			;- data-x = col num 

			face/vid-draw/data-drop-list: [
				cell/6: (p0 + 3x0)
				cell/7: (p1 + -3x-2)
				cell/11/1: 'text
				cell/11/2: p0 + 7x3
				cell/11/3: (form face/table-data/:data-y/:data-x)

				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				
				append cell compose/deep [
					;-- green bars
					line-width 1
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 2) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					
					;-- drop-down decor
					pen black
					fill-pen gray
					line-width 0.75								
					line (as-pair (p1/x - 15) (p0/y + 9))  (as-pair (p1/x - 11) (p0/y + 13 ))
					line (as-pair (p1/x - 11) (p0/y + 13))   (as-pair (p1/x - 7) (p0/y + 9) )
					
					;-- full cell box
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]

			face/vid-draw/data-request-date: [  ;-- copied from 'data-table-link
				cell/4: 255.255.255.0
				cell/6: (p0 + 3x1)
				cell/7: (p1 + -3x-2)				
				cell/11/1: 'text
				cell/11/2: p0 + 7x4
				cell/11/3: (form face/table-data/:data-y/:data-x)				

				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				
				append cell compose/deep [
					;-- green bars
					;-- ----------
					line-width 1
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 3) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					
					;-- data-request-date decor
					;-- -----------------
					pen black
					line-width .2
					fill-pen white
					box (as-pair (p1/x - 24) (p0/y + 3)) (as-point2D (p1/x + -5.75 ) ( p0/y + 20.5  )) 3
					line-width .9
					circle (as-pair (p1/x - 18) (p0/y + 16) ) .2
					circle (as-pair (p1/x - 15) (p0/y + 16) ) .2
					circle (as-pair (p1/x - 12) (p0/y + 16) ) .2
					
					;-- full cell outline
					;-- -----------------
					pen black
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]

			
			face/vid-draw/data-table-link: [  ;-- copied from 'cell-button
				cell/4: 255.255.255.0
				cell/6: (p0 + 3x1)
				cell/7: (p1 + -3x-2)				
				cell/11/1: 'text
				cell/11/2: p0 + 7x4
				link-data-blk: load face/vid-overlays/:data-x/code/1
				
				link-data: copy ""
				if all [
					face/table-data/:data-y/:data-x 
					face/table-data/:data-y/:data-x > 0 
				][
					if df: face/actors/get-data-from link-data-blk/data/1 face/table-data/:data-y/:data-x [
						link-data: collect [foreach i link-data-blk/data/3 [ keep pick df i ]]	
					]					
				]
				cell/11/3: (rejoin [ form link-data " (#" form face/table-data/:data-y/:data-x ")" ] )				

				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				
				append cell compose/deep [
					;-- green bars
					;-- ----------
					line-width 1
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 3) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					
					;-- data-table-link decor
					;-- -----------------
					pen black
					line-width .2
					fill-pen white
					box (as-pair (p1/x - 24) (p0/y + 3)) (as-point2D (p1/x + -5.75 ) ( p0/y + 20.5  )) 3
					line-width .9
					circle (as-pair (p1/x - 18) (p0/y + 16) ) .2
					circle (as-pair (p1/x - 15) (p0/y + 16) ) .2
					circle (as-pair (p1/x - 12) (p0/y + 16) ) .2
					
					;-- full cell outline
					;-- -----------------
					pen black
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]
			
			
			face/vid-draw/cell-button: [
				cell/4: 255.255.255.0
				cell/6: (p0 + 3x1)
				cell/7: (p1 + -3x-2)				
				cell/11/1: 'text
				cell/11/2: p0 + 7x4
				cell/11/3: rejoin [ " " (select load face/virtual-cols/(data-x)/code/2/1 'cell-button) ]

				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				
				append cell compose/deep [
					;-- green bars
					;-- ----------
					line-width 1
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 3) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					
					;-- cell-button decor
					;-- -----------------
					pen black
					line-width .2
					fill-pen 255.255.255.255
					box (p0 + 6x2 ) (as-pair (p1/x + -6) ( p0/y + 23  )) 3
					
					;-- full cell outline
					;-- -----------------
					pen black
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]
			
			face/vid-draw/data-checkbox-for-logic: [
				cell/6: (p0 + 3x0)
				cell/7: (p1 + -3x-2)
				cell/11/1: 'text
				cell/11/2: p0 + 23x3
				cell/11/3: (form to-valid-logic face/table-data/:data-y/:data-x)				
				either (form face/table-data/:data-y/:data-x) = "true" [
					box-clr: [ fill-pen 0.95.184 ]
					check-mrk: compose/deep [
						pen 255.255.255
						line-width .75
						line (p0 + 11x12) (p0 + 13x14)
						line (p0 + 13x14) (p0 + 17x10)
					]

				][
					box-clr: [ fill-pen 240.240.240 ]
					check-mrk: []
				]
				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				append cell compose/deep [
					;-- green bars
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 2) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					pen black

					;-- VID "check" decor
					line-width .6
					(box-clr)
					;-- box (p0 + 8x6) (p0 + 19x17 ) 2
					pen 0.95.184
					box (p0 + 8x6) (p0 + 19x18 ) 2
					(check-mrk)
					pen black
					
					;-- full cell box
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]
			
			face/vid-draw/cell-checkbox-for-row-selection: [
				cell/6: (p0 + 3x0)
				cell/7: (p1 + -3x-2)
				cell/11/1: 'text
				cell/11/2: p0 + 23x3
				(cell-name: to-lit-word	rejoin [ "cell" data-x "x" data-y ])
				cell/11/3: (form to-valid-logic face/vid-state/:cell-name)				
				either face/vid-state/:cell-name [
					box-clr: [ fill-pen 0.95.184 ]
					check-mrk: compose/deep [
						pen 255.255.255
						line-width .75
						line (p0 + 11x12) (p0 + 13x14)
						line (p0 + 13x14) (p0 + 17x10)
					]

				][
					box-clr: [ fill-pen 240.240.240 ]
					check-mrk: []
				]
				remove/part (skip cell 11) length? cell ;-- clean out rest of cell drawing
				append cell compose/deep [
					;-- green bars
					fill-pen 77.153.0
					pen 0.255.0
					box (p0 + 1x1 ) (as-pair (p0/x + 2) (p1/y - 1) )		
					box ( as-pair (p1/x - 3) (p0/y + 1)) (p1 + -1x-1)
					pen black

					;-- VID "check" decor
					line-width .6
					(box-clr)
					pen 0.95.184
					box (p0 + 8x6) (p0 + 19x18 ) 2
					(check-mrk)
					pen black
					
					;-- full cell box
					fill-pen 255.255.255.255
					box (p0) (p1)
				]
			]			
		]

		set-vid-lib: function [ face [object!]][
			face/vid-lib: make map! 10
			;-- these items will eventually be loaded from a file
			face/vid-lib/data-drop-list: make object! [	
				id: "data-drop-list"
			    code:  [ {data-drop-list data ["apple" "banana" "carrot"]} ]
			    on-F4: {
					do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
					table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'data-addr
					set-focus -target-vid-object-
			    }
			    when-applied: {setup-data-drop-list}
			    on-edit: {status-msg rejoin [ "To edit the VID Overlay at column " table-obj/active/x " , right click on any of the drop-down lists."] }
			    datatype: "string"
			]
			face/vid-lib/cell-checkbox-for-row-selection: make object! [	
				id: "cell-checkbox-for-row-selection"
			    code: [{cell-checkbox-for-row-selection}]
			    on-F4: {
					do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
					table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'data-addr
					-target-vid-object-/data: complement to-valid-logic -target-vid-object-/data
					do-actor -target-vid-object- none 'change			    
			    }
			    on-sort: "logic-to-sortable"
			    when-applied: {setup-cell-checkbox-for-row-selection}
			    on-edit: {status-msg rejoin [ "To modify the VID Overlay checkboxes at column " table-obj/active/x ", use the built in menus by right clicking on any checkbox."] }
			    datatype: "logic"
			]
						
			face/vid-lib/cell-button: make object! [	
				id: "cell-button"
			    code: [{cell-button}]
			    on-F4: {
			    	do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
			    	table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'addr
			    	do-actor -target-vid-object- none 'click
			    }
			]
			
			face/vid-lib/data-request-date: make object! [	
				id: "data-request-date"
			    code:  [ {data-request-date data []} ]
			    when-applied: {setup-data-request-date}
			    on-F4: {
			    	do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
			    	table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'addr
			    	do-actor -target-vid-object- none 'click
			    }
			    datatype: "date"
				on-edit: {status-msg rejoin [ "There are NO editable components for the VID Overlay at column " face/active/x ] }			    			    
			]
						
			face/vid-lib/data-table-link: make object! [	
				id: "data-table-link"
			    code:  [ {data-table-link data []} ]
			    when-applied: {setup-data-table-link}
			    on-F4: {
			    	do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
			    	table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'addr
			    	do-actor -target-vid-object- none 'click
			    }
			    datatype: "integer"
			]			
			
			face/vid-lib/data-checkbox-for-logic: make object! [	
				id: "data-checkbox-for-logic"
			    code: [{data-checkbox-for-logic}]
			    on-F4: {
					do bind load/all mold/only table-obj/vid-renderer/(target/4)/restore face
					table-obj/pane: layout/only new-lay: compose/deep bind load/all mold/only table-obj/vid-renderer/(target/4)/render 'addr
					-target-vid-object-/data: complement to-valid-logic -target-vid-object-/data
					do-actor -target-vid-object- none 'change
			    }
			    when-applied: {setup-data-checkbox-for-logic}
			    on-sort: "logic-to-sortable"
				on-edit: {status-msg rejoin [ "There are NO editable components for the VID Overlay at column " face/active/x ] }			    
			    datatype: "logic"
			]												
		]

		add-code-cell: function [
			face    [object! ]	
			data-x  [integer!]
			data-y  [integer!]
			pos		[pair!   ]
		][
			code-listing: collect [ 
				foreach item (keys-of face/code-lib) [
					keep to-string item 
				]
			]
			either req-res: request-list "Select a Code Overlay" code-listing [
				code-conf: face/code-lib/(to-get-word req-res)
			][
				exit
			]
			face/code-overlays/(data-x): code-conf 
		]
		
		get-at-key-or-less: function [
			{return the map item at the key location or one that is less}
			map
			key [integer!]
			/only {return key integer only}
		][
			keys: keys-of map 
			while [not find keys key] [
				key: key - 1
			]
			if only [ return key]
			return map/:key
		]

		add-cell: function [
			face    [object! ]
			row     [block!  ]
			data-y  [integer!]
			index-y [integer!]
			index-x [integer!]
			draw-y  [integer!]
			draw-x  [integer!]
			frozen? [logic!  ]
			p0      [pair!   ]
			p1      [pair!   ]
			/extern row-num col-num this-cell
		][
			data-x: face/col-index/:index-x
			if index-x <= face/total/x [
				if face/code-overlays/:data-x [
					if data-y > to-valid-integer get-max face/frozen-rows [
						do-code-overlay face data-x data-y
					]
				]
			]
						
			either frozen? [
				text: form case [
					data-x = 0 [either face/sheet? [index-y][data-y]]
					data-y = 0 [either face/sheet? [index-x][data-x]]
					data-x < 0 [face/virtual-cols/:data-x/data/:data-y ]
					true [any [face/table-data/:data-y/:data-x face/dummy]]
				]
				
				cell: compose/only [
					line-width 1
					fill-pen (get-color face draw-y draw-x frozen?)
					box (p0) (p1)
					clip (p0 + 1) (p1 - 1)
					(reduce ['text p0 + 4x2 text])
				]
				set-cell-align face cell data-x p0 p1
				if any [ face/vid-overlays/:data-x face/code-overlays/:data-x ] [
					append cell compose/only [
						pen 221.221.0
						line-width 2 
						line (as-pair (p0/x + 2) 2) (as-pair (p1/x - 2) 2) 
						pen black
					]
				]
				insert/only at row draw-x cell
			][
				case [
					draw?: all [t: face/col-type/:data-x t = 'draw][
						drawing: any [face/table-data/:data-y/:data-x copy []]
					]
					all [t: face/col-type/:data-x t = 'do][
						text: form either face/table-data/:data-y/:data-x [do face/table-data/:data-y/:data-x][face/dummy]
					]
					all [t: face/col-type/:data-x t = 'logic!][
						text: form face/table-data/:data-y/:data-x 
					]
					true [
						text: form case [
							data-x = 0 [either face/sheet? [index-y][data-y]]
							data-y = 0 [either face/sheet? [index-x][data-x]]
							all [v: face/virtual-cols/:data-x v/type = "vid-repeating" ] [
								;add-vid-cell face data-x data-y p0
								either all [ frozen? data-y = 1 ][
									v/data/:data-y									
								][
									face/dummy ;-- return dummy because VID object will display here 	
								]
							]	
							all [v: face/virtual-cols/:data-x v/type <> "vid-repeating" ] [
								form v/data/:data-y
							]													
							true [any [face/table-data/:data-y/:data-x face/dummy]]
						]
					]
				]
				cell: compose/only [
					line-width 1
					fill-pen (get-color face draw-y draw-x frozen?)
					box (p0) (p1)
					clip (p0 + 1) (p1 - 1)
					(reduce case [
						draw? [['translate  p0 + 1x1  drawing]]
						true  [['text       p0 + 4x2  text   ]]
					])
				]
				
				if vid-overlay?: face/vid-overlays/:data-x [
					if draw-vid: face/vid-draw/( to-word face/vid-overlays/:data-x/id) [
						do bind load mold/only draw-vid 'p0
					]
				]
				
				if not vid-overlay? [
					set-cell-align face cell data-x p0 p1 
					if clr: face/colors/(as-pair data-x data-y) [ cell/4: clr ]
				]
				insert/only at row draw-x cell
			]
		]

		set-table-cell: function [
			face    [object! ]
			row     [block!  ]
			data-y  [integer!]
			index-y [integer!]
			index-x [integer!]
			grid-y  [integer!]
			grid-x  [integer!]
			frozen? [logic!  ]
			px0     [integer!]
			py0     [integer!]
			py1     [integer!]
		][
			sx: get-size face 'x face/col-index/:index-x
			px1: px0 + sx
			p0: as-pair px0 py0
			p1: as-pair px1 py1

			data-col: face/col-index/:index-x
			data-row: face/row-index/:index-y
			
			if all [ 
				overlay: face/vid-overlays/:data-col
				not frozen?
			][
				sy: get-size face 'y data-y
				data-row: face/row-index/:index-y
				append/only face/vid-targets reduce [ p0 as-pair sx sy #(true) to-lit-word overlay/id as-pair data-col data-row as-pair grid-x ( grid-y + 1 ) ]
			]
			
			either block? cell: row/:grid-x [
				fill-cell face cell data-y index-y index-x grid-y grid-x frozen? p0 p1
			][
				if index-x <= face/total/x [
					add-cell face row data-y index-y index-x grid-y grid-x frozen? p0 p1
				]
			]
			px1
		]

		set-table-cells: function [
			face     [object! ]
			grid-row [block!  ] "Draw row minus frozen"
			data-y   [integer!] "Data row number"
			index-y  [integer!] "Index row number"
			grid-y   [integer!] "Draw row number minus frozen"
			frozen?  [logic!  ]
			py0      [integer!] "Row offset start"
			py1      [integer!] "Row offset end"
		][
			
			px0: to-integer face/freeze-point/x
			grid-x: 0
			
			while [px0 < face/size/x][
				;prin [ "   > grid-x = " grid-x  " " mold px0]
				grid-x: grid-x + 1
				index-x: face/current/x + grid-x
				either index-x <= face/total/x [
					px0: to-integer set-table-cell face grid-row data-y index-y index-x grid-y grid-x frozen? px0 py0 py1
					face/grid/x: grid-x
				][
					cell: grid-row/:grid-x
					either all [block? cell cell/6/x < face/size/x] [
						fix-cell-outside face cell 'x
					][break]
				]
			]
			cell: grid-row/(grid-x + 1)
			if all [block? cell cell/6/x < face/size/x] [
				fix-cell-outside face cell 'x
			]
		]

		set-checkmarks: function [ 
			{VID cell-checkbox-for-row-selection object support}
			face [object!] {This is a VID face. face/parent = table-obj}
			event [event! integer!]
			row-list [block! none!]
			/set-all 
			/every {action against everything}
			/off
		][
			addr: face/extra/data-addr
			tbl-obj: face/parent
			if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
			rows: either every [ tbl-obj/default-row-index ][tbl-obj/row-index ]
			if set-all [
				foreach i rows [
					if not find tbl-obj/frozen-rows i [
						cell-name: to-lit-word rejoin [ "cell" addr/x "x" i ]
						tbl-obj/vid-state/:cell-name: either off [#(false) ] [#(true)]
					]
				]					
			]
			tbl-obj/actors/fill tbl-obj  
		]
		
		get-row: function [ 
			{Return the full data row}
			face [object!]
			row-num [integer!]
		][
			row-data: pick face/table-data row-num
			row-collect: copy []
			foreach c face/col-index [
				if c > 0 [
					append/only row-collect (pick row-data c)
				]	
			]
			return row-collect
		]
		
		get-checked-rows: function [
			{Returns rows of data that have been checked off by the 'cell-checkbox-for-row-selection' overlay}
			face [object!]	
			col-id [integer! string!]
			/only {returns row indices only}
			/header {include the header row}
		][
			col-id
			if not checked-rows: get-checked-indices face col-id [ exit ]
			checked-rows: sort checked-rows
			if only [ return checked-rows ]
			results: either header [
				copy reduce [ (get-row face 1) ]
			][
				copy []
			]
			foreach row checked-rows [
				append/only results get-row face row
			]
			return results
		]
		
		export-checks-to-clip: function [ 
			face [object!] {This is a VID Object/ not the table}
			event [event!]
		][
			results: get-checked-rows face/parent face/extra/data-addr/x 
			write-clipboard mold results 
		]
		
		repop-drop-list-data: function [ 
			face [object!] ;-- face here is a vid object
			event [event!]]
		[	
			tbl-obj: face/parent
			col: face/extra/data-addr/x
			if find keys-of tbl-obj/vid-overlays col [
				-vid-code-: load tbl-obj/vid-overlays/:col/code/1 
				-vid-code-/data: copy get-column-data tbl-obj col
				tbl-obj/vid-overlays/:col/code: reduce [ mold/only -vid-code- ]
				tbl-obj/actors/fill tbl-obj				
			]
		]
		
		edit-drop-list-data: function [ 
			face [object!] ;-- face here is the vid object
			event [event!]
			/extern table-obj
		][	
			tbl-obj: face/parent
			col: face/extra/data-addr/x
			if find keys-of table-obj/vid-overlays col [ 
				-vid-code-: load tbl-obj/vid-overlays/:col/code/1 
				data-block: -vid-code-/data 
				if req-res: request-array rejoin [ "Setting drop-list items for column " col ] data-block [
					-vid-code-/data: req-res
					tbl-obj/vid-overlays/:col/code: reduce [ mold/only -vid-code- ]
					tbl-obj/actors/fill tbl-obj
				]
			]
		]

		fill: function [
			face [object!] 
			/only dim [word!]
			/extern table-obj "Make table-obj globally available" 
		][
			recycle/off
			system/view/auto-sync?: off
			face/vid-targets: copy []
			clear face/cell-queue
			py0: 0
			draw-y: 0
			index-y: 0
			while [all [py0 < face/size/y index-y < face/total/y]][
				draw-y: draw-y + 1            ; Skim through draw rows; which number?
				frozen?: draw-y <= face/frozen/y   			; Is it frozen?
				index-y: get-index-row face draw-y 			; Corresponding index row
				data-y: get-data-row face draw-y   			; Corresponding data row
				draw-row: face/draw/:draw-y   				; Actual draw-row
				unless block? draw-row [      				; Add new row if missing
					insert/only at face/draw draw-y draw-row: copy [] ; Make an empty row
					face/marks: next face/marks    ; Move marks-pointer further by one (new row before it)
				]
				
				if none? data-y [ exit ] ;-- catches rows that are larger than the actual table height
				sy: get-row-height face data-y frozen? ;Row height is used in each cell
				py1: to-integer ( py0 + sy )   ; Accumulative height

				px0: 0                        ; Start from leftmost cell
				
				repeat draw-x face/frozen/x [      ; Render frozen cells first
					index-x: get-index-col face draw-x ; Which index is given draw column
					px0: to-integer set-table-cell face draw-row data-y index-y index-x draw-y draw-x true px0 py0 py1 ;last: frozen
				]

				grid-row: skip draw-row face/frozen/x ; Move index to unfrozen cells
				grid-y: draw-y - face/frozen/y
				set-table-cells face grid-row data-y index-y grid-y frozen? py0 py1 
				py0: py1
			]
			; Move cells in unused rows outside of visible borders
			while [all [block? draw-row: face/draw/(draw-y: draw-y + 1) draw-row/1/6/y < face/size/y]][
				foreach cell draw-row [fix-cell-outside face cell 'y]
			]
			do-cell-queue face 
			face/scroller/y/page-size: face/grid/y
			face/scroller/x/page-size: face/grid/x
			show face
			system/view/auto-sync?: on
			recycle/on
			face/draw: face/draw
			auto-save face
			trigger-on-changed face
		]

		do-overlays: function [face[object!]][
			code-cols: keys-of face/code-overlays
			foreach cl code-cols [
				rw: 2
				loop ((length? face/row-index) - 1) [
					do-code-overlay face cl rw 
					rw: rw + 1
				]
			]
		]

		ask-code: function [/with default /txt deftext][
			view [
				Title "User Input Required"
				below text "Code:"
				code: area 400x100 focus with [
					case [
						with [text: mold/only default]
						txt  [text: copy deftext]
					]
				]
				across button "OK" [out: code/text unview]
				button "Cancel"    [out: none unview]
			]
			out
		]

		; EDIT



		make-editor: func [table [object!]][ 
			;-- Needs table-obj for Enter Key
			append table/parent/pane layout/only compose/deep [
				at 0x0 tbl-editor: field hidden with [
					options: [text: none]
					extra: #[
						on-table-tab: true
						edit-mode?: false
					]
				]
				on-unfocus [
					if face/visible? [
						face/visible?: no
						update-data face (table)
						set-focus face/extra/table
						face/extra/table/change-state: 'after
						do-actor face/extra/table none 'change
						face/extra/table/change-state: 'before
					]
				] 
				on-key-down [
					switch event/key [
						#"^M" [ ;-- enter
							face/visible?: no
							update-data face (table)
							set-focus face/extra/table
							direction: either find event/flags 'shift[ 'up ] [ 'down ]
							face/extra/table/change-state: 'after
							do-actor face/extra/table none 'change
							face/extra/table/change-state: 'before
							table-obj/actors/hot-keys/feed face/extra/table #(none) direction
						]
						#"^[" [ ;-- ESC 
							append clear face/text face/options/text
							face/visible?: no
							set-focus face/extra/table
							face/extra/table/change-state: 'after
							do-actor face/extra/table none 'change
							face/extra/table/change-state: 'before							
						]
						down  [
							face/visible?: no
							update-data face (table)
							set-focus face/extra/table
							face/extra/table/change-state: 'after
							do-actor face/extra/table none 'change
							face/extra/table/change-state: 'before	
							face/extra/table/actors/hot-keys/feed face/extra/table #(none) 'down
						]
						up [
							face/visible?: no
							update-data face (table)
							set-focus face/extra/table
							face/extra/table/change-state: 'after
							do-actor face/extra/table none 'change
							face/extra/table/change-state: 'before
							face/extra/table/actors/hot-keys/feed face/extra/table #(none) 'up
						]
						left [
							if not face/extra/edit-mode? [
								face/visible?: no
								update-data face (table)
								set-focus face/extra/table
								face/extra/table/change-state: 'after
								do-actor face/extra/table none 'change
								face/extra/table/change-state: 'before	
								face/extra/table/actors/hot-keys/feed face/extra/table #(none) 'left
							]
						]
						right [
							if not face/extra/edit-mode? [
								face/visible?: no
								update-data face (table)
								set-focus face/extra/table
								face/extra/table/change-state: 'after
								do-actor face/extra/table none 'change
								face/extra/table/change-state: 'before									
								face/extra/table/actors/hot-keys/feed face/extra/table none 'right
							]
						]
					]
				] on-focus [
					face/options/text: copy face/text
				]
			]
			table/tbl-editor: tbl-editor
		]

		use-editor: function [
			face [object!] 
			event [event! none!]
			/edit-mode
		][
			either face/tbl-editor <> [] [
				if face/tbl-editor/visible? [
					update-data tbl-editor face 	;Make sure field is updated according to correct type
					face/draw: face/draw     		;Update draw in case we edited a field and didn't enter
				]
			][
				make-editor face
			]
			cell: get-draw-address face event                     ;Draw-cell address
			show-editor/:edit-mode face cell
		]
		
		is-filtered?: function [ face [object!]][
			face/filtered <> #[ y: [] x: [] ]
		]

		is-read-only?: function [ 
			face [object!] 
			addr [pair!]
			/quiet
		][
			fnd-x: find face/read-only-cols addr/x
			fnd-y: find face/read-only-rows addr/y
			if all [
				any [ fnd-x fnd-y ]
				all [ 
					(y-not: not find face/frozen-rows addr/y)
					(x-not: not find face/frozen-cols addr/x)
				]
			][
				typ: rejoin [ either fnd-x [ "Column"][""] either all [ fnd-x fnd-y ] [ " and " ] [""] either fnd-y [ "Row"] [""]]
				msg-ext: either find (keys-of face/vid-overlays) addr/x [
					"This cell can be changed using the GUI widget supplied or for advanced users," newline "Press Shift + F2 on this cell to edit its' contents."
				][
					""
				]
				if not quiet [
					status-msg rejoin [ "This cell is part of a read-only " typ ". Be careful about changing it manually." newline  msg-ext ]
				]
				return true
			]
			return false
		]

		show-editor: function [
			face [object!] 
			cell [pair!]
			/with with-char [char! string!]
			/edit-mode
			/no-focus 
		][
			
			face/tbl-editor/extra/edit-mode?: :edit-mode 
			addr: get-data-address face cell
			col: addr/x
			ofs:  get-cell-offset face cell
			quiet: either no-focus [ true ][ false ]
			if is-read-only?/:quiet face addr [ 
				face/tbl-editor/extra/table: face
				exit 
			]			
			either col <> 0 [
				face/tbl-editor/extra/table: face                      ;Reference to table itself
				txt: switch/default face/col-type/:col [
					image! [
						either block? face/table-data/(addr/y)/(addr/x) [
							form face/table-data/(addr/y)/(addr/x)
						][
							mold face/table-data/(addr/y)/(addr/x)
						]
					]
				][
					form case [
						all [addr/y >= 0 addr/x > 0] [any [face/table-data/(addr/y)/(addr/x) face/dummy]]
						all [v: face/virtual-rows/(addr/y) v: v/source/(addr/x)][v]
						all [v: face/virtual-cols/(addr/x) v: v/source/(addr/y)][v]
						true [face/dummy]
					]
				]
				face/tbl-editor/extra/addr: addr                    ;Register data address
				face/tbl-editor/extra/cell: cell                    ;Register draw-cell address
				fof: to-pair face/offset                          	;Compensate offset for VID space
				either with [
					edit/with/:no-focus face fof + ofs/1 ofs/2 - ofs/1 txt with-char
				][
					edit/:no-focus face fof + ofs/1 ofs/2 - ofs/1 txt	
				]
				
			][
				face/tbl-editor/visible?: no
			]
		]

		status-msg: function [ 
			msg 
			/alert
		][
			either alert [
				request-message msg 
			][
			    print msg	
			]
		]	
		
		hide-editor: function [face [object!]] [
			if all [
				face/tbl-editor
				face/tbl-editor/visible?
			] [face/tbl-editor/visible?: no]
		]

		change-to-address: function [face [object!] x [integer!] y [integer!] c [integer!] r [integer!]][
			rejoin case [
				x = 0 [[" " either face/sheet? [r][y]]]
				y = 0 [[" " either face/sheet? [c][x]]]
				all [0 < y 0 < x] [[" data/" y "/" x]]
				all [0 > y 0 > x] [
					either all [v: face/virtual-rows/y v: v/data/x] [
						[" virtual-rows/" y "/data/" x]
					][
						[" virtual-cols/" x "/data/" y]
					]
				]
				0 > y [[" virtual-rows/" y "/data/" x]]
				0 > x [[" virtual-cols/" x "/data/" y]]
			]
		]

		expand-virtual: function [face [object!] cx addr /local nx ny r c r2 c2 ][
			int: face/int
			ws: face/ws
			parse cx [any [
				change [
					["R" copy r  int "C" copy c  int | "C" copy c  int "R" copy r  int]
					any ws #":" any ws
					["R" copy r2 int "C" copy c2 int | "C" copy c2 int "R" copy r2 int]
				] (
					r1: to-integer r
					y-diff: subtract to-integer r2 r1
					c1: to-integer c
					x-diff: subtract to-integer c2 c1

					y-cf: pick [-1 1] negative? y-diff
					x-cf: pick [-1 1] negative? x-diff
					out: copy ""

					r1: r1 - y-cf
					c1: c1 - x-cf
					repeat ny (absolute y-diff) + 1 [
						y: pick face/row-index my: r1 + (ny * y-cf)
						repeat nx (absolute x-diff) + 1 [
							x: pick face/col-index mx: c1 + (nx * x-cf)
							append out change-to-address face x y mx my
						]
					]
					out
				)
			|	change ["R" copy r int "C" copy c int | "C" copy c int "R" copy r int] (
					y: pick face/row-index r: to-integer r
					x: pick face/col-index c: to-integer c
					change-to-address face x y c r
				)
			| 	change ["R" copy r int any ws #":" any ws "R" copy r2 int] (
					r1: to-integer r
					y-diff: subtract to-integer r2 r1
					y-cf: pick [-1 1] negative? y-diff
					out: copy ""

					r1: r1 - y-cf
					x: addr/x ;pick face/col-index addr/x
					repeat ny (absolute y-diff) + 1 [
						y: pick face/row-index my: r1 + (ny * y-cf)
						append out change-to-address face x y index? find face/col-index x my
					]
					out
				)
			|	change ["R" copy r int] (
					x: addr/x ;pick face/col-index addr/x
					y: pick face/row-index r: to-integer r
					change-to-address face x y index? find face/col-index x r
				)
			| 	change ["C" copy c int any ws #":" any ws "C" copy c2 int] (
					c1: to-integer c
					x-diff: subtract to-integer c2 c1
					x-cf: pick [-1 1] negative? x-diff
					out: copy ""

					c1: c1 - x-cf
					y: addr/y
					repeat nx (absolute x-diff) + 1 [
						x: pick face/col-index mx: c1 + (nx * x-cf)
						append out change-to-address face x y mx index? find face/row-index y
					]
					out
				)
			|	change ["C" copy c int] (
					x: pick face/col-index c: to-integer c
					y: addr/y
					change-to-address face x y c index? find face/row-index y
				)
			|	skip
			]]
		]

		inject-update: function [ 
			face [object!] 
			data-addr [pair!]
			draw-addr [pair!]
			data 
		][
			
			either col-type: face/col-type/(data-addr/x) [
				col-type: to-string col-type
				remove back tail col-type
			][
				col-type: "string"
			]
			face/table-data/(data-addr/y)/(data-addr/x): cast-to-datatype col-type data
			
			unless (face/tbl-editor <> []) [make-editor face] 
			show-editor/no-focus face draw-addr 
			face/tbl-editor/text: to-string data
			
			face/tbl-editor/extra/addr: data-addr 
			face/tbl-editor/extra/cell: draw-addr 
			face/actors/update-data face/tbl-editor face 
			fill face
		]
		
		get-col-type: function [
			face [object!] 
			col-num [integer!]
		][
			len-data: length? face/table-data
			repeat row-num len-data [
				if not find face/frozen-rows row-num [
					return type? face/table-data/:row-num/:col-num
				]
			]
			return none 
		]

		update-data: function [
			face [object!] ;-- edited field
			table-face [object!]
		][
			switch type?/word addr2: addr: face/extra/addr  [ ;-- This is a data-address
				pair! [
					case [
						addr/y > 0 [;Don't update auto-row
							case [
								addr/x > 0 [ ; Don't update auto-col
									type: type? val: table-face/table-data/(addr/y)/(addr/x)
									if (to-string type) = "none" [
										type: get-col-type table-face addr/x
									]
									;if face/extra/table/options/auto-col [addr2/x: addr/x + 1]  ;@@ ??
									table-face/table-data/(addr/y)/(addr/x): switch/default table-face/col-type/(addr2/x) [
										logic!      [
											either any [
												addr/x = table-face/frozen/x
												addr/y = table-face/frozen/y
											][
												tx: form face/data
											][
												tx: attempt [get face/data]
											]											
										]
										draw image! [
											tx: face/data
										]
										do          [tx: to-block face/text]
										icon        [tx: face/text]
									][
										;-- default 
										tx: face/text either none! = type [
											tx
										][
											either find table-face/frozen-rows face/extra/addr/y [
												tx												
											][
												either conv-res: attempt [
													cast-to-datatype type tx
												][
													conv-res
												][
													status-msg rejoin [ "Error converting " mold tx " to datatype " mold type ]
													tx 
												]
											]
										]
									]
									cell:  face/extra/cell   ; This is draw-cell address
									draw-cell: face/extra/table/draw/(cell/y)/(cell/x)
									switch/default table-face/col-type/(addr2/x) [
										logic! [
											either any [
												addr/x = table-face/frozen/x
												addr/y = table-face/frozen/y
											][
												;-- allowing frozen/header cell to be modified with plain text
												draw-cell/11/3: to-string face/data
											][
												;draw-cell/11/3: form either tx [table-face/true-char][table-face/false-char]	
												draw-cell/11/3: form either tx ["true"]["false"]	
											]
										]
										draw   [
											draw-cell/11:   compose/only [translate (draw-cell/9) (tx)]
										]
										image! [if attempt [image? img: load tx] [draw-cell/11: compose [image (img) (draw-cell/9)]]]
										do     [draw-cell/11/3: form do tx]
										icon   [
											if all [
												1 < length? i: split table-face/table-data/(addr/y)/(addr/x) #"/"
												image? ico: get-icon/type i/1 i/2 i/3
											][
												draw-cell/11: compose [image (ico) (draw-cell/9)]
											]
										]
										vid-repeating [
											;-- no drawing needed 
										]
									][
										draw-cell/11/3: tx
									]
									;Update virtual rows and cols
									system/view/auto-sync?: off
									foreach [row vr] table-face/virtual-rows [
										if code: vr/default [
											repeat gx table-face/total/x - table-face/top/x [
												index-x: table-face/top/x + gx
												col: table-face/col-index/:index-x
												if not vr/source/:col [
													expand-virtual table-face cy: copy code as-pair col row
													vr/data/:col: do bind load/all cy self
												]
											]
											fill face/extra/table
										]
										if vr/code [
											foreach [x code] vr/code [
												vr/data/:x: do code
											]
										]
									]
									foreach [col vc] table-face/virtual-cols [
										if code: vc/default [
											repeat gy table-face/total/y - table-face/top/y [
												index-y: table-face/top/y + gy
												row: table-face/row-index/:index-y
												if not vc/source/:row [
													expand-virtual table-face cx: copy code as-pair col row
													vc/data/:row: do bind load/all cx self
												]
											]
											fill face/extra/table
										]
										if vc/code [
											foreach [y code] vc/code [
												vc/data/:y: do code
											]
										]
									]
									show face
									system/view/auto-sync?: on
								]
								addr/x < 0 [
									either empty? tx: table-face/virtual-cols/(addr/x)/source/(addr/y): face/text [
										system/view/auto-sync?: off
										foreach elem [source code table-face/table-data][
											remove/key table-face/virtual-cols/(addr/x)/:elem addr/y
										]
										show face
										system/view/auto-sync?: on
									][
										cx: copy tx
										expand-virtual table-face cx addr
										cx: table-face/virtual-cols/(addr/x)/code/(addr/y): bind load/all cx face/extra/table/actors
										dx: table-face/virtual-cols/(addr/x)/data/(addr/y): do cx
										cell: face/extra/cell
										draw-cell: face/extra/table/draw/(cell/y)/(cell/x)
										draw-cell/11/3: form dx
									]
								]
							]
						]

						addr/y < 0 [
							either empty? tx: table-face/virtual-rows/(addr/y)/source/(addr/x): face/text [
								system/view/auto-sync?: off
								foreach elem [source code data][
									remove/key table-face/virtual-rows/(addr/y)/:elem addr/x
								]
								show face
								system/view/auto-sync?: on
							][
								cx: copy tx
								expand-virtual table-face cx addr
								cx: table-face/virtual-rows/(addr/y)/code/(addr/x): bind load/all cx face/extra/table/actors
								dx: table-face/virtual-rows/(addr/y)/data/(addr/x): do cx
								cell: face/extra/cell
								draw-cell: face/extra/table/draw/(cell/y)/(cell/x)
								draw-cell/11/3: form dx
							]
						]
					]
				]
			]
			fill face/extra/table 
		]

		auto-save: function [ face [object!] ][
			if all [
				file? face/data
				to-logic face/options/auto-save
			][
				save-table face
			]
		]

		edit: function [
			face [object!] 
			ofs [pair!] 
			sz [pair!] 
			txt [string!]
			/with with-char [char! string!]
			/no-focus
		][
			if with [ 
				txt: copy to-string with-char
			]
			
			win: face/tbl-editor
			until [win: win/parent win/type = 'window]
			face/tbl-editor/offset:    ofs
			face/tbl-editor/size:      sz
			face/tbl-editor/text:      txt
			either no-focus [ 
				face/tbl-editor/visible?: no 
			][ 
				face/tbl-editor/visible?: yes 
				win/selected: face/tbl-editor
			]
			
			if with [
				face/tbl-editor/selected: 2x2
				set-focus face/tbl-editor
			]
		]

		edit-column: function [face [object!] event [event! none!]][
			col: get-col-number face event
			case [
				col > 0 [ ; Don't edit auto-col
					if code: request-multiline-text "Enter a Red function that takes a single argument.^/Omit the argument and the value of the cell will be put in it's place.^/The results of the function will be placed back into the cell." [
						code: load/all code
						code: back insert next code '_
						foreach i at face/row-index face/top/y + 1 [
							row: face/table-data/(face/row-index/:i)
							change/only code row/:col
							if res: attempt [do head code][
								row/:col: either series? res [head res][res]
							]
						]
						fill face
					]
				]
				col < 0 [
					if code: either s: face/virtual-cols/:col/default [ask-code/txt s][ask-code] [
						system/view/auto-sync?: off
						repeat gy face/total/y - face/top/y [
							index-y: face/top/y + gy
							row: face/row-index/:index-y
							either empty? face/virtual-cols/:col/default: copy code [
								face/virtual-cols/:col/default: none
								if not face/virtual-cols/:col/source/:row [
									remove/key face/virtual-cols/:col/data row
								]
							][
								if not face/virtual-cols/:col/source/:row [
									expand-virtual table-face cx: copy code as-pair col row
									face/virtual-cols/:col/data/:row: do bind load/all cx self
								]
							]
						]
						fill face
						show face
						system/view/auto-sync?: on
					]
				]
			]
		]
		
		edit-overlay: function [face [object!] event [event! integer!]][
			set [ 'data-addr 'draw-addr ] get-data-address/both face face/pos
			
			data-col: data-addr/x
			vis-col: index? find face/col-index data-addr/x  ;-- visible column
			
			case [
				all [
					vid-ovr: face/vid-overlays/:data-col
					in face/vid-lib/(to-word vid-ovr/id) 'on-edit 
				][
					do bind load/all (copy face/vid-lib/(to-word vid-ovr/id)/on-edit) face/actors 
				]
				any [ 
					code-over: face/code-overlays/:data-col
					vid-over: face/vid-overlays/:data-col
				][
					advanced-cell-edit/address/:code-over/:vid-over face data-addr draw-addr
				]
				true [
					status-msg rejoin [ {Unable to edit an Overlay for column } vis-col " because the column doesn't have an Overlay attached to it."] 
				]				
			]
		]
		
		clear-overlay: function [
			face [object!]
			col-num [integer!]
		][
			case/all [		
				face/code-overlays/(col-num) [
					remove/key face/code-overlays col-num
					clear-vid-decor face	
				]
				face/vid-overlays/(col-num) [
					remove/key face/vid-overlays col-num
					clear-vid-decor face
				]
				face/virtual-cols/(col-num) [
					key-list: exclude (keys-of face/virtual-cols/(col-num)) [ addr default type source code data ]
					face/virtual-cols/(col-num)/default: none
					face/virtual-cols/(col-num)/type: 'code
					foreach key key-list [
						face/virtual-cols/(col-num)/(key): ""
					]
					foreach typ [ source code data ] [
						foreach k skip (keys-of face/virtual-cols/:col-num/:typ ) 1 [
							remove/key face/virtual-cols/(col-num)/(typ) k
						]
					]					
				]					
			]
		]
		
		remove-overlay: function [face [object!] event [event!]][
			col-num: get-col-number face event
			clear-overlay face col-num
			fill face
		]
		
		no-header?: function [ face ][
			either face/frozen-rows = [] [ 
				request-message "The current table needs a frozen row to act as a header.^/Freeze the top row of the current table and try again." 
				return #(true)
			][
				return #(false)
			]
		]
		
		col-is-datatype?: function [
			face [object!]
			datatype [string!] "Using string name of datatype"
			col-num [integer!]
		][
			foreach i face/row-index [
				if not find face/frozen-rows i [
					datatype-string: to-string type? cell-val: face/table-data/:i/:col-num
					if datatype-string = "word" [
						datatype-string: if any [ cell-val = 'true cell-val = 'false ][ "logic" ]
					]
					if datatype-string <> datatype [ return #(false) ]							
				]
			]		
			return #(true)
		]	
		
		cast-column: function [
			{convert all column data to a specific datatype}
			face [object!]
			datatype [string!] "Using string name of datatype"
			col-num [integer!]
		][
			index: 1 
			data-len: length? face/table-data
           	either error? err: try/all  [
				converter: get to-word rejoin [ "to-valid-" datatype ]
				while [index <= data-len] [
					if not find face/frozen-rows index [
						face/table-data/:index/:col-num: converter face/table-data/:index/:col-num
					]
					index: index + 1
				]             
                true ;-- try return value
            ][
        		return false
            ][
                return true
            ]			
		]
		
		good-col-datatype?: function [ 
			face [object!]
			lib-config [object!]
			col-num [integer!]
			/force
		][
			if not in lib-config 'datatype [ return #(true) ]
			datatype: lib-config/datatype
			if col-is-datatype? face datatype col-num [
				face/col-type/:col-num: to-word rejoin [ lib-config/datatype "!" ]	
				return #(true)
			]
			if not force [
				if not req-res: request-yes-no rejoin [ "All of the contents of Column " col-num " are NOT of the datatype '" datatype "'. This is a pre-requisite for this Overlay to work properly. Do you want to force all of the data in the column to be converted to '"datatype "'?"][
					return #(false)
				]
			]
			either cast-column face datatype col-num [
				face/col-type/:col-num: to-word rejoin [ lib-config/datatype "!" ]		
				fill face 
				return #(true)	
			][
				return #(false)
			]
		]

				
		set-overlay-type: function [
			face [object!] 
			event [event!]
			/inject type* [word!] col-num* [integer!] id* [string!]
			/pre-built
			/request {force open a requester to pick code-id}
			/append {part of an append process. Not editable afterwards}
		][
			if no-header? face [ exit ]
			either inject [
				ovr-type: type*
				col-num: col-num*				
				data-col: any [ (pick face/col-index col-num) col-num ]
			][
				ovr-type: event/picked
				data-col: col-num: get-col-number face event				
			]

			
			set [ 'cell-prefix 'virtual? ] either positive? col-num [["data-" #(false)] ][["cell-" #(true)]]
			switch ovr-type [
				set-overlay-code [
					either all [ 
						inject 
						not request 
					][
						code-id: to-get-word id*						
					][
						code-listing: collect [ 
							foreach item (keys-of face/code-lib) [
								keep to-string item 
							]
						]
						either req-res: request-list "Select a Code Overlay" code-listing [
							code-id: to-get-word req-res
						][
							exit
						]
					]
					clear-overlay face data-col
					
					;-- face/code-overlays/(col-num): copy face/code-lib/(code-id) 
					face/code-overlays/(data-col): copy face/code-lib/(code-id) 
					
					code-lib-conf: copy face/code-lib/(code-id)
					
					if all [ not virtual? not pre-built ]  [					
						if not good-col-datatype? face code-lib-conf col-num [ 
							request-message "No Overlay Changes made."
							exit 
						]			
					]
					if all [ not virtual? pre-built ] [
						if not good-col-datatype?/force face code-lib-conf col-num [ 
							request-message "No Overlay Changes made."
							exit 
						]						
					]					
							
					if virtual? [
						virt-config: deep-copy face/overlay-config/(to-get-word code-id)
						if face/virtual-cols/(col-num)/source <> #[] [
							;-- copy pre-existing header data
							virt-config/source/1: copy face/virtual-cols/(col-num)/source/1 
							virt-config/code/1: copy face/virtual-cols/(col-num)/code/1 
							virt-config/data/1: copy face/virtual-cols/(col-num)/data/1 
						]
						face/virtual-cols/:col-num: virt-config						
					]
				]
				set-overlay-vid [
					either inject [
						vid-id: to-get-word id*							
					][
						vid-listing: collect [ 
							foreach item (keys-of face/vid-lib) [ 
								str-item: to-string item
								if (copy/part str-item 5) = cell-prefix [
									keep str-item
								]
							]
						]
						either req-res: request-list "Select a VID Overlay" vid-listing [
							vid-id: to-word req-res
						][
							exit
						]
					]
					clear-overlay face col-num
					vid-lib-conf: copy face/vid-lib/(vid-id)
					if all [ not virtual? not pre-built ] [
						if not good-col-datatype? face vid-lib-conf col-num [ 
							request-message "No Overlay Changes made."
							exit 
						]
					]
					if all [ not virtual? pre-built ] [
						if not good-col-datatype?/force face vid-lib-conf col-num [ 
							request-message "No Overlay Changes made."
							exit 
						]						
					]
					
					if in vid-lib-conf 'when-applied [
						vid-lib-conf: face/actors/(to-word vid-lib-conf/when-applied)/:pre-built face col-num						
					]
					if virtual? [
						virt-config: deep-copy face/overlay-config/(to-get-word vid-id)
						if face/virtual-cols/(col-num)/source <> #[] [
							;-- copy pre-existing header data
							virt-config/source/1: copy face/virtual-cols/(col-num)/source/1 
							virt-config/code/1:   copy face/virtual-cols/(col-num)/code/1 
							virt-config/data/1:   copy face/virtual-cols/(col-num)/data/1 
						]
						face/virtual-cols/:col-num: copy virt-config						
					]
					if not virtual? [
						set-access/read-only/col face col-num
						
					]
					face/vid-overlays/:col-num: make object! [ id: "" code: ""]
					face/vid-overlays/:col-num/id: copy vid-lib-conf/id
					face/vid-overlays/:col-num/code: copy vid-lib-conf/code					
					
				]
			]
			fill face
			if all [
				code-id = 'cell-New-Code-Overlay 
				not append
			][
				edit-overlay face col-num
			]
		]
		
		set-col-align: function [face [object!] event [event! integer!] align-type [word!]][
			col-num: either event? event [get-col-number face event][event]
			either align-type = 'left [
				remove/key face/col-align col-num ;-- default is left-align
			][
				face/col-align/:col-num: align-type	
			]
			fill face
		]
		

		set-col-type: function [
			face [object!] 
			event [event! integer!] 
			/only typ [word!]
			/recurse 
		][
			
			type: either event? event [event/picked][typ]
			col: either event? event [get-col-number face event][event]
			if col < 0 [
				status-msg "Virtual Columns can NOT have their datatype set."
				exit 
			]
			if not all [not only col = 0][
				if all [ 
					((length? face/cells-selected) > 1) 
					not recurse
				][
					exp-rng: either (face/cells-selected/2 = '-) [
						expand-range-block face/cells-selected
					][
						face/cells-selected
					]
					col-set: unique collect [ 
						foreach i exp-rng [ 
							keep get-data-col face i/x 
						]
					]
					name-set: collect [foreach c col-set [ keep get-col-label face c ]]
					if find name-set none! [
						request-message "Some of the columns selected do not have any names defined. You can fix this either by freezing the top row or by using the Menu: 'Column/Set Column Names'. Ideally you should do both to complete the table configuration."
						exit
					]
					msg: rejoin [ "You have selected more than one column. Are you sure you want to set columns " 
						mold name-set " to the " type " datatype?"
					]
					if request-yes-no msg [
						foreach col col-set [
							set-col-type/only/recurse face col type 
						]
					]
				]				

				;face/col-type/:col: type: either event? event [event/picked][typ]
				face/col-type/:col: type
				
				if not to-valid-logic 'data [
					data: face/table-data 
				]
				forall data [
					either block? data/1 [
						if not find face/frozen-rows index? data [
							data/1/:col: switch/default type [
								draw do     [to block! any [data/1/:col face/dummy]]
								load image! [load any [data/1/:col face/dummy]]
								string!     [
									either data/1/:col [
										either string? data/1/:col [ data/1/:col ][ to-valid-string data/1/:col ]
									][
										face/dummy
									]
								]
								money! [
									to-valid-money any [ data/1/:col face/dummy ]
								]
								vid-repeating  [
									if not logic? data/1/:col [
										any [data/1/:col face/dummy]
									]
								]				
								code-repeating  [
									if not logic? data/1/:col [
										any [data/1/:col face/dummy]
									]
								]												
								logic! [
									case [
										all [series? data/1/:col empty? data/1/:col][
											data/1/:col: false                          ; Empty series -> false
										]
										logic? data/1/col []                            ; It's logic! already, do nothing
										all [string? data/1/:col  val: get/any to-word data/1/:col][
											data/1/:col: either logic? val [val][false] ; Textual logic values get mapped
										]
										none? data/1/:col [ data/1/:col: false ]
										'else [
											data/1/:col: false 		; Default to false
										]                       
									]
								]
								icon [form any [data/1/:col face/dummy]]
							][
								attempt [to reduce type any [data/1/:col face/dummy]]
							]
						]
					][break]
				]
				face/table-data: data
			]
			if not only [fill face]
		]

		hide-row: function [face [object!] event [event! integer!]][
			row: either integer? event [event][get-row-number face event]
			face/sizes/y/:row: 0
			face/changed?: #(false)
			fill face
			show-marks face
		]

		hide-rows: function [face [object!] rows [block!]][
			foreach row rows [face/sizes/y/:row: 0]
			face/changed?: #(false)
			fill face
			show-marks face
		]

		hide-col: function [face [object!] event [event! integer!]][
			col: either integer? event [event][get-col-number face event]
			face/sizes/x/:col: 0
			face/changed?: #(false)
			fill face
			show-marks face
		]

		hide-column: function [face [object!] event [event! integer!]][
			hide-col face event
		]

		hide-columns: function [face [object!] cols [block!]][
			foreach col cols [face/sizes/x/:col: 0]
			clear-vid-decor face
			face/changed?: #(false)
			fill face
			show-marks face
		]

		unhide: function [face [object!] dim [word!] /only][
			foreach [key val] face/sizes/:dim [
				if zero? val [remove/key face/sizes/:dim key]
			]
			unless only [
				face/changed?: #(false)
				fill face
				show-marks face
			]
		]

		unhide-all: function [face [object!]][
			foreach dim [x y][unhide/only face dim]
			face/changed?: #(false)
			fill face
			show-marks face
		]

		show-row: function [face [object!] event [event! none!]][]

		show-col: function [face [object!] event [event! none!]][]

		get-col-count: function [ face [object!]][
			real-cols: copy face/col-index 
			remove-each c real-cols [ c < 1 ]
			return (length? real-cols)
		]

		auto-increment: function [
			col-name [string!]
			col-num [integer!]
			/init {initialize auto-increment state}
			/extern table-obj
		][
			if init [
				if req-res: request-text "Enter the integer that you want auto-increment to start at" [
					incr-start: to-integer req-res
				]
				either fnd: find-in-array-at/with-index table-obj/auto-incr 1 col-num [
					ndx: fnd/2
					table-obj/auto-incr/:ndx: reduce [ col-num col-name incr-start ]		
				][
					append/only table-obj/auto-incr reduce [ col-num col-name incr-start ]		
				]
				exit
			]
			fnd: find-in-array-at/with-index table-obj/auto-incr 1 col-num
			ndx: fnd/2
			incr-start: table-obj/auto-incr/:ndx/3
			table-obj/auto-incr/:ndx/3: (incr-start + 1)
			return incr-start
		]

		add-new-row: function [face [object!]][
			total-real: get-col-count face 
			row: make block! total-real
			repeat col total-real [
				;if face/options/auto-col [col: col + 1] ;@@ ??? Should it?
				content: case [
					face/defaults/:col [ 
						either series? face/defaults/:col [
							do bind source-to-block face/defaults/:col face/actors
						][
							face/defaults/:col
						]
					]
					type: face/col-type/:col [
						switch/default type [
							do draw image! [copy []]
							load icon [none]
							vid-repeating [copy ""]
							code-repeating [copy ""]
						][ 
							dtype: to-string type
							remove back tail dtype
							cast-to-datatype dtype none
						]		
						
					]
				]
				append/only row content
			]
			append/only face/table-data row
			face/total/y: face/total/y + 1
		]

		add-virtual-row: function [face [object!]][
			x: face/total/x
			vr: object [
				addr: #(none)
				source: make map! x
				code: make map! x
				data: make map! x
				default: #(none)
			]
			len: negate 1 + length? face/virtual-rows
			face/virtual-rows/:len: vr
			face/total/y: face/total/y + 1
			len
		]
		

		add-virtual-col: function [face [object!]][
			y: face/total/y
			vc: object [
				source: make map! y
				code: make map! y
				data: make map! y
				default: none
				type: 'code
				id: copy ""
			]
			new-key: find-unused-key face/virtual-cols
			face/virtual-cols/:new-key: vc
			face/total/x: face/total/x + 1
			new-key
		]


		refresh-view: func [face [object!]  ][
			set-last-page face
			adjust-scroller face
			face/changed?: #(false)
			fill face
			show-marks face
		]
		
	    print-code-overlays: func [ face [object!]][
			foreach i keys-of face/code-overlays [ 
			    print [ i ".)" mold face/actors/user-get-col-header face i ]
			    print face/code-overlays/:i/code
			    print newline
			]			
		]
		
	    print-table-data: func [ face [object!]][
	    	col-ndx: copy face/col-index
	    	remove-each i col-ndx [ i < 0 ]
		    print-table/columns/column-names/name/col-sequence (skip face/table-data 1)  (length? face/table-data/1) face/table-data/1 face/name col-ndx
		]
		

		insert-row: function [
			{insert row at row specified}
			face [object!] 
			event [event! integer!] {when event is integer! this is the row number used}
		][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before inserting a new row."
				exit
			]
			either integer? event [
				r: event 
			][
				dr: get-draw-row face event
				r: get-index-row face dr
			]			
			add-new-row face
			insert/only at face/row-index r face/total/y
			;-- to deal with unfilter properly
			insert/only at face/default-row-index r face/total/y
			
			refresh-view face
			fill face 
		]

		append-row: function [
			{Appends an empty row at the end of the table data}
			face [object!]
		][ 
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before appending a row to it."
				exit
			]
			add-new-row face
			append face/row-index face/total/y
			append face/default-row-index face/total/y
			refresh-view face
			fill face
		]

		insert-virtual-row: function [face [object!] event [event! integer!]][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before inserting a new virtual row."
				exit
			]			
			dr: get-draw-row face event
			ir: get-index-row face dr
			vr: add-virtual-row face
			insert/only at face/row-index ir vr
			refresh-view face
		]

		append-virtual-row: function [face [object!]][
			vr: add-virtual-row face
			append face/row-index vr
			refresh-view face
		]
		
		
		remove-vid-col-decor: function [
			face [object!]
			col [integer!]
			/delete {delete entire entry}
		][
			draw-len: (first-non-block face/draw) - 1
			r: 1
			while [r <= draw-len] [
				either delete [
					remove at (pick face/draw r) col							
				][
					if ( cell: face/draw/:r/:col ) [
						remove/part (skip cell 11) length? cell	
					]
				]
				r: r + 1	
			]
		]

		clear-vid-decor: function [
			face [object!]
		][
			if all [
				block? face/draw/1
				max-cols: length? face/draw/1
			][
				col: 1
				while [col <= max-cols ][
					remove-vid-col-decor face col 
					col: col + 1				
				]
			]
			if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
		]

		insert-col: function [
			{Inserts a column at the column specified}
			face [object!] 
			event [event! none! integer!] {If event is integer! this is the column number used}
			/ret-col-num {return the column number that has just been created}
		][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before adding a new column."
				exit
			]			
			either integer? event [
				c: event 
			][
				dc: get-draw-col face event
				c: get-index-col face dc
			]			
			clear-vid-decor face
			if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
			
			repeat i face/total/y [append face/table-data/:i none]
			face/total/x: face/total/x + 1
			insert/only at face/col-index c ( nc: (get-max face/col-index) + 1)
			insert/only at face/default-col-index c ( nc: (get-max face/col-index) + 1)
			refresh-view face
			if ret-col-num [ return nc ]
		]

		append-col: function [
			{Append a column to the existing table data}
			face [object!]
			/ret-col-num {returns the new column number just created}
		][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before adding a new column."
				exit
			]
			repeat i face/total/y [append face/table-data/:i none]
			face/total/x: face/total/x + 1
			append face/col-index ( nc: (get-max face/col-index) + 1)
			append face/default-col-index ( nc: (get-max face/col-index) + 1)
			refresh-view face
			
			either ret-col-num [ 
				return nc 
			][
				return none
			]
		]

		insert-virtual-col: function [face [object!] event [event! integer!]][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before inserting a new virtual column."
				exit
			]			
			dc: get-draw-col face event
			ic: get-index-col face dc
			vc: add-virtual-col face
			clear-vid-decor face
			insert/only at face/col-index ic vc
			insert/only at face/default-col-index ic vc
			refresh-view face
		]

		append-virtual-col: function [face [object!] /name header-name [string!]][
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before adding a new virtual column."
				exit
			]			
			vc: add-virtual-col face
			append face/col-index vc
			append face/default-col-index vc
			
			if name [
				face/virtual-cols/:vc/source/1: mold header-name
				face/virtual-cols/:vc/code/1: reduce header-name
				face/virtual-cols/:vc/data/1: header-name
			]
			refresh-view face
		]
		
		make-overlay-config: function [ face [object!] ][
			face/overlay-config: #[]
			face/overlay-config/cell-checkbox-for-row-selection: make object! [	
			    source: #[
			        1 {"Rows Selected"}
			        2 "{cell-checkbox-for-row-selection}"
			    ]
			    code: #[
			        1 ["Rows Selected"]
			        2 ["cell-checkbox-for-row-selection"]
			    ]
			    data: #[
			        1 "Rows Selected"
			        2 "cell-checkbox-for-row-selection"
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "cell-checkbox-for-row-selection"
			]
			
			face/overlay-config/cell-button: make object! [	
			    source: #[
			        1 {"Show Row Data"}
			    	2 {{cell-button "See Row Data" ^/^-on-click [ ^/^-^-print mold get-this-row^/^-]}}
			    ]
			    code: #[
			        1 ["Show Row Data"]
			        2 [{cell-button "See Row Data" ^/^-on-click [ ^/^-^-print mold get-this-row^/^-]}]
			    ]
			    data: #[
			        1 "Show Row Data"
			        2 {cell-button "See Row Data" ^/^-on-click [ ^/^-^-print mold get-this-row^/^-]}
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "cell-button"
			]

			face/overlay-config/cell-code-example: make object! [	
			    source: #[
			        1 {"Code Example"}
			    ]
			    code: #[
			        1 ["Code Example"]
			    ]
			    data: #[
			        1 "Code Example"
			    ]
			    default: none
			    type: "code-repeating"
			    id: "cell-code-example"
			]
				
			face/overlay-config/cell-New-Code-Overlay: make object! [	
			    source: #[
			        1 {"New Code"}
			    ]
			    code: #[
			        1 ["New Code"]
			    ]
			    data: #[
			        1 "New Code"
			    ]
			    default: none
			    type: "code-repeating"
			    id: "cell-New-Code-Overlay"
			]					
			
			face/overlay-config/data-checkbox-for-logic: make object! [	
			    source: #[
			        1 {"Checkbox"}
			    	2 {{data-checkbox-for-logic}}
			    ]
			    code: #[
			        1 ["Checkbox"]
			        2 [{data-checkbox-for-logic}]
			    ]
			    data: #[
			        1 "Checkbox"
			        2 {data-checkbox-for-logic}
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "data-checkbox-for-logic"
			]

			face/overlay-config/data-request-date: make object! [	
			    source: #[
			        1 {"Request-date"}
			    	2 {{data-request-date}}
			    ]
			    code: #[
			        1 ["Request-date"]
			        2 [{data-request-date}]
			    ]
			    data: #[
			        1 "Request-date"
			        2 {data-request-date}
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "data-request-date"
			]						

					
			face/overlay-config/data-drop-list: make object! [	
			    source: #[
			        1 {"Drop-list"}
			    	2 {{data-drop-list}}
			    ]
			    code: #[
			        1 ["Drop-list"]
			        2 [{data-drop-list}]
			    ]
			    data: #[
			        1 "Drop-list"
			        2 {data-drop-list}
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "data-drop-list"
			]						
			
			face/overlay-config/data-table-link: make object! [	
			    source: #[
			        1 {"Table-link"}
			    	2 {{data-table-link}}
			    ]
			    code: #[
			        1 ["Table-link"]
			        2 [{data-table-link}]
			    ]
			    data: #[
			        1 "Table-link"
			        2 {data-table-link}
			    ]
			    default: none
			    type: "vid-repeating"
			    id: "data-table-link"
			]						
		]
		
		place-pre-buit-col: function [
			face [object!] 
			event [event!]
			/append
		][
			{Defaults to inserting a pre-built column}
			if is-filtered? face [
				status-msg/alert "The Current table is filtered. Please clear the filter before adding any pre-built columns."
				exit
			]
			if no-header? face [ 
				status-msg/alert "The current table does not have any frozen header. Please freeze a header in place before adding any pre-built columns."
				exit 
			]
			make-overlay-config face
			cust-list: collect [ foreach item (keys-of face/overlay-config) [ keep to-string item ]]
			either req-res: request-list-enhanced/size "Select a Custom Pre-Built Column" cust-list 230x200 [
				custom-pre-built: face/overlay-config/(to-get-word req-res)
			][
				exit
			]
			either (copy/part req-res 4) = "cell" [	;-- cell-* for virtual cols
				either append [
					new-col: add-virtual-col face
					system/words/append face/col-index new-col
					system/words/append face/default-col-index new-col
				][
					dc: get-draw-col face event
					ic: get-index-col face dc
					new-col: add-virtual-col face
					clear-vid-decor face
					insert/only at face/col-index ic new-col								
					insert/only at face/default-col-index ic new-col								
				]
			][	;-- insert data col					
				either append [
					new-col: append-col/ret-col-num face 
				][
					new-col: insert-col/ret-col-num face event 	
				]
				
				if custom-pre-built/type = "vid-repeating" [
					if in face/vid-lib/(to-word custom-pre-built/id)	'datatype [
						face/col-type/:new-col: to-word rejoin [ face/vid-lib/(to-word custom-pre-built/id)/datatype "!" ]		
					]
				]														
				
			]
			overlay-type: case [
				custom-pre-built/type = "code-repeating" [ 'set-overlay-code ]
				custom-pre-built/type = "vid-repeating"  [ 'set-overlay-vid  ]
			]
			
			set-overlay-type/inject/pre-built/:append face event overlay-type new-col req-res
			set-access/read-only/col face new-col
			refresh-view face
		]

		remove-row: function [face [object!] event [event!]][
			dr: get-draw-row face event
			r: get-index-row face dr
			remove at face/row-index r
			refresh-view face
		]

		remove-col: function [face [object!] event [event!]][
			dc: get-draw-col face event
			c: get-index-col face dc
			remove at face/col-index c
			refresh-view face
		]

		restore-row: function [face [object!]][
			append clear face/row-index face/default-row-index
			refresh-view face
		]

		restore-col: function [face [object!]][
			append clear face/col-index face/default-col-index
			refresh-view face
		]

		delete-row: function [
			{Deletes the specified row}		
			face [object!] 
			event [event! integer!] {when event is integer!, that row number is deleted}
		][
			either integer? event [
				ri: event 
			][
				dr: get-draw-row face event
				ri: get-index-row face dr
			]
			remove at face/table-data rd: face/row-index/:ri
			remove at face/row-index ri
			repeat i length? face/row-index [
				if face/row-index/:i > rd [face/row-index/:i: face/row-index/:i - 1]
			]
			take/last face/default-row-index
			refresh-view face
		]
		
		step-num-keys: function [
			{returns a map with the keys stepped up or down depending on comapator}
			m [map!]
			needle [integer!]
			comparator [ block! ] {Usually key (> < =) needle comparison}
			/down "flag to decrease key value"
		][
			mb: to-block m
			step: either down [ -1 ] [ 1 ]
			key: 0
			forskip mb 2 [
				key: mb/1 
				if (do bind comparator 'key) [ 
					mb/1: mb/1 + step 
				]		
			]
			return to-map mb
		]		

		step-element-vals: function [ 
			{step each element up/down in a series depending on the filter}
			series [block!] {A flat series. Not block in block}
			needle [integer!] {'needle value in filter}
			filter [block!] {Filter Format: needle operator element . Where operator can be < > => =< }
			/down "Step element value down 1. Default is step element up 1"
			/skip skip-val "amount to skip within the series"
		][
			step: either down [ -1 ] [ 1 ]
			skip-amt: either skip [ skip-val ] [ 0 ]
			ndx: 1 + skip-amt
			series-len: length? series
			while [ ndx <= series-len ] [
				element: series/:ndx
				if (do bind filter 'element) [ 
					series/:ndx: series/:ndx + step			 
				]
				ndx: ndx + 1 + skip-amt
			]
		]		

		delete-col: function [face [object!] event [event!]][
			dc: get-draw-col face event
			ci: get-index-col face dc
			cd: get-data-col face dc
			
			remove/key face/col-type cd
			remove/key face/vid-overlays cd 
			take find face/read-only-cols cd
			remove-vid-col-decor/delete face dc
			clear-vid-decor face
			clear-overlay face cd 
			if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
			
			remove at face/col-index ci
			remove/key face/sizes/x cd
			if find face/frozen-cols cd [ unfreeze face 'x 	]
			
			either cd > 0 [			;-- Normal Cols ------------
				face/col-type: step-num-keys/down face/col-type cd [ key > needle ]
				face/vid-overlays: step-num-keys/down face/vid-overlays cd [ key > needle ] 
				face/code-overlays: step-num-keys/down face/code-overlays cd [ key > needle ] 
				step-element-vals/down face/read-only-cols cd [ needle < element ]				
				face/sizes/x: step-num-keys/down face/sizes/x cd [ key > needle ]
				foreach row face/table-data [either block? row [remove at row cd][break]]
				step-element-vals/down face/col-index cd [ needle < element ]	
				take/last face/default-col-index
				remove/key face/defaults cd 
				if fnd: find-in-array-at/with-index face/auto-incr 1 cd [
					remove skip face/auto-incr (fnd/2 - 1)
				]
				if fnd: find face/col-names cd [ remove/part (skip fnd -1) 2 ]
				step-element-vals/down/skip face/col-names cd [ needle < element ] 1 				
				face/defaults: step-num-keys/down face/defaults cd [ key > needle ]
				
			][						;-- Virtual Cols --------------
				remove/key face/virtual-cols cd
				keys: keys-of face/vid-state 
				foreach k keys [
					if find (to-string k) rejoin [ "cell" cd ][
						remove/key face/vid-state k
					]		
				]
				if fnd: find face/col-names cd [ remove/part (skip fnd -1) 2 ]
			]
			refresh-view face
		]

		move-row: function [face [object!] event [event! integer!] step [word! integer!] /to][
			either event? event [
				dr: get-draw-row face event
				ri: get-index-row face dr
			][
				ri: event
			]
			case [
				to [
					face/pos: max face/top/y + 1 min face/total/y step
					step: face/pos - ri
				]
				integer? step [
					step: max face/top/y - ri + 1 min face/total/y - ri step
				]
				word? step [
					step: switch step [
						up [-1]
						down [1]
						top [face/top/y - ri + 1]
						bottom [face/total/y - ri]
					]
				]
			]
			target: dr + step
			if any [
				find face/frozen-rows dr
				find face/frozen-rows target
			][
				status-msg "Can not move to or from a frozen row. Unfreeze the row first if you want to move it."
				exit	
			]
			
			move i: at face/row-index ri skip i step
			refresh-view face
			fill face
			show-marks face
		]

		move-col: function [face [object!] event [event! integer!] step [word! integer!] /to][
			either event? event [
				dc: get-draw-col face event
				ci: get-index-col face dc
			][
				ci: event
			]
			case [
				to [
					face/pos: max face/top/x + 1 min face/total/x step
					step: face/pos - ci
				]
				integer? step [
					step: max face/top/x - ci + 1 min face/total/x - ci step
				]
				word? step [
					step: switch step [
						left  [-1]
						right [1]
						first [face/top/x - ci + 1]
						last  [face/total/x - ci]
					]
				]
			]
			clear-vid-decor face
			move i: at face/col-index ci skip i step
			set-column-names/only face 
			refresh-view face
			fill face
			show-marks face
		]

		; MARKS

		set-new-mark: func [face [object!] active [pair!]][
			if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
			append face/cells-selected face/anchor: face/active
		]

		mark-active: func [face [object!] cell [pair! none!] /extend /extra /index][

			if none? cell [ exit ]
			either index [
				face/active: cell
			][
				face/pos: cell
				face/active: get-index-address face cell
			]
			face/marks/-1: 0.0.0.220
			either pair? last face/draw [
				case [
					extend [
						face/extend?: true
						either '- = first skip tail face/cells-selected -2 [
							change back tail face/cells-selected face/active
						][
							repend face/cells-selected ['- face/active]
						]
					]
					extra  [
						face/extend?: false face/extra?: true
						set-new-mark face face/active
					]
					true   [
						face/extra?: face/extend?: false
						clear face/cells-selected
						set-new-mark face face/active
					]
				]
			] [
				set-new-mark face face/active
			]
			show-marks face
		]

		unmark-active: func [face [object!]][
			if face/active [
				clear face/marks
				face/extend?: face/extra?: false
				face/anchor: face/active: face/pos: none
				clear face/cells-selected
			]
		]

		mark-address: function [face [object!] s [pair!] dim [word!]][
			case [
				s/:dim > face/top/:dim [
					case [
						s/:dim <= face/current/:dim [0]
						s/:dim > (face/current/:dim + face/grid/:dim) [-1]
						true [face/frozen/:dim + s/:dim - face/current/:dim]
					]
				]
				found: find face/frozen-nums/:dim face/index/:dim/(s/:dim) [index? found]

			]
		]

		mark-point: function [face [object!] a [pair!] /end][
			n: pick [7 6] end
			case [
				all [a/x > 0 a/y > 0][
					face/draw/(a/y)/(a/x)/:n
				]
				a/x > 0 [
					y: either a/y = 0 [face/freeze-point/y][face/size/y]
					as-pair face/draw/1/(a/x)/:n/x y
				]
				a/y > 0 [
					x: either a/x = 0 [face/freeze-point/x][face/size/x]
					as-pair x face/draw/(a/y)/1/:n/y
				]
				true [
					x: either a/x = 0 [face/freeze-point/x][face/size/x]
					y: either a/y = 0 [face/freeze-point/y][face/size/y]
					as-pair x y
				]
			]
		]

		show-marks: function [face [object!]][
			system/view/auto-sync?: off
			clear face/marks
			parse face/cells-selected [any [
				s: pair! '- pair! (
					a: min s/1 s/3
					b: max s/1 s/3
					r1: mark-address face a 'y
					c1: mark-address face a 'x
					r2: mark-address face b 'y
					c2: mark-address face b 'x
					a: as-pair c1 r1
					b: as-pair c2 r2
					p1: mark-point face a
					p2: mark-point/end face b
					repend face/marks ['box p1 p2]
				)
			|  pair! (
				if all [
					r: mark-address face s/1 'y
					c: mark-address face s/1 'x
				][
					case [
						all [r > 0 c > 0][
							append face/marks copy/part at face/draw/:r/:c 5 3
						]
						r > 0 [
							x: either c = 0 [face/freeze-point/x][face/size/x]
							p1: as-pair x face/draw/:r/1/6/y
							p2: as-pair x face/draw/:r/1/7/y
							repend face/marks ['box p1 p2]
						]
						c > 0 [
							y: either r = 0 [
								face/freeze-point/y
							][
								face/size/y
							]
							p1: as-pair face/draw/1/:c/6/x y
							p2: as-pair face/draw/1/:c/7/x y
							repend face/marks ['box p1 p2]
						]
					]
				]
			   )
			]]
			show face
			system/view/auto-sync?: on
			face/draw: face/draw
		]

		adjust-selection: function [face [object!] step [integer!] s [block!] dim [word!]][
			face/active/:dim: face/active/:dim + step
			either '- = s/-1 [
				s/1/:dim: s/1/:dim + step
			][
				e: s/1
				e/:dim: e/:dim + step
				repend face/cells-selected ['- e]
			]
			show-marks face
		]

		remove-color-selected: function [face [object!] color [tuple! word! none!]][
			range: either (length? face/cells-selected) = 1 [
				face/cells-selected
			][
				expand-range-block face/cells-selected
			]
			foreach cell range [
				remove/key face/colors cell
			]
			fill face
		]

		color-selected: function [face [object!] color [tuple! word! none!]][
			unless color [
				if not color: request-color [ exit ]
			]
			
			parse face/cells-selected [any [s:
				pair! '- pair! (
					mn: (min s/1 s/3) - 1
					mx: max s/1 s/3
					df: mx - mn
					repeat dy df/y [
						repeat dx df/x [
							face/pos: mn + as-pair dx dy
							x: face/col-index/(face/pos/x)
							y: face/row-index/(face/pos/y)
							put face/colors as-pair x y color
						]
					]
				)
			|	pair! (
					x: face/col-index/(s/1/x)
					y: face/row-index/(s/1/y)
					put face/colors as-pair x y color
				)
			]]
			fill face
		]

		name-selected: function [
			face [object!] 
			name [word! none! string!]
			/reload
		][
			unless name [name: ask-code]
			if not reload [ face/names/:name: copy face/cells-selected ]
			if block? items: face/menu/"Table"/"Select named range" [
				repend items [name to-word name]
			]
		]

		forget-names: function [face [object!] names [word! block! none!]][
			unless names [names: load ask-code]
			case [
				names = 'all [
					clear face/names
					all [items: face/menu/"Table"/"Select named range" clear items]
				]
				word? names [
					remove/key face/names names: form names
					all [
						items: face/menu/"Table"/"Select named range"
						found: find items names
						remove/part found 2
					]
				]
				block? names [
					foreach name names [
						remove/key face/names name: form name
						all [
							items: face/menu/"Table"/"Select named range"
							found: find items name
							remove/part found 2
						]
					]
				]
			]
		]


		normalize-range: function [range [block!]][
			bs: charset range
			clear range
			repeat i length? bs [if bs/:i [append range i]]
		]

		filter-rows: function [face [object!] data-col [integer!] crit [any-type!]][
			
			c: data-col
			row-index: face/row-index
			either block? crit [
				switch/default type?/word w: crit/1 [
					word! [
						case [
							op? get/any w [
								forall row-index [
									row: first row-index
										insert/only crit either data-col = 0 [row][face/table-data/:row/:c]
										if do crit [append face/filtered/y row]
										remove crit
								]
							]
							any-function? get/any w	[
								crit: back insert next crit '_
								forall row-index [
									row: first row-index
										change/only crit either data-col = 0 [row][face/table-data/:row/:c]
										if do head crit [append face/filtered/y row]
								]
							]
						]
					]
					path! [
						case [
							any-function? get/any w/1 [
								crit: back insert next crit '_
								forall row-index [
									row: first row-index
										change/only crit either data-col = 0 [row][face/table-data/:row/:c]
										if do head crit [append face/filtered/y row]
								]
							]
						]
					]
					paren! [

					]
					set-word! [
						crit: back insert next crit '_
						forall row-index [
							row: first row-index
								change/only crit either data-col = 0 [row][face/table-data/:row/:c]
								if do head crit [append face/filtered/y row]
						]
					]
				][  ;Simple list
					either data-col = 0 [
						normalize-range crit  ;Use charset spec to select rows
						face/filtered/y: intersect row-index crit
					][
						insert crit [_ =]
						forall row-index [
							row: first row-index
							if find crit face/table-data/:row/:c [append face/filtered/y row]
						]
					]
				]
			][  ;Single entry
				case [
					data-col > 0 [
						forall row-index [
							row: row-index/1
							if face/table-data/:row/:c = crit [append filtered/y row]
						]
					]
					data-col = 0 [
						face/filtered/y: to-block crit
					]
					data-col < 0 [

					]
				]
			]
		]

		filter: function [face [object!] data-col [integer!] crit [any-type!] ][
			face/row-index: skip face/row-index face/top/y
			face/scroller/y/position: 1 + face/top/y: face/current/y: face/frozen/y
			filter-rows face data-col crit
			face/row-index: head append clear face/row-index face/filtered/y
			
			adjust-scroller face
			set-last-page face
			unmark-active face
			on-filter face
			clear-vid-decor face
			face/changed?: #(false)
			fill face
			face/draw: face/draw
		]
		
		filter-with: function [
			face [object!] 
			filter-blk [block!] {Format: [ [<col-indices> ... ] [ <row-indices> ... ] ]} 
		][ 
			face/row-index: skip face/row-index face/top/y
			face/scroller/y/position: 1 + face/top/y: face/current/y: face/frozen/y
			face/filtered/y: copy filter-blk/2
			face/row-index: head append clear face/row-index face/filtered/y
			face/filtered/x: copy filter-blk/1
			
			face/col-index: head append clear face/col-index face/filtered/x
			adjust-scroller face
			set-last-page face
			unmark-active face
			on-filter face
			clear-vid-decor face 
			face/changed?: #(false)
			fill face
			face/draw: face/draw
		]		

		unfilter: func [face [object!]][
			clear face/filtered/y
			clear face/filtered/x
			append clear head face/row-index face/default-row-index
			append clear head face/col-index face/default-col-index
			adjust-scroller face
			on-unfilter face
			clear-vid-decor face 
			face/changed?: #(false)
			fill face
			face/draw: face/draw
		]

		freeze: function [face [object!] event [event!] dim [word!] ][

			fro: face/frozen
			cur: face/current
			face/frozen/:dim: either dim = 'x [
				get-draw-col face event
			][
				get-draw-row face event
			]
			fro/:dim: face/frozen/:dim - fro/:dim
			face/grid/:dim: face/grid/:dim - fro/:dim
			set-freeze-point face
			if fro/:dim > 0 [
				append face/frozen-nums/:dim copy/part at face/index/:dim cur/:dim + 1 fro/:dim
			]
			face/current/:dim: cur/:dim + fro/:dim
			face/top/:dim: face/current/:dim ;- face/frozen/:dim
			set-last-page face
			adjust-scroller/only face
			face/scroller/:dim/position: face/current/:dim + 1
			either dim = 'y [
				repeat i face/frozen/y [
					repeat j face/grid/x [
						j: j + face/frozen/x
						face/draw/:i/:j/4: 192.192.192
					]
				]
			][
				repeat i face/grid/y [
					i: i + face/frozen/y
					repeat j face/frozen/:dim [
						face/draw/:i/:j/4: 192.192.192
					]
				]
			]
			face/draw: face/draw
			clear-vid-decor face
			fill face
		]

		unfreeze: function [face [object!] dim [word!]][
			face/top/:dim: face/current/:dim: face/frozen/:dim: 0
			face/freeze-point/:dim: 0
			face/grid-size/:dim: face/size/:dim - face/scroller-width
			face/scroller/:dim/position: 1
			clear face/frozen-nums/:dim
			set-grid face
			set-last-page face
			fill face
			show-marks face
			adjust-scroller face
		]

		adjust-size: func [face [object!]][
			face/grid-size: face/grid-size - face/freeze-point - face/scroller-width
			set-grid face
			set-last-page face
		]

		adjust-border: function [face [object!] event [event! none!] dim [word!]][
			
			face/pane: layout/only []
			if face/on-border?/:dim > 0 [
				ofs0: either dim = 'x [
					face/draw/1/(face/on-border?/x)/7/x            ;box's actual end
				][
					face/draw/(face/on-border?/y)/1/7/y
				]
				ofs1: event/offset/:dim
				df:   ofs1 - ofs0
				num: get-index face face/on-border?/:dim dim
				case [
					all [event/ctrl? face/on-border?/:dim = 1] [
						clear face/sizes/:dim
						face/box/:dim: face/box/:dim + df
						if face/frozen/:dim > 0 [
							face/freeze-point/:dim: face/frozen/:dim * df + face/freeze-point/:dim
							face/grid-size/:dim: face/size/:dim - face/freeze-point/:dim
						]
					]
					event/ctrl? [
						sz: get-size face dim face/index/:dim/:num
						i: num - 1
						repeat n face/total/:dim - num + 1 [
							m: face/index/:dim/(i + n)
							face/sizes/:dim/:m: sz + df
						]
						if face/on-border?/:dim <= face/frozen/:dim [
							face/freeze-point/:dim: face/frozen/:dim - face/on-border?/:dim + 1 * df + face/freeze-point/:dim
							face/grid-size/:dim: face/size/:dim - face/freeze-point/:dim
						]
					]
					true [
						sz: get-size face dim i: face/index/:dim/:num
						face/sizes/:dim/:i: sz + df
						if face/on-border?/:dim <= face/frozen/:dim [
							face/freeze-point/:dim: to-integer face/freeze-point/:dim + df
							face/grid-size/:dim: face/size/:dim - face/freeze-point/:dim
						]
					]
				]
				set-grid face
			]
		]

		; SCROLLING

		make-scroller: func [face [object!] /local vscr hscr][
			vscr: get-scroller face 'vertical
			hscr: get-scroller face 'horizontal
			face/scroller: make map! 2
			face/scroller/x: hscr
			face/scroller/y: vscr
		]

		scroll: function [face [object!] dim [word!] steps [integer!]][
			if 0 <> step: set-scroller-pos face dim steps [ ;-- set-scroller-pos won't update if return = 0
				dif: calc-step-size face dim step
				face/current/:dim: face/current/:dim + step
				hide-editor face
				if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
				set-grid face
				clear-vid-decor face
				face/changed?: #(false) 
				fill face
			]
			step
		]

		adjust-scroller: func [face [object!] /only][
			face/scroller/y/max-size:  max 1 face/total/y: length? face/row-index
			face/scroller/x/max-size:  max 1 face/total/x: length? face/col-index
			unless only [
				set-grid face
			]
			face/scroller/y/page-size: min face/grid/y face/scroller/y/max-size
			face/scroller/x/page-size: min face/grid/x face/scroller/x/max-size
		]

		set-scroller-pos: function [face [object!] dim [word!] steps [integer!]][
			pos0: face/scroller/:dim/position
			min-pos: face/top/:dim + 1
			max-pos: face/scroller/:dim/max-size - face/last-page/:dim + pick [2 1] face/grid-offset/:dim > 0
			
			mid-pos: face/scroller/:dim/position + steps
			pos1: face/scroller/:dim/position: max min-pos min max-pos mid-pos
			pos1 - pos0
		]

		count-cells: function [face [object!] dim [word!] dir [integer!] /by-keys][
			case [
				dir > 0 [
					start: face/current/:dim
					gsize: 0
					repeat count face/total/:dim - start [
						start: start + 1
						bsize: get-size face dim face/index/:dim/:start
						gsize: gsize + bsize
						if gsize >= face/grid-size/:dim [break]
					]
					if (gsize - face/grid-size/:dim) > face/tolerance/:dim [count: count - 1]
				]
				dir < 0 [
					start: face/current/:dim
					gsize: count: 0
					if start > 0 [
						until [
							count: count + 1
							gsize: gsize + get-size face dim face/index/:dim/:start
							any [face/grid-size/:dim <= gsize 0 = start: start - 1]
						]
					]
				]
			]
			count
		]

		count-steps: function [face [object!] event [event! none!] dim [word!]][
			switch event/key [
				up left    [-1]
				down right [ 1]
				page-up page-left    [steps: count-cells face dim -1  0 - steps]
				page-down page-right [steps: count-cells face dim  1      steps]
				track      [step: event/picked - face/scroller/:dim/position]
			]
		]

		calc-step-size: function [face [object!] dim [word!] step [integer!]][

			dir: negate step / s: absolute step
			local-pos: either dir < 0 [
				face/current/:dim
			][
				face/current/:dim + 1
			]
			sz: 0
			repeat i s [
				sz: sz + get-size face dim local-pos + i
			]
			sz * dir
		]

		scroll-on-border: function [face [object!] event [event! none!] s [block!] dim [word!]][
			if any [
				all [
					event/offset/:dim > face/size/:dim
					0 < step: scroll face dim  1
				]
				all [
					s/1/:dim > face/frozen/:dim
					event/offset/:dim <= face/freeze-point/:dim
					0 > step: scroll face dim -1
				]
				all [
					s/1/:dim = face/frozen/:dim
					event/offset/:dim >= face/freeze-point/:dim
					0 > scroll face dim face/top/:dim - face/current/:dim
					step: 1
				]
			][step]
		]

		; SELECT / COPY / CUT / PASTE

		copy-selected: function [face [object!] /cut ][
			clear face/selected-data

			face/selected-range: copy face/cells-selected
			clpbrd: copy ""
			parse face/cells-selected [any [
				s: pair! '- pair! (
					start: s/1
					dabs: absolute df: s/3 - s/1
					sign: 1x1
					if df/x < 0 [sign/x: -1]
					if df/y < 0 [sign/y: -1]
					repeat row dabs/y + 1  [
						repeat col dabs/x + 1 [
							d: start - sign + (sign * as-pair col row)
							d: as-pair face/col-index/(d/x) face/row-index/(d/y)
							append/only face/selected-data out:
								either d/x = 0 [
									d/y
								][
									face/table-data/(d/y)/(d/x)
								]
							repend clpbrd [mold out tab]
							if cut [face/table-data/(d/y)/(d/x): none]
						]
						change back tail clpbrd lf
					]
				)
				|  pair! (
					row: face/row-index/(s/1/y)
					col: face/col-index/(s/1/x)
					append/only face/selected-data out:
						either col = 0 [
							s/1/y
						][
							face/table-data/:row/:col
						]
					repend clpbrd [mold out tab]
					if cut [face/table-data/:row/:col: make type? out 0]
				)
			]]
			remove back tail clpbrd
			write-clipboard clpbrd
			if cut [fill face]
		]

		parse-selection: function [face [object!] selection [block!] start [pair!] ][
			parse selection [any [
				end
				| s: (
					diff: s/1 - selection/1
				)
				pair! '- pair! (
					dabs: absolute df: s/3 - s/1
					sign: 1x1
					if df/x < 0 [sign/x: -1]
					if df/y < 0 [sign/y: -1]
					repeat y dabs/y + 1 [
						repeat x dabs/x + 1 [
							face/pos: start + diff - sign + (sign * as-pair x y)
							face/pos/x: face/col-index/(face/pos/x)
							face/pos/y: face/row-index/(face/pos/y)
							d: first face/selected-data
							if not face/pos/x = 0 [face/table-data/(face/pos/y)/(face/pos/x): d]
							face/selected-data: next face/selected-data
						]
					]
				)
				|	pair! (
					face/pos: start + diff
					face/pos/x: face/col-index/(face/pos/x)
					face/pos/y: face/row-index/(face/pos/y)
					d: first face/selected-data
					if not face/pos/x = 0 [face/table-data/(face/pos/y)/(face/pos/x): d]
					face/selected-data: next face/selected-data
				)
			]]
		]

		paste-selected: function [face [object!] /transpose ][
			if is-read-only? face to-pair 
				reduce [ 
					;(face/pos/x + face/current/x - face/frozen/x) (face/pos/y + face/current/y - face/frozen/y) 
					(pick face/col-index (face/pos/x + face/current/x - face/frozen/x))
					(pick face/row-index (face/pos/y + face/current/y - face/frozen/y))
				][ 
				exit 
			]
			orig-face-pos: face/pos
			either single? face/cells-selected [
				start: face/anchor 
				parse-selection face face/selected-range start
			][
				; Compare copied and selected sizes
				copied-size: 0
				parse face/selected-range [any [
					end
				|	s:
				|	pair! '- pair! (p: (absolute s/3 - s/1) + 1 copied-size: p/x * p/y + copied-size)
				|	pair! (copied-size: copied-size + 1)
				]]
				selected-size: 0
				parse face/cells-selected [any [
					end
				|	e:
				|	pair! '- pair! (q: (absolute e/3 - e/1) + 1 selected-size: q/x * q/y + selected-size)
				|	pair! (selected-size: selected-size + 1)
				]]
				either copied-size = selected-size [
					start: face/cells-selected/1
					parse-selection face face/cells-selected start
				][
					status-msg "Warning! Sizes do not match."
				]
			]
			face/selected-data: head face/selected-data
			fill face
			face/pos: orig-face-pos ;-- restore value after parse-selection
		]

		select: function [
			face [object!]
			range [pair! integer! block!]
			/from
				start "Either `top` - start counting from first non-frozen -, or `current` (also `cur`) - start from first visible after frozen -, or `view` - start from current view-port"
			/col
			/row
		][
			unmark-active face
			switch type?/word range [
				pair! [
					either from [
						switch start [
							view [mark-active/extra face range]
							top [mark-active/index/extra face top + range]
							cur face/current [mark-active/index/extra face face/current + range]
						]
					][
						mark-active/index face range
					]
				]
				integer! [

				]
				block! [
					parse range [any [s:
						pair! '- pair! (
							either from [
								switch start [
									view [
										mark-active/extra  face s/1
										mark-active/extend face s/3
									]
									face/current cur [
										mark-active/index/extra  face face/current + s/1
										mark-active/index/extend face face/current + s/3
									]
									top [
										mark-active/index/extra  face face/top + s/1
										mark-active/index/extend face face/top + s/3
									]
								]
							][
								mark-active/index/extra  face s/1
								mark-active/index/extend face s/3
							]
						)
					|	pair! (
							either from [
								switch start [
									view [
										mark-active/extra face s/1
									]
									face/current cur [
										mark-active/index/extra face face/current + s/1
									]
									top [
										mark-active/index/extra face face/top + s/1
									]
								]
							][
								mark-active/index/extra face s/1
							]
						)
					]]
					show-marks face
				]
			]
			set-focus tb
		]

		which-index: function [face [object!] event [event! integer!] dim [word!]][
			either event? event [
				switch dim [
					row [
						dri: get-draw-row face event
						get-index-row face dri
					]
					col [
						dri: get-draw-col face event
						get-index-col face dri
					]
				]
			][
				event
			]
		]

		select-row: function [
			face [object!] 
			event [event! integer!] 
			/add
		][
			ri: which-index face event 'row
			unless add [clear face/cells-selected]
			repend face/cells-selected [as-pair 1 ri '- as-pair face/total/x ri]
			show-marks face
		]

		select-col: function [face [object!] event [event! integer!] /add][
			ci: which-index face event 'col
			unless add [clear face/cells-selected]
			repend face/cells-selected [as-pair ci 1 '- as-pair ci face/total/y]
			show-marks face
		]

		select-name: function [face [object!] name [string!] /add][
			unless add [clear face/cells-selected]
			append face/cells-selected face/names/:name
			show-marks face
		]

		set-virtual-col: function [ 
			face [object!] 
			event [event! integer!] 
			type [ word! ] {Valid types: 'code 'VID}
		
		] [
			col: switch type?/word event [
				event!   [get-col-number face event]
				integer! [face/col-index/:event]
			]	
			face/virtual-cols/:col/type: type
			face/actors/fill face	
		]
		
		state-to-array: function [
			map-val [map!]
			array-len [integer!]
			name-pattern [block!] {ie: [ "cell-1x" 'index]  }
		][
			array: make block! array-len
			repeat index array-len [
				key-name: to-word rejoin reduce bind name-pattern 'array
				append/only array reduce [ map-val/:key-name]
			] 
		]
			
		logic-to-integer: function [ 
			{Converts value into an integer to represent logic for sorting purposes}
			val [string! logic! word!]
		][ ;-- built for speed
			if val = #(true)  [ return  1 ]
			if val = #(false) [ return  0 ]
			if val = none 	  [ return -1 ]
			if val = 'true 	  [ return  1 ]	
			if val = 'false   [ return  0 ]	
			if val = 'none 	  [ return -1 ]
			return -1 
		]
						
		get-checked-indices: function [ 
			face [object!] 
			address [pair! integer! string!]
		] [
			if integer? address [ address: as-pair address 1]
			if string? address [ 
				either col-num: system/words/select face/col-names address [
					address: as-pair col-num 1	
				][
					status-msg rejoin [ "Unable to find column associated to :" mold address ". Operation failed."]
					return none	
				]
				
			]
			states: get-matching-keys face/vid-state rejoin [ "cell" address/x ]
			return results: collect [
				foreach s states [
					if face/vid-state/:s [
						keep to-integer copy skip (find/reverse tail (to-string s) "x") 1		
					]
				]
			]
		]
		
		logic-to-sortable: function [ 
			face [object!]
			col [integer!]
		][
			
			either col < 0 [ ;-- virtual-col sorting against /vid-state
				len: (length? face/row-index)
				target-data: append/only/dup make block! len [ -1 ] len ;-- init to (-1)  = none				
				needle: rejoin [ "cell" col ]
				n-len: (length? needle)
				skip-len: n-len + 1
				foreach [ k v ] face/vid-state [
					ks: to-string k
					if (copy/part ks n-len ) = needle [ 
						y: to-integer copy skip ks skip-len
						target-data/(y): reduce [ logic-to-integer v ]
					]
				]
			][				;-- this is a normal data column 
				target-data: copy []
				foreach r face/table-data [
					append/only target-data reduce [ logic-to-integer r/:col ]
				]
			]
			return target-data
		]
		
		get-column-data: function [ 
			face [object!]
			col [integer!]
		][
			skip-amt: either face/frozen-rows <> [] [ last face/frozen-rows ][ 0 ]
			results: collect [
				foreach i (skip face/table-data	skip-amt) [
					if i/:col > "" [
						keep i/:col					
					]
				]
			]		
			return unique results	
		]
		
		setup-data-drop-list: function [ 
			face [object!]
			col [integer!]
			/pre-built
		][
			ddl: copy/deep face/vid-lib/data-drop-list 
			code: load ddl/code/1
			either pre-built [
				code/data: [ "Small" "Medium" "Large" ]
				face/table-data/1/:col: "Pre-built drop-list"
				foreach r ( skip face/row-index 1) [
					face/table-data/:r/:col: first random code/data
				]
			][
				code/data: copy get-column-data face col	
			]
			
			ddl/code: reduce [ mold/only code ]
			return ddl
		]
		
		setup-cell-checkbox-for-row-selection: function [ 
			face [object!]
			col [integer!]
			/pre-built ;-- not used just a placeholder for 'setup-* pattern
		][
			lib-entry: copy/deep face/vid-lib/cell-checkbox-for-row-selection
			code: load lib-entry/code/1
			lib-entry/code: reduce [ mold/only code ]
			return lib-entry
		]

		setup-data-request-date: function [ ;-- copied from: setup-data-checkbox-for-logic
			face [object!]
			col [integer!]
			/pre-built 
		][
			lib-entry: copy/deep face/vid-lib/data-request-date
			code: load lib-entry/code/1
			lib-entry/code: reduce [ mold/only code ]
			if pre-built [ face/table-data/1/:col: "Pre-blt data-request-date" ]
			return lib-entry
		]
		
		setup-data-table-link: function [ 
			face [object!]
			col [integer!]
			/pre-built 
		][
			lib-entry: copy/deep face/vid-lib/data-table-link
			if pre-built [ face/table-data/1/:col: "Pre-blt data-table-link" ]
			if req-res: request-table-link 	[
				tbl-name: copy/part req-res/1 ((length? req-res/1) - 7 )
				lib-entry/code: to-block mold rejoin [ {data-table-link data [ } mold tbl-name " " mold req-res/2 " " mold req-res/3  { ]} ]
				return lib-entry
			]
			return none
		]		
		
		setup-data-checkbox-for-logic: function [ 
			face [object!]
			col [integer!]
			/pre-built ;-- not used just a placeholder for 'setup-* pattern
		][
			lib-entry: copy/deep face/vid-lib/data-checkbox-for-logic
			code: load lib-entry/code/1
			lib-entry/code: reduce [ mold/only code ]
			if pre-built [
				face/table-data/1/:col: "Pre-blt data logic"
			]
			return lib-entry			
		]

		get-matching-keys: function [
			map [ map!]
			needle [string!]
		][
			keys: keys-of map
			matches: collect [
				foreach k keys [
					if find to-string k needle [ keep k ]	
				]
			]
			return matches 
		]

		get-virtual-col-key: function [ 
			id [string!]
		][
			foreach [ key val ] face/virtual-cols [
				if val/id = id [ 
					return key
				]
			] 
			return none
		]		

		on-sort: func [face [object!] event [event! integer!] /loaded /down /local col c fro idx found][
			recycle/off
			col: switch type?/word event [
				event!   [get-col-number face event]
				integer! [face/col-index/:event]
			]
			either 0 = col [
				append clear head face/row-index face/default-row-index
				if face/frozen/y > 0 [face/row-index: skip face/row-index face/frozen-rows/(face/frozen/y)]
				if down [reverse face/row-index]
				face/row-index: head face/row-index
			][
				either face/indices/x/:col [clear face/indices/x/:col][face/indices/x/:col: make block! face/total/y]
				target-data: face/table-data	
				idx: skip head face/row-index face/top/y
				c: absolute col				
				if all [ 
					vid-ovr: face/vid-overlays/:col 
					in face/vid-lib/(to-word vid-ovr/id) 'on-sort
				][
					sort-func: to-word face/vid-lib/(to-word vid-ovr/id)/on-sort
					target-data: face/actors/(sort-func) face col 
					c: 1					
				]
				
				sort/compare idx function [a b][
					attempt [case [
						all [loaded down][(load target-data/:b/:c) <= (load target-data/:a/:c)]
						loaded           [(load target-data/:a/:c) <= (load target-data/:b/:c)]
						down             [target-data/:b/:c <= target-data/:a/:c]
						true             [target-data/:a/:c <= target-data/:b/:c]
					]]
				]
				append face/indices/x/:col face/row-index
			]
			set-last-page face
			face/scroller/y/position: either 0 < fro: face/frozen/y [
				if found: find face/row-index face/frozen-rows/:fro [
					face/top/y: face/current/y: index? found
					face/current/y + 1
				]
			][
				face/top/y: face/current/y: 0
				1
			]
			face/changed?: #(false)
			fill face
			recycle/on
		]

		unsort: func [face [object!]][
			append clear face/row-index face/default-row-index
			adjust-scroller face
			face/changed?: #(false)
			fill face
		]

		resize: func [face [object!]][
			face/grid-size: face/size - face/scroller-width
			adjust-size face
			face/changed?: #(false)
			fill face
			show-marks face
		]
		
		hot-keys: func [
			face [object!] 
			event [event! none!]
			/feed fed-key [word!]
		][
			abs-row: face/pos/y + face/current/y - face/frozen/y
			if feed [
				event: object [ 
					shift?: #(false)
					ctrl?: #(false)
					flags: []
					key: fed-key
				]
			]
			if all [
				event/key = #" "
				find event/flags 'shift 
			][
				abs-row: face/pos/y + face/current/y - face/frozen/y
				select-row face abs-row
				exit
			]
			
			key: event/key
			within-view?: #(false)
			valid-key?: #(true)
			if all [ 
				key = 'page-down
				face/pos/y = face/frozen/y 
			][	;-- current position is sitting on a frozen row
				face/actors/hot-keys/feed face #(none) 'down
			]
			
			if all [ 
				key = 'page-down
				( face/pos/y + face/current/y - face/frozen/y ) = face/total/y 
			][
				exit									;-- at end of file 
			]
			
			step: switch key [
				down      [0x1]
				up        [0x-1]
				left      [-1x0]
				right     [1x0]
				page-up   [as-pair 0 negate face/grid/y]
				page-down [
					either ( face/pos/y + face/grid/y + face/current/y - face/frozen/y ) >= face/total/y [
						test-step: as-pair 0 (face/total/y - (face/pos/y + face/current/y - face/frozen/y))
						new-pos: min (abs-row + test-step/y) face/total/y
						within-view?: is-within-view? face test-step
						test-step
					][
						as-pair 0 face/grid/y ; ORIGINAL	
					]
				]
				home      [as-pair negate face/grid/x 0]
				end       [as-pair face/grid/x 0]
			]
			frozen-y-adj: either all [
				face/data-fit/y = 'perfect
				face/pos/y = face/usable-grid/y
				face/active/y + 1 = face/total/y
			][ 
				0	
			][ 
				face/frozen/y 
			]


			
			
			;prin [ "hot-keys face/active =" mold face/active]
			if not value? 'y [ y: 0 ]	;-- error suppressor
			if not value? 'x [ x: 0 ]	;-- error suppressor
			either all [face/active step] [
				case [
					; Active mark beyond edge
					case/all [
						all [face/active/y > (edge: face/current/y + face/grid/y)][
							ofs: face/active/y + step/y - edge
							either ofs > 0 [
								df: scroll face 'y ofs
								face/pos/y: face/frozen/y + face/grid/y
							][
								face/pos/y: face/frozen/y + face/grid/y + ofs
							]
							step/y: 0
							y: 'done
							false
						]
						all [face/active/x > (edge: face/current/x + face/grid/x)][
							ofs: face/active/x + step/x - edge
							either ofs > 0 [
								df: scroll face 'x ofs
								face/pos/x: face/frozen/x + face/grid/x
							][
								face/pos/x: face/frozen/x + face/grid/x + ofs
							]
							step/x: 0
							x: 'done
							false
						]
						all [face/active/y > face/top/y face/active/y <= face/current/y 'y <> 'done][
							scroll face 'y face/active/y - face/current/y - 1 + step/y
							face/pos/y: face/frozen/y + 1
							step/y: 0
							y: 'done
							false
						]
						all [face/active/x > face/top/x step/x <> 0 face/active/x <= face/current/x 'x <> 'done][
							scroll face 'x face/active/x - face/current/x - 1 + step/x
							face/pos/x: face/frozen/x + 1
							step/x: 0
							x: 'done
							false
						]
					][
						false
					]
					; Active mark on edge
					
					dim: case [
						any [
							all [
									key = 'down
									y <> 'done
									(face/active/y + 1) <= face/total/y
									;(min (face/active/y + 1) face/total/y) > min (face/current/y + face/usable-grid/y - frozen-y-adj) face/total/y
									not is-within-view? face 0x1
							]
							all [key = 'up face/frozen/y + 1 = face/pos/y y <> 'done]
							all [
								find [page-up page-down] key 
								not within-view?
								y <> 'done
							]
						][
							if key = 'down [ cell-offset: get-cell-offset face face/pos ]
														
							df: scroll face 'y step/y
							switch key [
								page-up   [if step/y < step/y: df [face/pos/y: face/pos/y - face/grid/y - step/y]]
								page-down [
									if step/y > step/y: df [face/pos/y: face/pos/y + face/grid/y - step/y]
								]
							]
							'y
						]
						any [
							all [key = 'right (face/pos/x + 1 + face/current/x) > (face/usable-grid/x + face/current/x) x <> 'done]
							all [key = 'left  face/frozen/x + 1    = face/pos/x x <> 'done]
							all [key = 'right ofs: get-cell-offset face face/pos + step ofs/2/x >  face/size/x x <> 'done]
						][

							df: scroll face 'x step/x
							step/x: df
							'x
						]
					][
						face/pos: max 1x1 min face/grid + face/frozen face/pos
						either df = 0 [
							if switch key [
								up        [face/pos/y: max 1 face/pos/y - 1]
								left      [face/pos/x: max 1 face/pos/x - 1]
								page-up   [face/pos/y: face/frozen/y + 1]
								page-down [face/pos/y: face/grid/y]
							][
								either event/shift? [
									mark-active/extend face face/pos
								][	mark-active face face/pos]
							]
						][
							if event/shift? [face/extend?: true]
							either any [face/extra? face/extend?] [
								either '- = first s: skip tail face/cells-selected -2 [
									s/2: s/2 + step
								][
									repend face/cells-selected ['- s/1 + step]
								]
								show-marks face
							][

								mark-active face face/pos
							]
						]
					]
					;Active mark in center ;probe reduce [active step active + step]
					true [
						case [
							all [key = 'down  face/pos/y = face/frozen/y y <> 'done][scroll face 'y face/top/y - face/current/y]
							all [key = 'right face/pos/x = face/frozen/x x <> 'done][scroll face 'x face/top/x - face/current/x]
							all [key = 'page-down face/pos/y <= face/frozen/y y <> 'done][
								scroll face 'y face/top/y - face/current/y
								step/y: face/frozen/y - face/pos/y + face/grid/y
							]
						]
						face/pos: face/pos + step
						face/pos: max 1x1 min face/grid + face/frozen face/pos
						either event/shift? [
							mark-active/extend face face/pos
						][	mark-active face face/pos]
					]
				]
			][
				either event/ctrl? [
					switch key [
						#"C" [copy-selected face]
						#"X" [copy-selected/cut face]
						#"V" [paste-selected face]
						#" " [
							abs-col: face/pos/x + face/current/x - face/frozen/x
							select-col face abs-col
						]
					]
				][
					switch key [
						#"^M" [	;-- enter
							direction: either find event/flags 'shift [ 'up ] [ 'down ]
							face/actors/hot-keys/feed face #(none) direction 							
						]
						F2 [
							case [
								(first event/flags) = 'shift [
									set [ 'data-addr 'draw-addr ] get-data-address/both face face/pos
									advanced-cell-edit/address face data-addr draw-addr
									return 'done
								]
								(first event/flags) = 'alt [
									edit-overlay face event 
									return 'done	
								]
								true [
									unless (face/tbl-editor <> []) [make-editor face]
									do-actor face none 'change
									show-editor/edit-mode face face/pos
								]
							]
						]
						F3 [
							if 	(first event/flags) = 'shift [
								set-overlay-type/inject/request face event 'set-overlay-code face/active/x ""
							]
						]
						F4 [
							set [ 'data-addr 'draw-addr ] get-data-address/both face face/pos
							this-cell: rejoin [ "cell" data-addr ]	;-- 'this-cell used in on-F4 script
							if data-addr/y > 1 [ ;-- skip the header of the column/ needs to handle multi-headers!!!							
								either negative? data-addr/x [	;-- This is a Virtual column
									if face/virtual-cols/(data-addr/x)/type = "vid-repeating" [
										closest-key: get-at-key-or-less/only face/virtual-cols/(data-addr/x)/code data-addr/y
										vid-id: to-word first split face/virtual-cols/(data-addr/x)/code/(closest-key)/1 " "
										if in face/vid-lib/(vid-id) 'on-F4 [
											if target: find-vid-target face data-addr [
												unset '-target-vid-object-
												do bind load face/vid-lib/(vid-id)/on-F4 face/actors
												valid-key?: #(false)
											]
										]
									]							
								][								;-- This is a Normal data column
									if vid-ovr: face/vid-overlays/(data-addr/x) [
										vid-id: to-word vid-ovr/id 
										if in face/vid-lib/(vid-id) 'on-F4 [
											if target: find-vid-target face data-addr [
												unset '-target-vid-object-
												do bind load face/vid-lib/(vid-id)/on-F4 face/actors
												valid-key?: #(false)
											]
										]									
									]									
								]
							]
							
						]
						delete [
							data-addr: get-data-address face face/pos
							do-actor face none 'change
							face/table-data/(data-addr/y)/(data-addr/x): copy ""
							fill face
						]				
						#"^H" [ ;-- Backspace
							unless (face/tbl-editor <> []) [make-editor face]
							do-actor face none 'change
							show-editor/with face face/pos ""
						]		
					]
					if all [
						valid-key?
						ky: to-valid-key event/key event/flags 
					][ 	
						do-actor face none 'change
						unless (face/tbl-editor <> []) [make-editor face]
						show-editor/with face face/pos ky
					]
				]
			]
		]
	
		find-vid-target: function [ 
			face [object!]
			addr [pair!]
		][
			fnd: none
			foreach item face/vid-targets [
				if item/5 = addr [
					fnd: copy item
					break
				]	
			]
			return fnd
		]

		advanced-cell-edit: function [
			face
			/address 
				data-addr [pair!] 
				draw-addr [pair!]
			/code-over 
			/vid-over 
		][
			
			input-is-string?: #(true)
			addr: either address [ data-addr ] [face/actors/get-data-address face face/pos]
			col-num: index? find face/col-index addr/x
			data-col: addr/x 
			row-num: index? find face/row-index addr/y
			req-msg: copy ""
			cell-data: case [
				addr/x < 0 [ ;-- Virt Column
					heading-msg: rejoin [ " with Heading: " mold face/virtual-cols/(addr/x)/data/1 ]
					case [	;-- sequence sensitive
						code-over [
							req-msg: rejoin [ "Editing the Code Overlay for Virtual Column (" addr/x ") at column position " col-num newline ] 
							face/code-overlays/(data-col)/code
						]
						vid-over [
							req-msg: rejoin [ "Editing the VID Overlay Code for Virtual Column (" addr/x ") at column position " col-num newline ]
							load face/virtual-cols/(data-col)/source/2		
						]
						face/virtual-cols/(addr/x)/source/(addr/y) [
							req-msg: rejoin [ "Editing the Virtual Cell Code at Virtual Column (" addr/x ") at column position "  col-num newline "and row " row-num ] 
							src-code: load face/virtual-cols/(data-col)/source/(addr/y)										
						]
						true [
							req-msg: rejoin [ "Editing the Virtual Cell Code at Virtual Column (" addr/x ") at column position" col-num  newline "and row " row-num ] 
							load ""
						]
					]
				]
				addr/x > 0 [ ;-- Data Column 
					heading-msg: rejoin [ " with Heading: " mold face/table-data/1/(addr/x) ]
					case [
						code-over [
							req-msg: rejoin [ "Editing the Code Overlay for Column " col-num ] 
							face/code-overlays/(addr/x)/code	
						]
						true [
							req-msg: rejoin [ "Editing the data cell at Column " col-num " Row " row-num ] 
							face/table-data/(addr/y)/(addr/x)	
						]
					]
				]
			]
			req-data: any [ cell-data "" ]
			if not string? req-data [
				req-data: mold/only req-data ;-- remove brackets 
				input-is-string?: #(false)
			]
			req-addr: addr 
			either face/frozen-rows <> [][
				header-msg: either addr/x < 0 [
					rejoin [ " with Heading: " mold face/virtual-cols/(addr/x)/data/1]
				][
					rejoin [ " with Heading: " mold face/table-data/(addr/y)/1]
				]
			][
				header-msg: ""
			]
			col-num: to-string index? find face/col-index addr/x 
			process-results: [ ;-- explicit 'req-results variable is used in this context
				case [	
					code-over [
						face/code-overlays/(req-addr/x)/code: copy req-results
					]
					all [ vid-over (req-addr/x < 0)][
						cx: either input-is-string? [ mold req-results ][ req-results ]
						face/virtual-cols/(req-addr/x)/source/2: copy cx
						expand-virtual face cx req-addr
						cx: face/virtual-cols/(req-addr/x)/code/2: bind load/all cx face/actors
						face/virtual-cols/(req-addr/x)/data/2: do cx
					]						
					vid-over [
						face/vid-overlays/(addr/x)/code/1: copy req-results
					]
					req-addr/x < 0 [
						req-results: copy req-results
						cx: either input-is-string? [ mold req-results ][ req-results ]
						face/virtual-cols/(req-addr/x)/source/(req-addr/y): copy cx
						expand-virtual face cx req-addr
						cx: face/virtual-cols/(req-addr/x)/code/(req-addr/y): bind load/all cx face/actors
						face/virtual-cols/(req-addr/x)/data/(req-addr/y): do cx
					]
					true [ ;-- Normal data cell
						inject-update face data-addr draw-addr req-results 											
					]
				]
				
			]
			if req-results: request-multiline-text/preload/size/submit/modal rejoin [ req-msg  heading-msg ] req-data 900x300
				[ 	;-- --------------------------- F5 Submit block---------------------------------------
					req-results: get-results
					do process-results
					do-column-code face code-over addr/x
					fill face
				]
				[	;-- ---------------------------- OK Button block-----------------------------
					do process-results
					do-column-code face code-over addr/x
					fill face
				]
			fill face
		]
		
		do-column-code: function [
			face [object!]
			code-over [logic!]
			col-num [integer!]
		][
			if all [
				code-over
				positive? col-num
			][
				rw: 2
				loop ((length? face/row-index) - 1) [ ;-- skip header
					do-code-overlay face col-num rw 
					rw: rw + 1
				]				
				
			]			
		]
		
		do-menu: function [face [object!] event [event! none!]][
			switch/default event/picked [
				; TABLE
				open-table      	[open-table face]
				save-table      	[save-table face]
				save-table-as   	[save-table-as face]
				save-state      	[save-state face]
				set-column-names  	[set-column-names face]
				use-state       	[use-state face]
				unhide-all      	[unhide-all  face]
				;force-state     	[use-state/force face]
				clear-color     	[clear face/colors fill face]
				forget-names    	[forget-names face none]
			    print-table-config   [print-table-config face ]
			    print-data			[print-table-data face ]
				refresh-view		[refresh-view face ]
			    print-code-overlays [print-code-overlays face ]
				open-big        	[open-big-table face]

				; CELL
				edit-cell       		[on-dbl-click face event]
				edit-cell-multi-line 	[ multi-line-editor face event ]
				freeze-cell     		[freeze face event 'y freeze face event 'x]
				unfreeze-cell   		[unfreeze face 'y unfreeze face 'x]

				; ROW
				freeze-row      [freeze face event 'y]
				unfreeze-row    [unfreeze face 'y]
				default-height  [set-default-height face event]

				select-row      [select-row face event]
				hide-row        [hide-row   face event]
				insert-row      [insert-row face event]
				append-row      [append-row face]
				insert-virtual-row [insert-virtual-row face event]
				append-virtual-row [append-virtual-row face]

				find-in-row     [find-in-row face event]

				move-row-top    [move-row face event 'top]
				move-row-up     [move-row face event 'up]
				move-row-down   [move-row face event 'down]
				move-row-bottom [move-row face event 'bottom]
				move-row-by     [if integer? step: load ask-code [move-row face event step]]
				move-row-to     [if integer? face/pos:  load ask-code [move-row/to face event face/pos]]

				remove-row      [remove-row  face event]
				restore-row     [restore-row face]
				delete-row      [delete-row  face event]
				unhide-row      [unhide face 'y]

				; COLUMN
				freeze-col      [freeze face event 'x]
				unfreeze-col    [unfreeze face 'x]
				default-width   [set-default-width  face event]
				full-height     [set-full-height    face event]
				remove-full-height [remove-full-height face]

				sort-up          [on-sort face event]
				sort-down        [on-sort/down face event]
				sort-loaded-up   [on-sort/loaded face event]
				sort-loaded-down [on-sort/loaded/down face event]
				unsort           [unsort face]

				; VIRTUAL-COLUMN
				set-virt-col-code [ set-virtual-col face event 'code ]
				set-virt-col-vid  [ set-virtual-col face event 'VID ]

				filter [
					if code: ask-code [
						code: load code
						col: get-col-number face event
						filter face col code
					]
				]
				unfilter    [unfilter face]

				select-col  [select-col face event]
				hide-col    [hide-col   face event]
				insert-col  [insert-col face event]
				append-col  [append-col face]
				insert-virtual-col [insert-virtual-col face event]
				append-virtual-col [append-virtual-col face]
				
				insert-pre-built-col [ place-pre-buit-col face event ]
				append-pre-built-col [ place-pre-buit-col/append face event ]
				
				find-in-col     [find-in-col face event]

				move-col-first  [move-col face event 'first]
				move-col-left   [move-col face event 'left]
				move-col-right  [move-col face event 'right]
				move-col-last   [move-col face event 'last]
				move-col-by     [if integer? step: load ask-code [move-col face event step]]
				move-col-to     [if integer? face/pos:  load ask-code [move-col/to face event face/pos]]

				edit-column     [edit-column face event]

				unhide-col      [unhide face 'x]
				remove-col      [remove-col  face event]
				restore-col     [restore-col face]
				delete-col      [delete-col  face event]

				load draw do icon
				integer! float! percent!
				string! char! block!
				date! time! logic!
				image! tuple! money! [set-col-type face event]

				set-default     			[set-default face event]
				remove-default				[set-default/delete face event]
				set-default-auto-incr     	[set-default/auto-incr face event]
				
				edit-overlay 	 [ edit-overlay face event     ]
				remove-overlay	 [ remove-overlay face event   ]
				set-overlay-vid  [ set-overlay-type face event ]
				set-overlay-code [ set-overlay-type face event ] 
				
				set-align-left	 [ set-col-align face event 'left   ]
				set-align-center [ set-col-align face event 'center ]
				set-align-right  [ set-col-align face event 'right  ]
				
				
				set-col-read-only  [ set-access/col/read-only face event ]
				set-col-read-write [ set-access/col face event ]
				set-row-read-only  [ set-access/row/read-only face event ]
				set-row-read-write [ set-access/row face event ]


				; SELECTION
				copy-selected   [copy-selected face]
				cut-selected    [copy-selected/cut face]
				paste-selected  [paste-selected face]
				transpose       [paste-selected/transpose face]
				color-selected  		[color-selected face none]
				remove-color-selected 	[remove-color-selected face none ]
				name-selected   		[name-selected face none]
			][
				case [
					all [menu: face/menu/"Table"/"Select named range" find menu name: form event/picked] [
						select-name face name
					]
				]
			]
		]

		do-over: func [
			face [object!]
			event [event! none!]
		][
			if all [event/down? not face/no-over][
				case [
					face/on-border? [
						adjust-border face event 'x
						adjust-border face event 'y
						fill face
						show-marks face
					]
					event/ctrl? []
					true [
						selection: find/last face/cells-selected pair!
						face/same-offset?: no
						case [
							step: scroll-on-border face event selection 'y [
								adjust-selection face step selection 'y
							]
							step: scroll-on-border face event selection 'x [
								adjust-selection face step selection 'x
							]
							true [
								if attempt [addr: get-draw-address face event] [
									if all [addr addr <> face/pos] [
										mark-active/extend face addr
									]
								]
							]
						]
					]
				]
			]
			if not event/away? [
				;-- --------------------------------------------
				;-- target index  description
				;--        -----  -----------
				;--          1		offset
				;--          2		size
				;--          3		not-rendered? 	
				;--          4		renderer name
				;-- 		 5      data address
				;--          6      draw address   
				;-- --------------------------------------------
				
				targets-len: length? face/vid-targets
				repeat i targets-len [
					target: face/vid-targets/:i 
					either all [
						target/3  			
						within?  event/offset target/1 target/2 
					][
						data-addr: target/5
						draw-addr: target/6
						row-num: target/5/y
						col-num: target/5/x
						
						-vid-code-: either find face/freeform-vid target/4 [
							face/virtual-cols/(data-addr/x)/code/2/1
						][
							"" 
						]
						unset '-target-vid-object-
						set-vid-overlay-context face col-num row-num
						do bind load/all mold/only face/vid-renderer/(target/4)/restore face
						face/pane: layout/only new-lay: compose/deep bind load/all mold/only face/vid-renderer/(target/4)/render 'addr
						face/vid-targets/:i/3: #(false)
						break
					][
						face/vid-targets/:i/3: #(true)
					]
				]
				
			]		
			face/no-over: false
		]

		find-in-row: function [face [object!] event [event!]][
			code: ask-code
			clear face/cells-selected
			r: get-row-number face event
			foreach c face/col-index [
				if (form face/table-data/:r/:c) ~ code [append face/cells-selected as-pair c r]
			]
			show-marks face
		]

		find-in-col: function [face [object!] event [event! integer!]][
			if code: ask-code [
				code: load code
				col: case [
					event? event [get-col-number face event]
					face/sheet? [face/col-index/:col]
					true   [col]
				]

				clear face/filtered/y
				face/row-index: skip head face/row-index face/top/y
				filter-rows face col code
				face/row-index: head face/row-index
				clear face/cells-selected
				index-col: index? find face/col-index col
				foreach r face/filtered/y [
					index-row: index? find face/row-index r
					append face/cells-selected as-pair index-col index-row
				]
				if not empty? face/cells-selected [
					first-found: index? find face/row-index face/filtered/y/1
					scroll face 'y first-found - face/current/y - 1
					face/marks/-1: 0.220.0.220
					show-marks face
				]
			]
		]

		; OPEN

		open-red-type-table: func [
			{Opens .red or .redtbl file. '.red' by default}
			face [object!] 
			fdata [block!] 
			/only 
			/redtbl {Opens .redtbl file}
			/local opts i col type sz
		][
			face/starting?: yes
			clear-table-state face 
			
			either redtbl [
				opts: fdata/options
				data: face/table-data: fdata/table-data				
			][			
				either only [
					opts: fdata
				][
					opts: fdata/2
					face/table-data: remove/part fdata 2	;-- system/words/data: has already been set to table-data
				]
			]
			recast-none opts
			face/sheet?: to-logic find [true on yes] opts/sheet
			either face/sheet? [
				put face/options 'sheet yes
				put face/options 'auto-col face/auto-col?: yes
				put face/options 'auto-row face/auto-row?: yes
			][
				face/auto-col?: to-logic find [true on yes] opts/auto-col
				face/auto-row?: to-logic find [true on yes] opts/auto-row
				put face/options 'auto-col face/auto-col?
				put face/options 'auto-row face/auto-row?
			]
			table-obj: face 
			init-grid face
			init-indices/only face
			if opts/frozen-cols [append clear face/frozen-cols opts/frozen-cols ]
			if opts/frozen-rows [append clear face/frozen-rows opts/frozen-rows ]
			if opts/read-only-rows [append clear face/read-only-rows opts/read-only-rows ]
			if opts/read-only-cols [append clear face/read-only-cols opts/read-only-cols ]
			if opts/auto-incr [append clear face/auto-incr opts/auto-incr ]
			if opts/col-names [append clear face/col-names opts/col-names ]
			face/frozen: as-pair length? face/frozen-cols length? face/frozen-rows
			
			append clear face/col-index either opts/col-index [opts/col-index][face/default-col-index]
			append clear face/row-index either opts/row-index [opts/row-index][face/default-row-index]
			face/default-col-index: copy face/col-index 
			face/default-row-index: copy face/row-index 
			
			either sz: opts/sizes [
				if sz/x [face/sizes/x: to-map sz/x]
				if sz/y [face/sizes/y: to-map sz/y]
			][
				if sz: opts/col-sizes [face/sizes/x: to-map sz]
				if sz: opts/row-sizes [face/sizes/y: to-map sz]
			]
			either opts/col-type  [
				face/col-type: to-map opts/col-type
				if only [
					foreach [col type] body-of face/col-type [
						set-col-type/only face col type
					]
				]
			][
				face/col-type: clear face/col-type
			]

			face/box: any [opts/box face/default-box]
			face/top: case/all [
				(x: face/frozen/x) > 0 [x: index? find face/col-index face/frozen-cols/:x]
				(y: face/frozen/y) > 0 [y: index? find face/row-index face/frozen-rows/:y]
				true [as-pair x y]
			]
			face/current:  any [opts/current  face/top]
			face/cells-selected: any [opts/selected [1x1]]
			face/anchor:   any [opts/anchor   1x1]
			face/active:   any [opts/active   1x1]

			face/pos: face/active - face/current + face/frozen

			either opts/names [
				face/names: to-map opts/names
				foreach name keys-of face/names [
					name-selected/reload face name
				]
			][
				clear face/names
			]
			face/scroller/x/position: face/current/x + 1
			face/scroller/y/position: face/current/y + 1
			set-freeze-point2 face
			adjust-scroller face
			set-last-page face

			face/draw: copy []
			face/marks: insert tail face/draw [pen 0.0.255 line-width 2.5 fill-pen 0.0.0.220]
			either redtbl [
				face/virtual-cols: fdata/virtual-cols
				face/vid-state: fdata/vid-state 			
				face/vid-overlays: fdata/vid-overlays 
				face/code-overlays: fdata/code-overlays 
				if fdata/defaults [ face/defaults: fdata/defaults ]
				if fdata/col-align [ face/col-align: fdata/col-align ]				
				if fdata/colors [ face/colors: fdata/colors ]				
			][

				if all [	;-- gurzgri patch
					face/data 
					file? face/data 
					exists? redbin-filename: to-file rejoin [ head (remove/part (skip tail copy face/data -4) 4) ".redbin" ]
				][					
					redbin-data: load/as redbin-filename 'redbin
					face/virtual-cols: 	redbin-data/virtual-cols
					face/vid-state: 	redbin-data/vid-state 			
					face/vid-overlays: 	redbin-data/vid-overlays 
					face/code-overlays: redbin-data/code-overlays 
					if redbin-data/defaults [ face/defaults: redbin-data/defaults ]
					if redbin-data/col-align [ face/col-align: redbin-data/col-align ]
					if redbin-data/col-names [ face/col-align: redbin-data/col-names ]
				]
			]
			face/name: either file? face/data [
				first split-filename second split-path face/data 
			][
				"none"
			]
			fill face
			show-marks face
			no-over: true
			
		]

		open-table: func [
			face [object!]
			/with state [file! block!] ;TBD
			/path file-path [file!]
			/local file opts bin-data
		][
			
			f-path: either path [ file-path ][ system/options/path ]
			either with [ 
				file: state 
			][
				file: request-file/title/file/filter 
					"Open file" f-path ["Red Table" "*.redtbl" "Red File" "*.red" "CSV" "*.csv" "All Files" "*.*"]
			]
					
			if file [
				face/data: file
				data: load file
				if value? '-target-vid-object- [ -target-vid-object-/visible?: false ]
				case [
					all [
						%.red = suffix? file
						data/1 = 'Red
						block? opts: data/2
					][	
						open-red-type-table face data 
					]
					%.redtbl = suffix? file [
						bin-data: load/as file 'redbin 
						open-red-type-table/redtbl face bin-data 
					]						
					true [ 
						clear-table-state face 
						set-table-template-data face face/data
						init face 
					]				
				]
			]
			face/no-over: true
			file
		]

		open-big-table: function [face [object!] /with file][
			if any [file file: request-file/title/file/filter "Open large file" system/options/path ["Red Table" "*.redtbl" "Red File" "*.red" "CSV" "*.csv" "All Files" "*.*"] ] [
				face/big-size: length? read/binary file
				face/big-length: length? csv: head clear find/last read/binary/part file 1000'000 lf
				face/data: file

				face/table-data: load-csv to-string csv
				open-red-type-table/only face [face/frozen-rows: [1]]
			]
		]

		next-chunk: function [face [object!]][
			file: face/data
			face/big-last: face/big-last + face/big-length + 1
			append face/prev-lengths face/big-length
			state: save-state/only/with face [col-sizes col-types frozen-cols] ;col-index ? why error?
			if attempt [found: find/last read/binary/seek/part file face/big-last 1000'000 lf] [
				face/big-length: length? csv: head clear found
				csv: to-string csv
				either error? loaded: load-csv csv [loaded halt][
					face/table-data: loaded
				]
				open-red-type-table/only face state
			]
		]

		prev-chunk: function [face [object!]][
			file: face/data
			state: save-state/only/with face [col-sizes col-types frozen-cols]
			if not empty? face/prev-lengths [
				face/big-length: take/last face/prev-lengths
				face/big-last: face/big-last - face/big-length - 1
				csv: read/binary/seek/part file face/big-last face/big-length
				csv: to-string csv
				either error? loaded: load-csv csv [loaded halt][face/data: loaded]
				open-red-type-table/only face state
			]
		]
		
		recast-none: function [
			{Sets all items with word 'none to real #(none)} 
			series [block!]
		][
			s-len: length? series
			repeat item s-len [
				if series/:item = 'none [
					series/:item: #(none)
				]
			]
		]		

		use-state: function [
			face [object!]
			/with opts [block!]
			/file filename [file!]
		][
			either with [
				state: opts
			][
				either file [
					state: load filename
				][
					if file: request-file/title/file/filter "Select state to use ..." system/options/path 
						[ "All Files" "*.*" "Red Table" "*.redtbl" "Red File" "*.red" "CSV" "*.csv" ] [
						state: load file
					]
				]
			]
			if state [open-red-type-table/only face state]
		]

		; SAVE

		get-table-state: func [face [object!]][
			compose/only [
				frozen-rows: (face/frozen-rows)
				frozen-cols: (face/frozen-cols)
				top:         (face/top)
				current:     (face/current)
				col-sizes:   (body-of face/sizes/x)
				row-sizes:   (body-of face/sizes/y)
				box:         (face/box)
				row-index:   (face/row-index)
				col-index:   (face/col-index)
				auto-col:    (face/options/auto-col)
				auto-row:    (face/options/auto-row)
				col-type:    (body-of face/col-type)
				cells-selected: (face/cells-selected)
				anchor:      	(face/anchor)
				active:      	(face/active)
				names:       	(body-of face/names)
				;defaults:    	(body-of face/defaults)
				scroller-x:  	(face/scroller/x/position)
				scroller-y:  	(face/scroller/y/position)
				read-only-rows: (face/read-only-rows)
				read-only-cols: (face/read-only-cols)
				auto-incr:      (face/auto-incr)
				col-names:  	(face/col-names)
			]
		]

		save-state: function [face [object!] /only /with included [block!] /except excluded [block!]][
			state: get-table-state face

			if any [with except] [
				state: to map! state
				foreach key keys-of state [
					case/all [
						with   [if not find included key [remove/key state key]]
						except [if     find excluded key [remove/key state key]]
					]
				]
				state: to block! state
			]

			either only [state][
				if file: request-file/save/title/file/filter "Save state as ..." system/options/path 
					[ "All Files" "*.*" "Red Table" "*.redtbl" "Red File" "*.red" "CSV" "*.csv" ][
					save file state
				]
			]
		]

		save-red-table: function [face [object!]][
			out: new-line/all face/table-data true
			opts: get-table-state face
			save/header face/data out opts
			
			redbin-filename: to-file rejoin [ head (remove/part (skip tail copy face/data -4) 4) ".redbin" ]
			save/as redbin-filename
				rdx: reduce [ 
					to-set-word 'virtual-cols 	to map! to block! face/virtual-cols 
					to-set-word 'vid-state  	to map! to block! face/vid-state 
					to-set-word 'vid-overlays  	to map! to block! face/vid-overlays
					to-set-word 'code-overlays  to map! to block! face/code-overlays
					to-set-word 'defaults       to map! to block! face/defaults
					to-set-word 'col-align      to map! to block! face/col-align
					to-set-word 'col-names    			to block! face/col-names
					to-set-word 'colors         to map! to block! face/colors
		]
				'redbin
		]
		
		save-redtbl: function [face [object!]][ 
			out: new-line/all face/table-data true
			opts: get-table-state face
			
			redbin-filename: to-file rejoin [ head (remove/part (skip tail copy face/data -7 ) 7) ".redtbl" ]
			save/as redbin-filename
				rdx: reduce [
					to-set-word 'options				to block! opts
					to-set-word 'table-data			    to block! out  
					to-set-word 'virtual-cols 	to map! to block! face/virtual-cols 
					to-set-word 'vid-state  	to map! to block! face/vid-state 
					to-set-word 'vid-overlays  	to map! to block! face/vid-overlays
					to-set-word 'code-overlays  to map! to block! face/code-overlays
					to-set-word 'defaults       to map! to block! face/defaults
					to-set-word 'col-align      to map! to block! face/col-align
					to-set-word 'colors         to map! to block! face/colors
				]
				'redbin
		]
		

		save-table: function [face [object!]][
			either file? file: face/data [
				switch/default suffix? file [
					%.red 		[save-red-table face]
					%.redtbl 	[save-redtbl face]
					%.csv 		[write file to-csv face/table-data]
				][
					write file face/table-data
				]
			][
				file: save-table-as face
			]
			face/no-over: true
			on-saved face
			file
		]

		save-table-as: func [face [object!] /path file-path [file!] /local file][
			f-path: either path [ file-path ][ system/options/path ]
			if file: request-file/save/title/file/filter "Save file as" f-path
				["Red Table" "*.redtbl" "Red File" "*.red" "CSV" "*.csv" "All Files" "*.*"] [
				face/data: file
				save-table face
			]
			file
		]

		on-scroll: function [face [object!] event [event! none!]][
			if 'end <> key: event/key [
				dim: pick [y x] event/orientation = 'vertical
				steps: count-steps face event dim
				if steps [scroll face dim steps]
				show-marks face
			]
		]

		on-wheel: function [face [object!] event [event! none!]][;May-be switch shift and ctrl ?
			dim: pick [x y] event/shift?
			steps: to-integer -1 * event/picked * either event/ctrl? [face/grid/:dim][system/words/select [x 1 y 3] dim]
			scroll face dim steps
			show-marks face
		]

		on-down: func [face [object!] event [event! none!] /local addr col][
			set-focus face
			face/on-border?: on-border face to-pair event/offset
			if not face/on-border? [
				hide-editor face
				face/pos: either pair? event [event][get-draw-address face event]
				face/same-offset?: yes
				case [
					event/shift? [mark-active/extend face face/pos]
					event/ctrl?  [mark-active/extra face face/pos]
					true         [
						mark-active face face/pos
					]
				]
			]
			do-actor face none 'click
		]
		
		on-click:   func [face [object!] event [event! none!]] []
		on-change:  func [face [object!] event [event! none!]] []
		on-filter: func [face [object!]][]
		on-unfilter: func [face [object!]][]
		on-changed: func [face[object!]][]
		trigger-on-changed: func [face [object!]][
			either face/changed? [
				on-changed face 
			][
				face/changed?: #(true)
			]
		]
		on-saved: func [face[object!]][]
		
		on-unfocus: func [face [object!]][
			if all [									;accomodate vid cells.
				face/tbl-editor
				face/tbl-editor/visible?
			][			
				hide-editor face
				unmark-active face
			]
		]

		on-over: func [face [object!] event [event! none!]][
			table-obj: face
			do-over face event
		]

		on-up: function [face [object!] event [event! none!]][
			case [
				face/on-border? [
					set-grid-offset face
					set-last-page face
				]
				event/ctrl? [
					if none? address: get-draw-address face event [ exit ]
					case/all [
						face/pos/x <> address/x [move at face/col-index face/pos/x  at face/col-index address/x]
						face/pos/y <> address/y [move at face/row-index face/pos/y  at face/row-index address/y]
					]
					fill face
				]
				true [
					if all [
						face/same-offset?
						if none? address: get-data-address face event [ exit ]
						face/col-type/(address/x) = 'logic!
					][
						face/table-data/(address/y)/(address/x): not face/table-data/(address/y)/(address/x)
						fill face
					]
				]
			]
			address
		]
		
		on-dbl-click: function [face [object!] event [event! none!]][
			do-actor face none 'change
			use-editor/edit-mode face event
		]

		on-key-down: func [face [object!] event [event! none!]][
			hot-keys face event	
		]
		
		on-create: func [face [object!] event [event! none!]] [
			face/frozen-nums/x: face/frozen-cols	;-- need to properly initialize these when table is used as a style
			face/frozen-nums/y: face/frozen-rows					
		]
		
		on-created: func [
		    face  [object!]
		    event [event! none!]
		    /local file data config bin-data
		][
		    make-scroller face
		    case [
				all [
					file? file: face/data
					%.red = suffix? file
					data: load file		;-- this is system/words/data GLOBAL
					data/1 = 'Red
					block? config: data/2
				][
					open-red-type-table face data 
				]		        

		        ; Handle .redtbl files
		        all [
					file? file: face/data
					%.redtbl = suffix? file 		        	
		        ][
		            bin-data: load/as file 'redbin
		            open-red-type-table/redtbl face bin-data
		        ]

		        ; Default handling for raw data or config options
		        true [
		            if face/data = %./ [ 
		            	status-msg "An invalid data file has been specified. Please select another file."
		            	exit 
		            ]
		            set-table-template-data face face/data
		            either config: face/options/config [
		                if file? config [config: load config]
		                open-red-type-table/only face config
		            ][
		                if face/options/sheet [
		                    face/sheet?: yes
		                    put face/options 'auto-col face/auto-col?: yes
		                    put face/options 'auto-row face/auto-row?: yes
		                ]
		                init face
		            ]
		        ]
		    ]

			if all [
				not file? face/data
				to-logic face/options/auto-save
			][
				status-msg [ "Can not use 'auto-save' when the data for the table is a Red block." newline "auto-save only works when the data is a file." ]
			]
		]		
		
		on-menu: function [face [object!] event [event! none!]][do-menu face event]
		
		update-vid-cell: function [ 
			face [object!] 
			val 
			data-addr [pair!]
			draw-addr [pair!]
		][
			
			either data-addr/x < 0 [ 
				vid-name: to-lit-word rejoin [ "cell" data-addr]
				face/vid-state/:vid-name: val	
			][
				face/table-data/(data-addr/y)/(data-addr/x): val
				inject-update face data-addr draw-addr val 
			]			
			fill face
		]
		
		multi-line-editor: function [
			face [object!]
			event [event!]
		][
			set [ 'data-addr 'draw-addr ] get-data-address/both face face/pos
			advanced-cell-edit/address face data-addr draw-addr
		]
		
		query: function [
			table-face [object!]
			spec [block!] {Allows select, where with and/or, order, limit }
			/index {return a block the index positions [ cols rows ] }
		][
		    rows: skip table-face/table-data table-face/top/y
		    
		    if ((length? table-face/col-names) / 2 ) <> (length? table-face/col-index )[
		    	request-message {The "query" function needs all column names to be defined.^/Please use the Menu: "Column/Set Column Names" to define the columns. Once this is done you can use the "query" function.}
		    	return none
		    ]
		    selected: headers: collect [ 
		    	foreach [ nam num ] table-face/col-names [ 
		    		if num > 0 [ keep nam ]
		    	]
		    ]
		    zselected: collect [ 
		    	foreach [ nam num ] table-face/col-names [ 
		    		keep nam
		    	]
		    ]
		    where-conds: copy []
		    where-ops: copy []
		    order-col: none
		    order-dir: 'asc
		    limit-n: none
		    
		    ;-- Parse the spec, collecting multiple where clauses
		    parse spec [
		        any [
		            'select set selected block!
		          | 'where set cond block! (append/only where-conds cond)
		            any [
		                ['and (append where-ops 'and) | 'or (append where-ops 'or)]
		                set cond block! (append/only where-conds cond)
		            ]
		          | 'order 'by set order-col string! opt ['desc (order-dir: 'desc)]
		          | 'limit set limit-n integer!
		        ]
		    ]
		    ;-- col-indices: collect [foreach n selected [keep (system/words/select table-face/col-names n)]]
		    
		    col-indices: collect [
		    	foreach [ nam num ] table-face/col-names [
		    		if num < 0 [ keep num ]
		    		if find selected nam [ keep num ]
		    	]
		    ]
		    
		    ;-- Build combined condition evaluator
		    eval-where: function [ctx conds ops][
		        if empty? conds [return true]
		        
		        result: do bind copy/deep conds/1 ctx
		        
		        repeat i length? ops [
		            next-result: do bind copy conds/(i + 1) ctx
		            result: either ops/:i = 'and [
		                result and next-result
		            ][
		                result or next-result
		            ]
		        ]
		        result
		    ]
		    
		    if selected = [*] [ selected: headers ]
		    
		    ;-- Process rows
		    result: reduce [selected]

    		row-indices: copy []  ; Track matching row indices
    		row-num: 1  ; Start counting rows (1-based index into 'rows')		    
		    
		    foreach row rows [
				ctx: context collect [
				    foreach [col-name col-num] table-face/col-names [
				    	if col-num > 0 [
				        	keep to-set-word col-name
				        	keep row/:col-num
				        ]
				    ]
				]		        
		        if eval-where ctx where-conds where-ops [
		            indices: collect [foreach c selected [keep index? find headers c]]
		            append/only result collect [
		            	foreach i indices [keep row/:i]
		            ]
		            append row-indices (row-num + 1)  ; Store the row index
		        ]
		        row-num: row-num + 1
		    ]
		    
			if order-col [
			    ofs: index? find selected order-col
			    sort/compare next result func [a b][
			        case [
			            a/:ofs < b/:ofs [-1]
			            a/:ofs > b/:ofs [1]
			            true [0]
			        ]
			    ]
			    if order-dir = 'desc [reverse next result]
			]
		    
		    ;-- Limit
		    if limit-n [
		        clear skip result limit-n + 1
		    ]
		    return either index [
		    	reduce [ col-indices row-indices ]
		    ][
		    	result	
		    ]
		]		

	] ;-- end of table actors
]

table-event-handler: func [
    face [object!]
    event [event!]
][
	if all [
		event/key = #"^-"
		event/type = 'key-down
		any [
			(select face 'identifier ) = "table-template"
			find face/extra 'on-table-tab
		]
	][
		direction: either find event/flags 'shift [ 'left ] [ 'right ]
		either find face/extra 'on-table-tab [
			face/visible?: no
			face/extra/table/actors/update-data face face/extra/table
			set-focus face/extra/table			
			face/extra/table/actors/hot-keys/feed face/extra/table none direction
		][
			face/actors/hot-keys/feed face none direction 
		]	
		return 'done		
	]
	if all [ 
		event/type = 'wheel
		dis: select face/extra 'disable-wheel 
		dis = 'true
	][
		return 'stop
	]
	if all [
		event/key = #"^-"
		event/type = 'key-down
		find face/extra 'tab-key-to-key-down
	][
		do-actor face event 'key-down
	]	
	
]

insert-event-func 'table-event-handler :table-event-handler
        
style/init 'table tbl [
	face: self
	face/actors/on-create: func [face [object!] event [event! none!]]  ;-- allows template to operate as a style. 
		head insert body-of :face/actors/on-create [
			frozen-nums/x: frozen-cols
			frozen-nums/y: frozen-rows					
		]
]	
