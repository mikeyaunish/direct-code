Red [
	Title: "vid-cdta.red"
	Comment: "Imported from: <root-path>%experiments/vid-cdta/vid-cdta.red"
]
id-block: function [
    blocks [block!] "all cdta entries that belong to this block"
] [return-value: none
either set-word: first find-key-value-in-array fix-dt blocks fix-dt reduce ['type set-word!] [
    either after-set-word: first find-key-value-in-array fix-dt blocks fix-dt reduce ['index (set-word/index + 1)] [
        return after-set-word/input
    ] [
    ]
] [
]
return return-value]
get-panel-styles: function [
    "V2 pull all panel styles from a block"
    value [block!]
    /extern dc-stock-panels
] [
    results-vals: copy []
    rule: [any
    [
        'style mark: (
            if find dc-stock-panels to-string second mark [
                append results-vals copy/part mark 2
            ]
        )
        | skip
    ]]
    parse-res: parse value rule
    return results-vals
]
set 'expand-panel-block function [
    panel-block [block!]
    cdta [block!]
    panel-name [string!]
    /tab-panel tab-panel-block [block!] " tab panel customizations"
] [
    panel-code: un-block-string/only/replace copy panel-block/input
    panel-cdta: vid-cdta-flat panel-code
    new-panels: get-cdta-panels cdta
    either tab-panel [
        orig-offset: tab-panel-block/token
        orig-line: tab-panel-block/line
    ] [
        orig-offset: panel-block/token
        orig-line: panel-block/line
    ]
    foreach p-cdta panel-cdta [
        panel-name-prefix: copy ""
        object-string-data: copy ""
        if (p-cdta/type) = string! [
            object-string-data: copy/part (skip panel-block/input (p-cdta/token - 1)) (p-cdta/token/y - p-cdta/token/x + 1)
            if (last object-string-data) = #"]" [
                p-cdta/token/y: p-cdta/token/y - 1
            ]
        ]
        either tab-panel [
            x-val: panel-block/token/x + p-cdta/token/x - 1
            if (p-cdta/type) <> string! [
                panel-name-prefix: copy "~"
            ]
            tab-panel-offset: p-cdta/line: panel-block/line/x + orig-line/x + p-cdta/line - 1
        ] [
            x-val: orig-offset/x + p-cdta/token/x - 1
            tab-panel-offset: p-cdta/line: orig-line/x + p-cdta/line - 1
        ]
        y-val: x-val + p-cdta/token/y - p-cdta/token/x
        p-cdta/token: to-pair reduce [x-val y-val]
        if p-cdta/parent = "" [p-cdta/parent: rejoin [panel-name-prefix panel-name]]
    ]
    append cdta panel-cdta
]
set 'get-cdta-panels function [
    cdta
    /extern dc-stock-panels
] [
    results: copy []
    foreach panel-type dc-stock-panels [
        either panel-blocks-fnd: find-key-value-in-array cdta fix-dt compose ['input (panel-type) 'type word!] [
            foreach entry panel-blocks-fnd [
                append results entry/object
            ]
        ] [
        ]
    ]
    return results
]
set 'block-types-to-ignore function [] [
    results: copy dc-actor-list
    insert results ["data" "extra" "with" "react" "draw" "font" "para"]
    return results
]
set 'get-lines-to-unpack function [
    cdta [block!]
    panel-types [block!]
] [
    results: copy []
    if not blocks-found: find-key-value-in-array cdta fix-dt compose ['type block!] [
        return []
    ]
    foreach line blocks-found [
        tab-panel-name: copy ""
        if line/object = "" [
            either line/parent = "" [
                continue
            ] [
                tab-panel-name: trim/left/with line/parent "~"
            ]
        ]
        if tab-panel-name <> "" [
            append/only results reduce [line "tab-panel"]
            continue
        ]
        id-lines: find-key-value-in-array cdta fix-dt compose ['object (line/object)]
        new-panel-styles: get-panel-styles id-lines
        line-offset: first find-key-value-in-array/index id-lines reduce ['token line/token]
        previous-line: pick id-lines (line-offset - 1)
        if find block-types-to-ignore previous-line/input [
            continue
        ]
        id-line: first find-key-value-in-array id-lines fix-dt compose ['object (line/object) 'type set-word!]
        type-lines: find-key-value-in-array id-lines fix-dt compose ['object (line/object) 'type word!]
        type-line: either any [
            (type-lines/1/input = "style")
            (type-lines/1/input = "at")
        ] [
            type-lines/2
        ] [
            type-lines/1
        ]
        previously-unpacked?: find-key-value-in-array cdta fix-dt compose ['parent (line/object)]
        either all [
            (fpt: find panel-types type-line/input)
            (not previously-unpacked?)
        ] [
            line-type: type-line/input
            line/parent: "-"
            append/only results reduce [line line-type]
        ] [
        ]
    ]
    return results
]
sort-cdta: function [
    cdta
] [
    sort/compare cdta func [a b] [(a/token/x) < (b/token/x)]
]
cleanup-cdta: function [
    cdta [block!]
] [
    sort-cdta cdta
    ndx: 1
    foreach item cdta [
        item/index: ndx
        if item/object = "" [item/object: trim/head/with item/parent "~"]
        ndx: ndx + 1
    ]
]
lines-left-to-unpack: function [
    {extract block entries that don't match with unpacks-done. Returns [ <line> <panel-type> ] }
    cdta [block!]
    unpacks-done [block!]
    panel-types [block!]
] [
    unpacks-to-do: copy []
    block-type-lines: find-key-value-in-array cdta fix-dt compose ['type block!]
    if (none? block-type-lines) [
        return [[] []]
    ]
    remove-each block block-type-lines [
        was-found?: false
        foreach line unpacks-done [
            if block/token = line/token [
                was-found?: true
            ]
        ]
        was-found?
    ]
    foreach block block-type-lines [
        either block/object = "" [
            object-name: copy (skip block/parent 1)
            object-lines: find-key-value-in-array cdta reduce ['object object-name]
            append/only unpacks-to-do reduce [block "tab-panel"]
            continue
        ] [
            object-name: block/object
            object-lines: find-key-value-in-array cdta reduce ['object object-name]
        ]
        either line-type-word: find-key-value-in-array object-lines ['type word!] [
            block-type: select (first line-type-word) 'input
        ] [
            block-type: "block-set-word"
        ]
        object-block-lines: find-key-value-in-array object-lines ['type block!]
        foreach block-line object-block-lines [
            block-code: to-block un-block-string copy select block-line 'input
            was-found?: false
            foreach line unpacks-done [
                if block-line/token = line/token [
                    was-found?: true
                    break
                ]
            ]
            if was-found? [continue]
            if (unique-panel-styles: get-panel-styles block-code) <> [] [
                foreach [style-name panel-type] unique-panel-styles [
                    append panel-types to-string style-name
                ]
            ]
            either find panel-types block-type [
                line-offset: first find-key-value-in-array/index object-lines reduce ['token block-line/token]
                previous-line: pick object-lines (line-offset - 1)
                either (not find block-types-to-ignore previous-line/input) [
                    block-id: id-block object-lines
                    upsert/only unpacks-to-do reduce [block-line block-id]
                ] [
                    upsert/only unpacks-done block-line
                ]
            ] [
            ]
        ]
    ]
    return either (unpacks-to-do = []) [
        [[] []]
    ] [
        ret-val: reduce [unpacks-to-do unpacks-done]
        ret-val
    ]
]
vid-cdta: function [
    "V3 return canonical data from VID source code"
    source [string!]
    /deep kinds-of-panels [block!] "Used internally when called recursively"
    /supply cdta-supplied [block!]
    /unpack unpack-details [block!] {2 blocks describing [ <unpacks-to-do> <unpacks-done> ]}
    /extern dc-stock-panels
] [
    either supply [
        cdta: cdta-supplied
    ] [
        cdta: vid-cdta-flat source
    ]
    either deep [] [
        kinds-of-panels: copy []
        kinds-of-panels: get-cdta-panels cdta
        append kinds-of-panels dc-stock-panels
        unpacks-done: copy []
    ]
    either unpack [
        unpacks-to-do: unpack-details/1
        unpacks-done: unpack-details/2
    ] [
        unpacks-to-do: get-lines-to-unpack cdta kinds-of-panels
    ]
    foreach item unpacks-to-do [
        block-code: to-block un-block-string copy select item/1 'input
        either (unique-panel-styles: get-panel-styles block-code) <> [] [
            foreach [style-name panel-type] unique-panel-styles [
                append kinds-of-panels to-string style-name
            ]
        ] []
    ]
    foreach line-item unpacks-to-do [
        line: line-item/1
        line-type: line-item/2
        if not (find dc-stock-panels line-type) [
            deep-styles: get-styles-deep to-block source
            if not line-type: to-string select deep-styles (to-word line-type) [
                exit
            ]
        ]
        either line-type = "tab-panel" [
            expand-panel-block/tab-panel line cdta line/object
            reduce ['index line/index 'token line/token 'line line/line]
        ] [
            expand-panel-block line cdta line/object
        ]
        if line [
            append/only unpacks-done line
        ]
    ]
    defined-vid-objects: get-defined-vid-objects source
    lines-left: lines-left-to-unpack cdta unpacks-done kinds-of-panels
    unpacks-to-do: lines-left/1
    either (unpacks-to-do <> []) [
        z: vid-cdta/deep/supply/unpack source kinds-of-panels cdta lines-left
    ] []
    cleanup-cdta cdta
    return cdta
]
