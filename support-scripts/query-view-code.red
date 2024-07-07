Red [
	Title: "query-view-code.red"
	Comment: "Imported from: <root-path>%experiments/query-view-code/query-view-code.red"
]
view-command-to-data: function [
    code-block [block!]
] [
    view-refinements: ["tight" "options" "flags" "no-wait" "no-sync"] 
    refiners: copy [] 
    block-count: 1 
    block-max: 0 
    block-order: copy [] 
    block-vals: copy [] 
    layout-name: copy "" 
    view-command: copy "" 
    view-line?: false 
    parse-results: parse code-block [
        any [
            'view mark: (
                view-command: "view" 
                layout-name: first mark 
                view-line?: true
            ) 
            | any-path! mark: (
                path-string: to-string first back mark 
                path-block: split path-string "/" 
                if path-block/1 = "view" [
                    view-line?: true 
                    view-command: copy path-string 
                    layout-name: first mark 
                    foreach refiner (skip path-block 1) [
                        if find view-refinements refiner [
                            append refiners to-word refiner 
                            if find "options flags" refiner [
                                append block-order to-word refiner 
                                block-max: block-max + 1
                            ]
                        ]
                    ]
                ]
            ) 
            | block! mark: (
                if view-line? [
                    if block-count <= block-max [
                        append block-vals pick block-order block-count 
                        append/only block-vals first back mark 
                    ] 
                    block-count: block-count + 1
                ]
            ) 
            | skip
        ]
    ] 
    return reduce [view-command refiners layout-name block-vals]
] 
get-current-view-code: function [
    view-data [block!] 
    view-code
] [
    view-cmd: 1 
    view-flags: 2 
    view-layout: 3 
    view-block-options: 4 
    source-text: view-code 
    first-fnd: find source-text view-data/:view-cmd 
    first-offset: index? first-fnd 
    second-fnd: find skip source-text first-offset to-string view-data/:view-layout 
    second-offset: index? second-fnd 
    last-blk: last view-data/:view-block-options 
    either last-blk <> none [
        last-string: un-block-string mold last-blk 
        last-fnd: find (skip source-text (second-offset)) last-string 
        last-bracket: find (skip source-text (index? last-fnd)) "]" 
        last-offset: ((index? last-bracket))
    ] [
        last-offset: ((index? second-fnd) + (length? to-string view-data/:view-layout) - 1)
    ] 
    return copy/part skip source-text (first-offset - 1) (last-offset - first-offset + 1)
] 
query-view-code: function [
    view-code [string!]
] [
    cmd-data: view-command-to-data to-block view-code 
    if cmd-data/1 = "" [
        request-message "Unable to locate the view code" 
        exit
    ] 
    curr-cmd: get-current-view-code cmd-data view-code 
    return reduce [curr-cmd cmd-data]
]
