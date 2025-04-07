Red [
	Title: "get-object-renames.red"
	Comment: "Imported from: <root-path>%experiments/get-object-renames/get-object-renames.red"
]
get-last-digits: function [
    "return the last sequence of digits in a string"
    val
    /offset pos "start looking backwards from this position"
    /index "return index position along with digits"
] [
    digit: charset "0123456789"
    digit-pos: copy []
    if not offset [
        pos: length? val
    ]
    forskip val 1 [
        if find digit (char: first val) [
            append digit-pos (index? val)
        ]
    ]
    reverse digit-pos
    in-seq: copy []
    forskip digit-pos 1 [if (first digit-pos) <= pos [break]]
    cur-pos: last-pos: first digit-pos
    foreach loc digit-pos [
        if (dist: cur-pos - loc) <= 1 [
            cur-pos: loc
            append in-seq loc
        ]
    ]
    ndx-res: reduce [last in-seq first in-seq]
    if ndx-res = [none none] [
        val-len: ((length? val) + 1)
        return either index [reduce ["" reduce [val-len val-len]]] [""]
    ]
    results: copy/part (skip val (ndx-res/1 - 1)) (ndx-res/2 - ndx-res/1 + 1)
    return either index [
        reduce [results ndx-res]
    ] [
        results
    ]
]
find-new-name: function [
    wrd [set-word!]
    used-words [block!]
] [
    wrd: to-string wrd
    last-digits: get-last-digits/index wrd
    digit-fld: 1
    offset-fld: 2
    head-part: copy/part wrd (last-digits/:offset-fld/1 - 1)
    tail-part: copy skip wrd (last-digits/:offset-fld/2)
    inc-val: 1
    until [
        new-digits: (to-safe-integer last-digits/:digit-fld) + inc-val
        new-name: rejoin [head-part new-digits tail-part]
        inc-val: inc-val + 1
        not find used-words to-word new-name
    ]
    return new-name
]
get-object-renames: function [
    used-words [block!]
    code [string!]
] [
    renames: copy []
    code-set-words: get-set-words/just to-block code
    foreach wrd code-set-words [
        if fnd: find used-words wrd [
            new-name: find-new-name wrd used-words
            append used-words to-word new-name
            append/only renames reduce [to-string wrd new-name]
        ]
    ]
    return renames
]
