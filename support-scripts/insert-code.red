Red [
	Title: "insert-code.red"
	Comment: "Imported from: <root-path>%experiments/insert-code/insert-code.red"
]
set 'is-EOF? function [
    source
    offset
] [
    src-len: length? source
    if offset = src-len [return true]
    past-offset: copy/part (skip vid-code/text (offset - 1)) (src-len - offset + 1)
    all-whitespace? past-offset
]
set 'insert-code function [
    {V2 insert code. insert-before is DEFAULT^M^/        ^-- sufix/prefix is handled. Defaults to insert-before target-obj^M^/        ^-}
    code [string!]
    target-obj [string! none!] {object name to do insertion relative to. none! indicates at top (after styles)}
    /after "insert-after target-obj"
    /end-of-script "beyond everything including returns etc.."
    /style "The code is style code"
    /local prefix suffix
] [
    code-copy: copy code
    trim/head/tail code-copy
    if style [
        insert-pos: second (tail-position-of-styles vid-code/text)
        insert-pos-value: pick vid-code/text insert-pos
        suffix: ""
        prefix: "^-"
        if ((length? vid-code/text) > 0) [
            suffix: newline
            if insert-pos <> 0 [
                if insert-pos-value <> #"^/" [prefix: "^/^-"]
            ]
        ]
    ]
    if all [
        target-obj
        not end-of-script
    ] [
        target-obj-loc: get-object-source/position/whitespace target-obj vid-code/text
        if not target-obj-loc [
            exit
        ]
        prefix: copy ""
        suffix: copy ""
        if not after [
            pos: target-obj-loc/2/x
            left-edge: target-obj-loc/3/x
            suffix: " "
            prev-square-bracket: char-index?/back vid-code/text pos #"["
            prev-newline: char-index?/back vid-code/text pos #"^/"
            if all [
                prev-square-bracket > prev-newline
                all-whitespace? (copy/part (skip vid-code/text prev-square-bracket) (pos - prev-square-bracket - 1))
            ] [
                pos-to-bracket-span: pos - prev-square-bracket
                span-str: copy/part (skip vid-code/text prev-square-bracket) (pos - prev-square-bracket - 1)
                prefix: ""
                indent-chars: get-indent-chars vid-code/text pos
                suffix: rejoin [newline indent-chars tab]
                left-edge: prev-square-bracket
            ]
            if prev-square-bracket <= prev-newline [
                edge-of-whitespace: whitespace-edge/reverse/with-newline vid-code/text pos
                prefix: get-indent-chars vid-code/text pos
                if prefix = "" [prefix: tab]
                either prev-newline < edge-of-whitespace [
                    suffix: rejoin [newline prefix]
                    prefix: ""
                    left-edge: pos - 1
                ] [
                    suffix: newline
                    left-edge: edge-of-whitespace
                ]
            ]
            insert-pos: either left-edge >= 0 [
                left-edge
            ] [
                pos - 1
            ]
        ]
        if after [
            right-edge: pos: target-obj-loc/3/y
            suffix: " "
            next-right-bracket: char-index? vid-code/text pos #"]"
            next-newline: char-index? vid-code/text pos #"^/"
            if is-EOF? vid-code/text next-newline [
                next-newline: 0
                suffix: ""
            ]
            if all [
                next-right-bracket < next-newline
                next-right-bracket <> 0
                all-whitespace? (copy/part (skip vid-code/text pos) (next-right-bracket - pos - 1))
            ] [
                obj-to-newline-span: next-right-bracket - pos
                span-str: copy/part (skip vid-code/text pos) (next-right-bracket - pos - 1)
                prefix: ""
                suffix: newline
                indent-chars: get-indent-chars vid-code/text pos
                right-edge: either (next-right-bracket - 1) = pos [
                    prefix: rejoin [newline "^-" indent-chars]
                    suffix: rejoin [newline indent-chars]
                    pos
                ] [
                    next-right-bracket
                ]
            ]
            if any [
                next-right-bracket >= next-newline
                next-right-bracket = 0
            ] [
                edge-of-whitespace: whitespace-edge/with-newline vid-code/text pos
                prefix: get-indent-chars vid-code/text pos
                if prefix = "" [prefix: "^-"]
                either (next-newline = 0) [
                    if prefix <> "^-" [
                        remove prefix
                    ]
                    insert prefix newline
                    right-edge: pos
                ] [
                    right-edge: edge-of-whitespace
                ]
                suffix: either next-newline = 0 [""] [newline]
            ]
            insert-pos: either right-edge >= 0 [
                right-edge
            ] [
                pos - 1
            ]
        ]
    ]
    if all [
        end-of-script
        after
    ] [
        either (length? vid-code/text) > 0 [
            printable: complement charset "^-^/^M "
            last-print-char: find/reverse (tail vid-code/text) printable
            last-print-pos: (index? last-print-char)
            prev-vid-obj: vid-obj-info/located-at/position vid-code/text "" to-pair reduce [last-print-pos last-print-pos]
            insert-pos: last-print-pos
            either prev-vid-obj [
                prefix: rejoin [newline get-indent-chars vid-code/text prev-vid-obj/2/x]
            ] [
                prefix: "^-"
            ]
            suffix: ""
        ] [
            insert-pos: 0
            prefix: "^-"
            suffix: ""
        ]
    ]
    insert (skip vid-code/text insert-pos) rejoin [prefix code-copy suffix]
]
