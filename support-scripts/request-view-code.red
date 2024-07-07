Red [
	Title: "request-view-code.red"
	Comment: "Imported from: <root-path>%experiments/request-view-code/request-view-code.red"
]
request-view-code: func [
    source-code [string!]
] [
    return-value: none 
    view/flags request-view-code-layout: compose [
        title "Window Configuration" 
        style rvc-check: check 
        on-change [
            update-code source-code-area
        ] 
        style group-heading: h5 underline center 
        style label-inline: text 230.230.230 font-color 0.0.0 right middle 
        style button-info: base 17x18 info-icon 
        extra [
            now-over?: 0 
            message: "" 
            box: 1
        ] 
        on-over [
            either event/away? [
                face/extra/now-over?: 0 
                face/image/rgb: complement face/image/rgb 
                show face 
                popup-help/close ""
            ] [
                if face/extra/now-over? = 0 [
                    face/image/rgb: complement face/image/rgb 
                    show face 
                    face/extra/now-over?: 1 
                    box: either face/extra/box = 0 [
                        false
                    ] [
                        true
                    ] 
                    popup-help/offset/:box face/extra/message (face/parent/offset + face/offset + event/offset + 20x20)
                ]
            ]
        ] 
        with [
            extra/message: ""
        ] 
        style base-box-outline: base 120x86 240.240.240 
        on-created [
            box-size: to-pair reduce [(face/size/x - 1) (face/size/y - 1)] 
            face/draw: compose/deep [
                pen 200.200.200 line-width 1 
                box 1x1 (box-size)
            ]
        ] 
        below 
        space 2x4 
        across 
        at 4x8 base-box-outline1: base-box-outline 195x123 
        at 4x135 base-box-outline2: base-box-outline 195x80 
        at 209x9 base-box-outline3: base-box-outline 165x250 
        h5 "        Refinements         " underline 
        return 
        tight-check: rvc-check "/tight" 
        button-info with [
            extra/message: "Zero offset and origin"
        ] 
        return 
        below 
        across 
        no-wait-check: rvc-check "/no-wait" 
        button-info with [
            extra/message: "Return immediately - do not wait"
        ] 
        return 
        below 
        across 
        no-sync-check: rvc-check "/no-sync" 
        button-info with [
            extra/message: "Requires `show` calls to refresh faces"
        ] 
        return 
        return 
        below 
        space 2x8 
        group-heading "            Options             " 
        across 
        label-inline "Offset:" 
        offset-field: field 80x24 
        extra [on-tab-away [update-code source-code-area]] 
        on-enter [update-code source-code-area] 
        button-info with [
            extra/message: {Offset position of window relative to the top left corner of the screen}
        ] 
        space 8x4 
        below 
        return 
        space 4x4 
        group-heading "     Flags       " 
        resize-check: rvc-check "resize" 
        no-title-check: rvc-check "no-title" 
        no-border-check: rvc-check "no-border" 
        no-min-check: rvc-check "no-min" 
        no-max-check: rvc-check "no-max" 
        no-buttons-check: rvc-check "no-buttons" 
        modal-check: rvc-check "modal" 
        popup-check: rvc-check "popup" 
        return 
        space 1x9 
        box 10x23 
        button-info with [
            extra/message: { enable window resizing (default is fixed size, not resizeable).}
        ] 
        button-info with [
            extra/message: "do not display a window's text title"
        ] 
        button-info with [
            extra/message: "remove window’s frame decorations"
        ] 
        button-info with [
            extra/message: "remove minimize button from window’s drag bar"
        ] 
        button-info with [
            extra/message: "remove maximize button from window’s drag bar"
        ] 
        button-info with [
            extra/message: "remove all buttons from window’s drag bar"
        ] 
        button-info with [
            extra/message: {makes the window modal, disabling all previously opened windows}
        ] 
        button-info with [
            extra/message: {alternative smaller frame decoration (Windows only)}
        ] 
        space 10x4 
        across 
        return 
        return 
        base1: base 500x1 font-color 255.255.255 
        return 
        h4-1: h5 "Generated 'view' Code" 
        return 
        source-code-area: area 500x97 wrap font-name "Consolas" font-size 10 (source-code) 
        on-create [
            update-gui face/text
        ] 
        on-focus [
            set-focus offset-field
        ] 
        return 
        across 
        button1: button "   OK    " 
        on-click [
            return-value: source-code-area/text 
            unview
        ] 
        box1: box 356x20 
        button2: button "Cancel" [return-value: none unview]
    ] [
        modal
    ] 
    return return-value
] 
do [
    window-flags: [resize no-title no-border no-min no-max no-buttons modal popup] 
    refinement-list: [tight no-wait no-sync] 
    get-checked-boxes: func [
        "Collect check boxes that are true" 
        check-names [block!] {Block of words identifying the root name of check boxes. Full check-box name expands to <check-name>-check: }
    ] [
        result-block: copy [] 
        foreach check-name check-names [
            if get to-path reduce [to-word rejoin [check-name "-check"] 'data] [
                alter result-block check-name
            ]
        ] 
        return result-block
    ] 
    set-check-box: func [
        check-name [word!] "The name of the check box to set" 
        check-names [block!] {Block of words identifying the root name of check boxes. Full check-box name expands to <check-name>-check: }
    ] [
        if find check-names check-name [
            set to-path reduce [to-word rejoin [check-name "-check"] 'data] true
        ]
    ] 
    set-flag-check: func [
        flag [word!]
    ] [
        if find window-flags flag [
            set to-path reduce [to-word rejoin [flag "-check"] 'data] true
        ]
    ] 
    set-refine-check: func [
        refiner [word!]
    ] [
        if find refinement-list refiner [
            set to-path reduce [to-word rejoin [refiner "-check"] 'data] true
        ]
    ] 
    update-code: func [
        code-area [object!]
    ] [
        flag-list: get-checked-boxes window-flags 
        refine-list: get-checked-boxes refinement-list 
        view-data: query-view-code code-area/text 
        original-source: view-data/1 
        view-data: view-data/2 
        call-string: 1 
        refinements: 2 
        layout-name: 3 
        arg-blocks: 4 
        view-refinements: copy "view" 
        block-args: copy [] 
        if all [(offset-field/text <> none) (offset-field/text <> "")] [
            append view-refinements "/options" 
            append block-args reduce [reduce [(to-set-word 'offset) (to-pair offset-field/text)]]
        ] 
        if flag-list <> [] [
            append view-refinements "/flags" 
            append block-args reduce [flag-list]
        ] 
        foreach refiner refine-list [
            append view-refinements rejoin ["/" refiner]
        ] 
        layout-name: view-data/:layout-name 
        new-call-string: rejoin [view-refinements " " layout-name] 
        foreach arg block-args [
            append new-call-string rejoin [" " mold arg]
        ] 
        replace code-area/text original-source new-call-string
    ]
] 
update-gui: func [
    view-code [string!]
] [
    view-data: query-view-code view-code 
    view-data: view-data/2 
    view-cmd: 1 
    refinements: 2 
    layout-name: 3 
    arg-blocks: 4 
    view-block-args: view-data/:arg-blocks 
    if options-data: select view-block-args 'options [
        if offset-val: select options-data 'offset [
            offset-field/text: to-string offset-val
        ]
    ] 
    if flags-list: select view-block-args 'flags [
        foreach flag flags-list [
            set-check-box flag window-flags
        ]
    ] 
    if refine-list: view-data/:refinements [
        foreach refine refine-list [
            set-check-box refine refinement-list
        ]
    ]
]
