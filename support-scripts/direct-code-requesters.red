Red [
	Title: "direct-code-requesters.red"
	Comment: "Imported from: <root-path>%experiments/direct-code-requesters/direct-code-requesters.red"
]
direct-code-requesters: context [
    set 'request-yes-no func [
        message [string!] "Message to display" 
        /size area-size "The size of the text area"
    ] [
        return-value: none 
        if not size [area-size: 400x200] 
        req-custom-layout: layout compose [
            title "User Input Required" 
            area (area-size) message font-size 12 wrap 
            return 
            button "YES" 100x24 [
                return-value: true 
                unview/only req-custom-layout
            ] 
            button "NO" 100x24 [
                return-value: false 
                unview/only req-custom-layout
            ] 
            button "CANCEL" 100x24 [
                return-value: false 
                unview/only req-custom-layout
            ]
        ] 
        view req-custom-layout 
        return return-value
    ] 
    set 'request-multiline-text function [
        "Written by: Mike Yaunish " 
        msg [string!] 
        /size area-size [pair!] 
        /preload prestr [string!] 
        /submit submit-code 
        /offset offset-value [pair! point2D!] 
        /custom custom-data [block!] "consists of <button-string> + <code-block>" 
        /modal {Makes the requester modal, disabling all previously opened windows}
    ] [
        --multiline-result: copy "" 
        area-size: any [area-size 500x200] 
        options-block: either offset [
            reduce [to-set-word 'offset offset-value]
        ] [
            []
        ] 
        flags-block: either modal [
            [modal]
        ] [
            []
        ] 
        prestr: copy any [prestr ""] 
        custom-button-code: either custom [
            custom-text: 1 
            custom-code: 2 
            bind custom-data/:custom-code '--multiline-area 
            compose/deep [
                custom-button: button (custom-data/:custom-text) 
                on-click [(custom-data/:custom-code)] 
                return
            ]
        ] [
            []
        ] 
        multiline-layout: layout compose [
            Title "User input required" 
            on-close [--multiline-result: none] 
            text1: text font-size 12 msg return 
            (custom-button-code) 
            --multiline-area: area area-size font-name "fixedsys" font-size 9 focus on-create [
                --multiline-area/text: copy prestr 
                face/flags: none
            ] 
            on-key [
                if event/key = 'F1 [
                    --multiline-result: --multiline-area/text 
                    unview
                ] 
                if all [(event/key = 'F5) submit] [
                    --multiline-result: --multiline-area/text 
                    do bind submit-code '--multiline-result
                ] 
                if event/key = #"^[" [
                    --multiline-result: none 
                    unview
                ]
            ] 
            return 
            button "     OK / (F1 key)" [
                --multiline-result: --multiline-area/text 
                unview
            ] 
            submit-button: button "   Submit Changes / (F5 key) " [
                --multiline-result: --multiline-area/text 
                do bind submit-code '--multiline-result
            ] 
            button "   CANCEL / (ESC key)  " [
                --multiline-result: none 
                unview
            ] 
            do [
                --multiline-result: copy "" 
                get-results: does [
                    return --multiline-area/text
                ] 
                if not submit [
                    submit-button/visible?: false
                ]
            ]
        ] 
        view/options/flags multiline-layout options-block flags-block 
        return --multiline-result
    ] 
    set 'request-date function [/set-date seed-date [date!]] [
        seed-date: any [seed-date now/date] 
        view [
            Title "Select a date" 
            on-key [
                if event/key = #"^[" [
                    res: none 
                    unview
                ]
            ] 
            on-close [res: none] 
            calendar1: calendar seed-date 
            return 
            button "OK" [
                res: calendar1/data 
                unview
            ] 
            button "CANCEL" [
                res: none 
                unview
            ]
        ] 
        return res
    ] 
    set 'request-specific-move does [
        view move-specific1-layout: [
            Title "Move Object" 
            space 2x2 
            text1: text "Move object to a specific location" 335x24 underline wrap font-size 13 
            return 
            t1: text "Direction:" font-size 13 
            ahead-radio: radio "Ahead" left font-size 13 data true 
            space 0x0 
            back-radio: radio "Back" left font-size 13 
            return 
            text1-1: text "Number of positions to move:" right wrap font-size 13 
            pos: field 29x24 240.253.0.0 font-size 13 on-enter [
                amt: (to-integer face/text) * (pick [1 -1] ahead-radio/data) 
                res: amt 
                unview
            ]
        ] 
        return res
    ] 
    set 'request-mutable-list function [
        {A list requester that allows lines to be removed.^/Block return format: [ <block-changed-flag?> <selected-item> <changed-list> ] } 
        message [string!] "message to display" 
        list-block [block!] "list to display" 
        /size list-size [pair!] 
        return: [block!]
    ] 
    [
        if not size [list-size: 250x200] 
        area-size: to-pair reduce [list-size/x 70] 
        top-button-size: to-pair reduce [list-size/x 24] 
        bottom-button-size: to-pair reduce [((list-size/x / 2) - 3) 24] 
        return-value: reduce [false "" []] 
        list-changed?: false 
        text-list1: copy "" 
        requester-layout: layout compose/deep [
            title "Select an item" 
            below 
            space 2x2 
            area1: area (area-size) message wrap 
            button1: button "Clear Entire List" (top-button-size) [
                list-changed?: true 
                text-list1/data: copy [] 
                text-list1/selected: none 
                selected-field/text: copy ""
            ] 
            button2: button "Delete Current Line" (top-button-size) [
                list-changed?: true 
                remove skip text-list1/data text-list1/selected - 1 
                text-list1/selected: none 
                selected-field/text: copy ""
            ] 
            text-list1: text-list (list-size) focus 
            data [(:list-block)] select 1 
            on-create [
                selected-field/text: pick face/data face/selected
            ] 
            on-change [
                selected-field/text: pick face/data face/selected
            ] 
            on-key [
                if event/key = 'delete [
                    list-changed?: true 
                    remove skip text-list1/data text-list1/selected - 1 
                    selected-field/text: copy ""
                ] 
                if event/key = #"^[" [
                    return-value: reduce [false "" []] 
                    unview/only requester-layout
                ] 
                if event/key = #"^M" [
                    return-value: reduce [list-changed? selected-field/text text-list1/data] 
                    unview/only requester-layout
                ]
            ] 
            on-dbl-click [
                return-value: reduce [list-changed? selected-field/text text-list1/data] 
                unview/only requester-layout
            ] 
            selected-field: field "" (top-button-size) 
            across 
            button "OK" (bottom-button-size) [
                return-value: reduce [list-changed? selected-field/text text-list1/data] 
                unview/only requester-layout
            ] 
            button "Cancel" (bottom-button-size) [
                return-value: reduce [false "" []] 
                unview/only requester-layout
            ]
        ] 
        view requester-layout 
        return return-value
    ] 
    set 'request-message func [
        message [string!] "Message to display" 
        /size area-size "The size of the text area" 
        /fixed-font 
        /no-wait
    ] [
        ret-val: copy "" 
        if not size [area-size: 400x200] 
        font-info: copy [] 
        if fixed-font [font-info: [font-name "Consolas"]] 
        rre: layout compose [
            title "User Message..." 
            area (area-size) message font-size 12 (font-info) wrap 
            return 
            button "OK" focus 100x24 [
                ret-val: true 
                unview/only rre
            ] 
            button "CANCEL" 100x24 [
                ret-val: false 
                unview/only rre
            ]
        ] 
        view/:no-wait/options rre [
            actors: make object! [
                on-key: func [face event] [
                    if event/key = #"^[" [unview]
                ]
            ]
        ] 
        return ret-val
    ] 
    set 'request-tray-list function [
        msg 
        data [block!] 
        on-click-function [word!] 
        /size sz [pair!] 
        /one-click "Allows one-click selection"
    ] [
        sz: any [sz 200x150] 
        view view-composed: compose/only/deep [
            text font-size 12 200 (form msg) return 
            f-lst: text-list sz data (data) 
            on-select [
                selected: pick data event/picked 
                (on-click-function) selected
            ] 
            on-key [
                if event/key = #"^[" [unview]
            ] 
            return 
            button "Close" [unview]
        ]
    ] 
    set 'request-items function [
        message [string!] 
        item-title [string!] 
        selected-title [string!] 
        item-data [block!] 
        /size list-size 
        /offset offset-pos
    ] [
        offset-block: copy [] 
        if offset [
            offset-block: reduce [to-set-word 'offset offset-pos]
        ] 
        list-size: either size [
            list-size
        ] [
            150x150
        ] 
        title-size: to-pair reduce [list-size/x 24] 
        requester-results: none 
        view/options compose/deep [
            title "User Selections Required" 
            style button-style: button 101x23 
            space 10x0 
            requester-message: text 377x43 font-size 12 (message) 
            return 
            group-box1: group-box [
                below 
                text1-1: text (item-title) (title-size) underline center font-size 12 
                space 4x1 
                text-list1: text-list (list-size) 
                on-create [
                    text-list1/data: (reduce [item-data])
                ] 
                on-change [
                    add-to-list pick face/data face/selected 
                    face/selected: none
                ] 
                return 
                text1: text (selected-title) (title-size) underline center font-size 12 
                collection-list: text-list (list-size) data [] 
                on-create [collection-list/data: copy []] 
                return 
                box1: box 78x25 
                button11: button-style "Remove Item" on-click [remove skip collection-list/data collection-list/selected - 1] 
                button-style1: button-style "Move Up" on-click [move-item/up collection-list/selected] 
                button-style1-1: button-style "Move Down" on-click [move-item/down collection-list/selected]
            ] 
            return 
            button1: button "OK" [
                requester-results: collection-list/data 
                unview
            ] 
            button1: button "Cancel" [
                requester-results: none 
                unview
            ] 
            do [
                add-to-list: func [value] [
                    if fnd: find collection-list/data value [
                        remove fnd
                    ] 
                    append collection-list/data value
                ] 
                move-item: func [
                    item-num 
                    /up 
                    /down
                ] [
                    data: copy collection-list/data 
                    if up [
                        move/part skip data item-num - 2 skip data item-num - 1 1 
                        new-selected: item-num - 1
                    ] 
                    if down [
                        move/part skip data item-num skip data item-num - 1 1 
                        new-selected: item-num + 1
                    ] 
                    collection-list/data: data 
                    collection-list/selected: new-selected
                ]
            ]
        ] offset-block 
        return requester-results
    ]
]
