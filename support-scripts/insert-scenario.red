Red [
	Title: "insert-scenario.red"
	Comment: "Imported from: <root-path>%experiments/insert-scenario/insert-scenario.red"
]
set 'insert-scenario func [
    "V2 using new insert-code "
    name [string!] "Scenario name to insert"
    target-obj [string! none!] {object name to do insertion relative to. none! indicates at top (after styles)}
    /after "insert-after instead of default of insert-before"
    /end-of-script
] [
    if not scenario-source: get-scenario-source name [
        request-message rejoin ["Scenario named: '" name "' not found."]
        return ""
    ]
    before-change-index: vid-code-undoer/action-index
    scenario-source-block: load scenario-source
    layout-block: (scenario-source-block/(to-word rejoin [name "-scenario-layout"]))
    layout-source: un-block-string
    select-text-block blank-out-comments/line scenario-source rejoin [name "-scenario-layout: "]
    code-segments: split-code layout-source
    scenario-styles: get-styles layout-source
    style-code: copy code-segments/1
    scenario-code: code-segments/2
    vid-set-words: get-set-words to-block vid-code/text
    scenario-object-names: get-names-of-styles scenario-styles scenario-code
    scenario-styled-obj-names: get-styled-obj-names scenario-styles scenario-code
    obj-renames: get-object-renames vid-set-words scenario-code
    foreach renaming obj-renames [
        replace scenario-code (rejoin [renaming/1 ":"]) rejoin [renaming/2 ":"]
    ]
    all-input-actions: copy []
    scenario: is-scenario-file? current-file
    existing-styles: get-all-vid-styles vid-code/text
    all-input-actions: generate-input-actions scenario-code scenario-styles style-code existing-styles
    foreach renaming obj-renames [
        replace scenario-code (rejoin [renaming/1 ":"]) rejoin [renaming/2 ":"]
    ]
    foreach [style-name obj-type] scenario-styles [
        the-style-name: to-string style-name
        if not find existing-styles the-style-name [
            style-source: get-style-source the-style-name style-code
            insert-style-code/:scenario the-style-name style-source
        ]
    ]
    if not none? target-obj [
        set [target-obj chk-obj-type] if-style-obj-get-last-style-obj target-obj
        if chk-obj-type = 'styled [
            after: true
            end-of-script: false
        ]
    ]
    insert-code/:after/:end-of-script scenario-code target-obj
    run-and-save "insert-scenario-stage-1"
    req-result: request-setup-style all-input-actions reduce ["scenario" name]
    if not req-result [
        back-out-vid-changes before-change-index
        request-message {While attempting to 'insert-scenario' the 'setup-style' did not complete. Any changes made have been reversed.}
        return false
    ]
    if not setup-result: process-setup-requester req-result [
        back-out-vid-changes before-change-index
        request-message {While attempting to 'insert-scenario' the 'setup-style' did not complete. Any changes made have been reversed.}
        return false
    ]
    clear-vid-code-selected
    run-and-save "setup-style"
    return setup-result
]
get-styled-obj-names: function [
    name-type-list [block!]
    source-code [string!]
] [
    results: copy []
    set-words: get-set-words to-block source-code
    style-names: collect [
        foreach [set-wrd style-name] name-type-list [
            keep to-string set-wrd
        ]
    ]
    results: collect [
        foreach [set-word style-name] set-words [
            if find style-names (to-string style-name) [
                keep to-string set-word
            ]
        ]
    ]
    return results
]
get-names-of-styles: function [
    name-type-list [block!]
    source-code [string!]
] [
    results: copy []
    foreach [set-wrd obj-type] name-type-list [
        either fnd: find source-code rejoin [": " to-string set-wrd] [
            label-name: trim/tail/with (get-previous-word source-code (index? fnd)) ":"
        ] [
            label-name: none
        ]
        append results label-name
    ]
    return results
]
split-code: func [
    "split code into 2 segments: 1.)style 2.)non-style"
    source [string!]
] [
    style-tail: tail-position-of-styles source
    return reduce [
        (copy/part source style-tail/y + 1)
        (copy skip source style-tail/y)
    ]
]
get-scenario-source: func [
    name [string!]
] [
    if not find dc-scenarios name [
        return false
    ]
    return read rejoin [dc-scenario-catalog-path rejoin [name "-scenario.red"]]
]
