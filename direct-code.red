Red [
    Title:   "Direct Code"
    Author:  "Nenad Rakocevic / Didier Cadieu / Mike Yaunish"
    File:    %direct-code.red
    Version: 2.0.1
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
                              reflect the impetus to create a larger scope for the project(Mike)}
        2.0.0 "03-01-2021"   {Full rewrite of code generation engine. (Mike)}   
        2.0.1 "15-02-2021"   {Correctly parse blocks imbedded in vid code}    
        3.0.0 "19-03-2022"   {Full rewrite of the code generation engine (again) using transcode. 
                              Rebuild the VID Object Editor to enable changing every facet of an object.}
    ]
    Tabs: 4
]

set 'root-path copy what-dir

#include %support-scripts/direct-code-includes.red
lprint: function [ s /no-newline ] [
    if global-logging [
        either no-newline [
            write/append %direct-code.log form reduce s    
        ][
            write/append/lines %direct-code.log form reduce s        
        ]
    ]
]
bprint: function [s] [
    lprint s
    print form reduce s
]
dc-ctx: context [    
    set 'root-path copy what-dir
    --obj-selected: none
    set '--dc-mainwin-offset 0x0
    --over-face: none
    set 'dc-evo-layout-template-file rejoin [ root-path %support-scripts/evo-layout-template.red ]
    set 'dc-evo-layout-template-data read dc-evo-layout-template-file 
    set 'active-evo-windows copy []
    set 'internal-source-change-flag? false
    set 'dc-last-setup-code-error copy []
    set 'dc-last-vid-code-error copy []
    set '--evo-window make object!  [size: 0x0 offset: 0x0] 
    set 'current-file copy ""   
    dc-reactor: make reactor! [
        ;current-file: clean-path %default-direct-code.red    
        current-file: clean-path %help/welcome-to-direct-code.red    
        active-object: ""
    ]
    current-path: does [ first split-path dc-reactor/current-file ]
    setup-size: 800x200    
    vid-size: 800x232
    output-panel-size: 987x526    
    live-update?: ""
    evo-after-insert?: true
    set 'dc-voe-selected-tab 1 ;-- This is global because it needs to be read by VOE
    set 'dc-voe-size "regular"
    last-red-cmd: copy ""
    reload-on-change?: false
    set 'global-logging false
    
    red-executable: none
    set 'dc-external-editor none
    set 'dc-external-editor-commands [
        needs-shell?: none
        plain-open: [ editor-executable " " filename ]
        open-to-line: none
        open-to-column: none
    ]
    
    direct-code-settings: clean-path %direct-code-settings.data
    
    set 'vid-code-marker {;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!} ;-- vid-code-marker:
    set 'get-list-of-named-objects function [] [ 
        res-blk: copy []
        foreach-face output-panel [ 
            obj-name: find-object-name face 
            if obj-name <> "*unusable-no-name*" [
                append res-blk obj-name
            ]
        ]
        return res-blk
    ]    
    set-red-executable: function [ 
        /none-set 
        /extern red-executable
    ][
        full-msg: "Where is the Red executable file?"
        either none-set [
             full-msg: copy rejoin ["The current 'Red Executable' Setting is missing or incomplete ^/" full-msg ]
             refines: copy [ skip-button ]
        ][
            refines: copy []
        ]        
        if red-ex: do refine-function/args request-a-file refines reduce [ 
            any [ (if (red-executable <> 'none) [red-executable])  "" ] 
            full-msg 
            "Red Executable File:" 
        ][
            red-executable: red-ex
            save-settings
        ]        
    ]
    set-external-editor: function [ 
        /none-set 
        /extern dc-external-editor
    ][
        full-msg: "Where is your External Text Editor?"
        either none-set [
             full-msg: copy rejoin ["The current 'External Text Editor' Setting is missing or incomplete ^/" full-msg ]
             refines: copy [ skip-button ]
        ][
            refines: copy []
        ]        
        if external-ed: do refine-function/args request-a-file refines reduce [ 
            any [ (if (dc-external-editor <> 'none) [ dc-external-editor ])  "" ] 
            full-msg 
            "External Text Editor:" 
        ][
            dc-external-editor: external-ed
            save-settings
        ]        
    ]
    set 'run-script function [ 
        {Run a Red script while protecting the current directory}
        filename {The full path and filename to the script}
    ] 
    [
        cur-dir: system/options/path
        do filename
        change-dir cur-dir
    ]
    
    run-user-script: func [] [ 
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
            the-color: 0.200.0
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
    
    find-unused-object-name: function [ obj-prefix [ string!]] [
        obj-midfix: pick [ "-" "" ] (all-to-logic find ["h1" "h2" "h3" "h4" "h5"] obj-prefix )
        ndx: 1
        obj-search: rejoin [ obj-prefix obj-midfix ndx  ":" ]
        while [ 
            if any [  
                find setup-code/text obj-search
                find vid-code/text obj-search
            ][ true ]
        ][
            ndx: ndx + 1
            obj-search: rejoin [ obj-prefix obj-midfix ndx ":"]
        ]
        return rejoin [ obj-prefix obj-midfix ndx ]
    ]
    
    set 'insert-vid-object function [ ;-- insert-vid-object:
        obj-type 
        /with-on-click on-click-code [block!] 
        /with-text text-string [string!]
    ][ 
        if obj-type = none [ 
            return none
        ]
        either ((copy/part to-string obj-type 4) = "ins-") [ ;-- This is to deal with the menu selection stuff
            orig-obj-name: copy skip to-string obj-type 4
        ][
            orig-obj-name: copy obj-type
        ]

        get-last-line-indent: function [ str ] [
            tbs: 0
            spcs: 0
            last-line: find/last str "^/"
            check-pos: either (last-line: find/last str "^/") [ skip last-line 1 ][ str ]
        	parse check-pos [ some [ "^-" ( tbs: tbs + 1 ) | " " (spcs: spcs + 1) ]  ]
        	return either any [ (tbs > 0) (spcs > 0 ) ] [
                pad (copy "") (spcs + (tbs * 4))
            ][
                ""    
            ]
        ]
                
        obj-template: [ 
            base        [ (obj-set-word) base         (obj-name)            font-color 255.255.255]
            text        [ (obj-set-word) text         (obj-name)           ]
            button      [ (obj-set-word) button       (obj-name)           ]
            check       [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            radio       [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            toggle      [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            field       [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            area        [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            image       [ (obj-set-word) (to-word orig-obj-name)           ]
            text-list   [ (obj-set-word) (to-word orig-obj-name)            data ["one" "two" "three" "four"] select 2 ]
            drop-list   [ (obj-set-word) (to-word orig-obj-name)            data ["one" "two" "three" "four"] select 2 ]
            drop-down   [ (obj-set-word) (to-word orig-obj-name)            data ["one" "two" "three" "four"] select 2 ]
            calendar    [ (obj-set-word) (to-word orig-obj-name)           ]
            progress    [ (obj-set-word) (to-word orig-obj-name) (obj-name) data 25% ]
            slider      [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            camera      [ (obj-set-word) (to-word orig-obj-name)             330x250 on-create [ (to-set-path rejoin [to-string obj-set-word "/selected" ]) 1 ] ]
            panel       [ (obj-set-word) (to-word orig-obj-name) (obj-name)  250.250.250 [ panel-button1: button "panel-button1"] ]
            tab-panel   [ (obj-set-word) (to-word orig-obj-name) (obj-name) [ "Tab-A" [ tab-a-btn1: button "tab-A-btn1"] "Tab-B" [ tab-b-btn1: button "tab-B-btn1" ] ]]
            ;window     [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            screen      [ (obj-set-word) (to-word orig-obj-name) (obj-name)]
            group-box   [ (obj-set-word) (to-word orig-obj-name) (obj-name)  [ group-box-button1: button "group-box-button1"] ]
            h1          [ (obj-set-word) (to-word orig-obj-name) (obj-name)]   
            h2          [ (obj-set-word) (to-word orig-obj-name) (obj-name)]   
            h3          [ (obj-set-word) (to-word orig-obj-name) (obj-name)]   
            h4          [ (obj-set-word) (to-word orig-obj-name) (obj-name)]   
            h5          [ (obj-set-word) (to-word orig-obj-name) (obj-name)] 
            rich-text   [ (obj-set-word) (to-word orig-obj-name) "Hello Red World" data [1x17 0.0.255 italic 7x3 255.0.0 bold 24 underline] ] 
        ]                                                                  
        obj-name: find-unused-object-name orig-obj-name
        obj-set-word: to-set-word obj-name
        new-line-amt: either all [ (vid-code/text <> "") ((last vid-code/text) <> #"^/" ) ] [ 
            new-line-amt: newline
        ][
            ""
        ]
        indent-amt: get-last-line-indent vid-code/text
        append vid-code/text rejoin [ new-line-amt indent-amt ]
        the-template: copy select obj-template (to-lit-word orig-obj-name)
        if with-on-click [
            append/only the-template [ (on-click-code) ]
        ]
        if with-text [
            obj-name: copy/part text-string 40
            ;-- prepares for the compose below
        ]
        append vid-code/text mold/only compose/deep the-template
        run-and-save "insert-vid-object"
        if evo-after-insert? [   
            edit-vid-object/refresh (to-string obj-set-word) "vid-code" { run-and-save-changes }
        ]
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
    
    extract-setup-code: function [ filename ] [
        the-code: read filename
    	either (find the-code vid-code-marker ) [
    	    clue: rejoin [ vid-code-marker "^/view"]    
    	][
    	    clue: "^/view"
    	]        
        a: first split the-code clue
        un-block-string any [ (second split a "do setup:") ""  ]
    ]
    
    extract-vid-code: function [ filename ] [
    	i: read filename 
    	either (find i vid-code-marker ) [
    	    clue: rejoin [ vid-code-marker "^/view"]    
    	][
    	    clue: "^/view"
    	]
    	b: second split i clue
    	c: find b "["   ; skip by any set-word if it exists
    	un-block-string c
    ]
        
    set 'dc-load-direct-code load-direct-code: function [filename [ file! ] ] 
    [
        filename: clean-path filename
        ;print [ "load-direct-code filename =(" mold filename ")"]
        ;print [ "load-direct-code dc-reactor/current-file = " dc-reactor/current-file ]
        if (not exists? filename)[
            req-res: request-message/size rejoin [ "Trying to open filename:^/" to-string filename "^/This file does not exist"] 600x300
            return false
        ]
        
        file-header: read/part filename 200
        either all [ (exists? filename) (find file-header  {Comment: "Generated with Direct Code"} ) ] [
            ;print [ "load-direct-code $2 filename =(" mold filename ")"]
            if (value? 'dc-initialized) [
                recent-menu/add-item dc-reactor/current-file    
            ]
            if ((to-string filename) <> dc-reactor/current-file ) [
                monitor-file-change false
            ]
            if filename <> dc-reactor/current-file [
                close-object-editor/all-open "" 
            ]
            setup-code/text: extract-setup-code filename
            vid-code/text: extract-vid-code filename
            dc-reactor/current-file: filename
            change-dir first split-path filename
            return true
        ][
            request-message/size rejoin [{Unable to load } filename {.^/Either the file doesn't exist or it isn't a 'Direct Code' program.}] 750x200
            return false
        ]
    ]
        
    save-direct-code: function [ filename [ file!] ]
    [
        tf: copy ""
        just-filename: to-string second split-path filename
        stb-code: string-to-block/no-indent setup-code/text 
        write filename append tf reduce [
            {Red [^/^-Title: "} just-filename {"}
            {^/^-Needs: View}
            {^/^-Comment: "Generated with Direct Code"} ; "
            {^/]^/}
            {^/}
            {do setup:} 
            string-to-block/no-indent any [ setup-code/text "" ]
            {^/}
            vid-code-marker
            {^/}
            "view " rejoin [ first split (to-string just-filename) "." "-layout: "]
            string-to-block/no-indent any [ vid-code/text "" ]
        ]
                
        save-settings
        change-dir first split-path filename
        set 'dc-filename filename
    ]

    set 'recent-menu closure [ ;-- recent-menu:
        recent-file-list: [] [block!]
        max-entries: 11
    ] 
    [
        /add-item filename [file!]
        /get-item item-num [number!]
        /get-all
        /set-all value [ block! ]
        /local push-into-menu ndx file-fnd
    ][
        push-into-menu: func [ value ][
            insert recent-file-list value
            recent-menu-location: ((index? find mainwin/menu/2 "Recent") + 1)
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
            save rejoin [  root-path %direct-code-settings.data ]
                new-line/skip/all reduce [ 
                    'filename               dc-reactor/current-file     
                    'setup-size             setup-code/size
                    'vid-size               vid-code/size
                    'output-panel-size      output-panel/size 
                    'live-update?           live-update?
                    'evo-after-insert?      evo-after-insert? 
                    'red-executable         red-executable
                    'external-editor        dc-external-editor
                    'logging                global-logging  
                    'recent-files           recent-files
                    'last-red-cmd           red-command/text
                    'reload-on-change?      reload-on-change?
                    'dc-voe-selected-tab    dc-voe-selected-tab
                    'dc-voe-size            dc-voe-size
                ] true 2        
        ]    
    ]   

    set 'run-and-save function [ ;-- run-and-save:
        id
        /no-save 
        /local vid-good? setup-good?
        /extern active-evo-windows internal-source-change-flag? dc-last-vid-code-error dc-last-vid-code-error
    ][  
        ;-- save only happens if the run is successful
        set 'project-path copy system/options/path
        set 'current-file copy dc-reactor/current-file
        setup-good?: vid-good?: true

        either error? err: try/all [ 
            if setup-code/text [
                do load setup-code/text
            ]
            true ;-- makes try happy
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
            either error? err: try/all [
                if vid-code/text [
                    the-vid-code: load vid-code/text
                    output-panel/pane: layout/only new-lay: the-vid-code
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
                    check-for-file-change/rate: 999:99:99       ;-- turn off monitor-file-change 
                    save-direct-code dc-reactor/current-file
                    file-modified? dc-reactor/current-file ;-- reset timestamp 
                    check-for-file-change/rate: curr-rate
                ]
                active-filename/color: white
                output-panel/pane: layout/only new-lay
            ]
        ]
        

        if any [ ( id = "internal-source-change") (id = "no-save" )][ ;-- The source has been modified, need to check if any evo-windows need to be updated.
            foreach win active-evo-windows [
                unique-num: get to-path reduce [ (to-word win) 'extra 'target-object-name ]
                after-view-widget: get to-path reduce [ ( to-word rejoin [ "evo-after-view" unique-num ] ) ]
                set (to-word rejoin [ "requester-completed?" unique-num ]) false
                after-view-widget/extra/rerun :after-view-widget
            ]        
        ]
        
    ]
    
    left-control-down: false
    left-alt-down: false
    
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
        /off 
        /on 
        /extern evo-after-insert?
    ][
        if on [
            evo-after-insert?: true
        ]
        if off [
            evo-after-insert?: false
        ]
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
        /extern dc-external-editor-commands 
    ][
        external-editor-template: load rejoin [ root-path %external-editor-settings.data ]
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
            ]
        ] 
    ]
        
    either (exists? direct-code-settings) [ ;-- load-settings:
        loaded-settings: load direct-code-settings
        dc-reactor/current-file: either all-to-logic loaded-settings/filename [ loaded-settings/filename ][ dc-reactor/current-file ]
        setup-size: either all-to-logic loaded-settings/setup-size [ loaded-settings/setup-size ][ setup-size ]
        last-red-cmd: either all-to-logic loaded-settings/last-red-cmd [ loaded-settings/last-red-cmd ][ last-red-cmd ]
        vid-size: either all-to-logic loaded-settings/vid-size [ loaded-settings/vid-size ][ vid-size ]
        dc-voe-selected-tab: either all-to-logic loaded-settings/dc-voe-selected-tab [ loaded-settings/dc-voe-selected-tab ][ 1 ]
        dc-voe-size: either all-to-logic loaded-settings/dc-voe-size [ loaded-settings/dc-voe-size ][ 1 ]
        output-panel-size: either all-to-logic loaded-settings/output-panel-size [
            loaded-settings/output-panel-size
        ][
                output-panel-size 
        ]
        live-update?: (all-to-logic loaded-settings/live-update?)
        evo-after-insert?: (all-to-logic loaded-settings/evo-after-insert?)
        reload-on-change?: (all-to-logic loaded-settings/reload-on-change?)
        global-logging:    (all-to-logic loaded-settings/logging)
        either global-logging [ change-logging/on ][ change-logging/off ]
        if not all-to-logic red-executable: loaded-settings/red-executable [
            set-red-executable/none-set
        ]
        if not all-to-logic dc-external-editor: loaded-settings/external-editor [
            set-external-editor/none-set
        ]
        setup-external-editor
        
    ][
        z: request-message rejoin [ 
            "To make full use of 'Direct Code' It is advisable" newline
            "to configure these two items under the Settings Menu:" newline
            "1.) Red Executable" newline
            "2.) External Editor" 
        ]
        loaded-settings: [ ;-- settings are missing so setting bare minimum
            recent-files []
        ]
    ]
    
    edit-source-object: function [
        /left-edge
        {Edit vid code source if it is selected}
    ][
        obj-fnd: none
        either pos: vid-code/selected [
            src-cdta: get-src-cdta vid-code/text
            foreach item src-cdta [
                if ((to-integer pos/x) <= (to-integer item/token/x)) [
                    obj-fnd: item/object
                    break
                ]
            ]
            if obj-fnd [
                either(left-edge) [
                    edit-vid-object/refresh/left-edge obj-fnd "vid-code" { run-and-save-changes }                    
                ][
                    edit-vid-object/refresh obj-fnd "vid-code" { run-and-save-changes }    
                ]
            ]
        ][
        ]
    ]

    set 'select-object func [ ;-- select-object:
        f 
        /left-edge
        /local g obj-name 
    ][  
    	obj-name: find-object-name f
        either ( obj-name = "*unusable-no-name*")[
            --obj-selected: none
        ][
            --obj-selected: f 
            --dc-mainwin-edge: mainwin/offset + mainwin/size 
            either left-edge [
                edit-vid-object/refresh/left-edge obj-name "vid-code" { run-and-save-changes }
            ][
                edit-vid-object/refresh obj-name "vid-code" { run-and-save-changes }    
            ]
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
        
    direct-code-event-handler: func [
        face [object!] 
        event [event!]
    ][
        if all [ ( event/key = 'F12) (event/type = 'key-up) ] [
            restart-direct-code
        ]
        if all [ (event/type = 'over) (event/flags/1 <> 'away) ] [
            --over-face: face
        ]
        if any [ (event/type = 'up) ] [
            if  (--over-face <> face)[
                --over-face: false    
            ]
        ]
        if any [ 
            all [(event/key = to-char 192) (event/type = 'key-down) left-control-down ] ;-- Control + Tilde
        ][
            if (--over-face/parent = output-panel) [ 
                select-object --over-face
            ]
            if face = vid-code [
                edit-source-object 
            ]
        ]
        if any [ 
            (event/type = 'mid-down) 
            all [(event/key = #"1") (event/type = 'key-down) left-control-down ] ;-- Control + "1"
        ][
            if (--over-face/parent = output-panel) [ 
                either left-control-down [
                    select-object/left-edge --over-face    
                ][
                    select-object --over-face
                ]
            ]
            if face = vid-code [
                either left-control-down [
                    edit-source-object/left-edge 
                ][
                    edit-source-object
                ]
            ]
        ]
        if all [ (event/key = 'left-control) (event/type = 'key-down )][
            left-control-down: true
        ]
        if all [ (event/key = 'left-control) (event/type = 'key-up )][
            left-control-down: false
        ]
        if all [ (event/key = 'left-alt) (event/type = 'key-down )][
            left-alt-down: true
        ]
        if event/key = #"^S"[
            run-and-save "control-S"
        ]
        
        if all [ (event/key = 'left-alt) (event/type = 'key-up )][
            left-alt-down: false
        ]
        
        if all [ left-alt-down (event/key = 'left ) (event/type = 'key-up ) ][
            load-and-run recent-menu/get-item 1
        ]
        if all [ 
            (event/type = 'key-up)
            any [ (event/key = 'right-control) ] 
        ][
            run-and-save "control-key-change"
        ]
        if event/key = 'F11 [
            system/view/debug?: xor~ system/view/debug? true
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
            switch/default event/window/text [
                "Direct Code" [ 
                    run-and-save "window-close"
                    remove-event-func :direct-code-event-handler    
                ]
            ][
                
            ]
        ]
        if event/type = 'move [
            --dc-mainwin-offset: face/offset
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

    on-spliter-init: func [face [object!] /local data v sz? op axis] [
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
        face/offset/:fa: face/extra/offset/:fa              ; must not move on the fixed axis
        amount: face/offset - face/extra/offset             ; amount of the move since the last move
        face/extra/offset: face/offset                      ; store the new offset
        if any [amount = 0x0 not block? face/data] [exit]
        foreach [prop op] face/data [
            do reduce [load rejoin [form prop ":"] prop op amount]          ; update the value with the new amount. I miss 'to-set-word here
        ]
    ]
    orig: 4x4
    red-object-browser: does [ do rejoin [ root-path  %tools/red-object-browser.red ] ] 

    mainwin: layout [
        title "Direct Code"
        backdrop gray
        origin orig
        space 0x0
        style area: area font-name "Fixedsys"
        style split: base 30x6 loose extra ['offset none 'auto-sync? none 'axis none 'fixedaxis none]
            on-drag-start [face/extra/offset: face/offset face/extra/auto-sync?: system/view/auto-sync? system/view/auto-sync?: no] ; Need to disable realtime mode as the position is changed by the drag an the code
            on-drag [on-spliter-move face show face/parent]
            on-drop [system/view/auto-sync?: face/extra/auto-sync?] ; Don't forget to reset realtime mode to its previous value
            on-over [face/color: either event/away? [gray][blue]]
            on-create [on-spliter-init face]

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
                    run-and-save "after-view"
                ]
            ] 
        ]
                
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
            back-btn: button "<" 15x24 [
                load-and-run recent-menu/get-item 1
            ] extra [
                first-over?: true
            ] on-over [
        	    either event/away? [
        	        back-btn/extra/first-over?: 'true
        	        popup-help/close ""
        	    ][
        	        if back-btn/extra/first-over? = 'true [
          	            back-btn/extra/first-over?: 'false
          	            popup-help/offset {load-and-run previous file} (face/parent/parent/offset + face/offset + event/offset + 20x0  )        
          	        ]
        	    ]
            ] 

            check-for-file-change: base 40x24 blue font-size 12 bold center white "File: " rate 999:00:00 ; hold here until we turn it on
                [
                    monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ] 
                    open-with-external-editor/monitor dc-reactor/current-file
                ]
                on-time [
                    if file-modified? dc-reactor/current-file [
                        load-and-run/no-save dc-reactor/current-file    
                    ]         
                ]
                on-create [
                    monitor-file-change (all-to-logic reload-on-change?)
                ]
            active-filename: text font-size 12 229x24 center white on-up [ 
                    run-and-save "file-name-clicked" 
                ]
                extra [ 'first-over? true ]
                react [ active-filename/text:  to-string second split-path dc-reactor/current-file ]
                on-over [
            	    either event/away? [
            	        active-filename/extra/first-over?: 'true
            	        popup-help/close ""
            	    ][
            	        if active-filename/extra/first-over? = 'true [
            	            active-filename/extra/first-over?: 'false 
            	            popup-help/offset (to-string dc-reactor/current-file) (face/parent/parent/offset + face/offset + event/offset + 20x0  )        
            	        ]
            	    ]
                ]
            space 6x4
            button 45x24 right center  " RED>> " [ 
                either error? err: try/all  [ 
                    do red-command/text
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
            space 0x4
            red-command: field 275x24 on-enter [ 
                    either error? err: try/all  [ 
                        do red-command/text
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
                on-wheel [
                    sel-pair: to-pair reduce [  1 (length? face/text ) ]
                    red-command/selected: sel-pair
                ]
                on-create [ 
                    red-command/text: last-red-cmd  
                ]
                
            mk-btn: button 36x24 font-size 8 "Mk Btn" [ 
                insert-vid-object/with-on-click/with-text "button" (to-block red-command/text ) red-command/text
                run-and-save 1904
            ]
            return
            below
            text "Setup Code (before layout) :" 200x15  
            setup-code: area setup-size on-key-up [ check-source-change event/key ] 
            pad 0x4
            ; horizontal splitter
            splith: split 800x6 data [setup-code/size vid-label/offset ver-text/offset vid-code/offset vid-code/size]

            across 
            vid-label: text "Layout code in VID dialect :" 150x15
            base 300x10 transparent
            ver-text: text right "" 270x15 on-create [
                ver-text/text: rejoin [ "Red build date: " system/build/git/date ]
            ]
            return 
            vid-code: area vid-size 
                on-key-up [ check-source-change event/key ]
        ]
                
        do [
            
            window-test: does [
                mainwin/offset: 0x55 
                --dc-mainwin-offset: mainwin/offset
            ]                    
            
            check-source-change: function [ keycode ][
                if all [ (keycode <> 'right-control ) (keycode <> 'F5 ) ][
                    either live-update? [ 
                        run-and-save "internal-source-change"
                    ][
                        active-filename/color: yellow                        
                    ] 
                ]    
            ]
            save-dc: func [ /next-version /backup-version ]  [
                if backup-version [
                    backup-filename: get-unique-version-name dc-reactor/current-file
                    print ["Backup file saved. Named:" backup-filename ]
                    file-data: read dc-reactor/current-file
                    write backup-filename file-data
                    return none
                ]
                either next-version [
                    rf: get-next-version-name dc-reactor/current-file
                ][
                    if ((rf: request-file/title/file "Save as" current-path ) = none!) [
                        return false
                    ]
                ]
                
                if (exists? rf )[
                    req-res: request-message/size rejoin [ "The file named:^/" to-string rf "^/already exists. Do you want to copy over it?"] 600x300
                    if (not req-res) [ return false ]
                ]    
                
                close-object-editor/all-open "919"
                either dc-reactor/current-file <> rf [
                    recent-menu/add-item dc-reactor/current-file
                    file-data: read dc-reactor/current-file
                    replace file-data rejoin [ {Title: "} second split-path dc-reactor/current-file {"}] rejoin [ {Title: "} second split-path rf {"}]
                    write rf file-data
                ][
                    copy-file dc-reactor/current-file rf    
                ]
                dc-reactor/current-file: copy rf
                monitor-file-change false
                run-and-save "save-dc"
            ]
            
            open-dc: does  [
                if (rf: request-file/title/file "Open" current-path  ) [
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
        	    if (rf: request-file/title/file/filter "Save Image of GUI as a '.png' file" current-path ["*.png"] )[
                    save rf img
                ]    
            ]
            
            new-dc: does [
                if (rf: request-file/title/file "Specify a NEW file name" current-path ) [
                    recent-menu/add-item dc-reactor/current-file
                    setup-code/text: copy ""
                    vid-code/text: copy ""
                    dc-reactor/current-file: rf
                    run-and-save "new-dc"
                ]
            ]
            set 'open-with-external-editor func [ ;-- open-with-external-editor:
                filename [file!] 
                /monitor 
                /line line-num 
                /col col-num
            ][ 
                editor-executable: to-local-file dc-external-editor 
                filename: to-local-file filename 
                
                call-cmd: rejoin reduce (bind dc-external-editor-commands/plain-open 'filename)
                if all [ line (all-to-logic dc-external-editor-commands/open-to-line) ] [
                    call-cmd: rejoin reduce (bind dc-external-editor-commands/open-to-line 'filename)
                ]
                if all [ col (all-to-logic dc-external-editor-commands/open-to-column )] [
                    call-cmd: rejoin reduce (bind dc-external-editor-commands/open-to-column 'filename)
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
            
            set 'close-object-editor function [  ;-- close-object-editor:
                obj-name
                /all-open
                /extern active-evo-windows 
            ][
                either all-open [
                    window-list: copy active-evo-windows
                ][
                    ;-- make sure the window matches the object 
                    window-list: none
                    foreach win active-evo-windows [
                        curr-obj: get to-path reduce [ (to-word win) 'extra 'current-object-name ]
                        if curr-obj = obj-name [
                            window-list: to-block mold win    
                        ]
                    ]                
                    if ( not window-list) [
                        window-list: to-block mold rejoin [ "--evo-window-" obj-name ]
                    ]
                ]
                if window-list <> [] [
                    foreach win window-list [
                        uid: get to-path reduce [(to-word win) 'extra 'target-object-name ]
                        uid: copy (skip uid 1)
                        unview/only  get to-word win
                        evo-window-cleanup win uid
                    ]                        
                ]
            ]                                                       

            evo-menu: context [
                find-edge-of-obj: function [ 
                    obj-name
                    rel-dir {+1 or -1, +1 returns end of obj, -1 returns start of obj} 
                ][ 
                    src-cdta: get-src-cdta vid-code/text
                    obj-info: find-in-array-at/every src-cdta 4 obj-name 
                    o-info: either (rel-dir < 0)[
                        first obj-info
                    ][
                        last obj-info
                    ]
                    return o-info/token
                ]

                valid-object?: function [ 
                    src-cdta 
                    obj-record 
                ][
                    
                    if obj-record/object = "" [ return false ]
                    obj-info: find-in-array-at/every src-cdta 4 obj-record/object 
                    
                    either ( obj-info/1/input = "style" ) [ 
                        return false
                    ][
                        return true
                    ]
                ]
                
                highlight-gui: function [ obj-name ][
                    obj-offset: get to-path (reduce [ to-word obj-name 'offset ])
                    obj-size: get to-path (reduce [ to-word obj-name 'size ])
                    
                    
            	    obj-image: either error? (try [ try-img: to-image get to-word obj-name ])[ [] ] [ try-img ]
                    diff-offset: 829x55 ;-- 830x55 should be the default
                    win-offset: obj-offset + diff-offset + --dc-mainwin-offset
                    hilight-window: layout/tight compose/deep [ 
                        base1: base (obj-image) (obj-size)
                            on-down [ 
                                unview/only hilight-window 
                            ]
                            rate 00:00:00.015
                            on-time [
                                face/extra/flash-count: face/extra/flash-count + 1
                                either face/extra/flash-count < 16 [
                                    f-count: face/extra/flash-count
                                    either f-count = none [ 
                                        ;-- won't work without this??
                                    ][
                                        pen-color: pick [ red black yellow ]  f-count % 3 + 1
                                    ]
                                    base1/draw:  reduce [
                                        'pen :pen-color
                                        'line-width :f-count
                                        'box 0x0 (obj-size) 
                                    ]
                                ][
                                    unview/only hilight-window
                                ]
                            ]
                            extra [ flash-count: 0]
                    ]
                        
                    view/flags/tight/options hilight-window
                        [ ;-- flags
                            no-border
                        ][ ;-- options
                            offset: win-offset
                        ]            
                ]
                highlight-gui-object: func [ obj-name src-position last-char ] [
                    highlight-gui obj-name
                ]
                
            	highlight-source-object: func [ obj-name src-position last-char ] [
            	    vid-code/selected: src-position
                    if check-for-file-change/rate <> 999:00:00 [
                        line-num: offset-to-line-num/vid vid-code/text src-position/x
                        open-with-external-editor/line dc-filename line-num
                    ]            	    
            	]
            	copy-object-to-clip: func [ obj-name src-position last-char ][
            	    write-clipboard  ( copy/part (skip vid-code/text src-position/x - 1 ) (src-position/y - src-position/x + 1))    
            	]
            	
            	delete-object: func [ obj-name src-position last-char ][
                    vid-code/selected: none
                    y-correction: either (last-char = #"^/")[2][1]
                    remove/part (skip vid-code/text (src-position/x - 1) ) (src-position/y - src-position/x + y-correction )
                    ;-- Need to check if object has been renamed.
                    close-object-editor obj-name
                    run-and-save "delete-object"
            	]
            	
            	insert-return-before: function [ obj-name src-position last-char ][
            	    insert (skip vid-code/text (src-position/x - 1)) {return^/}
            	    run-and-save "insert-return-before"
            	]
            	
                remove-return-before: func [ obj-name src-position last-char ][
                    whitespace: charset " ^-^/]" 
            	    backwards-offset: 20
            	    skip-amt: max (src-position/x - backwards-offset ) 0
            	    backwards-some: copy/part (skip vid-code/text skip-amt ) 40
            	    if (fnd: find/last backwards-some "return") [
            	        fnd-index: index? fnd  
            	        show-selected-text backwards-some to-pair reduce [ fnd-index (fnd-index + 30) ]   
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
            	
            	duplicate-object: func [ obj-name src-position last-char ][
                    src-info: second get-obj-info vid-code/text obj-name []
                    current-code: copy/part (skip vid-code/text src-position/x - 1) ( src-position/y - src-position/x + 1 )
                    loaded-code: load current-code
                    current-set-words: get-set-words to-block vid-code/text
                    new-obj-num: 1
                    new-obj-name: rejoin [ obj-name "-" new-obj-num ":" ]
                    while [all-to-logic find current-set-words (to-set-word new-obj-name)][
                        new-obj-num: new-obj-num + 1
                        new-obj-name: rejoin [ obj-name "-" new-obj-num ":" ]
                    ]
                    replace current-code (rejoin [obj-name ":"]) new-obj-name
                    if loaded-code/at [
                        replace current-code (rejoin ["at " to-string loaded-code/at " "]) ""
                    ]
                    append vid-code/text rejoin [ "^/" current-code ]
                    run-and-save "duplicate-object"
                    if evo-after-insert? [   
                        edit-vid-object/refresh (trim/with/tail new-obj-name ":") "vid-code" { run-and-save-changes }
                    ]
            	]

                set 'find-first-vid-object function [ 
                    src-cdta 
                    /last ;-- paradox, I know
                ][
                    cur-obj: ""
                    loop-candata: either last [
                        reverse copy src-cdta
                    ][
                        src-cdta
                    ]
                    foreach rec loop-candata [
                        either all [ (rec/object <> cur-obj) (valid-object? src-cdta rec )] [ 
                            return rec/object
                        ][
                            cur-obj: copy rec/object
                        ]
                    ]
                    return none
                ]            	

                
                find-relative-vid-obj-position: function [  
                    src-cdta obj-candata rel-pos
                ][
                    check-ndx: obj-candata/1/index
                    rel-dir: positive? rel-pos [ +1 ] [ -1 ] 
                    
                    curr-obj: obj-candata/1/object
                    obj-count: 0
                    rel-dir: either (positive? rel-pos) [ 1 ] [ -1 ]
                    last-obj: copy curr-obj
                    while [    
                        check-ndx: check-ndx + rel-dir
                        picked: pick src-cdta check-ndx
                    ][
                        if all [ (picked/object <> last-obj) (valid-object? src-cdta picked) ] [ 
                            obj-count: obj-count + 1 
                            last-obj: copy picked/object
                        ]
                        if obj-count = (absolute rel-pos) [ 
                            return picked/object
                        ] 
                    ]
                    return false
                ]
                
                move-object-relative: function [ 
                    obj-name 
                    src-position 
                    last-char 
                    rel-num
                    /beginning
                    /end
                ][
                    src-cdta: get-src-cdta vid-code/text 
                    obj-info: find-in-array-at/every src-cdta 4 obj-name ;-- 4 = object name
                    
                    either beginning [
                        target-obj: find-first-vid-object src-cdta
                    ][
                        target-obj: find-relative-vid-obj-position src-cdta obj-info rel-num
                    ]
                    if end [
                        target-obj: find-first-vid-object/last src-cdta
                    ]
                    either target-obj [
                        current-code: copy/part (skip vid-code/text src-position/x - 1) ( src-position/y - src-position/x + 1)
                        either last-char = #"]" [
                            next-char: vid-code/text
                            next-char: pick next-char (src-position/y + 1)
                            y-correction: either next-char = #"^/" [
                                2
                            ][
                                1
                            ]
                        ][
                            y-correction: either (last-char = #"^/")[2][1] ;-- include LF with object / remove it as well    
                        ]
                        
                        
                        rem-part: copy/part (skip vid-code/text (src-position/x - 1) ) (src-position/y - src-position/x + y-correction )
                        remove/part (skip vid-code/text (src-position/x - 1) ) (src-position/y - src-position/x + y-correction )
                        
                        rel-dir: either (positive? rel-num) [ +1 ] [ -1 ] 

                        fnd-pos: find-edge-of-obj target-obj rel-dir 
                        insert-pos: either (positive? rel-dir)[
                            pre-code: "^/"
                            post-code: ""
                            fnd-pos/y 
                        ][
                            pre-code: ""
                            post-code: "^/"
                            fnd-pos/x
                        ]
                        last-target-char: vid-code/text
                        either any [(negative? rel-dir) (insert-pos = 1) ((pick last-target-char insert-pos) =  #"^/")] [
                            insert-pos: insert-pos - 1
                        ][
                        ]
                        
                        insert (skip vid-code/text insert-pos ) rejoin [ pre-code current-code post-code ]    
                        run-and-save "move-object-relative" 
                        
                    ][
                        request-message rejoin ["Unable to move Object.^/Name: " obj-name "^/Positions: " rel-num ]
                    ]
                ]
                
                move-specific: func [ obj-name src-position last-char ][
                    amt: request-specific-move  
                    move-object-relative obj-name src-position last-char amt
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
                    cur-oset:  get to-path reduce [ to-word rejoin [ "--evo-window-" obj-name ] 'offset ]
                    set to-path reduce [ to-word rejoin [ "--evo-window-" obj-name ] 'offset ] to-pair reduce [ 6 cur-oset/y]
                ]
                
                open-to-this-tab: func [ obj-name src-position last-char ][
                    confirm-type:  to-path reduce [ to-word rejoin [ "--evo-window-" obj-name ] 'pane 2	'type ]
                    pane-type: get confirm-type
                    either pane-type = 'tab-panel [
                          selected-tab: get to-path reduce [ to-word rejoin [ "--evo-window-" obj-name ] 'pane 2	'selected ]
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
                    size-name [ string! ]
                    /extern dc-voe-size
                ][
                    either dc-voe-size = size-name [
                        request-message rejoin [ "The VID Object Editor is already set to a '" size-name "' font." ]                        
                    ][
                        close-object-editor obj-name
                        set-voe-size size-name
                        select-object get to-word obj-name
                    ]
                ]

                test-menu: func [ obj-name src-position last-char ][
                    move-object-relative/end obj-name src-position last-char 1
                ]
                
                set 'evo-menu-handler function [ obj-name action ] [ ;-- evo-menu-handler:
                	v-src: second ( get-obj-info vid-code/text obj-name [])
                	last-item: length? v-src
                	last-char: pick vid-code/text v-src/:last-item/token/y
                	y-correction: either (is-whitechar? any [ last-char #" " ] ) [ -1 ] [ 0 ] ;-- deal with last-char being 'none
                	obj-position: to-pair reduce [ v-src/1/token/x ( v-src/:last-item/token/y + y-correction )]
                    either error? err: try/all  [ 
                        do bind (reduce [ to-word action obj-name obj-position last-char]) 'delete-object
                        true ;-- try return value
                    ][
                        print "*** MENU ACTION ERROR (evo-menu-handler) ****************************************"
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
        splitv: split 6x100 data [pan/size splith/size setup-code/size vid-code/size output-panel/size output-panel/offset]
        output-panel: panel output-panel-size
    ]
    mainwin/menu: [
        "File" [ 
            "New"                           new
            "Open"                          open   
            "Open with External Editor"     open-external
            "Save  (and Run) - Ctrl + S"    run-interpreter          
            "Save As"                       save-as
            "Save As Next Version"          save-as-next-version
            "Save Backup Version"           save-backup-version
            "Save Image of GUI created"     save-gui-image
            "Open Current Folder"           show-cd 
            "Recent" []
            "Reload" [
                "Reload Now" reload
                "Reload when File changed ON"   reload-when-changed-on    
                "Reload when File changed OFF"  reload-when-changed-off   
            ] 
            
            "Run Separately - F9"       run-separate
            "Do File (Attached) - F6"   do-the-current-file
            "Restart Direct Code - F12" restart-program
        ]
        "Insert" [
            "VID Object Inserter GUI" do-vid-object-inserter
            "Area" ins-area "Base" ins-base 
            "Button" ins-button 
            "Calendar" ins-calendar 
            "Camera" ins-camera 
            "Check" ins-check 
            "Drop Down" ins-drop-down 
            "Drop List" ins-drop-list 
            "Field" ins-field 
            "Group Box" ins-group-box 
            "Headings" [
                "H1" ins-h1 
                "H2" ins-h2 
                "H3" ins-h3 
                "H4" ins-h4 
                "H5" ins-h5
            ] 
            "Image" ins-image 
            "Panel" ins-panel 
            "Progress" ins-progress 
            "Radio" ins-radio 
            "Rich Text" ins-rich-text
            "Slider" ins-slider 
            "Tab Panel" ins-tab-panel 
            "Text" ins-text 
            "Text List" ins-text-list 
            "Toggle" ins-toggle            
            "Includes" [
                    "direct-code-stand-alone" ins-dc-stand-alone 
            ]
        ]
        "Object" [
            "Show Named Objects"    show-named-objects
            "Object Browser"        object-browser
        ]
        "Debug" [
            "Logging" [
                "View Log File"     show-log    
                "Logging OFF - F8"  change-logging-off 
                "Logging ON   - F8" change-logging-on
            ]
            
            "System" [
                "Dump Reactions"                show-all-reactions
                "System/view/debug ON - F11"    system-view-debug-on
                "System/view/debug OFF- F11"    system-view-debug-off
            ]
        ]
        "Settings" [
            "Red Executable"    set-red-exe
            "External Editor"   set-ext-editor
            "Auto Open VID Editor - ON"   evo-after-insert-on
            "Auto Open VID Editor - OFF"  evo-after-insert-off
        ]
        "User" [
            "Run User Script" run-user-stuff
            "Edit User Script" edit-user-stuff
        ]
        "Help" [
            "Direct Code Help"          direct-code-help
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
                    open-with-external-editor/monitor dc-reactor/current-file
                ]
                new   [ new-dc ]
                reload [ load-and-run dc-reactor/current-file ]
                reload-when-changed-on [ monitor-file-change true ]
                reload-when-changed-off [ monitor-file-change false  ]
                restart-program [ restart-direct-code ]
                
                ins-dc-stand-alone [ insert-direct-code-stand-alone ]
                object-browser [ red-object-browser ]

                system-view-debug-on  [ system/view/debug?: true ]
                system-view-debug-off [ system/view/debug?: false ]
                evo-after-insert-on   [ evo-after-insert/on  ]
                evo-after-insert-off  [ evo-after-insert/off ]
                show-all-reactions [ dump-reactions ]
                show-log [
                    either exists? to-file dc-external-editor  [
                        call rejoin [ to-local-file dc-external-editor " " to-local-file repend what-dir %direct-code.log ]    
                    ][
                        set-external-editor/none-set
                    ]
                ]
                
                show-named-objects [
                    named-objs: get-list-of-named-objects
                    print [ newline "------ START OF NAMED OBJECTS ------" ]
                    ndx: 1
                    foreach obj-name named-objs [
                        print rejoin [ pad/left rejoin [ ndx ") "] 4 obj-name ]
                        ndx: ndx + 1
                    ]
                    print [ "------ END OF NAMED OBJECTS ------" ]
                ]
                run-separate [ 
                    run-program-separately
                ]
                do-the-current-file [
                    do-current-file
                ]
                do-vid-object-inserter [
                    do rejoin [ root-path %tools/vid-object-inserter.red ]
                ]
                run-interpreter [
                    run-and-save "run-interpreter"   
                ]
                set-red-exe [ set-red-executable ]
                set-ext-editor [ set-external-editor ]
                run-user-stuff [ run-user-script ]
                edit-user-stuff [ edit-user-script]
                goto-edit-vid-object [ edit-evo ]
                direct-code-help [
                    do rejoin [ root-path %help/direct-code-help.red ]
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
                        rejoin [ "Red Build " system/version " - " system/build/git/date "^/^/Window Offset: " mainwin/offset ]
                ]
                change-logging-on [
                    change-logging/on    
                ]
                change-logging-off [
                    change-logging/off
                ]
            ][ ; will catch all of the ins-????? menu items HERE
                insert-vid-object event/picked 
            ] 
        ] 
    ]
    view/flags/options mainwin [  
        resize        ;-- flags
    ][  
        offset: 0x0   ;-- options
    ]
]
