Red [
	Title: "request-setup-style.red"
	Comment: "Imported from: <root-path>%experiments/request-setup-style/request-setup-style.red"
]
run-setup-style: function [
    {returns true/false 'no-setup-style or "object-name" of a new object. ^M^/    ^-^- Defaults to getting setup-style from local-file and if it doesn't exist^M^/    ^-^- will try to find a setup-style from the catalog.^M^/    ^-^-}
    object-name
    src-position
    last-char
    /supply vid-code-supplied [string!] {allows for overriding default style code and testing}
    /test "test flag to return setup early"
    return: [string! logic!]
] [
    before-change-index: vid-code-undoer/action-index
    from-local: false
    from-catalog: false
    vid-code-text: either supply [vid-code-supplied] [vid-code/text]
    object-style: to-string get-object-style (get-object-source object-name vid-code-text)
    setup-style-block: either young-setup-style-data: get-youngest-setup-style-data object-style vid-code-text [
        young-style-name: 1
        young-setup-style-block: 2
        get-setup-style-block young-setup-style-data/:young-style-name young-setup-style-data/:young-setup-style-block
    ] [
        none
    ]
    if all [
        (not setup-style-block)
        (not catalog)
    ] [
        catalog: true
    ]
    if all [
        (setup-style-block)
        (not catalog)
    ] [
        from-local: true
        target-object-name: object-style
        object-source: vid-code-text
        object-type: select (to-block object-source) (to-word object-style)
    ]
    if catalog [
        if style-and-source: get-catalog-style/tree-block object-style [
            style-name: 1
            style-source: 2
            if youngest: get-youngest-parent-setup-style style-and-source [
                setup-style-block: get-setup-style-block youngest/:style-name youngest/:style-source
                object-type: select youngest/:style-source (to-word youngest/:style-name)
            ]
        ]
    ]
    if not setup-style-block [
        return 'no-setup-exists
    ]
    setup: copy/deep setup-style-block
    setup-header: reduce [
        'object (to-string object-type)
        'style (to-string object-style)
        'target object-name
    ]
    setup: reduce [setup]
    insert/only setup setup-header
    setup: reduce [setup]
    if test [
        return setup
    ]
    req-result: request-setup-style/:from-local/:from-catalog setup reduce ["Style" (to-string object-style)]
    if not req-result [
        return false
    ]
    if not setup-result: process-setup-requester req-result [
        back-out-vid-changes before-change-index
        request-message {While attempting to 'run-styled-object' the 'setup-style' did not complete. No changes have been made.}
        return false
    ]
    run-and-save "setup-style"
    return setup-result
]
get-total-data-entries: function [
    setup-block [block!]
] [
    results: 0
    foreach data-block setup-block [
        results: results + ((length? data-block) - 1)
    ]
    return results
]
build-setup-requester: function [
    setup-blocks [block!]
    requester-info {block defining type and name of requester. IE: [ "style" "text-plain" ] }
    /from-local
    /from-catalog
    return: [block!]
] [
    validator-list: [
        "object-name" [validate-word/return-string]
        "check" [validate-logic]
    ]
    default-validators: [
        "default" [validate-string]
        "check" [validate-logic]
        "file" [validate-file]
        "color" [validate-color]
        "pair" [validate-pair]
        "date" [validate-date]
        "integer" [validate-integer]
    ]
    ss-styles: [
        style chk-fld: field 288x24 disabled
        style integer-fld: field 263x24
        style label-above: text "Label Text:" font-color 0.0.0 font-size 12
        style detail: button "?" 20x23 extra [message: ""] on-click [request-message face/extra/message] on-create [face/flags: none]
        style fld: field 315x24 extra [on-tab-away-do-enter: true saved-input-val: copy ""]
        style fld-wide: field 355x24 extra [on-tab-away-do-enter: true]
        style chk: check 13x24
        style heading: text font-size 13
        style info-button: base 17x18 info-icon
        extra [
            now-over?: 0
            message: ""
        ]
        on-over [either event/away? [
            face/extra/now-over?: 0
            face/image/rgb: complement face/image/rgb
            show face
            popup-help/close ""
        ] [
            if face/extra/now-over? = 0 [
                face/image/rgb: complement face/image/rgb
                show face
                face/extra/now-over?: 1
                popup-help/offset/box face/extra/message (face/parent/offset + face/offset + event/offset + 20x20)
            ]
        ]]
        with [
            extra/message: ""
        ]
        style x-axis-button-root: base 230.230.230 0x0
        extra [
            start-down: none
            orig-val: none
            output-field: none
            get-output-field-integer: 0
            output-field-value: 0
            set-output-field: none
            starting-value: none
            directions: copy []
            original-color: 230.230.230
        ]
        on-down [
            face/extra/start-down: event/offset/x
            face/extra/orig-val: face/extra/get-output-field-integer face
        ]
        on-up [
            face/extra/set-output-field face to-string ((face/extra/get-output-field-integer face) + face/extra/directions/1)
            face/extra/start-down: 0
        ]
        on-wheel [
            face/extra/set-output-field face to-string to-integer ((face/extra/get-output-field-integer face) + (event/picked * face/extra/directions/2))
        ]
        on-over [
            if face/extra/start-down <> 0 [
                face/extra/set-output-field face to-string to-integer (face/extra/orig-val + (event/offset/x - face/extra/start-down))
            ]
            either event/away? [
                face/color: face/extra/original-color
            ] [
                face/color: 229.241.251
            ]
        ]
        on-create [
            face/flags: [all-over]
            face/extra/get-output-field-integer: func [this-face] [
                return either (this-face/extra/output-field-value: get to-path reduce [to-word this-face/extra/output-field 'text]) = "" [
                    either this-face/extra/starting-value = 'none [
                        0
                    ] [
                        this-face/extra/starting-value
                    ]
                ] [
                    to-safe-integer this-face/extra/output-field-value
                ]
            ]
            face/extra/set-output-field: func [this-face v] [
                do reduce [to-set-path reduce [to-word this-face/extra/output-field 'text] v]
            ]
            face/extra/start-down: 0
            face/extra/orig-val: 0
        ]
        style x-axis-button-right: x-axis-button-root 24x24
        with [extra/directions: [1 3]]
        draw [
            line-width 1
            pen 155.155.155
            line 0x0 24x0 24x24 0x24 0x0
            pen black
            line-width 2
            line 21x12 5x4
            line 21x12 5x20
            line-width 0.8
            line 3x12 13x12
            line 5x10 5x14
            line 8x10 8x14
            line 11x10 11x14
        ]
        style x-axis-button-left: x-axis-button-root 24x24
        with [extra/directions: [-1 3]]
        draw [
            line-width 1
            pen 155.155.155
            line 0x0 24x0 24x24 0x24 0x0
            pen black
            line-width 2
            line 4x12 20x4
            line 4x12 20x20
            line-width 0.8
            line 13x12 23x12
            line 15x10 15x14
            line 18x10 18x14
            line 21x10 21x14
        ]
        style button-request-file: button "..." 24x24
        extra [
            output-field: ""
            filename: ""
        ]
        on-click [
            if (face/extra/filename: request-file/file system/options/path) [
                set to-path reduce [to-word face/extra/output-field 'text] mold face/extra/filename
                do-actor (get to-word face/extra/output-field) none 'enter
            ]
        ]
        style button-request-date: button "..." 24x24
        extra [
            output-field: ""
            date-value: ""
        ]
        on-click [
            if face/extra/date-value: request-date [
                set to-path reduce [to-word face/extra/output-field 'text] to-string face/extra/date-value
                do-actor (get to-word face/extra/output-field) none 'enter
            ]
        ]
        style button-request-color: button "..." 24x24
        extra [
            output-field: ""
            color-value: ""
        ]
        on-click [
            if face/extra/color-value: request-color [
                set to-path reduce [to-word face/extra/output-field 'text] to-string face/extra/color-value
                do-actor (get to-word face/extra/output-field) none 'enter
            ]
        ]
        style hr-divider: base black 350x1
    ]
    heading-text: chunk-string copy rejoin ["Setup " requester-info/1 " for: '" requester-info/2 "' "] 47
    line-count: count-newlines heading-text
    msg-size: to-pair reduce [350 (line-count * 24)]
    title-detail: copy ""
    title-detail: either from-local [
        " [from active file]"
    ] [
        " [from catalog file]"
    ]
    title-text: rejoin [uppercase/part (requester-info/1) 1 " Setup" title-detail]
    layo: compose/deep [
        title (title-text)
        on-close [requester-results: false unview]
        (ss-styles)
        space 0x10
        heading (msg-size) (heading-text)
        return
        hr-divider
    ]
    total-entries: get-total-data-entries setup-blocks
    save-input-values/init none none 0 [] total-entries
    saved-input-index: 1
    input-row-types: [
        default [
            fld on-enter [
                save-input-values face 'text (saved-input-index) [(validator)]
            ]
            (focus-word)
        ]
        check [
            chk false on-change [
                (to-set-path reduce [to-word rejoin ["check" input-row-index] 'text]) either face/data ["True"] ["False"]
                save-input-values face 'data (saved-input-index) [(validator)]
            ]
            (focus-word)
            (to-set-word rejoin ["check" input-row-index]) chk-fld "False"
        ]
        file [
            fld-wide (focus-word)
            on-enter [
                save-input-values face 'text (saved-input-index) [(validator)]
            ]
            (to-set-word rejoin ["button" input-row-index]) button-request-file
            with [
                extra/output-field: (rejoin ["rsstyle-input" input-row-index])
            ]
        ]
        color [
            fld (focus-word)
            on-enter [
                if verified-input: verify-type 'color face/text [
                    face/text: verified-input
                ]
                save-input-values face 'text (saved-input-index) [(validator)]
            ]
            button-request-color
            with [
                extra/output-field: (rejoin ["rsstyle-input" input-row-index])
            ]
        ]
        pair [
            fld on-enter [
                if verified-input: verify-type pair! face/text [
                    face/text: verified-input
                ]
                save-input-values face 'text (saved-input-index) [(validator)]
            ]
            (focus-word)
        ]
        date [
            fld
            on-change [
                save-input-values face 'text (saved-input-index) [(validator)]
            ]
            button-request-date
            with [
                extra/output-field: (rejoin ["rsstyle-input" input-row-index])
            ]
        ]
        integer [
            (to-set-word rejoin ["integer-fld" input-row-index]) integer-fld
            on-change [
                save-input-values face 'data (saved-input-index) [(validator)]
            ]
            (to-set-word rejoin ["x-axis-button-left" input-row-index]) x-axis-button-left
            with [
                extra/output-field: (to-lit-word rejoin ["rsstyle-input" input-row-index])
            ]
            (to-set-word rejoin ["x-axis-button-right" input-row-index]) x-axis-button-right
            with [
                extra/output-field: (to-lit-word rejoin ["rsstyle-input" input-row-index])
            ]
        ]
    ]
    input-row-index: 0
    some-input?: false
    set 'dc-confirm-inputs function [val] [
        loop-count: 1
        loop val [
            actor-obj: get to-path reduce [obj-name: to-word rejoin ["rsstyle-input" loop-count] 'actors]
            action-word: first words-of :actor-obj
            vid-obj: get obj-name
            do-actor vid-obj none (to-word (skip (to-string action-word) 3))
            loop-count: loop-count + 1
        ]
    ]
    foreach setup-data setup-blocks [
        entry-index: 1
        loop ((length? setup-data) - 1) [
            ss-index: (1 + entry-index)
            focus-word: either (saved-input-index = 1) ['focus] [[]]
            either (prompt-string: select setup-data/:ss-index 'prompt) [
                input-row-index: input-row-index + 1
                either (input-type-defined: select setup-data/:ss-index 'type) [
                    input-type: to-word input-type-defined
                ] [
                    input-type: 'default
                ]
                either (validator-defined: select setup-data/:ss-index 'validator) [
                    validator: select validator-list validator-defined
                ] [
                    validator: either (fnd: find default-validators (to-string input-type)) [
                        fnd/2
                    ] [
                        []
                    ]
                ]
                input-row-block: select input-row-types input-type
                input-row: compose/deep input-row-block
                insert input-row (to-set-word rejoin ["rsstyle-input" input-row-index])
                new-line input-row true
                detail-block: either (detail-data: select setup-data/:ss-index 'detail) [
                    compose/deep [
                        info-button with [extra/message: (detail-data)]
                    ]
                ] [
                    []
                ]
                append layo compose/deep [
                    return
                    space 2x0
                    label-above (rejoin [setup-data/:ss-index/prompt " "])
                    (detail-block)
                    return
                    (input-row)
                    space 2x10
                ]
                some-input?: true
            ] [
                no-input: make object! [data: 'no-input-block]
                save-input-values no-input 'data saved-input-index []
            ]
            saved-input-index: saved-input-index + 1
            entry-index: entry-index + 1
        ]
    ]
    complete-msg: copy []
    if not some-input? [
        return false
    ]
    append layo compose/deep [
        (complete-msg)
        space 4x15
        return
        button "OK" [
            requester-results: true unview
            dc-confirm-inputs (input-row-index)
        ]
        space 192x4
        button "Cancel" [requester-results: false unview]
    ]
    return layo
]
set 'save-input-values closure [
    inputs: []
] [
    {saves input from setup-stye requester. Updates setup-style field accordingly if validator has changed value}
    face [object! none!]
    facet [lit-word! word! none!]
    index [integer!]
    validator [block!]
    /dump
    /init array-length
] [
    if init [
    ]
    if dump [
        return inputs
    ]
    if init [
        inputs: make-array [] array-length
        return ""
    ]
    value: safe-select face facet
    if validator <> [] [
        do compose [new-value: (validator) value]
        if new-value <> value [
            set in face facet new-value
            set-focus face
            value: new-value
        ]
    ]
    set to-set-path reduce ['inputs index] value
    return value
]
get-target-action-list: function [
    "Extract target and action from setup data"
    setup-data [block!]
] [
    target-action-list: copy []
    object-header: 1
    foreach object-block setup-data [
        target-object-name: object-block/1/target
        foreach input-entry object-block/2 [
            append/only target-action-list reduce [target-object-name input-entry/action]
        ]
    ]
    append/only target-action-list reduce ["" []]
    return target-action-list
]
request-setup-style: function [
    setup [block!]
    requester-info [block!]
    /feed requester-block "For testing- provides requester"
    /from-local
    /from-catalog
] [
    either feed [
        requester: copy requester-block
    ] [
        setup-style-data: setup-style-to-data setup
        requester: build-setup-requester/:from-local/:from-catalog setup-style-data requester-info
    ]
    requester-results: copy ""
    verified-input: copy ""
    requester-offset: to-pair reduce [(splith/size/x - 320) 160]
    requester-block: reduce [to-set-word 'offset requester-offset]
    if requester [
        view/options/flags (bind requester 'requester-results) requester-block [modal]
    ]
    input-entries: save-input-values/dump none none 0 []
    if not requester-results [
        return none
    ]
    all-object-results: copy []
    target-action-list: get-target-action-list setup
    target-action-index: 1
    target-field: 1
    action-field: 2
    object-results: copy []
    foreach input input-entries [
        action: target-action-list/:target-action-index/:action-field
        append/only object-results reduce [to-block mold input action]
        target-object-name: target-action-list/:target-action-index/:target-field
        if target-object-name <> target-action-list/(target-action-index + 1)/:target-field [
            insert object-results target-object-name
            append/only all-object-results object-results
            object-results: copy []
        ]
        target-action-index: target-action-index + 1
    ]
    return all-object-results
]
set 'alter-facet function [
    {alter-facet is a wrapper for modify-facet, but it provides source-code and object-name to the modify-facet function}
    facet [word!] {lit-word name of the facet to alter. LIST OF FLAG FACETS: all-over anti-alias bold bottom center cleartype disabled focus hidden italic left loose middle no-border no-wrap password right strike top tri-state true underline wrap. WARNING: Some flags are mutually exclusive, you will need to deal with that. FACETS THAT NEED VALUES: color data options date default-string draw extra file font-color font-name font-size hint layout-block name offset on-<actor> percent rate react select size text url with}
    /value new-value [any-type!] {value of facets that aren't FLAGS. Ignored if using the /delete refinement.}
    /delete "Removes the facet indicated."
    /extern dc-alter-facet-object-name vid-code
] [
    if facet = 'name [
        if not new-value: validate-word new-value [
            return false
        ]
    ]
    modify-facet/:value/:delete vid-code/text dc-alter-facet-object-name facet :new-value
    if facet = 'name [
        dc-alter-facet-object-name: new-value
    ]
    return true
]
process-setup-requester: function [
    "Runs the actions defined. Using input-action DSL"
    value-action-blocks [block!]
    /extern dc-alter-facet-object-name
] [
    object-name: copy ""
    original-object-name: copy ""
    dc-alter-facet-object-name: copy ""
    saved-input-val: copy ""
    object-block-index: 1
    input-field: 1
    action-field: 2
    objects: copy []
    foreach object-block value-action-blocks [
        input-values: copy []
        object-name: first object-block
        original-object-name: dc-alter-facet-object-name: object-name
        object-blocks: copy (skip object-block 1)
        entry-block-index: 1
        foreach input-entry-blocks object-blocks [
            input-value: if-empty-block-to-none if-word-to-datatype first input-entry-blocks/:input-field
            append input-values input-value
            either input-value <> none [
                if input-entry-blocks/:action-field [
                    do-action: copy input-entry-blocks/:action-field
                    action-results: do bind do-action 'object-name
                ]
            ] [
            ]
            entry-block-index: entry-block-index + 1
        ]
        append/only objects reduce [
            'object-name dc-alter-facet-object-name
            'input-values input-values
        ]
        object-block-index: object-block-index + 1
    ]
    if all [
        ((length? value-action-blocks) = 1)
        (dc-alter-facet-object-name <> original-object-name)
    ] [
        return dc-alter-facet-object-name
    ]
    return true
]
