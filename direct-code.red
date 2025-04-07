Red [
    Title:   "Direct Code"
    Author:  "Mike Yaunish / Nenad Rakocevic / Didier Cadieu /"
    File:    %direct-code.red
    Version: 4.0.0
    Needs:   'View
    Requires: 10-Oct-2023/9:48:47-06:00
    Usage:  {
        Continuation of sample livecode-enhanced.red script. from Nenad and Didier.
        Type VID code in the bottom left area, you will see the resulting GUI components
        rendered live on the right side and fully functional (events/actors/reactors working live).
        The top left area lets you define Red's values to be used in your VID code, even functions or anything.
    }
    History: [
        1.0.0 "01-09-2016"  "First version (Nenad)."
        1.1.0 "09-09-2016"  "Addition of red code predefinitions area and window resizing (Didier)."
        1.2.0 "21-09-2016"  "Addition of vertical and horizontal spliters (Didier)."
        1.2.1 "06-10-2016"  "Correction of vertical spliter resize (Didier)."
        1.3.0 "06-12-2017"  {Added: Live update check, manual update buttons, Save/Open/New of script as
                             well as Update check and panel sizes.
                             Autosave of file when it interprets correctly. Control+Tilde or middle mouse
                             to see details of the object that you are over (Mike)}
        1.4.0 "13-12-2017"   {Start adding direct maninpulation features and rename project 'direct-code' to
                              reflect the impetus to create a larger scope for the project(Mike)}
        2.0.0 "03-01-2021"   {Full rewrite of code generation engine. (Mike)}
        2.0.1 "15-02-2021"   {Correctly parse blocks imbedded in vid code}
        3.0.0 "19-03-2022"   {Full rewrite of the code generation engine (again) using transcode.
                              Rebuild the VID Object Editor to enable changing every facet of an object.}
		4.0.0 "02-06-2024"   {Added: Insert Tool, Style Object Editor, Scenario and setup-style code blocks}                               
    ]
    Tabs: 4
]

if system/build/date < 10-Oct-2023/15:49:07 [
    version-test: ask rejoin [ {The version of Red you are using needs to be} newline
            {at least at: 10-Oct-2023/15:49:07 or this program } newline
            {will not work properly.} newline {Do you want to continue anyway? y = "yes", n = "no"}
        ]
    if version-test <> "y" [ exit ]
]



set 'root-path copy what-dir
#include %support-scripts/direct-code-includes.red


                                                                                   
lprint: function [ s /no-newline /force ] [
    if any [
        global-logging
        force        
    ][
        lines: either no-newline [ false ] [ true ]
        write/append/:lines rejoin [ ( first split-path current-file ) %direct-code.log ] form reduce s
    ]
]
bprint: function [s /force ] [
    lprint/:force s
    print form reduce s
]

load-importable: function [ 									
	source-file [file!]											
][																
	do select (select (load source-file ) 'setup) 'importable	
]																



dc-ctx: context [
    
	#include rejoin [ root-path %support-scripts/select-text-block.red ]
	#include rejoin [ root-path %support-scripts/direct-code-utilities.red ]
    #include rejoin [ root-path %support-scripts/dc-images.red  ]
	
	set 'dc-default-selected-object-string "Layout code"
	
	set 'dc-default-selected-object-label-string "Insertion Point"  
	set 'dc-hilight-selected-object-label-string "Insertion Point <LOCKED ON>"  
	
	set 'dc-default-selected-object-label-color 198.196.225.0 
	set 'dc-hilight-selected-object-label-color green 
	
    set 'dc-alter-facet-object-name
    set 'dc-code-version 0
    set 'dc-voe-layout-template-file rejoin [ root-path %support-scripts/voe-layout-template.red ]
    set 'dc-voe-layout-template-data read dc-voe-layout-template-file
    set 'dc-style-template rejoin [ root-path %support-scripts/style-template.red ]
    set 'active-voe-windows copy []
    set 'orphaned-voe-windows copy []

    set 'internal-source-change-flag? false
    set 'dc-last-setup-code-error copy []
    set 'dc-last-vid-code-error copy []
    --over-face: none
    --obj-selected: none
    set '--dc-mainwin-offset 0x0
    set '--dc-mainwin-edge 0x0
    
    set '--voe-window make object!  [size: 0x0 offset: 0x0]
    set 'dc-red-executable copy ""

    set 'dc-all-active-styles copy []
    set 'dc-style-catalog-path rejoin [ root-path %style-catalog/ ]
    set 'dc-scenario-catalog-path rejoin [ root-path %scenario-catalog/ ]
    set 'current-file copy ""
    set 'gray-green 157.178.145
    set 'yellow-green 205.194.79
    set 'dc-locked-on-object copy []
    
    dc-reactor: make reactor! [
        current-file: rejoin [ system/options/path %help/welcome-to-direct-code.red ]
        active-object: ""
    ]
    set 'rooted function [ file [file!]][
        return rejoin [ root-path file ]
    ]

	set 'evo-after-insert true
    current-path: does [ first split-path dc-reactor/current-file ]
    setup-size: 752x200
    vid-size: 752x232
    output-panel-size: 987x526
    live-update?: ""
    
    insert-tool-pinned?: false
    set 'dc-live-update? false
    set 'dc-voe-selected-tab 1 ;-- This is global because it needs to be read by VOE
    set 'dc-voe-size "regular"
    set 'dc-insert-tool-tab 1
    set 'dc-style-catalog-selected 1
    set 'dc-object-catalog-selected 1
    set 'dc-scenario-catalog-selected 1
    reload-on-change?: false
    set 'global-logging false
    red-executable: none
    


    set 'dc-external-editor none
    set 'dc-external-editor-commands [
        needs-shell?: none
        plain-open: [ editor-executable " " filename ]
        open-to-line: none
        open-to-column: none
        open-with-find: none
    ]
    
    set 'dc-default-action-list does [ ;-- dc-default-action-list:
    	return collect [ 
			foreach i (keys-of system/view/vid/styles) [
				keep i
				keep to-safe-string system/view/vid/styles/:i/default-actor
			]
		]
	]

    set 'dc-actor-list sort collect [
    	foreach [ a1 a2 ] to-block system/view/evt-names [
    	    keep to-string a2
    	]
    ]

    direct-code-settings: rejoin [ root-path %settings/direct-code-settings.data ]

    set 'back-out-vid-changes func [ ;-- back-out-vid-changes:
        change-index [integer!]
    ][
    	if vid-code-undoer/action-index = change-index [ exit ]
    	new-vid-code: vid-code-undoer/back-out-changes change-index
    	vid-code/text: copy new-vid-code
    	run-and-save "back-out-changes"
    ]

	set 'prettify-vid-code function [] [	;-- prettify-vid-code:
		either pretty-result: valid-prettify-vid vid-code/text [
			if pretty-result = -1 [ return none ]
		    close-object-editor/all-open 
		    vid-code/text: pretty-result 
		    run-and-save "prettif-vid-code" 
		    show-insert-tool/refresh			
		][
			request-message "Unable to prettify current vid-code. The differences are shown in the console. First entry is the original. Second entry is the mismatch"	
		]
	]

    set 'dc-undo-redo func [
        /vid
        /setup
        /undo
        /redo
        /local new-setup-code new-vid-code
    ][

        undoer-refine: either undo [
            'undo
        ][
            'redo
        ]
        if all [
            setup
            (new-setup-code: setup-code-undoer/:undoer-refine )
        ][
            setup-code/text: copy new-setup-code
        ]
        if all [
            vid
            (new-vid-code: vid-code-undoer/:undoer-refine )
        ][
            vid-code/text: copy new-vid-code
        ]

        if any [ new-setup-code new-vid-code ][
            run-and-save "undo-redo"
        ]
    ]

    set 'get-catalog-entry-names function[ ;-- get-catalog-entry-names2
        /scenario
        /code
    ][ 
    	either code [
    		read rooted %code-catalog/
    	][
	        catalog-files: get-catalog-filenames/:scenario
	        post-len: either scenario [ 13 ][ 10 ]
		    collect [
		        foreach filename catalog-files [
		            keep copy/part (to-string filename) (( length? filename) - post-len )
		        ]
		    ]
		]
    ]

    set 'dc-catalog-styles get-catalog-entry-names
    set 'dc-scenarios get-catalog-entry-names/scenario
    set 'dc-code-catalog get-catalog-entry-names/code
    set 'dc-orig 4x4
    
    set 'is-scenario-file? function [
        filename
    ][
        return either find to-string (second split-path filename ) "-scenario.red" [
            true    
        ][
            false
        ]
    ]

    set 'vid-code-marker {;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!} ;-- vid-code-marker:
    set 'show-window-code-marker {;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!} ;-- vid-code-marker:

	in-output-panel?: function [ f ]  [
		fnd-face?: #(false)
		foreach-face output-panel [ 
			if f = face [ fnd-face?: #(true) ]
		]
		return fnd-face?
	]	


	old-in-output-panel?: function [
		object
	][
		output-panel-found?: #(false)
		until [
			either not none? object/parent [
				if not none? object/parent/data [
					if (first object/parent/data) = 'dc-output-panel [
						output-panel-found?: #(true)
						break
					]	
				]
			][
				false
			]
			? object/parent/text
			either not none? object/parent/text [
			 	either object/parent/text = "Direct Code" [ 
					true 
				][
					object: object/parent 
					false
				]
			][
				false
			]
		]
		return output-panel-found?
	]

    get-list-of-styles: function [] [
    	results: collect [
    		foreach [style-name x ] (get-styles to-block vid-code/text) [
    			keep to-string style-name
    		]
    	]
    	return results
    ]

	
    set 'get-list-of-named-objects function [ ;-- get-list-of-named-objects:
    	{return valid named objects}
    	/every {return objects without names as well}
    	/both  {return names as well objects}
    ] [ 
        res-blk: copy []
        foreach-face output-panel [
            obj-name: get-object-name face
            if obj-name = "*unusable-no-name*" [
            	if all [
            		face/type = 'panel
            		face/parent/type = 'tab-panel 
            	][
            		obj-name: "valid-not-named"
            	]
            ]
            if obj-name <> "valid-not-named" [
	            if any [
	            	obj-name <> "*unusable-no-name*" 
	            	every
	            ][
	           		append res-blk obj-name	
					if both [
						append res-blk :face 
					]
	                
	            ]
            ]
        ]
        return res-blk
    ]
    
    
    set-red-executable: function [
        /none-set
        /extern red-executable dc-red-executable
    ][
        full-msg: "Where is the Red executable file?"
        if none-set [
            red-executable: system/options/boot
            dc-red-executable: system/options/boot
            save-settings
            return ""
        ]
        refines: copy []
        if red-ex: do refine-function/args request-a-file refines reduce [
            any [ (if (red-executable <> 'none) [red-executable])  "" ]
            full-msg
            "Red Executable File:"
        ][
            red-executable: red-ex
            dc-red-executable: red-ex
            save-settings
        ]
    ]
    
    set-external-editor: function [
        /none-set
        /extern dc-external-editor
    ][
        full-msg: "Please locate your external Text Editor OR pick a Previous Selection"
        either none-set [
             full-msg: copy rejoin ["The current 'External Text Editor' Setting is missing or incomplete ^/" full-msg ]
             refines: copy [ skip-button ]
             skip-button: true
        ][
            skip-button: false
        ]
        external-ed: request-a-file/:skip-button/history  
        	any [ (if (dc-external-editor <> 'none) [ dc-external-editor ])  "" ]
        	full-msg
        	"External Text Editor:"
        	reduce [rejoin [root-path %settings/previous-ext-editors.data] "Previous Selections:"] 
        	
        if external-ed = 'skip [ exit ]	
        
        if external-ed [
            dc-external-editor: external-ed
            save-settings
            setup-external-editor
        ]
    ]
    
    set 'run-script function [ ;-- run-script:
        {Run a Red script while protecting the current directory}
        filename {The full path and filename to the script}
        /args arg
    ]
    [
        cur-dir: system/options/path
        either args [
            do/args filename arg
        ][
            do filename
        ]

        change-dir cur-dir

    ]

    set 'run-user-script does  [
        run-script rejoin [ root-path %user-script/user-script.red ]
    ]
    
    edit-user-script: does [
        load-and-run rejoin [ root-path %user-script/user-script.red ]
    ]
    
    edit-evo: does [
        load-and-run rejoin [ root-path %experiments/edit-vid-object/edit-vid-object.red ]
    ]

    run-program-separately: does [
        either (exists? to-file red-executable) [
            call/shell rejoin [ to-local-file red-executable " " to-local-file dc-reactor/current-file ]
        ][
            set-red-executable/none-set
        ]
    ]
    
    do-current-file: does [
        do dc-reactor/current-file
    ]

    set 'monitor-file-change function [ ;-- monitor-file-change:
        status
        /extern reload-on-change?
    ][
        either status [
            the-rate: 00:00:00.250
            the-color: 1.200.3
            reload-on-change?: true
        ][
            the-rate: 999:00:00
            the-color: blue
            reload-on-change?: false
        ]
        save-settings
        check-for-file-change/rate: the-rate
        check-for-file-change/color: the-color
    ]

    set 'find-unused-object-name function [ ;-- find-unused-object-name:
        obj-prefix [ string!]
        /excluding exclude-names [string!]
    ][
        obj-midfix: pick [ "-" "" ] (all-to-logic find ["h1" "h2" "h3" "h4" "h5"] obj-prefix )
        ndx: 1
        obj-search: rejoin [ obj-prefix obj-midfix ndx  ":" ]
        if not excluding [ exclude-names: "" ]
        while [
            if any [
                find setup-code/text obj-search
                find vid-code/text obj-search
                find exclude-names obj-search
            ][ true ]
        ][
            ndx: ndx + 1
            obj-search: rejoin [ obj-prefix obj-midfix ndx ":"]
        ]
        return rejoin [ obj-prefix obj-midfix ndx ] ;-- obj-prefix
    ]


	get-function-source: function [
		filename [file!]
		function-name [string!]
	][
		
		src: load filename 
		if fnd: select src to-lit-word function-name [
			return mold/only fnd
		]
		return false
	]
	
	indent-string: function [
		val [string!]
		indent [string!]
	][
		replace/all val "^/" rejoin [ "^/" indent ]
		insert val indent	
		return val
	]	
	
	set 'insert-catalog-code function [
		catalog-code-name [file!]
	][
		if file-data: read rejoin [ root-path %code-catalog/ catalog-code-name ] [
			header: select-text-block file-data "Red "
			replace file-data rejoin ["Red " header] ""
			trim-newlines/head file-data
			either last-prt: last-printable setup-code/text [
				indent: get-indent-chars setup-code/text last-prt
			][
				indent: "^-"
			]			
			indent-string file-data indent			
			if last-prt [ append setup-code/text rejoin [ newline ] ]
			append setup-code/text file-data	
			run-and-save "insert-function-code"
		]
	]
	
	set 'insert-function-code function [
		function-name [string!]
	][
		code-catalog: load rooted %code-catalog/code-catalog-index.data
		if catalog-entry: select code-catalog function-name [
			filename: rooted rejoin [ %code-catalog/ (select catalog-entry 'filename) ]
			if source-code: get-function-source filename (select catalog-entry 'function-name ) [
				either last-prt: last-printable setup-code/text [
					indent: get-indent-chars setup-code/text last-prt
				][
					indent: ""
				]
				indent-string source-code indent
				if last-prt [ append setup-code/text rejoin [ newline newline ] ]
				append setup-code/text source-code	
				run-and-save "insert-function-code"
			]
		]

		return ""
	]

    set 'extract-setup-code function [ filename ] [ ;-- extract-setup-code:
        the-code: read filename
    	either (find the-code vid-code-marker ) [
    	    clue: rejoin [ vid-code-marker "^/view"]
    	][
    	    clue: "^/view"
    	]
        a: first split the-code clue
        un-block-string any [ (second split a "do setup:") ""  ]
    ]

    set 'extract-vid-code function [ filename ] [ ;-- extract-vid-code:
    	i: read filename
    	either (find i vid-code-marker ) [
    	    clue: rejoin [ vid-code-marker "^/view"]
    	][
    	    clue: "^/view"
    	]
    	b: second split i clue
    	c: find b "["   
    	un-block-string c
    ]

    set 'extract-from-source function [ ;-- extract-from-source:
        series [string!]
        left-delim [string!]
        right-delim [string!]
    ][
        extracted: delim-extract/first series left-delim right-delim
        return un-block-string extracted
    ]
    
    set 'get-dc-code-version function [
        file-data
        /extern show-window-code-marker
    ][
        return either find file-data show-window-code-marker [ 2 ][ 1 ]
    ]    

    set 'get-setup-code function [
        file-data [string!]
        /extern vid-code-marker
    ][
        extract-from-source file-data rejoin [ "^/do setup:" ] vid-code-marker
    ]


    set 'get-vid-code function [
        file-data [string!]
        code-version [integer!]
        /extern vid-code-marker
    ][
        head-marker: either code-version = 1 [
            rejoin [ vid-code-marker "^/view " ]
        ][
            vid-code-marker
        ]
        content: find file-data head-marker
        content: find/tail content ": "
        if code-version = 2 [
            content: delim-extract/use-head/first content "" show-window-code-marker
        ]
        return un-block-string content
    ]

    set 'edit-show-window-code function [
        code
    ][
        results: request-multiline-text/size/preload/custom/modal
			"Change window setting by clicking on the 'Window Configuration' button or just type changes below." 
			800x100
			code
			[ 											;-- custom block
				"Window Configuration" [	
					if req-res: request-view-code --multiline-area/text [
						--multiline-area/text: req-res
					]
				]
			]
		
        if results [
            either error? err: try/all [
                test-code: load results
                true ;-- makes try happy dev-init
            ][ 
                print "********** show-window CODE ERROR **************************************************************"
                print err
                print "*********************************************************************************"
            ][ ;-- Good run condition
                show-window-code/text: copy results
                run-and-save "show-window-code"
            ]
        ]
    ]

    set 'get-show-window-code function [
        file-data [string!]
        /extern show-window-code-marker
    ][
        either content: find/tail file-data rejoin [ show-window-code-marker {^/do show-window: }][
            return un-block-string content
        ][
            return false
        ]
    ]

    set 'get-file-base-name function [
        filename [file!]
    ][
        return to-string first split (second (split-path filename)) "."
    ]


    set 'dc-load-direct-code load-direct-code: function [
        filename [ file! ]
        /extern dc-code-version
    ][
        filename: clean-path filename
        if (not exists? filename)[
            req-res: request-message/size rejoin [ "Trying to open filename:^/" to-string filename "^/This file does not exist"] 600x300
            return false
        ]

        file-header: read/part filename 200
        either all [
            (exists? filename)
            (find file-header  {Comment: "Generated with Direct Code"} )
        ][
            if (value? 'dc-initialized) [
                recent-menu/add-item dc-reactor/current-file
            ]
            if ((to-string filename) <> dc-reactor/current-file ) [
                monitor-file-change false
            ]
            if filename <> dc-reactor/current-file [
                close-object-editor/all-open ""
            ]

            file-data: read filename
            dc-code-version: get-dc-code-version file-data

            if dc-code-version = 1 [
                setup-code/text: orig-setup-code: extract-setup-code filename
                vid-code/text: orig-vid-code: extract-vid-code filename
                show-window-code/text: copy ""          ;-- just zero it out
            ]

            if dc-code-version = 2 [
                setup-code/text: new-setup-code: get-setup-code file-data
                vid-code/text: new-vid-code: get-vid-code file-data dc-code-version
                show-window-code/text: get-show-window-code file-data
                red-header-code/text: select-text-block/only/trim-newline file-data "Red "
            ]

            dc-reactor/current-file: filename
            change-dir first split-path filename
            return true
        ][
            request-message/size rejoin [{Unable to load } filename {.^/Either the file doesn't exist or it isn't a 'Direct Code' program.}] 750x200
            return false
        ]
    ]

    save-direct-code: function [
        filename [ file!]
        /version version-num [integer!]
    ][
        direct-code-version: 2 ;-- This is the new default version
        temp-file: copy ""
        just-filename: to-string second split-path filename
        if version [
            direct-code-version: version-num
        ]
        if direct-code-version = 1 [
            write filename append temp-file reduce [
                {Red [^/^-Title: "} just-filename {"}
                {^/^-Needs: View}
                {^/^-Comment: "Generated with Direct Code"} ; "
                {^/]^/}
                {^/}
                {do setup: }
                string-to-block/no-indent any [ setup-code/text "" ]
                {^/}
                vid-code-marker
                {^/}
                "view " rejoin [ first split (to-string just-filename) "." "-layout: "]
                string-to-block/no-indent any [ vid-code/text "" ]
            ]
        ]
        if direct-code-version = 2 [
            if any [
                (red-header-code/text = "")
                (red-header-code/text = none)
            ][
                red-header-code/text: rejoin [
                    {^/^-Title: "} just-filename {"}
                    {^/^-Needs: View}
                    {^/^-Comment: "Generated with Direct Code"} ; "
                    {^/}
                ]
            ]

            base-name: first split (to-string just-filename) "."
            show-win-code: copy either any [
                (show-window-code/text = "")
                (show-window-code/text = none)
            ][
                rejoin [ "^-view "  base-name "-layout"  ]
            ][
                show-window-code/text
            ]
            write filename append temp-file reduce [
                {Red }
                string-to-block/no-indent red-header-code/text
                {^/^/}
                {do setup: }
                string-to-block/no-indent any [ setup-code/text "" ]
                {^/^/}
                vid-code-marker
                {^/}
                rejoin [ base-name "-layout: "]
                string-to-block/no-indent any [ vid-code/text "" ]
                {^/^/}
                show-window-code-marker
                {^/}
                {do show-window: }
                string-to-block/no-indent show-win-code
            ]
        ]
        save-settings
        change-dir first split-path filename
        set 'dc-filename filename
    ]

    set 'recent-menu closure [ ;-- recent-menu:
        recent-file-list: [] [block!]
        max-entries: 11
    ][
        /add-item filename [file!]
        /get-item item-num [number!]
        /get-all
        /set-all value [ block! ]
        /local push-into-menu ndx file-fnd
    ][
        push-into-menu: func [ value ][
            insert recent-file-list value
            recent-menu-location: ((index? find mainwin/menu/2 "Recent Files") + 1)
            if ((length? recent-file-list) > max-entries) [
                recent-file-list: copy/part recent-file-list max-entries
            ]
            ndx: 1
            remove/part mainwin/menu/2/:recent-menu-location (length? mainwin/menu/2/:recent-menu-location )
            foreach i recent-file-list [
                append mainwin/menu/2/:recent-menu-location reduce [ (to-string second split-path i) to-word rejoin [ "recent-" ndx ] ]
                ndx: ndx + 1
            ]
        ]
        case [
            add-item [
                if (file-fnd: find recent-file-list filename ) [
                    remove file-fnd
                ]
                push-into-menu filename
            ]
            get-item [
                return pick recent-file-list item-num
            ]
            get-all [
                prin ""
                return recent-file-list
            ]
            set-all [
                foreach i value [
                    push-into-menu i
                ]
            ]
        ]
    ]

    save-settings: does [
        recent-files: recent-menu/get-all
        if value? 'setup-code [
            save rejoin [  root-path %/settings/direct-code-settings.data ]
                new-line/skip/all reduce [
                    'filename                       dc-reactor/current-file
                    'setup-size                     setup-code/size
                    'vid-size                       vid-code/size
                    'output-panel-size              output-panel/size
                    'dc-live-update?                   dc-live-update?
                    'evo-after-insert?              evo-after-insert?
                    'insert-tool-pinned?            insert-tool-pinned?
                    'red-executable                 red-executable
                    'external-editor                dc-external-editor
                    'logging                        global-logging
                    'recent-files                   recent-files
                    'reload-on-change?              reload-on-change?
                    'dc-voe-selected-tab            dc-voe-selected-tab
                    'dc-voe-size                    dc-voe-size
                    'dc-insert-tool-tab             dc-insert-tool-tab
                    'dc-style-catalog-selected      dc-style-catalog-selected
                    'dc-object-catalog-selected		dc-object-catalog-selected
                    'dc-scenario-catalog-selected	dc-scenario-catalog-selected
                    'insert-tool-open?              insert-tool-open?
                ] true 2
        ]
    ]

    set 'run-and-save function [ ;-- run-and-save:
        id
        /no-save
        /version version-num
        /extern active-voe-windows internal-source-change-flag? 
        		dc-last-vid-code-error dc-last-vid-code-error dc-code-version
        		dc-locked-on-object
    ][
        ;-- save only happens if the run is successful

        set 'project-path copy system/options/path
        set 'current-file copy dc-reactor/current-file
        setup-good?: vid-good?: true

        either exists? dc-reactor/current-file [
            either dc-code-version = 1 [
                original-setup-text: extract-setup-code dc-reactor/current-file
                original-vid-text:   extract-vid-code dc-reactor/current-file
            ][
                file-data: read dc-reactor/current-file
                original-setup-text: get-setup-code file-data
                original-vid-text: get-vid-code file-data dc-code-version
            ]
        ][
            original-setup-text: copy ""
            original-vid-text: copy ""
        ]

        either error? err: try/all [
            if setup-code/text [
                do load setup-code/text
            ]
            true ;-- makes try happy dev-init

        ][
            dc-last-setup-code-error: err
            print "*** SETUP CODE ERROR / VID CODE IGNORED! ****************************************"
            print err
            print "*********************************************************************************"
            active-filename/color: yellow
            setup-code/color: yellow
            setup-good?: false
        ][ ;-- setup code ran clean
            dc-last-setup-code-error: copy ""
            either error? err: try/all
             [
                if vid-code/text [
                    output-panel/pane: layout/only load/all vid-code/text
                ]
                true ;-- makes try happy
            ][
                dc-last-vid-code-error: err
                print "*** VID CODE ERROR **************************************************************"
                print err
                print "*********************************************************************************"
                
                
                active-filename/color: yellow
                vid-code/color: yellow
                vid-good?: false
            ][
                dc-last-vid-code-error: copy ""
                setup-code/color: white
                vid-code/color: white
                if not no-save [
                    curr-rate: check-for-file-change/rate
                    check-for-file-change/rate: 999:99:99                               ;-- turn off monitor-file-change
                    either version [
                        save-direct-code/version dc-reactor/current-file version-num
                    ][
                        save-direct-code dc-reactor/current-file
                    ]

                    file-modified? dc-reactor/current-file                              ;-- reset timestamp
                    check-for-file-change/rate: curr-rate
                ]
                active-filename/color: white
                active-filename/extra/message: (to-string dc-reactor/current-file)
            ]
        ]

        either any [
            id = "after-view"
            id = "open-dc"
            id = "new-dc"
            id = "devel-load-and-run"
            id = "clear-file"
        ][
            close-object-editor/all-open ""
            setup-code-undoer/set-initial-text original-setup-text
            vid-code-undoer/set-initial-text original-vid-text
            show-insert-tool/refresh
        ][
            either id <> "undo-redo"[
                vid-code-undoer/post-changed-text vid-code/text
                setup-code-undoer/post-changed-text setup-code/text
            ][
            ]
        ]

        if any [
            id = "internal-source-change"
            id = "file-name-clicked"
            id = "control-key-change"
            id = "undo-redo"
            no-save
        ][ 
            foreach win active-voe-windows [
                tilde-id: get to-path reduce [ (to-word win) 'extra 'target-object-name ]


                set (rcomp: to-word rejoin [ "requester-completed?" tilde-id ]) false
                after-view-widget: get to-path reduce [ ( to-word rejoin [ "evo-after-view" tilde-id ] ) ]
                after-view-widget/extra/rerun :after-view-widget
            ]
        ]
       
		       
		if all [ 
			dc-locked-on-object <> [] 
			not find id "insert-vid-object-style"
		][
			obj-name: 1
			voe-menu-handler/lock dc-locked-on-object/:obj-name "highlight-source-object" dc-locked-on-object
		]
		resync-selected-object 
    ]

    set 'change-logging function [ /off /on /extern global-logging] [ ;-- change-logging:
    	
        if on [
            print [ "change-logging global-logging =( true )"]
            global-logging: true
        ]
        if off [
            print [ "change-logging global-logging =( false )"]
            global-logging: false
        ]
        save-settings
    ]
    set 'evo-after-insert function [ ;--evo-after-insert:
    	{This allows this flag to be read within VOE as well- because it is out of context}
        /off
        /on
        /status
        /extern evo-after-insert?
    ][
    	if status [
    		return evo-after-insert?
    	]
        if on [
            evo-after-insert?: true
        ]
        if off [
            evo-after-insert?: false
        ]
        save-settings
    ]

    set 'insert-tool-pinned function [
        /off
        /on
        /extern insert-tool-pinned?
    ][
        if on [
            pinner/text: "Unpin Tool"
            insert-tool-pinned?: true
        ]
        if off [
            pinner/text: "Pin Tool"
            insert-tool-pinned?: false
        ]
        save-settings
    ]
    
    set 'set-dc-variable function [
    	var-name [word!]
    	val [integer!]
    	/extern dc-insert-tool-tab dc-style-catalog-selected dc-object-catalog-selected
    ][
		set var-name val 
		save-settings    	
    ]

    set 'set-voe-selected-tab function [
        tab-num [integer!]
        /extern dc-voe-selected-tab
    ][
        dc-voe-selected-tab: tab-num
        save-settings
    ]

    set 'set-voe-size function [
        size-string [string!] {size is either "regular" or "large"}
        /extern dc-voe-size
    ][
        dc-voe-size: size-string
        save-settings
    ]

    setup-external-editor: function [
        /extern dc-external-editor-commands dc-external-editor
    ][
        if dc-external-editor = 'none [ exit ]
        external-editor-template: load rejoin [ root-path %/settings/external-editor-settings.data ]
        foreach ext-editor external-editor-template [
            if fnd: find dc-external-editor ext-editor/identifier [
                if ext-editor/needs-shell? [
                    dc-external-editor-commands/needs-shell?: ext-editor/needs-shell?
                ]
                if ext-editor/plain-open [
                    dc-external-editor-commands/plain-open: ext-editor/plain-open
                ]
                if ext-editor/open-to-line [
                    dc-external-editor-commands/open-to-line: ext-editor/open-to-line
                ]
                if ext-editor/open-to-column [
                    dc-external-editor-commands/open-to-column: ext-editor/open-to-column
                ]
                if ext-editor/open-with-find [
                    dc-external-editor-commands/open-with-find: ext-editor/open-with-find
                ]

            ]
        ]
    ]

    either all [(exists? direct-code-settings) (system/script/args <> "SAFE-START") ][ ;-- load-settings:
        loaded-settings: load direct-code-settings
        dc-reactor/current-file: either all-to-logic loaded-settings/filename [ loaded-settings/filename ][ dc-reactor/current-file ]
        setup-size: either all-to-logic loaded-settings/setup-size [ loaded-settings/setup-size ][ setup-size ]
        selected-object-offset: to-pair reduce [ 95 ( setup-size/y + 83 )]
        vid-size: either all-to-logic loaded-settings/vid-size [ loaded-settings/vid-size ][ vid-size ]
        dc-voe-selected-tab: either all-to-logic loaded-settings/dc-voe-selected-tab [ loaded-settings/dc-voe-selected-tab ][ 1 ]
        dc-voe-size: either all-to-logic loaded-settings/dc-voe-size [ loaded-settings/dc-voe-size ][ 1 ]
        dc-insert-tool-tab: either all-to-logic loaded-settings/dc-insert-tool-tab [ loaded-settings/dc-insert-tool-tab ][ 1 ]
        dc-style-catalog-selected: either all-to-logic loaded-settings/dc-style-catalog-selected [ loaded-settings/dc-style-catalog-selected ][ 1 ]
        dc-object-catalog-selected: either all-to-logic loaded-settings/dc-object-catalog-selected [ loaded-settings/dc-object-catalog-selected ][ 1 ]
        dc-scenario-catalog-selected: either all-to-logic loaded-settings/dc-scenario-catalog-selected [ loaded-settings/dc-scenario-catalog-selected ][ 1 ]
        output-panel-size: either all-to-logic loaded-settings/output-panel-size [
            loaded-settings/output-panel-size
        ][
                output-panel-size
        ]
        dc-live-update?:        (all-to-logic loaded-settings/dc-live-update?)
        insert-tool-open?:      (all-to-logic loaded-settings/insert-tool-open?)
        evo-after-insert?:      (all-to-logic loaded-settings/evo-after-insert?)
        insert-tool-pinned?:    (all-to-logic loaded-settings/insert-tool-pinned? )
        reload-on-change?:      (all-to-logic loaded-settings/reload-on-change?)
        global-logging:         (all-to-logic loaded-settings/logging)
        either global-logging [ change-logging/on ][ change-logging/off ]
        if not all-to-logic dc-red-executable: red-executable: loaded-settings/red-executable [
            set-red-executable/none-set
        ]
        if not all-to-logic dc-external-editor: loaded-settings/external-editor [
        	;print "setup-external-editor #CALLING set-external-editor/none-set"
            set-external-editor/none-set
        ]
        setup-external-editor
        
    ][
        safe-start-message: copy ""
        if system/script/args = "SAFE-START" [
            safe-start-message: rejoin [
                "**************************************************" newline
                "  Direct Code is running in SAFE-START mode.    " newline
                "  All existing settings have been by-passed.    " newline
                "**************************************************" newline
            ]
        ]
        z: request-message rejoin [
            safe-start-message
            "To make full use of 'Direct Code' It is advisable" newline
            "to configure these two items under the Settings Menu:" newline
            "1.) Red Executable" newline
            "2.) External Editor"
        ]
        loaded-settings: [ ;-- settings are missing so setting bare minimum
            recent-files: []
        ]
    ]

    edit-source-object: function [
    	{Edit vid code source if it is selected}
        /left-edge
    ][
        obj-fnd: none
        either pos: vid-code/selected [
            ;-- obj-fnd: find-vid-object vid-code/text vid-code/selected
            obj-fnd: vid-obj-info/located-at/just-name vid-code/text "" vid-code/selected  
            if obj-fnd [
                obj-type: second query-vid-object vid-code/text obj-fnd [word!]

                refines: copy []
                if obj-type = "style" [
                    append refines 'style
                ]
                if left-edge [
                    append refines 'left-edge
                ]

                do refine-function/args edit-vid-object refines reduce [
                    obj-fnd
                    "vid-code"
                ]
            ]
        ][
        ]
    ]

    set 'select-object function [ ;-- select-object:
        face
        /left-edge
        /style
    ][
        object-name: get-object-name/dupes face
        ;object-name: get-object-name face
		if block? object-name [
			object-name: collect[ foreach obj object-name [ keep to-string obj ]]
			request-message rejoin [ "There are duplicate object names in this layout. This should be corrected before continuing.^/" (print-each/output/name object-name "The Duplicate Names") ]
			exit
		]
    	if style [
    		fail-msg: does [ rejoin [ "You were attempting to open a style for the object: '" object-name "', but this object does not use a style." ]]
			either style-name: get-object-style (get-object-source object-name vid-code/text )[
    			object-name: to-string style-name 
    			if stock-style? object-name [
    				request-message fail-msg
    				return none
    			]
    		][
    			request-message fail-msg 
    			return none
    		]
    	]
    	
        either ( object-name = "*unusable-no-name*")[
        	request-message "The VID object you have selected does not have a name. In order to use any VID object in Direct Code, the object should be assigned a name. Give the object a name and try again."
            --obj-selected: none
        ][
            --obj-selected: face
            --dc-mainwin-edge: mainwin/offset + mainwin/size
            edit-vid-object/:style/:left-edge object-name "vid-code" 
        ]
    ]
    
    set 'restart-direct-code does [
        either red-executable = 'none [
            req-res: request-message/size rejoin [ "In order to restart Direct Code the 'Red Executable' needs to be ^/setup in the Settings first.^/^/Do you want to do this now?"] 600x300
            if req-res [
                set-red-executable/none-set
            ]
        ][
            unview/all
            remove-event-func :direct-code-event-handler
            unset 'first-run?
            call/shell rejoin [ to-local-file red-executable " " to-local-file clean-path rejoin [ root-path %direct-code.red ] ]
        ]
    ]
    
    set 'all-objects-named? does [ ;-- all-objects-named?:
    	if find object-list: get-list-of-named-objects/every  "*unusable-no-name*" [
    		request-message rejoin [ "There are some objects without names. This needs to be fixed before "
    			 "you can continue. See the console for the object list. Sometimes re-interpretting " 
    			 "the current file will fix the issue. Select the menu item: 'Object' / "
    			 "'Manage Named Objects' to determine which objects don't have a name. "
    			 "If you click on 'View Source' of the object directly before the object "
    			 "without a name you can identify where the VID Object that is missing a name."
    		]
    		pe object-list
    		return false
    	]    	
    	return true
    ]
    
    select-current-face: function [
    	event [event!]
    	face 
    	/extern --over-face	
    ][
    	if not all-objects-named? [ 
    		return none 
    	]
        if (--over-face = output-panel)[
        	vid-objects: get-defined-vid-objects/no-styles  vid-code/text
        	found-object?: false
        	reverse/skip vid-objects 2
        	foreach [ a-face face-type ] vid-objects [
        		a-face: get a-face
        		if within? 	event/offset a-face/offset a-face/size [
					--over-face: a-face
					found-object?: true
					break            			
        		]
        	]
        	unless found-object? [
        		request-message "Sorry, can not find a VID object in this location."
        		return none
        	]
        ]
        target: --over-face 
        while [
			all [ 
				target <> output-panel
				target/type <> 'window
			]
		][
			target: get in target 'parent 
		]
		
		either face = vid-code [
            either find event/flags 'control [
           		edit-source-object/left-edge	
            ][
                edit-source-object
            ]
            return none
		][
			style: false
			left-edge: false
			if find event/flags 'shift [ style: true ]
	    	if find event/flags 'control [	left-edge: true ]
			select-object/:style/:left-edge --over-face 
			return none
		]

		if target/type = 'window [ 
			return none 
		]

    ]

	handle-over-face: func [
		event 
		action [string!] { One of these: "move-object"  "highlight-source-object" "insert-return-before" "remove-return-before" }
		/lock 
	][
		object-name: either (in-output-panel? --over-face ) [
			get-object-name --over-face
		][
			offset-to-object-name event/offset 
		]
		
		if object-name [
			lock-block: either lock [ reduce [ object-name "" ]	][ [] ]
			voe-menu-handler/:lock object-name action lock-block
		]
	]

    direct-code-event-handler: func [
        face [object!]
        event [event!]
    ][
		if all [
			(event/key = #"^-") ((event/type = 'key-down))
		][
			if find face/extra 'on-tab-away [
				do bind face/extra/on-tab-away 'face
			]
			if find face/extra 'on-tab-away-do-enter [
				do-actor face none 'enter 
			]
		]

				
        if all [ 
        	( event/key = 'F12) 
        	(event/type = 'key-up) 
        ][
            restart-direct-code
        ]
        
        if all [ (event/type = 'over) (event/flags/1 <> 'away) ] [
            --over-face: face
        ]
        
        if event/type = 'up [
            if  (--over-face <> face)[
                --over-face: false
            ]
        ]

		
        if all [		;-- Control + Tilde
        	(event/key = #"`") 
        	(event/type = 'key-down) 
        	((first event/flags) = 'control ) 
       	][
            
            if ( in-output-panel? --over-face) [
				if find event/flags 'shift [	;-- mid-click style edit STYLE
            		select-object/style --over-face
            		return none
            	]            	
                select-object --over-face
            ]

            if face = vid-code [
                edit-source-object
            ]
        ]

		if all [
			(event/key = 'F1)
			(event/type = 'key-up)
		][
			if object-name:	either (in-output-panel? --over-face ) [
				get-object-name --over-face
			][
				offset-to-object-name event/offset 
			][
				browse https://github.com/mikeyaunish/direct-code/blob/master/docs/SUMMARY.adoc	
			]			
		]        
		
		if all [
			(event/key = 'F2)
			(event/type = 'key-up)
		][
			handle-over-face event "move-object"
		]

		if all [
			(event/key = #"8")
			(event/type = 'key-up)
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
					
		][
			handle-over-face event "duplicate-object"
		]		
			
					
		
		if all [						
			(event/key = 'F3)			
			(event/type = 'key-up)		
		][								                                       				
			handle-over-face event "highlight-source-object"
		] 
        
        if all [ 
        	event/key = 'F4  
        	event/type = 'key-up 
        ][
			handle-over-face/lock event "highlight-source-object"

        ]		                              

		if all [						
			(event/key = 'left )			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)		
		][	
			handle-over-face event "move-back-1"
		]		

		if all [						
			(event/key = 'right )			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)		
		][	
			handle-over-face event "move-forward-1"
		]		

		if all [						
			(event/key = 'up )			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)		
		][	
			handle-over-face event "move-to-beginning"
		]		

		if all [						
			(event/key = 'down )			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)		
		][	
			handle-over-face event "move-to-end"
		]		

		
		if all [						
			(event/key = #"^M")			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)		
		][	
			handle-over-face event "insert-return-before"
		]							                                       				

		if all [						
			(event/key = #"^H")			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)				
		][	
			handle-over-face event "remove-return-before"
		]		

		if all [						
			(event/key = #"-" )			
			((first event/flags) = 'control )		
			((second event/flags) = 'shift )
			(event/type = 'key-up)			
		][	
			handle-over-face event "delete-object"
		]		

        if all [		;-- Escape key
        	(event/key = #"^[") 
        	(event/type = 'key-up) 
       	][
			un-highlight-source-object/quiet "" "" ""
			clear-vid-code-selected
		]
		
		if all [ 
			(event/type = 'alt-up) 
			(find event/flags 'alt)
		][
			select-current-face event face 
		]
				
        if any [
            (event/type = 'mid-down)
            all [(event/key = #"1") (event/type = 'key-down) ((first event/flags) = 'control ) ] ;-- Control + "1"
        ][
        	
			select-current-face event face
        ]
        
        if event/key = #"^S"[
            either event/flags = [control shift] [
                save-dc
            ][
                run-and-save "control-S"
            ]
        ]
        
        if event/key = #"^O"[
            if event/flags = [control] [
                open-dc
            ]
        ]        

        if all [ ((first event/flags) = 'alt ) (event/key = 'left ) (event/type = 'key-up ) ][
            load-and-run recent-menu/get-item 1
        ]

        if event/key = #"^Z"[
            if event/flags = [control shift] [
                either (--over-face = setup-code) [
                    dc-undo-redo/setup/undo
                ][
                    dc-undo-redo/vid/undo
                ]
            ]
        ]

        if event/key = #"^Y"[
            if event/flags = [control shift] [
                either (--over-face = setup-code) [
                    dc-undo-redo/setup/redo
                ][
                    dc-undo-redo/vid/redo
                ]
            ]
        ]

        if all [
            (event/type = 'key-up)
            (event/key = 'right-control)
        ][
            run-and-save "control-key-change"
        ]
        if all [ event/key = 'F11 (event/type = 'key-up) ] [
        		system/view/debug?: xor~ system/view/debug? true	
        ]
        if all [ event/key = 'F7 (event/type = 'key-up) ] [
            run-user-script
        ]
        if all [ (event/key = 'F8) (event/type = 'key-up) ] [
            either global-logging [ change-logging/off ][ change-logging/on ]
        ]
        if all [ event/key = 'F10  event/type = 'key-up ][
        ]
        if all [ event/key = 'F9  event/type = 'key-up ][
            run-program-separately
        ]
        if all [ event/key = 'F6  event/type = 'key-up ][
            do-current-file
        ]

        
        if event/type = 'resize [
            --dc-mainwin-edge: mainwin/offset + mainwin/size
        ]
        if event/type = 'close [
            if event/window/text = "Direct Code" [
                run-and-save "window-close"
                remove-event-func 'direct-code-event-handler
            ]
        ]
        if event/type = 'move [
            if face/text = "Direct Code" [
                --dc-mainwin-offset: face/offset
            ]
        ]

        if event/type = 'resize [
            insert-tool-height: 4
            sz: mainwin/size - dc-orig
            pan/size/y:  (to-integer sz/y) - (to-integer pan/offset/y)
            vid-code/size/y: (to-integer pan/size/y)  - (to-integer vid-code/offset/y) - dc-orig/y - insert-tool-height
            output-panel/size: sz - output-panel/offset
            splitv/size/y: (to-integer sz/y) - (to-integer splitv/offset/y)
            insert-tool-tab/size/y: to-integer mainwin/size/y - 89
            insert-tool/size/y: to-integer mainwin/size/y - 45
            basic-list/size/y: to-integer mainwin/size/y - 136
            active-list/size/y: to-integer mainwin/size/y - 136
            styles-vid-list/size/y: to-integer mainwin/size/y - 136
            'done
        ]
        return none
    ]

    either system/build/date < 10-Oct-2023/9:48:47-06:00 [ ;-- deal with new insert-event-func refinements
        insert-event-func :direct-code-event-handler
    ][
        insert-event-func 'direct-code-event-handler :direct-code-event-handler ;--10-OCT-2023
    ]
    
    on-spliter-init: func [face [object!] /local data v sz? op axis] [
    	face/extra/offset: face/offset 
        face/extra/fixedaxis: select [x y x] face/extra/axis: axis: either face/size/x < face/size/y ['x] ['y]
        if not block? data: face/data [exit]
        forall data [
            v: copy data/1
            while [all [not empty? v  not face? get v]] [all [sz?: take/last v  none? find [size offset] sz?  sz?: none]]
            all [
                not empty? v
                v: get v
                op: pick [+ -] (v/offset/:axis > face/offset/:axis) xor (sz? = 'size)
                insert data: next data op
            ]
        ]
    ]

    on-spliter-move: function [face [object!] /local amount fa] [
        fa: face/extra/fixedaxis
        face/offset/:fa: face/extra/offset/:fa              ;-- must not move on the fixed axis
        amount: face/offset - face/extra/offset             ;-- amount of the move since the last move
        face/extra/offset: face/offset                      ;-- store the new offset
        if any [amount = 0x0 not block? face/data] [exit]
        foreach [prop op] face/data [
            do zz: reduce [load rejoin [form prop ":"] prop op amount]          ;-- update the value with the new amount. I miss 'to-set-word here
        ]
    ]
  
    red-object-browser: does [ do rejoin [ root-path  %tools/red-object-browser.red ] ]

    mainwin: layout [
        title "Direct Code"
        backdrop gray
        origin dc-orig
        space 0x0
        style area: area font-name "Fixedsys"
        style split-style: base 30x6 loose 
        	extra [
	        	'offset none 
	        	'auto-sync? none 
	        	'axis none 
	        	'fixedaxis none
	        ]
            on-drag-start [
            	face/extra/offset: face/offset 
            	face/extra/auto-sync?: system/view/auto-sync? 
            	system/view/auto-sync?: no
            ] ;-- Need to disable realtime mode as the position is changed by the drag an the code
            on-drag [on-spliter-move face show face/parent]
            on-drop [system/view/auto-sync?: face/extra/auto-sync?] ;-- Don't forget to reset realtime mode to its previous value
            on-over [face/color: either event/away? [gray][blue]]
            on-create [
            	on-spliter-init face
            ]

        style after-view: button hidden 0x0 rate 00:00:00.001
            on-time [
                face/rate: 999:99:99
        		do face/extra/code-to-run
        		face/extra/rerun: func [ this-face ] [
        		    do bind this-face/extra/code-to-run 'this-face
        		]
        	]
        	extra [
        	    code-to-run: []
        	    rerun: copy []
        	]
		style dc-button-with-image-face: button  
			extra [
				normal-image: ""
				hilight-image: ""
			]
			on-created [
				if not none? face/image [
					face/extra/normal-image: face/image
					face/extra/hilight-image: get-hilight-image face/image
				]
			]
		    on-over [ 
				face/image: either event/away? [ 
					face/extra/normal-image
				][ 
					face/extra/hilight-image 
				]
			] 

					style dc-button-with-image-and-tooltip: button 
						extra [
							normal-image: "" 
							hilight-image: "" 
						    now-over?: #(false)
						    over-offset: 0x0 
						    message: {Add with [ extra/message: "a message" ] to display your own message} 
						    boxed: #(false)	
						    close-pop: func [] [
								if face/extra/now-over? [
									face/rate: 99:99:99
									face/extra/now-over?: #(false)
									popup-help/close ""
								]						    	
						    ]						
						] 
						on-created [
							if not none? face/image [
								face/extra/normal-image: face/image 
								face/extra/hilight-image: get-hilight-image face/image
							]
						]
						on-create [ face/extra/now-over?: #(false) ]
						on-over [
							either event/away? [
								face/image: face/extra/normal-image 
								face/rate: 99:99:99	
								if face/extra/now-over? [
						    		face/extra/now-over?: #(false)
						    		popup-help/close ""
						    	]				            								
							] [
								face/image: face/extra/hilight-image 
						        if not face/extra/now-over?  [
									face/rate: 00:00:00.55
									face/extra/over-offset: event/offset 				                
								]
							]
						]
						on-time [
							face/extra/now-over?: #(true)
							face/rate: 99:99:99
							box: face/extra/boxed 
							popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + -12x14) 
						]
			
			style dc-button-with-tooltip: button
				rate 99:99:99 
		        extra [ 
		            now-over?: #(false)
		            over-offset: 0x0 
		            message: {Add with [ extra/message: "a message" ] to display your own message} 
		            boxed: #(false)
		        ]
		        on-create [ face/extra/now-over?: #(false)]
		        on-over [
		            either event/away? [
		            	face/rate: 99:99:99	
			        	if face/extra/now-over? [
			        		face/extra/now-over?: #(false)
			        		popup-help/close ""
			        	]				            
			        ][
		                if not face/extra/now-over?  [
							face/rate: 00:00:00.55
							face/extra/over-offset: event/offset 				                ]
		            ]
		        ]
		        on-time [
		        	face/rate: 99:99:99
		        	face/extra/now-over?: #(true)
		        	box: face/extra/boxed 
		        	popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + -12x14) 
		        ]

			style dc-text-with-tooltip: text
				rate 99:99:99 
		        extra [ 
		            now-over?: #(false)
		            over-offset: 0x0 
		            message: {} 
		            boxed: #(false)
		        ]
		        on-create [ face/extra/now-over?: #(false)]
		        on-over [
		            either event/away? [
		            	face/rate: 99:99:99	
			        	if face/extra/now-over? [
			        		face/extra/now-over?: #(false)
			        		popup-help/close ""
			        	]				            
			        ][
		                if not face/extra/now-over?  [
							face/rate: 00:00:00.55
							face/extra/over-offset: event/offset 				                ]
		            ]
		        ]
		        on-time [
		        	face/rate: 99:99:99
		        	face/extra/now-over?: #(true)
		        	box: face/extra/boxed 
		        	popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + -12x14) 
		        ]

			style button-with-toggle-image: button 
				extra [
					first-image: "" 
					second-image: "" 
					current-image: "" 
					showing-image: 1 
				]			
				on-created [
					face/extra/current-image: face/image: reduce (pick [face/extra/first-image face/extra/second-image] face/extra/showing-image)
					face/image: face/extra/current-image
				] 
				on-over [
					face/image: either event/away? [
						face/extra/current-image
					] [
						get-hilight-image face/extra/current-image
					]
				] 
 
				on-click [
					face/image: either (face/extra/showing-image = 2) [
						face/extra/showing-image: 1 
						face/extra/current-image: face/extra/first-image 
						face/extra/first-image
					] [
						face/extra/showing-image: 2 
						face/extra/current-image: face/extra/second-image 
						face/extra/second-image
					]
				]
			       

        dc-after-view: after-view with [
            extra/code-to-run: [
                set 'dc-initialized true
                if any [ (not (value? 'first-run?) ) (first-run? = none)] [
                    write %direct-code.log ""                                   
                    first-run?: false

                    --dc-mainwin-edge: mainwin/offset + mainwin/size
                    if loaded-settings/recent-files [
                        recent-menu/set-all loaded-settings/recent-files
                    ]
                    vid-code-undoer: copy/deep text-undoer
                    setup-code-undoer: copy/deep text-undoer
                    run-and-save "after-view"
                    if insert-tool-open? [
                        do-actor insert-tool-button none 'down
                    ]
		    		system/console/run/no-banner 
                ]
            ]
        ]

        pan: panel [
            below
            origin dc-orig
            space 10x2
            across
         
            space 0x4
            back-btn: dc-button-with-tooltip "<" 15x24 
            	with [ extra/message: "Load and run previous file"]
	            on-click [
					face/rate: 100:40:39
					if face/extra/now-over? [
						face/extra/now-over?: #(false)
						popup-help/close ""
						do-events
					]	            	
	                load-and-run recent-menu/get-item 1
	            ]
            space 1x1
            check-for-file-change: base 40x24 blue font-size 12 bold center white "File: " rate 999:00:00 ;-- hold here until we turn it on
                [
                    monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ]
                    editor/monitor dc-reactor/current-file
                ]
                on-time [
                    if file-modified? dc-reactor/current-file [
                        load-and-run/no-save dc-reactor/current-file
                    ]
                ]
                on-create [
                    monitor-file-change (all-to-logic reload-on-change?)
                ]
            active-filename: dc-text-with-tooltip font-size 12 229x24 center white 
            	with [ extra/message: (to-string dc-reactor/current-file) ]
            	on-up [
                    run-and-save "file-name-clicked"
                ]
                react [ active-filename/text:  to-string second split-path dc-reactor/current-file ]

            space 2x1    
			run-source-btn: dc-button-with-image-and-tooltip 22x21 play-icon
				with [ extra/message: "Run Script (Right Ctrl Key)"]
				on-click [
					face/rate: 100:40:39
					if face/extra/now-over? [
						face/extra/now-over?: #(false)
						popup-help/close ""
						do-events
					]
					run-and-save "play-icon"
				]   

			edit-source-btn: dc-button-with-image-and-tooltip 22x22 edit-icon-normal
				with [ extra/message: "Open Script with External Editor"]
				on-click [
					face/rate: 100:40:39
					if face/extra/now-over? [
						face/extra/now-over?: #(false)
						popup-help/close ""
						do-events
					]
                    monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ]
                    editor/monitor dc-reactor/current-file
				]   
				             
            space 6x4
            red-run-btn: dc-button-with-tooltip 50x24 right center font-size 10  " RED>> " bold
            	with [ extra/message: "Click to run the Red code to the right"]
	            on-click [
					face/rate: 100:40:39
					if face/extra/now-over? [
						face/extra/now-over?: #(false)
						popup-help/close ""
						do-events
					]	            	
	                do-red-cmd
	            ]
	            
            space 0x4
            red-cmd-field: field font-size 11 325x24
                extra [
                    history: []
                    index: 1
                    data-file: %red-cmd-field-history.data
                    data-file-path: %/

                ]
                on-key [
                    switch event/key [
                        down [
                            goto-cmd-history face 'down
                        ]
                        up [
                            goto-cmd-history face 'up
                        ]
                        F4 [
                            requester-on-field 'red-cmd-field
                        ]
                    ]
                ]
                on-wheel [
                    switch event/picked [
                        -1.0 [
                            goto-cmd-history face 'down
                        ]
                        +1.0 [
                            goto-cmd-history face 'up
                        ]
                    ]
                ]
                on-enter [
                    do-red-cmd
                ]
                on-mid-down [
                    face/selected: 1x300
                ]
                on-create [
                    face/extra/data-file-path: rejoin [root-path %settings/ face/extra/data-file]
                    if exists? face/extra/data-file-path [
                        face/extra/history: load/all face/extra/data-file-path
                        if face/extra/history <> [] [
                            face/text: copy first back tail face/extra/history
                        ]
                    ]
                    do [
                        set 'requester-on-field function [field-name [word!] ] [
                            history: get to-path reduce [ field-name 'extra 'history ]
                            his: copy history
                            reverse his
                            req-ret: request-mutable-list/size "Select the command you want. You can also delete any lines you don't want in the command history." his 500x200
                            if req-ret/1  [
                                do reduce [ to-set-path reduce [ field-name 'extra 'history ] copy req-ret/3 ]
                                data-file: get to-path reduce [ field-name 'extra 'data-file-path ]
                                history: get to-path reduce [ field-name 'extra 'history ]
                                save data-file reverse history
                            ]
                            if req-ret/2 <> "" [
                                do reduce [to-set-path reduce [ field-name 'text ] copy req-ret/2 ]
                                set-focus get field-name
                                do-red-cmd
                            ]
                        ]
                        set 'do-red-cmd does [ ;-- do-red-cmd:

                            remove-each entry red-cmd-field/extra/history [ entry = red-cmd-field/text ]
                            append/only red-cmd-field/extra/history (copy red-cmd-field/text)
                            red-cmd-field/extra/index: 1
                            save red-cmd-field/extra/data-file-path red-cmd-field/extra/history
                            either error? err: try/all  [
                                do red-cmd-field/text
                                true ;-- try return value
                            ][
                                print "______________________________________________________________"
                                print "*** *************** RED COMMAND ERROR ************************"
                                print err
                                print "**************************************************************"
                                print "--------------------------------------------------------------"
                            ][
                                save-settings
                            ]
                        ]
                        goto-cmd-history: function [
                            face
                            direction
                        ][
                            if direction = 'down [
                                if face/extra/history <> [] [
                                    face/extra/index: min (face/extra/index + 1) length? face/extra/history
                                    face/text: copy first skip tail face/extra/history (-1 * face/extra/index)
                                ]
                            ]
                            if direction = 'up [
                                if face/extra/history <> [] [
                                    face/extra/index: max (face/extra/index - 1) 1
                                    face/text: copy first skip tail face/extra/history (-1 * face/extra/index)
                                ]
                            ]
                        ]
                    ]
                ]
            space 0x4
            dot-button: button "..." 20x24 [
                requester-on-field 'red-cmd-field
            ]
            return
            base "Setup Code (before layout)" 200x24  snow bottom left
            base 250x10 transparent
            insert-tool-button: Base "    Insert Tool  " left 110x22 138.138.138 font-color 255.255.255
                draw [
                    pen black
                    box 0x0 110x22
                    pen 245.245.245
                    line-width 2
                    line 88x9 95x15
                    line 95x15 103x9
                ]
                on-down [
                    show-insert-tool
                    insert-tool-open?: true
                    save-settings
                ]
                on-over [
                    either event/away? [
                        face/color: 138.138.138
                    ][
                        face/color: 199.199.199
                    ]
                ]
            return
            below
            setup-code: area setup-size
                on-create [ face/flags: none ]
                on-change [
                    check-source-change event/key
                    setup-code-undoer/post-changed-text setup-code/text
                ]

            pad 0x4
            ;-- horizontal splitter
            ;-- splith: split-style 752x6 data [setup-code/size vid-label/offset zero-out-selected-obj/offset vid-code/offset vid-code/size selected-object-label/offset selected-object-field/offset ]
            splith: split-style 752x6 data [setup-code/size vid-label/offset vid-code/offset vid-code/size selected-object-panel/offset ]
            across
            base 510x35 transparent
            return
            vid-label: base "Layout code" 80x26 white bottom center 
			on-create [
				face/draw: compose/deep [
					pen black 
					line-width 1 
					box 1x8 79x27 
					pen snow 
					fill-pen snow
					box 0x0 80x7
				]
			]
			
			at selected-object-offset selected-object-panel: panel gray 
				[

					origin 0x0
					pad 2x2
					space 1x0
					insert-method-label: base " Insert Method" left 90x24 198.196.225.0
					selected-object-label: base dc-default-selected-object-label-string 198.196.225
						center 185x24
					
					pad 1x1
					lock-toggle-button: button-with-toggle-image 22x22 unlocked-icon
						with [
							extra/first-image: unlocked-icon
							extra/second-image: locked-icon							
						] 
						on-click [
							either face/extra/showing-image = 2 [ 
								;-- UNLOCKING ---
								if selected-object-field/text <> dc-default-selected-object-string [
									selected-object-label/text: dc-default-selected-object-label-string
									face/extra/showing-image: 1 
									face/extra/current-image: face/extra/first-image 
									face/image: face/extra/first-image								
 									voe-menu-handler selected-object-field/text "highlight-source-object" 
								]
							][
								;-- LOCKING ON ---
								if selected-object-field/text <> dc-default-selected-object-string [
									face/extra/showing-image: 2 
									face/extra/current-image: face/extra/second-image 
									face/image: face/extra/second-image
 									voe-menu-handler/lock selected-object-field/text "highlight-source-object" 
 										reduce [
 											selected-object-field/text ""
 										]									
								]
							]
						]
						do [
							set 'set-lock-toggle-button-state function [
								state [logic!]
							][
								;-- defaults to UNLOCKED
								target-image: lock-toggle-button/extra/first-image
								img-num: 1

								if state [  ;-- ON / LOCKED
									target-image: lock-toggle-button/extra/second-image
									img-num: 2
								]
		                    	lock-toggle-button/extra/current-image: lock-toggle-button/image: target-image
		                    	lock-toggle-button/extra/showing-image: img-num
							]
						]
					b3: base 1x0 transparent
					return
					pad 2x0
					insert-method: drop-list 90x25 ;-- orig 86x25
						data [
							"Insert Before" 
							"Insert After"
						] 
						select 2
					
					selected-object-field: field 135x23 dc-default-selected-object-string disabled
					space 0x0
					pad 0x1
					selected-object-dots-btn: dc-button-with-tooltip "..." 21x21 
				        with [ 
				            extra/message: "Select a VID Object from a list"
				        ]					
						on-click [
							face/rate: 100:40:39
							if face/extra/now-over? [
								face/extra/now-over?: #(false)
								popup-help/close ""
								do-events
							]				
							named-objs: get-list-of-named-objects/every
							req-offset: ((get-absolute-offset selected-object-field)  + -2x25 )
							if req-res: request-list-enhanced/size/offset "Select an Object" named-objs 200x200 req-offset [
								voe-menu-handler req-res "highlight-source-object"
							]
						]
					space 2x0
					zero-out-selected-obj-btn: dc-button-with-image-and-tooltip 22x21 zero-out-icon-normal 
						on-click [
							face/extra/close-pop
							un-highlight-source-object "" "" ""
							clear-vid-code-selected
						]
						with [
	    					extra/message: "Clear the Insertion Point" 
						]
						
					edit-selected-obj-btn: dc-button-with-image-and-tooltip 22x21 edit-icon-normal
						on-click [
							face/extra/close-pop
							if selected-object-field/text <> dc-default-selected-object-string [
								edit-vid-object selected-object-field/text "vid-code"
							]
						]
						with [
	    					extra/message: "Edit 'Insertion Point' Object" 
						]						
				]			
            space 4x0
            return
            vid-code: area vid-size
            	extra [
            		last-selection: ""
            		selected-object: ""
            	]
                on-create [
                    face/flags: none
                ]
                on-change [
                    check-source-change event/key
                    vid-code-undoer/post-changed-text vid-code/text
                ]
                on-select [
                	either face/selected [
						face/extra/selected-object: vid-obj-info/located-at/just-name vid-code/text "" vid-code/selected                 		
						if all [
							face/extra/selected-object 
							face/extra/selected-object <> face/extra/last-selection
						][
							orig-sel: vid-code/selected
							voe-menu-handler/no-editor face/extra/selected-object "highlight-source-object"
							vid-code/selected: orig-sel							
						]
						face/extra/last-selection: face/extra/selected-object
                	][
                	]
                ]
            return
            at 0x0 show-window-code: area hidden
            at 0x0 red-header-code: area hidden

            insert-tool: panel "panel1" 0x0 188.188.188 [] hidden
                on-create [ initialize-insert-tool ]
            do [
                initialize-insert-tool: does [
                    insert-tool-width: 350
                    spacer-size: to-pair reduce [ (insert-tool-width - 436)  2 ]
                    tab-panel-size: to-pair reduce [ (insert-tool-width - 25) (mainwin/size/y - 90 )]
                    list-size: to-pair reduce [ (tab-panel-size/x - 22) (tab-panel-size/y - 46 )]
                    insert-tool/pane: layout/only/tight compose/deep [
                    ;-- insert-tool/pane: layout/only compose/deep [
                    	space 10x2
                        return
                        insert-tool-heading: text "    Insert Tool" 188.188.188 font-size 11 white
                        space 27x24
                        reload-button: base 18x18 188.188.188 
                            draw [
                                pen 255.255.255 
                                line-width 1 
                                box 0x0 18x18 
                                line 9x7 15x7 
                                line 15x2 15x8 
                                line 10x6 15x6 
                                line 14x3 14x8 
                                line-width 2
                                arc 9x9 6x6 15 325
                            ]
                        	on-over [either event/away? [
                        	        ;-- back to normal
                            		face/color: 188.188.188
                            		face/draw: [
                                    pen 255.255.255 
                                    line-width 1 
                                    box 0x0 18x18 
                                    line 9x7 15x7 
                                    line 15x2 15x8 
                                    line 10x6 15x6 
                                    line 14x3 14x8 
                                    line-width 2
                                    arc 9x9 6x6 15 325
                            		]
                        		][
                        		    ;-- hilighted state
                            		face/color: 255.255.255
                            		face/draw: [
                                        pen 0.0.0 
                                        line-width 1 
                                        box 0x0 18x18 
                                        line 9x7 15x7 
                                        line 15x2 15x8 
                                        line 10x6 15x6 
                                        line 14x3 14x8 
                                        line-width 2
                                        arc 9x9 6x6 15 325
                            		]
                        		]
                        	]
                        	on-down [ show-insert-tool/refresh ]                        
                        
                        space 4x24
                        insert-return: base "Insert RETURN" 87x18 188.188.188 font-color 255.255.255
                            draw [pen 255.255.255 box 0x0 87x18]
                        	on-down [
                        		set [ selected-obj after end-of-script ] get-selected-object-info
                        		insert-code/:after/:end-of-script "return" selected-obj
                        		run-and-save "insert-return"
                        	]
                        	on-over [either event/away? [
                        	        ;-- back to normal
                        	        face/font/color: 255.255.255
                            		face/color: 188.188.188
                            		face/draw: [pen 255.255.255 box 0x0 87x18]
                        		][
                        		    ;-- hilighted state
                        		    face/font/color: 0.0.0
                            		face/color: 255.255.255
                            		face/draw: [pen 0.0.0 box 0x0 87x18]
                        		]
                        	]
                        space 4x4
                        pinner: base "Pin Tool" 87x18 188.188.188 font-color 255.255.255
                            draw [pen 255.255.255 box 0x0 87x18]
                            on-create [
                                if insert-tool-pinned? [
                                    insert-tool-pinned/on
                                ][
                                    insert-tool-pinned/off
                                ]
                            ]
                        	on-down [
                	            either face/text = "Pin Tool" [
                	                insert-tool-pinned/on
                	            ][
                	                insert-tool-pinned/off
                	            ]
                        	]
                        	on-over [either event/away? [
                        	        ;-- back to normal
                        	        face/font/color: 255.255.255
                            		face/color: 188.188.188
                            		face/draw: [pen 255.255.255 box 0x0 87x18]
                        		][
                        		    ;-- hilighted state
                        		    face/font/color: 0.0.0
                            		face/color: 255.255.255
                            		face-size: face/size
                            		face/draw: [pen 0.0.0 box 0x0 87x18 ]
                        		]
                        	]

                        space 4x0

                        hide-tool: base "X" 20x18 188.188.188 font-color 255.255.255
                            draw [pen 255.255.255 box 0x0 20x18]
                        	on-down [
                        	    hide-insert-tool
                        	]
                        	on-over [either event/away? [
                        	        ;-- back to normal
                        	        face/font/color: 255.255.255
                            		face/color: 188.188.188
                            		face/draw: [pen 255.255.255 box 0x0 20x18]
                        		][
                        		    ;-- hilighted state
                        		    face/font/color: 0.0.0
                            		face/color: 255.255.255
                            		face/draw: [pen 0.0.0 box 0x0 20x18]
                        		]
                        	]
                        return
                        box 5x0
                        space 10x10
                        insert-tool-tab: tab-panel tab-panel-size on-create [ insert-tool-tab/selected: (dc-insert-tool-tab) ] [
                            "Object" [
                            	origin 10x10
                                basic-list: text-list (list-size)
                                    data sort dc-stock-styles
                                    on-change [
                                    	if sel: pick face/data face/selected [
                                    		set-dc-variable 'dc-object-catalog-selected face/selected
                                    		set-dc-variable 'dc-insert-tool-tab 1
	                                        check-tool-pinned
	                                        replace/all sel " " "-"
	                                        face/selected: none
											set [ selected-obj after end-of-script ] get-selected-object-info
											insert-vid-object/:after/:end-of-script to-word rejoin [ "ins-" sel ] selected-obj
	                                        face/selected: dc-object-catalog-selected 
	                                        face/selected: none 
	                                        set-focus insert-tool-heading
	                                    ]
                                    ]
                            ]
                            "Active Styles" [
                            	origin 10x10
                                active-list: text-list (list-size)
                                    data []
                                    on-change [
                                        if selection: pick face/data face/selected [
                                        	set-dc-variable 'dc-insert-tool-tab 2
	                                        check-tool-pinned
	                                        object-type: to-string select dc-all-active-styles to-set-word selection
	                                        face/selected: none
											set [ selected-obj after end-of-script ] get-selected-object-info	
 	                                        insert-vid-object/style/named/:after/:end-of-script object-type selected-obj selection selection                                        	
 	                                        set-focus insert-tool-heading
                                        ]
                                    ]
                            ]
                            "Style Catalog" [
                            	origin 10x10
                                below
                                styles-vid-list: text-list (list-size - 75x0 )
                                    data dc-catalog-styles
                                    on-change [
                                    	if selection: pick face/data face/selected [
                                    		set-dc-variable 'dc-style-catalog-selected face/selected
                                    		set-dc-variable 'dc-insert-tool-tab 3
	                                        check-tool-pinned
	                                        face/selected: none
	                                        scenario: is-scenario-file? current-file
											set [ selected-obj after end-of-script ] get-selected-object-info
											insert-styled-object/catalog/:scenario/:after/:end-of-script selection selected-obj
	                                        face/selected: dc-style-catalog-selected
	                                        face/selected: none 
	                                        set-focus insert-tool-heading
                                    	]
                                    ]
                                space 10x10
                                return
                                button "Edit Style" [
                                    set-dc-variable 'dc-insert-tool-tab 3
                                    if req-res: request-file/title/file/filter "Select a style to Open" dc-style-catalog-path [ "Red File" "*-style.red" ] [
                                        load-and-run req-res
                                    ]
                                ]
                                button "New Style" [
                                    set-dc-variable 'dc-insert-tool-tab 3
                                    new-dc/path/message dc-style-catalog-path "Enter New style name. Name format: (*-style.red)"
                                ]
                            ]
                            "Scenario"[
                            	origin 10x10
                                below
                                scenario-list: text-list (list-size - 49x0 )
                                    data dc-scenarios
                                    on-change [
                                        if selection: pick face/data face/selected [
                                        	set-dc-variable 'dc-scenario-catalog-selected face/selected
	                                        set-dc-variable 'dc-insert-tool-tab 4
	                                        check-tool-pinned
	                                        face/selected: none
											set [ selected-obj after end-of-script ] get-selected-object-info
											insert-scenario/:after/:end-of-script selection selected-obj
	                                        face/selected: dc-scenario-catalog-selected
	                                        face/selected: none
	                                        set-focus insert-tool-heading
	                                    ]
                                    ]
                                space 4x8
                                return
                                button {Edit^/Scenario} 50x35 [
                                    set-dc-variable 'dc-insert-tool-tab 4
                                    if req-res: request-file/title/file/filter "Select a scenario to Open" dc-scenario-catalog-path [ "Red File" "*-scenario.red" ] [
                                        load-and-run req-res
                                    ]
                                ]
                                button {New^/Scenario} 50x35 [
                                    set-dc-variable 'dc-insert-tool-tab 4
                                    new-dc/path/message dc-scenario-catalog-path "Enter New style name. Name format: (*-scenario.red)"
                                ]
                            ]
                            "Code" [
                            	origin 10x10
                                code-catalog-list: text-list (list-size - 75x0 )
                                    data dc-code-catalog
                                    on-change [
                                        if sel: pick face/data face/selected [
	                                        set-dc-variable 'dc-insert-tool-tab 5
	                                        check-tool-pinned
	                                        face/selected: none
	                                        insert-catalog-code sel
	                                        face/selected: none
                                        ]
                                    ]
                                space 4x8
								button 75x34 {Show Code ^/Folder} [
									set-dc-variable 'dc-insert-tool-tab 5
									show-folder rejoin [ root-path %code-catalog/ ]	
								]                                    
                            ]
                        ]
                    ]
                ]
                check-tool-pinned: does [
                    if not insert-tool-pinned? [
                        insert-tool/visible?: false
                        insert-tool-open?: false
                        save-settings
                    ]
                ]
            ]
        ;-- END INSERT TOOL *******************************************************************************
        ]

        do [
        	refresh-objects-list: does [
        		basic-list/data: sort dc-stock-styles 
        		basic-list/selected: dc-object-catalog-selected	
        		basic-list/selected: none	
        	]
        	
            refresh-style-catalog: does [
                dc-catalog-styles: sort get-catalog-entry-names
                styles-vid-list/data: dc-catalog-styles
                styles-vid-list/selected: dc-style-catalog-selected
                styles-vid-list/selected: none
                basic-list/selected: dc-object-catalog-selected 
                basic-list/selected: none
            ]
            refresh-scenario-catalog: does [
                dc-scenarios: sort get-catalog-entry-names/scenario
                scenario-list/data: dc-scenarios
                scenario-list/selected: dc-scenario-catalog-selected
                scenario-list/selected: none
            ]
            refresh-code-catalog: does [
            	dc-code-catalog: sort get-catalog-entry-names/code 
            	code-catalog-list/data: dc-code-catalog
            ]
            
            show-insert-tool: function [
                /refresh
                /extern dc-all-active-styles
            ][
                dc-all-active-styles: get-styles to-block vid-code/text
                ndx: 0
                active-style-list: collect [foreach i dc-all-active-styles [ndx: ndx + 1 if odd? ndx [keep to-string i]]]
                active-list/data: active-style-list
                active-list/selected: none
                refresh-style-catalog
                refresh-scenario-catalog
                refresh-code-catalog
                refresh-objects-list
                if not refresh [
                    insert-tool/offset: to-pair reduce [ (vid-code/size/x - 346) 32 ]
                    insert-tool/size: to-pair reduce [ insert-tool-width (mainwin/size/y - 45) ]
                    insert-tool/visible?: true
                    if not find-path-in-array splitv/data [ insert-tool offset ][
                        append splitv/data reduce [ 'insert-tool/offset '+ ] ;-- to accomodate this being on the wrong side of the splitter
                    ]
                ]
            ]
            
            hide-insert-tool: function [
                /extern insert-tool-open?
            ] [
                insert-tool/visible?: false
                insert-tool-open?: false
                save-settings
            ]
            
            dc-stock-styles: function [] [
            	list: collect [
            		foreach style (keys-of system/view/vid/styles) [
            			keep to-string style
            		]
            	]
            	remove find list "window"
            ]
            
            dc-stock-panels: [ "panel" "tab-panel" "group-box" ]
            

            check-source-change: function [ keycode ][
                if all [ (keycode <> 'right-control ) (keycode <> 'F5 ) ][
                    either dc-live-update? [
                        run-and-save "internal-source-change"
                    ][
                        active-filename/color: yellow
                    ]
                ]
            ]

            rename-header-title: function [
            	series
            	new-name
            ][
            	current-name: string-select series "Title:"
            	replace series rejoin [ "Title: " current-name ] rejoin [ "Title: " new-name ]
            ]

            save-dc: func [ 
            	/next-version 
            	/backup-version 
            ][
                
                if backup-version [
                    backup-filename: get-unique-version-name dc-reactor/current-file

                    file-data: read dc-reactor/current-file
                    write backup-filename file-data
                    request-message/size rejoin  ["Backup file saved" newline "Named: " backup-filename ] 800x100
                    return none
                ]
                either next-version [
                    new-filename: get-next-version-name dc-reactor/current-file
                ][
                    if ((new-filename: request-file/title/file "Save as" current-path ) = none) [
                        return false
                    ]
                ]

                if all [ (new-filename) (exists? new-filename ) ][
                    req-res: request-message/size rejoin [ "The file named:^/" to-string new-filename "^/already exists. Do you want to copy over it?"] 600x300
                    if (not req-res) [ return false ]
                ]

                close-object-editor/all-open "close-all-for-save"
                either dc-reactor/current-file <> new-filename [
                    recent-menu/add-item dc-reactor/current-file
                    rename-header-title red-header-code/text rejoin [ {"} (second split-path new-filename) {"} ]
                    if not any [
                        (show-window-code/text = "")
                        (show-window-code/text = none)
                    ][
                        replace show-window-code/text
                            (a: rejoin [ " " (get-file-base-name dc-reactor/current-file) "-layout" ])
                            (b: rejoin [ " " (get-file-base-name second split-path new-filename) "-layout"])
                    ]

                ][
                    copy-file dc-reactor/current-file new-filename
                ]
                dc-reactor/current-file: copy new-filename
                monitor-file-change false
                run-and-save "save-dc"
            ]

            open-dc: does  [
                if (rf: request-file/title/file/filter "Open" current-path ["Red Files (*.red)" "*.red" "All Files (*.*)" "*.*"]  ) [
                    recent-menu/add-item dc-reactor/current-file
                    close-object-editor/all-open "940"
                    monitor-file-change false
                    if (load-direct-code rf) [
                        run-and-save "open-dc"
                    ]
                ]
            ]

            save-gui-image-file: does [
                img: to-image output-panel
        	    if (rf: request-file/title/file/filter "Save Image of GUI as a '.png' file" current-path ["PNG Image" "*.png"] )[
                    save rf img
                ]
            ]

            new-dc: function [
                /path file-path
                /message message-text
            ][
                req-path: either path [
                    file-path
                ][
                    current-path
                ]
                req-msg: either message [
                    message-text
                ][
                    "Specify a NEW file name"
                ]
                if rf: request-file/title/file req-msg req-path  [
                    recent-menu/add-item dc-reactor/current-file
                    setup-code/text: copy ""
                    vid-code/text: copy ""
                    show-window-code/text: copy ""
                    red-header-code/text: copy ""
                    dc-reactor/current-file: rf
                    run-and-save "new-dc"
                ]
            ]

            set 'editor func [ ;-- editor:
                {Uses the external editor configured within direct-code to open a file}
                filename [file!]
                /monitor
                /line line-num
                /col col-num
                /find find-string
            ][
                if none? dc-external-editor [
                	set-external-editor/none-set
                	return ""	
                ]
                editor-executable: to-local-file dc-external-editor
                red-filename: filename
                filename: to-local-file filename

                call-cmd: rejoin reduce (bind dc-external-editor-commands/plain-open 'filename)

                if all [ line (all-to-logic dc-external-editor-commands/open-to-line) ] [
                    call-cmd: rejoin reduce (bind dc-external-editor-commands/open-to-line 'filename)
                ]

                if all [ col (all-to-logic dc-external-editor-commands/open-to-column )] [
                    call-cmd: rejoin reduce (bind dc-external-editor-commands/open-to-column 'filename)
                ]

                if all [ find (all-to-logic dc-external-editor-commands/open-with-find )] [
                    x-editor: to-string dc-external-editor
                    either not (system/words/find x-editor "uedit") [
                    	locations: locate-in-file red-filename find-string
                    	line-num: locations/1
                    	col-num: locations/2	
                    ][
                    ]
                    call-cmd: rejoin reduce (bind dc-external-editor-commands/open-with-find 'filename)
                ]

                either exists? to-file dc-external-editor  [
                    if monitor [ monitor-file-change true ]
                    either dc-external-editor-commands/needs-shell? = "yes" [
                        call/shell call-cmd
                    ][
                        call call-cmd
                    ]
                ][
                    set-external-editor/none-set
                ]
            ]
			
			set 'active-voe? function [ 
				obj-name
				/extern active-voe-windows
			][
				return find active-voe-windows rejoin [ "--voe-window-" obj-name ]
			]

            set 'close-object-editor function [  ;-- close-object-editor:
                obj-name
                /all-open
                /extern active-voe-windows
            ][
                either all-open [
                    window-list: copy active-voe-windows
                ][
                    ;-- make sure the window matches the object
                    window-list: none
                    foreach win active-voe-windows [
                        curr-obj: get to-path reduce [ (to-word win) 'extra 'current-object-name ]
                        if curr-obj = obj-name [
                            window-list: to-block mold win
                        ]
                    ]
                    if ( not window-list) [
                        window-list: to-block mold rejoin [ "--voe-window-" obj-name ]
                    ]
                ]
                if window-list <> [] [
                    foreach win window-list [
                        if value? (to-word win) [
                            do-actor (get to-word win ) none 'close
                        ]
                    ]
                ]
            ]

            voe-menu: context [
                find-edge-of-obj: function [
                    obj-name
                    rel-dir {+1 or -1, +1 returns end of obj, -1 returns start of obj}
                ][
                    
                    ;-- src-cdta: get-src-cdta vid-code/text
                    src-cdta: vid-cdta vid-code/text
                    
                    obj-info: find-in-array-at/every src-cdta 4 obj-name
                    o-info: either (rel-dir < 0)[
                        first obj-info
                    ][
                        last obj-info
                    ]
                    return o-info/token
                ]



                set 'highlight-gui function [ ;-- highlight-gui:
                	obj [string! object!]
                ][ 
                	
                	if string? obj [
                		obj: get to-word obj
                	]
                	
                    ;obj-offset: get to-path (reduce [ to-word obj 'offset ])
                    obj-offset: obj/offset
                    ;obj-size: get to-path (reduce [ to-word obj 'size ])
                    obj-size: obj/size
            	    ;obj-image: either error? (try [ try-img: to-image get to-word obj ])[ [] ] [ try-img ]
            	    obj-image: either error? (try [ try-img: to-image obj ])[ [] ] [ try-img ]
                    ;win-offset: get-absolute-offset (get to-word obj)
                    win-offset: get-absolute-offset obj
                    highlight-window: layout/tight compose/deep [
                        base1: base (obj-image) (obj-size)
                            rate 00:00:00.01
                            on-time [
                                face/extra/flash-count: face/extra/flash-count + 1
                                either face/extra/flash-count < 15 [
                                    f-count: face/extra/flash-count
                                    pen-color: pick [ red black yellow ]  f-count % 3 + 1
                                    base1/draw:  reduce [
                                        'pen :pen-color
                                        'line-width :f-count
                                        'box 0x0 (obj-size)
                                    ]
                                ][
                                	if value? 'highlight-window [
                                		lprint/force "#2800"
                                    	;face/rate: 999:99:99
                                    	unview/only highlight-window
                                    ]
                                ]
                            ]
                            extra [ flash-count: 0]
                    ]

                    view/flags/tight/options highlight-window
                        [ ;-- flags
                            no-border
                        ][ ;-- options
                            offset: win-offset
                        ]
                ]
                
                highlight-gui-object: func [ obj-name src-position last-char ] [
                    highlight-gui obj-name
                ]

                add-to-style-catalog: func [ 
                    object-name
                    src-position
                    last-char
                ][
                    style-source: get-style-source object-name vid-code/text
                    title-name: rejoin [ object-name "-style.red"]
                    layout-name: rejoin [ object-name "-style-layout" ]
                    style-program: read dc-style-template
                    replace style-program "--title-name--" title-name
                    replace/all style-program "--layout-name--" layout-name
                    replace style-program "--style-source--" style-source
                    full-filename: rejoin [ dc-style-catalog-path to-file title-name ] 
                    if exists? full-filename [
                        req-res: request-yes-no rejoin [ "The filename '" full-filename "' already exists. Do you want to OVERWRITE it?"]
                        if not req-res [
                            return ""    
                        ]
                    ]
                    write full-filename style-program 
                    refresh-style-catalog
                ]

            	convert-object-to-style: function [ obj-name src-position last-char ] [
            	    convert-to-style obj-name vid-code
            	]
            	
				set 'un-highlight-source-object func [ 
					obj-name 
					src-position 
					last-char 
					/quiet
				] [ ;-- un-highlight-source-object:
					if not quiet [
						vid-code/selected: none
					]
					selected-object-field/text: dc-default-selected-object-string
					selected-object-label/text: dc-default-selected-object-label-string
					selected-object-label/color: dc-default-selected-object-label-color
					set-lock-toggle-button-state off
					if dc-locked-on-object <> [][
						tilde-id: 2
						target-obj-name: rejoin [ "target-object-label" dc-locked-on-object/:tilde-id ]
						if value? to-word target-obj-name [
							lock-obj: get to-word target-obj-name
    	                	do-actor lock-obj none 'down						
						]
						dc-locked-on-object: []						
					]
				]

            	set 'highlight-source-object func [ 
            		obj-name 
            		src-position 
            		last-char 
            		/no-editor
            	][ ;-- highlight-source-object:
					
            	    either vid-code/selected = src-position [
            	    	clear-vid-code-selected
            	    ][
            	    	
	            	    vid-code/selected: src-position
	            	    vid-code/extra/last-selection: obj-name
	            	    selected-object-field/text: obj-name
	            	    selected-object-label/color: dc-hilight-selected-object-label-color
	            	    selected-object-label/text: dc-default-selected-object-label-string
	                    if check-for-file-change/rate <> 999:00:00 [
	                        line-num: offset-to-line-num/vid vid-code/text src-position/x
	                        if not no-editor [
	                        	editor/line dc-filename line-num	
	                        ]
	                    ]
            	    ]
            	    set-lock-toggle-button-state false
					if dc-locked-on-object <> [][
						if (first dc-locked-on-object) <> obj-name [
							dc-locked-on-object: copy []
						]
					]
            	]

				lock-to-object: func [ obj-name src-position last-char ] [
					if uid: get-voe-window-uid obj-name [
						target-obj: get to-word rejoin [ "target-object-label" uid ]
						lock-fun: get to-word rejoin [ "lock-to-this-object" uid ]
						do [ lock-fun target-obj obj-name uid ]
					]
				]

				set 'lock-highlight-source-object func [ obj-name src-position last-char ] [ ;-- lock-highlight-source-object
            	    vid-code/selected: src-position
                    if check-for-file-change/rate <> 999:00:00 [
                        line-num: offset-to-line-num/vid vid-code/text src-position/x
                        editor/line dc-filename line-num
                    ]
                    selected-object-label/text: dc-hilight-selected-object-label-string
                    selected-object-label/color: dc-hilight-selected-object-label-color
                    selected-object-field/text: obj-name 
					set-lock-toggle-button-state on
            	]	

            	edit-previous-object: func [ obj-name src-position last-char ] [
            	    obj-name: first back back tail dc-last-voe-object
            	    all-styles: get-styles to-block vid-code/text

            	    either find all-styles (to-set-word obj-name) [
            	        edit-vid-object/style obj-name "vid-code"
            	    ][
            	        edit-vid-object obj-name "vid-code"
            	    ]

            	]
            	copy-object-to-clip: func [ obj-name src-position last-char ][
            	    write-clipboard  ( copy/part (skip vid-code/text src-position/x - 1 ) (src-position/y - src-position/x + 1))
            	]

				set 'get-setup-style-block function [ ;-- get-setup-style-block:
					object-name [string!]
					source [string!]
				][
					source: get-object-source object-name source 
					source: load source
					if not source/extra [ 
						return none 
					]
					if not source/extra/setup-style [ 
						return none 
					]
					return source/extra/setup-style
				]

                set 'insert-setup-style function [ ;-- insert-setup-style:
                    object-name
            	    src-position
            	    last-char
                ][
                	
                    setup-sample: either setup-code: request-setup-facets [
                        setup-code    
                    ][
                        {
                        setup-style: [
                            [
                                input [
                                    prompt "Object text"
                                    detail "Text displayed on the object created."
                                ]
                                action [
                                    alter-facet/value 'text input-value
                                ]
                            ]
                        ]
                    }
                    ]
                    
                    setup-style-sample: copy load setup-sample
                    style-obj: load get-style-source object-name vid-code/text
                    
                    if style-obj/extra  <> none [
                        current-extra: copy style-obj/extra
                        if style-obj/extra/setup-style [
                            req-res: request-yes-no rejoin [ {A 'setup-style' block for '} object-name "' already exists. Do you want to OVERWRITE it?"]
                            if not req-res [
                                return ""    
                            ]
                            if found-setup: find current-extra 'setup-style [
                                found-setup-index: index? found-setup
                                remove/part (skip current-extra (found-setup-index - 1)) 2
                            ]
                            modify-source/delete vid-code/text object-name [ word! "extra" ] none
                            run-and-save "removing-insert-setup-style"
                        ]
                        insert setup-style-sample new-line current-extra true
                    ]
                    modify-source vid-code/text object-name [ word! "extra" ] setup-style-sample
                    
                    run-and-save "internal-source-change"
                ]

                set 're-run-setup-style func [ ;-- re-run-setup-style:
                    object-name
            	    src-position
            	    last-char
            	    /new-object "Brand new object so really need the VID Object Editor"
            	    /manual "script run directly - rather than thru VOE"
                ][
                    voe-object-renamed: false
                    fail-msg: rejoin [ "The object: '" object-name "' is not a Style, so does not have a 'setup-style' attached to it."]
                    if not object-style: get-object-style get-object-source object-name vid-code/text [
                    	;request-message fail-msg
                    	return false
                    ]
                    if stock-style? to-string object-style [
                    	;request-message fail-msg
                    	return false
                    ]
					either new-object [
						evo-name: object-name
					][
	                    setup-results: run-setup-style object-name src-position last-char
	                    if any [
	                    	setup-results = false
	                    	setup-results = 'no-setup-exists
	                    ][
	                    	return false
	                    ]
	                    
	                	either setup-results = true [
	                		evo-name: object-name
	                	][
	                		if active-voe? object-name [
	                			close-object-editor object-name	
	                			voe-object-renamed: true
	                		]
	                		new-object: true
	                		evo-name: setup-results
	                	]
	                ]
                	
					if not manual [
						if not unset? :update-downstream-voe [ ;-- VOE hasn't been run yet.
							update-downstream-voe/only evo-name		
						]
					]
					if any [ 
						all [ 
							new-object 
							evo-after-insert/status
							not manual
						]
						voe-object-renamed
					][
						edit-vid-object evo-name "vid-code"
					]
					
                ]
                
            	set 'zdelete-vid-object function [ ;-- delete-vid-object: func 
            		obj-name [string!]
            	][
            		obj-info: get-object-source/whitespace/position/with-newline obj-name vid-code/text
            		one-char-back: pick vid-code/text (obj-info/3/x - 1)
            		;one-char-back: " "
            		skip-amt: either one-char-back = #"^/" [ 2 ][ 1 ]
            		 
;            			either is-whitespace? one-char-back [
;            				1
;            			][
;            				1
;            			]	 
;            		]
            		full-src: copy/part ( skip vid-code/text obj-info/3/x - skip-amt ) (obj-info/3/y - obj-info/3/x + skip-amt)
            		remove/part ( skip vid-code/text obj-info/3/x - 1 ) (obj-info/3/y - obj-info/3/x + 1)
            		return reduce [ full-src obj-info/3/x ]
            	]
            	
            	delete-object: func [ 
            		obj-name 
            		src-position 
            		last-char 
            		/local res
            	][ 
                    res: delete-vid-object obj-name
                    run-and-save "delete-object"
                    close-object-editor obj-name ;-- This needs to happen last, otherwise crashes sometimes.
            	]

            	set 'insert-return-before function [ 
            		obj-name 
            		src-position 
            		last-char 
            	][ ;-- insert-return-before:
					insert-code "return" obj-name					
            	    run-and-save "insert-return-before"
            	]

                set 'remove-return-before func [ 
                	obj-name 
                	src-position 
                	last-char 
                ][
                    whitespace: charset " ^-^/]"
            	    backwards-offset: 20
            	    skip-amt: max (src-position/x - backwards-offset ) 0
            	    backwards-some: copy/part (skip vid-code/text skip-amt ) 40
            	    if (fnd: find/last backwards-some "return") [
            	        fnd-index: index? fnd
            	        start-pos: (skip-amt + fnd-index - 1)
            	        maybe-ret-selected: copy (skip vid-code/text start-pos ) ( src-position/y - start-pos )
                        obj-name-set-word: rejoin [obj-name ":"]
                        if parse maybe-ret-selected [
                            some ["return"  |
                                whitespace  |
                                obj-name-set-word to end
                            ]
                        ][
                            end-pos: src-position/x - start-pos - 1
                            to-remove: copy/part (skip vid-code/text start-pos) end-pos
                            remove/part (skip vid-code/text start-pos) end-pos
                            run-and-save "remove-return-before"
                        ]
            	    ]
            	]

            	save-object-image: func [ obj-name src-position last-char ][
            	    either attempt [
            	        img: to-image get to-word obj-name
            	    ][
            	        if (rf: request-file/title/file/filter "Save as ... '.png' file" current-path ["*.png"] )[
                            save rf img
                        ]
            	    ][
            	        request-message rejoin [ "Unable to convert '" obj-name "' to an image" ]
            	    ]
            	]

				set 'resync-selected-object function [ ;-- resync-selected-object:
					/extern dc-locked-on-object
				][ 
					sel-obj: get-object-source/position/whitespace selected-object-field/text vid-code/text
					either all [
						selected-object-field/text <> dc-default-selected-object-string 
						sel-obj: get-object-source/position/whitespace selected-object-field/text vid-code/text
					][
						code-location: 2 
						vid-code/selected: sel-obj/:code-location
						if dc-locked-on-object = [] [
							clear-vid-code-selected
						] 
					][
						clear-vid-code-selected
						if sel-obj = #(false) [
							un-highlight-source-object "" 0x0 ""	
						]
					]
				]

                move-back-1: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char -1
                ]

                move-back-2: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char -2
                ]

                move-back-3: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char -3
                ]

                move-back-4: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char -4
                ]

                move-forward-1: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char 1
                ]

                move-forward-2: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char 2
                ]

                move-forward-3: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char 3
                ]

                move-forward-4: func [ obj-name src-position last-char ][
                    move-object-relative obj-name src-position last-char 4
                ]

                move-to-beginning: func [ obj-name src-position last-char ][
                    move-object-relative/beginning obj-name src-position last-char -1
                ]

                move-to-end: func [ obj-name src-position last-char ][
                    move-object-relative/end obj-name src-position last-char 1
                ]

                move-to-left-edge: func [ obj-name src-position last-char ][
                    cur-oset:  get to-path reduce [ to-word rejoin [ "--voe-window-" obj-name ] 'offset ]
                    set to-path reduce [ to-word rejoin [ "--voe-window-" obj-name ] 'offset ] to-pair reduce [ 6 cur-oset/y]
                ]

                open-to-this-tab: func [ obj-name src-position last-char ][
                    confirm-type:  to-path reduce [ to-word rejoin [ "--voe-window-" obj-name ] 'pane 2	'type ]
                    pane-type: get confirm-type
                    either pane-type = 'tab-panel [
                          selected-tab: get to-path reduce [ to-word rejoin [ "--voe-window-" obj-name ] 'pane 2	'selected ]
                          set-voe-selected-tab selected-tab
                    ][
                        user-message "Sorry, unable to locate the tab panel you have selected."
                    ]
                ]

                voe-regular-font: function [
                    obj-name
                    src-position
                    last-char
                    /extern dc-voe-size

                ][
                    voe-set-font obj-name "regular"
                ]

                voe-large-font: func [
                    obj-name
                    src-position
                    last-char
                    /extern dc-voe-size

                ][
                    voe-set-font obj-name "large"
                ]

                voe-set-font: function [
                    obj-name [string!]
                    size-name [string!]
                    /extern dc-voe-size
                ][
                    either dc-voe-size = size-name [
                        request-message rejoin [ "The VID Object Editor is already set to a '" size-name "' font." ]
                    ][
                        close-object-editor obj-name
                        set-voe-size size-name

                        either value? to-word obj-name [ ;-- assuming if obj-name doesn't exist then it is a style
                            edit-vid-object  obj-name "vid-code"
                        ][
                            edit-vid-object/style  obj-name "vid-code"
                        ]

                    ]
                ]

                test-menu: func [ obj-name src-position last-char ][
                    move-object-relative/end obj-name src-position last-char 1
                ]

                set 'get-object-source-position function [ ;-- get-object-source-position:
                    source [string!]
                    object-name [ string! ]
                ][
                    cdta: second ( query-vid-object source object-name [])
                    return to-pair reduce  [ (first pick (first cdta) 10 ) (second pick (last cdta) 10 ) ]
                ]

                set 'voe-menu-handler function [	;-- voe-menu-handler: function 
                	obj-name [string!]
                	action [string!]
                	/lock lock-details [block!] {locks the highlight-source-object to the object indicated}
                	/no-editor
                	/extern dc-locked-on-object
                ][ 
                    
                    if all [ 
                    	(dc-locked-on-object <> [])
                    	(not lock)
                    	(action = "highlight-source-object")
                    ][
                    	lprint [ "voe-menu-handler #LOCK-IN-PLACE dc-locked-on-object =" mold dc-locked-on-object]
                    	tilde-id: 2
                    	
						target-obj-name: rejoin [ "target-object-label" dc-locked-on-object/:tilde-id ]
						if value? to-word target-obj-name [
							lock-obj: get to-word target-obj-name
	                    	current-lock-object: copy first dc-locked-on-object
	                    	do-actor lock-obj none 'down
	                    	lprint [ "voe-menu-handler #AFTER-ACTOR"]
	                    	dc-locked-on-object: copy []
	                    	if obj-name = current-lock-object [
		                    	action: "un-highlight-source-object"		
		                    	bprint [ "voe-menu-handler #ACTION-CHANGED = un-highlight-source-object" ]
	                    	]
						]
                    ]
                    
                    if lock [
                    	dc-locked-on-object: lock-details
                    	action: "lock-highlight-source-object"
                    ]
                    
                    query-res: query-vid-object vid-code/text obj-name []
                    if query-res/2 = #(false) [
                    	return none
                    ]
                    v-pos: query-res/1
                    v-src: query-res/2
                	
                	last-item: length? v-src
                	last-char: pick vid-code/text v-src/:last-item/token/y
					
					either none? v-pos [
			       		y-correction: 0
			        	if any [
			        		(last-char = none)
			        		(is-whitespace? last-char)	
			        	][
			        		y-correction: -1
			        	]                	
	                	obj-position: to-pair reduce [ v-src/1/token/x ( v-src/:last-item/token/y + y-correction )]
	                ][
	                	obj-position: v-pos 
	                ]
	                
                	
	                set [ selected-obj after end-of-script ] get-selected-object-info
	                either no-editor [
	                	menu-code: [ to-path reduce [ to-word action 'no-editor ] obj-name obj-position last-char selected-obj after ]	
	                ][
	                	menu-code: [ to-word action obj-name obj-position last-char selected-obj after ]		
	                ]

                    either error? err: try/all  [
                        do bind (reduce menu-code ) 'delete-object
                        true ;-- try return value
                    ][
                        print "*** MENU ACTION ERROR (Direct Code VID Object Editor Menu Handler) ****************************************"
                        print err
                        print "*********************************************************************************"

                        
                		return false
                    ][
                        return true
                    ]
                ]
            ]

            load-direct-code dc-reactor/current-file
        ]
        splitv: split-style 6x100 data [pan/size splith/size setup-code/size vid-code/size output-panel/size output-panel/offset ]
        output-panel: panel output-panel-size 
        	data [ 'dc-output-panel ]	
    ]

    mainwin/menu: [
        "File" [
            "New"                              	new
            "Open                             	Ctrl+O"  open
            "Open with External Editor"        	open-external
            "Save  (AND RUN)          Ctrl+S"  	run-interpreter
            "Save As             Ctrl+Shift+S" 	save-as
            "________________________"	     	none
            "Save As Next Version"           	save-as-next-version
            "Save Backup Version"            	save-backup-version
            "Save Image of GUI created"      	save-gui-image
            "________________________"		 	none
            "Open Current Folder"            	show-cd
            "Recent Files" []
            "Reload" [
                "Reload Now" reload
                "Reload when File changes: ON"   reload-when-changed-on
                "Reload when File changes: OFF"  reload-when-changed-off
            ]

            "Run Separately    F9"       run-separate
            "Do File (Attached)    F6"   do-the-current-file
            "Restart Direct Code    F12" restart-program
        ]
        "Edit" [
            "Setup Code" [
                "Undo      Ctrl + Shift + Z"   setup-undo
                "Redo      Ctrl + Shift + Y"   setup-redo
            ]
            "VID Code" [
                "Undo      Ctrl + Shift + Z"   vid-undo
                "Redo      Ctrl + Shift + Y"   vid-redo
                "Prettify VID Code"			  pretty-vid
            ]
           	"Window Config. / Program Completion"   win-cfg            	

        ]
        "Object" [
            "Manage Named Objects"    	show-named-objects
            "Object Browser"        	object-browser
        ]
        "Debug" [
            "Logging" [
                "View Log File"     show-log
                "Logging OFF -    F8"  change-logging-off
                "Logging ON   -    F8" change-logging-on
            ]

            "System" [
                "Dump Reactions"                show-all-reactions
                "System/view/debug ON -    F11"    system-view-debug-on
                "System/view/debug OFF-    F11"    system-view-debug-off
            ]
        ]
        "Settings" [
            "Red Executable"    			set-red-exe
            "External Editor"   			set-ext-editor
            "Edit 'facet-setup-list'" 		edit-facet-setup-list
            "Auto Open VID Editor - ON"   	evo-after-insert-on
            "Auto Open VID Editor - OFF"  	evo-after-insert-off
            "Insert Tool Pinned"  			insert-tool-pinned-on
            "Insert Tool NOT Pinned" 		insert-tool-pinned-off
        ]
        "User" [
            "Run User Script   F7" run-user-stuff
            "Edit User Script" edit-user-stuff
        ]
        "Help" [
            "Direct Code Online Help    F1"   direct-code-help
            "Quick Start Guide"         quick-start-guide
            "Red Online Search Tool"    red-online-search-tool
            "Create Error Report"       create-error-report
            "About"                     help-about
            "Red Version"               red-version
        ]
    ]
    mainwin/actors: make object! [
        on-menu: function [face [object!] event [event!]][
            switch/default event/picked [
            	pretty-vid [ prettify-vid-code       ]
                setup-undo [ dc-undo-redo/setup/undo ]
                setup-redo [ dc-undo-redo/setup/redo ]
                vid-undo   [ dc-undo-redo/vid/undo   ]
                vid-redo   [ dc-undo-redo/vid/redo   ]
                win-cfg    [
					either dc-code-version = 2 [
	                    edit-show-window-code get-show-window-code (read current-file)
	                ][
	                    print "Version 1 doesn't have window config"
	                ]                 	
                ]
                recent-1  [ load-and-run recent-menu/get-item 1 ]
                recent-2  [ load-and-run recent-menu/get-item 2 ]
                recent-3  [ load-and-run recent-menu/get-item 3 ]
                recent-4  [ load-and-run recent-menu/get-item 4 ]
                recent-5  [ load-and-run recent-menu/get-item 5 ]
                recent-6  [ load-and-run recent-menu/get-item 6 ]
                recent-7  [ load-and-run recent-menu/get-item 7 ]
                recent-8  [ load-and-run recent-menu/get-item 8 ]
                recent-9  [ load-and-run recent-menu/get-item 9 ]
                recent-10 [ load-and-run recent-menu/get-item 10 ]
                recent-11 [ load-and-run recent-menu/get-item 11 ]
                save-as  [ save-dc ]
                save-as-next-version [ save-dc/next-version ]
                save-backup-version [ save-dc/backup-version ]
                save-gui-image [ save-gui-image-file ]
                show-cd [ show-current-folder ]
                open  [ open-dc ]
                open-external [
                    editor/monitor dc-reactor/current-file
                ]
                new   [ new-dc ]
                reload [ load-and-run dc-reactor/current-file ]
                reload-when-changed-on [ monitor-file-change true ]
                reload-when-changed-off [ monitor-file-change false  ]
                restart-program [ restart-direct-code ]
                object-browser [ red-object-browser ]

                system-view-debug-on  [ system/view/debug?: true ]
                system-view-debug-off [ system/view/debug?: false ]
                evo-after-insert-on   [ evo-after-insert/on  ]
                evo-after-insert-off  [ evo-after-insert/off ]
                insert-tool-pinned-on [ insert-tool-pinned/on ]
                insert-tool-pinned-off [ insert-tool-pinned/off ]

                show-all-reactions [ dump-reactions ]
                show-log [
                    either exists? to-file dc-external-editor  [
                        call rejoin [ to-local-file dc-external-editor " " to-local-file repend what-dir %direct-code.log ]
                    ][
                        set-external-editor/none-set
                    ]
                ]

                show-named-objects [
                    named-objs: get-list-of-named-objects/every
                    print [ newline "------ START OF NAMED OBJECTS ------" ]
                    ndx: 1
                    foreach obj-name named-objs [
                        print rejoin [ pad/left rejoin [ ndx ") "] 4 obj-name ]
                        ndx: ndx + 1
                    ]
                    print [ "------ END OF NAMED OBJECTS ------" ]
                    show-named-objects-gui named-objs
                ]
                run-separate [
                    run-program-separately
                ]
                do-the-current-file [
                    do-current-file
                ]
                run-interpreter [
                    run-and-save "run-interpreter"
                ]
                set-red-exe [ set-red-executable ]
                set-ext-editor [ set-external-editor ]
                edit-facet-setup-list [ editor rejoin [ root-path %settings/facet-setup-list.data ] ]
                run-user-stuff [ run-user-script ]
                edit-user-stuff [ edit-user-script]
                goto-edit-vid-object [ edit-evo ]
                direct-code-help [
                    browse https://github.com/mikeyaunish/direct-code/blob/master/docs/SUMMARY.adoc
                ]
                quick-start-guide [
                    load-and-run rejoin [ root-path %help/quick-start-guide.red ]
                ]
                help-about [
                    request-message/size
                        read rejoin [ root-path %help/help-about.txt ]
                        700x300
                ]
                create-error-report [
                    error-report-file: get-unique-version-name  to-file rejoin [ root-path %support-scripts/error-report.txt ]
                    print [ "Error report created:" error-report-file ]
                    write error-report-file rejoin [
                        form dc-last-setup-code-error
                        form dc-last-vid-code-error
                    ]
                ]
                red-online-search-tool [
                    do rejoin [ root-path %tools/red-online-search-tool.red ]
                ]
                
                red-version [
                    request-message
                        rejoin [ "Red Build " system/version " - " system/build/git/date ]
                ]
                change-logging-on [
                    change-logging/on
                ]
                change-logging-off [
                    change-logging/off
                ]
                insert-style-use-catalog [
                    insert-style-from-catalog
                ]
                
            ][ ;-- switch/default 
            ]
        ]
    ]
    view/flags/options mainwin [
        resize        ;-- flags
    ][
        offset: 0x0   ;-- options
    ]
]
