Red [
	Title: "edit-vid-object.red"
	Comment: "Imported from: <root-path>%experiments/edit-vid-object/edit-vid-object.red"
]
voe-window-cleanup: function [
    window-name [string!]
    unique-id [string!]
    /extern active-voe-windows orphaned-voe-windows dc-locked-on-object
] [
    target-object-label: copy (get to-path reduce [(to-word rejoin ["target-object-label~" unique-id]) 'text])
    style-text: copy (get to-path reduce [(to-word rejoin ["style-field~" unique-id]) 'text])
    if any [
        (target-object-label = "Style Name:")
        all [(style-text <> "<none>") (not stock-style? style-text)]
    ] [
        case [
            (target-object-label = "Style Name:") [
                custom-style-name: copy (get to-path reduce [(to-word rejoin ["name-field~" unique-id]) 'text])
            ]
            (style-text <> "<none>") [
                custom-style-name: copy (get to-path reduce [(to-word rejoin ["style-field~" unique-id]) 'text])
            ]
        ]
        style-parents: get-style-parents custom-style-name vid-code/text
        if (target-object-label = "Style Name:") [
            unset-object to-word custom-style-name
        ]
    ]
    unset-uid-vars unique-id
    if fnd: find active-voe-windows window-name [
        remove fnd
    ]
    if orphan: find orphaned-voe-windows rejoin ["~" unique-id] [
        if win-fnd: find active-voe-windows (first next orphan) [
            remove win-fnd
        ]
        remove/part orphan 2
    ]
    unset to-word window-name
]
edit-vid-object: function [
    obj-name [string!] "Object name you want to edit"
    src-code-widget-name [string!] "This is the name of the area conatining the code"
    /left-edge
    /style
    /quiet
    /extern target-object-name~ source-code-widget-name refresh-results-gui
    --voe-window active-voe-windows dc-voe-layout-template-data dc-voe-layout-template-file
] [
    uwin-string: unique-window-name: rejoin ["--voe-window-" obj-name]
    object-menu: [
        "Object" [
            {Set as Insertion Point                               F3} highlight-source-object
            "Lock-On to Object as Insertion Point    F4" lock-to-object
            {Unset Insertion Point                               ESC} un-highlight-source-object
            "____________________________________" none
            {Delete                           Ctrl + Shift + Minus Key} delete-object
            "Duplicate to Insertion Point" duplicate-object
            "Convert to Style" convert-object-to-style
            "Re-run 'setup-style'" re-run-setup-style
            "Copy to Clipboard" copy-object-to-clip
            "Highlight GUI Object" highlight-gui-object
            "Save Image of Object" save-object-image
        ]
        "Position" [
            {Insert 'return' before object          Ctrl + Shift + Enter} insert-return-before
            {Remove 'return' before object      Ctrl + Shift + Backspace} remove-return-before
            "_____________________________" none
            "Move to Insertion Point              F2" move-object
            "_____________________________" none
            {Move to START of boundary      Ctrl + Shift + Up Arrow} move-to-beginning
            {Move Object Ahead 1                Ctrl + Shift + Right Arrow} move-forward-1
            "Move Object Ahead 2" move-forward-2
            "Move Object Ahead 3" move-forward-3
            "Move Object Ahead 4" move-forward-4
            {Move Object  Back 1                  Ctrl + Shift + Left Arrow} move-back-1
            "Move Object  Back 2" move-back-2
            "Move Object  Back 3" move-back-3
            "Move Object  Back 4" move-back-4
            {Move to END of boundary        Ctrl + Shift + Down Arrow} move-to-end
        ]
        "Window" [
            "Position" [
                "Move to Left Edge" move-to-left-edge
            ]
            "Tab" [
                "Save Tab Position" open-to-this-tab
            ]
            "Font" [
                "Regular Font" voe-regular-font
                "Large Font" voe-large-font
            ]
        ]
    ]
    style-menu: [
        "Style" [
            "Highlight Source Code" highlight-source-object
            "Copy to Clipboard" copy-object-to-clip
            "Create 'setup-style'" insert-setup-style
            "Add to 'Style Catalog'" add-to-style-catalog
        ]
        "Window" [
            "Position" [
                "Move to Left Edge" move-to-left-edge
            ]
            "Tab" [
                "Save Tab Position" open-to-this-tab
            ]
            "Font" [
                "Regular Font" voe-regular-font
                "Large Font" voe-large-font
            ]
        ]
    ]
    either find active-voe-windows unique-window-name [
        if not quiet [
            target-object-name: get to-path reduce [to-word rejoin ["--voe-window-" obj-name] 'extra 'target-object-name]
            set to-path reduce [to-word unique-window-name 'color] complement get to-path reduce [to-word unique-window-name 'color]
            wait 0:00:00.1
            set to-path reduce [to-word unique-window-name 'color] complement get to-path reduce [to-word unique-window-name 'color]
            set-focus get to-word rejoin ["name-field" target-object-name]
        ]
        return none
    ] [
    ]
    target-object-name~: copy obj-name
    voe-target-object-name: copy target-object-name~
    source-code-widget-name: copy src-code-widget-name
    voe-layout-template: copy dc-voe-layout-template-data
    uid: get-uid
    replace/all voe-layout-template "~" rejoin ["~" uid]
    replace/all voe-layout-template "vid-code-test/text" rejoin [source-code-widget-name "/text"]
    replace voe-layout-template "awidget" obj-name
    if (last split-path current-file) <> %edit-vid-code.red [
        replace/all voe-layout-template "refresh-results-gui" rejoin ["run-and-save-changes~" uid]
    ]
    replace/all voe-layout-template "refresh-gui" ""
    replace/all voe-layout-template "voe-target-object-name" (mold obj-name)
    replace/all voe-layout-template "--voe-window" unique-window-name
    either style [
        the-source: get to-path reduce [(to-word src-code-widget-name) 'text]
        make-style-global (to-lit-word obj-name) the-source
        replace voe-layout-template {title "VID Object Editor"} rejoin [{title "VID Style: [} obj-name {]"}]
        replace voe-layout-template {"Object Name:"} {"Style Name:"}
        replace voe-layout-template "backdrop snow" "backdrop gray-green"
        window-menu: copy style-menu
    ] [
        window-menu: copy object-menu
        object-style: select-in-object (to-word obj-name) [options style]
        either not stock-style? object-style [
            replace voe-layout-template {title "VID Object Editor"} rejoin [{title "VID Object: [} obj-name "] Style: [" object-style {]"}]
        ] [
            replace voe-layout-template {title "VID Object Editor"} rejoin [{title "VID Object : [} obj-name {]"}]
        ]
    ]
    voe-layout: load voe-layout-template
    unique-object-name: to-word rejoin ["target-object-name~" uid]
    set unique-object-name obj-name
    either dc-voe-size = "regular" [
        regular-voe
    ] [
        large-voe
    ]
    unique-window-name: to-word unique-window-name
    set unique-window-name layout voe-layout
    window-size: get to-path reduce [unique-window-name 'size]
    screen-size: system/view/screens/1/size
    at-screen-bottom-offset: to-pair reduce [390 (screen-size/y - window-size/y - 81)]
    at-window-bottom-offset: to-pair reduce [390 (--dc-mainwin-edge/y + 50)]
    calc-offset: min at-screen-bottom-offset at-window-bottom-offset
    win-offset: either active-voe-windows <> [] [
        last-win: last active-voe-windows
        last-win-offset: get to-path reduce [to-word last-win 'offset]
        last-win-size: get to-path reduce [to-word last-win 'size]
        new-win-offset: last-win-offset + to-pair reduce [last-win-size/x 0]
        new-win-offset
    ] [
        either left-edge [
            to-pair reduce [6 calc-offset/y]
        ] [
            calc-offset
        ]
    ]
    voe-window-offset: compose [offset: (win-offset)]
    append active-voe-windows uwin-string
    set to-path reduce [unique-window-name 'menu] window-menu
    view/no-wait/options get unique-window-name
    requester-window-escape/options compose/deep [
        unview/only (unique-window-name)
        voe-window-cleanup (to-string unique-window-name) (uid)
    ] obj-name voe-window-offset
]
tilde: to-char 126
source-code-widget-name: "vid-code-test"
target-object-name~: copy "amazing"
voe-target-object-name: copy "amazing"
text-field-string: copy target-object-name~
object-label-name: rejoin [" " target-object-name~]
first-face-name: to-set-word rejoin ["first-face-" target-object-name~]
widget-name: "awidget"
source-code-widget: "vid-code-test"
refresh-results-gui: does [
    either error? err: try/all [
        if vid-code-test/text [
            example-output/pane: layout/only load vid-code-test/text
        ]
        true
    ] [
        print {*** ERROR WITH WIDGET ****************************************}
        print err
        print {*********************************************************************************}
    ] []
    highlight-styled-fields~/refresh/id "refresh-results-gui"
]
set 'large-voe does [
    voe-font-size: 13
    voe-label-size: 110x24
    voe-indent-label-size: 140x24
    voe-chk-size: 15x19
    voe-true-false-spacer: 11x19
    voe-zero-btn-size: 24x24
    voe-missing-zero-btn-size: 26x4
    voe-xy-btn-size: 24x24
    voe-clr-swatch-size: 26x25
    voe-clr-field-size: 154x25
    voe-fld-size: 180x24
    voe-indent-fld-size: 150x24
    voe-xy-fld-size: 105x24
    voe-x-fld-size: 155x24
    voe-action-fld-size: 145x24
    voe-fld-bracket-size: 12x25
    voe-dot-btn-size: 24x24
    voe-missing-dot-btn-size: 18x4
    voe-large-dot-btn-size: 30x24
    voe-import-icon-size: 20x24
    voe-edit-icon-size: 18x24
    voe-drop-down-font-size: 11
    voe-anti-alias-drop-down-font-size: 9
    voe-drop-down-size: 180x15
    voe-anti-alias-drop-down-size: 180x12
    voe-drop-down-label-size: 110x26
    voe-action-panel-size: 344x325
    voe-hline-size: 344x2
    voe-select-hline-size: 232x2
    voe-select-gap-line-size: 110x2
    voe-data-hline-size: 346x2
    voe-action-header-size: 344
    import-icon-image: import-icon-image-large
    edit-icon-image: edit-icon-large
    zero-icon-image: zero-icon-image-large
    zero-icon-image-tall: zero-icon-image-large-tall
    voe-multiline-requester-size: 700x400
    voe-requester-width: 357x0
    data-drawing: [
        pen red
        line 10x12 10x138
        line 10x12 60x12
        line 60x12 49x8
        line 60x12 49x16
        line 10x78 25x78
        line 10x107 65x107
        line 10x138 45x138
    ]
    left-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 24x0 24x24 0x24 0x0
        pen black
        line-width 2
        line 5x12 19x5
        line 5x12 19x19
    ]
    right-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 24x0 24x24 0x24 0x0
        pen black
        line-width 2
        line 19x12 5x5
        line 19x12 5x19
    ]
    up-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 24x0 24x24 0x24 0x0
        pen black
        line-width 2
        line 12x5 5x19
        line 12x5 19x19
    ]
    down-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 24x0 24x24 0x24 0x0
        pen black
        line-width 2
        line 12x19 5x5
        line 12x19 19x5
    ]
]
set 'regular-voe does [
    voe-font-size: 9
    voe-label-size: 80x19
    voe-indent-label-size: 110x19
    voe-chk-size: 13x19
    voe-true-false-spacer: 9x19
    voe-zero-btn-size: 19x19
    voe-missing-zero-btn-size: 21x4
    voe-xy-btn-size: 19x19
    voe-clr-swatch-size: 26x19
    voe-clr-field-size: 154x19
    voe-fld-size: 180x19
    voe-indent-fld-size: 150x19
    voe-xy-fld-size: 120x19
    voe-x-fld-size: 160x19
    voe-action-fld-size: 180x19
    voe-fld-bracket-size: 12x19
    voe-dot-btn-size: 19x19
    voe-missing-dot-btn-size: 13x4
    voe-large-dot-btn-size: 30x19
    voe-import-icon-size: 20x19
    voe-edit-icon-size: 18x19
    voe-drop-down-font-size: 9
    voe-anti-alias-drop-down-font-size: 8
    voe-drop-down-size: 180x17
    voe-anti-alias-drop-down-size: 180x17
    voe-drop-down-label-size: 80x22
    voe-action-panel-size: 344x250
    voe-hline-size: 344x2
    voe-select-hline-size: 222x2
    voe-select-gap-line-size: 80x2
    voe-data-hline-size: 306x2
    voe-action-header-size: 344
    voe-multiline-requester-size: 700x330
    import-icon-image: import-icon-image-small
    edit-icon-image: edit-icon-small
    zero-icon-image: zero-icon-image-small
    zero-icon-image-tall: zero-icon-image-small-tall
    voe-requester-width: 357x0
    data-drawing: [
        pen red
        line 12x10 12x116
        line 12x10 50x10
        line 50x10 40x6
        line 50x10 40x14
        line 12x66 25x66
        line 12x91 48x91
        line 12x116 35x116
    ]
    up-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 19x0 19x19 0x19 0x0
        pen black
        line-width 2
        line 9x5 4x15
        line 9x5 15x15
    ]
    down-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 19x0 19x19 0x19 0x0
        pen black
        line-width 2
        line 9x15 4x5
        line 9x15 15x5
    ]
    right-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 19x0 19x19 0x19 0x0
        pen black
        line-width 2
        line 15x9 4x5
        line 15x9 4x15
    ]
    left-btn-drawing: [
        line-width 1
        pen 155.155.155
        line 0x0 19x0 19x19 0x19 0x0
        pen black
        line-width 2
        line 4x9 15x5
        line 4x9 15x15
    ]
]
large-voe
voe-backdrop-color: snow
