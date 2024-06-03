Red [
	Title: "insert-styled-object.red"
	Comment: "Imported from: <root-path>%experiments/insert-styled-object/insert-styled-object.red"
]
set 'insert-style-code function [
    style-name [string!] 
    style-source [string!] 
    /scenario "style inserted is part of a scenario"
] [
    current-styles: get-styles to-block vid-code/text 
    if not current-styles/(to-word style-name) [
        styles-tail: tail-position-of-styles vid-code/text 
        either styles-tail/y = 0 [
            pre-source: "^-" 
            post-source: newline
        ] [
            pre-source: "^/^-" 
            post-source: ""
        ] 
        if not scenario [
            style-source: remove-setup-style style-name style-source
        ] 
        insert skip vid-code/text styles-tail/y rejoin [pre-source style-source post-source]
    ] 
] 
set 'get-youngest-setup-style-data function [
    style-name [string!] 
    source [string!]
] [
    style-and-source: get-style-source/tree-block style-name source 
    return get-youngest-parent-setup-style style-and-source
] 
set 'get-youngest-parent-setup-style function [
    style-source-block [block!]
] [
    source-style-block: copy/deep style-source-block 
    reverse source-style-block 
    return foreach [source style] source-style-block [
        setup-style-block: get-setup-style-block style source 
        if (not none? setup-style-block) [
            break/return reduce [style source]
        ]
    ] 
    return none
] 
set 'run-youngest-setup-style function [
    "defaults to checking the style-catalog" 
    style-name [string!] 
    target-object-name [string!] 
    /local-file "process the local-file style"
] [
    style-and-source: get-catalog-style/tree-block style-name 
    if youngest-parent: get-youngest-parent-setup-style style-and-source [
        setup-style-block: 2 
        style-name: 1 
        parent-setup: youngest-parent/:setup-style-block 
        append parent-setup rejoin [newline target-object-name ": " youngest-parent/:style-name] 
        return run-setup-style/supply target-object-name 0 "" parent-setup
    ] 
] 
set 'insert-styled-object function [
    "V2 of insert-styled-object" 
    style-name 
    /catalog 
    /scenario "style is being inserted into a scenario"
] [
    before-change-index: vid-code-undoer/action-index 
    if not style-and-source: get-catalog-style/tree-block style-name [
        request-message rejoin ["Style name: " style-name " does not exist in the style catalog"] 
        return false
    ] 
    parent-child-style?: either ((length? style-and-source) > 2) [true] [false] 
    selected-object: either vid-code/selected <> none [
        first find-vid-object/location vid-code/text vid-code/selected
    ] [
        none
    ] 
    foreach [style-name style-source] style-and-source [
        object-type: get-object-style to-block style-source 
        insert-style-code/:scenario style-name style-source 
        if not parent-child-style? [
            insert-vid-object/style/named/pre-selected/:catalog object-type style-name style-name selected-object
        ]
    ] 
    if parent-child-style? [
        style-name: first back back tail style-and-source 
        last-source: back tail style-and-source 
        object-type: get-object-style last-source/1 
        inserted-object-name: insert-vid-object/style/named/pre-selected/:catalog/no-setup object-type style-name style-name selected-object 
        result: run-youngest-setup-style style-name inserted-object-name 
        if not result [
            back-out-vid-changes before-change-index 
            request-message {While attempting to 'insert-styled-object' the 'setup-style' did not complete. Any changes made have been reversed.}
        ]
    ] 
]
