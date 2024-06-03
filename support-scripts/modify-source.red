Red [
	Title: "modify-source.red"
	Comment: "Imported from: <root-path>%experiments/modify-source/modify-source.red"
]
dc-modify-source: context [
    if not value? 'show-selected [show-selected: does []] 
    flag-words: [
        loose left center right top middle bottom bold italic underline 
        hidden disabled tri-state password focus true false wrap no-wrap
    ] 
    is-flag-word?: func [target] [
        either all [(target/1 = word!) (find flag-words (to-word target/2))] [
            return true
        ] [return false]
    ] 
    insert word-at-block: copy ["at"] word! 
    set 'find-insert-position function [
        source-chunks [block!] 
        obj-name [string!] 
        target [block!]
    ] [
        keyword-order: fix-datatype reverse copy [
            style 
            set-word! word! string! pair! tuple! file! date! percent! logic! loose disable 
            true false 
            hidden disabled password 
            focus flags 
            para left center right 
            top middle bottom 
            bold italic underline strike wrap no-wrap no-border 
            font-name font-size font-color font 
            hint image draw 
            data select default rate 
            react url! 
            all-over tri-state 
            actors on-click on-down on-up on-create on-created on-mid-down on-mid-up on-alt-down on-alt-up 
            on-aux-down on-aux-up on-drag-start on-drag on-drop on-dbl-click 
            on-over on-move on-resize on-moving on-resizing on-wheel on-zoom 
            on-touch on-pan on-rotate on-two-tap on-press-tap on-key-down on-key 
            on-key-up on-enter on-focus on-unfocus on-select on-change on-menu on-close 
            on-time on-detect 
            on-drawing on-ime on-scroll 
            block! 
            extra with
        ] 
        fix-datatype target 
        needle: either (target/1 = word!) [
            to-word target/2
        ] [
            target/1
        ] 
        either (fnd: find/only keyword-order needle) [
            fix-datatype source-chunks 
            foreach keyword (skip fnd 1) [
                foreach src source-chunks [
                    comparing: either (word? keyword) [
                        c-type: "IS-word" 
                        either (src/type = word!) [to-word src/input] [src/type]
                    ] [
                        c-type: "NOT-word" 
                        src/type
                    ] 
                    if (comparing = keyword) [
                        if not any [(src/input = "at") (src/input = "style")] [
                            at-pair-chunk?: find-in-array-at source-chunks 2 (src/index - 1) 
                            if not all [at-pair-chunk? (at-pair-chunk?/6 = "at")] [
                                return src
                            ]
                        ]
                    ]
                ]
            ]
        ] [
            return none
        ]
    ] 
    set 'modify-source function [
        {Change source code supplied. Defaults to creating a new entry if it doesn't exist.V19-Feb-2022} 
        source-code 
        obj-name [string!] 
        target [block!] " datatype! + <optional input-string>  " 
        new-value [any-type!] 
        /delete 
        /extern zglobal
    ] [
        obj-info: query-vid-object source-code obj-name target 
        either obj-info/1 [
            if all [(is-flag-word? fix-datatype target) (not delete)] [
                return none
            ] 
            current-value: copy/part skip source-code (obj-info/1/x - 1) (obj-info/1/y - obj-info/1/x + 1) 
            last-current-value: last current-value 
            either find "^/^- " last-current-value [
                change-pos: (obj-info/1 - 0x1)
            ] [
                change-pos: obj-info/1
            ] 
            either delete [
                prefix-char: first skip source-code (change-pos/x - 2) 
                pos-adjustment: either prefix-char = #"^/" [1] [2] 
                remove/part (skip source-code change-pos/x - pos-adjustment) (change-pos/y - change-pos/x + 2)
            ] [
                switch (to-string target/1) [
                    "word" [
                        new-value: reduce [target/2 " " mold new-value]
                    ] 
                    "string" [
                        new-value: mold new-value
                    ] 
                    "file" [
                        new-value: mold new-value
                    ] 
                    "block" [
                        new-value: mold new-value
                    ]
                ] 
                indent-chars: get-indent-chars source-code change-pos/x 
                if block? new-value [
                    foreach segment new-value [
                        replace/all segment "^/" rejoin ["^/" indent-chars]
                    ] 
                ] 
                change/part (skip source-code change-pos/x - 1) new-value (change-pos/y - change-pos/x + 1)
            ]
        ] [
            if delete [
                return none
            ] 
            target: fix-datatype target 
            either (target = word-at-block) [
                insert (skip source-code (obj-info/2/1/token/x - 1)) reduce ["at" " " new-value " "]
            ] [
                pre-value-list: [
                    "at" "font-color" "font-name" "font-size" "rate" "select" "hint" "default" "data" "extra" "with"
                ] 
                insert-chunk: find-insert-position obj-info/2 obj-name target 
                insert-pos: insert-chunk/token 
                pre-value: copy "" 
                post-value: copy " " 
                if any [((type? new-value) = block!) (find pre-value-list target/2)] [
                    if target/2 
                    [
                        pre-value: rejoin [to-word target/2 " "]
                    ]
                ] 
                if (search-in-block-at/find-in owner-switch-block [2 2 1] insert-chunk/input) [
                    next-chunk: find-in-array-at obj-info/2 2 (insert-chunk/index + 1) 
                    insert-pos: either next-chunk [
                        next-chunk/token
                    ] [
                        insert-chunk/token
                    ] 
                ] 
                last-char: pick source-code insert-pos/y 
                either any [(last-char = none) (last-char = #"^/")] [
                    insert pre-value " " 
                    post-value: copy "" 
                    insert-position: (insert-pos/y - 1)
                ] [
                    if (last-char <> #" ") [
                        post-value: copy "" 
                        insert pre-value " "
                    ] 
                    insert-position: insert-pos/y
                ] 
                new-value: mold new-value 
                if find new-value "^/" [
                    replace/all new-value "^/" "^/^-"
                ] 
                insert skip source-code insert-position rejoin [pre-value new-value post-value]
            ]
        ] 
        return head source-code
    ]
]
