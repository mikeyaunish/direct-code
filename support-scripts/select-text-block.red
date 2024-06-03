Red [
	Title: "select-text-block.red"
	Comment: "Imported from: <root-path>%experiments/select-text-block/select-text-block.red"
]
get-file-basename: func [
    filename [file!]
] [
    return to-string first split (second (split-path filename)) "."
] 
extract-to-matching-bracket: function [
    input [string!] {Should be a copied series before it gets here. Not an indexed value.} 
    /only "Exclude outer brackets" 
    /span "Include span in results"
] [
    left-count: 0 
    left-pos: 0 
    right-count: 0 
    right-pos: 0 
    match-span: 0x0 
    completed: [none] 
    parse input [
        any [
            #"[" mark: (
                if left-pos = 0 [
                    left-pos: ((index? mark) - 1)
                ] 
                left-count: left-count + 1 
            ) 
            | "]" mark: (
                right-count: right-count + 1 
                if left-count = right-count [
                    right-pos: ((index? mark) - 1) 
                    match-span: to-pair reduce [left-pos right-pos] 
                    completed: [break]
                ]
            ) 
            completed 
            | skip
        ]
    ] 
    either match-span = 0x0 [
        return none
    ] [
        either only [
            left-adjust: 0 
            right-adjust: -1
        ] [
            left-adjust: -1 
            right-adjust: 1
        ] 
        output: copy/part (skip input (match-span/x + left-adjust)) (match-span/y - match-span/x + right-adjust) 
        if only [
            match-span: match-span + 1x-1
        ] 
        either span [
            return reduce [output match-span]
        ] [
            return output
        ]
    ]
] 
all-space-or-newline?: function [
    val [string!]
] [
    space-newline: 
    foreach char val [
        if not find " ^/" char [
            return false
        ]
    ] 
    return true
] 
trim-newlines: function [
    {trims newline and blanks from series head and tail} 
    val 
    /tail "only trims tail " 
    /head "only trims head "
] [
    if not tail [
        if fnd: find val "^/" [
            segment: copy/part val (index? fnd) 
            if all-space-or-newline? segment [
                remove/part val ((index? fnd))
            ]
        ]
    ] 
    if not head [
        if fnd: find/reverse (tail val) "^/" [
            segment: fnd 
            if all-space-or-newline? segment [
                remove/part (skip (head val) ((index? segment) - 1)) (length? segment)
            ]
        ]
    ] 
    return val
] 
select-text-block: function [
    "V2 17-Dec-2023" 
    input-text [string!] 
    value [string!] 
    /only "Exclude outer brackets" 
    /trim-newline 
    /at offset {find block at this offset ignore value provided. Must not contain any orphan brackets} 
    /span "Include span in results"
] [
    if at [
    ] 
    either at [
        offset-val: copy skip input-text offset 
        if not (res: extract-to-matching-bracket/:only/:span offset-val) [
            return none
        ] 
        results: copy res 
        span-start: offset + 1
    ] [
        if not (fnd: find input-text value) [
            return none
        ] 
        found: copy fnd 
        if not (res: extract-to-matching-bracket/:only/:span found) [
            return none
        ] 
        results: copy res 
        span-start: index? fnd
    ] 
    if span [
        results/2: results/2 + to-pair reduce [(span-start - 1) (span-start - 1)] 
    ] 
    return-value: either trim-newline [
        either span [
            reduce [trim-newlines results/1 results/2]
        ] [
            trim-newlines results
        ]
    ] [
        either span [
            reduce [results/1 results/2]
        ] [
            results
        ]
    ] 
    return return-value
]
