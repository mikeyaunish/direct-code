Red [
	Title: "text-undoer.red"
	Comment: "Imported from: <root-path>%experiments/text-undoer/text-undoer.red"
]
text-undoer: context [
    current-text: copy "" 
    action-index: 0 
    actions: copy [] 
    trim-actions: function [action-block] [
        result: copy [] 
        r-block: copy action-block/1 
        i-block: copy action-block/2 
        r-text: copy r-block/4 
        i-text: copy i-block/4 
        ndx: 1 
        r-char: back tail r-text 
        i-char: back tail i-text 
        ndx: 0 
        while [(first r-char) == (first i-char)] [
            ndx: ndx + 1 
            r-char: back r-char 
            i-char: back i-char
        ] 
        if (ndx < (length? r-text)) [
            append/only result reduce ['r r-block/2 (r-block/3 - ndx) (copy/part r-block/4 ((length? r-block/4) - ndx))]
        ] 
        if (ndx < (length? i-text)) [
            append/only result reduce ['i i-block/2 (i-block/3 - ndx) (copy/part i-block/4 ((length? i-block/4) - ndx))]
        ] 
        return result
    ] 
    status: func [] [
        print ["current-text =  {" mold/part current-text 70 "...)"] 
        print ["action-index = " action-index] 
        print-each actions
    ] 
    set-initial-text: func [val [string!]] [
        action-index: 0 
        actions: copy [] 
        current-text: copy val 
    ] 
    post-changed-text: func [
        val [string!] 
        /local new-actions
    ] [
        if current-text == val [
            return none
        ] 
        if val = "" [
            return ""
        ] 
        if not-equal? action-index (length? actions) [
            remove/part skip actions action-index (length? actions) 
            action-index: (length? actions) 
        ] 
        if new-actions: compare-text current-text val [
            append/only actions copy new-actions 
            action-index: action-index + 1 
            current-text: copy val
        ] 
    ] 
    run-actions: function [
        {Run the redo operations by default - gathered from the compare-text function} 
        action-block [block!] 
        input [string!] 
        /undo "Run the undo operation" 
        return: [string!]
    ] [
        actions: copy action-block 
        action: 1 
        offset: 2 
        length: 3 
        value: 4 
        insert-action: 'i 
        remove-action: 'r 
        either undo [
            insert-action: 'r 
            remove-action: 'i
        ] [
            reverse actions
        ] 
        foreach act actions [
            if block? act/:action [
                the-act: copy act 
                run-actions/:undo reverse the-act input
            ] 
            if act/:action = insert-action [
                insert (skip input (act/:offset - 1)) act/:value
            ] 
            if act/:action = remove-action [
                remove/part (skip input (act/:offset - 1)) act/:length
            ]
        ] 
        return input
    ] 
    undo: does [
        if action-index > 0 [
            diff-data: pick actions action-index 
            action-index: action-index - 1 
            return run-actions/undo diff-data current-text
        ] 
        return none
    ] 
    redo: does [
        action-index: action-index + 1 
        if action-index <= length? actions [
            diff-data: pick actions action-index 
            return run-actions diff-data current-text
        ] 
        action-index: action-index - 1 
        return none
    ] 
    back-out-changes: function [
        target-index [integer!]
    ] [
        while [action-index > (target-index + 1)] [
            undo
        ] 
        return undo
    ] 
    get-mismatch: function [s1 s2] [
        index: 1 
        while [(s1/:index) == (s2/:index)] [
            index: index + 1
        ] 
        return reduce [index s1/:index s2/:index]
    ] 
    pick-word: function [
        string [string!] 
        index [integer!]
    ] [
        pick delim-split string [" " "^/"] index
    ] 
    last-word-index?: function [s] [
        return index? find/reverse tail s (last delim-split s [" " "^/"])
    ] 
    get-shortest-distance: function [diff-end-block] [
        shortest: copy [0 9999999] 
        index: 0 
        foreach item diff-end-block [
            index: index + 1 
            if (abs-val: absolute item/1 - item/2) < shortest/2 [
                shortest: reduce [index abs-val]
            ]
        ] 
        return pick diff-end-block shortest/1
    ] 
    find-end-diff: function [
        s1 [string!] 
        s2 [string!] 
        offset [integer!] 
        /extern zglobal
    ] [
        results: copy [] 
        distance-trip-line: 20 
        max-refind: 6 
        offset: offset - 1 
        orig-s1: copy s1 
        orig-s2: copy s2 
        s1: a: copy skip s1 offset 
        s2: b: copy skip s2 offset 
        word-num: 1 
        found-count: 0 
        b-next?: true 
        while [test-word: pick-word a word-num] [
            if b-fnd: find/case b test-word [
                found-count: found-count + 1 
                a-fnd: find/case a test-word 
                distance: absolute (index? a-fnd) - (index? b-fnd) 
                either b-next? [
                    either distance > distance-trip-line [
                        append/only results reduce [(index? a-fnd) + offset (index? b-fnd) + offset test-word]
                    ] [
                        return reduce [(index? a-fnd) + offset (index? b-fnd) + offset test-word]
                    ]
                ] [
                    either distance > distance-trip-line [
                        append/only results reduce [(index? b-fnd) + offset (index? a-fnd) + offset test-word]
                    ] [
                        return reduce [(index? b-fnd) + offset (index? a-fnd) + offset test-word]
                    ]
                ]
            ] 
            if found-count > 1 [
            ] 
            if found-count = max-refind [break] 
            either b-next? [
                b: s1 
                a: s2 
                b-next?: false
            ] [
                word-num: word-num + 1 
                a: s1 
                b: s2 
                b-next?: true
            ]
        ] 
        either results = [] [
            return reduce [(length? orig-s1) + 1 (length? orig-s2) + 1 test-word]
        ] [
            return get-shortest-distance results
        ]
    ] 
    compare-text: function [
        {return a block of changes. i = insert, r = remove, block! [ r and i ] = change } 
        str1 [string!] 
        str2 [string!] 
        return: [block!]
    ] [
        results: copy [] 
        if str1 == str2 [
            return none
        ] 
        end-of-file: none 
        index1: 0 
        index2: 0 
        len-str1: length? str1 
        len-str2: length? str2 
        count: 0 
        forever [
            count: count + 1 
            if count > 1000 [
                break
            ] 
            string1: skip str1 index1 
            string2: skip str2 index2 
            if string1 == string2 [
                return results
            ] 
            diff-start: get-mismatch string1 string2 
            if diff-start/2 = end-of-file [
                diff-string: copy/part skip string2 (diff-start/1 - 1) ((length? string2) - diff-start/1 + 1) 
                append/only results reduce ['i (diff-start/1 + index1) ((length? string2) - diff-start/1 + 1) diff-string] 
                return results
            ] 
            if diff-start/3 = end-of-file [
                diff-string: copy/part skip string1 (diff-start/1 - 1) ((length? string1) - diff-start/1 + 1) 
                append/only results reduce ['r (diff-start/1 + index1) ((length? string1) - diff-start/1 + 1) diff-string] 
                return results
            ] 
            if diff-end: find-end-diff string1 string2 diff-start/1 [
                diff-string1: copy/part skip string1 (diff-start/1 - 1) (diff-end/1 - diff-start/1) 
                diff-string2: copy/part skip string2 (diff-start/1 - 1) (diff-end/2 - diff-start/1) 
                if diff-string1 = "" [
                    append/only results reduce ['i (diff-start/1 + index1) (diff-end/2 - diff-start/1) diff-string2]
                ] 
                if diff-string2 = "" [
                    append/only results reduce ['r (diff-start/1 + index1) (diff-end/1 - diff-start/1) diff-string1]
                ] 
                if all [
                    diff-string1 <> "" 
                    diff-string2 <> ""
                ] [
                    append/only results trim-actions reduce [
                        reduce ['r (diff-start/1 + index1) (diff-end/1 - diff-start/1) diff-string1] 
                        reduce ['i (diff-start/1 + index1) (diff-end/2 - diff-start/1) diff-string2]
                    ]
                ] 
                if any [
                    diff-end/1 >= len-str1 
                    diff-end/2 >= len-str2 
                    diff-end/3 = end-of-file
                ] [
                    return results
                ] 
                orig-index1: index1 
                orig-index2: index2 
                index1: index1 + diff-end/1 + (length? diff-end/3) - 1 
                index2: index2 + diff-end/2 + (length? diff-end/3) - 1 
            ]
        ] 
        return results
    ]
] 
delim-split: function [
    {Break a string series into pieces using one or more provided delimiter(s)} 
    series [any-string!] dlm [string! char! bitset! block!] 
    /local s num new-dlm
] [
    if (type? dlm = block!) [
        new-dlm: copy [] 
        foreach i dlm [
            append new-dlm reduce [i '|]
        ] 
        remove back tail new-dlm 
        dlm: copy new-dlm
    ] 
    num: either string? dlm [length? dlm] [1] 
    results: parse series [collect any [copy s [to [dlm | end]] keep (s) num skip [end keep (copy "") | none]]] 
    remove-each i results [i = ""] 
    return results
]
