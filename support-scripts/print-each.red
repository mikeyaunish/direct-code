Red [
	Title: "print-each.red"
	Comment: "Imported from: <root-path>%experiments/print-each/print-each.red"
]
pe: print-each: function [
    {print-each item in a block or string with item numbers (v4)}
    'value [block! string! word!]
    /output "return a value rather than print it"
    /deep {show details of all sub-blocks within the main block}
    /depth depth-label [string!] "Used internally by the function for recursion"
    /columns num-of-cols [integer!]
    /width wide [integer!] "Used with /columns to set column width"
    /name display-name [string!]
] [
    either name [
        value-name: rejoin ["'" display-name "' ="]
        if word? value [value: get value]
    ] [
        either (word? value) [
            value-name: rejoin ["'" to-string to-word value "' ="]
            value: get value
        ] [
            value-name: "'<value passed to function>' ="
        ]
    ]
    pad-size: either width [wide] [0]
    results: copy ""
    either depth [
        depth-num: rejoin [to-string depth-label "."]
    ] [
        depth-num: copy ""
        append results value-name
    ]
    index: 1
    item-label: rejoin [depth-num to-string index]
    col-index: 1
    foreach item value [
        either all [
            (block? item)
            deep
        ] [
            append results rejoin [newline item-label ") ----------"]
            append results print-each/depth/output/deep (copy item) item-label
        ] [
            either columns [
                either col-index = 1 [
                    append results rejoin [
                        "^/  "
                        pad/left rejoin [item-label ") "] 5
                        pad mold item pad-size
                    ]
                ] [
                    append results rejoin [
                        " "
                        pad mold item pad-size
                    ]
                ]
                col-index: col-index + 1
                if col-index > num-of-cols [
                    col-index: 1
                ]
            ] [
                append results rejoin [
                    "^/  "
                    pad/left rejoin [item-label ") "] 5
                    mold item
                ]
            ]
        ]
        index: index + 1
        item-label: rejoin [depth-num to-string index]
    ]
    if not depth [
        append results "^/"
    ]
    if output [
        return results
    ]
    print results
]
