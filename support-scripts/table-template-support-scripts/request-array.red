Red [
	Title: "request-array.red"
	Needs: View
]
	
system/view/VID/styles/request-list-picker: [
	default-actor: on-change
	template: [
		type: 'field
		size: 120x23 
		text: ""
		flags: []			
		extra: [ data-source: none ]
		actors: [
			; placeholders
			on-create: func [face [object!] event [event! none!]][]
			on-key: func [face [object!] event [event! none!]][]
			on-key-up: func [face [object!] event [event! none!]][]
			on-key-down: func [face [object!] event [event! none!]][]
			on-wheel: func [face [object!] event [event! none!]][]
			on-change: func [[trace] face [object!] event [event! none!]][]
			
			move-selection: func [ 
				text-list-name 
				direction 
				/page {direction amount is considered a full page} 						
				/local new-index
			][
				text-list-face: get to-word text-list-name 
				if page [
					line-height: second size-text/with text-list-face "X"
					face-height: text-list-face/size/y - 5
					page-size: to-integer round (face-height / line-height) - 1
					direction: (direction * page-size)
				]						
				new-index: (
					either none? text-list-face/selected [ text-list-face/extra/last-selected ] [ text-list-face/selected ]
				) + direction
				
				if (new-index < 1) [
				    new-index: 1
				]
				if (new-index > (length? text-list-face/data)) [
					new-index: length? text-list-face/data
				]
				select-this-item/index text-list-name new-index
			]
			
			list-picker-search: func [
				face
				text-list-name
			][
				text-list-face: get to-word text-list-name 
				fnd: face/actors/find-in-block copy text-list-face/data face/text 
				either fnd = [] [
					face/color: orange		
					text-list-face/extra/last-selected: either none? text-list-face/selected [
						text-list-face/extra/last-selected
					][
						text-list-face/selected
					]
					text-list-face/selected: none	
														
				][
					face/color: white 
					text-list-face/selected: fnd/2
				]
			]

			find-in-block: function [
				{returns value that matches a value in the block. Allows partial match with beginning of string}
				blk [block!]
				val [string!]
				/all 
			][
				block: copy blk
				results: copy []
				forall block [ 
					if fnd: find/match (first block) val [
						either all [
							append/only results reduce [ fnd index? block ]
						][
							results: reduce [ fnd index? block ]
							break	
						]
					]
				]
				if results [ return results ]
				return none
			]
			
			is-whitespace?: func [
			    c [char!]
			][
			    any [ 
			    	(c == #" ") (c == #"^-") (c == #"^M") (c == #"^/") (c == #"^K") (c == #"^L")
			    ]
			]
							
		    select-this-item: func [
		    	text-list-name
		    	/index index-val
		    	/selected 
		    ][
		    	text-list-face: get to-word text-list-name
		    	if selected [ index-val: text-list-face/selected ]
		    	if index-val = 0 [ return none ]
				either none? text-list-face/selected [
					face/text: none
				][
					either sel-item: pick text-list-face/data index-val [
						face/text: sel-item
					][
						text-list-face/selected: 0
						return none	
					]
					;-- face/text: copy pick text-list-face/data index-val ;-- text-list-face/selected
				]
				text-list-face/selected: index-val						
			]			
		]

	]
	init: [
		face: self
		face/actors/on-key: func [face [object!] event [event! none!] /local selected] 
			head insert body-of :face/actors/on-key [
			if event/key = 'down [
				face/actors/move-selection face/extra/data-source 1 	
				face/color: white
			]
			if event/key = 'up [
				face/actors/move-selection face/extra/data-source -1 	
				face/color: white
			]
			if event/key = 'page-down [
				face/actors/move-selection/page face/extra/data-source 1
			]
			if event/key = 'page-up [
				face/actors/move-selection/page face/extra/data-source -1
			]					
		]
                	
		face/actors/on-wheel: func [face [object!] event [event! none!] /local selected] 
			head insert body-of :face/actors/on-wheel [ 
                switch event/picked [
                    -1.0 [
                        face/actors/move-selection face/extra/data-source 1
                    ]
                    +1.0 [
                        face/actors/move-selection face/extra/data-source -1
                    ]
                ]
			]                   	
                	
		face/actors/on-key-down: func [face [object!] event [event! none!] /local selected] 
			head insert body-of :face/actors/on-key-down [
				if event/key = #"^M" [
					face/actors/select-this-item/selected face/extra/data-source 
					exit 
				]					
			]

		face/actors/on-key-up: func [face [object!] event [event! none!] /local selected] 
			head insert body-of :face/actors/on-key-up [
				if event/key = #"^[" [
					text-list-face: get to-word face/extra/data-source 
					text-list-face/extra/last-selected: either none? text-list-face/selected [
						text-list-face/extra/last-selected
					][
						text-list-face/selected
					]							
					face/text: copy ""
					ds-selected: to-set-path reduce [ to-word face/extra/data-source 'selected ]
					do reduce [ :ds-selected  none  ]
					set-focus face	
					exit 
				]
				
				if all [
					char? event/key 
					not face/actors/is-whitespace? event/key
				][
					face/actors/list-picker-search face face/extra/data-source
				]				
			]
	]
]

				
request-array: func [
	{Requester for building and modifying arrays of data.Vers. 5}
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
	;- view/flags/options request-array3-layout
	view/flags/options  layout [ ;-- request-array3-layout: [
		title "Data List Editor"
		on-close [ results: none ]
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
		[ no-min no-max modal ] 	;-- flags
		options-block
	return results
]
