Red [
	Title: "generate-input-actions.red"
	Comment: "Imported from: <root-path>%experiments/generate-input-actions/generate-input-actions.red"
]
generate-input-actions: function [
    {returns a input-action block, also insert-style-code appropriately}
    scenario-code
    scenario-styles
    style-code
    existing-styles
    /local input-action all-input-actions input-action-block
] [
    all-input-actions: copy []
    scenario-set-words: get-set-words to-block scenario-code
    scenario-styles: collect [
        foreach [set-word style-name] scenario-styles [
            keep to-string set-word
            keep to-string style-name
        ]
    ]
    foreach [set-word style-name] scenario-set-words [
        the-style-name: to-string style-name
        if fnd: find/skip scenario-styles the-style-name 2 [
            input-action: copy []
            target-name: to-string set-word
            style-source: get-style-source the-style-name style-code
            either input-action-source: select-text-block style-source "setup-style: " [
                input-action-block: load input-action-source
            ] [
                input-action-block: copy [[]]
            ]
            insert/only input-action reduce [
                'object (second fnd)
                'style the-style-name
                'target target-name
            ]
            append/only input-action input-action-block
            append/only all-input-actions input-action
        ]
    ]
    return all-input-actions
]
