Red [
	Title: "setup-style-to-data.red"
	Comment: "Imported from: <root-path>%experiments/setup-style-to-data/setup-style-to-data.red"
]
dots: does [
    return rejoin [newline {.........................................................} newline]
] 
setup-style-to-data: func [
    code-blocks [block!] "block of blocks" 
    return: [block!]
] [
    object-type: none 
    parse-results: copy [] 
    setup-header: 1 
    if select code-blocks/1 'object [
        code-blocks: reduce [code-blocks] 
    ] 
    return-block: copy [] 
    foreach object-block code-blocks [
        object-header: object-block/1 
        object-block: copy (skip object-block 1) 
        all-entries: copy [] 
        foreach input-entries object-block [
            foreach entry input-entries [
                input-entry: copy [] 
                if (entry/input) [
                    append input-entry (entry/input)
                ] 
                if (entry/action) [
                    append input-entry 'action 
                    append/only input-entry entry/action
                ] 
                append/only all-entries input-entry
            ] 
            insert/only all-entries object-header 
            append/only return-block all-entries
        ]
    ] 
    return return-block
]
