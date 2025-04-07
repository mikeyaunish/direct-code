Red [
	Title: "request-list-enhanced.red"
	Comment: "Imported from: <root-path>%experiments/request-list-enhanced/request-list-enhanced.red"
]
system/view/VID/styles/request-list-picker: [
    default-actor: on-change
    template: [
        type: 'field
        size: 120x23
        text: ""
        flags: []
        extra: [data-source: none]
        actors: [
            on-create: func [face [object!] event [event! none!]] []
            on-key: func [face [object!] event [event! none!]] []
            on-key-up: func [face [object!] event [event! none!]] []
            on-key-down: func [face [object!] event [event! none!]] []
            on-wheel: func [face [object!] event [event! none!]] []
            on-change: func [[trace] face [object!] event [event! none!]] []
            move-selection: func [
                text-list-name
                direction
                /page "direction amount is considered a full page"
                /local new-index
            ] [
                text-list-face: get to-word text-list-name
                if page [
                    line-height: second size-text/with text-list-face "X"
                    face-height: text-list-face/size/y - 5
                    page-size: to-integer round (face-height / line-height) - 1
                    direction: (direction * page-size)
                ]
                new-index: (
                    either none? text-list-face/selected [text-list-face/extra/last-selected] [text-list-face/selected]
                ) + direction
                if (new-index < 1) [
                    new-index: 1
                ]
                if (new-index > (length? text-list-face/data)) [
                    new-index: length? text-list-face/data
                ]
                select-this-item/index text-list-name new-index
            ]
            list-picker-search: func [
                face
                text-list-name
            ] [
                text-list-face: get to-word text-list-name
                fnd: face/actors/find-in-block copy text-list-face/data face/text
                either fnd = [] [
                    face/color: orange
                    text-list-face/extra/last-selected: either none? text-list-face/selected [
                        text-list-face/extra/last-selected
                    ] [
                        text-list-face/selected
                    ]
                    text-list-face/selected: none
                ] [
                    face/color: white
                    text-list-face/selected: fnd/2
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
                forall block [
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
                text-list-name
                /index index-val
                /selected
            ] [
                text-list-face: get to-word text-list-name
                if selected [index-val: text-list-face/selected]
                if index-val = 0 [return none]
                either none? text-list-face/selected [
                    face/text: none
                ] [
                    face/text: copy pick text-list-face/data index-val
                ]
                text-list-face/selected: index-val
            ]
        ]
    ]
    init: [
        face: self
        face/actors/on-key: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key [
            if event/key = 'down [
                face/actors/move-selection face/extra/data-source 1
                face/color: white
            ]
            if event/key = 'up [
                face/actors/move-selection face/extra/data-source -1
                face/color: white
            ]
            if event/key = 'page-down [
                face/actors/move-selection/page face/extra/data-source 1
            ]
            if event/key = 'page-up [
                face/actors/move-selection/page face/extra/data-source -1
            ]
        ]
        face/actors/on-wheel: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-wheel [
            switch event/picked [
                -1.0 [
                    face/actors/move-selection face/extra/data-source 1
                ]
                1.0 [
                    face/actors/move-selection face/extra/data-source -1
                ]
            ]
        ]
        face/actors/on-key-down: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key-down [
            if event/key = #"^M" [
                face/actors/select-this-item/selected face/extra/data-source
                exit
            ]
        ]
        face/actors/on-key-up: func [face [object!] event [event! none!] /local selected]
        head insert body-of :face/actors/on-key-up [
            if event/key = #"^[" [
                text-list-face: get to-word face/extra/data-source
                text-list-face/extra/last-selected: either none? text-list-face/selected [
                    text-list-face/extra/last-selected
                ] [
                    text-list-face/selected
                ]
                face/text: copy ""
                ds-selected: to-set-path reduce [to-word face/extra/data-source 'selected]
                do reduce [:ds-selected none]
                set-focus face
                exit
            ]
            if all [
                char? event/key
                not face/actors/is-whitespace? event/key
            ] [
                face/actors/list-picker-search face face/extra/data-source
            ]
        ]
    ]
]
request-list-enhanced: func [
    {Asks user to pick from a text data list. The list will automatically be sorted.}
    message [string!]
    data-block [block!]
    /size list-size [pair!]
    /offset win-offset
] [
    results: copy ""
    sort data-block
    if not size [list-size: 180x140]
    options-block: either offset [
        compose [offset: (win-offset)]
    ] [
        []
    ]
    picker-size: to-pair reduce [(list-size/x - 23) 23]
    msg-size: to-pair reduce [(list-size/x) 23]
    spacer-size: to-pair reduce [(list-size/x - 109) 23]
    view/flags/options [
        title "Select"
        style search-icon: base 23x23 220.220.220
        draw [
            pen 0.0.0
            line-width 2
            circle 9x9 6
            line 14x14 21x21
        ]
        space 10x2
        msg-text: text message msg-size center font-size 11
        return
        tlist: text-list list-size
        data data-block
        on-change [
            if face/selected <> 0 [
                target-selector: get to-word face/extra/selector
                target-selector/text: copy pick face/data face/selected
            ]
        ]
        on-dbl-click [
            if tlist/selected <> 0 [
                ds1/actors/select-this-item/selected "tlist"
                do-actor ds1 none 'enter
            ]
        ]
        extra [
            selector: "ds1"
            last-selected: 0
        ]
        return
        search-icon1: search-icon
        space 0x0
        ds1: request-list-picker picker-size focus with [extra/data-source: "tlist"]
        on-enter [
            results: face/text
            unview
        ]
        space 10x10
        return
        box spacer-size
        button "OK" 35x23 on-click [
            ds1/actors/select-this-item/selected "tlist"
            do-actor ds1 none 'enter
        ]
        button "Cancel" 50x23 on-click [
            results: none
            unview
        ]
    ]
    [no-min no-max modal]
    options-block
    return results
]
