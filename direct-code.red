Red [
    Title:   "Direct Code"
    Author:  "Nenad Rakocevic / Didier Cadieu / Mike Yaunish"
    File:    %direct-code.red
    Version: 1.4.0
    Needs:   'View
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
                              reflect the impetus to create a larger scope for the project}
    ]
    Tabs: 4
]
;E:\Program Files (x86)\IDM Computer Solutions\UltraEdit\uedit64.exe

#include %support-scripts/direct-code-includes.red

get-list-of-named-objects: function [] [ 
    res-blk: copy []
    foreach-face output-panel [ 
        obj-name: find-object-name face 
        if obj-name <> "*unusable-no-name*" [
            append res-blk obj-name
        ]
    ]
    return res-blk
]

dc-ctx: context [    
    ; Isolate the code to not missbehave on some reuse of its words by the user code
    root-path: copy what-dir
    
    --obj-selected: none
    --over-face: none
    if (exists? %user.red)[ do %user.red ]
    dc-reactor: make reactor! [
        current-file: clean-path %default-direct-code.red    
        active-object: ""
        active-object-color: black
    ]
    current-path: does [ first split-path dc-reactor/current-file ]
    
    setup-size: 800x200    
    vid-size: 800x400
    output-panel-size: 800x600    
    live-update?: true
    
    red-executable: copy ""
    external-editor: copy ""
    --move-pointer-origin: -50x-50
    direct-code-settings: clean-path %direct-code-settings.data
    set-red-executable: does [
        if ( red-ex: request-a-file any [ :red-executable  "" ] "Where is the Red executable?" "Red Executable File: " ) [
            red-executable: red-ex
        ]
    ]
    set-external-editor: does [
        if ( external-ed: request-a-file any [ :external-editor  "" ] "Where is your External Text Editor?" "External Editor: " ) [
            external-editor: external-ed
        ]
    ]
    run-program-separately: does [
        call/shell rejoin [ to-local-file red-executable " " to-local-file dc-reactor/current-file ]
    ]
    monitor-file-change: function [ status ] [
        either status [
            the-rate: 00:00:00.250
            the-color: 0.200.0
        ][
            the-rate: 999:00:00
            the-color: blue
        ]
        check-for-file-change/rate: the-rate
        check-for-file-change/color: the-color
    ]
    find-unused-object-name: function [ obj-prefix [ string!]] [
        bprint [ "obj-prefix = " mold obj-prefix ]
        ndx: 1
        obj-search: rejoin [ obj-prefix ndx  ":" ]
        while [ 
            if any [  
                find setup-code/text obj-search
                find vid-code/text obj-search
            ][ true ]
        ][
            ndx: ndx + 1
            obj-search: rejoin [ obj-prefix ndx ":"]
        ]
        return rejoin [ obj-prefix ndx ]
    ]
    insert-object: function [ obj-type ][
        obj-template: [ 
            field [ (obj-set-word) field (obj-name) loose ]
            button [ (obj-set-word) button (obj-name) loose ]
            base [ (obj-set-word) base white black (obj-name) loose ]
        ]
        name-prefix: [ field "fld" button "btn" base "base"]
        obj-name: find-unused-object-name select name-prefix obj-type
        obj-set-word: to-set-word obj-name
        append vid-code/text newline
        append vid-code/text mold/only compose select obj-template obj-type
        run-and-save
    ]
    insert-direct-code-stand-alone: has [ 
        indent-hint 
        indent-text 
        file-prefix
    ][
        either find what-dir root-path [
            what-dir-len: length? split to-string what-dir "/"
            root-path-len: length? split to-string root-path "/"
            file-prefix: "%"
            append/dup file-prefix "../" (what-dir-len - root-path-len)
            indent-text: ""
            if setup-code/text <> "" [
                indent-hint: copy/part setup-code/text 4
                if any [
                    ((first indent-hint) = #"^-")
                    (indent-hint = "    ")    
                ][
                    indent-text: "    "
                ]
            ]
            insert setup-code/text rejoin [ indent-text {#include } file-prefix {direct-code-stand-alone.red} "^/" ]
            save-direct-code dc-reactor/current-file 
        ] [
            request-message {The current directory doesn't have an obviouse path back to^/the file %direct-code-stand-alone.red^/You will have to add this #include manually}    
        ]
    ]
    extract-setup-code: function [ the-code ] [
         un-block-string any [ (second split ( first split the-code "view [") "do setup:") ""  ]
    ]
    extract-vid-code: function [ the-code ] [ 
        un-block-string any [ (second split the-code "^/view " ) "" ] 
    ]
    load-direct-code: function [filename [ file! ] ] 
    [
        filename: clean-path filename
        if (exists? filename)[
            setup-code/text: extract-setup-code (filedata: read filename) 
            vid-code/text: extract-vid-code filedata
            dc-reactor/current-file: filename
            change-dir first split-path filename
        ]
    ]
    save-direct-code: function [ filename [ file!] ]
    [
        tf: copy ""
        write filename append tf reduce [
            {Red [^/^-Title: "} to-string second split-path filename {"}
            {^/^-Needs: View}
            {^/^-Comment: "Generated with Direct Code"} ; "
            {^/]^/}
            {^/^/}
            {do setup:} 
            string-to-block/no-indent any [ setup-code/text "" ]
            {^/}
            "^/^/"
            "view "
            string-to-block/no-indent any [ vid-code/text "" ]
            {^/}
        ]
        save repend ( copy root-path ) %direct-code-settings.data reduce [ 
            'filename filename
            'setup-size setup-code/size
            'vid-size vid-code/size
            'output-panel-size output-panel/size 
            'live-update? live-update?
            'red-executable red-executable
            'external-editor external-editor
        ]
        change-dir first split-path filename
    ]
        
    get-matrix-actions: function [ action-object-name action-name ] [
        if action-object-name <> "no-action" [
            lprint [ "GET-MATRIX-ACTIONS for: " action-object-name "/" action-name] 
            action-object-name-to-word: to-word action-object-name
    		action-obj: dc-matrix/:action-object-name-to-word
    		action-name-to-word: to-word action-name
    		return get in action-obj action-name-to-word		
        ]
    ]    
    
    update-source-code: function [ obj-name action-object-name ] [ 
        upd-src-func: get-matrix-actions action-object-name 'update-source-code
        bind body-of :upd-src-func dc-ctx
        upd-src-func obj-name
        active-filename/color: yellow        
    ]    

    inserts-to-vid-code: [] ; This will be used in the next version of direct-code
    
    run-and-save: func [ /no-save ] [ ;-- save only happens if the run is successful
        either error? err: try/all [ 
            if setup-code/text [
                do load setup-code/text
            ]
            true ; makes try happy
        ][
            print "--- SETUP CODE ERROR / VID CODE IGNORED ------"
            print err
            print "----------------------------------------------"
            active-filename/color: yellow
            setup-code/color: yellow 
        ][ ;-- setup code ran clean
            either error? err: try/all [ 
                if vid-code/text [
                    the-vid-code: load vid-code/text
                    insert the-vid-code new-line inserts-to-vid-code true 
                    ;output-panel/pane: layout/only new-lay: load vid-code/text
                    output-panel/pane: layout/only new-lay: the-vid-code
                    ;lprint reduce [ "new-lay = " mold new-lay ]
                ]
                true ;-- makes try happy
            ][
                print "--- VID CODE ERROR ---------------------------"
                print err
                print "---------------------------------------------- "                
                active-filename/color: yellow
                vid-code/color: yellow
            ][
                setup-code/color: white
                vid-code/color: white
                if not no-save [ 
                    save-direct-code dc-reactor/current-file 
                ]
                active-filename/color: white
                append new-lay appends-to-layout 
                output-panel/pane: layout/only new-lay
            ]
        ]
    ]
    
    left-control-down: false
    either (exists? direct-code-settings) [ 
        llf: load direct-code-settings
        dc-reactor/current-file: llf/filename 
        setup-size: llf/setup-size
        vid-size: llf/vid-size
        output-panel-size: llf/output-panel-size
        live-update?: all-to-logic llf/live-update?
        if not red-executable: llf/red-executable [
            set-red-executable
        ]
        if not external-editor: llf/external-editor [
            set-external-editor
        ]
    ][
        z: request-message rejoin [ 
            "To make full use of 'Direct Code' It is advisable" newline
            "to configure these two items under the Settings Menu:" newline
            "1.) Red Executable" newline
            "2.) External Editor" 
        ]
    ]
    
    show-object-details: function [ obj obj-name] [
        g: copy obj 
        g/parent: "...SKIPPED..."
        print [ newline "     OBJECT NAME                   " obj-name ]
        print [ ? g ]
    ]

    select-object: func [ f /local g obj-name ] [
        if --obj-selected [
            dc-matrix/deactivate
			if not none? f/extra [  
			    f/extra/track: 0     
			]
    	]
    	obj-name: find-object-name f
        dc-reactor/active-object: obj-name
        
        either ( obj-name = "*unusable-no-name*")[
            dc-reactor/active-object-color: orange
            --obj-selected: none
        ][
            --obj-selected: f    
            dc-reactor/active-object-color: black
            either object-action-selected/text = "no-action" [
                
            ][
                dc-matrix/activate to-word object-action-selected/text
            ]
                        
            if not none? f/extra [
                if f/extra/track [
                    f/extra/track: 1
                ]
            ]
        ]
    ]

    restart-direct-code: does [
        unview/all
        remove-event-func :direct-code-event-handler
        unset 'first-run?
        call/shell rejoin [ to-local-file red-executable " " to-local-file clean-path %direct-code.red     ]
    ]
    
    direct-code-event-handler: func [
        face [object!] 
        event [event!]
    ][
        if all [ ( event/key = 'F12) (event/type = 'key-up) ] [
            restart-direct-code
        ]
        if event/type = 'over [
            --over-face: face
        ]
        
        if any [ (event/type = 'up) ] [
            if  (--over-face <> face)[
                --over-face: false    
            ]
        ]
        
        if any [ 
            (event/type = 'mid-down)
            all [(event/key = to-char 192) (event/type = 'key-down) left-control-down ] ; Control + Tilde
        ][
            if (--over-face/parent = output-panel) [
                either not --obj-selected [
                    select-object --over-face
                ][
                    if all [
                        (--over-face <> --move-pointer)
                        (--over-face <> --obj-selected)
                    ][
                        dc-matrix/deactivate
                        select-object --over-face
                    ]
                ]
            ]
        ]
        
        if all [ (event/key = 'left-control) (event/type = 'key-down )][
            left-control-down: true
        ]
        if all [ (event/key = 'left-control) (event/type = 'key-up )][
            left-control-down: false
        ]
        if all [ 
            (event/type = 'key-up)
            any [ (event/key = 'right-control) (event/key = 'F5)  ] 
        ][
            run-and-save
        ]
        if event/key = 'F11 [
            system/view/debug?: xor~ system/view/debug? true
        ]
        
        if all [ event/key = 'F10  event/type = 'key-up ][
            monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ]
        ]
        if all [ event/key = 'F9  event/type = 'key-up ][
            run-program-separately 
        ]
        if event/type = 'moving [ ; A little hacky -  fires off the first interpret after the program has loaded.
            if not (value? 'first-run?) [
                first-run?: false
                delete %direct-code.log
                run-and-save
            ]
        ]
        
        if event/type = 'close [
            if event/window/text = "Red Direct Code" [ 
                run-and-save
                remove-event-func :direct-code-event-handler    
            ]
        ]
        
        ; This handle the resize of window content when it is resized
        if event/type = 'resize [
            sz: mainwin/size - orig
            pan/size/y: sz/y - pan/offset/y
            vid-code/size/y: pan/size/y - vid-code/offset/y - orig/y
            output-panel/size: sz - output-panel/offset
            splitv/size/y: sz/y - splitv/offset/y
            'done
        ]
        return none
    ]
    insert-event-func :direct-code-event-handler

    ; There is a spliter style that does what a splitter must do. Here is the functions it needs.
    ; Initialize the spliter data in regards to its initial content.
    on-spliter-init: func [face [object!] /local data v sz? op axis] [
        ; init global value
        face/extra/fixedaxis: select [x y x] face/extra/axis: axis: either face/size/x < face/size/y ['x] ['y]
        if not block? data: face/data [exit]
        ; Here is updated the face/data block by computing if the value of a move must be added or subtract
        ; to the facet regarding the face position, then store the operator next to the value.
        forall data [
            v: copy data/1
            ; search the face! object in the path
            while [all [not empty? v  not face? get v]] [all [sz?: take/last v  none? find [size offset] sz?  sz?: none]]
            all [
                not empty? v
                v: get v
                ; use 'add or 'substract depends on where it is in regards of the spliter and the property to change
                op: pick [+ -] (v/offset/:axis > face/offset/:axis) xor (sz? = 'size)
                insert data: next data op
            ]
        ]
    ]

    ; This func does what is needed when a splitter is moved.
    ; The splitter/data block! must contain pairs of "facet operator" values, where :
    ; - "facet" is a face path ending by /size or /offset that must be changed when the splitter move like a-face/size or a-face/offset,
    ; - "operator" is one of '+ or '-, and determines if the move amount is added or subtract to the "facet" value.
    on-spliter-move: func [face [object!] /local amount fa] [
        fa: face/extra/fixedaxis
        face/offset/:fa: face/extra/offset/:fa              ; must not move on the fixed axis
        amount: face/offset - face/extra/offset             ; amount of the move since the last move
        face/extra/offset: face/offset                      ; store the new offset
        if any [amount = 0x0 not block? face/data] [exit]
        foreach [prop op] face/data [
            do reduce [load rejoin [form prop ":"] prop op amount]          ; update the value with the new amount. I miss 'to-set-word here
        ]
    ]
    orig: 4x4

    appends-to-layout: [
        at -50x-50 --move-pointer: base transparent 40x40 draw [
        	line-width 20 pen transparent
        	circle 19x20 10
        	line-width 3 pen white
        	line 15x40 15x0
        	line 23x40 23x0 
        	line 0x16 40x16
        	line 0x24 40x24
        	line-width 4 pen black
        	line 19x40 19x0
        	line 0x20 40x20
        ]
        on-drop [ 
            dc-matrix/deactivate
            obj-name: find-object-name --obj-selected
            update-source-code obj-name 'move-object
			--obj-selected: none
			run-and-save
        ] loose
    ]

    red-object-browser: does [ do repend (copy root-path)  %tools/red-object-browser.red ]

    view/flags/options/no-wait mainwin: layout [
        title "Red Direct Code"
        backdrop gray
        origin orig

        style dc-button: button loose on-create [
            change-function-in-object face 'on-change* new-line (f-block: reduce [ 'track-changes find-object-name face ]) true
            change-function-in-object face 'on-deep-change* new-line (f-block: reduce [ 'track-changes/deep find-object-name face ]) true
        ]  
        
        style redbase: base red 
        
        space 0x0

        style area: area font-name "Fixedsys"
        style split: base 30x6 loose extra ['offset none 'auto-sync? none 'axis none 'fixedaxis none]
            on-drag-start [face/extra/offset: face/offset face/extra/auto-sync?: system/view/auto-sync? system/view/auto-sync?: no] ; Need to disable realtime mode as the position is changed by the drag an the code
            on-drag [on-spliter-move face show face/parent]
            on-drop [system/view/auto-sync?: face/extra/auto-sync?] ; Don't forget to reset realtime mode to its previous value
            on-over [face/color: either event/away? [gray][blue]]
            on-create [on-spliter-init face]
        

        pan: panel [
            below
            origin orig
            space 10x2
            across
            update-check: check "Live Update " font-size 12 data live-update? [ 
                live-update?: update-check/data 
                save-direct-code dc-reactor/current-file
            ]
            space 0x4
            check-for-file-change: base 40x24 blue font-size 12 bold right white "File: " rate 999:00:00 ; hold here until we turn it on
                on-down [ 
                    load-and-run dc-reactor/current-file
                    monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ] 
                ]
                on-time [
                    if file-modified? dc-reactor/current-file [
                        load-and-run/no-save dc-reactor/current-file
                    ]         
                ]
            active-filename: text font-size 12 180x24 center white 
                extra [ 'first-over? true ]
                react [ active-filename/text:  to-string second split-path dc-reactor/current-file ]
                on-down [ run-and-save ]
                on-over [
            	    either event/away? [
            	        active-filename/extra/first-over?: 'true
            	        popup-help/close ""
            	    ][
            	        if active-filename/extra/first-over? = 'true [
            	            active-filename/extra/first-over?: 'false 
            	            popup-help/offset (to-string first split-path dc-reactor/current-file) (face/parent/parent/offset + face/offset + event/offset + 20x0  )        
            	        ]
            	    ]
                ]
            space 6x4            
            base 60x24 font-size 12 bold right "Object: " blue white  on-down [ red-object-browser ]
            space 0x4
            active-object: button font-size 12 170x24 font [color: black ] bold  [
                if all [ 
                    active-object/text <> "" 
                    active-object/text <> "*unusable-no-name*" 
                ][
                    show-object-details (get to-word active-object/text) active-object/text 
                ]
            ]
            
            react [ 
                active-object/text: dc-reactor/active-object
                active-object/font/color: dc-reactor/active-object-color
            ] 
            action-label: text 60x24 font-size 12 bold right blue white "action>"
            object-action-selected: drop-down font-size 10 
                data [ "move-object" "no-action" ] "move-object"
                on-select [ if object-action-selected/text = "no-action" [ dc-matrix/deactivate ] ]
            space 4x4
            return
            below
            text "Setup Code (before layout) :" 200x15
            setup-code: area setup-size on-key-up [ check-source-change event/key ] 
            pad 0x4
            ; horizontal splitter
            splith: split 800x6 data [setup-code/size vidtit/offset vid-code/offset vid-code/size]

            vidtit: text "Layout code in VID dialect :" 150x15
            vid-code: area vid-size on-key-up [ check-source-change event/key ] 
        ]
                
        do [
            check-source-change: function [ keycode ][
                if all [ (keycode <> 'right-control ) (keycode <> 'F5 ) ][
                    either live-update? [ 
                        run-and-save 
                    ][
                        active-filename/color: yellow                        
                    ] 
                ]    
            ]
            save-dc: does  [
                if (rf: request-file/title/file "Save as" current-path ) [
                    copy-file dc-reactor/current-file rf    
                    dc-reactor/current-file: copy rf
                ]
            ]
            open-dc: does  [
                if (rf: request-file/title/file "Open" current-path  ) [
                    load-direct-code rf
                    run-and-save
                ]
            ]
            new-dc: does [
                if (rf: request-file/title/file "Specify a NEW file name" current-path ) [
                    setup-code/text: ""
                    vid-code/text: ""
                    dc-reactor/current-file: rf
                    run-and-save
                ]
            ]
            load-direct-code dc-reactor/current-file
        ]
        ; vertical spliter
        splitv: split 6x100 data [pan/size splith/size setup-code/size vid-code/size output-panel/size output-panel/offset]
        output-panel: panel output-panel-size
    ][  
        resize        ;-- flags
    ][  
        offset: 0x0  ;-- options
    ]

        
    mainwin/menu: [
        "File" [ 
            "Save As"           save-as
            "Open"              open   
            "Open with External Editor" open-external
            "New"               new
            "Reload" [
                "Reload Now" reload
                "Reload when changed ON - F10"  reload-when-changed-on    
                "Reload when changed OFF -F10"  reload-when-changed-off   
            ]           
            "Run Separately - F9"    run-separate
            "Restart Direct Code - F12" restart-program
        ]
        "Insert" [
            "Field"             ins-field
            "Button"            ins-button
            "Base"              ins-base
            "Includes" [
                    "direct-code-stand-alone" ins-dc-stand-alone 
            ]
        ]
        "Tools" [
            "Object Browser" object-browser
        ]
        "Debug" [
            "View Log File" show-log
            "System" [
                "System/view/debug ON - F11"  system-view-debug-on
                "System/view/debug OFF- F11" system-view-debug-off
            ]
            "Objects" [
                "Show Named Objects" show-named-objects
            ]
        ]
        "Settings" [
            "Red Executable" set-red-exe
            "External Editor" set-ext-editor
        ]
        "Help" [
            "Direct Code Help" direct-code-help
            "About" help-about
        ]
    ]
    mainwin/actors: make object! [
        on-menu: func [face [object!] event [event!]][ 
            switch event/picked [
                save-as  [ save-dc ]
                open  [ open-dc ]
                open-external [
                    either exists? to-file external-editor  [
                        call rejoin [ to-local-file external-editor " " to-local-file dc-reactor/current-file ]    
                    ][
                        request-message {The external text editor hasn't been set yet.^/Please select your external text editor through ^/the 'Settings/External Editor' menu}
                    ]
                ]
                new   [ new-dc ]
                reload [ load-and-run dc-reactor/current-file ]
                reload-when-changed-on [ monitor-file-change true ]
                reload-when-changed-off [ monitor-file-change false  ]
                restart-program [ restart-direct-code ]
                ins-field [ insert-object 'field ]
                ins-button [ insert-object 'button ]
                ins-base [ insert-object 'base ]
                ins-dc-stand-alone [ insert-direct-code-stand-alone ]
                object-browser [ red-object-browser ]
                system-view-debug-on [ system/view/debug?: true ]
                system-view-debug-off [ system/view/debug?: false ]
                show-log [
                    either exists? to-file external-editor  [
                        call rejoin [ to-local-file external-editor " " to-local-file repend what-dir %direct-code.log ]    
                    ][
                        request-message {The external text editor hasn't been set yet.^/Please select your external text editor through ^/the 'Settings/External Editor' menu}
                    ]
                ]
                show-named-objects [
                    print [ newline "------ START OF NAMED OBJECTS ------" ]
                    ndx: 1
                    foreach-face output-panel [ 
                        face-name: find-object-name face 
                        print rejoin [ ndx ") " face-name ]
                        ndx: ndx + 1
                    ]
                    print [ "------ END OF NAMED OBJECTS ------" ]
                ]
                run-separate [ 
                    run-program-separately
                ]
                set-red-exe [ set-red-executable ]
                set-ext-editor [ set-external-editor ]
                direct-code-help [
                    do repend copy (root-path) %help/direct-code-help.red 
                ]
                help-about [
                    request-message/size  read repend copy root-path %help/help-about.txt 700x300
                ]
            ] 
        ] 
    ]    
]


