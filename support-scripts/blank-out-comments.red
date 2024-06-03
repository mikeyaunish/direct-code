Red [
	Title: "blank-out-comments.red"
	Comment: "Imported from: <root-path>%experiments/blank-out-comments/blank-out-comments.red"
]
skip-to-line: function [s line-num] [
    if line-num = 1 [return s] 
    fnd-cnt: 1 
    fnd-pos: s 
    while [fnd-cnt < line-num] [
        either (fnd-pos: find (skip fnd-pos 1) "^/") [
            fnd-cnt: fnd-cnt + 1
        ] [
            break
        ]
    ] 
    either fnd-cnt = line-num [
        return skip fnd-pos 1
    ] [
        return false
    ]
] 
blank-out-comments: function [
    "Removes semi-colon comments from source code" 
    source [string!] 
    /line {Removes newline as well if beginning of line is only whitespace} 
    /with replacement-char [char!] {replaces entire comment with this character - to maintain size and spacing}
] [
    s: copy source 
    comments-found: get-comments s 
    reverse/skip comments-found 2 
    replacement: copy "" 
    foreach [line-num comment-string] comments-found [
        if with [
            replacement: copy "" 
            insert/dup replacement replacement-char (length? comment-string)
        ] 
        comment-line: skip-to-line s line-num 
        comment-offset: index? find comment-line comment-string 
        replace comment-line comment-string replacement 
        if line [
            comment-index: index? comment-line 
            comment-preamble: copy/part (skip s (comment-index - 1)) (comment-offset - comment-index) 
            if all-whitespace? comment-preamble [
                remove/part (skip s (comment-index - 2)) (comment-offset - comment-index + 1)
            ]
        ]
    ] 
    return head s
]
