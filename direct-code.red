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
                              reflect the impetus to create a larger scope for the project(Mike)}
        2.0.0 "03-01-2021"   {Full rewrite of code generation engine. }                              
    ]
    Tabs: 4
]

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

lprint: function [ s ] [
    if global-logging [
        write/append/lines %direct-code.log form reduce s    
    ]
]

bprint: function [s] [
    lprint s
    print form reduce s
]

dc-ctx: context [    
    root-path: copy what-dir  
    --obj-selected: none
    --dc-main-win-edge: 0x0
    obj-edit-ctx: context [
        link-text: function [ obj1 obj2 ] [
        	obj1/text: obj2/text
        ]
        link-offset: function [ obj1 obj2 ] [
            obj1/offset: to-pair obj2/text
        ]
        set 'requester-locations-used copy [] 

        set 'requester-slot function [ 
            /add-slot the-obj-name win-name variables-list reactions-list
            /remove-slot slot-num
            /unlink-slot unlink-num
            /relink-slot relink-num
        ][ 
            
            if remove-slot [
                if fnd: find requester-locations-used slot-num [
                    requester-slot/unlink-slot slot-num
                    cur-obj: copy fnd/2
                    var-list: copy fnd/4
                    foreach var-name var-list [
                        unset to-word var-name
                    ]
                    remove/part fnd 5
                    dc-matrix/deactivate/this-object cur-obj 'edit-object
                ]
            ]
            if add-slot [
                if fnd: find requester-locations-used the-obj-name [
                    set-focus get to-word rejoin [ "first-face-" the-obj-name ]
                    return -1
                ]
                i: 0
                while [ find/skip requester-locations-used i 5 ] [
                    i: i + 1                        
                ]
                append      requester-locations-used i                  ; item 1 slot number
                append      requester-locations-used the-obj-name       ; item 2 object name
                append      requester-locations-used win-name           ; item 3 requester window name
                append/only requester-locations-used variables-list     ; item 4 requester varialbles (for unsetting)
                append/only requester-locations-used reactions-list     ; item 5 reactions that will need to be redone on interpretation
                
                return i
            ]
            if unlink-slot [
                fnd-slot: skip (find/skip requester-locations-used unlink-num 5) 4
                foreach i fnd-slot/1 [
        		    trig-res: react-man/unlink i/1 i/2
        		    either :trig-res [
                    ][
                    ]
           		]
            ]        
            if relink-slot [
                fnd-slot: skip (find/skip requester-locations-used relink-num 5) 4
                foreach i fnd-slot/1 [
            		    react-man/link i/1 i/2
           		]
            ]
        ]
               
        create-color-requester: function [ linked-field-name [string!] ] [
;-- *************************** START STATIC STRING ***********************
    color-req: copy {
    button "..." 24x24 [
        res: request-color/size/title 400x400 "Select a color" 
        if res [
            link-field/text: to-string res
        ]
    ]
    }        
;-- ******************************** END STATIC STRING *****************************
            replace/all color-req "link-field" linked-field-name
            append variables-list rejoin [ linked-field-name "-color" ]
            return rejoin [ " space 0x4 " linked-field-name "-color: " color-req ]
        ]
        

; -----------------------------------------------------------------------------------CREATE-MULTILINE-REQUESTER-------------------------        
        create-multiline-requester: function [ linked-field-name [string!] existing-data [string!]] [
;-- *************************** START STATIC STRING ***********************
    multiline-req: copy {
    button "..." 24x24 [
        res: request-multiline-text/size/preload "Enter a text string" 700x400 <existing-data>
        if res [
            link-field/text: to-string res
        ]
    ]
    }  
;-- ******************************** END STATIC STRING *****************************
            replace/all multiline-req "link-field" linked-field-name
            replace multiline-req "<existing-data>" existing-data
            append variables-list rejoin [ linked-field-name "-multiline" ]
            return rejoin [ " space 0x4 " linked-field-name "-multiline: " multiline-req ]
        ]        
; -----------------------------------------------------------------------------------CREATE-MULTILINE-REQUESTER-------------------------        

        create-xy-widget: function [ linked-field-name [string!] ] [
    ;*************************** START STATIC STRING *************************************************************************************            
    xy-widget: copy {base green 24x24 draw [
    circle 12x12 4 line 0x12 10x12 line 0x12 4x8 line 0x12 4x16 line 12x0 12x10 line 12x0 8x4 line 12x0 16x4 line 14x12 23x12 line 23x12 19x16 line 23x12 19x9 line 12x23 12x14	    line 12x23 8x19	    line 12x23 16x19
    ] 
    on-down [
        face/rate: 00:00:00.3
        face/extra/start-down: event/offset	
        face/extra/orig-val: to-pair link-field/text 
    ]
    on-up [
            if (event/offset = face/extra/start-down) [ 
                case [
                    point-in-triangle? event/offset 0x0                              to-pair reduce [ (face/size/x / 2) (face/size/y / 2) ] to-pair reduce [face/size/x 0]  [link-field/text: to-string ( (to-pair link-field/text ) + to-pair reduce [ 0 (face/extra/grid/y * -1)] )]
                    point-in-triangle? event/offset to-pair reduce [ face/size/x 0 ] to-pair reduce [ (face/size/x / 2) (face/size/y / 2) ] face/size                       [link-field/text: to-string ( (to-pair link-field/text ) + to-pair reduce [ face/extra/grid/x 0 ] )]
                    point-in-triangle? event/offset to-pair reduce [ 0 face/size/x ] to-pair reduce [ (face/size/x / 2) (face/size/y / 2) ] face/size                       [link-field/text: to-string ( (to-pair link-field/text ) + to-pair reduce [ 0 face/extra/grid/y ] )]
                    point-in-triangle? event/offset 0x0                              to-pair reduce [ (face/size/x / 2) (face/size/y / 2) ] to-pair reduce [0 face/size/y ] [link-field/text: to-string ( (to-pair link-field/text ) + to-pair reduce [ (face/extra/grid/x * -1) 0] )]
                ]
            ]
            face/extra/start-down: 0
            face/rate: 100:00:00
    ]
    on-over [
        react [
        	if face/extra/start-down <> 0 [
        		link-field/text: to-string new-offset-val: ( face/extra/orig-val +  ( event/offset - face/extra/start-down )) 
        	]
        ]
    ]
    on-create [ 
        face/flags: [ all-over ] 
        face/extra: [ start-down: 0 orig-val: 0 grid: 1x1 ] 
    ]
    }
    ;******************************** END STATIC STRING ************************************************************************************** 
        replace/all xy-widget "link-field" linked-field-name
        append variables-list rejoin [ linked-field-name "-xy-widget" ]
        return rejoin [ " space 0x4 " linked-field-name "-xy-widget: " xy-widget ]
        ]
        to-valid-pair: function [ s [ string!] ] [
            either error? err: try/all  [ 
                res: to-pair s
                true ; try return value
            ][
        		print ["Value of:(" s ") is an invalid pair value. Default value of 50x50 used. Please correct the value" ]
                return 50x50
            ][
                return res
            ]
        ]

        to-valid-colour: function [ s [ string!] ] [
            either error? err: try/all  [ 
                res: to-tuple s
                true ; try return value
            ][
        		print ["Value of:(" s ") is an invalid color value. Default value of 255.0.0 used. Please correct the value" ]
                return 255.0.0
            ][
                return res
            ]
        ]        

        set 'get-object-details function [ obj ] [
            output: copy []
            fld-names: words-of obj
            ndx: 0
            foreach fld fld-names [
                ndx: ndx + 1
                val-type: copy ""
                val: get in obj fld
                case [
                    unset?      :val  [ val-type: unset!   ]
                    word?       :val  [ val-type: word!    ]
                    function?   :val  [ val-type: function! val: :fld ]
                    object?     :val  [ val-type: object!   val: :fld ]
                    block?      :val  [ val-type: block!    val: "[...]" ]
                ]
                if ( val-type = "" ) [ val-type: type? val ]
                append/only output reduce [ fld val-type  val]
            ]
            return output
        ]
        
        set 'get-valid-fields function [ obj ] [
            eo: get-object-details obj 
            keeping: copy []
            foreach i eo [
                if any [ (i/2 = word!) (i/2 = pair!) (i/2 = string!) (i/2 = tuple!)][
                    append/only keeping i
                ]
            ]
            keeping        
        ]

        set 'edit-vid-object func [ obj ] [
            valid-fields: get-valid-fields obj
            obj-name: find-object-name obj
            link-req-offset: function [ req-tgt req-src ] [	
                req-src/text: to-string req-tgt/offset
                req-tgt/offset: to-valid-pair req-src/text 
            ]
            link-req-size: function [ req-tgt req-src ] [ 
                req-src/text: to-string req-tgt/size
                req-tgt/size: to-valid-pair req-src/text 
            ]
            link-req-text: function [ req-tgt req-src ] [ 
                req-src/text: req-tgt/text
                req-tgt/text: to-string req-src/text 
            ]
            link-req-color: function [ req-tgt req-src ] [ 
                req-src/text: to-string req-tgt/color
                req-tgt/color: to-valid-colour req-src/text 
            ]
            
    ;(((((((((((((((START STATIC TEXT **************************            
            lay: copy {
    Title "VID Object Editor"            
    style lbl: text font-size 13 120 right
    style fld: field 180x25 font-size 13
    style ro-fld: base font-size 13 left 202.202.202 black 180x24
    style btn: button font-size 13 left 202.202.202 black 180x24
    space 4x4 
    }
    ;)))))))))))))END STATIC TEXT **************************  
            first-face: rejoin [ "first-face-" obj-name ] 
            variables-list: copy []   
            drop-down-name: rejoin ["action-" get-uid "-drop-down"]  
            append variables-list drop-down-name
                 
            append lay rejoin [ "lbl" { "Object Name:" } first-face {: btn " } obj-name {" [ vid-source/do-highlight "} obj-name 
                {" ]   
                return space 4x4} 
                newline  
            ]
            react-code: copy ""
            requester-reactions: copy []  
        	foreach i valid-fields [ 
        	    assist-button: copy ""
        	    data-type: (to-string i/2)
        	    field-type: (to-string i/1) 
        	    valid-react: false
        	    requester-field-name: rejoin [ i/1 get-uid "-field" ]
        	    append variables-list requester-field-name 
            	data-field-style: switch/default data-type [   
           		    "word" [ 
           		        data-val: mold rejoin [ " " mold i/3 ]
           		        "ro-fld" 
           		    ]
           		    "pair" [
           		        assist-button: create-xy-widget requester-field-name
           		        valid-react: true
           		        data-val: mold mold i/3
           		        "fld"
           		    ]                        
           		    "tuple" [
           		        assist-button: create-color-requester requester-field-name
           		        valid-react: true
           		        data-val: mold mold i/3
           		        "fld"
           		    ]
            	][ ; default string! value
            	    valid-react: true
            	    data-val: mold i/3
         	        assist-button: create-multiline-requester requester-field-name data-val
            	    "fld"
            	]
                if valid-react [
                    append react-code rejoin [ "[ link-req-" field-type " [ " obj-name " " requester-field-name " ]  ]" newline tab tab tab ]
                ]
                append lay z: reduce [ 
                    tab {lbl "} i/1 {:" } requester-field-name {: } data-field-style " " data-val " " assist-button " space 4x4 return" newline
                ]
            ]
            remove/part skip tail react-code -4 4
            
            requester-reactions: to-block  copy react-code
            react-code: rejoin [ "[" newline tab tab tab react-code newline tab tab "]" ]
            react-code: rejoin [ "foreach i " react-code  newline tab tab "[ react-man/link i/1 i/2" newline tab tab "]" ]
            
    ;***** START STATIC TEXT ******************************************************************************************                
            append lay rejoin [{
    do [} react-code
    { 
    requester-object: "} obj-name {"       
    ]            
}]    
    ;*** END STATIC TEXT ***********************************************************************************************
            win-name: rejoin [ "win-" get-uid ]
            append variables-list win-name
            qt: {"} ; "
            req-slot: requester-slot/add-slot obj-name win-name variables-list requester-reactions
            if ( req-slot > -1 ) [
                req-offset: ( to-pair reduce [ 0 (--dc-mainwin-edge/y + 48 ) ]) + ( 351x0 * req-slot )
                
    ; **** START OF STATICALLY FORMATTED TEXT *****            
                to-do-blk: rejoin [{ 
the-layout: layout to-block lay
the-layout/menu: [ ; Actors for the menu are imbedded in 'requester-window-escape'
    "Object" [
        "Highlight" highlight-object
        "Copy to Clip" copy-object-to-clip
        "Delete" delete-object
    ]    
] 
view/no-wait/options } win-name {: the-layout
requester-window-escape/options [
    unview/only } win-name {
    requester-slot/remove-slot } req-slot {
] "} obj-name {" [ offset: } req-offset {]
}]                               
    ; **** END OF STATICALLY FORMATTED TEXT *****
                do to-block to-do-blk
            ]
        ]
    ] ; End of obj-edit-ctx *******************************************************************************
    
    dc-matrix: object [
        modify-source-code: function [ 
            {Default behaviour is to add/update value after the 'object type' word}
            obj-name [string! block!]
            field-name [string!]
            /prepend 
        ][    
            either ((type? obj-name) = block! ) [ ; IE: ["text1" "at"] - this specifies the key-word to modify
                key-word: to-word second obj-name
                obj-name:  first obj-name
                orig-obj-source-block: copy obj-source-block: get-vid-code-block vid-code/text to-word obj-name
            ][
                orig-obj-source-block: copy obj-source-block: get-vid-code-block vid-code/text to-word obj-name
                key-word: select orig-obj-source-block to-set-word obj-name 
            ]
            obj-type: select orig-obj-source-block to-set-word obj-name 
            
            obj-creator: select orig-obj-source-block to-set-word obj-name             
            new-entry: false
            field-datatype: type? select (get to-word obj-name) (to-lit-word field-name)
           
        	new-val:  reduce to-path reduce [ to-word obj-name to-word field-name ]
            
            code-details: get-vid-code-text/return-positions vid-code/text obj-source-block 
            
            obj-source-string: code-details/1
            orig-obj-source-string: copy obj-source-string
            
            if obj-type = 'button [
                switch field-name [ ; accomodate changes from Windows widget size and placement
                    "offset" [ new-val: new-val + 1x1   ]
                    "size"   [ new-val: new-val + -2x-2 ]
                ]
            ]
            if not (find vid-code/text obj-source-string) [
                request-message  {Unable to correctly modify the source code.^/If you are entering complex strings, it is more reliable^/to enter them directly in the source code editor.}
                return
            ]   
            either val-ndx: index-of-value obj-source-block key-word field-datatype [ 
                ins-point: insert remove skip obj-source-block (val-ndx - 1) new-val          ;-- Modify existing value
            ][
                ins-point: insert (skip ( find obj-source-block obj-creator ) 1 ) new-val     ;-- Add new entry directly after object name ie: button, text, base. also works with styles                
                new-entry: true
            ]
            ins-ndx: (index? ins-point) - 1
            either all [ prepend  new-entry ] [
                new-object-source: copy orig-obj-source-string
                insert new-object-source  rejoin [ ( mold/flat/only reduce [ to-word key-word new-val ] ) " " ] ; manual inserting of code to prepend existing code string
            ][
                either new-entry [
                    new-object-source: create-modified-source/inserted (copy obj-source-string) orig-obj-source-block obj-source-block to-block ins-ndx            
                ][
                    new-object-source: create-modified-source          (copy obj-source-string)  orig-obj-source-block obj-source-block to-block ins-ndx            
                ]
            ]
            src-pos: to-pair code-details/2
            replace (skip vid-code/text src-pos/x ) orig-obj-source-string new-object-source
        ]
        triggers: [ 
            button: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            field: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            base: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            text: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            drop-list: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            check: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]       
            radio: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            area: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            text-list: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]
            drop-down: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]      
            progress: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]                  
            slider: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]           
            panel: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]            
            tab-group: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]      
            group-box: [  
                offset: 'move-object
                size: 'size-object
                text: 'text-object
                color: 'color-object
            ]              
        ]
        deactivate-object-name: none
        activate: func [ 
            action-object-name [word!] 
            /local action-obj activate-func
        ][
            action-obj: dc-matrix/edit-object 
        	activate-func: get in action-obj 'activate
            do (bind body-of :activate-func '--obj-selected) 
        ]
        deactivate: func [                           
            /this-object this-object-name obj-action
            /local action-obj deactivate-func
        ][
            if any [ (this-object) ] [ ; just exit func if neither
                either not this-object [
                    action-obj: dc-matrix/edit-object
                    deactivate-func: get in action-obj 'deactivate 
                    do (bind body-of :deactivate-func '--obj-selected)
                ][
                    dc-matrix/deactivate-object-name: this-object-name
                    deactivate-func: get in (get in dc-matrix to-word obj-action) 'deactivate
                    do (bind body-of :deactivate-func '--obj-selected)                  
                ]
            ]
        ]
        reflect-changes: make object! [
            trigger-list: copy []
            set 'previous-obj-vals copy []
            save-object-vals: function [ obj-name [string!] /remove-vals ][ ; defaults to saving all of the values
                either remove-vals [
                    fnd: find-in-array-at/with-index previous-obj-vals 1 obj-name
                    if fnd [
                        rem-ndx: second fnd
                        remove skip previous-obj-vals (rem-ndx - 1)
                    ]
                ][
                    either not fnd: find-in-array-at/with-index previous-obj-vals 1 obj-name [ ; Create a new entry
                        new-obj: safe-object-copy (get (to-word obj-name))
                        new-obj/text: copy any [ (get in (get to-word obj-name) 'text) "" ]     ; doubles up on separating text from object
                        insert/only previous-obj-vals  reduce [ obj-name new-obj ]    
                    ][                                                                          ; modify existing entry
                        new-obj: safe-object-copy (get (to-word obj-name))
                        new-obj/text: copy any [ (get in (get to-word obj-name) 'text) "" ]     ; doubles up on separating text from object
                        remove skip previous-obj-vals ( fnd/2 - 1)
                        insert/only previous-obj-vals  reduce [ obj-name new-obj ]    
                    ]
                ]
            ]
            link-gui-fields: function [ trig-tgt trig-src ] [
            	trig-tgt/text:   trig-src/text
            	trig-tgt/offset: trig-src/offset
            	trig-tgt/size:   trig-src/size
            	trig-tgt/color:  trig-src/color
            ]
            trigger-reaction: object [ 
            	object-name: none
            	text: none
            	size: none
            	offset: none
            	color: none
            	on-change*: func [word old new][
                	if any [ (word = 'text) (all [ (not none? old) (not none? new) (not-equal? old new)]) ][
                        if all [   	   
                    	    (not old = 0x0) 
                    	    (not old = "")
                    	][  
                    	    trigger-modifications object-name to-string word 
                    	]
                    ]
                	system/reactivity/check/only self word
              	]
            ]     
            get-new-trigger: function [ obj-name [string!]] [
                ndx: 0
                until  [
                    ndx: ndx + 1            
                    not find-in-array-at trigger-list 1 ndx
                ]
                append/only trigger-list reduce [ ndx obj-name ]
                return ndx
            ]
            set 'reflect-changes-to-source function [ obj [ object!] /stop  ] [ 
                obj-name: find-object-name obj
                either stop [
                    if empty? trigger-list [ return false ]
                    trigger-entry: find-in-array-at/with-index trigger-list 2 obj-name
                    trigger-num: first first trigger-entry
                    rem-ndx: second trigger-entry
                    trigger-name: rejoin [ "trigger-" trigger-num ]

                    react-man/unlink 'link-gui-fields  reduce [ to-word trigger-name (to-word obj-name) ]
                    save-object-vals/remove-vals obj-name
                    remove skip trigger-list (rem-ndx - 1)
                ][ ; New Trigger created here
                    either not trigger-fnd: find-in-array-at trigger-list 2 obj-name [
                        trigger-num: get-new-trigger obj-name
                        trigger-name: rejoin [ "trigger-" trigger-num ]
                        do reduce [ ( to-set-word trigger-name ) construct/with reduce [ to-set-word "object-name" obj-name ] trigger-reaction  ]
                        react-man/link 'link-gui-fields reduce [ to-word trigger-name (to-word obj-name) ] 
                        save-object-vals obj-name
                    ][ ; Relink existing trigger values
                        trigger-name: rejoin [ "trigger-" trigger-fnd/1 ]
                        react-man/unlink 'link-gui-fields reduce [ to-word trigger-name (to-word obj-name) ] 
                        react-man/link   'link-gui-fields reduce [ to-word trigger-name (to-word obj-name) ] ; ***later***
                        save-object-vals obj-name
                    ]
                ]
            ]
            set 'trigger-modifications function [ obj-name [string!] field-name [string!] ] [ ; trigger-modifications:
                switch/default field-name [
           		    "offset" [ 
                        modify-source-code/prepend reduce [ obj-name "at" ] field-name 
           		    ]    
           		    "text" [
           		        ;print "trigger-modifications $field-type=TEXT"
                        if fnd: find-in-array-at previous-obj-vals 1 obj-name [
                            old-val: get in fnd/2 to-lit-word field-name
                            new-val: any [ (get in ( get (to-lit-word obj-name)) to-lit-word field-name) "" ]
                            either not-equal?  old-val new-val [ ; only modify source if text is different - on-change* generates a lot of false changes
                                set in fnd/2 'text copy new-val
                                modify-source-code obj-name field-name
                            ][  ; Empty block below is used for debugging only
                            ]
                        ]
           		    ]
               	][ ; Default switch action
        	        modify-source-code obj-name field-name     
           		]
            ]            
        ]        

    	; ********** action objects  ***********
    	move-object: object [
            field-name: "offset"
            update-source-code: function [ obj-name ] [
                modify-source-code/prepend reduce [ obj-name "at" ] field-name 
            ]
        ]
        size-object: object [
            field-name: "size"
            update-source-code: function [ obj-name ] [
                modify-source-code obj-name field-name     
            ]
        ]
        text-object: object [
            field-name: "text"
            update-source-code: function [ obj-name ] [
                modify-source-code obj-name field-name     
            ]
        ]
        color-object: object [
            field-name: "color"
            update-source-code: function [ obj-name ] [
                modify-source-code obj-name field-name     
            ]
        ]
        edit-object: object [
            activate: does [
                if --obj-selected  [
                    reflect-changes-to-source --obj-selected 
                    edit-vid-object (get to-word  dc-reactor/active-object)
                ]
            ]
            deactivate: does [
                reflect-changes-to-source/stop (get to-word dc-matrix/deactivate-object-name)
                run-and-save
            ]
        ]
    ]   
     
    --over-face: none
    dc-reactor: make reactor! [
        current-file: clean-path %default-direct-code.red    
        active-object: ""
    ]
    current-path: does [ first split-path dc-reactor/current-file ]
    setup-size: 800x200    
    vid-size: 800x400
    output-panel-size: 800x600    
    live-update?: true
    
    red-executable: copy ""
    external-editor: copy ""
    direct-code-settings: clean-path %direct-code-settings.data
    vid-code-marker: {;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!}
    set-red-executable: func [ /none-set ] [
        full-msg: "Where is the Red executable file?"
        if none-set [ full-msg: rejoin ["The current 'Red Executable' setting is invalid^/" full-msg ] ]
        if ( red-ex: request-a-file any [ :red-executable  "" ] full-msg "Red Executable File: " ) [
            red-executable: red-ex
            save-settings
        ]
    ]
    set-external-editor: func [ /none-set ] [
        full-msg: "Where is your External Text Editor?"
        if none-set [ full-msg: rejoin ["The current 'External Editor' setting is invalid^/" full-msg ] ]
        if ( external-ed: request-a-file any [ :external-editor  "" ] full-msg "External Editor: " ) [
            external-editor: external-ed
            save-settings
        ]
    ]
    run-program-separately: does [
        either (exists? to-file red-executable) [
            call/shell rejoin [ to-local-file red-executable " " to-local-file dc-reactor/current-file ]
        ][
            set-red-executable/none-set
        ]
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
    insert-vid-object: function [ obj-type ][
        if obj-type = none [ 
            return none
        ]
        if ((copy/part to-string obj-type 4) = "ins-") [
            orig-obj-name: copy skip to-string obj-type 4
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
            base        [ (obj-set-word) base white black (obj-name) loose ]
            text        [ (obj-set-word) text (obj-name) loose ]
            button      [ (obj-set-word) button (obj-name) loose ]
            check       [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            radio       [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            field       [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            area        [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            text-list   [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            drop-list   [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            drop-down   [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            calendar    [ (obj-set-word) (to-word orig-obj-name)            loose ]
            progress    [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            slider      [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            camera      [ (obj-set-word) (to-word orig-obj-name)            loose ]
            panel       [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            tab-panel   [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            window      [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            screen      [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]
            group-box   [ (obj-set-word) (to-word orig-obj-name) (obj-name) loose ]             
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
        append vid-code/text mold/only compose (select obj-template (to-lit-word orig-obj-name))
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
        if (not exists? filename)[
            req-res: request-message/size rejoin [ "Trying to open filename:^/" to-string filename "^/This file does not exist"] 600x300
            return false
        ]
        
        file-header: read/part filename 200
        either all [ (exists? filename) (find file-header  {Comment: "Generated with Direct Code"} ) ] [
            if (value? 'dc-initialized) [
                recent-menu/add-item dc-reactor/current-file    
            ]
            if ((to-string filename) <> dc-reactor/current-file ) [
                monitor-file-change false
            ]
            close-object-editor/all-open 
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
    ]

    set 'recent-menu closure [ 
        recent-file-list: [] [block!]
        max-entries: 5
    ] 
    [
        /add-item filename [file!]
        /get-item item-num [number!]
        /get-all
        /set-all value [ block! ]
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
                if (not find recent-file-list filename ) [    
                    push-into-menu filename        
                ]
            ]
            get-item [
                return pick recent-file-list item-num
            ]
            get-all [
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
            save repend ( copy root-path ) %direct-code-settings.data 
                new-line/skip/all reduce [ 
                    'filename dc-reactor/current-file     
                    'setup-size setup-code/size
                    'vid-size vid-code/size
                    'output-panel-size output-panel/size 
                    'live-update? live-update?
                    'red-executable red-executable
                    'external-editor external-editor
                    'logging global-logging
                    'recent-files recent-files
                ] true 2        
        ]    
    ]    
        
    get-matrix-actions: function [ action-object-name action-name ] [
        if action-object-name <> "no-action" [
            action-object-name-to-word: to-word action-object-name
    		action-obj: dc-matrix/:action-object-name-to-word
    		action-name-to-word: to-word action-name
    		return get in action-obj action-name-to-word		
        ]
    ]    
    
    update-source-code: function [ obj-name action-object-name ] [ 
        upd-src-func: get-matrix-actions action-object-name 'update-source-code
        upd-src-func obj-name
        active-filename/color: yellow        
    ]    
    
    set 'run-and-save func [ /no-save /local vid-good? setup-good?] [ ;-- save only happens if the run is successful
        setup-good?: vid-good?: true
        foreach [ n o w v reactions ] requester-locations-used [        
            requester-slot/unlink-slot n
            reflect-changes-to-source/stop get to-word o
        ]
        either error? err: try/all [ 
            if setup-code/text [
                do load setup-code/text
            ]
            true ; makes try happy
        ][
            print "*** SETUP CODE ERROR / VID CODE IGNORED! ****************************************"
            print err
            print "*********************************************************************************"
            active-filename/color: yellow
            setup-code/color: yellow 
            setup-good?: false
        ][ ;-- setup code ran clean
            either error? err: try/all [
                if vid-code/text [
                    the-vid-code: load vid-code/text
                    output-panel/pane: layout/only new-lay: the-vid-code
                ]
                true ;-- makes try happy
            ][
                print "*** VID CODE ERROR **************************************************************"
                print err
                print "*********************************************************************************"
                active-filename/color: yellow
                vid-code/color: yellow
                vid-good?: false
            ][
                setup-code/color: white
                vid-code/color: white
                if not no-save [ 
                    save-direct-code dc-reactor/current-file 
                ]
                active-filename/color: white
                output-panel/pane: layout/only new-lay
            ]
        ]
        if all [ vid-good? setup-good?] [
            foreach [ n obj-name w v reactions ] requester-locations-used [        
                reflect-changes-to-source get to-word obj-name
                requester-slot/relink-slot n
            ]
        ]
    ]
    
    left-control-down: false
    change-logging: function [ /off /on /extern global-logging] [
        if on [
            global-logging: true
            bprint [ "change-logging global-logging =( true )"] 
        ]
        if off [
            bprint [ "change-logging global-logging =( false )"]
            global-logging: false
        ]
        
        save-settings 
    ]
        
    either (exists? direct-code-settings) [ 
        loaded-settings: load direct-code-settings
        dc-reactor/current-file: loaded-settings/filename 
        setup-size: loaded-settings/setup-size
        vid-size: loaded-settings/vid-size
        output-panel-size: loaded-settings/output-panel-size
        live-update?: all-to-logic loaded-settings/live-update?
        global-logging: all-to-logic loaded-settings/logging
        either global-logging [ change-logging/on ][ change-logging/off ]
        if not red-executable: loaded-settings/red-executable [
            set-red-executable
        ]
        if not external-editor: loaded-settings/external-editor [
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
            --obj-selected: none
        ][
            --obj-selected: f 
            --dc-mainwin-edge: mainwin/offset + mainwin/size    
            dc-matrix/activate 'edit-object
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
        call/shell rejoin [ to-local-file red-executable " " to-local-file clean-path rejoin [ root-path %direct-code.red]   ]
    ]
    
    
    direct-code-event-handler: func [
        face [object!] 
        event [event!]
    ][
        if all [ ( event/key = 'F12) (event/type = 'key-up) ] [
            restart-direct-code
        ]
        if all [ ( event/key = 'F2) (event/type = 'key-up) ] [
            edit-vid-object --obj-selected
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
            (event/type = 'mid-down)
            all [(event/key = to-char 192) (event/type = 'key-down) left-control-down ] ; Control + Tilde
        ][
            if (--over-face/parent = output-panel) [ 
                select-object --over-face 
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
        if all [ (event/key = 'F8) (event/type = 'key-up) ] [
            either global-logging [ change-logging/off ][ change-logging/on ]
        ]
        if all [ event/key = 'F10  event/type = 'key-up ][
            monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ]
        ]
        if all [ event/key = 'F9  event/type = 'key-up ][
            run-program-separately 
        ]
        if event/type = 'moving [ ; A little hacky -  fires off the first interpret after the program has loaded.
            set 'dc-initialized true
            if any [ (not (value? 'first-run?) ) (first-run? = none)] [
                write %direct-code.log ""
                first-run?: false
                --dc-mainwin-edge: mainwin/offset + mainwin/size
                recent-menu/set-all loaded-settings/recent-files
                run-and-save
            ]
        ]
        if event/type = 'resize [
            --dc-mainwin-edge: mainwin/offset + mainwin/size
        ]
        if event/type = 'close [
            switch/default event/window/text [
                "Direct Code" [ 
                    run-and-save
                    remove-event-func :direct-code-event-handler    
                ]
            ][
                
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
    
    red-object-browser: does [ do repend (copy root-path)  %tools/red-object-browser.red ]

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
                [
                    load-and-run dc-reactor/current-file
                    monitor-file-change either check-for-file-change/rate = 999:00:00 [ true ] [ false ] 
                ]
                on-time [
                    if file-modified? dc-reactor/current-file [
                        load-and-run/no-save dc-reactor/current-file
                    ]         
                ]
            active-filename: text font-size 12 250x24 center white 
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
            	            popup-help/offset (to-string dc-reactor/current-file) (face/parent/parent/offset + face/offset + event/offset + 20x0  )        
            	        ]
            	    ]
                ]
            space 6x4            
            space 0x4
            space 6x4
            button 45x24 right center  " RED>> " [ 
                do red-fld/text
            ]
            space 0x4
            red-fld: field 340x24 [ do red-fld/text ]
            return
            below
            text "Setup Code (before layout) :" 200x15  
            setup-code: area setup-size on-key-up [ check-source-change event/key ] 
            pad 0x4
            ; horizontal splitter
            splith: split 800x6 data [setup-code/size vid-lable/offset vid-code/offset vid-code/size]

            vid-lable: text "Layout code in VID dialect :" 150x15
            vid-code: area vid-size 
                on-key-up [ check-source-change event/key ]
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
                    if (exists? rf )[
                        req-res: request-message/size rejoin [ "The file named:^/" to-string rf "^/already exists. Do you want to copy over it?"] 600x300
                        if (not req-res) [ return false ]
                    ]
                    close-object-editor/all-open
                    either dc-reactor/current-file <> rf [
                        file-data: read dc-reactor/current-file
                        replace file-data rejoin [ {Title: "} second split-path dc-reactor/current-file {"}] rejoin [ {Title: "} second split-path rf {"}]
                        write rf file-data
                    ][
                        copy-file dc-reactor/current-file rf    
                    ]
                    dc-reactor/current-file: copy rf
                    monitor-file-change false
                ]
            ]
            
            open-dc: does  [
                if (rf: request-file/title/file "Open" current-path  ) [
                    recent-menu/add-item dc-reactor/current-file
                    close-object-editor/all-open
                    monitor-file-change false
                    if (load-direct-code rf) [
                        run-and-save    
                    ]
                ]
            ]
            
            new-dc: does [
                if (rf: request-file/title/file "Specify a NEW file name" current-path ) [
                    recent-menu/add-item dc-reactor/current-file
                    setup-code/text: copy ""
                    vid-code/text: copy ""
                    dc-reactor/current-file: rf
                    run-and-save
                ]
            ]
            
            set 'do-to-object func [ obj-name do-action  ] [                                   
                              
                do-this: to-path reduce [ 'vid-source to-word rejoin [ "do-" do-action ] ]     
                do reduce [ do-this obj-name ] 
                if do-action = "delete" [
                    close-object-editor/only obj-name                                          
                    run-and-save
                ]
            ]                                                                                  

            set 'close-object-editor function [ /only obj-name  /all-open ] [
                if only [
                    slot-num: first back fnd: find requester-locations-used obj-name
                    win-name: first next fnd
                    unview/only ( get to-word win-name )    
                    requester-slot/remove-slot slot-num
                ]
                if all-open [
                    while [(length? requester-locations-used) > 0 ] [
                        foreach [ num obj-name win-name v reac ] copy/part requester-locations-used 5 [
                            unview/only get to-word win-name
                            requester-slot/remove-slot num
                        ]  
                    ]
                ]
            ]            

            set 'vid-source func [ obj-name [string!] /do-highlight /do-delete /do-copy-to-clip ] [
                obj-source-block: get-vid-code-block vid-code/text to-word obj-name
                src-text: get-vid-code-text/return-positions vid-code/text obj-source-block
                if (src-text/2 = none)[ 
                    return false 
                ]
                obj-source-string: src-text/1
                obj-position: to-pair src-text/2
            	return-res: none
                case [
                    do-highlight [
                        select-pair: obj-position + 1x-1
                        vid-code/selected: select-pair 
                    ]
                    do-delete [
                        remove/part (skip vid-code/text obj-position/x ) (obj-position/y - obj-position/x)
                    ]
                    do-copy-to-clip [
                        write-clipboard  ( copy/part (skip vid-code/text obj-position/x ) (obj-position/y - obj-position/x))
                    ]
                ]
                return true
            ]
            load-direct-code dc-reactor/current-file
        ]
        ; vertical spliter
        splitv: split 6x100 data [pan/size splith/size setup-code/size vid-code/size output-panel/size output-panel/offset]
        output-panel: panel output-panel-size
    ]
    mainwin/menu: [
        "File" [ 
            "New"               new
            "Open"              open   
            "Open with External Editor" open-external
            "Save As"           save-as
            "Recent" []
            "Reload" [
                "Reload Now" reload
                "Reload when changed ON - F10"  reload-when-changed-on    
                "Reload when changed OFF -F10"  reload-when-changed-off   
            ]           
            "Run Separately - F9"    run-separate
            "Restart Direct Code - F12" restart-program
        ]
        "Insert" [
            "Base"      ins-base 
            "Text"      ins-text 
            "Button"    ins-button 
            "Check"     ins-check 
            "Radio"     ins-radio 
            "Field"     ins-field 
            "Area"      ins-area 
            "Text List" ins-text-list
            "Drop List" ins-drop-list 
            "Calendar"  ins-calendar
            "Drop Down" ins-drop-down 
            "Progress"  ins-progress 
            "Slider"    ins-slider 
            "Camera"   ins-camera 
            "Panel"     ins-panel 
            "Tab Panel" ins-tab-panel 
            "Group Box" ins-group-box                
            
            "Includes" [
                    "direct-code-stand-alone" ins-dc-stand-alone 
            ]
        ]
        "Object" [
            "Edit" edit-object
            "Show Named Objects" show-named-objects
            "Object Browser" object-browser
        ]
        "Debug" [
            "Logging" [
                "View Log File" show-log    
                "Logging OFF - F8"   change-logging-off 
                "Logging ON   - F8"   change-logging-on
            ]
            
            "System" [
                "Dump Reactions" show-all-reactions
                "System/view/debug ON - F11"  system-view-debug-on
                "System/view/debug OFF- F11"  system-view-debug-off
            ]
        ]
        "Settings" [
            "Red Executable" set-red-exe
            "External Editor" set-ext-editor
        ]
        "Help" [
            "Direct Code Help" direct-code-help
            "Quick Start Guide" quick-start-guide
            "About" help-about
            "Red Version" red-version
        ]
    ]
    mainwin/actors: make object! [
        on-menu: function [face [object!] event [event!]][ 
            switch/default event/picked [
                recent-1 [ load-and-run recent-menu/get-item 1 ]
                recent-2 [ load-and-run recent-menu/get-item 2 ]
                recent-3 [ load-and-run recent-menu/get-item 3 ]
                recent-4 [ load-and-run recent-menu/get-item 4 ]
                recent-5 [ load-and-run recent-menu/get-item 5 ]
                save-as  [ save-dc ]
                open  [ open-dc ]
                open-external [
                    either exists? to-file external-editor  [
                        monitor-file-change true
                        call rejoin [ to-local-file external-editor " " to-local-file dc-reactor/current-file ]    
                    ][
                        set-external-editor/none-set
                    ]
                ]
                new   [ new-dc ]
                reload [ load-and-run dc-reactor/current-file ]
                reload-when-changed-on [ monitor-file-change true ]
                reload-when-changed-off [ monitor-file-change false  ]
                restart-program [ restart-direct-code ]
                
                ins-dc-stand-alone [ insert-direct-code-stand-alone ]
                object-browser [ red-object-browser ]

                system-view-debug-on [ system/view/debug?: true ]
                system-view-debug-off [ system/view/debug?: false ]
                show-all-reactions [ dump-reactions ]
                show-log [
                    either exists? to-file external-editor  [
                        call rejoin [ to-local-file external-editor " " to-local-file repend what-dir %direct-code.log ]    
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
                set-red-exe [ set-red-executable ]
                set-ext-editor [ set-external-editor ]
                direct-code-help [
                    do repend copy (root-path) %help/direct-code-help.red 
                ]
                quick-start-guide [
                    load-and-run rejoin [ root-path %help/quick-start-guide.red ]
                ]
                help-about [
                    request-message/size  
                        read repend copy root-path %help/help-about.txt
                        700x300
                ]
                red-version [
                    request-message 
                        rejoin [ "Red Build " system/version " - " system/build/git/date  ]
                ]
                edit-object [
                    edit-vid-object --obj-selected
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
