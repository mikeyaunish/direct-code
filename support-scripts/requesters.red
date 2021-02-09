Red [
	author: ["Gregg Irwin"]
	notes: {
		Experimental requesters, for design discussion. Not just about the
		implementation, but about modal vs modeless dialogs. I think there's
		value in the simple, modal approach, but we probably want to provide
		more advanced options. e.g. document/sheet modal, and mobile standard
		approaches.
	
		TBD: Determine if we want to build everything on inner funcs that are
			 heavily overloaded with options and refinements, or keep each 
			 dialog more independent for ease of understanding and maintenance.
		TBD: Determine on-key handling model. A common actor object may make
			 things harder to do and reason about.
		TBD: Auto-size text in dialogs.
		TBD: Show-dialog: add support for timeouts on pre-built face objects?
		TBD: Fully scalable draw commands for ISO images.
		TBD: Decide if all these requesters should be modal only.
		TBD: Is Rebol name compatibility important for these?
		TBD: Look at how notifications work across platforms.
		TBD: More color picker types.
	}
]

requesters: context [
	; Window flags: modal resize no-title no-border no-min no-max no-buttons popup
	
	; Native OS:   Dir, File, Font
	; In this lib: Notify, Alert, Confirm, Prompt, Color, Date(TBD)
	
	;---------------------------------------------------------------------------

	; General warning:  Yellow in black triangle with exclamation	239.202.64
	; Information: i												
	; Prohibition: Red stop/slash-circle (ul to lr)					177.34.54
	; Mandatory Action: Exclamation in blue circle					30.81.133

	iso-yellow: 239.202.64
	iso-red: 	177.34.54
	iso-blue: 	30.81.133

	;iso-font-40: make font! [style: 'bold size: 40 name: "Times New Roman"]
	iso-font-40: make font! [style: 'bold size: 40 name: "Symbol"]
	iso-font-40i: make font! [style: [bold italic] size: 40 name: "Times New Roman"]
	;iso-font-32: make font! [style: 'bold size: 32 name: "Symbol"]
	iso-font-26: make font! [style: 'bold size: 26 name: "Symbol"]

	svvs: system/view/vid/styles
	svvs/iso-info: [
		template: [
			type: 'base size: 48x48 color: none
			draw: [font iso-font-40i pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 7x-7 "i"]
		]
	]
	svvs/iso-question: [
		template: [
			type: 'base size: 48x48 color: none
			draw: [font iso-font-40 pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 3x-11 "?"]
		]
	]
;	svvs/iso-question: [
;		template: [
;			type: 'base size: 48x48 color: none
;			draw: [font iso-font-40 pen iso-yellow fill-pen iso-yellow circle 24x24 23 pen black text 3x-11 "?"]
;		]
;	]
	svvs/iso-warning: [
		template: [
			type: 'base size: 48x48 color: none
			draw: [font iso-font-26 pen black fill-pen iso-yellow line-width 4 line-join round polygon 24x4 46x44 2x44 text 13x5 "!"]
		]
	]
	svvs/iso-action-required: [
		template: [
			type: 'base size: 48x48 color: none
			draw: [font iso-font-40 pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 7x-12 "!"]
		]
	]
	svvs/iso-prohibit: [
		template: [
			type: 'base size: 48x48 color: none
			draw: [pen iso-red fill-pen white line-width 5 circle 24x24 21 line-width 4 line 8x8 40x40]
		]
	]
	;view [iso-info iso-warning iso-action-required iso-prohibit]
	
	;---------------------------------------------------------------------------

	svvs/timer: [
		default-actor: on-time
		template: [
			type: 'base size: 0x0 color: none
		]
	]
	
	std-dialog-actors: object [
		res: none
		on-key: func [face event] [
			;print [mold event/key mold event/flags]
			;!! If control is down, keys are always uppercase chars, including
			;	the caret, so we don't really need to check for 'control in
			;	event/flags if that is by design. Nice for char-key mapping.
			switch event/key [
				#"^M" [res: true  unview]	; enter
				#"^[" [res: none  unview]	; escape
				#"^O" #"^Y"  [if find event/flags 'control [res: true  unview]]
				#"^C" [if find event/flags 'control [res: none  unview]]
				#"^N" [if find event/flags 'control [res: false unview]]
			]
		]
	]
	std-dialog-opts: compose [
		flags: [modal no-min no-max]
		actors: (std-dialog-actors)
	]

	;---------------------------------------------------------------------------

;	add-dialog-timeout: func [
;		"Return modified copy of spec, with timer added"
;		spec [block! object!]
;		time [time!]
;	][
;		either block? spec [
;			append copy spec reduce ['timer 'rate time [unview]]
;		][
;			spec: make spec []
;			append spec/pane make face! [
;				type: 'base offset: 0x0 size: 0x0 rate: time
;				actors: object [
;					on-time: func [face [object!] event [event!]][unview]
;				]
;			]
;		]
;	]
	
	; To set the title for a dialog, use [title "xxx"] in the layout, or options/text.
	; To set the offset for a dialog, use options/offset.
	show-dialog: function [
		spec [block! object!]
		/options opts [block!] "[offset: flags: actors: menu: parent: text:]"
		/timeout time [time!]  "Hide after timeout; only block specs supported"
		/with    init [block! none!] "Code to run after layout, before showing; e.g., to center face"
	][
		;if time [spec: add-dialog-timeout spec time]
		if block? spec [
			if time [spec: append copy spec reduce ['timer 'rate time [unview]]]
			spec: layout spec
		]
		face: :spec												; let them use 'face in init block
		if init [do bind/copy init 'face]
		view/options spec make std-dialog-opts any [opts []]
	]

	; The idea of allowing specs to be prebuilt objects/faces came from thinking
	; about how notifcations are used in 2017. They are often shown in place of
	; minimized or background apps, rather than as proper dialogs over a window.
	; They are also often animated into existence, which is something to consider.
	; No-title and no-border flags may be desirable.
	set 'notify function [
		"Display a dialog with a short message for a period of time"
		spec "Message to display or layout/face spec"
		time [time!]
		/over ctr [object!] "Center over this face"
		/offset pos [pair!]
	][
		spec: case [
			object? :spec [spec]
			block?  :spec [spec]
			'else [compose [across iso-info pad 10x0 text font-size 12 350x70 (form :spec)]]
		]

		opts: copy/deep std-dialog-opts
		; If we include a title and text, that's the first thing they may read, taking time.
		; "i" means information, but not good as title bar text by itself.
		; If we don't, they can still include it in the layout, but then we can't use no-title.
		; Default is "Red: untitled". Opts/text overrides 'title in layout specs.
		if all [block? spec  not find spec 'title][append opts [text: ""]]
		if pair? pos [append opts compose [offset: (pos)]]

		if ctr [init: [center-face/with face ctr]]				; 'face refers to the dialog

		show-dialog/options/timeout/with spec opts time init
	]
	
	; alert [ok] confirm [ok cancel] prompt [text box]
	set 'alert function [
		"Display a dialog with a short message, until the user closes it"
		msg
		;/options opts [block!]  "[offset: flags: actors: menu: parent: text:]"
		/style   sty  [word!]   "Include standard image and title: [info warn stop action]"
		/over    ctr  [object!] "Center over this face"
		/offset  pos  [pair!]   "Top-left offset of window"
		/local img txt
	][
		set [img txt] switch/default sty [
			info	[[iso-info "Information"]]
			warn    [[iso-warning "Warning"]]
			stop    [[iso-prohibit "Stop!"]]
			action  [[iso-action-required "Action required"]]
		][reduce [() "Information"]]							; paren == unset, for no image

		spec: compose [
			title (txt)
			across (get/any 'img) pad 10x0 text font-size 12 350x70 (form msg) return
			pad 300x0 button "OK" [res: true unview]
		]

		;opts: append copy std-dialog-opts opts ;any [opts [flags: [modal no-min no-max]]]
		opts: copy/deep std-dialog-opts
		if pair? pos [append opts compose [offset: (pos)]]
		
		if ctr [init: [center-face/with face ctr]]				; 'face refers to the dialog
		show-dialog/options/with spec opts init
		res
	]
		
;	set 'confirm function [msg][
;		view/options compose [
;			across
;			text font-size 12 350x70 (form msg) return
;			pad 200x0
;			button "OK" [res: true  unview]
;			button "Cancel" [res: none  unview]
;		] std-dialog-opts
;		any [std-dialog-actors/res res]
;	]

	set 'prompt function [
		"Display a dialog with a short message, and OK/Cancel buttons"
		msg
		/text "Include a text box for a simple, typed response"
		/prefill prefill-text "text entry field prefilled value"

	][
		view/options compose [
			across
			text font-size 12 350 (form msg) 
			return
			(
    			either text [
    			    [f-fld: field 350 return]
    			]
    			[]
			)
			pad 200x0
			button "OK" [res: true  unview]
			button "Cancel" [res: none  unview]
			(either text [[do [set-focus f-fld]]][])
		] std-dialog-opts
		either any [std-dialog-actors/res res][
			either text [f-fld/text][true]
		][none]
	]
	set 'confirm :prompt
	set 'request-text func [
		"Display a simple text entry dialog with a short message."
		msg
	][
		prompt/text msg
	]
	
	;---------------------------------------------------------------------------

	set 'request-list function [
		"Display a simple list selection dialog with a short message"
		msg
		data [block!]
	][
		view/options compose/only [
			across
			text font-size 12 200 (form msg) return
			f-lst: text-list 200x125 data (data) on-dbl-click [res: true  unview]
			return
			pad 100x0
			button "OK" [res: true  unview]
			button "Cancel" [res: none  unview]
			do [set-focus f-lst]
		] std-dialog-opts
		if any [std-dialog-actors/res res] [pick f-lst/data f-lst/selected]
	]

	;---------------------------------------------------------------------------
	
	set 'request-color function [
		"Display a simple color picker"
		/size sz [pair!]
		/title txt [string!]
		/over    ctr  [object!] "Center over this face"
		/offset  pos  [pair!]   "Top-left offset of window"
	][
		sz: any [sz 150x150]
		palette: make image! sz
		draw palette compose [	; Credit to @honix for this
			pen off
			fill-pen linear red orange yellow green aqua blue purple
			box 0x0 (sz)
			fill-pen linear white transparent black 0x0 (as-pair 0 sz/y)
			box 0x0 (sz)
		]
		spec: compose [
			title (any [txt ""])
			; The mouse down check here is because the window may pop up directly
			; over the mouse, and get focus. Hence, it gets a mouse up event, even
			; though they didn't mouse down on the color palette.
			image palette all-over on-down [dn?: true] 
				on-up [
					if dn? [
						res: pick palette event/offset
						unview
					]
				]
				on-over [
					; TBD: Show current color somewhere
					;if dn? [
					;	print pick palette event/offset
					;]
				]
		]

		opts: copy/deep std-dialog-opts
		if pair? pos [append opts compose [offset: (pos)]]
		
		if ctr [init: [center-face/with face ctr]]				; 'face refers to the dialog
		show-dialog/options/with spec opts init
		res
	]	
	
	;---------------------------------------------------------------------------

    set 'request-multiline-text function [ 
    	msg [string!]
    	/size win-size [pair!] 
    	/preload prestr [ string!]
    ][
    	res: copy ""
    	win-size: either size [ win-size ] [ 500x300 ]
    	prestr: copy either preload [
    	    prestr
    	][
    	    ""
    	]
        view [
            Title "User input required"
    		text1: text font-size 12 msg return 
            area1: area win-size on-create [ area1/text: copy prestr ]
    		return 
            button "     OK     " [ 
                res: area1/text
                unview 
            ]
            button "   CANCEL   " [ 
                res: none
                unview 
            ]
        ]	
        return res
    ]

]

e.g.: :comment
e.g. [
	notify "test" 0:0:2
	notify "Now is the time for all good men to come to the aid of their country.^/ and a new line" 0:0:5
	notify [text "Yadda!"] 0:0:2
	notify [title "App X says" text "Yadda!"] 0:0:2
	notify layout [text "Yadda!"] 0:0:2					; !! Won't timeout automatically because we use `layout`!
	notify [iso-info pad 15x0 text "Yadda!"] 0:0:2
	view [button [notify/over "Now is the time for all good men to come to the aid of their country.^/ and a new line" 0:0:5 face/parent]]

	alert "test"
	alert "Now is the time for all good men to come to the aid of their country.^/ and a new line"
	alert/style "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'xx
	alert/style "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'info
	alert/style "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'warn
	alert/style "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'stop
	alert/style "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'action
	alert/offset "Now is the time for all good men to come to the aid of their country.^/ and a new line" 'action 0x0
	view [button [alert/over "Now is the time for all good men to come to the aid of their country.^/ and a new line" face/parent]]

	prompt "Are you sure?"
	prompt/text "Enter your name"
	confirm "Are you sure?"
	confirm/text "Enter your name"
	request-text "Enter your name"

	request-list "Pick one" ["A" "B" "C"]
	
	request-color
	request-color/size 480x360
	request-color/offset 0x0
	view [button [print request-color/over face/parent]]
	
	
]

