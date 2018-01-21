Red [
	title:  "Red Object Browser"
	author: "Gregg Irwin"
	needs:  'view
]

e.g.: :comment

map-ex: func [
	"Evaluates a function for all values in a series and returns the results."
	series [series!]
	fn [any-function!] "Function to perform on each value; called with value, index, series, [? and size ?] args"
][
	collect [
		repeat i length? series [   ; use FORSKIP if we want to support /SKIP.
			keep/only fn series/:i :i :series ;:size
		]
	]
]

obj-browser: context [
	num-lists: 5	; How many text-list faces we want to use
	top-ref: none	; Reference to top level object, as a block of words. e.g., [system view VID]
	cur-ref: none	; Reference to the current word (top-ref + list selections).
	find-fld: txt-body: cur-top-obj-lbl: none	; face references

	;---------------------------------------------------------------------------

	build-ref-block: function [
		blk [block!] "Block of list faces referring to path elements"
	][
		map-ex collect [
			; top-ref is the alternate, top-level object, which has been
			; shifted into the left-most list.
			if top-ref [
				foreach item top-ref [keep :item]
			]
			; Blk is the list faces themselves, where we get an offset into obj-lists.
			foreach item blk [
				keep pick item/data item/selected
			]
		] :to-word
	]

	clear-text-area: does [txt-body/text: copy ""]

	clear-all-lists: does [clear-lists head obj-lists]

	clear-list: func [lst [object!]][clear lst/data  lst/selected: none]
	
	clear-lists: func [
		"Lists may be none, if the last list face triggers the call."
		lists "The starting point for the series of list faces you want to clear."
	][
		if lists [foreach lst lists [clear-list lst]]
	]

	;-- Find functions
	find-words: func [
		start-blk [block!] "Where to look"
		txt "Search pattern"
		/local 
	][
		print "Find feature TBD"
	]

	do-find: func [txt] [find-words get-top-level-objects txt]

	get-blk-obj: func [blk [block!] "Block of words"][get to path! blk]

	get-path-obj: func [str [string!]][get load str]

	get-top-level-objects: has [result] [
		sort collect [
			foreach w words-of system/words [
				if object? get/any :w [keep form :w]
			]
		]
	]

	init: func [/with ref [block!] /local lst][
		top-ref: ref
		cur-ref: none
		clear cur-top-obj-lbl/text
		clear-all-lists
		clear-text-area
		set-focus lst: first obj-lists
		either with [
			; Default back to system/words if we get a bad top-level object.
			if error? try [
				cur-top-obj-lbl/text: form to path! top-ref
				load-list-with-obj lst get-blk-obj top-ref
			][init]
		][
			lst/data: get-top-level-objects
		]
	]

	load-list-with-obj: func [lst [object!] "Face" obj [object!]] [
		lst/selected: none
		lst/data: sort map-ex words-of obj :form
	]

	obj-lists: does [
		collect [
			foreach ctl lay/pane [
				if ctl/options/style = 'obj-list [keep ctl]
			]
		]
	]

	;selected-object: does [get-blk-obj cur-ref]
	
	;selected-path: does [to path! build-ref-block]
	
	set-blk-obj: func [blk value][set to path! blk :value]

	set-cur-value: has [value] [
		;!! Need to think about *exactly* how this should work. Creating function
		;	values, without evaluating them, is at odds with creating blocks of
		;	values.
		value: reduce load txt-body/text
		set-blk-obj :cur-ref either block? :value [last value][:value]
	]

	set-top-level: func [
		target [block! path!]
	][
		init/with to-block target
	]

	;---------------------------------------------------------------------------

	; Return obj-list at the face given
	at-list: func [face [object!]][find obj-lists face]

	; Return obj-list at the face after the one given
	at-next-list: func [face [object!]][next at-list face]

	; Return obj-list up to the face given
	up-to-list: func [face [object!]][copy/part obj-lists index? at-list face]
;	up-to-list: func [face [object!]][
;		; This fails without `index?`, with what looks like stack corruption,
;		; seeing /part as an invalid refinement somehow. Can't reproduce in
;		; a smaller test case yet.
;		copy/part obj-lists at-list face
;	]
	
	;---------------------------------------------------------------------------


	obj-list-click: func [
		face [object!] event [event!]
		/local ref next-list err
	][
		clear-lists at-next-list face
		clear-text-area
		; Look at the selected item
		; - Object	Load next list
		; - Else	Show word value
		either error? err: try [
			ref: get-blk-obj build-ref-block up-to-list face
		][
			txt-body/text: rejoin ["Unable to retrieve value for word: " err/arg1 " ERR:" mold err]
			cur-ref: none
		][
			cur-ref: build-ref-block up-to-list face
			either object? :ref [
				if next-list: select obj-lists :face [
					load-list-with-obj next-list ref
				]
			][txt-body/text: mold :ref]
		]
	]

	obj-list-dbl-click: func [
		face [object!] event [event!]
		/local blk-ref ref err
	][
		blk-ref: build-ref-block up-to-list face
		; Get our reference before we clear everything. If we should get an
		; error, because they choose an invalid item, just stay where we are.
		either any [
			error? err: try [ref: get-blk-obj blk-ref]
			not object? :ref
		][exit][init/with blk-ref]
	]

	;---------------------------------------------------------------------------

	main-layout: compose [
		space 5x5
		style obj-list: text-list 150x275
			on-change    :obj-list-click
			on-dbl-click :obj-list-dbl-click
		across
		text 615x35 "Click an item in the list to display its contents. Double-click an item to move it to the left-most list.^/Click the Top button to restore the top level system objects to the left-most list."
		button 70 "Unview" [unview]
		button 70 "Quit" [quit]
		return
		button "Top" 150 [init]
		cur-top-obj-lbl: text 300 bold ;snow white
		find-fld: field 150
		button "Find" 150 [do-find find-fld/text]
		return

		; Load the first list with the top level objects in the system.
		obj-list data get-top-level-objects
		(collect [loop num-lists - 1 [keep 'obj-list]])

		return 
		txt-body: area 775x200
		pad -95x10
		button "Set Value" [set-cur-value]
	]
	
	lay: layout main-layout

]

view/no-wait/options obj-browser/lay [ offset: 1025x29 ]
