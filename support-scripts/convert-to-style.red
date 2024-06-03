Red [
	Title: "convert-to-style.red"
	Comment: "Imported from: <root-path>%experiments/convert-to-style/convert-to-style.red"
]
set 'word-in-use? function [
    "Checks if word or style is already being used." 
    the-word [word!]
] [
    return either not value? the-word [
        curr-styles: get-styles to-block vid-code/text 
        either find curr-styles (to-set-word the-word) [
            true
        ] [
            false
        ]
    ] [
        true
    ]
] 
set 'tail-position-of-styles function [
    source-code [string!]
] [
    style-list: get-styles to-block source-code 
    if style-list = [] [
        return 0x0
    ] 
    last-style: copy/part back back tail style-list 1 
    obj-src: get-object-source/position (to-string last-style) source-code 
    return second obj-src
] 
set 'validate-word function [
    value [string!]
] [
    results: validate-all value [
        [
            [
                if (not value? (to-word target)) [
                    target
                ]
            ] 
            ["The word '" target {' is used in the system context. Please try another word.}]
        ] 
        [
            [
                refresh-style-catalog 
                if any [
                    ((to-string second split-path current-file) = rejoin [value "-style.red"]) 
                    (not find dc-catalog-styles target)
                ] [
                    target
                ]
            ] 
            ["The word '" target {' is used in the Style Catalog. Please try another word.}]
        ] 
        [
            [
                refresh-scenario-catalog 
                if any [
                    ((to-string second split-path current-file) = rejoin [value "-scenario.red"]) 
                    (not find dc-scenarios target)
                ] [
                    target
                ]
            ] 
            ["The word '" target {' is used in the Scenario Catalog. Please try another word.}]
        ] 
        [
            [
                local-styles: collect [foreach [x y] (get-styles vid-code/text) [keep x]] 
                if (not find local-styles to-word trim target) [
                    target
                ]
            ] 
            ["The word '" target {' is in use as a local style. Please try another name.}]
        ]
    ] 
    return results
] 
set 'convert-to-style function [
    obj-name [string!] "Object name you want to apply the conversion to" 
    source-code-widget [object!] "Name of the area conatining the source code"
] [
    src-dets: get-object-source/position obj-name source-code-widget/text 
    target: src-dets/1 
    src-pos: src-dets/2 
    offset-detail: none 
    if (copy/part target 2) = "at" [
        offset-detail: split target " " 
        replace target rejoin [offset-detail/1 " " offset-detail/2 " "] "" 
    ] 
    obj-type: first parse (to-block target) [collect [any set-word! keep word! | skip]] 
    style-name: request-text "Enter the name of the style you want to create." 
    if not style-name [
        return ""
    ] 
    style-name: validate-word style-name 
    if not style-name [return ""] 
    style-source: copy target 
    replace style-source (rejoin [obj-name ":"]) rejoin ["style " style-name ":"] 
    styles-tail: tail-position-of-styles source-code-widget/text 
    either styles-tail/y = 0 [
        pre-newline: "" 
        post-newline: newline
    ] [
        pre-newline: newline 
        post-newline: ""
    ] 
    insert skip source-code-widget/text styles-tail/y rejoin [pre-newline "^-" style-source post-newline] 
    src-dets: get-object-source/position/whitespace obj-name source-code-widget/text 
    target: src-dets/1 
    src-pos: src-dets/2 
    remove/part (skip vid-code/text src-dets/3/x - 1) (src-dets/3/y - src-dets/3/x + 1) 
    close-object-editor obj-name 
    either offset-detail [
        offset-pos: to-pair offset-detail/2 
        insert-vid-object/style/named/position/with-offset obj-type style-name obj-name src-pos/x offset-pos
    ] [
        insert-vid-object/style/named/position obj-type style-name obj-name src-dets/3/x
    ] 
]
