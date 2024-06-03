Red [
	Title: "insert-scenario.red"
	Comment: "Imported from: <root-path>%experiments/insert-scenario/insert-scenario.red"
]
insert-scenario: func [
    name [string!] "Scenario name to insert"
] [
    if not scenario-source: get-scenario-source name [
        request-message rejoin ["Scenario named: '" name "' not found."] 
        return ""
    ] 
    selected-object: either vid-code/selected <> none [
        selected-object: first find-vid-object/location vid-code/text vid-code/selected
    ] [
        none
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
    new-names: get-multiple-unused-object-names scenario-styles 
    existing-names: get-names-of-styles scenario-styles scenario-code 
    index: 1 
    all-input-actions: copy [] 
    scenario: is-scenario-file? current-file 
    foreach [set-wrd obj-type] scenario-styles [
        input-action: copy [] 
        target-name: pick new-names index 
        style-source: get-style-source (to-string set-wrd) style-code 
        insert-style-code/:scenario (to-string set-wrd) style-source 
        either input-action-source: select-text-block style-source "setup-style: " [
            input-action-block: load input-action-source
        ] [
            input-action-block: copy [[]]
        ] 
        insert/only input-action reduce [
            'object (to-string obj-type) 
            'style (to-string set-wrd) 
            'target target-name
        ] 
        append/only input-action input-action-block 
        replace scenario-code existing-names/(index) rejoin [new-names/(index) ":"] 
        index: index + 1 
        append/only all-input-actions input-action
    ] 
    either selected-object [
        selected-object-pos: get-object-source-position vid-code/text selected-object 
        last-selected-char: last (copy/part (skip vid-code/text selected-object-pos/x - 1) (selected-object-pos/y - selected-object-pos/x + 1)) 
        if last-selected-char = #"^/" [
            trim-newlines/head scenario-code
        ] 
        append scenario-code "^/" 
        skip-amt: selected-object-pos/y
    ] [
        if (last vid-code/text) = #"^/" [
            trim-newlines/head scenario-code
        ] 
        skip-amt: length? vid-code/text
    ] 
    insert (skip vid-code/text skip-amt) scenario-code 
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
    run-and-save "setup-style" 
    return setup-result
] 
run-scenario-setup: function [
    setup [block!]
] [
] 
get-names-of-styles: function [
    name-type-list [block!] 
    source-code [string!]
] [
    results: copy [] 
    foreach [set-wrd obj-type] name-type-list [
        either fnd: find source-code rejoin [": " to-string set-wrd] [
            label-name: get-previous-word source-code (index? fnd)
        ] [
            label-name: none
        ] 
        append results label-name
    ] 
    return results
] 
get-multiple-unused-object-names: function [
    name-type-list [block!]
] [
    exclude-names: copy "" 
    new-names: copy [] 
    foreach [set-wrd obj-type] name-type-list [
        unused-name: find-unused-object-name/excluding (to-string set-wrd) exclude-names 
        append new-names unused-name 
        append exclude-names rejoin [unused-name ": "]
    ] 
    return new-names
] 
get-non-style-code: func [
    source [string!]
] [
    styles-tail: tail-position-of-styles source 
    return copy (skip source styles-tail/y)
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
