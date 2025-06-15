Red [
	title: "table-template"
	author: [@toomasv  custom fork by: @mikeyaunish]
	file: %table-template.red
	date: 15-JUNE-2025
]

#include %style.red
#include %re.red
~: make op! func [a b][re a b]
tbl: [
	type: 'base
	size: 317x217
	color: silver
	flags: [scrollable all-over]
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
	tbl-editor: 		copy []
	
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
	sizes/x:       	make map! (copy [])
	sizes/y:       	make map! (copy [])
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
	max-usable: 0x0

	menu: [
		"Cell" [
			"Freeze"   freeze-cell
			"Unfreeze" unfreeze-cell
			"Edit"     edit-cell
		]
		"Row" [
			"Freeze"         freeze-row
			"Unfreeze"       unfreeze-row
			"Default height" default-height
			"Show" [
				"Select"     select-row
				"Hide"       hide-row
				"Unhide"     unhide-row
				"Remove"     remove-row
				"Restore"    restore-row
				"Delete"     delete-row
				"Insert"     insert-row
				"Append"     append-row
				"Insert virtual" insert-virtual-row
				"Append virtual" append-virtual-row
			]
			"Move" [
				"Top"        move-row-top
				"Up"         move-row-up
				"Down"       move-row-down
				"Bottom"     move-row-bottom
				"By ..."     move-row-by
				"To ..."     move-row-to
			]
			"Find ..."       find-in-row
			;"Edit"           edit-row
		]
		"Column" [
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
			"Show" [
				"Select"        select-col
				"Default width" default-width
				"Full height"   full-height
				"Hide"          hide-col
				"Unhide"        unhide-col
				"Remove"        remove-col
				"Restore"       restore-col
				"Delete"        delete-col
				"Insert"        insert-col
				"Append"        append-col
				"Insert virtual" insert-virtual-col
				"Append virtual" append-virtual-col
			]
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
				"integer!" integer!
				"float!"   float!
				"percent!" percent!
				"string!"  string!
				"char!"    char!
				"block!"   block!
				"date!"    date!
				"time!"    time!
				"logic!"   logic!
				"tuple!"   tuple!
				"image!"   image!
				"Load"     load
				"Draw"     draw
				"Do"       do
				"Icon"     icon
			]
			"Set default"  set-default
		]
		"Table" [
			"Unhide"    [
				"All"    unhide-all
				"Row"    unhide-row
				"Column" unhide-col
			]
			"Default height" remove-full-height
			;"Default width"  set-table-default-width
			"Open ..."    open-table
			"Open big ..." open-big
			"Save"        save-table
			"Save as ..." save-table-as
			"Use state ..." use-state
			"Save state as ..." save-state
			"Clear color" clear-color
			"Select named range" []
			"Forget names" forget-names
		]
		"Selection" [
			"Copy"      copy-selected
			"Cut"       cut-selected
			"Paste"     paste-selected
			;"Transpose" transpose
			"Set Color" color-selected
			"Set Name"  name-selected
		]
	]
	actors: [
		on-create: func [face [object!] event [event! none!]][] ;-- placeholder to allow init changes
		
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
				face [object!]
				/local grid-size
		][
			grid-size: face/size - face/scroller-width ;-- bare bones grid-size without frozen
			foreach dim [x y][
				cur: face/current/:dim
				i: k: sz: 0
				if 0 < steps: face/total/:dim - cur [
					repeat i steps [
						j: cur + i
						sz: to-integer (sz + get-size face dim face/index/:dim/:j)
						if sz >= grid-size/:dim [
							if sz > grid-size/:dim [
								i: i - 1
							]
							break
						]
					]
				]
				face/usable-grid/:dim: i
			]
			face/max-usable: max face/usable-grid face/max-usable
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

		set-last-page: function [ face [object!] ][
			foreach dim [x y][
				t: face/total/:dim
				j: sz: 0
				while [
					all [
						r: face/index/:dim/(t - j)
						sz: sz + s: get-size face dim r
						sz <= face/grid-size/:dim
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

		set-default: function [face [object!] event [event! integer!]][
			col: get-col-number face event
			val: either val: face/defaults/:col [ask-code/with val][ask-code]
			either all [
				series? val: load val
				empty? val
			][
				remove/key face/defaults col
			][
				face/defaults/:col: val
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

		get-data-address: function [face [object!] event [event! pair!]][
			cell: either event? event [cell: get-draw-address face event][event]
			out: get-logic-address face cell
			out
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
			any [face/sizes/:dim/:idx face/box/:dim]
		]

		get-color: func [i [integer!] frozen? [logic!]][
			case [frozen? [silver] odd? i [white] 'else [snow]]
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

		set-data: func [face [object!] spec [file! url! block! pair! none!] /local row][
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
			face/total/x: length? first face/table-data
			if face/options/auto-col [face/total/x: face/total/x + 1]
			if face/options/auto-row [face/total/y: face/total/y + 1]
			face/grid-size: face/size - face/scroller-width
			clear face/sizes/x
			clear face/sizes/y
			clear face/frozen-rows
			clear face/frozen-cols
		]

		init-indices: func [face [object!] /only /local i][
			;Prepare indices
			face/indices/x: make map! min 10 face/total/x                         ;Room for index for each column
			face/indices/y: make map! min 10 face/total/y                         ;Room for index for some rows     @@ May be on request?
			either face/default-row-index [
				clear face/filtered/y
				clear face/row-index
				clear face/default-row-index
			][
				face/filtered/y:
					copy face/row-index:                                         ;Active row-index
					copy face/default-row-index: make block! face/total/y        ;Room for row numbers
			]
			either face/default-col-index [
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
			face/marks: insert tail face/draw [line-width 2.5 fill-pen 0.0.0.220]
			unless only [
				mark-active face 1x1
				set-grid-offset face
			]
		]

		init: func [face [object!]][
			face/freeze-point: face/frozen: face/top: face/current: 0x0
			face/selected: copy []
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
		][
			either index-x <= face/total/x [
				data-x: face/col-index/:index-x
				cell/4:  any [
					face/colors/(as-pair data-x data-y)
					get-color draw-y frozen?
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
					][
						cell/11/1: 'text
						cell/11/2:  4x2  +  p0
						cell/11/3: form case [
							all [data-y > 0 data-x > 0][
								switch/default type [
									do [
										do face/table-data/:data-y/:data-x
									]
									logic! [either face/table-data/:data-y/:data-x [face/true-char][face/false-char]]
								][
									any [face/table-data/:data-y/:data-x face/dummy]
								]
							]
							data-x = 0 [either face/sheet? [index-y][data-y]]
							data-y = 0 [either face/sheet? [index-x][data-x]]
							true [
								cell/4: 250.220.220
								case [
									all [v: face/virtual-rows/:data-y v: v/data/:data-x] [form v]
									all [v: face/virtual-cols/:data-x v: v/data/:data-y] [form v]
									true [face/dummy]
								]
							]
						]
					]
				]
			][
				fix-cell-outside face cell 'x
			]
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
		][

			data-x: face/col-index/:index-x
			either frozen? [
				text: form case [
					data-x = 0 [either face/sheet? [index-y][data-y]]
					data-y = 0 [either face/sheet? [index-x][data-x]]
					true [any [face/table-data/:data-y/:data-x face/dummy]]
				]
				cell: compose/only [
					line-width 1
					fill-pen (get-color draw-y frozen?)
					box (p0) (p1)
					clip (p0 + 1) (p1 - 1)
					(reduce ['text p0 + 4x2 text])
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
					true [
						text: form case [
							data-x = 0 [either face/sheet? [index-y][data-y]]
							data-y = 0 [either face/sheet? [index-x][data-x]]
							true [any [face/table-data/:data-y/:data-x face/dummy]]
						]
					]
				]
				cell: compose/only [
					line-width 1
					fill-pen (get-color draw-y frozen?)
					box (p0) (p1)
					clip (p0 + 1) (p1 - 1)
					(reduce case [
						draw? [['translate  p0 + 1x1  drawing]]
						true  [['text       p0 + 4x2  text]]
					])
				]
				insert/only at row draw-x cell
			]
		]

		set-cell: function [
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
			either block? cell: row/:grid-x [
				fill-cell face cell data-y index-y index-x grid-y grid-x frozen? p0 p1
			][
				if index-x <= face/total/x [
					add-cell face row data-y index-y index-x grid-y grid-x frozen? p0 p1
				]
			]
			px1
		]

		set-cells: function [
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
				grid-x: grid-x + 1
				index-x: face/current/x + grid-x
				either index-x <= face/total/x [
					px0: to-integer set-cell face grid-row data-y index-y index-x grid-y grid-x frozen? px0 py0 py1
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

		fill: function [
			face [object!] /only dim [word!]
		][
			recycle/off
			system/view/auto-sync?: off

			py0: 0
			draw-y: 0
			index-y: 0
			while [all [py0 < face/size/y index-y < face/total/y]][
				draw-y: draw-y + 1            ; Skim through draw rows; which number?
				frozen?: draw-y <= face/frozen/y   			; Is it frozen?
				index-y: get-index-row face draw-y 		; Corresponding index row
				data-y: get-data-row face draw-y   		; Corresponding data row
				draw-row: face/draw/:draw-y   			; Actual draw-row
				unless block? draw-row [      			; Add new row if missing
					insert/only at face/draw draw-y draw-row: copy [] ; Make an empty row
					;-- self/marks: next marks    ; Move marks-pointer further by one (new row before it)
					face/marks: next face/marks    ; Move marks-pointer further by one (new row before it)
				]
				sy: get-row-height face data-y frozen? ;Row height is used in each cell
				py1: to-integer ( py0 + sy )   ; Accumulative height

				px0: 0                        ; Start from leftmost cell
				repeat draw-x face/frozen/x [      ; Render frozen cells first
					index-x: get-index-col face draw-x ; Which index is given draw column
					px0: to-integer set-cell face draw-row data-y index-y index-x draw-y draw-x true px0 py0 py1 ;last: frozen
				]

				grid-row: skip draw-row face/frozen/x ; Move index to unfrozen cells
				grid-y: draw-y - face/frozen/y
				set-cells face grid-row data-y index-y grid-y frozen? py0 py1
				py0: py1
			]
			; Move cells in unused rows outside of visible borders
			while [all [block? draw-row: face/draw/(draw-y: draw-y + 1) draw-row/1/6/y < face/size/y]][
				foreach cell draw-row [fix-cell-outside face cell 'y]
			]
			face/scroller/y/page-size: face/grid/y
			face/scroller/x/page-size: face/grid/x
			show face
			system/view/auto-sync?: on
			recycle/on
			face/draw: face/draw
			auto-save face
		]

		ask-code: function [/with default /txt deftext][
			view [
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
			append table/parent/pane layout/only compose/deep [
				at 0x0 tbl-editor: field hidden with [
					options: [text: none]
					extra: #[]
				] on-enter [
					face/visible?: no
					update-data face (table)
					set-focus face/extra/table
				] on-key-down [
					switch event/key [
						#"^[" [ ;esc
							append clear face/text face/options/text
							face/visible?: no
						]
						down  [
							show-editor face/extra/table face/extra/cell + 0x1
						]
						up    [show-editor face/extra/table face/extra/cell - 0x1]
						#"^-" [
							either find event/flags 'shift [
								show-editor face/extra/table face/extra/cell - 1x0
							][
								show-editor face/extra/table face/extra/cell + 1x0
							]
						]
					]
				] on-focus [
					face/options/text: copy face/text
				]
			]
			table/tbl-editor: tbl-editor
		]

		use-editor: function [face [object!] event [event! none!]][
			either face/tbl-editor <> [] [
				if tbl-editor/visible? [
					update-data tbl-editor face 	;Make sure field is updated according to correct type
					face/draw: face/draw     		;Update draw in case we edited a field and didn't enter
				]
			][
				make-editor face
			]
			cell: get-draw-address face event                     ;Draw-cell address
			show-editor face cell
		]

		show-editor: function [face [object!] cell [pair!]][
			addr: get-data-address face cell
			col: addr/x
			ofs:  get-cell-offset face cell
			either col <> 0 [
				;if auto [col: col + 1]
				;-- tbl-editor/extra/table: face                      ;Reference to table itself
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
				face/tbl-editor/extra/addr: addr                       ;Register data address
				face/tbl-editor/extra/cell: cell                       ;Register draw-cell address
				fof: to-pair face/offset                          ;Compensate offset for VID space
				edit face fof + ofs/1 ofs/2 - ofs/1 txt
			][face/tbl-editor/visible?: no]
		]

		hide-editor: function [face [object!]] [
			if all [
				face/tbl-editor <> []
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
							append out change-to-address1 x y mx my
						]
					]
					out
				)
			|	change ["R" copy r int "C" copy c int | "C" copy c int "R" copy r int] (
					y: pick face/row-index r: to-integer r
					x: pick face/col-index c: to-integer c
					change-to-address2 x y c r
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
						append out change-to-address3 x y index? find face/col-index x my
					]
					out
				)
			|	change ["R" copy r int] (
					x: addr/x ;pick face/col-index addr/x
					y: pick face/row-index r: to-integer r
					change-to-address4 x y index? find face/col-index x r
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
						append out change-to-address5 x y mx index? find face/row-index y
					]
					out
				)
			|	change ["C" copy c int] (
					x: pick face/col-index c: to-integer c
					y: addr/y
					change-to-address6 x y c index? find face/row-index y
				)
			|	skip
			]]
		]

		update-data: function [face [object!] table-face [object!]][; face is edited field here
			switch type?/word addr2: addr: face/extra/addr [ ; This is data-address
				pair! [
					case [
						addr/y > 0 [;Don't update auto-row
							case [
								addr/x > 0 [ ; Don't update auto-col
									type: type? table-face/table-data/(addr/y)/(addr/x)
									;if face/extra/table/options/auto-col [addr2/x: addr/x + 1]  ;@@ ??
									table-face/table-data/(addr/y)/(addr/x): switch/default table-face/col-type/(addr2/x) [
										logic!      [tx: attempt [get face/data]]
										draw image! [tx: face/data]
										do          [tx: to-block face/text]
										icon        [tx: face/text]
									][
										;-- default 
										tx: face/text either none! = type [
												tx
											][
												to type tx
											]
									]
									cell:  face/extra/cell   ; This is draw-cell address
									draw-cell: face/extra/table/draw/(cell/y)/(cell/x)
									switch/default table-face/col-type/(addr2/x) [
										logic! [draw-cell/11/3: form either tx [table-face/true-char][table-face/false-char]]
										draw   [draw-cell/11:   compose/only [translate (draw-cell/9) (tx)]]
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
									][draw-cell/11/3: tx]
									;Update virtual rows and cols
									system/view/auto-sync?: off
									foreach [row vr] table-face/virtual-rows [
										if code: vr/default [
											repeat gx table-face/total/x - face/top/x [
												index-x: face/top/x + gx
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
											repeat gy table-face/total/y - face/top/y [
												index-y: face/top/y + gy
												row: table-
												face/row-index/:index-y
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
			fill face/extra/table ;Added temporarily for quick refreshing to update virtual rows
		]

		auto-save: function [ face [object!] ][
			if all [
				file? face/data
				to-logic face/options/auto-save
			][
				save-table face
			]
		]

		edit: function [face [object!] ofs [pair!] sz [pair!] txt [string!]][
			win: face/tbl-editor
			until [win: win/parent win/type = 'window]
			face/tbl-editor/offset:    ofs
			face/tbl-editor/size:      sz
			face/tbl-editor/text:      txt
			face/tbl-editor/visible?:  yes
			win/selected:         face/tbl-editor
		]

		edit-column: function [face [object!] event [event! none!]][
			col: get-col-number face event
			case [
				col > 0 [ ; Don't edit auto-col
					if code: ask-code [
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

		set-col-type: function [face [object!] event [event! integer!] /only typ [word!]][
			col: either event? event [get-col-number face event][event]
			if not all [not only col = 0][
				old-type: face/col-type/:col
				face/col-type/:col: type: either event? event [event/picked][typ]
				data: face/table-data
				forall data [
					either block? data/1 [
						if not find face/frozen-rows index? data [
							data/1/:col: switch/default type [
								draw do     [to block! any [data/1/:col face/dummy]]
								load image! [load any [data/1/:col face/dummy]]
								string!     [mold any [data/1/:col face/dummy]]
								logic! [
									case [
										all [series? data/1/:col empty? data/1/:col][
											data/1/:col: false                          ; Empty series -> false
										]
										logic? data/1/col []                            ; It's logic! already, do nothing
										all [string? data/1/:col  val: get/any to-word data/1/:col][
											data/1/:col: either logic? val [val][false] ; Textual logic values get mapped
										]
										none? data/1:col [data/1/:col: false]
										'else [data/1/:col: true]                       ; Should it be false instead?
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
			fill face
			show-marks face
		]

		hide-rows: function [face [object!] rows [block!]][
			foreach row rows [face/sizes/y/:row: 0]
			fill face
			show-marks face
		]

		hide-col: function [face [object!] event [event! integer!]][
			col: either integer? event [event][get-col-number face event]
			face/sizes/x/:col: 0
			fill face
			show-marks face
		]

		hide-column: function [face [object!] event [event! integer!]][
			hide-col face event
		]

		hide-columns: function [face [object!] cols [block!]][
			foreach col cols [face/sizes/x/:col: 0]
			fill face
			show-marks face
		]

		unhide: function [face [object!] dim [word!] /only][
			foreach [key val] face/sizes/:dim [
				if zero? val [remove/key face/sizes/:dim key]
			]
			unless only [
				fill face
				show-marks face
			]
		]

		unhide-all: function [face [object!]][
			foreach dim [x y][unhide/only face dim]
			fill face
			show-marks face
		]

		show-row: function [face [object!] event [event! none!]][]

		show-col: function [face [object!] event [event! none!]][]

		add-new-row: function [face [object!]][
			row: make block! face/total/x
			repeat col face/total/x [
				;if face/options/auto-col [col: col + 1] ;@@ ??? Should it?
				content: any [
					face/defaults/:col
					all [
						type: face/col-type/:col
						switch/default type [
							do draw image! [copy []]
							load icon [none]
						][make reduce type 0]
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
				addr: none
				source: make map! x
				code: make map! x
				data: make map! x
				default: none
			]
			len: negate 1 + length? face/virtual-rows
			face/virtual-rows/:len: vr
			face/total/y: face/total/y + 1
			len
		]

		add-virtual-col: function [face [object!]][
			y: face/total/y
			vc: object [
				addr: none
				source: make map! y
				code: make map! y
				data: make map! y
				default: none
			]
			len: negate 1 + length? face/virtual-cols
			face/virtual-cols/:len: vc
			face/total/x: face/total/x + 1
			len
		]

		refresh-view: func [face [object!]][
			set-last-page face
			adjust-scroller face
			fill face
			show-marks face
		]

		insert-row: function [face [object!] event [event!]][
			dr: get-draw-row face event
			r: get-index-row face dr
			add-new-row face
			insert/only at face/row-index r face/total/y
			refresh-view face
		]

		append-row: function [face [object!]][
			add-new-row face
			append face/row-index face/total/y
			refresh-view face
		]

		insert-virtual-row: function [face [object!] event [event! integer!]][
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

		insert-col: function [face [object!] event [event! none!]][
			dc: get-draw-col face event
			c: get-index-col face dc
			repeat i face/total/y [append face/table-data/:i none]
			face/total/x: face/total/x + 1
			insert/only at face/col-index c face/total/x
			refresh-view face
		]

		append-col: function [face [object!]][
			repeat i face/total/y [append face/table-data/:i none]
			face/total/x: face/total/x + 1
			append face/col-index face/total/x
			refresh-view face
		]

		insert-virtual-col: function [face [object!] event [event! integer!]][
			dc: get-draw-col face event
			ic: get-index-col face dc
			vc: add-virtual-col face
			insert/only at face/col-index ic vc
			refresh-view face
		]

		append-virtual-col: function [face [object!]][
			vc: add-virtual-col face
			append face/col-index vc
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

		delete-row: function [face [object!] event [event!]][
			dr: get-draw-row face event
			ri: get-index-row face dr
			remove at face/table-data rd: face/row-index/:ri
			remove at face/row-index ri
			repeat i length? face/row-index [
				if face/row-index/:i > rd [face/row-index/:i: face/row-index/:i - 1]
			]
			take/last face/default-row-index
			refresh-view face
		]

		delete-col: function [face [object!] event [event!]][
			dc: get-draw-col face event
			ci: get-index-col face dc
			cd: get-data-col face dc
			if cd > 0 [
				foreach row face/table-data [either block? row [remove at row cd][break]]
				remove at face/col-index ci
				repeat i length? face/col-index [
					if face/col-index/:i > cd [face/col-index/:i: face/col-index/:i - 1]
				]
				take/last face/default-col-index
				refresh-view face
			]
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
			move i: at face/row-index ri skip i step
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
			move i: at face/col-index ci skip i step
			fill face
			show-marks face
		]

		; MARKS

		set-new-mark: func [face [object!] active [pair!]][
			append face/selected face/anchor: face/active
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
						either '- = first skip tail face/selected -2 [
							change back tail face/selected face/active
						][
							repend face/selected ['- face/active]
						]
					]
					extra  [
						face/extend?: false face/extra?: true
						set-new-mark face face/active
					]
					true   [
						face/extra?: face/extend?: false
						clear face/selected
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
				clear face/selected
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
			parse face/selected [any [
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
				repend face/selected ['- e]
			]
			show-marks face
		]

		color-selected: function [face [object!] color [tuple! word! none!]][
			unless color [color: load ask-code]
			parse face/selected [any [s:
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

		name-selected: function [face [object!] name [word! none!]][
			unless name [name: ask-code]
			face/names/:name: copy face/selected
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
			fill face
			face/draw: face/draw
		]

		on-filter: func [face [object!]][]

		unfilter: func [face [object!]][
			clear face/filtered/y
			append clear head face/row-index face/default-row-index
			adjust-scroller face
			on-filter face
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
			if 0 <> step: set-scroller-pos face dim steps [
				dif: calc-step-size face dim step
				face/current/:dim: face/current/:dim + step
				hide-editor face
				set-grid face
				fill face
			]
			step
		]

		adjust-scroller: func [face [object!] /only][
			face/scroller/y/max-size:  max 1 face/total/y: length? face/row-index
			face/scroller/x/max-size:  max 1 face/total/x: length? face/col-index
			unless only [set-grid face]
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

			face/selected-range: copy face/selected
			clpbrd: copy ""
			parse face/selected [any [
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
			either single? face/selected [
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
				parse face/selected [any [
					end
				|	e:
				|	pair! '- pair! (q: (absolute e/3 - e/1) + 1 selected-size: q/x * q/y + selected-size)
				|	pair! (selected-size: selected-size + 1)
				]]
				either copied-size = selected-size [
					start: face/selected/1
					parse-selection face face/selected start
				][
					print "Warning! Sizes do not match."
				]
			]
			face/selected-data: head face/selected-data
			fill face
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

		select-row: function [face [object!] event [event! integer!] /add][
			ri: which-index face event 'row
			unless add [clear face/selected]
			repend face/selected [as-pair 1 ri '- as-pair face/total/x ri]
			show-marks face
		]

		select-col: function [face [object!] event [event! integer!] /add][
			ci: which-index face event 'col
			unless add [clear face/selected]
			repend face/selected [as-pair ci 1 '- as-pair ci face/total/y]
			show-marks face
		]

		select-name: function [face [object!] name [string!] /add][
			unless add [clear face/selected]
			append face/selected face/names/:name
			show-marks face
		]

		; More helpers

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
				c: absolute col
				idx: skip head face/row-index face/top/y
				sort/compare idx function [a b][
					attempt [case [
						all [loaded down][(load face/table-data/:b/:c) <= (load face/table-data/:a/:c)]
						loaded           [(load face/table-data/:a/:c) <= (load face/table-data/:b/:c)]
						down             [face/table-data/:b/:c <= face/table-data/:a/:c]
						true             [face/table-data/:a/:c <= face/table-data/:b/:c]
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
			fill face
			recycle/on
		]

		unsort: func [face [object!]][
			append clear face/row-index face/default-row-index
			adjust-scroller face
			fill face
		]

		resize: func [face [object!]][
			face/grid-size: face/size - face/scroller-width
			adjust-size face
			fill face
			show-marks face
		]

		hot-keys: function [face [object!] event [event! none!]][

			key: event/key
			step: switch key [
				down      [0x1]
				up        [0x-1]
				left      [-1x0]
				right     [1x0]
				page-up   [as-pair 0 negate face/grid/y]
				page-down [as-pair 0 face/grid/y]
				home      [as-pair negate face/grid/x 0] ;TBD
				end       [as-pair face/grid/x 0]        ;TBD
			]

			                           ;-- (min (face/active/y + 1) face/total/y) > min (face/current/y + face/max-usable/y - face/frozen/y) face/total/y
			

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
									(min (face/active/y + 1) face/total/y) > min (face/current/y + face/max-usable/y - face/frozen/y) face/total/y
								]
							all [key = 'up      face/frozen/y + 1    = face/pos/y y <> 'done]
							all [find [page-up page-down] key face/pos/y > face/frozen/y y <> 'done]
						][
							df: scroll face 'y step/y
							switch key [
								page-up   [if step/y < step/y: df [face/pos/y: face/pos/y - face/grid/y - step/y]]
								page-down [if step/y > step/y: df [face/pos/y: face/pos/y + face/grid/y - step/y]]
							]
							'y
						]
						any [
							;-- all [key = 'right face/frozen/x + face/grid/x = face/pos/x face/current/x < (face/total/x - face/last-page/x) x <> 'done]
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
								either '- = first s: skip tail face/selected -2 [
									s/2: s/2 + step
								][
									repend face/selected ['- s/1 + step]
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
					]
				][
					switch key [
						#"^M" [
							unless face/tbl-editor [make-editor face]
							show-editor face face/pos
						]
					]
				]
			]
		]

		do-menu: function [face [object!] event [event! none!]][
			switch/default event/picked [
				; TABLE
				open-table      [open-table face]
				save-table      [save-table face]
				save-table-as   [save-table-as face]
				save-state      [save-state face]
				use-state       [use-state face]
				unhide-all      [unhide-all  face]
				;force-state     [use-state/force face]
				clear-color     [clear face/colors fill face]
				forget-names    [forget-names face none]

				open-big        [open-big-table face]

				; CELL
				edit-cell       [on-dbl-click face event]
				freeze-cell     [freeze face event 'y freeze face event 'x]
				unfreeze-cell   [unfreeze face 'y unfreeze face 'x]

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
				image! tuple!   [set-col-type face event]

				set-default     [set-default face event]

				; SELECTION
				copy-selected   [copy-selected face]
				cut-selected    [copy-selected/cut face]
				paste-selected  [paste-selected face]
				transpose       [paste-selected/transpose face]
				color-selected  [color-selected face none]
				name-selected   [name-selected face none]
			][
				case [
					all [menu: face/menu/"Table"/"Select named range" find menu name: form event/picked] [
						select-name face name
					]
				]
			]
		]

		do-over: function [
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
						selection: find/last face/selected pair!
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
			face/no-over: false
		]

		find-in-row: function [face [object!] event [event!]][
			code: ask-code
			clear face/selected
			r: get-row-number face event
			foreach c face/col-index [
				if (form face/table-data/:r/:c) ~ code [append face/selected as-pair c r]
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
				clear face/selected
				index-col: index? find face/col-index col
				foreach r face/filtered/y [
					index-row: index? find face/row-index r
					append face/selected as-pair index-col index-row
				]
				if not empty? face/selected [
					first-found: index? find face/row-index face/filtered/y/1
					scroll face 'y first-found - face/current/y - 1
					face/marks/-1: 0.220.0.220
					show-marks face
				]
			]
		]

		; OPEN

		open-red-table: func [face [object!] fdata [block!] /only /local opts i col type sz][
			face/starting?: yes
			either only [
				opts: fdata
			][
				opts: fdata/2
				face/table-data: remove/part fdata 2
			]
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
			init-grid face
			init-indices/only face

			if opts/frozen-cols [append clear face/frozen-cols opts/frozen-cols ]
			if opts/frozen-rows [append clear face/frozen-rows opts/frozen-rows ]
			face/frozen: as-pair length? face/frozen-cols length? face/frozen-rows
			append clear face/col-index either opts/col-index [opts/col-index][face/default-col-index]
			append clear face/row-index either opts/row-index [opts/row-index][face/default-row-index]
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
			if opts/defaults [face/defaults: to-map opts/defaults]

			face/box: any [opts/box face/default-box]
			face/top: case/all [
				(x: face/frozen/x) > 0 [x: index? find face/col-index face/frozen-cols/:x]
				(y: face/frozen/y) > 0 [y: index? find face/row-index face/frozen-rows/:y]
				true [as-pair x y]
			]
			face/current:  any [opts/current  face/top]
			face/selected: any [opts/selected [1x1]]
			face/anchor:   any [opts/anchor   1x1]
			face/active:   any [opts/active   1x1]

			face/pos: face/active - face/current + face/frozen

			either opts/names [face/names: to-map opts/names][clear face/names]

			face/scroller/x/position: face/current/x + 1
			face/scroller/y/position: face/current/y + 1
			set-freeze-point2 face
			adjust-scroller face
			set-last-page face

			face/draw: copy []
			face/marks: insert tail face/draw [line-width 2.5 fill-pen 0.0.0.220]
			fill face
			show-marks face
			no-over: true
		]

		open-table: func [
			face [object!]
			/with state [file! block!] ;TBD
			/local file opts
		][
			if file: request-file/title/file "Open file" system/options/path [
				face/data: file
				data: load file
				either all [
					%.red = suffix? file
					data/1 = 'Red
					block? opts: data/2
					;opts/current
				][
					open-red-table face data
				][
					init face
				]
			]
			face/no-over: true
			file
		]

		open-big-table: function [face [object!] /with file][
			if any [file file: request-file/title/file "Open large file" system/options/path ] [
				face/big-size: length? read/binary file
				face/big-length: length? csv: head clear find/last read/binary/part file 1000'000 lf
				face/data: file

				face/table-data: load-csv to-string csv
				open-red-table/only face [face/frozen-rows: [1]]
			]
		]

		next-chunk: function [face [object!]][
			file: face/data
			face/big-last: face/big-last + face/big-length + 1
			append face/prev-lengths face/big-length
			state: save-state/only/with face [col-sizes col-types face/frozen-cols] ;col-index ? why error?
			if attempt [found: find/last read/binary/seek/part file face/big-last 1000'000 lf] [
				face/big-length: length? csv: head clear found
				csv: to-string csv
				either error? loaded: load-csv csv [loaded halt][
					face/table-data: loaded
				]
				open-red-table/only face state
			]
		]

		prev-chunk: function [face [object!]][
			file: face/data
			state: save-state/only/with face [col-sizes col-types face/frozen-cols]
			if not empty? face/prev-lengths [
				face/big-length: take/last face/prev-lengths
				face/big-last: face/big-last - face/big-length - 1
				csv: read/binary/seek/part file face/big-last face/big-length
				csv: to-string csv
				either error? loaded: load-csv csv [loaded halt][face/data: loaded]
				open-red-table/only face state
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
					if file: request-file/title/file "Select state to use ..." system/options/path [
						state: load file
					]
				]
			]
			if state [open-red-table/only face state]
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
				selected:    (face/selected)
				anchor:      (face/anchor)
				active:      (face/active)
				names:       (body-of face/names)
				defaults:    (body-of face/defaults)
				scroller-x:  (face/scroller/x/position)
				scroller-y:  (face/scroller/y/position)
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
				if file: request-file/save/title/file "Save state as ..." system/options/path [
					save file state
				]
			]
		]

		save-red-table: function [face [object!]][
			;-- out: new-line/all data true
			out: new-line/all face/table-data true
			opts: get-table-state face
			save/header face/data out opts
		]

		save-table: function [face [object!]][
			either file? file: face/data [
				switch/default suffix? file [
					%.red [save-red-table face]
					%.csv [write file to-csv face/table-data]
				][write file face/table-data]
			][
				file: save-table-as face
			]
			face/no-over: true
			file
		]

		save-table-as: func [face [object!] /local file][
			if file: request-file/save/title/file "Save file as" system/options/path [
				face/data: file
				save-table face
			]
			file
		]

		; STANDARD

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
				face/pos: get-draw-address face event
				face/same-offset?: yes
				case [
					event/shift? [mark-active/extend face face/pos]
					event/ctrl?  [mark-active/extra face face/pos]
					true         [
						mark-active face face/pos
					]
				]
			]
		]

		on-unfocus: func [face [object!]][
			hide-editor face
			unmark-active face
		]

		on-over: func [face [object!] event [event! none!]][
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

		on-dbl-click: function [face [object!] event [event! none!] /local e][use-editor face event]

		on-key-down: func [face [object!] event [event! none!]][hot-keys face event]
		
		on-create: func [face [object!] event [event! none!]] [
			face/frozen-nums/x: face/frozen-cols	;-- need to properly initialize these when table is used as a style
			face/frozen-nums/y: face/frozen-rows					
		]
		
		on-created: func [face [object!] event [event! none!] /local file config ][
			make-scroller face
			either all [
				file? file: face/data
				%.red = suffix? file
				data: load file
				data/1 = 'Red
				block? config: data/2
				;opts/current
			][
				open-red-table face data config
			][
				set-data face face/data
				either config: face/options/config [
					if file? config [config: load config]
					open-red-table/only face config
				][
					if face/options/sheet [
						face/sheet?: yes
						put face/options 'auto-col face/auto-col?: yes
						put face/options 'auto-row face/auto-row?: yes
					]
					init face
				]
			]
			if all [
				not file? face/data
				to-logic face/options/auto-save
			][
				print [ "Can not use 'auto-save' when the data for the table is a Red block." newline "auto-save only works when the data is a file." ]
			]
		]

		on-menu: function [face [object!] event [event! none!]][do-menu face event]
	]
	
]

style/init 'table tbl [
	face: self
	face/actors/on-create: func [face [object!] event [event! none!]]  ;-- allows template to operate as a style. 
		head insert body-of :face/actors/on-create [
			frozen-nums/x: frozen-cols
			frozen-nums/y: frozen-rows					
		]
]	
