Red [
	Title: "field-data-picker.red"
	Comment: "Imported from: <root-path>%experiments/field-data-picker/field-data-picker.red"
]
system/view/VID/styles/field-data-picker: [
    default-actor: on-change
    template: [
        type: 'field
        size: 120x23
        text: ""
        flags: []
        extra: [
            data-face: none
            last-selected: 0
            setup-style: []
        ]
        actors: [
            on-key: func [face [object!] event [event! none!]] []
            on-key-up: func [face [object!] event [event! none!]] []
            on-key-down: func [face [object!] event [event! none!]] []
            on-wheel: func [face [object!] event [event! none!]] []
            on-change: func [[trace] face [object!] event [event! none!]] []
            move-selection: func [
                data-face
                direction
                /page "direction amount is considered a full page"
                /local new-index
            ] [
                if page [
                    line-height: second size-text/with data-face "X"
                    face-height: data-face/size/y - 5
                    page-size: to-integer round (face-height / line-height) - 1
                    direction: (direction * page-size)
                ]
                new-index: (
                    either none? data-face/selected [data-face/extra/last-selected] [data-face/selected]
                ) + direction
                if (new-index < 1) [
                    new-index: 1
                ]
                if (new-index > (length? data-face/data)) [
                    new-index: length? data-face/data
                ]
                select-this-item/index data-face new-index
            ]
            field-data-picker-search: func [
                face
                data-face
            ] [
                fnd: face/actors/find-in-block copy data-face/data face/text
                either fnd = [] [
                    face/color: orange
                    data-face/extra/last-selected: either none? data-face/selected [
                        data-face/extra/last-selected
                    ] [
                        data-face/selected
                    ]
                    data-face/selected: none
                ] [
                    face/color: white
                    data-face/selected: fnd/2
                ]
            ]
            find-in-block: function [
                {returns value that matches a value in the block. Allows partial match with beginning of string}
                blk [block!]
                val [string!]
                /all
            ] [
                block: copy blk
                results: copy []
                forskip block 1 [
                    if fnd: find/match (first block) val [
                        either all [
                            append/only results reduce [fnd index? block]
                        ] [
                            results: reduce [fnd index? block]
                            break
                        ]
                    ]
                ]
                if results [return results]
                return none
            ]
            is-whitespace?: func [
                c [char!]
            ] [
                any [
                    (c == #" ") (c == #"^-") (c == #"^M") (c == #"^/") (c == #"^K") (c == #"^L")
                ]
            ]
            select-this-item: func [
                data-face
                /index index-val
                /selected
            ] [
                if selected [index-val: data-face/selected]
                either none? data-face/selected [
                    face/text: none
                ] [
                    face/text: copy pick data-face/data index-val
                ]
                data-face/selected: index-val
            ]
        ]
    ]
    init: [
        face: self
        face/actors/on-key: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key [
            if event/key = 'down [
                face/actors/move-selection face/extra/data-face 1
                face/color: white
            ]
            if event/key = 'up [
                face/actors/move-selection face/extra/data-face -1
                face/color: white
            ]
            if event/key = 'page-down [
                face/actors/move-selection/page face/extra/data-face 1
            ]
            if event/key = 'page-up [
                face/actors/move-selection/page face/extra/data-face -1
            ]
        ]
        face/actors/on-wheel: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-wheel [
            switch event/picked [
                -1.0 [
                    face/actors/move-selection face/extra/data-face 1
                ]
                1.0 [
                    face/actors/move-selection face/extra/data-face -1
                ]
            ]
        ]
        face/actors/on-key-down: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key-down [
            if event/key = #"^M" [
                face/actors/select-this-item/selected face/extra/data-face
                exit
            ]
        ]
        face/actors/on-key-up: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key-up [
            if event/key = #"^[" [
                data-face: face/extra/data-face
                data-face/extra/last-selected: either none? data-face/selected [
                    data-face/extra/last-selected
                ] [
                    data-face/selected
                ]
                face/text: copy ""
                data-face/selected: none
                set-focus face
                exit
            ]
            if all [
                char? event/key
                not face/actors/is-whitespace? event/key
            ] [
                face/actors/field-data-picker-search face face/extra/data-face
            ]
        ]
    ]
]
