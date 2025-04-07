Red [
	Title: "move-object.red"
	Comment: "Imported from: <root-path>%experiments/move-object/move-object.red"
]
set 'get-valid-entry function [
    src-cdta [block!]
    cdta-line [block!]
    /in-panel "don't dig into panel"
] [
    if any [
        (cdta-line/parent = "")
        in-panel
    ] [
        cdta-line: first find-key-value-in-array src-cdta reduce ['object cdta-line/object 'input (rejoin [cdta-line/object ":"])]
        return cdta-line
    ]
    if cdta-line/parent = "-" [
        return cdta-line
    ]
    panel-obj: first find-key-value-in-array src-cdta reduce ['object cdta-line/parent 'input (rejoin [cdta-line/parent ":"])]
    while [panel-obj/parent <> ""] [
        panel-obj: first find-key-value-in-array src-cdta reduce ['object panel-obj/parent 'input (rejoin [panel-obj/parent ":"])]
    ]
    return panel-obj
]
inside?: function [
    source [pair!]
    target [pair!]
] [
    if between? source/x target [
        if between? source/y target [
            return true
        ]
    ]
    return false
]
get-container-span: function [
    cdta [block!]
    index [integer!]
    /just-name
] [
    loop-index: index + 1
    forever [
        loop-index: loop-index - 1
        if all [
            ((to-string cdta/:loop-index/type) = "block")
            inside? cdta/:index/token cdta/:loop-index/token
        ] [
            panel-span: either just-name [
                cdta/:loop-index/object
            ] [
                cdta/:loop-index/token
            ]
            break
        ]
    ]
    return panel-span
]
set 'get-objects-within-container function [
    source [string!]
    container-name [string!]
] [
    cdta: vid-cdta source
    found: find-key-value-in-array cdta reduce ['object container-name 'type 'block!]
    obj: first found
    objects-within: get-objects-in-container cdta obj/index
    remove-each line objects-within [
        line/object = line/parent
    ]
    results: collect [
        foreach line objects-within [
            if ((to-string line/type) = "set-word") [
                keep to-string to-word line/input
            ]
        ]
    ]
    return results
]
set 'get-objects-in-container function [
    {returns all cdta within an object. index can be any object that is within the container}
    cdta [block!]
    index [integer!]
] [
    panel-span: get-container-span cdta index
    container-objects: collect [
        foreach line cdta [
            if inside? line/token panel-span [
                keep/only line
            ]
        ]
    ]
    remove/part container-objects 1
    return container-objects
]
set 'valid-object? function [
    src-cdta
    obj-record
] [
    if obj-record/object = "" [return false]
    if obj-record/parent = obj-record/object [return false]
    obj-info: find-in-array-at/every src-cdta 4 obj-record/object
    either (obj-info/1/input = "style") [
        return false
    ] [
        return true
    ]
]
set 'find-first-vid-object function [
    {V4 utilizing new 'parent field in cdta. Uses panel edges at boundaries}
    src-cdta [block!]
    obj-name [string!]
    /last
] [
    obj: first find-key-value-in-array src-cdta reduce ['object obj-name 'input (rejoin [obj-name ":"])]
    if obj/parent = "" [
        sort/compare src-cdta function [a b] [a/token/y < b/token/y]
        cdta: either last [reverse copy src-cdta] [src-cdta]
        foreach entry cdta [
            if valid-object? src-cdta entry [
                return (select (get-valid-entry src-cdta entry) 'object)
            ]
        ]
        return none
    ]
    either obj/parent = "~" [
        panel-entries: get-objects-in-container src-cdta obj/index
    ] [
        panel-entries: find-key-value-in-array src-cdta reduce ['parent obj/parent]
    ]
    panel-entries: either last [
        reverse copy panel-entries
        sort/compare panel-entries function [a b] [a/token/y > b/token/y]
    ] [
        panel-entries
    ]
    foreach panel-entry panel-entries [
        if valid-object? src-cdta panel-entry [
            valid-entry: get-valid-entry/in-panel src-cdta panel-entry
            if valid-entry/object = obj-name [
                parent-container: get-container-span/just-name src-cdta valid-entry/index
                return parent-container
            ]
            return select valid-entry 'object
        ]
    ]
    return none
]
pick-non-container: function [
    obj-list
    start-index
    rel-pos
    source
] [
    containers: [panel tab-panel group-box]
    initial-obj-name: to-string to-word obj-list/:start-index/1
    initial-obj-type: obj-list/:start-index/2
    if find containers initial-obj-type [
        obj-within: get-objects-within-container source initial-obj-name
        skip-to-obj: either positive? rel-pos [
            last obj-within
        ] [
            first obj-within
        ]
        fnd: find-in-array-at/with-index obj-list 1 (to-set-word skip-to-obj)
        start-index: second fnd
    ]
    curr-index: start-index
    index-step: either positive? rel-pos [1] [-1]
    step-count: 0
    until [
        step-count: step-count + 1
        curr-index: curr-index + index-step
        if none? obj-list/:curr-index [return none]
        while [find [panel tab-panel group-box] obj-list/:curr-index/2] [
            curr-index: curr-index + index-step
            if none? obj-list/:curr-index [return none]
        ]
        (step-count = (absolute rel-pos))
    ]
    if picked: pick obj-list curr-index [
        return to-string picked/1
    ]
    return none
]
set 'find-relative-vid-object function [
    "v3"
    source
    obj-name
    relative-pos
] [
    all-objs: get-vid-object-list source
    obj-index: second find-in-array-at/with-index all-objs 1 to-word obj-name
    if picked: pick-non-container all-objs obj-index relative-pos source [
        return picked
    ]
    last: either positive? relative-pos [true] [false]
    return find-first-vid-object/:last vid-cdta vid-code/text obj-name
]
set 'get-last-styled-object function [
    {return the last styled object in a style group. Should work with styles embedded in container panels.}
    obj-list [block!] " obj-list from: get-defined-vid-objects/detail "
    style-name [string!] "valid style name"
] [
    fnd-index: index? find obj-list (to-word style-name)
    last-fnd: copy ""
    foreach [set-wrd obj-type kind] (skip obj-list (fnd-index - 1)) [
        either kind = 'styled [
            last-fnd: set-wrd
        ] [
            break
        ]
    ]
    return to-string last-fnd
]
set 'if-style-obj-get-last-style-obj function [
    obj-name
] [
    full-obj-list: get-defined-vid-objects/detail vid-code/text
    if (pick (find full-obj-list (to-word obj-name)) 3) = 'styled [
        return reduce [(get-last-styled-object full-obj-list obj-name) 'styled]
    ]
    return reduce [obj-name 'stock]
]
set 'move-object function [
    "V1"
    obj-name [string!]
    src-position [pair!]
    last-char
    target-obj [string!]
    after [logic!] "flag to do insert-after. default is insert-before"
] [
    if obj-name = target-obj [exit]
    set [new-target obj-type] if-style-obj-get-last-style-obj target-obj
    if obj-type = 'styled [
        target-obj: new-target
        after: true
    ]
    target-obj-loc: get-object-source/position/whitespace target-obj vid-code/text
    if inside? target-obj-loc/3 src-position [
        request-message rejoin ["Can not move the source object named: " mold obj-name " into the target object named: " mold target-obj { . Because the target object is contained within the source object.}]
        return none
    ]
    current-code: first delete-vid-object obj-name
    insert-code/:after current-code target-obj
    run-and-save "move-object"
]
set 'move-object-relative function [
    "V2 move object in relation to itself"
    obj-name
    src-position
    last-char
    rel-pos "plus or minus relative position from obj-name"
    /beginning
    /end
] [
    container-skipped?: false
    object-name-field: 4
    after-flag: true
    src-cdta: vid-cdta vid-code/text
    obj-info: find-in-array-at/every src-cdta object-name-field obj-name
    if beginning [
        target-obj: find-first-vid-object src-cdta obj-name
        after-flag: false
    ]
    if end [
        target-obj: find-first-vid-object/last src-cdta obj-name
    ]
    if not any [beginning end] [
        target-obj: find-relative-vid-object vid-code/text obj-info/1/object rel-pos
    ]
    if target-obj = false [
        reason-str: either end [
            "End of Script"
        ] [
            either beginning [
                "Beginning of Script"
            ] [
                either positive? rel-pos [
                    rejoin [rel-pos " Objects Ahead"]
                ] [
                    rejoin [rel-pos " Objects Back"]
                ]
            ]
        ]
        request-message rejoin ["Unable to move Object^/^-Name: " mold obj-name "^/^-To: " reason-str]
        return none
    ]
    if target-obj = obj-name [return none]
    after-flag: either positive? rel-pos [true] [false]
    move-object obj-name src-position "" target-obj after-flag
]
resolve-styles: function [
    obj-list
    style-list
] [
    foreach [style-name stock-obj] style-list [
        replace/all obj-list (to-lit-word style-name) (to-word stock-obj)
    ]
    return obj-list
]
get-vid-object-list: function [
    {provide a full list of objects in order with stock object types}
    source [string!]
] [
    def-objs: get-defined-vid-objects/no-styles source
    def-styles: get-styles-deep to-block source
    def-objs: resolve-styles def-objs def-styles
    results: copy []
    cdta: vid-cdta source
    foreach [obj-name obj-type] def-objs [
        append/only results reduce [obj-name obj-type]
    ]
    return results
]
