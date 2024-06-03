Red [
	Title: "area-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
area-saved-style-layout: [
	style area-saved: area "Saved Area"  
        extra [
            save-name: ""
            save-filename: copy %""
            setup-style: [
                [
                    input [
                        prompt "Area name"
                        detail "Name of of the area to be created."
                    ]
                ][
                    input [
                        prompt "Save name"
                        detail "The 'Save Name' is used as the filename that holds the contents of this area. IE: <save-name>.data"
                    ]
                    action [
	                	comment {first check if a .data file with this name exists}
	                	if exists? to-file rejoin [ system/options/path (input-value) ".data" ][
	                		requester-results: prompt/text/size rejoin [ "The data file name: '" input-value ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
	                		while [ exists? rejoin [ system/options/path requester-results ".data" ]] [
	                			requester-results: prompt/text/size rejoin [ "The data file name: '" requester-results ".data' already exists. Please enter a different base name for the save file (excluding the '.data' file name extension." ] 400x100
	                		]
	                		input-value: copy requester-results
	                	]
	                	either none? input-value [
	                		false
	                	][
	                		alter-facet/value 'with compose/deep [ extra/save-name: (input-value) ]	
	                		alter-facet/value 'name input-values/1
	                	]
					]
                ]
            ]    
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
        on-key [
            if event/key = #"^K" [
                do face/text
            ]
            if event/key = #"^E" [
                editor face/extra/save-filename
            ]
            if event/key = #"^R" [
                face/text: read face/extra/save-filename
            ]
        ]        
    
    a: area-saved with [extra/save-name: "a"]
    box1: box "box1" 210.85.18.0
    b: area-saved with [extra/save-name: "a"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view area-saved-style-layout
]