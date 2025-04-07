Red [
	Title: "tab-panel-has-tab-position-saved-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
tab-panel-has-tab-position-saved-style-layout: [
	style tab-panel-has-tab-position-saved: tab-panel
    extra [
    	save-filename: %""
    	changed?: #(false)
    	setup-style: [
            [    		
	            action [
					full-filename: find-unused-filename rejoin [
						system/options/path rejoin 
						["vid-" object-name "-tab-panel-selected.data"]
					] 
					alter-facet/value 'with compose/deep [extra/save-filename: (second split-path full-filename)] 
            		alter-facet/value 'layout-block compose/deep [ 
				    	"Tab-A" [
				    		(to-set-word rejoin [ object-name "-tab-a-btn1"] ) button "Tab-A btn1"
				    		(to-set-word rejoin [ object-name "-tab-a-btn2"] ) button "Tab-A btn2"
				    	] 
				    	"Tab-B" [
				    		(to-set-word rejoin [ object-name "-tab-b-btn1"] ) button "Tab-B btn1"
				    	]
				    	"Tab-C" [
				    		(to-set-word rejoin [ object-name "-tab-c-btn1"] ) button "Tab-C btn1"
				    	]	            			
            		]
	            ]
            ]    		
    	]
    ]
    on-create [
		if exists? face/extra/save-filename [
			face/selected: load face/extra/save-filename
		]           	
    ]
    on-change [
    	face/extra/changed?: #(true)
    ]
	on-up [
		if face/extra/changed? [
			face/extra/changed?: #(false)
			if face/extra/save-filename <> %"" [
				save/all face/extra/save-filename face/selected 
			]        
		]
	]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view tab-panel-has-tab-position-saved-style-layout
]