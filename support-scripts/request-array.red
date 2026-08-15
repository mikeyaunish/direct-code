Red [
	Title: "request-array.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [
	get-column-data: does [ return ["Calgary" "Vancouver" "Toronto" "Montreal" "Quebec City"] ]
	layout-vars: [
		list-size: 220x220	;-- 220x220 default
		picker-size: to-pair reduce [ (list-size/x - 23) 23 ]
		msg-size: to-pair reduce [ (list-size/x + 130) 23 ]
		new-item-size: to-pair reduce [ (list-size/x + 137 ) 37 ]	
		gapper-size: to-pair reduce [ (list-size/x - 40 ) 23 ]	
		new-item-field-size: to-pair reduce [ (list-size/x - 62 ) 24 ]
		custom-btn-size: to-pair reduce [ (list-size/x + 156) 24 ]
		req-msg: "Please create a full list of data that you require"
		data-block: [ "apple" "banana" "coconut" ]
		cust: true
		cust-block: [ "Fill list with data from Column" [ get-column-data ] ]
	]
	do layout-vars ;-- NEEDED WHEN BEING DEVELOPED!!
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
request-array-layout: [
	title "Data List Editor"
	style search-icon: base 23x23 220.220.220 
		draw [
			pen 0.0.0
			line-width 2 
			circle 9x9 6 
			line 14x14 21x21
		]				
	style box-plain: box 250.250.250
	style btn: button 150x24		
	
	space 10x2
	msg-text: text req-msg msg-size center font-size 11 underline
	return 
	main-list: text-list list-size 	
		data data-block			
		on-change [
			if face/selected <> 0 [
				target-selector: get to-word face/extra/selector
				target-selector/text: copy pick face/data face/selected 
			]
		]
		on-dbl-click [
			if main-list/selected <> 0[
				field-data-picker2/actors/select-this-item/selected "main-list"
				do-actor field-data-picker2 none 'enter
			]
		]				
		extra [ 
			selector: "field-data-picker2"
			last-selected: 0
		]
	space 0x4	
	panel1: panel 250.250.250 158x219 
		[
			
			space 2x2
			origin 4x4
			button-plain1: btn "Move UP"  
				on-click [
					move-item/up main-list/data main-list/selected
					main-list/data: main-list/data
					main-list/selected: (main-list/selected - 1)
				]
			return
			button-plain2: btn "Move DOWN" 
				on-click [
					move-item/down main-list/data main-list/selected
					main-list/data: main-list/data
					main-list/selected: (main-list/selected + 1)
				]
			return
			top-btn: btn "Move to TOP" 
				on-click [
					move-item/top main-list/data main-list/selected
					main-list/data: main-list/data
					main-list/selected: 1
				]
			return 
			btm-btn: btn "Move to BOTTOM" 
				on-click [
					move-item/bottom main-list/data main-list/selected
					main-list/data: main-list/data
					main-list/selected: (length? main-list/data)
				]
			return
			return
			button2: btn "Sort List" 
				on-click [
					main-list/data: sort main-list/data
				]
			return 
			clear-btn: btn "Clear List" font-color 255.0.0 bold 
				on-click [
					main-list/data: []
					main-list/selected: 0
				]			
		]
				
	return	
	search-icon1: search-icon	
	space 0x0
	field-data-picker2: request-list-picker picker-size focus with [ extra/data-source: "main-list" ]  
	button1: btn "Remove Item" 157x23 font-color 255.0.0 bold 
				on-click [
					remove skip main-list/data (main-list/selected - 1)
					main-list/selected: main-list/selected - 1
					field-data-picker2/text: pick main-list/data main-list/selected
				]
	space 2x4				
	return 
	
	base1: base 377x2 font-color 255.255.255
	return
	t1: text "New Item:" right middle 230.230.230 60x23
	new-item: field new-item-field-size 
		on-enter [
			do-actor add-item-btn none 'click
			new-item/text: copy ""
		]
	space 0x0
	add-item-btn: button "Add Item" 157x24 
		on-click [
			insert (skip main-list/data main-list/selected) copy new-item/text
			main-list/selected: main-list/selected + 1
			field-data-picker2/text: pick main-list/data main-list/selected
		]
	space 2x2
	return 	
	custom-button: button "Pull List from Column" font-color 0.170.0 font-size 11 hidden bold  custom-btn-size
		on-create [ 
			if cust [
				face/text: cust-block/1
				face/visible?: true
			]
		]
		on-click [
			append main-list/data do cust-block/2
		]
	return 
	pre-gap: box 30x20 255.255.255.255
	ok-btn: button "OK" 50x25  on-click [
		results: copy main-list/data
		unview
	]
	gapper: box gapper-size 255.255.255.255
	canc-btn: button "Cancel" 50x25  on-click [
		;-- results: #(none)
		results: none
		unview
	]
	do [
	    move-item: function [
	    	data
	        item-num
	        /up
	        /down
	        /top
	        /bottom
	    ][
	    	tgt: case [
	    		up [ (skip data (item-num - 2)) ]
				down [ (skip data item-num)]
	        	top [ data ]
	        	bottom [ (skip data (length? data)) ]
	    	]
	    	move (skip data (item-num - 1 )) tgt
	    ]		
	]	
						
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	;view request-array-layout
	request-array: func [
		{Requester for building and modifying arrays of data. 31-DEC-2025}
		message [string!]
		array [block!]
		/size the-list-size [pair!]
		/offset win-offset
		/custom custom-block [block!] "Two elements <button-string>  [<code-block>]"	
	][
		options-block: either offset [ compose [ offset: (win-offset) ]	][ [] ]
		list-size: either size [ max the-list-size 220x220 ][ 220x220 ] ;-- forcing value needed for requester
		
		picker-size: to-pair reduce [ (list-size/x - 23) 23 ]
		msg-size: to-pair reduce [ (list-size/x + 130 ) 23 ]
		new-item-size: to-pair reduce [ (list-size/x + 137 ) 37 ]	
		new-item-field-size: to-pair reduce [ (list-size/x - 62 ) 24 ]
		gapper-size: to-pair reduce [ (list-size/x - 40 ) 23 ]	
		custom-btn-size: to-pair reduce [ (list-size/x + 156) 24 ]
		req-msg: message
		data-block: copy array
		results: copy []
		cust-block: copy []
		cust: #(none)
		;-- words above initialized here to work properly with requester
		either custom [
			cust: true
			cust-block: custom-block
		][
			cust: false
		]
		view/flags/options request-array-layout
			[ no-min no-max modal ] 	;-- flags
			options-block
		return results
	]
	
	;		probe request-array/offset/size 
	;			"Create your custom data list for column 3" [ "apple" "baker" "cucumber" "dandelion" "estuary" ] 
	;			1077x249 300x500
]
