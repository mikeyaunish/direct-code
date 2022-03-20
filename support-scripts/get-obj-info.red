Red [
	Title: "get-obj-info.red"
	Comment: "Extracted from: <root-path>%experiments/get-obj-info/get-obj-info.red"
	Date: 19-Mar-2022
	Time: 20:41:08
]

    get-obj-info-ctx: context [
        set 'owner-switch-block [
            "tuple" [["font-color"]] 
            "pair" [["at"]] 
            "string" [["font-name" "hint" "default" "data"]] 
            "logic" [["data" "extra" "with"]] 
            "integer" [["font-size" "select"]] 
            "time" [["rate"]] 
            "block" [[
                "default" 
                "font" "with" "actors" "extra" "do" "data" "draw" "para" "react" 
                "on-down" "on-up" "on-mid-down" "on-mid-up" "on-alt-down" "on-alt-up" "on-aux-down" 
                "on-aux-up" "on-drag-start" "on-drag" "on-drop" "on-create" "on-click" "on-dbl-click" "on-over" 
                "on-move" "on-resize" "on-moving" "on-resizing" "on-wheel" "on-zoom" "on-touch" "on-pan" 
                "on-rotate" "on-two-tap" "on-press-tap" "on-key-down" "on-key" "on-key-up" "on-enter" 
                "on-focus" "on-unfocus" "on-select" "on-change" "on-menu" "on-close" "on-time"
            ]]
        ] 
        get-styles: function [code-block [block!]] [
            return parse code-block [collect [any ['style keep set-word! keep word! | skip]]]
        ] 
        select-datatype-value: func [haystack dtype value] [
            if (fnd: find haystack (to dtype value)) [
                if ((type? (first fnd)) = dtype) [
                    return first next fnd
                ]
            ] 
            return none
        ] 
        get-obj-type: function [
            code-cdta [block!] 
            obj-name [string!] 
            styles-list [block!]
        ] [
            type-field: 8 
            index-field: 2 
            fixed-code-cdta: fix-datatype code-cdta 
            set-word-at: find-in-array-at/with-index fixed-code-cdta type-field set-word! 
            next-index-val: (set-word-at/1/index + 1) 
            obj-type-at: find-in-array-at code-cdta index-field next-index-val 
            assigned-type: obj-type-at/input 
            return either (style-type: select-datatype-value styles-list set-word! assigned-type) [
                style-type
            ] [
                assigned-type
            ]
        ] 
        set 'previous-chunk-owns? function [
            obj-chunks [block!] 
            target-chunk [block!] 
            datatype-filter [datatype!] 
            /extern owner-switch-block
        ] [
            index-field: 2 
            owner-keywords: switch/default (to-string datatype-filter) owner-switch-block [
                return false
            ] 
            if (previous-chunk: find-in-array-at obj-chunks index-field (target-chunk/index - 1)) [
                either find owner-keywords previous-chunk/input [
                    return true
                ] [
                    return false
                ]
            ]
        ] 
        has-no-name-equivalent?: function [
            obj-name 
            filter 
            code-styles 
            obj-type
        ] [
            set 'dc-default-action-list [
                base "on-down" field "on-enter" drop-down "on-enter" h1 "on-down" 
                text "on-down" area "on-change" calendar "on-change" h2 "on-down" 
                button "on-click" image "on-down" progress "on-change" h3 "on-down" 
                check "on-change" text-list "on-change" slider "on-change" h4 "on-down" 
                radio "on-change" drop-list "on-change" camera "on-down" h5 "on-down" 
                toggle "on-change"
            ] 
            if filter/1 = 'word! [
                obj-default-action: select dc-default-action-list (to-word obj-type) 
                if obj-default-action = filter/2 [
                    return true
                ]
            ] 
            return false
        ] 
        set 'get-obj-info function [
            source-code [string!] "full source code to be inspected" 
            obj-name [string!] 
            filter [block!] { datatype! + input-string <input-string optional>  } 
            /with with-src-cdta "supply the scr-cdta for the function" 
            /extern owner-switch-block
        ] [
            src-cdta: get-src-cdta source-code 
            object-field: 4 
            input-field: 6 
            type-field: 8 
            match-pos: false 
            datatype-filter: reduce filter/1 
            either obj-chunks: find-in-array-at/every src-cdta object-field obj-name [
                either datatype-chunks: find-in-array-at/every obj-chunks type-field datatype-filter [
                    either ((length? filter) > 1) [
                        input-filter: reduce filter/2 
                        either (dt-input-chunks: find-in-array-at/every datatype-chunks input-field input-filter) [
                            either ((length? dt-input-chunks) = 1) [
                                match-pos: dt-input-chunks/1/index 
                                resulting-chunks: reduce [dt-input-chunks/1/token dt-input-chunks/1/input]
                            ] [
                                resulting-chunks: copy dt-input-chunks
                            ]
                        ] [
                            code-styles: get-styles to-block source-code 
                            obj-type: get-obj-type obj-chunks obj-name code-styles 
                            if (has-no-name-equivalent? obj-name filter code-styles obj-type) [
                                return get-obj-info source-code obj-name [block!]
                            ] 
                            return reduce [none obj-chunks]
                        ]
                    ] [
                        resulting-chunks: copy datatype-chunks
                    ]
                ] [
                    return reduce [none obj-chunks]
                ]
            ] [
                return reduce [none obj-chunks]
            ] 
            if ((length? filter) > 1) [
                if (datatype-filter = word!) [
                    if (siba: search-in-block-at/find-in owner-switch-block [2 2 1] input-filter) [
                        block-chunk: pick src-cdta (match-pos + 1) 
                        location: to-pair reduce [resulting-chunks/1/x block-chunk/token/y] 
                        resulting-chunks: reduce [location resulting-chunks/2 block-chunk/input]
                    ] 
                ]
            ] 
            if match-pos [
                return resulting-chunks
            ] 
            foreach chunk resulting-chunks [
                either not (pco: previous-chunk-owns? obj-chunks chunk datatype-filter) [
                    return reduce [chunk/token chunk/input]
                ] [
                ]
            ] 
            return reduce [none obj-chunks]
        ]
    ]
