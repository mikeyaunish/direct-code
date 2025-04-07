Red [
	Title: "query-vid-object.red"
	Comment: "Imported from: <root-path>%experiments/query-vid-object/query-vid-object.red"
]
query-vid-object-ctx: context [
    set 'get-object-source function [
        "get-object-source V4"
        object-name [string!]
        source-code [string!]
        /position
        /whitespace {include pre and post whitespace with /position.Result pair appended to result.}
        /with-newline
    ] [
        block-type: none
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
        return results
    ]
    set 'owner-switch-block [
        "tuple" [["font-color"]]
        "pair" [["at"]]
        "string" [["font-name" "hint" "default" "data"]]
        "logic" [["data" "extra" "with"]]
        "integer" [["font-size" "select"]]
        "time" [["rate"]]
        "block" [[
            "default"
            "font" "with" "actors" "extra" "do" "data" "draw" "para" "react"
            "on-down" "on-up" "on-mid-down" "on-mid-up" "on-alt-down" "on-alt-up" "on-aux-down"
            "on-aux-up" "on-drag-start" "on-drag" "on-drop" "on-create" "on-click" "on-dbl-click" "on-over"
            "on-move" "on-resize" "on-moving" "on-resizing" "on-wheel" "on-zoom" "on-pan"
            "on-rotate" "on-two-tap" "on-press-tap" "on-key-down" "on-key" "on-key-up" "on-enter"
            "on-focus" "on-unfocus" "on-select" "on-change" "on-menu" "on-close" "on-time"
            "on-created" "on-detect" "on-drawing" "on-ime"
        ]]
    ]
    set 'get-styles function [
        code-blk [block! string!]
    ] [
        code-block: copy code-blk
        if string? code-block [
            code-block: to-block un-block-string code-block
        ]
        rez: parse code-block [collect [any ['style keep set-word! keep word! | skip]]]
        return rez
    ]
    select-datatype-value: function [haystack dtype value] [
        if (fnd: find haystack (to dtype value)) [
            if ((type? (first fnd)) = dtype) [
                return first next fnd
            ]
        ]
        return none
    ]
    get-obj-type: function [
        code-cdta [block!]
        obj-name [string!]
        styles-list [block!]
    ] [
        type-field: 8
        index-field: 2
        fixed-code-cdta: fix-datatype code-cdta
        set-word-at: find-in-array-at/with-index fixed-code-cdta type-field set-word!
        next-index-val: (set-word-at/1/index + 1)
        obj-type-at: find-in-array-at code-cdta index-field next-index-val
        assigned-type: obj-type-at/input
        return either (style-type: select-datatype-value styles-list set-word! assigned-type) [
            style-type
        ] [
            assigned-type
        ]
    ]
    previous-chunk-owns?: function [
        obj-chunks [block!]
        target-chunk [block!]
        datatype-filter [datatype!]
        /extern owner-switch-block
    ] [
        index-field: 2
        owner-keywords: switch/default (to-string datatype-filter) owner-switch-block [
            return false
        ]
        if (previous-chunk: find-in-array-at obj-chunks index-field (target-chunk/index - 1)) [
            either find owner-keywords previous-chunk/input [
                return true
            ] [
                return false
            ]
        ]
    ]
    is-no-name-equivalent?: function [
        "is-no-name-equivalent? query-vid-object.red"
        obj-name
        filter
        code-styles
        obj-type
        /extern dc-default-action-list
    ] [
        def-action-list: dc-default-action-list
        if find ["panel" "tab-panel" "group-box"] obj-type [
            return false
        ]
        if (filter/1 = word!) [
            obj-default-action: select dc-default-action-list (to-word obj-type)
            if obj-default-action = filter/2 [
                return true
            ]
        ]
        return false
    ]
    set 'stock-style? function [
        style-name [string! word!]
    ] [
        return either (find keys-of system/view/vid/styles to-word style-name) [
            true
        ] [
            false
        ]
    ]
    get-style: function [
        source-code [string!]
    ] [
        return first parse to-block source-code [
            collect [any [set-word! keep word! | skip]]
        ]
    ]
    set 'get-object-from-source function [
        {Retrieves VID object from source code. Will traverse and return full style tree if need be.. }
        obj-name [string!] "The object or style name"
        full-src [string!] "The source code containing the object"
        /catalog
    ] [
        obj-src: get-object-source obj-name full-src
        this-style: get-style obj-src
        if catalog [
            replace obj-src "style" ""
            replace obj-src this-style "base"
            replace obj-src rejoin [obj-name ":"] rejoin [obj-name "XYZ:"]
            return do (layout/only to-block obj-src)
        ]
        if (copy/part obj-src 5) = "style" [
            src-split: split obj-src ":"
            replace obj-src rejoin [src-split/1 ":"] ""
        ]
        while [not stock-style? this-style] [
            style-src: get-object-source (to-string this-style) full-src
            if not style-src [
                return false
            ]
            insert obj-src rejoin [style-src "^/"]
            this-style: get-style style-src
        ]
        replace obj-src rejoin [obj-name ":"] rejoin [obj-name "XYZ:"]
        return do (layout/only to-block obj-src)
    ]
    set 'find-no-owner-block function [
        chunks
    ] [
        ignore-blocks: block-types-to-ignore
        if block-lines-all: find-key-value-in-array/index chunks ['type block!] [
            foreach chunk-index block-lines-all [
                prev-chunk: pick chunks (chunk-index - 1)
                if not find ignore-blocks prev-chunk/input [
                    return pick chunks chunk-index
                ]
            ]
            return pick chunks (last block-lines-all)
        ]
        return last chunks
    ]
    set 'query-vid-object function [
        "v2 query a VID Object from the source"
        source-code [string!] "full source code to be inspected"
        obj-name [string!]
        filter [block!] " datatype! + <input-string> OPTIONAL "
        /with with-src-cdta "supply the scr-cdta"
        return: [block!]
        /extern owner-switch-block
    ] [
        src-cdta: vid-cdta source-code
        object-field: 4
        input-field: 6
        type-field: 8
        match-pos: false
        datatype-filter: reduce filter/1
        either obj-chunks: find-in-array-at/every src-cdta object-field obj-name [
            either datatype-chunks: find-in-array-at/every obj-chunks type-field datatype-filter [
                either ((length? filter) > 1) [
                    input-filter: reduce filter/2
                    either (dt-input-chunks: find-in-array-at/every datatype-chunks input-field input-filter) [
                        either ((length? dt-input-chunks) = 1) [
                            match-pos: dt-input-chunks/1/index
                            resulting-chunks: reduce [dt-input-chunks/1/token dt-input-chunks/1/input]
                        ] [
                            resulting-chunks: copy dt-input-chunks
                        ]
                    ] [
                        code-styles: get-styles to-block source-code
                        obj-type: get-obj-type obj-chunks obj-name code-styles
                        if (is-no-name-equivalent? obj-name (fix-dt filter) code-styles obj-type) [
                            return query-vid-object source-code obj-name [block!]
                        ]
                        return reduce [none obj-chunks]
                    ]
                ] [
                    resulting-chunks: copy datatype-chunks
                ]
            ] [
                if filter = [] [
                    if obj-type-word: find-key-value-in-array obj-chunks ['type word!] [
                        block-type: select (first obj-type-word) 'input
                        all-styled-panels: get-styles-deep/panels to-block source-code
                        if fnd: find/skip all-styled-panels block-type 1 [
                            if blocks-found: find-key-value-in-array obj-chunks ['type block!] [
                                last-no-owner-chunk-in-object: find-no-owner-block obj-chunks
                                last-chunk-in-object: last find-key-value-in-array obj-chunks reduce ['object obj-name]
                                if (last-chunk-in-object/token/y < last-no-owner-chunk-in-object/token/y) [
                                    last-chunk-in-object: last-no-owner-chunk-in-object
                                ]
                                target-pair: to-pair reduce [obj-chunks/1/token/x last-chunk-in-object/token/y]
                                panel-obj-chunks: collect [
                                    foreach line src-cdta [
                                        if (between? line/token/x target-pair) [
                                            keep reduce [line]
                                        ]
                                    ]
                                ]
                                return reduce [target-pair panel-obj-chunks]
                            ]
                        ]
                    ]
                ]
                return reduce [none obj-chunks]
            ]
        ] [
            return reduce [none obj-chunks]
        ]
        if ((length? filter) > 1) [
            if (datatype-filter = word!) [
                if (siba: search-in-block-at/find-in owner-switch-block [2 2 1] input-filter) [
                    block-chunk: pick src-cdta (match-pos + 1)
                    location: to-pair reduce [resulting-chunks/1/x block-chunk/token/y]
                    resulting-chunks: reduce [location resulting-chunks/2 block-chunk/input]
                ]
            ]
        ]
        if match-pos [
            return resulting-chunks
        ]
        foreach chunk resulting-chunks [
            either not (pco: previous-chunk-owns? obj-chunks chunk datatype-filter) [
                return reduce [chunk/token chunk/input]
            ] [
            ]
        ]
        return reduce [none obj-chunks]
    ]
]
