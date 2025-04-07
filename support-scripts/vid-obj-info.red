Red [
	Title: "vid-obj-info.red"
	Comment: "Imported from: <root-path>%experiments/vid-obj-info/vid-obj-info.red"
]
set 'whitespace-edge function [
    "finds edge of whitespace surrounding an object"
    val [string!]
    pos [integer!] "location to start"
    /reverse
    /start {allow checking from start of val - overrides pos = 0}
    /with-newline {include the newline if it exists at end of line - not for reverse}
    /printable "use a printable character set"
] [
    whitespace-chars: either printable [
        [#" " #"^-" #"^M" #"^K" #"^L" ## "^/"]
    ] [
        [#" " #"^-" #"^M" #"^K" #"^L"]
    ]
    if all [(pos = 0) (not start)] [
        return 1
    ]
    if pos > val-length: length? val [
        return val-length
    ]
    value: copy val
    if reverse [
        system/words/reverse value
        pos: (val-length - pos + 1)
    ]
    value: (skip value pos)
    forall value [
        char: first value
        if not find whitespace-chars char [
            pos-fnd: (index? value) - 1
            if all [
                with-newline
                (char = #"^/")
            ] [
                pos-fnd: pos-fnd + 1
            ]
            return either reverse [
                (val-length - pos-fnd + 1)
            ] [
                pos-fnd
            ]
        ]
    ]
    either reverse [
        return 1
    ] [
        return val-length
    ]
]
set 'vid-obj-info function [
    {return vid object information. default returns just the un-adorned source code.}
    source-code [string!]
    object-name [string!]
    /position {returns block with position [ <source-code> <plain-offset> }
    /whitespace {returns block [ <source-code> <plain-offset> <whitespace-offset> ] }
    /with-newline {must be used with /whitespace - includes any tailing newline if exists}
    /located-at located [pair!] "find the object by location not name"
    /just-name "return just the name of the object"
] [
    block-type: none
    cdta: vid-cdta source-code
    if located-at [
        object-fld: 4
        foreach item reverse copy cdta [
            if between? located/x item/token [
                obj-fnd: find-in-array-at cdta object-fld item/object
                object-name: obj-fnd/object
                break
            ]
        ]
    ]
    if not (v-src: second (query-vid-object source-code object-name [])) [
        return false
    ]
    either word-type-lines: find-key-value-in-array v-src ['type word!] [
        initial-type: select (first word-type-lines) 'input
        either initial-type = "style" [
            first-set-word-index: select (first word-type-lines) 'index
            block-type: select (second word-type-lines) 'input
        ] [
            panel-styles: get-styles-deep/panels to-block source-code
            if fnd: find/skip panel-styles initial-type 1 [
                initial-type: "style"
                block-type: second fnd
            ]
        ]
    ] [
        block-type: "generic-block"
    ]
    last-item-index: select (last v-src) 'index
    if block-type = "tab-panel" [
        if fnd: find-key-value-in-array v-src ['type block!] [
            last-item-index: select (first fnd) 'index
        ]
    ]
    if find ["panel" "group-box"] block-type [
        either initial-type = "style" [
            either block-line: find-key-value-in-array v-src ['type block!] [
                last-item-index: select (last find-key-value-in-array v-src ['type block!]) 'index
            ] [
                last-item-index: select (last v-src) 'index
            ]
        ] [
            last-item-index: select (first find-key-value-in-array v-src ['type block!]) 'index
        ]
    ]
    last-no-owner-chunk-in-object: find-no-owner-block v-src
    last-chunk-in-object: last find-key-value-in-array v-src reduce ['object object-name]
    if (last-chunk-in-object/token/y < last-no-owner-chunk-in-object/token/y) [
        last-chunk-in-object: last-no-owner-chunk-in-object
    ]
    if last-chunk-in-object/type = block! [
        block-type: "generic-block"
    ]
    last-char: pick source-code last-chunk-in-object/token/y
    y-correction: 0
    if any [
        (last-char = none)
        all [
            (last-char = #"]")
            none? block-type
        ]
        (is-whitespace? last-char)
    ] [
        y-correction: -1
    ]
    obj-position: to-pair reduce [v-src/1/token/x (last-chunk-in-object/token/y + y-correction)]
    results: copy/part (skip source-code (obj-position/x - 1)) (obj-position/y - obj-position/x + 1)
    if position [
        results: reduce [results]
        append results obj-position
        if whitespace [
            left-edge: whitespace-edge/reverse source-code obj-position/x
            right-edge: whitespace-edge/:with-newline source-code obj-position/y
            append results to-pair reduce [left-edge right-edge]
        ]
    ]
    if just-name [
        either block? results [
            remove results
            insert results object-name
        ] [
            results: object-name
        ]
    ]
    return results
]
