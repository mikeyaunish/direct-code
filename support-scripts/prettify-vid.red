Red [
	Title: "prettify-vid.red"
	Comment: "Imported from: <root-path>%experiments/prettify-vid/prettify-vid.red"
]
facet-block-ids: [
    "font" "with" "actors" "extra" "data" "draw" "para" "react"
]
facet-keyword-ids: [
    "rate" "loose" "hidden" "disabled" "focus" "all-over" "wrap" "no-wrap" "hint"
    "top" "middle" "bottom" "left" "center" "right" "bold" "italic" "underline" "strike"
    "rate"
]
panel-block-ids: ["panel" "tab-panel" "group-box"]
break-at: function [
    {Split the series at a position or value, returning the two halves, excluding delim.}
    series [series!]
    delim "Delimiting value, or index if an integer"
    /last {Split at the last occurrence of value, from the tail}
    /local s
] [
    reduce either all [integer? delim not last] [
        parse series [collect [keep delim skip keep to end]]
    ] [
        if string? series [delim: form delim]
        if not find/only series delim [
            return reduce [copy series copy ""]
        ]
        either last [
            reduce [
                copy/part series find/only/last series :delim
                copy find/only/last/tail series :delim
            ]
        ] [
            parse series [collect [keep copy s to delim delim keep to end]]
        ]
    ]
]
break-out-quotes: function [
    str [string!]
] [
    results: copy str
    quote-strings: delim-extract/include-delimiters/pairs-only/indexed results {"} {"}
    append quote-strings (delim-extract/include-delimiters/pairs-only/indexed results "{" "}")
    if quote-strings = [] [return str]
    pair-fld: 2
    insiders: copy []
    forall quote-strings [
        if (length? quote-strings) > 1 [
            item: quote-strings/1
            foreach i (skip quote-strings 1) [
                if (wi-rez: which-inside (item/:pair-fld) (i/:pair-fld)) [
                    append insiders wi-rez
                ]
            ]
        ]
    ]
    foreach inside insiders [
        remove-each r-item quote-strings [
            (r-item/2 = inside)
        ]
    ]
    ret-val: copy []
    curr-str: copy results
    breaker: copy []
    foreach quoted quote-strings [
        breaker: break-at curr-str quoted/1
        if breaker/2 <> "" [
            append ret-val breaker/1
            append ret-val quoted/1
            curr-str: breaker/2
        ]
    ]
    append ret-val breaker/2
    return ret-val
]
set-all-indents: function [
    input [string!]
    indent-amount [integer!]
] [
    results: copy input
    all-broken: break-out-quotes results
    either block? all-broken [
        broken: copy/part all-broken ((length? all-broken) - 1)
        forskip broken 2 [
            replace/all (first broken) "    " "^-"
            indent-string: copy ""
            append/dup indent-string "^-" indent-amount
            indent: rejoin [newline indent-string]
            replace/all (first broken) "^/^-" indent
        ]
        last-broken: last all-broken
        if not char? last-broken [
            replace/all last-broken "    " "^-"
            indent-string: copy ""
            append/dup indent-string "^-" indent-amount
            indent: rejoin [newline indent-string]
            replace/all last-broken "^/^-" indent
            indent-string: copy ""
            append/dup indent-string "^-" (indent-amount - 1)
            indent: rejoin [newline indent-string]
            replace (skip last-broken ((length? last-broken) - 2)) "^/]" rejoin [indent "]"]
        ]
        results: to-string all-broken
    ] [
        replace/all results "    " "^-"
        indent-string: copy ""
        append/dup indent-string "^-" indent-amount
        indent: rejoin [newline indent-string]
        replace/all results "^/^-" indent
        indent-string: copy ""
        append/dup indent-string "^-" (indent-amount - 1)
        indent: rejoin [newline indent-string]
        replace (skip results ((length? results) - 2)) "^/]" rejoin [indent "]"]
    ]
    return to-string results
]
set-indent: function [
    amount [integer!]
    /line
] [
    results: copy either line ["^/"] [""]
    append/dup results "^-" amount
]
get-record: function [
    {return the record by the index, none if out of bounds}
    cdta [block!]
    index [integer!]
] [
    if any [
        (index < 1)
        (index > (length? cdta))
    ] [
        return none
    ]
    return cdta/:index
]
object-lines-to-code: closure [
    last-indent: 0 [integer!]
    disable-plain-item-indent?: false
    object-indent-table: [] {internal record of indent required for each object}
] [
    code-cdta [block!]
    indent-amount [integer!] "number of tab indents to use to start with"
    next-record [block! none!] "next record"
    /init "Zeros out the internal object-indent-table"
] [
    split-at: 80
    if init [
        object-indent-table: copy []
        last-indent: 0
        disable-plain-item-indent?: false
        return none
    ]
    indent-required?: true
    results: copy ""
    orig-indent: indent-amount
    left-margin: indent-amount
    facet-block-indent: 0
    actor-block-indent: 0
    if last-indent > indent-amount [
        indent-amount: last-indent
        either disable-plain-item-indent? [
            disable-plain-item-indent?: false
        ] [
            plain-item-indent-required?: true
        ]
    ]
    index: 1
    code-cdta-length: length? code-cdta
    while [index <= code-cdta-length] [
        line-type: "plain-item"
        if find facet-block-ids code-cdta/:index/input [
            line-type: "facet-block"
        ]
        if find dc-actor-list code-cdta/:index/input [
            line-type: "actor-block"
        ]
        if find panel-block-ids code-cdta/:index/input [
            line-type: "panel-block"
        ]
        if code-cdta/:index/input = "do" [
            line-type: "do-block"
        ]
        if code-cdta/:index/type = 'block-start [
            line-type: "block-start"
        ]
        if code-cdta/:index/type = 'block-end [
            line-type: "block-end"
        ]
        switch (line-type) [
            "block-start" [
                prettify-block?: any [
                    ((to-string code-cdta/:index/token) = (select next-record 'input))
                    all [
                        ((select next-record 'parent) <> "")
                        ((select next-record 'parent) <> "~")
                        (code-cdta/:index/object <> (select next-record 'parent))
                    ]
                ]
                either prettify-block? = true [
                    append results "["
                    pretty-results: mold dc-prettify/split-at to-block un-block-string copy code-cdta/:index/input 0
                    un-block-string/only pretty-results
                    indented-string: set-all-indents pretty-results (indent-amount + 2)
                    append results indented-string
                ] [
                    append results set-indent/line (indent-amount + 1)
                    append results "["
                ]
                append results newline
                indent-amount: indent-amount + 2
                index: index + 1
                disable-plain-item-indent?: true
                indent-required?: true
            ]
            "block-end" [
                append results set-indent/line (indent-amount - 1)
                append results "]^/ "
                indent-amount: indent-amount - 2
                disable-plain-item-indent?: true
                index: index + 1
                indent-required?: true
            ]
            "facet-block" [
                append results set-indent/line (indent-amount + 1)
                append results rejoin [code-cdta/:index/input " "]
                index: index + 1
                facet-block-indent: indent-amount + 2
                indent-required?: false
            ]
            "actor-block" [
                append results set-indent/line (indent-amount + 1)
                append results rejoin [code-cdta/:index/input " "]
                index: index + 1
                actor-block-indent: indent-amount + 2
            ]
            "panel-block" [
                append results rejoin [code-cdta/:index/input " "]
                index: index + 1
            ]
            "do-block" [
                pretty-results: mold dc-prettify/split-at to-block un-block-string copy code-cdta/(:index + 1)/input 0
                un-block-string/only pretty-results
                indented-string: set-all-indents pretty-results (indent-amount + 1)
                append results rejoin [
                    set-indent indent-amount
                    "do [^/"
                    indented-string
                    newline
                    set-indent indent-amount
                    "]^/ "
                ]
                index: index + 2
                indent-required?: true
            ]
            "plain-item" [
                case [
                    (
                        if (to-string code-cdta/:index/type) = "block" [
                            any [
                                facet-block-indent > 0
                                actor-block-indent > 0
                            ]
                        ]
                    )
                    [
                        either all [
                            (index - 1) > 0
                            code-cdta/(index - 1)/input = "draw"
                        ] [
                            pretty-results: mold dc-prettify/draw/split-at to-block un-block-string copy code-cdta/:index/input 0
                        ] [
                            pretty-results: mold dc-prettify to-block un-block-string copy code-cdta/:index/input
                            if find facet-keyword-ids code-cdta/:index/input [
                                actor-block-indent: actor-block-indent - 1
                            ]
                        ]
                        indented-string: set-all-indents pretty-results max facet-block-indent actor-block-indent
                        append results rejoin [indented-string " "]
                        facet-block-indent: 0
                        actor-block-indent: 0
                    ]
                    true [
                        previous-item: get-record code-cdta (index - 1)
                        if (select previous-item 'object) <> code-cdta/:index/object [
                            either fnd: find-in-array-at object-indent-table 1 code-cdta/:index/object [
                                if code-cdta/:index/parent = "" [
                                    indent-amount: (fnd/2 + 1)
                                ]
                            ] [
                                upsert/only object-indent-table reduce [code-cdta/:index/object indent-amount]
                            ]
                        ]
                        previous-item: get-record code-cdta (index - 1)
                        if (select previous-item 'type) = block! [
                            fnd: find-in-array-at object-indent-table 1 code-cdta/:index/object
                            append results set-indent/line (fnd/2 + 1)
                            indent-required?: false
                        ]
                        if indent-required? [
                            append results set-indent indent-amount
                            indent-required?: false
                        ]
                        switch/default (to-string code-cdta/:index/type) [
                            "file" [
                                append results rejoin [(mold to-file trim to-string code-cdta/:index/input) " "]
                            ]
                        ] [
                            append results rejoin [code-cdta/:index/input " "]
                        ]
                    ]
                ]
                index: index + 1
            ]
        ]
    ]
    remove/part (back tail results) 1
    append results newline
    object-head: first split-series: split results "^/"
    if (spaced-length? object-head) > split-at [
        split-results: split-with-underdent (trim/tail (first (split-series))) (indent-amount + 1)
        results: rejoin [split-results "^/"]
        foreach item (skip split-series 1) [
            if item <> "" [
                append results rejoin [item "^/"]
            ]
        ]
    ]
    last-indent: indent-amount
    results
]
find-block-end: function [
    cdta
    index
] [
    block-line: copy cdta/:index
    while [index <= (length? cdta)] [
        if any [
            cdta/:index/token/y > block-line/token/y
        ] [
            return (index - 1)
        ]
        index: index + 1
    ]
    return false
]
is-a-layout-block?: function [
    cdta [block!]
    index [integer!]
    source [string!]
] [
    cdta-block: cdta/:index
    if cdta-block/type = block! [
        if all [
            cdta-block/parent <> "~"
            cdta-block/parent <> ""
        ] [
            return true
        ]
        if cdta-block/parent = "~" [
            all-panel-types: copy ["panel" "group-box" "tab-panel"]
            custom-panel-types: get-panel-styles to-block source
            foreach [custom-name panel-type] custom-panel-types [
                append all-panel-types to-string custom-name
            ]
            prev-index: index - 1
            until [
                if (to-string cdta/:prev-index/type) = "word" [
                    if find all-panel-types cdta/:prev-index/input [
                        return true
                    ]
                ]
                if cdta/:prev-index/object <> cdta-block/object [
                    return false
                ]
                prev-index: prev-index - 1
                (prev-index = 0)
            ]
        ]
    ]
    return false
]
add-format-markers: function [
    cdta [block!]
    source [string!]
] [
    format-num: 1
    index: (length? cdta)
    while [index > 0] [
        next-index: index + 1
        prev-index: index - 1
        layout-block?: false
        layout-block?: is-a-layout-block? cdta index source
        if prev-index > 0 [
            if cdta/:prev-index/input = "do" [
                block-end: find-block-end cdta index
                if not block-end [
                    block-end: length? cdta
                ]
                format-name: rejoin ["format" format-num]
                cdta/:prev-index/object: format-name
                cdta/:index/object: format-name
                loop (block-end - index) [
                    remove skip cdta index
                ]
                layout-block?: false
            ]
            if find ["data" "with" "extra" "draw" "font" "do"] cdta/:prev-index/input [
                layout-block?: false
            ]
        ]
        if layout-block? [
            cdta/:index/type: (to-lit-word 'block-start)
            block-end: find-block-end cdta index
            either block-end [
                insert/only (skip cdta block-end)
                reduce ['index 0 'object "" 'input (to-string cdta/:index/token) 'type (to-lit-word 'block-end) 'token 0x0 'line 0 'parent ""]
            ] [
                append/only cdta reduce ['index 0 'object "" 'input (to-string cdta/:index/token) 'type (to-lit-word 'block-end) 'token 0x0 'line 0 'parent ""]
            ]
        ]
        if find ["across" "below" "return" "space" "pad" "origin" "size" "title" "do" "backdrop"] cdta/:index/input [
            cdta/:index/object: rejoin ["format" format-num]
            if cdta/:index/input <> "return" [
                cdta/(index + 1)/object: rejoin ["format" format-num]
            ]
            format-num: format-num + 1
        ]
        index: index - 1
    ]
    return cdta
]
sequential: function [
    {returns only values in a series that are in a sequential order}
    series [series!]
    /key key-id [word! integer!] {Can be a word or number to ID the locate value to use for comparison}
] [
    series-len: length? series
    if series-len = 1 [
        return series
    ]
    either key [
        either word? key-id [
            picker: func [v] [select v key-id]
        ] [
            picker: func [v] [pick v key-id]
        ]
    ] [
        picker: func [v] [v]
    ]
    index: 2
    prev-val: picker (first series)
    val: picker (second series)
    upto: until [
        if (val - prev-val) <> 1 [
            break/return (index - 1)
        ]
        prev-val: val
        index: index + 1
        either index > series-len [
            break/return series-len
        ] [
            val: picker series/:index
        ]
        false
    ]
    return copy/part series upto
]
valid-prettify-vid: func [
    input [string!]
] [
    if not all-objects-named? [return -1]
    p-string: copy ""
    plain-red-block: to-block input
    p-string: prettify-vid input
    prettified-block: to-block p-string
    if (load mold/flat plain-red-block) = (load mold/flat prettified-block) [
        return p-string
    ]
    print ["#VALID-PRETTIFY-VID **** FAILED ***"]
    the-diff: difference (load mold/flat plain-red-block) (load mold/flat prettified-block)
    pe the-diff
    print "run comp-it to see comparison"
    comp-it: does [
        compare (pe/deep/output plain-red-block) (pe/deep/output prettified-block)
    ]
    return false
]
prettify-vid: function [
    "31-Jan-2025 Version"
    input [string!]
    /extern fixed-cdta
] [
    edge-of-whitespace: whitespace-edge/start input 0
    indent-string: copy/part input edge-of-whitespace
    indent-count: (length? split indent-string #"^-")
    indent-count: max (indent-count - 1) 0
    input: mold/only/flat load input
    cdta: vid-cdta input
    cdta: add-format-markers cdta input
    cdta-length: length? cdta
    index: 1
    bad-count: 1
    output: copy ""
    object-lines-to-code/init [] 0 []
    while [index <= cdta-length] [
        object: cdta/:index/object
        either object <> "" [
            all-object-lines: sequential/key (find-key-value-in-array (skip cdta (index - 1)) reduce ['object object]) 'index
            all-object-lines-index: sequential (find-key-value-in-array/index (skip cdta (index - 1)) reduce ['object object])
            first-index: first all-object-lines-index
            last-index: last all-object-lines-index
            all-object-lines-indexed: copy/part
            (skip all-object-lines (first-index - 1))
            (last-index - first-index + 1)
            next-record: get-record cdta (last-index + index)
            append output object-lines-to-code all-object-lines-indexed indent-count next-record
            index: index + last-index
        ] [
            next-record: get-record cdta (index + 1)
            append output object-lines-to-code reduce [cdta/:index] indent-count next-record
            index: index + 1
        ]
    ]
    return remove-blank-lines output
]
spaced-length?: function [
    series
] [
    s: copy series
    replace/all s "^-" "    "
    return length? s
]
remove-blank-lines: function [
    input [string!]
] [
    split-input: split input "^/"
    remove-each line split-input [
        all-whitespace? line
    ]
    results: copy ""
    foreach line split-input [
        append results rejoin [line "^/"]
    ]
    remove back tail results
    return results
]
split-tab-prefix: function [
    series [string!]
] [
    index: 1
    foreach char series [
        either char = #"^-" [
            index: index + 1
        ] [
            break
        ]
    ]
    index: index - 1
    return reduce [(copy/part series index) (copy (skip series index))]
]
has-previous-owner?: function [
    cdta
    index
] [
    datatype-owners: [
        ["integer" ["font-size"]]
        ["string" ["font-name" "hint"]]
        ["tuple" ["font-color" "backdrop"]]
        ["time" ["rate"]]
        ["pair" ["origin" "space" "pad" "size"]]
    ]
    if fnd-owner: find-in-array-at datatype-owners 1 (to-string cdta/:index/type) [
        if all [
            ((index - 1) > 0)
            (index - 1) <= (length? cdta)
        ] [
            prev-item-input: cdta/(index - 1)/input
            if find fnd-owner/2 prev-item-input [
                return true
            ]
        ]
    ]
    return false
]
split-with-underdent: function [
    series [string!]
    underdent-amount [integer!]
] [
    max-length: 80
    keyword-only-facets: ["loose" "focus" "right" "bottom" "left" "bold" "italic" "all-over" "hidden" "disabled" "underline" "no-border" "wrap"]
    keyword-value-facets: ["font-name" "font-size" "font-color" "font" "hint"]
    datatype-only-facets: ["pair" "tuple" "file" "date" "percent" "logic" "url" "integer" "percent" "point2D" "point3D" "string" "word"]
    break-pos: 0
    scan-at: max-length
    break-count: 0
    header-split: split-tab-prefix series
    series: copy header-split/2
    while [
        ((spaced-length? series) > scan-at)
    ] [
        series-cdta: vid-cdta-flat series
        scan-index: 1
        foreach item series-cdta [
            if item/token/y > scan-at [
                break
            ]
            scan-index: scan-index + 1
        ]
        index: scan-index - 1
        while [index > 0] [
            break-type: none
            break-after-string: false
            if find keyword-only-facets series-cdta/:index/input [
                break-pos: series-cdta/:index/token/y
                break-type: 'keyword-only
                break
            ]
            if find keyword-value-facets series-cdta/:index/input [
                break-pos: series-cdta/:index/token/y
                break-type: 'keyword-value
                break
            ]
            if find datatype-only-facets (to-string series-cdta/:index/type) [
                if not has-previous-owner? series-cdta index [
                    if all [
                        (to-string series-cdta/:index/type) = "string"
                        (length? series-cdta/:index/input) > (max-length + 2)
                    ] [
                        break-after-string: true
                    ]
                    break-pos: series-cdta/:index/token/y
                    break-type: 'datatype-only
                    break
                ]
            ]
            index: index - 1
        ]
        if none? break-type [break]
        if break-type = 'keyword-only [
        ]
        if find ['keyword-value 'datatype-only] break-type [
            break-pos: (series-cdta/:index/token/x - 1)
        ]
        insert (skip series (break-pos)) set-indent/line underdent-amount
        break-count: break-count + 1
        if break-after-string [
            break-pos: series-cdta/:index/token/y + underdent-amount + 1
            insert (skip series (break-pos)) set-indent/line underdent-amount
            break-count: break-count + 1
        ]
        scan-at: break-pos + max-length
        two-ahead-index: index + 2
        either two-ahead-index <= (length? series-cdta) [
            if scan-at < two-ahead-right-edge: (series-cdta/:two-ahead-index/token/y + (underdent-amount * 4 * break-count) + 2) [
                scan-at: two-ahead-right-edge
            ]
        ] [
            scan-at: (spaced-length? series) + 1
        ]
    ]
    return rejoin [header-split/1 series]
]
