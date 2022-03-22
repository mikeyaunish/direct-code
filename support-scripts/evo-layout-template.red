[
    title "VID Object Editor" 
    style lbl: base font-size voe-font-size voe-label-size right 230.230.230 black 
    style fld-bracket: text "[" bold voe-fld-bracket-size 255.255.255 center middle font-size voe-font-size 
    style fld: field voe-fld-size font-size voe-font-size 
    style clr-fld: field voe-clr-field-size font-size voe-font-size 
    style clr-swatch: base voe-clr-swatch-size draw [pen gray box 0x0 25x24] 
    style ro-fld: field disabled no-border font-size voe-font-size left 202.202.202 black voe-fld-size 
    style btn: button font-size voe-font-size left 202.202.202 black voe-fld-size 
    style chk: check voe-chk-size 247.247.247 
    style zero-btn: button voe-zero-btn-size zero-icon-image 
    style dot-btn: button "..." font-size voe-font-size voe-dot-btn-size 
    style drop-dwn: drop-down font-size voe-drop-down-font-size voe-drop-down-size 
    style receive-data-field: field hidden 0x0 
    style drop-dwn-lbl: lbl voe-drop-down-label-size 
    style action-panel-line: base black voe-hline-size 
    style select-divider-line: base black voe-select-hline-size 
    style select-gap-line: base hidden voe-select-gap-line-size 
    style data-hline: base black voe-data-hline-size 
    style xy-btn: base 230.230.230 voe-xy-btn-size 
    extra [
        last-timestamp: none 
        start-down: none 
        orig-val: none 
        output-field: none 
        target-object: none 
        get-output-field-text: none 
        set-output-field: none 
        starting-value: none 
        directions: copy [] 
        delay-buffer: 0:00:00.05 
        on-up-action: none
    ] 
    on-down [
        face/extra/start-down: event/offset 
        face/extra/orig-val: to-pair face/extra/get-output-field-text face
    ] 
    on-up [
        either (event/offset = face/extra/start-down) [
            face/extra/set-output-field face to-string ((to-safe-pair face/extra/get-output-field-text face) + face/extra/directions/1)
        ] [
            do bind face/extra/on-up-action 'face
        ] 
        face/extra/start-down: 0
    ] 
    on-wheel [
        face/extra/set-output-field face to-string ((to-safe-pair face/extra/get-output-field-text face) + (event/picked * face/extra/directions/2))
    ] 
    on-over [
        if face/extra/start-down <> 0 [
            if ((now/time/precise - face/extra/last-timestamp) > face/extra/delay-buffer) 
            [
                face/extra/set-output-field face to-string (face/extra/orig-val + (event/offset - face/extra/start-down)) 
                face/extra/last-timestamp: now/time/precise
            ]
        ]
    ] 
    on-create [
        face/flags: [all-over] 
        face/extra/get-output-field-text: func [this-face] [
            return any [
                (either 
                    (output-field-value: get to-path reduce [to-word this-face/extra/output-field 'text]) = "" 
                    [
                        none
                    ] [
                        output-field-value
                    ]
                ) 
                (either this-face/extra/starting-value <> 'none [this-face/extra/starting-value] [none]) 
                0x0
            ]
        ] 
        face/extra/set-output-field: func [this-face v] [
            cur-val: get to-path reduce [to-word this-face/extra/output-field 'text] 
            if cur-val = "" [
                v: to-string to-safe-pair get to-path reduce this-face/extra/target-object 
            ] 
            do reduce [to-set-path reduce [to-word this-face/extra/output-field 'text] v] 
            if this-face/extra/target-object <> "" [
                do reduce [
                    to-set-path reduce this-face/extra/target-object 
                    to-safe-pair (to-pair v)
                ]
            ]
        ] 
        face/extra/starting-value: to-safe-pair get to-path reduce face/extra/target-object 
        face/extra/start-down: 0 
        face/extra/orig-val: 0 
        face/extra/last-timestamp: now/time/precise
    ] 
    style offset-xy-btn: xy-btn with [
        extra/output-field: 'offset-field~ 
        extra/target-object: [to-word target-object-name~ 'offset] 
        extra/on-up-action: [
            if (face/extra/get-output-field-text face) <> "" [
                modify-source vid-code-test/text target-object-name~ [word! "at"] (to-safe-pair offset-field~/text) 
                refresh-results-gui
            ]
        ]
    ] 
    style size-xy-btn: xy-btn with [
        extra/output-field: 'size-field~ 
        extra/target-object: [to-word target-object-name~ 'size]
    ] 
    style after-view: button hidden 0x0 rate 0:00:00.0001 
    on-time [
        face/rate: 1000:40:39 
        do face/extra/code-to-run 
        face/extra/rerun: func [this-face] [
            do bind this-face/extra/code-to-run 'this-face
        ]
    ] 
    extra [
        code-to-run: [] 
        rerun: copy []
    ] 
    style tempered-field: field voe-xy-fld-size 
    rate 0:00:00.1 
    on-time [
        if all [(
            ((time-diff: now/time/precise - face/extra/last-change) > 0:00:00.19)
        ) 
            (not face/extra/last-event-fired?)
        ] [
            face/extra/last-event-fired?: true 
            face/extra/last-change: now/time/precise 
            do bind face/extra/on-change-action 'face
        ]
    ] 
    on-change [
        if ((now/time/precise - face/extra/key-timestamp) > 0:00:00.02) [
            face/extra/last-change-diff: (now/time/precise - face/extra/last-change) 
            face/extra/last-change: now/time/precise 
            face/extra/last-event-fired?: false
        ]
    ] 
    on-key [
        face/extra/key-timestamp: now/time/precise
    ] 
    extra [
        last-change: none 
        last-change-diff: none 
        last-event-fired?: true 
        key-timestamp: none 
        on-change-action: none 
        key-timestamp: none 
        on-create-action: none 
        on-change-immediate: none 
        last-field-value: none
    ] 
    on-create [
        face/extra/last-change: now/time/precise 
        face/extra/last-change-diff: now/time/precise 
        face/extra/key-timestamp: now/time/precise 
        do bind face/extra/on-create-action 'face
    ] 
    style x-axis-button: base 230.230.230 voe-xy-btn-size 
    extra [
        last-timestamp: none 
        start-down: none 
        orig-val: none 
        output-field: none 
        target-object: none 
        get-output-field-integer: 0 
        set-output-field: none 
        starting-value: none 
        directions: copy [] 
        delay-buffer: 0:00:00.05 
        on-up-action: none
    ] 
    on-down [
        face/extra/start-down: event/offset/x 
        face/extra/orig-val: face/extra/get-output-field-integer face
    ] 
    on-up [
        either (event/offset/x = face/extra/start-down) [
            face/extra/set-output-field face to-string ((face/extra/get-output-field-integer face) + face/extra/directions/1)
        ] [
            do bind face/extra/on-up-action 'face
        ] 
        face/extra/start-down: 0
    ] 
    on-wheel [
        face/extra/set-output-field face to-string to-integer ((face/extra/get-output-field-integer face) + (event/picked * face/extra/directions/2))
    ] 
    on-over [
        if face/extra/start-down <> 0 [
            if ((now/time/precise - face/extra/last-timestamp) > face/extra/delay-buffer) 
            [
                face/extra/set-output-field face to-string (face/extra/orig-val + (event/offset/x - face/extra/start-down)) 
                face/extra/last-timestamp: now/time/precise
            ]
        ]
    ] 
    on-create [
        face/flags: [all-over] 
        face/extra/get-output-field-integer: func [this-face] [
            return either (output-field-value: get to-path reduce [to-word this-face/extra/output-field 'text]) = "" [
                either this-face/extra/starting-value = 'none [
                    9
                ] [
                    this-face/extra/starting-value
                ]
            ] [
                to-safe-integer output-field-value
            ]
        ] 
        face/extra/set-output-field: func [this-face v] [
            do reduce [to-set-path reduce [to-word this-face/extra/output-field 'text] v] 
            if this-face/extra/target-object <> none [
                do reduce [
                    to-set-path reduce this-face/extra/target-object v
                ]
            ]
        ] 
        if face/extra/target-object <> none [
            face/extra/starting-value: get to-path reduce face/extra/target-object
        ] 
        face/extra/start-down: 0 
        face/extra/orig-val: 0 
        face/extra/last-timestamp: now/time/precise
    ] 
    style voe-x-axis-button: x-axis-button with [
        extra/output-field: 'font-size-field~ 
        extra/target-object: none 
        extra/on-up-action: [
            if (face/extra/get-output-field-integer face) <> none [
                valid-size: to-valid-font-size to-safe-integer font-size-field~/text 
                modify-source vid-code-test/text target-object-name~ [word! "font-size"] valid-size 
                if (to-string valid-size <> font-size-field~/text) [
                    font-size-field~/text: to-string valid-size
                ] 
                refresh-results-gui
            ]
        ]
    ] 
    evo-after-view~: after-view with [extra/code-to-run: [
        if system/script/args = "immediate-close" [
            system/script/args: copy "" 
            unview edit-vid-object-layout
        ] 
        clear-voe-fields "~" 
        clear-all-actions 
        vid-cdta-to-view-fields/id src-cdta-to-vid-cdta (to-word target-object-name~) vid-code-test/text "~" 
    ]] 
    space 2x2 
    tab-panel1~: tab-panel [
        "Object" [
            backdrop 247.247.247 
            space 4x4 
            lbl "Object Name:" on-up [
                evo-menu-handler name-field~/text "highlight-source-object"
            ] 
            name-field~: fld [
                named-objs: get-list-of-named-objects 
                either find named-objs name-field~/text [
                    request-message rejoin [{Can not rename this object to: "} name-field~/text {"} newline "because this name is already being used."]
                ] [
                    window-name: "--evo-window" 
                    set (to-path reduce [(to-word window-name) 'extra 'current-object-name]) face/text 
                    modify-source vid-code-test/text target-object-name~ [set-word!] rejoin [face/text ":"] 
                    target-object-name~: copy face/text 
                    new-title: rejoin ["VID Object Editor - [" name-field~/text "]"] 
                    set (to-path reduce [(to-word window-name) 'text]) new-title 
                    dash: copy "-" 
                    set (to-word rejoin [dash dash "evo-window" dash face/text]) get to-word window-name 
                    refresh-results-gui
                ]
            ] 
            return space 4x4 
            lbl "Type:" type-field~: ro-fld 
            options-style-field~: receive-data-field 
            space 4x4 return 
            lbl "Text:" text-field~: fld on-enter [
                modify-source vid-code-test/text target-object-name~ [string!] text-field~/text 
                refresh-results-gui
            ] 
            space 0x4 
            text-field-multiline~: 
            dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a TEXT string for the object named: '" target-object-name~ "'"] voe-multiline-requester-size (to-safe-string text-field~/text) [
                    either value? to-word "target-object-name~" [
                        text-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [string!] get-results 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        text-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [string!] text-field~/text 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            space 0x4 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [string!] none 
                text-field~/text: copy "" 
                refresh-results-gui
            ] 
            import-to-text-field~: button import-icon-image voe-import-icon-size [
                text-field~/text: to-string get to-path reduce [(to-word target-object-name~) 'text] 
                modify-source vid-code-test/text target-object-name~ [string!] text-field~/text 
                refresh-results-gui
            ] 
            return 
            space 4x4 
            lbl "Offset:" 
            offset-field~: tempered-field font-size voe-font-size 
            with [
                extra/on-change-action: [
                    if offset-field~/text <> "" [
                        either (extra/last-field-value <> offset-field~/text) [
                            extra/last-field-value: offset-field~/text 
                            btn-adjust: 0x0 
                            if type-field~/text = "button" [
                                btn-adjust: 1x1
                            ] 
                            modify-source vid-code-test/text target-object-name~ [word! "at"] (
                                ((to-safe-pair offset-field~/text) + btn-adjust)
                            ) 
                            refresh-results-gui
                        ] [
                            extra/last-field-value: offset-field~/text 
                        ]
                    ]
                ]
            ] 
            on-enter [
                either offset-field~/text = "" [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "at"] none
                ] [
                    btn-adjust: 0x0 
                    if type-field~/text = "button" [
                        btn-adjust: 1x1
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "at"] (
                        ((to-safe-pair offset-field~/text) + btn-adjust)
                    )
                ] 
                refresh-results-gui
            ] 
            space 0x4 
            offset-starting-value-field~: receive-data-field on-change [
                down-y-offset-btn~/extra/starting-value: up-y-offset-btn~/extra/starting-value: right-x-offset-btn~/extra/starting-value: left-x-offset-btn~/extra/starting-value: to-safe-pair offset-starting-value-field~/text
            ] 
            space 1x4 
            left-x-offset-btn~: offset-xy-btn 
            with [extra/directions: [-1x0 5x0]] 
            draw left-btn-drawing 
            right-x-offset-btn~: offset-xy-btn 
            with [extra/directions: [1x0 5x0]] 
            draw :right-btn-drawing 
            up-y-offset-btn~: offset-xy-btn 
            with [extra/directions: [0x-1 0x-5]] 
            draw up-btn-drawing 
            down-y-offset-btn~: offset-xy-btn 
            with [extra/directions: [0x1 0x-5]] 
            draw down-btn-drawing 
            space 1x4 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [word! "at"] none 
                offset-field~/text: copy "" 
                refresh-results-gui 
                offset-starting-value: to-string get to-path reduce [to-word target-object-name~ 'offset] 
                down-y-offset-btn~/extra/starting-value: up-y-offset-btn~/extra/starting-value: right-x-offset-btn~/extra/starting-value: left-x-offset-btn~/extra/starting-value: offset-starting-value
            ] 
            space 0x4 
            import-to-offset-field~: button import-icon-image voe-import-icon-size [
                offset-field~/text: to-string (get to-path reduce [(to-word target-object-name~) 'offset]) 
                if offset-field~/text <> "" [
                    modify-source vid-code-test/text target-object-name~ [word! "at"] (to-safe-pair offset-field~/text) 
                    refresh-results-gui
                ]
            ] 
            return 
            space 4x4 
            lbl "Size:" 
            size-field~: tempered-field font-size voe-font-size 
            with [extra/on-change-action: [
                either size-field~/text <> "" [
                    either (extra/last-field-value <> size-field~/text) [
                        extra/last-field-value: size-field~/text 
                        btn-adjust: 0x0 
                        if type-field~/text = "button" [
                            btn-adjust: -2x-2
                        ] 
                        modify-source vid-code-test/text target-object-name~ [pair!] (
                            ((to-safe-pair size-field~/text) + btn-adjust)
                        ) 
                        refresh-results-gui
                    ] [
                        extra/last-field-value: size-field~/text 
                    ]
                ] [
                ]
            ]] 
            on-enter [
                either size-field~/text = "" [
                    modify-source/delete vid-code-test/text target-object-name~ [pair!] none
                ] [
                    modify-source vid-code-test/text target-object-name~ [pair!] (to-safe-pair size-field~/text)
                ] 
                refresh-results-gui
            ] 
            space 0x4 
            size-starting-value-field~: receive-data-field 
            on-change [
                down-y-size-btn~/extra/starting-value: up-y-size-btn~/extra/starting-value: right-x-size-btn~/extra/starting-value: left-x-size-btn~/extra/starting-value: to-safe-pair size-starting-value-field~/text
            ] 
            space 1x4 
            left-x-size-btn~: size-xy-btn 
            with [extra/directions: [-1x0 5x0]] 
            draw left-btn-drawing 
            right-x-size-btn~: size-xy-btn 
            with [extra/directions: [1x0 5x0]] 
            draw :right-btn-drawing 
            up-y-size-btn~: size-xy-btn 
            with [extra/directions: [0x-1 0x-5]] 
            draw up-btn-drawing 
            down-y-size-btn~: size-xy-btn 
            with [extra/directions: [0x1 0x-5]] 
            draw down-btn-drawing 
            space 1x4 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [pair!] none 
                size-field~/text: copy "" 
                refresh-results-gui 
                size-starting-value: to-string get to-path reduce [to-word target-object-name~ 'size] 
                down-y-size-btn~/extra/starting-value: up-y-size-btn~/extra/starting-value: right-x-size-btn~/extra/starting-value: left-x-size-btn~/extra/starting-value: size-starting-value
            ] 
            space 4x4 
            return 
            requester-completed-field~: tempered-field rate 0:00:00.3 hidden 0x0 
            with [
                extra/on-change-action: [
                    requester-completed?~: true
                ]
            ] 
            lbl "Color:" 
            color-field~: clr-fld [
                modify-source vid-code-test/text target-object-name~ [tuple!] to-tuple face/text 
                refresh-results-gui
            ] 
            on-enter [
                modify-source vid-code-test/text target-object-name~ [tuple!] to-tuple face/text 
                refresh-results-gui
            ] 
            space 0x4 
            color-swatch~: clr-swatch on-up [
                res: request-color/size/title 400x400 "Select a color" 
                if res [
                    color-field~/text: to-string res 
                    color-swatch~/color: to-tuple res 
                    modify-source vid-code-test/text target-object-name~ [tuple!] to-tuple res 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    color-swatch~/color: to-safe-tuple color-field~/text
                ]
            ] 
            space 0x4 
            dot-btn [
                res: request-color/size/title 400x400 "Select a color" 
                if res [
                    color-field~/text: to-string res 
                    color-swatch~/color: to-tuple res 
                    modify-source vid-code-test/text target-object-name~ [tuple!] to-tuple res 
                    refresh-results-gui
                ]
            ] 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [tuple!] none 
                color-field~/text: copy "" 
                refresh-results-gui
            ] 
            return 
            space 4x4 
            lbl "Loose:" loose-field~: ro-fld 
            space 0x4 
            loose-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "loose"] 'loose 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "loose"] none 
                    refresh-results-gui
                ]
            ] 
            options-drag-on-field~: ro-fld hidden 0x0 on-create [
                react [
                    loose-field-checkbox~/data: any [(options-drag-on-field~/text = "down") false] 
                    loose-field~/text: to-safe-string loose-field-checkbox~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Hidden:" vid-hidden-field~: ro-fld space 0x4 
            hidden-field~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "hidden"] 'hidden 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "hidden"] 'hidden 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-hidden-field~/text: to-string hidden-field~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Disabled:" vid-disabled-field~: ro-fld space 0x4 
            disabled-field~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "disabled"] 'disabled 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "disabled"] 'disabled 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-disabled-field~/text: to-string disabled-field~/data
                ]
            ] 
            return 
            space 4x4 
            lbl "Tri-state:" tri-state-field~: ro-fld space 0x4 
            tri-state-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "tri-state"] 'tri-state 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "tri-state"] none 
                    refresh-results-gui
                ]
            ] 
            flags-tri-state-field~: check false hidden 0x0 on-create [
                react [
                    tri-state-field-checkbox~/data: flags-tri-state-field~/data 
                    tri-state-field~/text: to-string tri-state-field-checkbox~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Focus:" vid-focus-field~: ro-fld space 0x4 
            vid-focus-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "focus"] 'focus 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "focus"] none 
                    refresh-results-gui
                ]
            ] 
            focus-field~: check false hidden 0x0 on-create [
                react [
                    vid-focus-field-checkbox~/data: focus-field~/data 
                    vid-focus-field~/text: to-string vid-focus-field-checkbox~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Password:" password-field~: ro-fld 
            space 0x4 
            password-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "password"] 'password 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "password"] none 
                    refresh-results-gui
                ]
            ] 
            flags-password-field~: check false hidden 0x0 on-create [
                react [
                    password-field-checkbox~/data: flags-password-field~/data 
                    password-field~/text: to-string password-field-checkbox~/data
                ]
            ] 
            return 
            space 4x4 
            lbl "All-over:" 
            all-over-field~: ro-fld 
            space 0x0 
            all-over-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "all-over"] 'all-over 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "all-over"] 'all-over 
                    refresh-results-gui
                ]
            ] 
            flags-all-over-field~: check false hidden 0x0 on-create [
                react [
                    all-over-field-checkbox~/data: flags-all-over-field~/data 
                    all-over-field~/text: to-string all-over-field-checkbox~/data
                ]
            ] 
            return 
            base voe-requester-width hidden
        ] 
        "Appearance" [
            backdrop 247.247.247 
            space 4x4 
            drop-dwn-lbl "Horiz. Align:" 
            halign-drop-down~: drop-dwn data ["left" "center" "right" "<omitted>"] 
            on-change [
                last-dropped: copy/part face/data ((length? face/data) - 1) 
                foreach align-str last-dropped [
                    either align-str = face/text [
                        modify-source vid-code-test/text target-object-name~ reduce [word! align-str] (to-word align-str) 
                        refresh-results-gui
                    ] [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! align-str] none 
                        refresh-results-gui
                    ]
                ]
            ] 
            space 0x4 
            para-align-field~: field 0x0 hidden 
            on-create [
                react [
                    halign-drop-down~/selected: index? find ["left" "center" "right" "<omitted>"] any [para-align-field~/text "<omitted>"]
                ]
            ] 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "center"] none 
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "left"] none 
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "right"] none 
                halign-drop-down~/selected: 4 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            drop-dwn-lbl "Vert. Align:" 
            valign-drop-down~: drop-dwn data ["top" "middle" "bottom" "<omitted>"] 
            on-change [
                last-dropped: copy/part face/data ((length? face/data) - 1) 
                foreach align-str last-dropped [
                    either align-str = face/text [
                        modify-source vid-code-test/text target-object-name~ reduce [word! align-str] (to-word align-str) 
                        refresh-results-gui
                    ] [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! align-str] none 
                        refresh-results-gui
                    ]
                ]
            ] 
            space 0x4 
            para-v-align-field~: field 0x0 hidden 
            on-create [
                react [
                    valign-drop-down~/selected: index? find ["top" "middle" "bottom" "<omitted>"] any [para-v-align-field~/text "<omitted>"]
                ]
            ] 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "top"] none 
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "bottom"] none 
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "middle"] none 
                valign-drop-down~/selected: 4 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            drop-dwn-lbl "Wrap:" 
            wrap-drop-down~: drop-dwn data ["wrap" "no-wrap" "<omitted>"] 
            on-change [
                last-wrap-dropped: copy/part face/data ((length? face/data) - 1) 
                foreach wrap-str last-wrap-dropped [
                    either wrap-str = face/text [
                        modify-source vid-code-test/text target-object-name~ reduce [word! "wrap"] (to-word wrap-str) 
                        refresh-results-gui
                    ] [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! wrap-str] none 
                        refresh-results-gui
                    ]
                ]
            ] 
            space 0x4 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "wrap"] none 
                modify-source/delete vid-code-test/text target-object-name~ reduce [word! "no-wrap"] none 
                wrap-drop-down~/selected: 3 
                refresh-results-gui
            ] 
            para-wrap?-field~: check 0x0 hidden 
            on-create [
                react [
                    wrap-drop-down~/selected: either para-wrap?-field~/data [1] [3]
                ]
            ] 
            para-no-wrap?-field~: check 0x0 hidden 
            on-create [
                react [
                    wrap-drop-down~/selected: either para-no-wrap?-field~/data [2] [3]
                ]
            ] 
            return 
            space 4x4 
            lbl "No-border:" 
            flags-no-border-field~: ro-fld 
            space 0x0 
            flags-no-border-field-checkbox~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ [word! "no-border"] 'no-border 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "no-border"] none 
                    refresh-results-gui
                ]
            ] 
            flags-no-border-field~: check false hidden 0x0 on-create [
                react [
                    flags-no-border-field-checkbox~/data: flags-no-border-field~/data 
                    flags-no-border-field~/text: to-string flags-no-border-field-checkbox~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Hint:" options-hint-field~: fld "" on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "hint"] options-hint-field~/text 
                refresh-results-gui
            ] 
            space 0x4 
            hint-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a HINT string for the object named: '" target-object-name~ "'"] voe-multiline-requester-size (to-safe-string options-hint-field~/text) [
                    either value? to-word "target-object-name~" [
                        options-hint-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "hint"] options-hint-field~/text 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        options-hint-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! "hint"] options-hint-field~/text 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                options-hint-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "hint"] none 
                refresh-results-gui
            ]
        ] 
        "Font" [
            backdrop 247.247.247 
            space 4x8 
            lbl "Font Name:" font-name-field~: fld 
            space 0x4 
            dot-btn [
                if not current-font: get (to-path reduce [(to-word target-object-name~) 'font]) [
                    current-font: make object! [
                        name: "Segoe UI" 
                        size: 9 
                        style: none 
                        angle: 0 
                        color: none 
                        anti-alias?: false
                    ]
                ] 
                either current-font [
                    new-font: request-font/font current-font
                ] [
                    new-font: request-font
                ] 
                dif: compare-objects/show-diffs current-font new-font 
                monitored-font-vals: [
                    size [
                        font-size-field~/text: copy to-string new-val 
                        modify-source vid-code-test/text target-object-name~ [word! "font-size"] (to-integer new-val) 
                        refresh-results-gui
                    ] 
                    name [
                        font-name-field~/text: copy new-val 
                        modify-source vid-code-test/text target-object-name~ [word! "font-name"] to-string new-val 
                        refresh-results-gui
                    ] 
                    style [
                        new-val: if-single-to-block new-val 
                        foreach i [bold italic] [
                            either find new-val i [
                                set-font-check-widget to-string i true
                            ] [
                                set-font-check-widget to-string i false
                            ]
                        ]
                    ]
                ] 
                foreach i dif [
                    if fnd: find monitored-font-vals i [
                        new-val: get in new-font (to-lit-word i) 
                        do reduce fnd/2
                    ]
                ]
            ] 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [word! "font-name"] none 
                font-name-field~/text: copy "" 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Font Size:" 
            font-size-field~: tempered-field voe-x-fld-size font-size voe-font-size 
            with [
                extra/on-change-action: [
                    either font-size-field~/text <> "" [
                        either (extra/last-field-value <> font-size-field~/text) [
                            valid-size: either (extra/last-field-value = none) [
                                9
                            ] [
                                to-valid-font-size to-safe-integer font-size-field~/text
                            ] 
                            extra/last-field-value: font-size-field~/text 
                            modify-source vid-code-test/text target-object-name~ [word! "font-size"] valid-size 
                            if (to-string valid-size <> font-size-field~/text) [
                                font-size-field~/text: to-string valid-size
                            ] 
                            refresh-results-gui
                        ] [
                            extra/last-field-value: font-size-field~/text 
                        ]
                    ] [
                    ]
                ]
            ] 
            on-enter [
                either font-size-field~/text = "" [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "font-size"] none
                ] [
                    valid-size: to-valid-font-size to-safe-integer font-size-field~/text 
                    modify-source vid-code-test/text target-object-name~ [word! "font-size"] valid-size 
                    if (to-string valid-size <> font-size-field~/text) [
                        font-size-field~/text: to-string valid-size
                    ]
                ] 
                refresh-results-gui
            ] 
            space 1x4 
            left-x-font-size-btn~: voe-x-axis-button 
            with [extra/directions: [-1 3]] 
            draw left-btn-drawing 
            right-x-font-size-btn~: voe-x-axis-button 
            with [extra/directions: [1 3]] 
            draw :right-btn-drawing 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [word! "font-size"] none 
                font-size-field~/text: copy "" 
                font-size-field~/extra/last-field-value: none 
                refresh-results-gui
            ] 
            font-size-starting-value-field~: receive-data-field 
            on-change [
                left-x-font-size-btn~/extra/starting-value: right-x-font-size-btn~/extra/starting-value: to-safe-integer font-size-starting-value-field~/text 
            ] 
            space 4x4 
            return 
            lbl "Font Color:" 
            font-color-field~: clr-fld [
                modify-source vid-code-test/text target-object-name~ [word! "font-color"] to-tuple face/text 
                refresh-results-gui
            ] on-enter [
                font-color-swatch~/color: to-tuple font-color-field~/text 
                modify-source vid-code-test/text target-object-name~ [word! "font-color"] to-tuple face/text 
                refresh-results-gui
            ] 
            space 0x4 
            font-color-swatch~: clr-swatch on-up [
                res: request-color/size/title 400x400 "Select a color" 
                if res [
                    font-color-field~/text: to-string res 
                    font-color-swatch~/color: to-tuple res 
                    modify-source vid-code-test/text target-object-name~ [word! "font-color"] to-tuple res 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    font-color-swatch~/color: to-safe-tuple font-color-field~/text
                ]
            ] 
            dot-btn [
                res: request-color/size/title 400x400 "Select a color" 
                if res [
                    font-color-field~/text: to-string res 
                    font-color-swatch~/color: to-tuple res 
                    modify-source vid-code-test/text target-object-name~ [word! "font-color"] to-tuple res 
                    refresh-results-gui
                ]
            ] 
            zero-btn [
                font-color-field~/text: copy "" 
                font-color-swatch~/color: 128.128.128 
                modify-source/delete vid-code-test/text target-object-name~ [word! "font-color"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Bold:" 
            vid-font-bold-field~: ro-fld space 0x4 
            font-bold-field~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ reduce ['word! "bold"] 'bold 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "bold"] 'bold 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-font-bold-field~/text: to-string font-bold-field~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Italic:" 
            vid-font-italic-field~: ro-fld space 0x4 
            font-italic-field~: chk false [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ reduce ['word! "italic"] 'italic 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "italic"] 'italic 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-font-italic-field~/text: to-string font-italic-field~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Underline:" 
            vid-font-underline-field~: ro-fld space 0x4 
            font-underline-field~: chk false on-change [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ reduce ['word! "underline"] 'underline 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "underline"] none 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-font-underline-field~/text: to-string font-underline-field~/data
                ]
            ] 
            space 4x4 
            return 
            lbl "Anti-alias?:" 
            vid-font-anti-alias?-field~: ro-fld space 0x4 
            font-anti-alias?-field~: chk false on-change [
                either face/data [
                    modify-source vid-code-test/text target-object-name~ reduce ['word! "font"] [anti-alias?: true] 
                    refresh-results-gui
                ] [
                    modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "font"] none 
                    refresh-results-gui
                ]
            ] 
            on-create [
                react [
                    vid-font-anti-alias?-field~/text: to-string font-anti-alias?-field~/data
                ]
            ]
        ] 
        "Graphics" [
            backdrop 247.247.247 
            space 4x4 
            lbl "Image:" image-field~: fld "" on-enter [
                modify-source vid-code-test/text target-object-name~ [file!] (to-valid-file image-field~/text) 
                image-field~/text: mold to-valid-file image-field~/text 
                refresh-results-gui
            ] 
            space 0x4 
            image-file-requester~: dot-btn [
                res: request-file/title/file "Select an image file" (to-red-file get-current-dir) 
                if res [
                    modify-source vid-code-test/text target-object-name~ [file!] (to-valid-file res) 
                    image-field~/text: mold to-valid-file res 
                    refresh-results-gui
                ]
            ] 
            zero-btn [
                image-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [file!] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Draw Block:" 
            space 0x4 
            fld-bracket "[" 
            gui-draw-field~: fld no-border 160 "" on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "draw"] (to-block gui-draw-field~/text) 
                refresh-results-gui
            ] 
            fld-bracket "]" 
            draw-field~: receive-data-field on-change [
                gui-draw-field~/text: de-block-string draw-field~/text
            ] 
            space 0x4 
            draw-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a DRAW string for the object named: '" target-object-name~ "'"] voe-multiline-requester-size (to-safe-string gui-draw-field~/text) [
                    either value? to-word "target-object-name~" [
                        gui-draw-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "draw"] (to-block gui-draw-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        gui-draw-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! "draw"] (to-block gui-draw-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                gui-draw-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "draw"] none 
                refresh-results-gui
            ] 
            return 
            space 0x0 
            base white 350x4 return 
            base black 350x2 return 
            base white 350x4 return 
            space 4x4 
            text font-size 12 "PANEL / TAB-PANEL / GROUP-BOX" 350 center 
            return 
            lbl "Layout Block:" 
            space 0x4 
            fld-bracket "[" 
            gui-layout-block-field~: fld no-border 160 "" on-enter [
                either any [
                    type-field~/text = "panel" 
                    type-field~/text = "tab-panel" 
                    type-field~/text = "group-box"
                ] 
                [
                    modify-source vid-code-test/text target-object-name~ [block!] (to-block gui-layout-block-field~/text) 
                    refresh-results-gui
                ] [
                    gui-layout-block-field~/text: copy "" 
                    request-message/size {The 'Layout Block' can only be used for VID Objects:^/1.) panel^/2.) tab-panel^/3.) group-box} 400
                ]
            ] 
            fld-bracket "]" 
            layout-block-field~: receive-data-field on-change [
                gui-layout-block-field~/text: de-block-string layout-block-field~/text
            ] 
            space 0x4 
            layout-block-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a layout string for the object named: '" target-object-name~ "'"] voe-multiline-requester-size (to-safe-string gui-layout-block-field~/text) [
                    either value? to-word "target-object-name~" [
                        gui-layout-block-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [block!] (to-block gui-layout-block-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        gui-layout-block-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [block!] (to-block gui-layout-block-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                gui-layout-block-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [block!] none 
                refresh-results-gui
            ] 
            return 
            space 0x0 
            base white 350x4 return 
            base black 350x2 return 
            base white 350x4 return
        ] 
        "Data etc." [
            backdrop 247.247.247 
            space 4x4 
            lbl "Data:" 
            gui-data-field~: fld "" 
            on-enter [
                process-data-field~ gui-data-field~/text
            ] 
            on-create [
                process-data-field~: func [
                    val 
                    /not-gui-source
                ] [
                    valid-value: string-to-valid-type val 
                    either block? valid-value [
                        clear-data-fields-group/except ["select-field" "data-field"]
                    ] [
                        clear-data-fields-group/except ["data-field"]
                    ] 
                    switch/default (to-string type? valid-value) [
                        "logic" [
                            true-false-field~/data: valid-value 
                            modify-source vid-code-test/text target-object-name~ [word! "true"] valid-value
                        ] 
                        "date" [
                            date-field~/text: to-string valid-value 
                            modify-source vid-code-test/text target-object-name~ [date!] valid-value
                        ] 
                        "percent" [
                            percent-field~/text: to-string valid-value 
                            modify-source vid-code-test/text target-object-name~ [percent!] valid-value
                        ]
                    ] [
                        modify-source vid-code-test/text target-object-name~ [word! "data"] valid-value
                    ] 
                    if not-gui-source [
                        gui-data-field~/text: mold valid-value
                    ] 
                    refresh-results-gui
                ]
            ] 
            space 0x4 
            data-field~: receive-data-field on-change [
                if (data-field~/text <> "") [
                    process-data-field~/not-gui-source data-field~/text
                ]
            ] 
            data-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter DATA for the object named: '" target-object-name~ "'"] voe-multiline-requester-size gui-data-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        gui-data-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    process-data-field~ gui-data-field~/text
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        gui-data-field~/text: to-string res 
                        process-data-field~ gui-data-field~/text
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                clear-data-fields-group 
                modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Select:" 
            selected-field~: fld "" on-enter [
                clear-data-fields-group/except ["select-field" "data-field"] 
                either (selected-field~/text = "") [
                    modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none
                ] [
                    modify-source vid-code-test/text target-object-name~ [word! "select"] (to-integer selected-field~/text)
                ] 
                refresh-results-gui
            ] 
            base hidden voe-missing-dot-btn-size 
            zero-btn [
                selected-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none 
                refresh-results-gui
            ] 
            return 
            select-gap-line 
            select-divider-line 
            return 
            lbl "True/False:" 
            logic-field~: ro-fld space 0x4 
            true-false-field~: chk false on-change [
                clear-data-fields-group/except ["true-false-field"] 
                either face/data [
                    gui-data-field~/text: copy "true" 
                    modify-source vid-code-test/text target-object-name~ [word! "true"] 'true 
                    refresh-results-gui
                ] [
                    clear gui-data-field~/text 
                    modify-source/delete vid-code-test/text target-object-name~ [word! "true"] none 
                    refresh-results-gui
                ]
            ] 
            data-logic-field~: receive-data-field on-create [
                react [
                    true-false-field~/data: all-to-logic data-logic-field~/text 
                    logic-field~/text: to-safe-string true-false-field~/data
                ]
            ] 
            base hidden voe-true-false-spacer 
            zero-btn [
                clear-data-fields-group 
                modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none 
                true-false-field~/data: false 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Date:" date-field~: fld "" on-enter [
                either (first scan/next date-field~/text) = date! [
                    valid-date: load date-field~/text 
                    clear-data-fields-group/except ["date-field"] 
                    date-field~/text: to-string valid-date 
                    gui-data-field~/text: to-string valid-date 
                    modify-source vid-code-test/text target-object-name~ [date!] valid-date 
                    refresh-results-gui
                ] [
                    request-message {The date value entered is not in the correct format.^/Try one of the following formats:^/yyyy-mmm-dd^/dd-mmm-yyyy^/dd-mmm-yy^/mm/dd/yyyy^/dd-<full-month-name>-yyyy}
                ]
            ] 
            space 0x4 
            date-field-multiline~: dot-btn [
                either date-field~/text = "" [
                    pre-date: now/date
                ] [
                    pre-date: string-to-date date-field~/text
                ] 
                res: request-date/set-date pre-date 
                if res [
                    date-field~/text: to-string res 
                    clear-data-fields-group/except ["date-field"] 
                    gui-data-field~/text: to-string res 
                    modify-source vid-code-test/text target-object-name~ [date!] (string-to-date date-field~/text) 
                    refresh-results-gui
                ]
            ] 
            zero-btn [
                clear-data-fields-group 
                modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Percent:" percent-field~: fld "" on-enter [
                field-type: first scan/next percent-field~/text 
                either any [(field-type = percent!) (field-type = float!) (field-type = integer!)] [
                    valid-percent: to-percent load percent-field~/text 
                    clear-data-fields-group/except ["percent-field"] 
                    percent-field~/text: to-string valid-percent 
                    gui-data-field~/text: to-string valid-percent 
                    modify-source vid-code-test/text target-object-name~ [percent!] valid-percent 
                    refresh-results-gui
                ] [
                    request-message/size {The percent value entered is not in the correct format.^/For example, fifty percent can be entered in one of two formats0:^/1.) 50%^/2.) .50} 500x200
                ]
            ] 
            base hidden voe-missing-dot-btn-size 
            zero-btn [
                clear-data-fields-group 
                refresh-results-gui
            ] 
            return 
            data-hline 
            return 
            space 4x4 
            lbl "Default String:" options-default-field~: fld "" on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "default"] options-default-field~/text 
                refresh-results-gui
            ] 
            space 0x4 
            default-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter DEFAULT DATA for the object named: '" target-object-name~ "'"] voe-multiline-requester-size to-safe-string options-default-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        options-default-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "default"] (to-block options-default-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        options-default-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! "default"] (to-block options-default-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                clear options-default-field~/text 
                modify-source/delete vid-code-test/text target-object-name~ [word! "default"] none 
                refresh-results-gui
            ] 
            return 
            space 4x4 
            lbl "Extra:" extra-field~: fld "" on-enter [
                process-extra-field~ extra-field~/text
            ] 
            on-create [
                process-extra-field~: func [val] [
                    valid-value: string-to-valid-type val 
                    value-type: type? valid-value 
                    modify-source vid-code-test/text target-object-name~ [word! "extra"] to value-type valid-value 
                    refresh-results-gui
                ]
            ] 
            space 0x4 
            extra-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter EXTRA DATA for the object named: '" target-object-name~ "'"] voe-multiline-requester-size to-safe-string extra-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        extra-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    process-extra-field~ extra-field~/text
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        extra-field~/text: to-string res 
                        process-extra-field~ extra-field~/text
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                extra-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "extra"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "With Block:" 
            space 0x4 
            fld-bracket "[" 
            gui-with-field~: fld no-border "" 160 on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text) 
                refresh-results-gui
            ] 
            with-field~: receive-data-field on-change [
                gui-with-field~/text: trim/with (trim copy with-field~/text) "[]"
            ] 
            fld-bracket "]" 
            with-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter WITH DATA for the object named: '" target-object-name~ "'"] voe-multiline-requester-size to-safe-string with-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        gui-with-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        gui-with-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                gui-with-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "with"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "Rate:" rate-field~: fld "" on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "rate"] (to-time rate-field~/text) 
                refresh-results-gui
            ] 
            base hidden voe-missing-dot-btn-size 
            zero-btn [
                rate-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [word! "rate"] none 
                refresh-results-gui
            ] 
            space 4x4 
            return 
            lbl "URL:" url-field~: fld "" on-enter [
                modify-source vid-code-test/text target-object-name~ [url!] (to-url url-field~/text) 
                refresh-results-gui
            ] 
            space 0x4 
            url-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a URL for the object named: '" target-object-name~ "'"] voe-multiline-requester-size to-safe-string url-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        url-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [url!] (to-url url-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        url-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [url!] (to-url url-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                url-field~/text: copy "" 
                modify-source/delete vid-code-test/text target-object-name~ [url!] none 
                refresh-results-gui
            ] 
            at 6x11 data-diagram~: base 68x185 transparent draw :data-drawing
        ] 
        "Actions" [
            space 4x4 
            button "Create Default Action" bold font-size 12 102.168.152.0 center green 61.174.71.0 [
                modify-action-line/create-line/with-focus (select dc-default-action-list (to-word type-field~/text)) []
            ] 
            button "Create Any Action" bold font-size 12 102.168.152.0 center green 61.174.71.0 [
                if (picked: request-list/size/one-click "Pick an action.<one-click>" [
                    "on-alt-down" "on-alt-up" 
                    "on-aux-down" "on-aux-up" "on-change" 
                    "on-click" "on-close" "on-create" "on-dbl-click" "on-down" "on-drag" "on-drag-start" 
                    "on-drop" "on-enter" "on-focus" "on-key" "on-key-down" "on-key-up" "on-menu" 
                    "on-mid-down" "on-mid-up" "on-move" "on-moving" "on-over" "on-pan" "on-press-tap" 
                    "on-resize" "on-resizing" "on-rotate" "on-select" "on-time" "on-touch" "on-two-tap" 
                    "on-unfocus" "on-up" "on-wheel" "on-zoom"
                ] 300x300) [
                    modify-action-line/create-line/with-focus picked []
                ]
            ] 
            return 
            action-panel-line 
            return 
            text font-size 12 "List of Current Actions " voe-action-header-size center 
            return 
            action-panel-line 
            return 
            actors-on-click-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-click" (copy to-block face/text)] 
            actors-on-create-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-create" (copy to-block face/text)] 
            actors-on-down-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-down" (copy to-block face/text)] 
            actors-on-up-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-up" (copy to-block face/text)] 
            actors-on-mid-down-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-mid-down" (copy to-block face/text)] 
            actors-on-mid-up-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-mid-up" (copy to-block face/text)] 
            actors-on-alt-down-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-alt-down" (copy to-block face/text)] 
            actors-on-alt-up-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-alt-up" (copy to-block face/text)] 
            actors-on-aux-down-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-aux-down" (copy to-block face/text)] 
            actors-on-aux-up-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-aux-up" (copy to-block face/text)] 
            actors-on-drag-start-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-drag-start" (copy to-block face/text)] 
            actors-on-drag-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-drag" (copy to-block face/text)] 
            actors-on-drop-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-drop" (copy to-block face/text)] 
            actors-on-dbl-click-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-dbl-click" (copy to-block face/text)] 
            actors-on-over-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-over" (copy to-block face/text)] 
            actors-on-move-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-move" (copy to-block face/text)] 
            actors-on-resize-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-resize" (copy to-block face/text)] 
            actors-on-moving-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-moving" (copy to-block face/text)] 
            actors-on-resizing-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-resizing" (copy to-block face/text)] 
            actors-on-wheel-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-wheel" (copy to-block face/text)] 
            actors-on-zoom-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-zoom" (copy to-block face/text)] 
            actors-on-touch-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-touch" (copy to-block face/text)] 
            actors-on-pan-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-pan" (copy to-block face/text)] 
            actors-on-rotate-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-rotate" (copy to-block face/text)] 
            actors-on-two-tap-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-two-tap" (copy to-block face/text)] 
            actors-on-press-tap-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-press-tap" (copy to-block face/text)] 
            actors-on-key-down-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-key-down" (copy to-block face/text)] 
            actors-on-key-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-key" (copy to-block face/text)] 
            actors-on-key-up-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-key-up" (copy to-block face/text)] 
            actors-on-enter-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-enter" (copy to-block face/text)] 
            actors-on-focus-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-focus" (copy to-block face/text)] 
            actors-on-unfocus-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-unfocus" (copy to-block face/text)] 
            actors-on-select-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-select" (copy to-block face/text)] 
            actors-on-change-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-change" (copy to-block face/text)] 
            actors-on-menu-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-menu" (copy to-block face/text)] 
            actors-on-close-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-close" (copy to-block face/text)] 
            actors-on-time-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-time" (copy to-block face/text)] 
            action-panel~: panel voe-action-panel-size snow []
        ] 
        "React" [
            backdrop 247.247.247 
            space 4x4 
            lbl "React Block:" 
            space 0x4 
            fld-bracket "[" 
            gui-react-field~: fld no-border "" on-enter [
                modify-source vid-code-test/text target-object-name~ [word! "react"] (to-block gui-react-field~/text) 
                refresh-results-gui
            ] 
            fld-bracket "]" 
            react-field~: receive-data-field on-change [
                gui-react-field~/text: trim/with (trim copy react-field~/text) "[]"
            ] 
            space 0x4 
            react-field-multiline~: dot-btn [
                res: request-multiline-text/size/preload/submit/offset "Enter a text string" voe-multiline-requester-size gui-react-field~/text 
                [
                    either value? to-word "target-object-name~" [
                        gui-react-field~/text: get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! "react"] (to-block gui-react-field~/text) 
                    refresh-results-gui
                ] (--evo-window/offset + (to-pair reduce [--evo-window/size/x 0]) + 2x0) 
                if res [
                    either (value? to-word "target-object-name~") [
                        gui-react-field~/text: to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! "react"] (to-block gui-react-field~/text) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            zero-btn [
                modify-source/delete vid-code-test/text target-object-name~ [word! "react"] none 
                gui-react-field~/text: copy "" 
                refresh-results-gui
            ]
        ]
    ]
    do [
    active-actions: copy [] 
    current-layout: copy [] 
    return-needed?: false 
    action-list: copy [] 
    action-data: copy [] 
    receive-action-line~: function [
        action-name [string!] 
        /init 
        /with-code action-code 
        /no-focus 
        /extern current-layout return-needed? action-list requester-completed?~
    ] [
        action-code: action-code/1 
        either (value? to-word "requester-completed?~") [
            either requester-completed?~ [
                modify-action-line/update-line action-name action-code
            ] [
                create-action-line~/with-code/no-focus action-name action-code 
            ]
        ] [
            create-action-line~/with-code/no-focus action-name action-code
        ] 
    ] 
    clear-all-actions: function [
        /extern action-list action-data
    ] [
        create-action-line~/init "" 
        action-list: copy [] 
        action-data: copy []
    ] 
    create-action-line~: function [
        action-name [string!] 
        /init 
        /with-code action-code 
        /no-focus 
        /extern current-layout return-needed? action-list res
    ] [
        if with-code [
        ] 
        if init [
            return-needed?: false 
            current-layout: copy [
                style lbl: base font-size voe-font-size voe-label-size right 230.230.230 black 
                style action-fld: field no-border voe-action-fld-size font-size voe-font-size 
                style fld-bracket: text "[" bold voe-fld-bracket-size 255.255.255 center middle font-size voe-font-size 
                style dot-btn: button "..." font-size voe-font-size voe-dot-btn-size 
                style x-btn: button bold gray red font-size voe-font-size voe-dot-btn-size "X" 
                style action-panel-line: base black voe-hline-size 
                space 4x4
            ] 
            return none
        ] 
        the-code: either with-code [copy action-code] [[]] 
        append current-layout compose/deep [
            (either return-needed? ['return] []) 
            space 4x4 
            lbl (rejoin [action-name ":"]) 
            space 0x4 
            fld-bracket "[" 
            (to-set-word rejoin [action-name "-field~:"]) action-fld (mold/only the-code) 
            [
                modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block face/text 
                modify-action-line (action-name) to-block face/text 
                refresh-results-gui
            ] 
            fld-bracket "]" 
            space 0x4 
            (to-set-word rejoin [action-name "-dots~:"]) dot-btn 
            [
                res: request-multiline-text/size/preload/submit/offset (rejoin ["Enter the Red code for '" action-name "' action"]) voe-multiline-requester-size 
                (to-path reduce [to-word rejoin [action-name "-field~"] 'text]) 
                [
                    either value? to-word "target-object-name~" [
                        (to-set-path reduce [(to-word rejoin [action-name "-field~"]) 'text]) to-string get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ] 
                    modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block 
                    (
                        to-path reduce [(to-word rejoin [action-name "-field~"]) 'text]
                    ) 
                    modify-action-line (action-name) to-block (to-path reduce [(to-word rejoin [action-name "-field~"]) 'text]) 
                    refresh-results-gui
                ] (to-paren {--evo-window/offset + (to-pair reduce [ --evo-window/size/x 0] ) + 2x0}) 
                if res [
                    either value? to-word "target-object-name~" [
                        (to-set-path reduce [(to-word rejoin [action-name "-field~"]) 'text]) to-string res 
                        modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block 
                        (
                            to-path reduce [(to-word rejoin [action-name "-field~"]) 'text]
                        ) 
                        modify-action-line (action-name) to-block (to-path reduce [(to-word rejoin [action-name "-field~"]) 'text]) 
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.} 
                        return none
                    ]
                ]
            ] 
            space 0x4 
            x-btn [modify-action-line/delete-line (action-name) []]
        ] 
        if not find action-list action-name [
            append action-list action-name
        ] 
        save %current-action-layout.red current-layout 
        action-panel~/pane: layout/only current-layout 
        save-all-actions 
        return-needed?: true 
        if not no-focus [
            set-focus get (to-word rejoin [action-name "-field~"])
        ] 
    ] 
    modify-action-line: function [
        action-name [string!] 
        code [block!] 
        /create-line 
        /delete-line 
        /update-line 
        /with-focus 
        /extern action-list action-data
    ] [
        either update-line [
            either (fnd: select action-data action-name) [
                either fnd = code [
                    return none
                ] [
                    change fnd code
                ]
            ] [
                append action-data reduce [action-name code]
            ]
        ] [
            save-all-actions
        ] 
        if delete-line [
            remove/part find action-data action-name 2 
            remove find action-list action-name 
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! action-name] "" 
            refresh-results-gui
        ] 
        if create-line [
            either find action-list action-name [
                return none
            ] [
                append action-data reduce [action-name code]
            ]
        ] 
        create-action-line~/init "" 
        either (action-data = []) [
            action-panel~/pane: layout/only current-layout
        ] [
            foreach [the-action-name the-action-code] action-data [
                either all [with-focus (the-action-name = action-name)] [
                    create-action-line~/with-code the-action-name the-action-code
                ] [
                    create-action-line~/with-code/no-focus the-action-name the-action-code
                ]
            ]
        ]
    ] 
    create-action-line~/init "" 
    set-font-check-widget: func [widget-name state] [
        field-name: rejoin ["font-" widget-name "-field" "~"] 
        do reduce [to-set-path reduce [(to-word field-name) 'data] state] 
        field-val: either state [
            modify-source vid-code-test/text target-object-name~ reduce ['word! widget-name] (to-word widget-name) 
            refresh-results-gui 
            "true"
        ] [
            modify-source/delete vid-code-test/text target-object-name~ reduce ['word! widget-name] none 
            refresh-results-gui 
            "false"
        ] 
        do reduce [to-set-path reduce [(to-word field-name) 'text] field-val]
    ] 
    save-all-actions: function [/extern action-list action-data] [
        action-data: copy [] 
        foreach action-line action-list [
            append action-data reduce [action-line to-block to-safe-string (get to-path reduce [to-word rejoin [action-line "-field~"] 'text])]
        ] 
    ] 
    extra: [
        target-object-name: "~" 
        current-object-name: "" 
        original-window-name: "--evo-window"
    ] 
    requester-completed?~: false 
    run-and-save-changes: does [
        if value? to-word "requester-completed?~" [
            if requester-completed?~ [
                run-and-save "evo-requester"
            ]
        ]
    ] 
    clear-voe-fields: func [unique-num] [
        vid-object-editor-fields: [
            name-field type-field text-field offset-field size-field color-field 
            color-swatch loose-field loose-field-checkbox options-drag-on-field vid-hidden-field 
            hidden-field vid-disabled-field disabled-field tri-state-field 
            tri-state-field-checkbox flags-tri-state-field vid-focus-field vid-focus-field-checkbox 
            focus-field password-field password-field-checkbox flags-password-field 
            options-hint-field all-over-field all-over-field-checkbox flags-all-over-field 
            halign-drop-down valign-drop-down wrap-drop-down 
            font-name-field font-size-field font-color-field 
            font-color-swatch vid-font-bold-field font-bold-field vid-font-italic-field 
            font-italic-field vid-font-underline-field font-underline-field 
            vid-font-anti-alias?-field font-anti-alias?-field image-field 
            draw-field data-field selected-field options-default-field extra-field rate-field 
            with-field date-field percent-field logic-field url-field 
            react-field
        ] 
        foreach fld vid-object-editor-fields [
            fld-name: to-path reduce [(to-word rejoin [fld unique-num]) 'text] 
            set fld-name copy ""
        ]
    ] 
    clear-data-fields-group: func [
        /except exception-block [block!]
    ] [
        exception-block: any [exception-block []] 
        if not find exception-block "data-field" [
            clear gui-data-field~/text 
            modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none
        ] 
        if not find exception-block "select-field" [
            modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none 
            clear selected-field~/text
        ] 
        if not find exception-block "true-false-field" [
            modify-source/delete vid-code-test/text target-object-name~ [word! "true"] none 
            true-false-field~/data: false 
            clear logic-field~/text
        ] 
        if not find exception-block "date-field" [
            clear date-field~/text 
            modify-source/delete vid-code-test/text target-object-name~ [date!] none
        ] 
        if not find exception-block "precent-field" [
            modify-source/delete vid-code-test/text target-object-name~ [percent!] none 
            clear percent-field~/text
        ]
    ]
] ;-- End of do block 
] ;-- End of view block 
