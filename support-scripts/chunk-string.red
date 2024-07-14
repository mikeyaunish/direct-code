Red [
	Title: "chunk-string.red"
	Comment: "Imported from: <root-path>%experiments/chunk-string/chunk-string.red"
]
chunk-string: func [
    {Divides a long string into lengths using the space character as the delimiter} 
    value [string!] "Source string" 
    length [integer!] "Limits line length" 
    /line-separator separator [string! char!] "Changes the default separator from newline"
] [
    if ((length? value) <= length) [
        return value
    ] 
    newline-sep: either line-separator [
        separator
    ] [
        newline
    ] 
    str-offset: 0 
    last-fnd-offset: 0 
    until [
        str-offset: str-offset + length 
        read-pos: skip value str-offset 
        if read-pos = "" [break] 
        if any [
            (space-fnd: find/reverse read-pos " ") 
            (space-fnd: find/reverse read-pos newline-sep) 
            (none = find/reverse read-pos " ")
        ] [
            fnd-offset: either space-fnd [index? space-fnd] [0] 
            either fnd-offset <= last-fnd-offset [
                insert (skip value ((index? read-pos) - 1)) newline-sep 
                str-offset: index? read-pos 
                last-fnd-offset: str-offset
            ] [
                remove/part (skip value (fnd-offset - 1)) 1 
                insert (skip value (fnd-offset - 1)) newline-sep 
                last-fnd-offset: fnd-offset 
                str-offset: fnd-offset
            ]
        ] 
        (read-pos = "")
    ] 
    return value
]
