Red [
	Title: "insert-styled-object.red"
	Comment: "Imported from: <root-path>%experiments/insert-styled-object/insert-styled-object.red"
]
remove-setup-style: function [
    "V3 of remove-setup-style"
    style-name [string!]
    source [string!]
    return: [string!]
] [
    setup-style-clue: "setup-style: "
    source-code: copy source
    if not extra-block: select-text-block/span source-code "extra " [
        return source-code
    ]
    if not setup-style-block: select-text-block/span (skip source-code extra-block/2/x) setup-style-clue [
        return source-code
    ]
    span: to-pair reduce [
        char-index?/back source-code (setup-style-block/2/x - (length? setup-style-clue)) #"^/"
        char-index? source-code setup-style-block/2/y #"^/"
    ]
    remove/part (skip source-code span/x) (span/y - span/x)
    if ((length? fnd-extra: find-all source-code "extra ") = 1) [
        orig-extra-block: select-text-block blank-out-comments/line source-code "extra "
        x-block: copy orig-extra-block
        if (trim un-block-string/only x-block) = "" [
            to-replace: rejoin [(first split fnd-extra/1 "[") orig-extra-block]
            replace source-code to-replace ""
            trim-newlines/tail trim/tail source-code
        ]
    ]
    return source-code
]
set 'insert-style-code function [
    {V2 .Insert code in correct location relative to styles}
    style-name [string!]
    style-source [string!]
    /scenario "style inserted is part of a scenario"
    /end-of-script
] [
    current-styles: get-styles to-block vid-code/text
    if not current-styles/(to-word style-name) [
        styles-tail: tail-position-of-styles vid-code/text
        if not scenario [
            style-source: remove-setup-style style-name style-source
        ]
        insert-code/:end-of-script style-source none
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
    style-name [string!]
    target-obj [string! none!]
    /catalog
    /scenario "style is being inserted into a scenario"
    /after
    /end-of-script
] [
    before-change-index: vid-code-undoer/action-index
    if not style-and-source: get-catalog-style/tree-block style-name [
        request-message rejoin ["Style name: " style-name " does not exist in the style catalog"]
        return false
    ]
    parent-child-style?: either ((length? style-and-source) > 2) [true] [false]
    selected-object: either vid-code/selected <> none [
        vid-obj-info/located-at/just-name vid-code/text "" vid-code/selected
    ] [
        get-vid-object-name/last vid-code/text
    ]
    foreach [style-name style-source] style-and-source [
        object-type: get-object-style to-block style-source
        insert-style-code/:scenario style-name style-source
        if not parent-child-style? [
            insert-vid-object/style/named/:catalog/:after/:end-of-script object-type target-obj style-name style-name
        ]
    ]
    if parent-child-style? [
        style-name: first back back tail style-and-source
        last-source: back tail style-and-source
        object-type: get-object-style last-source/1
        inserted-object-name: insert-vid-object/style/named/:catalog/no-setup object-type target-obj style-name style-name
        result: run-youngest-setup-style style-name inserted-object-name
        if not result [
            back-out-vid-changes before-change-index
            request-message {While attempting to 'insert-styled-object' the 'setup-style' did not complete. Any changes made have been reversed.}
        ]
    ]
]
