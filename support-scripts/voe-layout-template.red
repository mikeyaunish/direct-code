[title "VID Object Editor"
backdrop snow
style lbl: base font-size voe-font-size voe-label-size right 230.230.230 black
style indent-lbl: base font-size voe-font-size voe-indent-label-size right 230.230.230 black
style fld-bracket: text "[" bold voe-fld-bracket-size 255.255.255 center middle font-size voe-font-size
style fld: field voe-fld-size font-size voe-font-size
extra [on-tab-away-do-enter: true]
style label-button: base font-size voe-font-size voe-label-size right 230.230.230 black on-over [] extra [original-color: none]
style dropdown-label-button: base font-size voe-font-size voe-drop-down-label-size right 230.230.230 black
on-over []
style clr-fld: field voe-clr-field-size font-size voe-font-size
extra [on-tab-away-do-enter: true]
style voe-button-with-image-face: button voe-zero-btn-size
extra [
    normal-image: ""
    hilight-image: ""
]
on-created [
    if not none? face/image [
        face/extra/normal-image: face/image
        face/extra/hilight-image: get-hilight-image face/image
        face/size: (face/image/size + 2x2)
    ]
]
on-over [
    face/image: either event/away? [
        face/extra/normal-image
    ] [
        face/extra/hilight-image
    ]
]
style voe-button-with-image-and-tooltip: button
extra [
    normal-image: ""
    hilight-image: ""
    over-offset: 0x0
    message: ""
    box: 0
    popped?: false
]
on-created [
    face/extra/popped?: false
    if not none? face/image [
        face/extra/normal-image: face/image
        face/extra/hilight-image: get-hilight-image face/image
    ]
]
on-over [
    either event/away? [
        face/image: face/extra/normal-image
        face/rate: 100:40:39
        if face/extra/popped? [
            face/extra/popped?: false
            popup-help/close ""
        ]
    ] [
        face/image: face/extra/hilight-image
        face/rate: 0:00:00.5
        face/extra/over-offset: event/offset
    ]
]
on-time [
    face/rate: 100:40:39
    face/extra/popped?: true
    box: either face/extra/box = 0 [false] [true]
    popup-help/offset/:box face/extra/message ((get-absolute-offset face) + face/extra/over-offset + 10x0)
]
style clr-swatch: base voe-clr-swatch-size draw [pen gray box 0x0 25x24]
style ro-fld: field disabled no-border font-size voe-font-size left 202.202.202 black voe-fld-size
style indent-ro-fld: field disabled no-border font-size voe-font-size left 202.202.202 black voe-indent-fld-size
style btn: button font-size voe-font-size left 202.202.202 black voe-fld-size
style chk: check voe-chk-size 247.247.247
style zero-btn: voe-button-with-image-face zero-icon-image
style zero-btn-tall: voe-button-with-image-face zero-icon-image-tall
style import-btn: voe-button-with-image-and-tooltip import-icon-image
style edit-btn: voe-button-with-image-and-tooltip edit-icon-image
with [
    extra/message: "Edit Style with VID Style Editor"
]
style dot-btn: button "..." font-size voe-font-size voe-dot-btn-size
style drop-dwn: drop-down font-size voe-drop-down-font-size voe-drop-down-size
style anti-alias-drop-dwn: drop-down font-size voe-anti-alias-drop-down-font-size
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
    face/extra/start-down: to-safe-pair event/offset
    face/extra/orig-val: to-safe-pair face/extra/get-output-field-text face
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
            face/extra/set-output-field face to-string to-safe-pair (face/extra/orig-val + (event/offset - face/extra/start-down))
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
            ])
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
                to-set-path reduce this-face/extra/target-object to-safe-pair v
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
        this-face/extra/rerun-flag: 1
        do bind this-face/extra/code-to-run 'this-face
        this-face/extra/rerun-flag: 0
    ]
]
extra [
    code-to-run: []
    rerun: copy []
    rerun-flag: 0
]
style tempered-field: field voe-xy-fld-size
rate 0:00:00.1
on-time [
    if all [(
        ((time-diff: now/time/precise - face/extra/last-change) > 0:00:00.19)
    )
    (not face/extra/last-event-fired?)] [
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
    on-tab-away-do-enter: true
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
            face/extra/set-output-field face to-string to-integer (face/extra/orig-val + (event/offset/x - face/extra/start-down))
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
do [
    convert-to-button: function [face] [
        draw-box: compose [pen 170.170.170 box 0x0 (face/size)]
        face/draw: bind draw-box 'event
        face/actors/on-over:
        func [[trace] face [object!] event [event! none!]] [
            either event/away? [
                face/color: face/extra/original-color
            ] [
                face/extra/original-color: face/color
                face/color: 229.241.251
            ]
        ]
    ]
    object-label-to-button: function [face] [
        face/draw: compose [pen 170.170.170 box 0x0 (face/size)]
        face/actors/on-over:
        func [[trace] face [object!] event [event! none!]] [
            either event/away? [
                face/extra/now-over?: false
                face/color: face/extra/original-color
            ] [
                face/color: 229.241.251
                if not face/extra/now-over? [
                    face/extra/now-over?: true
                ]
            ]
        ]
        face/actors/on-down:
        func [[trace] face [object!] event [event! none!]] [
            face/draw: compose [pen 170.170.170 box 0x0 (face/size)]
            face/color: face/extra/original-color
            face/extra/now-over?: false
            popup-help/close ""
        ]
        face/actors/on-dbl-click:
        func [[trace] face [object!] event [event! none!]] [
            face/draw: compose [line-width 2 pen 255.0.0 box 1x1 (face/size - 1x1)]
            voe-menu-handler/lock name-field~/text "highlight-source-object" reduce [name-field~/text "~"]
            face/extra/dbl-clicked?: true
        ]
        face/actors/on-up:
        func [[trace] face [object!] event [event! none!]] [
            either face/extra/dbl-clicked? [
                face/extra/dbl-clicked?: false
            ] [
                voe-menu-handler name-field~/text "highlight-source-object"
            ]
        ]
    ]
]
evo-after-view~: after-view with [
    extra/code-to-run: [
        evo-after~: function [/rerun] [
            if rerun [
                saved-action-list: copy action-list~
                create-action-line~/init ""
            ]
            clear-voe-fields "~"
            clear-all-actions~
            current-object-type: get to-path reduce [(to-word target-object-name~) 'type]
            source-to-view-fields/id target-object-name~ current-object-type vid-code-test/text "~"
            if (current-object-type <> none) [disable-unneeded-facets :current-object-type]
            if target-object-label~/text = "Style Name:" [
                disable-unneeded-facets 'style
                style-label~/text: "Parent Style:"
            ]
            highlight-styled-fields~/id "evo-after-"
            if not rerun [
                tab-panel1~/selected: dc-voe-selected-tab
            ]
        ]
        rerun: either (evo-after-view~/extra/rerun-flag = 1) [true] [false]
        evo-after~/:rerun
    ]
]
space 2x2
return
space 2x2
tab-panel1~: tab-panel [
    "Object" [
        backdrop 247.247.247
        space 4x4
        target-object-label~: base "Object Name:" font-size voe-font-size voe-label-size right 230.230.230 black
        rate 100:40:39
        extra [
            orig-color: 230.230.230
            hilite-color: 229.241.251
            orig-edge: 128.128.128
            hilite-edge: 0.100.195
            locked-edge: 255.0.0
            info: {Click once = Set Insertion Point to this object. Double click = LOCK-ON to this object as the Insertion Point. Single click again = Unset Insertion Point}
            popped?: false ""
            locked?: false ""
            dbl-clicked?: false ""
            dbl-clicked-time: 0:00:00
            over-offset: 0x0
        ]
        on-create [
            face/extra/orig-color: face/color
            face/draw: compose [pen (face/extra/orig-edge) box 0x0 (face/size)]
            face/extra/popped?: false
            face/extra/locked?: false
            face/extra/dbl-clicked?: false
            face/extra/dbl-clicked-time: 0:00:00
        ]
        on-dbl-click [
            lprint ["name-field~/text = " name-field~/text]
            lock-to-this-object~ face name-field~/text "~"
        ]
        on-down [
            if face/extra/popped? [
                face/extra/popped?: false
                popup-help/close ""
            ]
            if face/extra/locked? [
                face/extra/locked?: false
                face/draw: compose [pen (face/extra/orig-edge) box 0x0 (face/size)]
            ]
        ]
        on-up [
            time-delay: now/time/precise - face/extra/dbl-clicked-time
            either face/extra/dbl-clicked? [
                either time-delay > 0:00:00.13 [
                    face/extra/dbl-clicked?: false
                    voe-menu-handler name-field~/text "highlight-source-object"
                ] [
                ]
            ] [
                voe-menu-handler name-field~/text "highlight-source-object"
            ]
        ]
        on-over [
            either event/away? [
                face/rate: 100:40:39
                face/color: face/extra/orig-color
                if not face/extra/locked? [
                    face/draw: compose [pen (face/extra/orig-edge) box 0x0 (face/size)]
                ]
                if face/extra/popped? [
                    face/extra/popped?: false
                    popup-help/close ""
                ]
            ] [
                face/rate: 0:00:00.5
                face/extra/over-offset: event/offset
                face/color: face/extra/hilite-color
                if not face/extra/locked? [
                    face/draw: compose [pen (face/extra/hilite-edge) box 0x0 (face/size)]
                ]
            ]
        ]
        on-time [
            face/rate: 100:40:39
            face/extra/popped?: true
            popup-help/offset/box face/extra/info ((get-absolute-offset face) + face/extra/over-offset + 10x0)
        ]
        name-field~: fld focus [
            if name-field~/text = target-object-name~ [
                return none
            ]
            either valid-name: validate-word name-field~/text [
                name-field~/text: valid-name
            ] [
                name-field~/text: target-object-name~
                return none
            ]
            window-name: "--voe-window"
            set (to-path reduce [(to-word window-name) 'extra 'current-object-name]) face/text
            modify-source vid-code-test/text target-object-name~ [set-word!] rejoin [face/text ":"]
            target-object-name~: copy face/text
            new-title: rejoin ["VID Object Editor - [" name-field~/text "]"]
            set (to-path reduce [(to-word window-name) 'text]) new-title
            new-window-name: rejoin ["--" "voe-window-" face/text]
            set (to-word new-window-name) (get to-word window-name)
            replace active-voe-windows window-name new-window-name
            append orphaned-voe-windows reduce ["~" new-window-name]
            refresh-results-gui
        ]
        return space 4x4
        style-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Style:" [highlight-field-source~ face]
        style-field~: base font-size voe-font-size left 227.227.227 black voe-fld-size all-over
        space 0x4
        options-style-field~: receive-data-field
        react [
            either type-field~/text <> options-style-field~/text [
                style-field~/text: options-style-field~/text
            ] [
                style-field~/text: "<none>"
            ]
        ]
        dot-btn1~: dot-btn [
            style-obj: get (to-word name-field~/text)
        ]
        query-style-button: dot-btn "?" [
            if all [(style-field~/text <> "<none>") (not stock-style? style-field~/text)] [
                style-parents: get-style-parents style-field~/text vid-code-test/text
                num-parents: length? style-parents
                if num-parents > 1 [
                    style-message: rejoin ["Parents of style: '" style-field~/text "'^/^/" to-string style-parents/1]
                    foreach s (skip style-parents 1) [
                        append style-message rejoin reduce ["  -" to-char 187 "  " (to-string s)]
                    ]
                    request-message style-message
                ]
            ]
        ]
        edit-style-button~: edit-btn voe-edit-icon-size [
            if all [(style-field~/text <> "<none>") (not stock-style? style-field~/text)] [
                the-style: copy style-field~/text
                edit-vid-object/style the-style "vid-code"
            ]
        ]
        return space 4x4
        i-lbl1~: indent-lbl "Type:"
        type-field~: indent-ro-fld
        space 4x10 return
        text-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Text:" [highlight-field-source~ face]
        text-field~: fld on-enter [
            do zero-check~ "text"
            modify-source vid-code-test/text target-object-name~ [string!] text-field~/text
            refresh-results-gui
        ]
        space 0x4
        text-field-multiline~: dot-btn [
            res: request-multiline-text/size/preload/submit/offset rejoin ["Enter a TEXT string for the object named: '" target-object-name~ "'"] voe-multiline-requester-size (to-safe-string text-field~/text) [
                either value? to-word "target-object-name~" [
                    text-field~/text: get-results
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
                modify-source vid-code-test/text target-object-name~ [string!] get-results
                refresh-results-gui
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        space 0x2
        text-zero-btn~: zero-btn on-click [
            modify-source/delete vid-code-test/text target-object-name~ [string!] none
            text-field~/text: none
            refresh-results-gui
            text-field~/text: get-facet-zero-value~ "text"
        ]
        import-to-text-field~: import-btn voe-import-icon-size
        [
            text-field~/text: to-string get to-path reduce [(to-word target-object-name~) 'text]
            modify-source vid-code-test/text target-object-name~ [string!] text-field~/text
            refresh-results-gui
        ]
        with [
            extra/message: "Import text string from live object"
        ]
        space 4x4
        return
        offset-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Offset:" [highlight-field-source~ face]
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
                if verified-input: verify-type pair! offset-field~/text [
                    offset-field~/text: verified-input
                    modify-source vid-code-test/text target-object-name~ [word! "at"] (
                        ((to-safe-pair offset-field~/text) + btn-adjust)
                    )
                ]
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
        draw right-btn-drawing
        up-y-offset-btn~: offset-xy-btn
        with [extra/directions: [0x-1 0x-5]]
        draw up-btn-drawing
        down-y-offset-btn~: offset-xy-btn
        with [extra/directions: [0x1 0x-5]]
        draw down-btn-drawing
        space 1x4
        offset-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [word! "at"] none
            offset-field~/text: ""
            refresh-results-gui
            offset-starting-value: to-string get to-path reduce [to-word target-object-name~ 'offset]
            down-y-offset-btn~/extra/starting-value: up-y-offset-btn~/extra/starting-value: right-x-offset-btn~/extra/starting-value: left-x-offset-btn~/extra/starting-value: offset-starting-value
        ]
        space 0x4
        import-to-offset-field~: import-btn voe-import-icon-size
        [
            offset-field~/text: to-string (get to-path reduce [(to-word target-object-name~) 'offset])
            if offset-field~/text <> "" [
                modify-source vid-code-test/text target-object-name~ [word! "at"] (to-safe-pair offset-field~/text)
                refresh-results-gui
            ]
        ]
        with [
            extra/message: "Import offset value from live object"
        ]
        return
        space 4x4
        size-label~: base "Size:" font-size voe-font-size voe-label-size right 230.230.230 black
        [highlight-field-source~ face]
        on-over []
        extra [original-color: none]
        size-field~: tempered-field font-size voe-font-size
        with [extra/on-change-action: [
            either size-field~/text <> "" [
                either (extra/last-field-value <> size-field~/text) [
                    btn-adjust: 0x0
                    if type-field~/text = "button" [
                        btn-adjust: -2x-2
                    ]
                    if extra/last-field-value <> 'none [
                        modify-source vid-code-test/text target-object-name~ [pair!] (
                            ((to-safe-pair size-field~/text) + btn-adjust)
                        )
                        refresh-results-gui
                    ]
                    extra/last-field-value: size-field~/text
                ] [
                    extra/last-field-value: size-field~/text
                ]
            ] [
                extra/last-field-value: 0
            ]
        ]]
        on-enter [
            either size-field~/text = "" [
                do zero-check~ "size"
                modify-source/delete vid-code-test/text target-object-name~ [pair!] none
            ] [
                if verified-input: verify-type pair! size-field~/text [
                    size-field~/text: verified-input
                    modify-source vid-code-test/text target-object-name~ [pair!] (to-safe-pair size-field~/text)
                ]
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
        size-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [pair!] none
            size-field~/text: none
            size-starting-value: to-string get to-path reduce [to-word target-object-name~ 'size]
            down-y-size-btn~/extra/starting-value: up-y-size-btn~/extra/starting-value: right-x-size-btn~/extra/starting-value: left-x-size-btn~/extra/starting-value: size-starting-value
            size-field~/extra/last-field-value: 'none
            refresh-results-gui
            zero-val: get-facet-zero-value~ "size"
            size-field~/text: zero-val
        ]
        space 4x4
        return
        requester-completed-field~: tempered-field rate 0:00:00.3 hidden 0x0
        with [
            extra/on-change-action: [
                requester-completed?~: true
            ]
        ]
        color-label~: base font-size voe-font-size voe-label-size right 230.230.230 black on-over []
        extra [original-color: none] "Color:" [highlight-field-source~ face]
        color-field~: clr-fld
        on-enter [
            if verified-input: verify-type 'color color-field~/text [
                color-field~/text: verified-input
                modify-source vid-code-test/text target-object-name~ [tuple!] to-safe-tuple color-field~/text
                refresh-results-gui
            ]
        ]
        space 0x4
        color-swatch~: clr-swatch on-up [
            res: request-color
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
        dot-btn2~: dot-btn [
            res: request-color
            if res [
                color-field~/text: to-string res
                color-swatch~/color: to-tuple res
                modify-source vid-code-test/text target-object-name~ [tuple!] to-tuple res
                refresh-results-gui
            ]
        ]
        color-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [tuple!] none
            color-field~/text: none
            refresh-results-gui
            color-field~/text: get-facet-zero-value~ "color"
        ]
        return
        space 4x4
        do [
            lock-to-this-object~: function [
                face [object!]
                obj-name [string!]
                uid [string!]
            ] [
                if dc-locked-on-object <> [] [
                    if obj-name <> dc-locked-on-object/1 [
                        tilde-id: 2
                        locked-face: get to-word rejoin ["target-object-label" dc-locked-on-object/:tilde-id]
                        locked-face/extra/locked?: false
                        locked-face/draw: compose [pen (locked-face/extra/orig-edge) box 0x0 (locked-face/size)]
                    ]
                ]
                face/extra/locked?: true
                face/extra/dbl-clicked?: true
                face/extra/dbl-clicked-time: now/time/precise
                face/draw: compose [line-width 2 pen (face/extra/locked-edge) box 1x1 (face/size - 1x1)]
                voe-menu-handler/lock obj-name "highlight-source-object" reduce [obj-name uid]
            ]
            flip-checkbox~: function [
                face [object!] "ie: options-drag-on-checkbox~ "
                object-name [string!] {ie: "button2"                 }
                id [string!] "ie: rejoin [tilde id-num ]    "
                facet-id [string!] {ie: "options-drag-on"         }
                modifier-block [block!] {ie: [word! "loose" ]          }
                modifier-word [word!] "ie. 'loose                    "
            ] [
                check-action: copy []
                modifier: compose/deep [modify-source/delete vid-code-test/text object-name [(modifier-block)] none]
                label-obj: get to-word rejoin [facet-id "-label" id]
                either face/data [
                    modifier: compose/deep [modify-source vid-code-test/text object-name [(modifier-block)] (to-lit-word modifier-word)]
                    check-action: compose/deep reduce [to-set-path reduce [to-word rejoin [(facet-id) "-checkbox" id] 'data] true]
                ] [
                    if label-obj/color = gray-green [
                        modifier: compose/deep [modify-source vid-code-test/text object-name [(modifier-block)] (to-lit-word modifier-word)]
                        check-action: compose/deep reduce [to-set-path reduce [to-word rejoin [(facet-id) "-checkbox" id] 'data] true]
                    ]
                    if label-obj/color = yellow-green [
                        check-action: compose/deep reduce [to-set-path reduce [to-word rejoin [(facet-id) "-checkbox" id] 'data] true]
                    ]
                ]
                do modifier
                refresh-results-gui
                do check-action
            ]
        ]
        options-drag-on-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        extra [original-color: none] on-over [] "Loose:" [highlight-field-source~ face]
        options-drag-on-gui-field~: ro-fld space 0x4
        options-drag-on-checkbox~: chk false [
            flip-checkbox~ options-drag-on-checkbox~ target-object-name~ "~" "options-drag-on" [word! "loose"] 'loose
        ]
        options-drag-on-field~: ro-fld hidden 0x0
        react [
            options-drag-on-gui-field~/text: to-safe-string options-drag-on-checkbox~/data
        ]
        on-change [
            options-drag-on-checkbox~/data: any [(options-drag-on-field~/text = "down") false]
        ]
        space 4x4 return
        hidden-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Hidden" [highlight-field-source~ face]
        hidden-gui-field~: ro-fld space 0x4
        hidden-checkbox~: chk false [
            flip-checkbox~ hidden-checkbox~ target-object-name~ "~" "hidden" [word! "hidden"] 'hidden
        ]
        hidden-field~: ro-fld hidden 0x0
        react [
            hidden-gui-field~/text: to-safe-string hidden-checkbox~/data
        ]
        on-change [
            hidden-checkbox~/data: any [(hidden-field~/text = "true") false]
        ]
        space 4x4 return
        disabled-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Disabled:" [highlight-field-source face]
        disabled-gui-field~: ro-fld space 0x4
        disabled-checkbox~: chk false [
            flip-checkbox~ disabled-checkbox~ target-object-name~ "~" "disabled" [word! "disabled"] 'disabled
        ]
        disabled-field~: ro-fld hidden 0x0
        react [
            disabled-gui-field~/text: to-safe-string disabled-checkbox~/data
        ]
        on-change [
            disabled-checkbox~/data: any [(disabled-field~/text = "true") false]
        ]
        space 4x4 return
        focus-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Focus:" [highlight-field-source~ face]
        focus-gui-field~: ro-fld space 0x4
        focus-checkbox~: chk false [
            flip-checkbox~ focus-checkbox~ target-object-name~ "~" "focus" [word! "focus"] 'focus
        ]
        focus-field~: ro-fld hidden 0x0
        react [
            focus-gui-field~/text: to-safe-string focus-checkbox~/data
        ]
        on-change [
            focus-checkbox~/data: any [(focus-field~/text = "true") false]
        ]
        space 4x4 return
        flags-all-over-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "All-over:" [highlight-field-source~ face]
        flags-all-over-gui-field~: ro-fld space 0x4
        flags-all-over-checkbox~: chk false [
            flip-checkbox~ flags-all-over-checkbox~ target-object-name~ "~" "flags-all-over" [word! "all-over"] 'all-over
        ]
        flags-all-over-field~: ro-fld hidden 0x0
        react [
            flags-all-over-gui-field~/text: to-safe-string flags-all-over-checkbox~/data
        ]
        on-change [
            flags-all-over-checkbox~/data: any [(flags-all-over-field~/text = "true") false]
        ]
        space 4x4 return
        flags-password-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Password:" [highlight-field-source~ face]
        flags-password-gui-field~: ro-fld space 0x4
        flags-password-checkbox~: chk false [
            flip-checkbox~ flags-password-checkbox~ target-object-name~ "~" "flags-password" [word! "password"] 'password
        ]
        flags-password-field~: ro-fld hidden 0x0
        react [
            flags-password-gui-field~/text: to-safe-string flags-password-checkbox~/data
        ]
        on-change [
            flags-password-checkbox~/data: any [(flags-password-field~/text = "true") false]
        ]
        space 4x4 return
        flags-tri-state-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Tri-state:" [highlight-field-source~ face]
        flags-tri-state-gui-field~: ro-fld space 0x4
        flags-tri-state-checkbox~: chk false [
            flip-checkbox~ flags-tri-state-checkbox~ target-object-name~ "~" "flags-tri-state" [word! "tri-state"] 'tri-state
        ]
        flags-tri-state-field~: ro-fld hidden 0x0
        react [
            flags-tri-state-gui-field~/text: to-safe-string flags-tri-state-checkbox~/data
        ]
        on-change [
            flags-tri-state-checkbox~/data: any [(flags-tri-state-field~/text = "true") false]
        ]
        return
        b1~: base voe-requester-width hidden
    ]
    "Appearance" [
        backdrop 247.247.247
        space 4x4
        para-h-align-label~: base font-size voe-font-size voe-drop-down-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Horiz. Align:" [highlight-field-source~ face]
        para-h-align-drop-down~: drop-dwn data ["left" "center" "right" "<omit>"]
        on-change [
            either face/text = "<omit>" [
                do-actor para-h-align-zero-btn~ none 'click
            ] [
                valid-choices: copy/part face/data 3
                foreach align-str valid-choices [
                    either align-str = face/text [
                        modify-source vid-code-test/text target-object-name~ reduce [word! align-str] (to-word align-str)
                        refresh-results-gui
                    ] [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! align-str] none
                        refresh-results-gui
                    ]
                ]
            ]
        ]
        space 0x4
        para-h-align-field~: field 0x0 hidden
        on-create [
            react [
                para-h-align-drop-down~/selected: index? find ["left" "center" "right" "<omit>"] any [para-h-align-field~/text "<omit>"]
            ]
        ]
        para-h-align-zero-btn~: zero-btn-tall [
            selecting: either (zero-val: get-facet-zero-value~ "para-h-align") [
                index? find ["left" "center" "right" ""] zero-val
            ] [
                4
            ]
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "center"] none
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "left"] none
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "right"] none
            para-h-align-drop-down~/selected: selecting
            refresh-results-gui
        ]
        space 4x4
        return
        para-v-align-label~: base font-size voe-font-size voe-drop-down-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Vert. Align:" [highlight-field-source~ face]
        para-v-align-drop-down~: drop-dwn data ["top" "middle" "bottom" "<omit>"]
        on-change [
            either face/text = "<omit>" [
                do-actor para-v-align-zero-btn~ none 'click
            ] [
                valid-choices: copy/part face/data 3
                foreach align-str valid-choices [
                    either align-str = face/text [
                        modify-source vid-code-test/text target-object-name~ reduce [word! align-str] (to-word align-str)
                        refresh-results-gui
                    ] [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! align-str] none
                        refresh-results-gui
                    ]
                ]
            ]
        ]
        space 0x4
        para-v-align-field~: field 0x0 hidden
        react [
            para-v-align-drop-down~/selected: index? find ["top" "middle" "bottom" "<omit>"] any [para-v-align-field~/text "<omit>"]
        ]
        para-v-align-zero-btn~: zero-btn-tall [
            selecting: either (zero-val: get-facet-zero-value~ "para-v-align") [
                index? find ["top" "middle" "bottom" ""] zero-val
            ] [
                4
            ]
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "top"] none
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "bottom"] none
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "middle"] none
            para-v-align-drop-down~/selected: selecting
            refresh-results-gui
        ]
        space 4x4
        return
        para-wrap?-label~: base font-size voe-font-size voe-drop-down-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Wrap:" [highlight-field-source~ face]
        para-wrap?-drop-down~: drop-dwn data ["wrap" "no-wrap" "<omit>"]
        on-change [
            picked: pick face/data face/selected
            either picked = "<omit>" [
                do-actor para-wrap?-zero-btn~ none 'click
            ] [
                switch picked [
                    "wrap" [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! "no-wrap"] none
                        modify-source vid-code-test/text target-object-name~ reduce [word! "wrap"] 'wrap
                    ]
                    "no-wrap" [
                        modify-source/delete vid-code-test/text target-object-name~ reduce [word! "wrap"] none
                        modify-source vid-code-test/text target-object-name~ reduce [word! "no-wrap"] 'no-wrap
                    ]
                ]
                refresh-results-gui
            ]
        ]
        space 0x4
        para-wrap?-zero-btn~: zero-btn-tall [
            selecting: either (zero-val: get-facet-zero-value~ "para-wrap?") [
                index? find ["wrap" "no-wrap" ""] zero-val
            ] [
                3
            ]
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "wrap"] none
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! "no-wrap"] none
            para-wrap?-drop-down~/selected: selecting
            refresh-results-gui
        ]
        para-wrap?-field~: field 0x0 hidden
        react [
            para-wrap?-drop-down~/selected: index? find ["wrap" "no-wrap" "<omit>"] any [para-wrap?-field~/text "<omit>"]
        ]
        space 4x4 return
        flags-no-border-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "No-border:" [highlight-field-source~ face]
        flags-no-border-gui-field~: ro-fld space 0x4
        flags-no-border-checkbox~: chk false [
            flip-checkbox~ flags-no-border-checkbox~ target-object-name~ "~" "flags-no-border" [word! "no-border"] 'no-border
        ]
        flags-no-border-field~: ro-fld hidden 0x0
        react [
            flags-no-border-gui-field~/text: to-safe-string flags-no-border-checkbox~/data
        ]
        on-change [
            flags-no-border-checkbox~/data: any [(flags-no-border-field~/text = "true") false]
        ]
        space 4x4 return
        options-hint-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "hint:" [highlight-field-source~ face]
        options-hint-field~: fld "" on-enter [
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        options-hint-zero-btn~: zero-btn [
            options-hint-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "hint"] none
            refresh-results-gui
            options-hint-field~/text: get-facet-zero-value~ "options-hint"
        ]
        space 4x4 return
        options-field~: fld "" hidden
    ]
    "Font" [
        backdrop 247.247.247
        space 4x8
        font-name-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Font Name:" [highlight-field-source~ face]
        font-name-field~: fld
        space 0x4
        font-name-dot-btn~: dot-btn [
            either not current-font: get (to-path reduce [(to-word target-object-name~) 'font]) [
                current-font: make object! [
                    name: "Segoe UI"
                    size: 9
                    style: none
                    angle: 0
                    color: none
                    anti-alias?: false
                ]
                compare-font: make object! [
                    name: ""
                    size: 0
                    style: none
                    angle: 0
                    color: none
                    anti-alias?: false
                ]
            ] [
                compare-font: copy current-font
            ]
            new-font: request-font/font current-font
            if new-font = none [return ""]
            font-diff: compare-objects/show-diffs compare-font new-font
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
            foreach i font-diff [
                if fnd: find monitored-font-vals i [
                    new-val: get in new-font (to-lit-word i)
                    do reduce fnd/2
                ]
            ]
        ]
        font-name-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [word! "font-name"] none
            font-name-field~/text: none
            refresh-results-gui
            font-name-field~/text: get-facet-zero-value~ "font-name"
        ]
        space 4x4
        return
        font-size-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Font Size:" [highlight-field-source~ face]
        font-size-field~: tempered-field voe-x-fld-size font-size voe-font-size
        with [
            extra/on-change-action: [
                either font-size-field~/text <> "" [
                    either (face/extra/last-field-value <> font-size-field~/text) [
                        valid-size: either (face/extra/last-field-value = 'none)
                        [
                            9
                        ] [
                            to-valid-font-size to-safe-integer font-size-field~/text
                        ]
                        style-font-size: 0
                        if all [
                            (style-field~/text <> "<none>")
                            (not stock-style? style-field~/text)
                            (face/extra/last-field-value = 'none)
                        ] [
                            style-name: copy style-field~/text
                            set (to-word style-name) get-object-from-source style-name vid-code-test/text
                            style-font: get to-path reduce [(to-word style-name) 'font]
                            if style-font <> none [
                                valid-size: style-font/size
                            ]
                        ]
                        either face/extra/last-field-value <> 'none [
                            modify-source vid-code-test/text target-object-name~ [word! "font-size"] valid-size
                            if (to-string valid-size <> font-size-field~/text) [
                                font-size-field~/text: to-string valid-size
                            ]
                            refresh-results-gui
                        ] [
                        ]
                        face/extra/last-field-value: font-size-field~/text
                    ] [
                        face/extra/last-field-value: font-size-field~/text
                    ]
                ] [
                    face/extra/last-field-value: 0
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
        font-size-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [word! "font-size"] none
            font-size-field~/text: none
            font-size-field~/extra/last-field-value: font-size-field~/text: get-facet-zero-value~ "font-size"
            refresh-results-gui
        ]
        font-size-starting-value-field~: receive-data-field
        on-change [
            left-x-font-size-btn~/extra/starting-value: right-x-font-size-btn~/extra/starting-value: to-safe-integer font-size-starting-value-field~/text
        ]
        space 4x4
        return
        font-color-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Font Color:" [highlight-field-source~ face]
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
            res: request-color
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
        font-color-dot-btn~: dot-btn [
            res: request-color
            if res [
                font-color-field~/text: to-string res
                font-color-swatch~/color: to-tuple res
                modify-source vid-code-test/text target-object-name~ [word! "font-color"] to-tuple res
                refresh-results-gui
            ]
        ]
        font-color-zero-btn~: zero-btn [
            font-color-field~/text: none
            font-color-swatch~/color: 128.128.128
            modify-source/delete vid-code-test/text target-object-name~ [word! "font-color"] none
            refresh-results-gui
            font-color-field~/text: get-facet-zero-value~ "font-color"
        ]
        space 4x4 return
        font-bold-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Bold:" [highlight-field-source~ face]
        font-bold-gui-field~: ro-fld space 0x4
        font-bold-checkbox~: chk false [
            flip-checkbox~ font-bold-checkbox~ target-object-name~ "~" "font-bold" [word! "bold"] 'bold
        ]
        font-bold-field~: ro-fld hidden 0x0
        react [
            font-bold-gui-field~/text: to-safe-string font-bold-checkbox~/data
        ]
        on-change [
            font-bold-checkbox~/data: any [(font-bold-field~/text = "true") false]
        ]
        space 4x4 return
        font-italic-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Italic:" [highlight-field-source face]
        font-italic-gui-field~: ro-fld space 0x4
        font-italic-checkbox~: chk false [
            flip-checkbox~ font-italic-checkbox~ target-object-name~ "~" "font-italic" [word! "italic"] 'italic
        ]
        font-italic-field~: ro-fld hidden 0x0
        react [
            font-italic-gui-field~/text: to-safe-string font-italic-checkbox~/data
        ]
        on-change [
            font-italic-checkbox~/data: any [(font-italic-field~/text = "true") false]
        ]
        space 4x4 return
        font-underline-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Underline:" [highlight-field-source~ face]
        font-underline-gui-field~: ro-fld space 0x4
        font-underline-checkbox~: chk false [
            flip-checkbox~ font-underline-checkbox~ target-object-name~ "~" "font-underline" [word! "underline"] 'underline
        ]
        font-underline-field~: ro-fld hidden 0x0
        react [
            font-underline-gui-field~/text: to-safe-string font-underline-checkbox~/data
        ]
        on-change [
            font-underline-checkbox~/data: any [(font-underline-field~/text = "true") false]
        ]
        space 4x4 return
        font-strike-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Strike:" [highlight-field-source~ face]
        font-strike-gui-field~: ro-fld space 0x4
        font-strike-checkbox~: chk false [
            flip-checkbox~ font-strike-checkbox~ target-object-name~ "~" "font-strike" [word! "strike"] 'strike
        ]
        font-strike-field~: ro-fld hidden 0x0
        react [
            font-strike-gui-field~/text: to-safe-string font-strike-checkbox~/data
        ]
        on-change [
            font-strike-checkbox~/data: any [(font-strike-field~/text = "true") false]
        ]
        space 4x4 return
        font-anti-alias?-label~: base font-size voe-font-size voe-drop-down-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Anti-Alias?:" [highlight-field-source~ face]
        font-anti-alias?-drop-down~: drop-dwn data ["true" "false" "'ClearType" "<omit>"]
        on-change [
            modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "font"] none
            switch (pick face/data face/selected) [
                "true" [
                    modify-source vid-code-test/text target-object-name~ reduce [word! "font"] [anti-alias?: true]
                ]
                "false" [
                    do-actor font-anti-alias?-zero-btn~ none 'click
                ]
                "'ClearType" [
                    modify-source vid-code-test/text target-object-name~ reduce [word! "font"] [anti-alias?: 'ClearType]
                ]
                "<omit>" [
                    do-actor font-anti-alias?-zero-btn~ none 'click
                ]
            ]
            refresh-results-gui
        ]
        space 0x4
        font-anti-alias?-zero-btn~: zero-btn-tall on-click [
            font-anti-alias?-drop-down~/selected: none
            modify-source/delete vid-code-test/text target-object-name~ reduce ['word! "font"] none
            refresh-results-gui
            selecting: either (zero-val: get-facet-zero-value~ "font-anti-alias?") [
                index? find ["true" "false" "ClearType" ""] zero-val
            ] [
                zero-val: "<omit>"
                4
            ]
            font-anti-alias?-field~/text: zero-val
            font-anti-alias?-drop-down~/selected: selecting
        ]
        font-anti-alias?-field~: field 0x0 hidden
        react [
            either font-anti-alias?-field~/text = "" [
                font-anti-alias?-drop-down~/selected: none
            ] [
                font-anti-alias?-drop-down~/selected: index? find ["true" "" "ClearType" "<omit>"] any [font-anti-alias?-field~/text "<omit>"]
            ]
        ]
    ]
    "Graphics" [
        backdrop 247.247.247
        space 4x4
        image-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Image:" [highlight-field-source~ face]
        image-field~: fld ""
        on-enter [
            modify-source vid-code-test/text target-object-name~ [file!] (to-valid-file image-field~/text)
            image-field~/text: mold to-valid-file image-field~/text
            refresh-results-gui
        ]
        space 0x4
        image-file-requester~: dot-btn [
            image-dir: either image-field~/text = "" [
                to-red-file get-current-dir
            ] [
                to-valid-file image-field~/text
            ]
            res: request-file/title/file "Select an image file" image-dir
            if res [
                modify-source vid-code-test/text target-object-name~ [file!] (to-valid-file res)
                image-field~/text: mold to-valid-file res
                refresh-results-gui
            ]
        ]
        image-zero-btn~: zero-btn [
            image-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [file!] none
            refresh-results-gui
            image-field~/text: get-facet-zero-value~ "image"
        ]
        space 4x4
        return
        draw-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Draw Block:" [highlight-field-source~ face]
        space 0x4
        draw-left-bracket~: fld-bracket "["
        gui-draw-field~: fld no-border 160 "" on-enter [
            modify-source vid-code-test/text target-object-name~ [word! "draw"] (to-block gui-draw-field~/text)
            refresh-results-gui
        ]
        draw-right-bracket~: fld-bracket "]"
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        draw-zero-btn~: zero-btn [
            gui-draw-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "draw"] none
            refresh-results-gui
            z: get-facet-zero-value~ "draw"
            draw-field~/text: mold/only get-facet-zero-value~ "draw"
        ]
        return
        space 0x0
        b2~: base white 350x4 return
        b3~: base black 350x2 return
        b4~: base white 350x4 return
        space 4x4
        t1~: text font-size 12 "PANEL / TAB-PANEL / GROUP-BOX" 350 center
        return
        layout-block-label~: base "Layout Block:" font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] [highlight-field-source~ face]
        space 0x4
        layout-left-bracket~: fld-bracket "["
        gui-layout-block-field~: fld no-border 160 ""
        on-enter [
            either any [
                type-field~/text = "panel"
                type-field~/text = "tab-panel"
                type-field~/text = "group-box"
            ] [
                modify-source vid-code-test/text target-object-name~ [block!] (to-block gui-layout-block-field~/text)
                refresh-results-gui
            ] [
                gui-layout-block-field~/text: copy ""
                request-message/size {The 'Layout Block' can only be used for VID Objects:^/1.) panel^/2.) tab-panel^/3.) group-box} 400
            ]
        ]
        layout-right-bracket~: fld-bracket "]"
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        layout-block-zero-btn~: zero-btn [
            gui-layout-block-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [block!] none
            refresh-results-gui
            layout-zero: get-facet-zero-value~ "layout-block"
            gui-layout-block-field~/text: de-block-string mold layout-zero
        ]
        return
        space 0x0
        b5~: base white 350x4 return
        b6~: base black 350x2 return
        b7~: base white 350x4 return
    ]
    "Data etc." [
        backdrop 247.247.247
        space 4x4
        data-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Data:" [highlight-field-source~ face]
        gui-data-field~: fld ""
        on-enter [
            either gui-data-field~/text = "" [
                do-actor data-zero-btn~ none 'click
            ] [
                process-data-field~ gui-data-field~/text
            ]
        ]
        on-create [
            process-data-field~: func [
                val
                /not-gui-source
            ] [
                valid-value: string-to-valid-type val
                switch/default to-string type? valid-value [
                    "block" [
                        clear-data-fields-group~/except ["selected-field" "data-field"]
                    ]
                    "date" [
                        clear-data-fields-group~/except ["date-field" "data-field"]
                    ]
                    "percent" [
                        clear-data-fields-group~/except ["percent-field" "data-field"]
                    ]
                    "logic" [
                        clear-data-fields-group~/except ["true-false-field" "data-field"]
                    ]
                ] [
                    clear-data-fields-group~/except ["data-field"]
                ]
                modify-action: switch/default (to-string type? valid-value) [
                    "logic" [
                        true-false-field~/text: to-string valid-value
                        [modify-source vid-code-test/text target-object-name~ reduce [word! to-string valid-value] valid-value]
                    ]
                    "date" [
                        date-field~/text: to-string valid-value
                        [modify-source vid-code-test/text target-object-name~ [date!] valid-value]
                    ]
                    "percent" [
                        percent-field~/text: to-string valid-value
                        [modify-source vid-code-test/text target-object-name~ [percent!] valid-value]
                    ]
                ] [
                    [modify-source vid-code-test/text target-object-name~ [word! "data"] valid-value]
                ]
                either not-gui-source [
                    gui-data-field~/text: either valid-value = "" [""] [mold valid-value]
                ] [
                    do modify-action
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        data-zero-btn~: zero-btn [
            clear-data-fields-group~/except ["selected-field"]
            modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none
            modify-source/delete vid-code-test/text target-object-name~ [word! "true"] none
            modify-source/delete vid-code-test/text target-object-name~ [word! "false"] none
            refresh-results-gui
            new-zero: get-facet-zero-value~ "data"
            data-field~/text: either block? new-zero [mold new-zero] [new-zero]
            process-data-field~/not-gui-source data-field~/text
        ]
        space 4x4
        return
        selected-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Select:" [highlight-field-source~ face]
        selected-field~: fld ""
        on-enter [
            clear-data-fields-group~/except ["selected-field" "data-field"]
            either (selected-field~/text = "") [
                modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none
            ] [
                modify-source vid-code-test/text target-object-name~ [word! "select"] (to-integer selected-field~/text)
            ]
            refresh-results-gui
        ]
        b8~: base hidden voe-missing-dot-btn-size
        selected-zero-btn~: zero-btn [
            selected-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none
            refresh-results-gui
            selected-field~/text: get-facet-zero-value~ "selected"
        ]
        return
        sgl1~: select-gap-line
        sdl1~: select-divider-line
        return
        true-false-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "True/False:" [highlight-field-source~ face]
        true-false-drop-down~: drop-dwn data ["true" "false" "<omit>"]
        on-change [
            true-false-field-select~ face
        ]
        on-create [
            do [
                true-false-field-select~: func [
                    face
                    /with face-text [string!]
                    /local selected-item valid-states logic-state
                ] [
                    selected-item: either with [
                        face-text
                    ] [
                        face/text
                    ]
                    clear-data-fields-group~/except ["true-false-field"]
                    valid-states: copy/part face/data 2
                    foreach logic-state valid-states [
                        either logic-state = selected-item [
                            modify-source vid-code-test/text target-object-name~ reduce [word! logic-state] (to-word logic-state)
                            gui-data-field~/text: copy logic-state
                        ] [
                            modify-source/delete vid-code-test/text target-object-name~ reduce [word! logic-state] none
                        ]
                    ]
                    if any [
                        (selected-item = "")
                        (selected-item = "<omit>")
                    ] [
                        do-actor data-zero-btn~ none 'click
                        return ""
                    ]
                    refresh-results-gui
                ]
            ]
        ]
        true-false-field~: field 0x0 hidden
        react [
            true-false-drop-down~/selected: either any [
                (true-false-field~/text = "")
                (true-false-field~/text = none)
            ] [
                none
            ] [
                index? find ["true" "false" "<omit>"] true-false-field~/text
            ]
        ]
        b9~: base hidden voe-true-false-spacer
        true-false-zero-btn~: zero-btn [
            true-false-field-select~/with true-false-drop-down~ ""
        ]
        space 4x4
        return
        date-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Date:" [highlight-field-source~ face]
        date-field~: fld "" on-enter [
            if date-field~/text = "" [
                do-actor data-zero-btn~ none 'click
                return ""
            ]
            either (first scan/next date-field~/text) = date! [
                valid-date: load date-field~/text
                clear-data-fields-group~/except ["date-field"]
                date-field~/text: to-string valid-date
                gui-data-field~/text: to-string valid-date
                modify-source vid-code-test/text target-object-name~ [date!] valid-date
                refresh-results-gui
            ] [
                request-message {The date value entered is not in the correct format.^/Try one of the following formats:^/yyyy-mmm-dd^/dd-mmm-yyyy^/dd-mmm-yy^/mm/dd/yyyy^/dd-<full-month-name>-yyyy}
            ]
        ]
        space 0x4
        date-field-requester~: dot-btn [
            either date-field~/text = "" [
                pre-date: now/date
            ] [
                pre-date: to-valid date! date-field~/text
            ]
            res: request-date/set-date pre-date
            if res [
                date-field~/text: to-string res
                clear-data-fields-group~/except ["date-field"]
                gui-data-field~/text: to-string res
                modify-source vid-code-test/text target-object-name~ [date!] (to-valid date! date-field~/text)
                refresh-results-gui
            ]
        ]
        date-zero-btn~: zero-btn [
            do-actor data-zero-btn~ none 'click
        ]
        space 4x4
        return
        percent-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Percent:" [highlight-field-source~ face]
        percent-field~: fld "" on-enter [
            if percent-field~/text = "" [
                do-actor data-zero-btn~ none 'click
                return ""
            ]
            field-type: first scan/next face/text
            either any [(field-type = percent!) (field-type = float!) (field-type = integer!)] [
                valid-percent: to-percent load face/text
                clear-data-fields-group~/except ["percent-field"]
                face/text: to-string valid-percent
                gui-data-field~/text: to-string valid-percent
                modify-source vid-code-test/text target-object-name~ [percent!] valid-percent
                refresh-results-gui
            ] [
                request-message/size {The percent value entered is not in the correct format.^/For example, fifty percent can be entered in one of two formats:^/^/^-1.)  50%^/^-2.)  .50} 500x200
            ]
        ]
        b10~: base hidden voe-missing-dot-btn-size
        percent-zero-btn~: zero-btn [
            do-actor data-zero-btn~ none 'click
        ]
        return
        dl1~: data-hline
        return
        space 4x4
        options-default-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Default String:" [highlight-field-source~ face]
        options-default-field~: fld "" on-enter [
            if options-default-field~/text = "" [
                do-actor options-default-zero-btn~ none 'click
                return ""
            ]
            modify-source vid-code-test/text target-object-name~ [word! "default"] options-default-field~/text
            refresh-results-gui
        ]
        space 0x4
        options-default-field-multiline~: dot-btn [
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        options-default-zero-btn~: zero-btn [
            clear options-default-field~/text
            modify-source/delete vid-code-test/text target-object-name~ [word! "default"] none
            refresh-results-gui
            options-default-field~/text: get-facet-zero-value~ "options-default"
        ]
        return
        space 4x4
        extra-label~: base "Extra:" font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] [highlight-field-source~ face]
        extra-field~: fld "" on-enter [
            process-extra-field~ extra-field~/text
        ]
        on-create [
            process-extra-field~: func [val] [
                if extra-field~/text = "" [
                    do-actor extra-zero-btn~ none 'click
                    return ""
                ]
                valid-value: string-to-valid-type val
                value-type: type? valid-value
                modify-source vid-code-test/text target-object-name~ [word! "extra"] to value-type valid-value
                refresh-results-gui
            ]
        ]
        space 0x4
        extra-field-multiline~: dot-btn [
            res: request-multiline-text/size/preload/submit/offset
            rejoin ["Enter EXTRA DATA for the object named: '" target-object-name~ "'. Include square brackets if defining a block."]
            voe-multiline-requester-size to-safe-string
            extra-field~/text
            [
                either value? to-word "target-object-name~" [
                    extra-field~/text: get-results
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
                process-extra-field~ extra-field~/text
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        extra-zero-btn~: zero-btn [
            extra-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "extra"] none
            refresh-results-gui
            facet-zero-value: get-facet-zero-value~ "extra"
            extra-field~/text: either block? facet-zero-value [mold facet-zero-value] [facet-zero-value]
        ]
        space 4x4
        return
        with-label~: base "With Block:" font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] [highlight-field-source~ face]
        space 0x4
        with-block-left-bracket~: fld-bracket "["
        gui-with-field~: fld no-border "" 160 on-enter [
            if gui-with-field~/text = "" [
                do-actor with-zero-btn~ none 'click
                return ""
            ]
            modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text)
            refresh-results-gui
        ]
        with-field~: receive-data-field on-change [
            gui-with-field~/text: de-block-string with-field~/text
        ]
        with-block-right-bracket~: fld-bracket "]"
        with-field-multiline~: dot-btn [
            res: request-multiline-text/size/preload/submit/offset
            rejoin ["Enter WITH DATA value for the object named: '" target-object-name~ "'. All data entered is placed in a block."]
            voe-multiline-requester-size
            to-safe-string gui-with-field~/text
            [
                either value? to-word "target-object-name~" [
                    gui-with-field~/text: de-block-string get-results
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
                modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text)
                refresh-results-gui
            ]
            (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
            if res [
                either (value? to-word "target-object-name~") [
                    with-field~/text: to-string res
                    modify-source vid-code-test/text target-object-name~ [word! "with"] (to-block gui-with-field~/text)
                    refresh-results-gui
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
            ]
        ]
        with-zero-btn~: zero-btn [
            gui-with-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "with"] none
            with-field~/text: either (zero-val: get-facet-zero-value~ "with") = [] [
                ""
            ] [
                either block? zero-val [mold zero-val] [zero-val]
            ]
            refresh-results-gui
        ]
        space 4x4
        return
        rate-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "Rate:" [highlight-field-source~ face]
        rate-field~: fld "" on-enter [
            if rate-field~/text = "" [
                do-actor rate-zero-btn~ none 'click
                return ""
            ]
            modify-source vid-code-test/text target-object-name~ [word! "rate"] (to-time rate-field~/text)
            refresh-results-gui
        ]
        b11~: base hidden voe-missing-dot-btn-size
        rate-zero-btn~: zero-btn [
            rate-field~/text: none
            modify-source/delete vid-code-test/text target-object-name~ [word! "rate"] none
            refresh-results-gui
            rate-field~/text: get-facet-zero-value~ "rate"
        ]
        space 4x4
        return
        url-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "URL:" [highlight-field-source~ face]
        url-field~: fld "" on-enter [
            if url-field~/text = "" [
                do-actor url-zero-btn~ none 'click
                return ""
            ]
            modify-source vid-code-test/text target-object-name~ [url!] (to-url url-field~/text)
            refresh-results-gui
        ]
        space 0x4
        url-field-multiline~: dot-btn [
            res: request-multiline-text/size/preload/submit/offset rejoin ["Enter the URL for the object named: '" target-object-name~ "'"] voe-multiline-requester-size to-safe-string url-field~/text
            [
                either value? to-word "target-object-name~" [
                    url-field~/text: get-results
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
                modify-source vid-code-test/text target-object-name~ [url!] url-field~/text
                refresh-results-gui
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
            if res [
                either (value? to-word "target-object-name~") [
                    url-field~/text: to-string res
                    modify-source vid-code-test/text target-object-name~ [url!] url-field~/text
                    refresh-results-gui
                ] [
                    request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                    return none
                ]
            ]
        ]
        url-zero-btn~: zero-btn [
            url-field~/text: copy ""
            modify-source/delete vid-code-test/text target-object-name~ [url!] none
            refresh-results-gui
            url-field~/text: get-facet-zero-value~ "url"
        ]
        at 6x11 data-diagram~: base 68x185 transparent draw :data-drawing
    ]
    "Actions" [
        space 4x4
        b20~: button "Create Default Action" bold font-size 12 102.168.152.0 center green 61.174.71.0 [
            the-obj-type: either style-field~/text = "timer" [
                to-word "timer"
            ] [
                to-word type-field~/text
            ]
            modify-action-line~/create-line/with-focus (select dc-default-action-list the-obj-type) []
        ]
        b21~: button "Create Any Action" bold font-size 12 102.168.152.0 center green 61.174.71.0 [
            if (
                picked: request-list/size/one-click "Pick an action.<one-click>" dc-actor-list 300x300
            ) [
                modify-action-line~/create-line/with-focus picked []
            ]
        ]
        return
        apl1~: action-panel-line
        return
        t2~: text font-size 12 "List of Current Actions " voe-action-header-size center
        return
        apl2~: action-panel-line
        return
        actors-on-created-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-created" (copy to-block face/text)]
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
        actors-on-detect-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-detect" (copy to-block face/text)]
        actors-on-drawing-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-drawing" (copy to-block face/text)]
        actors-on-ime-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-ime" (copy to-block face/text)]
        actors-on-scroll-field~: receive-data-field on-change [receive-action-line~/with-code/no-focus "on-scroll" (copy to-block face/text)]
        action-panel~: panel voe-action-panel-size snow []
    ]
    "React" [
        backdrop 247.247.247
        space 4x4
        react-label~: base font-size voe-font-size voe-label-size right 230.230.230 black
        on-over [] extra [original-color: none] "React Block:" [highlight-field-source~ face]
        space 0x4
        fb1~: fld-bracket "["
        gui-react-field~: fld no-border "" on-enter [
            modify-source vid-code-test/text target-object-name~ [word! "react"] (to-block gui-react-field~/text)
            refresh-results-gui
        ]
        fb2~: fld-bracket "]"
        react-field~: receive-data-field on-change [
            gui-react-field~/text: mold/only load react-field~/text
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
            ] (--voe-window/offset + (to-pair reduce [--voe-window/size/x 0]) + 2x0)
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
        react-zero-btn~: zero-btn [
            modify-source/delete vid-code-test/text target-object-name~ [word! "react"] none
            gui-react-field~/text: none
            react-field~/text: mold get-facet-zero-value~ "react"
            refresh-results-gui
        ]
    ]
]    do [
    active-actions: copy []
    current-layout: copy []
    return-needed?: false
    action-list~: copy []
    action-data~: copy []
    action-deleted~: none
    receive-action-line~: function [
        action-name [string!]
        /init
        /with-code action-code
        /no-focus
        /extern current-layout return-needed? action-list~ requester-completed?~
    ] [
        action-code: action-code/1
        tilde-id: get-voe-window-uid target-object-name~
        source-obj: get to-word src-obj: rejoin ["actors-" action-name "-field" tilde-id]
        if with-code [
        ]
        x: requester-completed?~
        either (value? to-word "requester-completed?~") [
            either requester-completed?~ [
                modify-action-line~/update-line action-name action-code
            ] [
                create-action-line~/with-code/no-focus action-name action-code
            ]
        ] [
            create-action-line~/with-code/no-focus action-name action-code
        ]
    ]
    clear-all-actions~: function [
        /extern action-list~ action-data~
    ] [
        action-list~: copy []
        action-data~: copy []
    ]
    create-action-line~: function [
        action-name [string!]
        /init
        /with-code action-code
        /no-focus
        /extern current-layout return-needed? action-list~ res
    ] [
        if with-code [
        ]
        if init [
            return-needed?: false
            current-layout: copy [
                style action-lbl: base font-size voe-font-size voe-label-size right 230.230.230 black [highlight-field-source~ face] on-over [] extra [original-color: none]
                style action-fld: field no-border voe-action-fld-size font-size voe-font-size
                extra [on-tab-away: []]
                style action-fld-bracket: text "[" bold voe-fld-bracket-size 255.255.255 center middle font-size voe-font-size
                style action-dot-btn: button "..." font-size voe-font-size voe-dot-btn-size
                style x-btn: button bold gray red font-size voe-font-size voe-dot-btn-size "X"
                space 4x4
            ]
            action-panel~/pane: layout/only current-layout
            return none
        ]
        the-code: either with-code [copy action-code] [[]]
        append current-layout compose/deep [
            (either return-needed? ['return] [])
            space 4x4
            (to-set-word rejoin ["actors-" action-name "-label~"]) action-lbl (rejoin [action-name ":"])
            space 0x4
            action-fld-bracket "["
            (to-set-word rejoin ["-actors-" action-name "-field~:"]) action-fld (mold/only the-code)
            on-enter [
                modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block face/text
                modify-action-line~ (action-name) to-block face/text
                refresh-results-gui
                set-focus (to-word rejoin ["-actors-" action-name "-field~:"])
            ]
            extra [
                on-tab-away: [
                    do-actor face none 'enter
                    return 'stop
                ]
            ]
            action-fld-bracket "]"
            space 0x4
            (to-set-word rejoin [action-name "-dots~:"]) action-dot-btn
            [
                res: request-multiline-text/size/preload/submit/offset (rejoin ["Enter the Red code for '" action-name "' action"]) voe-multiline-requester-size
                (to-path reduce [to-word rejoin ["-actors-" action-name "-field~"] 'text])
                [
                    either value? to-word "target-object-name~" [
                        (to-set-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text]) to-string get-results
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                        return none
                    ]
                    modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block
                    (
                        to-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text]
                    )
                    modify-action-line~ (action-name) to-block (to-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text])
                    refresh-results-gui
                ] (to-paren {--voe-window/offset + (to-pair reduce [ --voe-window/size/x 0] ) + 2x0})
                if res [
                    either value? to-word "target-object-name~" [
                        (to-set-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text]) to-string res
                        modify-source vid-code-test/text target-object-name~ [word! (action-name)] to-block
                        (
                            to-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text]
                        )
                        modify-action-line~ (action-name) to-block (to-path reduce [(to-word rejoin ["-actors-" action-name "-field~"]) 'text])
                        refresh-results-gui
                    ] [
                        request-message {The 'VID Object Editor' has been closed,^/rendering this text editor unusable.^/Any changes made have been lost.^/Please close this text editor and^/open the 'VID Object Editor' again.}
                        return none
                    ]
                ]
            ]
            space 0x4
            (to-set-word rejoin [action-name "-zero-btn~:"]) x-btn [modify-action-line~/delete-line (action-name) []]
        ]
        if not find action-list~ action-name [
            append action-list~ action-name
        ]
        action-panel~/pane: layout/only current-layout
        save-all-actions~
        return-needed?: true
        if not no-focus [
            set-focus get (to-word rejoin ["-actors-" action-name "-field~"])
        ]
    ]
    modify-action-line~: function [
        action-name [string!]
        code [block!]
        /create-line
        /delete-line
        /update-line
        /with-focus
        /no-run "Stops run-and-save-changes"
        /extern action-list~ action-data~ action-deleted~
    ] [
        either update-line [
            either (fnd: select action-data~ action-name) [
                either fnd = code [
                    return none
                ] [
                    change fnd code
                ]
            ] [
                append action-data~ reduce [action-name code]
            ]
        ] [
            save-all-actions~
        ]
        if delete-line [
            remove/part find action-data~ action-name 2
            remove find action-list~ action-name
            action-deleted~: copy action-name
            modify-source/delete vid-code-test/text target-object-name~ reduce [word! action-name] ""
            if not no-run [
                refresh-results-gui
            ]
            zero-val: get-facet-zero-value~ rejoin ["actors-" action-name]
            if zero-val <> [] [
                code: to-block zero-val
                create-line: true
            ]
        ]
        if create-line [
            either find action-list~ action-name [
                return none
            ] [
                append action-data~ reduce [action-name code]
            ]
        ]
        create-action-line~/init ""
        either (action-data~ = []) [
            action-panel~/pane: layout/only current-layout
        ] [
            foreach [the-action-name the-action-code] action-data~ [
                either the-action-code <> "" [
                    either all [with-focus (the-action-name = action-name)] [
                        create-action-line~/with-code the-action-name the-action-code
                    ] [
                        create-action-line~/with-code/no-focus the-action-name the-action-code
                    ]
                ] [
                ]
            ]
        ]
        if not no-run [
            refresh-results-gui
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
    save-all-actions~: function [/extern action-list~ action-data~] [
        action-data~: copy []
        foreach action-line action-list~ [
            append action-data~ reduce [action-line to-block to-safe-string (get to-path reduce [to-word rejoin ["-actors-" action-line "-field~"] 'text])]
        ]
    ]
    extra: [
        target-object-name: "~"
        current-object-name: ""
        original-window-name: "--voe-window"
    ]
    requester-completed?~: false
    run-and-save-changes~: does [
        either value? to-word "requester-completed?~" [
            if requester-completed?~ [
                run-and-save "evo-requester"
                highlight-styled-fields~/refresh/id "run-and-save-changes~"
                update-downstream-voe target-object-name~
            ]
        ] [
        ]
    ]
    clear-voe-fields: func [unique-num] [
        vid-object-editor-fields: [
            name-field type-field text-field offset-field size-field color-field
            color-swatch options-drag-on-field options-drag-on-checkbox hidden-gui-field
            hidden-field disabled-gui-field disabled-field flags-tri-state-field
            flags-tri-state-checkbox focus-gui-field focus-checkbox
            focus-field flags-password-field flags-password-checkbox
            options-hint-field flags-all-over-field flags-all-over-checkbox
            para-h-align-drop-down para-v-align-drop-down para-wrap?-drop-down
            font-name-field font-size-field font-color-field
            font-color-swatch font-bold-field font-italic-field
            font-underline-field font-strike-field
            font-strike-field font-anti-alias?-field image-field
            draw-field data-field selected-field
            true-false-drop-down options-default-field extra-field rate-field
            with-field date-field percent-field url-field
            react-field
        ]
        foreach fld vid-object-editor-fields [
            fld-name: to-path reduce [(to-word rejoin [fld unique-num]) 'text]
            set fld-name copy ""
        ]
    ]
    clear-data-fields-group~: func [
        /except exception-block [block!]
    ] [
        if except [
        ]
        exception-block: any [exception-block []]
        if not find exception-block "data-field" [
            clear gui-data-field~/text
            modify-source/delete vid-code-test/text target-object-name~ [word! "data"] none
        ]
        if not find exception-block "selected-field" [
            modify-source/delete vid-code-test/text target-object-name~ [word! "select"] none
            clear selected-field~/text
        ]
        if not find exception-block "true-false-field" [
            modify-source/delete vid-code-test/text target-object-name~ [word! "true"] none
            true-false-field~/text: copy ""
            true-false-drop-down~/text: copy ""
        ]
        if not find exception-block "date-field" [
            clear date-field~/text
            modify-source/delete vid-code-test/text target-object-name~ [date!] none
        ]
        if not find exception-block "percent-field" [
            modify-source/delete vid-code-test/text target-object-name~ [percent!] none
            clear percent-field~/text
        ]
    ]
    disable-label: function ['object] [
        set (to-set-path reduce [object 'font 'color]) 195.195.195
    ]
    disable-object: function ['object] [
        obj: get object
        obj/enabled?: false
    ]
    disable-unneeded-facets: function [
        object-type [word!]
    ] [
        unneeded-facets: [
            base [tri-state password no-border hint layout-block select true-false date percent default-string]
            text [tri-state password no-border hint image draw-block layout-block select true-false date percent default-string]
            rich-text [tri-state password no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false date percent default-string]
            button [tri-state password wrap no-border hint draw-block layout-block select true-false date percent default-string]
            check [password wrap no-border hint image draw-block layout-block select date percent default-string]
            radio [tri-state password wrap no-border hint image draw-block layout-block select date percent default-string]
            field [tri-state wrap image draw-block layout-block select true-false date percent]
            area [tri-state password hint image draw-block layout-block select true-false date percent default-string]
            text-list [text tri-state password halign valign wrap no-border hint image draw-block layout-block true-false date percent default-string]
            drop-list [text tri-state password halign valign wrap no-border hint image draw-block layout-block true-false date percent default-string]
            drop-down [text tri-state password halign valign wrap no-border hint image draw-block layout-block true-false date percent default-string]
            toggle [tri-state password wrap no-border hint image draw-block layout-block select date percent default-string]
            progress [text tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false date default-string]
            slider [text tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false date default-string]
            image [tri-state password no-border hint draw-block layout-block select true-false date percent default-string]
            calendar [tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false percent default-string]
            camera [tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false date percent default-string]
            panel [text tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block select true-false date percent default-string]
            group-box [tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block select true-false date percent default-string]
            tab-panel [text tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block select true-false date percent default-string]
            scroller [text tri-state password halign valign wrap no-border hint font-name font-size font-color bold italic underline strike anti-alias? image draw-block layout-block select true-false date default-string]
            style [offset]
        ]
        unneeded: select unneeded-facets object-type
        disable-voe-lines unneeded "~"
    ]
    voe-lines: [
        text [
            text-label
            text-field
            text-field-multiline
            text-zero-btn
            import-to-text-field
        ]
        password [
            flags-password-label
            flags-password-field
            flags-password-checkbox
        ]
        hint [
            options-hint-label
            options-hint-field
            hint-field-multiline
            options-hint-zero-btn
        ]
        tri-state [
            flags-tri-state-label
            flags-tri-state-checkbox
        ]
        halign [
            para-h-align-label
            para-h-align-drop-down
            para-h-align-zero-btn
        ]
        valign [
            para-v-align-label
            para-v-align-drop-down
            para-v-align-zero-btn
        ]
        wrap [
            para-wrap?-label
            para-wrap?-drop-down
            para-wrap?-zero-btn
        ]
        no-border [
            flags-no-border-label
            flags-no-border-field
            flags-no-border-checkbox
        ]
        font-name [
            font-name-label
            font-name-field
            font-name-dot-btn
            font-name-zero-btn
        ]
        font-size [
            font-size-label
            font-size-field
            left-x-font-size-btn
            right-x-font-size-btn
            font-size-zero-btn
        ]
        font-color [
            font-color-label
            font-color-field
            font-color-swatch
            font-color-dot-btn
            font-color-zero-btn
        ]
        bold [
            font-bold-label
            font-bold-field
        ]
        italic [
            font-italic-label
            font-italic-field
        ]
        underline [
            font-underline-label
            font-underline-field
            font-underline-field
        ]
        strike [
            font-strike-label
            font-strike-field
        ]
        anti-alias? [
            font-anti-alias?-label
            font-anti-alias?-field
        ]
        image [
            image-label
            image-field
            image-file-requester
            image-zero-btn
        ]
        draw-block [
            draw-label
            draw-left-bracket
            draw-right-bracket
            gui-draw-field
            draw-field-multiline
            draw-zero-btn
        ]
        layout-block [
            layout-block-label
            layout-left-bracket
            layout-right-bracket
            gui-layout-block-field
            layout-block-field
            layout-block-field-multiline
            layout-block-zero-btn
        ]
        select [
            selected-label
            selected-field
            selected-zero-btn
        ]
        true-false [
            true-false-label
            true-false-drop-down
            true-false-zero-btn
        ]
        date [
            date-label
            date-field
            date-field-requester
            date-zero-btn
        ]
        percent [
            percent-label
            percent-field
            percent-zero-btn
        ]
        default-string [
            options-default-label
            options-default-field
            options-default-field-multiline
            options-default-zero-btn
        ]
        offset [
            offset-label
            offset-field
            left-x-offset-btn
            right-x-offset-btn
            up-y-offset-btn
            down-y-offset-btn
            offset-zero-btn
            import-to-offset-field
        ]
    ]
    highlight-styled-fields~: function [
        /refresh
        /id id-string
    ] [
        if id [
        ]
        if all [
            (style-field~/text <> none)
            (style-field~/text <> "<none>")
            (not stock-style? style-field~/text)
        ] [
            highlight-styled-fields/id/:refresh style-field~/text target-object-name~ "~" vid-code-test/text "hilight-tilde"
        ]
    ]
    highlight-styled-fields: function [
        {wrapper that serves the tilde version for this VOE requester}
        style-name
        object-name
        unique-id [string!]
        source-code [string!]
        /id source-id
        /refresh "refresh styled fields after a field change"
        /extern voe-lines style-fields
    ] [
        if id [
        ]
        root-object-style: first get-style-parents/root style-name source-code
        field-origins: copy source-to-view-fields/id/origins (copy object-name) (to-word style-name) source-code "~" root-object-style
        hi-fields: get-field-origins field-origins object-name
        append hi-fields [style-label 2 style-field 2]
        foreach [fld status] hi-fields [
            new-color: pick reduce [230.230.230 gray-green yellow-green] status
            if (copy/part tail (to-string fld) -6) = "-label" [
                fld-obj: get to-word rejoin [fld unique-id]
                convert-to-button fld-obj
            ]
            set (fld-chg: to-set-path reduce [(to-word rejoin [fld unique-id]) 'color]) new-color
        ]
        if refresh [
            pos: back tail hi-fields
            forever [
                remove pos
                if ((index? pos) < 3) [break]
                pos: back back pos
            ]
            remaining-fields: exclude get-styled-labels hi-fields
            foreach fld remaining-fields [
                set (z: to-set-path reduce [(to-word rejoin [fld unique-id]) 'color]) 230.230.230
            ]
        ]
    ]
    get-field-origins: function [
        origin-data [block!]
        object-name [string!]
    ] [
        just-object: 1
        just-style: 2
        collected: copy []
        collected: collect [
            foreach [key val] origin-data [
                object-flag: 0
                style-flag: 0
                foreach field-val val [
                    either field-val/2 = (to-word object-name) [
                        object-flag: just-object
                    ] [
                        style-flag: just-style
                    ]
                ]
                keep reduce [(to-word rejoin [key "-label"]) (object-flag + style-flag)]
            ]
        ]
        if fnd: find collected 'offset-label [remove/part fnd 2]
        return collected
    ]
    disable-voe-lines: function [
        line-ids [block!]
        unique-id [string!]
        /extern voe-lines
    ] [
        foreach line-id line-ids [
            line-list: select voe-lines line-id
            obj-name: to-word rejoin [(first line-list) unique-id]
            disable-label :obj-name
            line-list: copy skip line-list 1
            foreach obj-name line-list [
                obj-name: to-word rejoin [obj-name unique-id]
                disable-object :obj-name
            ]
        ]
    ]
    label-to-origin: [
        ["Text" "text"]
        ["Offset" "offset"]
        ["Size" "size"]
        ["Color" "color"]
        ["Loose" "options-drag-on"]
        ["Hidden" "hidden"]
        ["Disabled" "disabled"]
        ["Focus" "focus"]
        ["All-over" "flags-all-over"]
        ["Password" "flags-password"]
        ["Tri-state" "flags-tri-state"]
        ["Horiz. align" "para-h-align"]
        ["Vert. Align" "para-v-align"]
        ["Wrap" "para-wrap?"]
        ["No-border" "flags-no-border"]
        ["Hint" "options-hint"]
        ["Font Name" "font-name"]
        ["Font Size" "font-size"]
        ["Font Color" "font-color"]
        ["Bold" "font-bold"]
        ["Italic" "font-italic"]
        ["Underline" "font-underline"]
        ["Strike" "font-strike"]
        ["Anti-alias?" "font-anti-alias?"]
        ["Image" "image"]
        ["Draw Block" "draw"]
        ["Layout Block" "layout-block"]
        ["Data" "data"]
        ["Select" "selected"]
        ["True/False" "true-false"]
        ["Date" "date"]
        ["Percent" "percent"]
        ["Default String" "options-default"]
        ["Extra" "extra"]
        ["With Block" "with"]
        ["Rate" "rate"]
        ["URL" "url"]
        ["React Block" "react"]
    ]
    highlight-field-source~: function [face] [
        if face/color <> 230.230.230 [
            label-text: copy face/text
            either any [(label-text = "Style:") (label-text = "Parent Style:")] [
                style-origin: copy style-field~/text
            ] [
                remove back tail label-text
                facet: either ((copy/part label-text 3) = "on-") [
                    rejoin ["actors-" label-text]
                ] [
                    second (find-in-array-at label-to-origin 1 label-text)
                ]
                style-origin: get-facet-zero-value~/origin/sorted facet
                style-origin: to-string second first style-origin
            ]
            voe-menu-handler style-origin "highlight-source-object"
        ]
    ]
    source-to-view-fields: function [
        "v3 from %edit-vid-object.red"
        object-name [string!]
        object-type [word!]
        source-code [string!]
        /id identifier
        /origins root-object-name [word!]
        /sorted "sort the origins field youngest to oldest"
        /refresh
    ] [
        if id [
        ]
        if origins [
        ]
        object-source: get-object-source object-name source-code
        if not origins [
            root-object-name: object-type
        ]
        orig-obj-data: source-to-data/root-object to-block object-source root-object-name
        object-data: copy orig-obj-data
        object-style: select-in-object (to-word object-name) [options style]
        append object-data compose/deep [
            name: [(object-name)]
            options-style: [(object-style)]
        ]
        facet-origins: reduce [copy object-data]
        if not stock-style? object-style [
            either sorted [
                style-parents: reverse (get-style-parents (to-string object-style) source-code)
            ] [
                style-parents: (get-style-parents (to-string object-style) source-code)
            ]
            foreach style-word style-parents [
                style-data: source-to-data/root-object to-block (get-object-source (to-string style-word) source-code) object-type
                append facet-origins reduce [copy style-data]
                object-data: union/skip (copy style-data) object-data 2
            ]
        ]
        if origins [
            collated-origins: collate-facet-origins facet-origins
            return collated-origins
        ]
        object-data: union/skip orig-obj-data object-data 2
        starting-offset: select-in-object (to-word object-name) 'offset
        starting-size: select-in-object (to-word object-name) 'size
        put object-data 'type reduce [object-type]
        object-data/options-style: reduce [object-style]
        append object-data compose/deep [
            offset-starting-value: [(starting-offset)]
            size-starting-value: [(starting-size)]
        ]
        foreach [key value] object-data [
            value: first value
            field-name: rejoin [key "-field" identifier]
            switch/default to-string (type? value) [
                "logic" [
                    set (to-path reduce [to-word field-name 'text]) to-safe-string value
                ]
                "block" [
                    only: false
                    if (copy/part (to-string key) 10) = "actors-on-" [
                        field-actors: get to-path reduce [(to-word field-name) 'actors]
                        if not (in field-actors 'on-change) [
                            only: true
                        ]
                    ]
                    set (to-path reduce [to-word field-name 'text]) (mold/:only value)
                ]
                "file" [
                    set (to-path reduce [to-word field-name 'text]) (mold/only value)
                ]
                "pair" [
                    adj-val: 0x0
                    if object-type = 'button [
                        if key = 'offset [adj-val: -1x-1]
                        if key = 'size [adj-val: 2x2]
                    ]
                    value: value + adj-val
                    if all [(key = 'size) (refresh)] [
                        set (to-path reduce [to-word field-name 'extra 'last-field-value]) 'none
                    ]
                    set (to-path reduce [to-word field-name 'text]) (to-string value)
                ]
            ] [
                if refresh [
                    if (to-string key) = "font-size" [
                        set (to-path reduce [to-word field-name 'extra 'last-field-value]) 'none
                    ]
                ]
                set (to-path reduce [to-word field-name 'text]) (to-string value)
            ]
        ]
        requester-complete-field: to-word rejoin ["requester-completed-field" identifier]
        set (to-path reduce [requester-complete-field 'text]) "DONE"
    ]
    collate-facet-origins: function [facet-data] [
        remove/part (find facet-data/1 (to-set-word "options-style")) 2
        replace facet-data/1 (to-set-word "name") (to-set-word "options-style")
        facet-data/1/options-style/1: (to-word first facet-data/1/options-style)
        reverse/skip facet-data/1 2
        collected: copy []
        foreach facet facet-data [
            foreach [key val] facet [
                if key = to-set-word "type" [
                    continue
                ]
                If key = (to-set-word "options-style") [
                    origin-name: first copy val
                    continue
                ]
                if fnd: find collected key [
                    value: either (block? first val) [
                        val
                    ] [
                        first val
                    ]
                    append fnd/2 compose/deep [
                        [(value) (origin-name)]
                    ]
                    continue
                ]
                value: either (block? first val) [
                    val
                ] [
                    first val
                ]
                insert collected compose/deep [
                    (key) [[(value) (origin-name)]]
                ]
            ]
        ]
        return collected
    ]
    get-facet-zero-value~: function [
        field-name [string!]
        /origin
        /sorted
    ] [
        style-name: style-field~/text
        if all [(style-name <> "<none>") (not stock-style? style-name)] [
            root-object-style: to-word type-field~/text
            field-origins: source-to-view-fields/id/origins/:sorted target-object-name~ (to-word style-name) vid-code-test/text "~" root-object-style
            if found: select field-origins (to-set-word field-name) [
                if origin [
                    return found
                ]
                obj-style: to-string second last found
                if obj-style = name-field~/text [
                    return none
                ]
                ret-val: first last found
                return switch/default (to-string type? ret-val) [
                    "pair" [
                        object-type: get to-path reduce [(to-word target-object-name~) 'type]
                        either all [(object-type = 'button) (field-name = "size")] [
                            to-string (ret-val + 2x2)
                        ] [
                            to-string ret-val
                        ]
                    ]
                    "block" [
                        ret-val
                    ]
                    "file" [
                        mold ret-val
                    ]
                ] [
                    (to-string ret-val)
                ]
            ]
        ]
        if any [
            (find ["draw" "react" "with" "layout-block"] field-name)
            ((copy/part field-name 10) = "actors-on-")
        ]
        [
            return []
        ]
        return ""
    ]
    zero-check~: function [
        {Will use <field-name>-field as the data field^/                 and will use <field-name>-zero-btn as the actor if needed}
        field-prefix-name [string!]
    ] [
        field-obj: get field-obj-name: to-word rejoin [field-prefix-name "-field~"]
        if field-obj/text = "" [
            zero-btn-obj: get zero-btn-name: to-word rejoin [field-prefix-name "-zero-btn~"]
            do-actor zero-btn-obj none 'click
            return [return ""]
        ]
        return []
    ]
    re-arm-action-fields: function [
        object-name [string!]
        action-list [block!]
    ] [
        tilde-id: get-voe-window-uid object-name
        foreach action action-list [
            actor-field: get to-word actor-field-name: rejoin ["actors-" action "-field" tilde-id]
            paren-val: to-paren [copy to-block face/text]
            fun-path: to-path reduce [to-word rejoin ["receive-action-line" tilde-id] 'with-code 'no-focus]
            on-change-block: compose/deep [
                on-change: func [[trace] face [object!] event [event! none!]]
                [
                    (fun-path) (action) (paren-val)
                ]
            ]
            actor-on-change: object :on-change-block
            actor-field/actors: make actor-field/actors actor-on-change
        ]
    ]
    refresh-voe~: function [
        object-name [string!]
        object-type [word!]
        source-code [string!]
        tilde-id [string!]
        /delete-action deleted-action [string! none!]
        /extern requester-completed?~
    ] [
        clear-voe-fields tilde-id
        source-to-view-fields/id/refresh object-name object-type source-code tilde-id
        if all [
            delete-action
            deleted-action
        ] [
            modify-action-line-tilde: get to-word rejoin ["modify-action-line" tilde-id]
            modify-action-line-tilde/delete-line/no-run deleted-action []
        ]
        do to-path reduce [to-word (rejoin ["highlight-styled-fields" tilde-id]) 'refresh]
        requester-completed?~: true
    ]
    get-downstream-objects: function [
        source-object [string!]
        target-objects [block!]
    ] [
        all-parents: collect [
            foreach obj-name target-objects [
                style-parents: get-style-parents obj-name vid-code/text
                either none? style-parents [
                    keep []
                ] [
                    if (length? style-parents) > 1 [
                        keep reduce [style-parents]
                    ]
                ]
            ]
        ]
        downstream: collect [
            foreach entry all-parents [
                if (fnd: find entry to-lit-word source-object) [
                    if (fnd-item: to-string last fnd) <> source-object [
                        keep fnd-item
                    ]
                ]
            ]
        ]
        return downstream
    ]
    set 'update-downstream-voe function [
        object-name [string!]
        /only "Just check the object-name specified"
        /extern action-deleted~
    ] [
        either only [
            downstream: reduce [object-name]
        ] [
            target-objects: collect [
                foreach i active-voe-windows [
                    keep copy skip i 13
                ]
            ]
            downstream: get-downstream-objects object-name target-objects
        ]
        foreach obj-name downstream [
            obj-type: get to-path reduce [(to-word obj-name) 'type]
            win-name: copy rejoin ["--" "voe-window-" obj-name]
            if find active-voe-windows win-name [
                win-info: (get to-path reduce [to-word win-name 'extra])
                tilde-id: win-info/target-object-name
                refresh-voe~/delete-action obj-name obj-type vid-code/text win-info/target-object-name action-deleted~
            ]
        ]
    ]
] ;-- End of do block 
] ;-- End of view block 
