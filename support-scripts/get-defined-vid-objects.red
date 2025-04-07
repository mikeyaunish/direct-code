Red [
	Title: "get-defined-vid-objects.red"
	Comment: "Imported from: <root-path>%experiments/get-defined-vid-objects/get-defined-vid-objects.red"
]
get-vid-object-name: func [
    {returns the name of the vid object requested. One refinement mandatory}
    code [string!]
    /first "returns the first object name"
    /last "returns last object name"
    /next target-obj [string!] {returns the next non-style object past the target-obj}
] [
    cdta: vid-cdta code
    sort/compare cdta function [a b] [b/token/y > a/token/y]
    if next [
        target-index: system/words/last find-key-value-in-array/index cdta reduce ['object target-obj]
    ]
    if first [
        target-index: 0
    ]
    if last [
        sort/compare cdta function [a b] [a/token/y > b/token/y]
        target-index: 0
    ]
    last-item-name: copy ""
    foreach item (skip cdta target-index) [
        if last-item-name = item/object [continue]
        obj-type: second query-vid-object vid-code/text item/object [word!]
        either obj-type = "style" [
            last-item-name: item/object
        ] [
            return item/object
        ]
    ]
    return none
]
get-styles-deep: func [
    "v2 within get-defined-vid-objects"
    value [block!]
    /panels {return only styled panels in (objec-name/ panel-type) pairs ie: "gb1" "group-box" }
] [
    results-vals: copy []
    rule: [any
    [
        'style mark: (
            append results-vals copy/part mark 2
        )
        | ahead block! into rule
        | skip
    ]]
    parse-res: parse value rule
    if panels [
        panel-styles: copy []
        foreach styl dc-stock-panels [
            append panel-styles reduce [styl styl]
        ]
        foreach [set-word obj-type] results-vals [
            if fnd: find/skip panel-styles (to-string obj-type) 1 [
                append panel-styles reduce [(to-string set-word) (second fnd)]
            ]
        ]
        return panel-styles
    ]
    return results-vals
]
get-vid-set-words: func [
    value [block!]
    styles [block!]
] [
    results-vals: copy []
    rule: [any
    [
        set-word! mark: (
            either find styles (to-string first mark) [
                append results-vals first back mark
                append results-vals first mark
            ] [
            ]
        )
        | ahead block! into rule
        | skip
    ]]
    parse-res: parse value rule
    return results-vals
]
set 'get-all-vid-styles function [
    source [string! block!]
    /extern dc-stock-styles
] [
    if string? source [source: to-block source]
    all-vid-styles: copy []
    custom-vid-styles: get-styles-deep to-block source
    all-vid-styles: collect [
        foreach [style-name vid-type] custom-vid-styles
        [keep to-string style-name]
    ]
    append all-vid-styles dc-stock-styles
    return all-vid-styles
]
get-defined-vid-objects: function [
    source [string!] "source code"
    /no-styles
    /detail {include wether the object is a 'stock or 'styled object }
    /extern dc-stock-styles
] [
    all-vid-styles: get-all-vid-styles source
    all-vid-set-words: get-vid-set-words (to-block source) all-vid-styles
    if no-styles [
        all-styles: get-styles-deep to-block source
        return difference/skip all-vid-set-words all-styles 2
    ]
    if detail [
        just-styles: get-styles-deep to-block source
        results: collect [
            foreach [set-wrd obj-typ] all-vid-set-words [
                either find just-styles set-wrd [
                    keep reduce [set-wrd obj-typ 'styled]
                ] [
                    keep reduce [set-wrd obj-typ 'stock]
                ]
            ]
        ]
        return results
    ]
    return all-vid-set-words
]
