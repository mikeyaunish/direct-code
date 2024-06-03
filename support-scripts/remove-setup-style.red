Red [
	Title: "remove-setup-style.red"
	Comment: "Imported from: <root-path>%experiments/remove-setup-style/remove-setup-style.red"
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
