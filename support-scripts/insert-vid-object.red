Red [
	Title: "insert-vid-object.red"
	Comment: "Imported from: <root-path>%experiments/insert-vid-object/insert-vid-object.red"
]
set 'clear-vid-code-selected does [
    vid-code/selected: none
    selected-object-field/text: dc-default-selected-object-string
    selected-object-label/color: dc-default-selected-object-label-color
]
set 'insert-vid-object function [
    {V2 .Inserts a given object type into the current layout. By default "insert-before" selected object or at end of vid-code script.}
    obj-type [string! word!] {Object type that determines object naming prefix as well}
    target-object [string! none!] {Object name to use as reference point""}
    /with-on-click on-click-code [block!]
    /with-text text-string [string!]
    /with-offset offset-pos [pair!]
    /style style-name [string!]
    /named named-object [string!] "Custom object name prefix"
    /pre-selected pre-insert-object-selected
    /catalog
    /no-setup "exclude running run-setup-style"
    /no-save
    /after "insert-after selected object"
    /end-of-script {Insert at end of script, which includes past returns etc. Needs /after to work properly}
] [
    before-change-index: vid-code-undoer/action-index
    if all [
        not none? target-object
        target-object <> ""
    ] [
        set [target-object chk-obj-type] if-style-obj-get-last-style-obj target-object
        if chk-obj-type = 'styled [
            after: true
            clear-vid-code-selected
        ]
    ]
    if none? obj-type [
        return none
    ]
    object-type: either ((copy/part to-string obj-type 4) = "ins-") [
        object-type: copy skip to-string obj-type 4
    ] [
        object-type: copy to-string obj-type
    ]
    obj-template: [
        base [(obj-set-word) (to-word object-type) (obj-name) font-color 255.255.255]
        box [(obj-set-word) (to-word object-type) (obj-name)]
        text [(obj-set-word) (to-word object-type) (obj-name)]
        button [(obj-set-word) (to-word object-type) (obj-name)]
        check [(obj-set-word) (to-word object-type) (obj-name)]
        radio [(obj-set-word) (to-word object-type) (obj-name)]
        toggle [(obj-set-word) (to-word object-type) (obj-name)]
        field [(obj-set-word) (to-word object-type) (obj-name)]
        area [(obj-set-word) (to-word object-type) (obj-name)]
        image [(obj-set-word) (to-word object-type)]
        text-list [(obj-set-word) (to-word object-type) data ["one" "two" "three" "four"] select 2]
        drop-list [(obj-set-word) (to-word object-type) data ["one" "two" "three" "four"] select 2]
        drop-down [(obj-set-word) (to-word object-type) data ["one" "two" "three" "four"] select 2]
        calendar [(obj-set-word) (to-word object-type)]
        progress [(obj-set-word) (to-word object-type) 25%]
        slider [(obj-set-word) (to-word object-type)]
        scroller [(obj-set-word) (to-word object-type)]
        camera [(obj-set-word) (to-word object-type) 330x250 on-create [(to-set-path rejoin [to-string obj-set-word "/selected"]) 1]]
        panel [(obj-set-word) (to-word object-type) 250.250.250 [(to-set-word rejoin [obj-name "-button1"]) button (rejoin [obj-name "-button1"])]]
        tab-panel [(obj-set-word) (to-word object-type) ["Tab-A" [(to-set-word rejoin [obj-name "-tab-a-btn1"]) button (rejoin [obj-name "-btn1"])] "Tab-B" [(to-set-word rejoin [obj-name "-tab-b-btn1"]) button (rejoin [obj-name "-btn2"])]]]
        screen [(obj-set-word) (to-word object-type) (obj-name)]
        group-box [(obj-set-word) (to-word object-type) (obj-name) [(to-set-word rejoin [obj-name "-button1"]) button (rejoin [obj-name "-button1"])]]
        h1 [(obj-set-word) (to-word object-type) (obj-name)]
        h2 [(obj-set-word) (to-word object-type) (obj-name)]
        h3 [(obj-set-word) (to-word object-type) (obj-name)]
        h4 [(obj-set-word) (to-word object-type) (obj-name)]
        h5 [(obj-set-word) (to-word object-type) (obj-name)]
        rich-text [(obj-set-word) (to-word object-type) "Hello Red World" data [1x17 0.0.255 italic 7x3 255.0.0 bold 24 underline]]
        timer [(obj-set-word) (to-word object-type) (obj-name) 210.210.210]
        iso-info [(obj-set-word) (to-word object-type)]
        iso-question [(obj-set-word) (to-word object-type)]
        iso-warning [(obj-set-word) (to-word object-type)]
        iso-action-required [(obj-set-word) (to-word object-type)]
        iso-prohibit [(obj-set-word) (to-word object-type)]
    ]
    obj-name: either named [
        find-unused-object-name named-object
    ] [
        find-unused-object-name object-type
    ]
    obj-set-word: to-set-word obj-name
    the-template: copy either style [
        orig-object-type: object-type
        object-type: style-name
        show-insert-tool/refresh
        [(obj-set-word) (to-word style-name)]
    ] [
        either find obj-template (to-lit-word object-type) [
            copy select obj-template (to-lit-word object-type)
        ] [
            internal-style: select system/view/vid/styles (to-lit-word object-type)
            copy select obj-template internal-style/template/type
        ]
    ]
    if with-on-click [
        append/only the-template 'on-click
        append/only the-template [(on-click-code)]
    ]
    if with-offset [
        insert the-template reduce ['at offset-pos]
    ]
    if with-text [
        orig-obj-name: copy obj-name
        obj-name: copy/part text-string 40
    ]
    insert-code/:after/:end-of-script (mold/only compose/deep the-template) target-object
    if with-text [obj-name: copy orig-obj-name]
    if no-save [
        return true
    ]
    run-and-save-id: copy "insert-vid-object"
    append run-and-save-id either style ["-style"] ["-no-style"]
    append run-and-save-id either catalog ["-catalog"] ["-no-catalog"]
    run-and-save run-and-save-id
    if no-setup [
        return to-string obj-set-word
    ]
    setup-result: either style [
        run-setup-style obj-name "" ""
    ] [
        true
    ]
    if setup-result = 'no-target-from-source [
        if req-res: request-yes-no rejoin ["Error inserting: '" object-type {'. If this style requires a parent style, try inserting the parent style first. ^/Do you want to roll back the changes that have been made?}] [
            back-out-vid-changes before-change-index
            request-message {While attempting to 'insert-vid-object' there was a problem locating the 'setup-style'. Any changes made have been reversed.}
            return none
        ]
    ]
    if setup-result = false [
        back-out-vid-changes before-change-index
        request-message {While attempting to 'insert-vid-object' the 'setup-style' did not complete. Any changes made have been reversed.}
        return none
    ]
    if evo-after-insert? [
        obj-name: either all-to-logic setup-result [
            either setup-result = true [
                to-string obj-set-word
            ] [
                setup-result
            ]
        ] [
            to-string obj-set-word
        ]
        edit-vid-object obj-name "vid-code"
    ]
]
