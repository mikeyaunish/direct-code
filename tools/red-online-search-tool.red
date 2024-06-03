Red [
	Title: "red-online-search-tool.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Date: 17-Mar-2024
]

do setup: [
    num-of-search-fields: 5
    run-search: does [
        ndx: 1
        loop num-of-search-fields [
            status: get ( to-path reduce [ to-word rejoin [ "search-" ndx ] 'data ])
            if status [
                field-code: get (to-path reduce [to-word rejoin [ "search-" ndx ] 'extra 'search-format ])
                full-url: rejoin reduce field-code
                browse to-url full-url
            ]
            ndx: ndx + 1
        ]
    ]
    set-all-checks: function [
        status [logic!]
        /extern num-of-search-fields    
    ][
        ndx: 1
        loop num-of-search-fields [
            set (to-path reduce [ to-word rejoin ["search-" ndx ] 'data ]) status
            ndx: ndx + 1
        ]
    ]
    git-languages: [
        "English"  {%5Een%5C}
        "Chinese"  {%5Ezh-hans%5C}
        "French"   {%5Efr%5C}             
        "Czech"    {%5Ecs%5C}     
        "Japanese" {%5Eja%5C}     
    ]
]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
red-online-search-tool-layout: [
    title "Red Online Search Tool"
    style search-check: check font-size 14
	style label: base "Label Text:" 77x25 230.230.230 font-color 0.0.0 right
	style saved-field: Field hint "Enter search term here" 80x23 
        extra [
            save-name: ""
            save-filename: copy %""    
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name ".data"]
                if exists? face/extra/save-filename [
                    face/text: read face/extra/save-filename
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                write face/extra/save-filename face/text     
            ]
        ]
	style check-saved: check font-size 14
        extra [
            save-name: ""
            save-filename: copy %""
            search-format: copy ""
        ] 
        on-create [
            if face/extra/save-name <> "" [
                face/extra/save-filename: to-file rejoin [ system/options/path face/extra/save-name ".data"]
                if exists? face/extra/save-filename [
                    face/data: either (load face/extra/save-filename) = 'false [ false ] [ true ]
                ]
            ]
        ] 
        on-change [
            if face/extra/save-name <> "" [
                save face/extra/save-filename face/data
            ]
        ] 
    at 6x9 base1: base "Github Searches (requires Github login to work well)" 390x128 210.210.210 
        font-color 0.0.0 center top wrap font-size 12 
    return
	search-1: check-saved "Github Search of: Red Documents" 
        with [
        	extra/search-format: [ {https://github.com/search?q=repo%3Ared%2Fdocs+path%3A%2F} git-language {%2F%2F+} search-field/text { &type=code} ]
        	extra/save-name: "search-1"
        ] 
        
    return
    search-2: check-saved {Github Search of: ALL "*.red" source code} 
        with [
        	extra/search-format: [{https://github.com/search?q=} search-field/text {+path%3A*.red+language%3ARed+&type=code}]
        	extra/save-name: "search-2"
        ]
    return
    
	label1: label "Language:" 77x23 font-size 11
	space 1x1
    drop-down1: drop-down 
        data ["English" "Chinese" "French" "Czech" "Japanese"] 
        extra [ save-filename: %ROST-language.data ]
        select 1
        on-create [
            either exists? face/extra/save-filename [
                face/selected:  index? find face/data load face/extra/save-filename
            ][
                save face/extra/save-filename pick face/data face/selected 
            ]
            git-language: select git-languages face/text
        ]
        on-change [
            git-language: select git-languages face/text
            save face/extra/save-filename pick face/data face/selected
        ]
    space 4x4
    return
	search-3: check-saved "Google Search of: www.red-lang.org" 
        with [
        	extra/search-format: [ {https://www.google.ca/search?q=} search-field/text {+site%3Ahttps%3A%2F%2Fwww.red-lang.org%2F} ]
        	extra/save-name: "search-3"
        ]
        
    return
    search-4: check-saved "Google Search of: Helpin.red" 
        with [
        	extra/search-format: [{https://www.google.ca/search?q=} search-field/text {+site%3Ahttps%3A%2F%2Fhelpin.red%2F}]
        	extra/save-name: "search-4"
        ]
    return
    search-5: check-saved "Google Search of: www.red-by-example.org" 
        with [
        	extra/search-format: [{https://www.google.ca/search?q=} search-field/text {+site%3A+www.red-by-example.org} ]
        	extra/save-name: "search-5"
        ]
    return 
    toggle1: toggle "Select ALL Sources" 389x23 on-change [
        either face/data [
            face/text: "ALL Sources Selected" 
            set-all-checks true
        ] [
            face/text: "NO Sources Selected" 
            set-all-checks false
        ]
    ]
    return
    label-1: text "Search:" right bold font-size 14
	search-field: saved-field font-size 14 306x30 focus 
	    hint "Enter search term here" 
	    with [
	    	extra/save-name: "search-field"] 
	    	on-create [
	    		if face/extra/save-name <> "" [
	    			face/extra/save-filename: to-file rejoin [system/options/path face/extra/save-name ".data"] 
	    			if exists? face/extra/save-filename [
	        			face/text: read face/extra/save-filename
	    			]
				] 
			] 
	    on-enter [write-clipboard face/text 
            run-search
        ]
    return
    button1: button "Search" 389x23 [ run-search ]
    
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view red-online-search-tool-layout
]
