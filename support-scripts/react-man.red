Red [
    Title: "react-man.red"
]

copy-func: function [ fun [function! lit-word!] ][
    spec: copy/deep spec-of :fun
    body: copy/deep body-of :fun
    func spec body
]    
    
react-man: closure [ active-reactions: copy [] link-count: 0 ] [ 
        reactive-function [ word! ]
        reactive-objects /link /unlink /later /show-reactions 
    ][ 
    ; ****************************************************
    ; active-reactions FIELD DETAILS
    ; 1 = original-reactive-function               IE. link-text
    ; 2 = unique reactive function (generated)     IE. link-text-1
    ; 3 = reactive object                          IE. [ F1 F2 ]
    ; *****************************************************
    if show-reactions [
        print [ "react-man link-count = " link-count ]
        foreach i active-reactions [
            print i
        ]
        return ""
    ] 
    if link [
        either all [ 
            (link-matches: find-in-array-at/every active-reactions 1 ( mold reactive-function )) 
            (exact-match: find-in-array-at/every link-matches 3 reactive-objects )
        ][
            return false   
        ][
            reactive-function-num: to-string ( link-count: link-count + 1)
            new-reactive-function-name: rejoin [ mold reactive-function "-" reactive-function-num ]
            do compose [ ( to-set-word new-reactive-function-name ) copy-func get reactive-function ]
            either later [
                react-result: react/link/later (get to-word new-reactive-function-name) reactive-objects
            ][
                react-result: react/link (get to-word new-reactive-function-name) reactive-objects    
            ]
            either :react-result [ 
                append/only active-reactions reduce [ (mold reactive-function) new-reactive-function-name reactive-objects ]
                return true
            ][
                return false
            ]
        ]
    ]
    if unlink [
        link-matches: find-in-array-at/every active-reactions 1 ( mold reactive-function )
        either link-matches [
            exact-match: find-in-array-at/every link-matches 3 reactive-objects
            either all [ ( exact-match ) ((length? exact-match) = 1) ] [
                react-result: react/unlink (get to-word exact-match/1/2) exact-match/1/3
                either :react-result [ 
                    fnd-pos: find-in-array-at/with-index active-reactions 2 exact-match/1/2
                    remove skip active-reactions (fnd-pos/2 - 1)
                    return true
                ][
                    return false
                ]
            ][
                return false
            ]                
        ][
            return false
        ]
    ]
]
