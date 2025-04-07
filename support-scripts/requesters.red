Red [
	Title: "requesters.red"
	Comment: "Imported from: <root-path>%experiments/requesters/requesters.red"
]
requesters: context [
    iso-yellow: 239.202.64
    iso-red: 177.34.54
    iso-blue: 30.81.133
    iso-font-40: make font! [style: 'bold size: 40 name: "Symbol"]
    iso-font-40i: make font! [style: [bold italic] size: 40 name: "Times New Roman"]
    iso-font-26: make font! [style: 'bold size: 26 name: "Symbol"]
    svvs: system/view/vid/styles
    svvs/iso-info: [
        template: [
            type: 'base size: 48x48 color: none
            draw: [font iso-font-40i pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 7x-7 "i"]
        ]
    ]
    svvs/iso-question: [
        template: [
            type: 'base size: 48x48 color: none
            draw: [font iso-font-40 pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 3x-11 "?"]
        ]
    ]
    svvs/iso-warning: [
        template: [
            type: 'base size: 48x48 color: none
            draw: [font iso-font-26 pen black fill-pen iso-yellow line-width 4 line-join round polygon 24x4 46x44 2x44 text 13x5 "!"]
        ]
    ]
    svvs/iso-action-required: [
        template: [
            type: 'base size: 48x48 color: none
            draw: [font iso-font-40 pen iso-blue fill-pen iso-blue circle 24x24 23 pen white text 7x-12 "!"]
        ]
    ]
    svvs/iso-prohibit: [
        template: [
            type: 'base size: 48x48 color: none
            draw: [pen iso-red fill-pen white line-width 5 circle 24x24 21 line-width 4 line 8x8 40x40]
        ]
    ]
    svvs/timer: [
        default-actor: on-time
        template: [
            type: 'base size: 0x0 color: none
        ]
    ]
    std-dialog-actors: object [
        res: none
        on-key: func [face event] [
            switch event/key [
                #"^M" [res: true unview]
                #"^[" [res: none unview]
                #"^O" #"^Y" [if find event/flags 'control [res: true unview]]
                #"^C" [if find event/flags 'control [res: none unview]]
                #"^N" [if find event/flags 'control [res: false unview]]
            ]
        ]
    ]
    std-dialog-opts: compose [
        flags: [modal no-min no-max]
        actors: (std-dialog-actors)
    ]
    show-dialog: function [
        spec [block! object!]
        /options opts [block!] "[offset: flags: actors: menu: parent: text:]"
        /timeout time [time!] "Hide after timeout; only block specs supported"
        /with init [block! none!] {Code to run after layout, before showing; e.g., to center face}
    ] [
        if block? spec [
            if time [spec: append copy spec reduce ['timer 'rate time [unview]]]
            spec: layout spec
        ]
        face: :spec
        if init [do bind/copy init 'face]
        view/options spec make std-dialog-opts any [opts []]
    ]
    set 'notify function [
        {Display a dialog with a short message for a period of time}
        spec "Message to display or layout/face spec"
        time [time!]
        /over ctr [object!] "Center over this face"
        /offset pos [pair!]
    ] [
        spec: case [
            object? :spec [spec]
            block? :spec [spec]
            'else [compose [across iso-info pad 10x0 text font-size 12 350x70 (form :spec)]]
        ]
        opts: copy/deep std-dialog-opts
        if all [block? spec not find spec 'title] [append opts [text: ""]]
        if pair? pos [append opts compose [offset: (pos)]]
        if ctr [init: [center-face/with face ctr]]
        show-dialog/options/timeout/with spec opts time init
    ]
    set 'alert function [
        {Display a dialog with a short message, until the user closes it}
        msg
        /style sty [word!] {Include standard image and title: [info warn stop action]}
        /over ctr [object!] "Center over this face"
        /offset pos [pair!] "Top-left offset of window"
        /local img txt
    ] [
        set [img txt] switch/default sty [
            info [[iso-info "Information"]]
            warn [[iso-warning "Warning"]]
            stop [[iso-prohibit "Stop!"]]
            action [[iso-action-required "Action required"]]
        ] [reduce [() "Information"]]
        spec: compose [
            title (txt)
            across (get/any 'img) pad 10x0 text font-size 12 350x70 (form msg) return
            pad 300x0 button "OK" [res: true unview]
        ]
        opts: copy/deep std-dialog-opts
        if pair? pos [append opts compose [offset: (pos)]]
        if ctr [init: [center-face/with face ctr]]
        show-dialog/options/with spec opts init
        res
    ]
    set 'prompt function [
        {Display a dialog with a short message, and OK/Cancel buttons}
        msg "Message to display"
        /text "Include a text box for a simple, typed response"
        /prefill prefill-text "Text entry field prefilled value"
        /win-title title-text "The title that displays on the requester window"
    ] [
        formatted-msg: chunk-string copy msg 51
        line-count: count-newlines formatted-msg
        msg-size: to-pair reduce [350 (line-count * 18)]
        if not prefill [prefill-text: copy ""]
        if not win-title [title-text: copy "User Input Required"]
        view/options compose/deep [
            title (title-text)
            across
            base (msg-size) 240.240.240 top left font-size 10 (form formatted-msg)
            return
            (
                either text [
                    compose [
                        f-fld: field (prefill-text) 350 [
                            res: true
                            unview
                        ]
                        return
                    ]
                ]
                []
            )
            pad 200x0
            button "  OK  " [res: true unview]
            button "Cancel" [res: none unview]
            (either text [[do [set-focus f-fld]]] [])
        ] std-dialog-opts
        either any [std-dialog-actors/res res] [
            either text [f-fld/text] [true]
        ] [none]
    ]
    set 'confirm :prompt
    set 'request-text func [
        {Display a simple text entry dialog with a short message.}
        msg
    ] [
        prompt/text msg
    ]
    set 'request-list function [
        "Modified By: Mike Yaunish. Supports 'one-click'"
        msg
        data [block!]
        /size sz [pair!]
        /one-click "Allows one-click selection"
    ] [
        sz: any [sz 200x150]
        picked: 0
        either one-click [
            actor-name: 'on-select
            ok-status: 'hidden
        ] [
            actor-name: 'on-dbl-click
            ok-status: 'all-over
        ]
        view view-composed: compose/only/deep [
            across
            text font-size 12 200 (form msg) return
            f-lst: text-list sz data (data)
            on-select [picked: event/picked]
            (actor-name) [res: true picked: event/picked unview]
            return
            button "OK" on-click [res: true unview] (ok-status)
            button "Cancel" on-click [res: none unview]
            do [set-focus f-lst]
        ] std-dialog-opts
        if any [std-dialog-actors/res res] [pick f-lst/data picked]
    ]
    set 'get-custom-colors does [
        sort difference default-colors get-current-colors
    ]
    set 'default-colors ["aqua" "beige" "black" "blue" "brick" "brown" "coal" "coffee" "crimson" "cyan" "forest" "glass" "gold" "gray" "green" "ivory" "khaki" "leaf" "linen" "magenta" "maroon" "mint" "navy" "oldrab" "olive" "orange" "papaya" "pewter" "pink" "purple" "reblue" "rebolor" "red" "sienna" "silver" "sky" "snow" "tanned" "teal" "transparent" "violet" "water" "wheat" "white" "yello" "yellow"]
    set 'get-current-colors does [next sort extract split replace/all lowercase trim fetch-help tuple! [some [#" " | #"^/"]] #" " #" " 2]
    set 'request-color function [
        "Display a simple color picker"
        /title txt [string!]
        /over ctr [object!] "Center over this face"
        /offset pos [pair!] "Top-left offset of window"
    ] [
        sz: 530x350
        sample-sz: as-pair 60 sz/y
        palette: make image! sz
        draw palette compose [
            pen off
            fill-pen linear red orange yellow green aqua blue purple
            box 0x0 (sz)
            fill-pen linear white transparent black 0x0 (as-pair 0 sz/y)
            box 0x0 (sz)
        ]
        res: copy ""
        named-layout: create-color-layout default-colors
        custom-named-layout: create-color-layout/large-names get-custom-colors
        bind named-layout 'res
        spec: compose/deep [
            title (any [txt "Select a Color"])
            tab-pan: tab-panel [
                "Pallete" [
                    image palette all-over on-down [dn?: true]
                    on-up [
                        if dn? [
                            res: pick palette to-pair event/offset
                            unview
                        ]
                    ]
                    on-over [
                        picked: pick palette to-pair event/offset
                        if not none? picked [
                            sample-box/color: to-tuple picked
                            sample-value/text: to-string picked
                        ]
                    ]
                    return
                    sample-box: base 200x40
                    sample-value: text 140x40 font-size 14 "" left middle
                ]
                "Default Named Colors" [
                    (named-layout)
                ]
                "Other Named Colors" [
                    (custom-named-layout)
                ]
            ]
        ]
        opts: copy/deep std-dialog-opts
        if pair? pos [append opts compose [offset: (pos)]]
        if ctr [init: [center-face/with face ctr]]
        show-dialog/options/with spec opts init
        res
    ]
    create-color-layout: function [
        color-list [block!]
        /large-names
    ] [
        either large-names [
            bas-size: 132x40
            txt-size: 132x36
            row-width: 4
        ] [
            bas-size: 65x40
            txt-size: 65x18
            row-width: 8
        ]
        color-layout: compose [
            style txt: base (txt-size) wrap center middle 222.222.184 on-down [res: to-tuple get to-word face/text unview]
            style bas: base (bas-size) on-down [res: face/color unview]
        ]
        forskip color-list row-width [
            color-row: copy/part color-list row-width
            append color-layout [space 2x0]
            foreach color-name color-row [
                append color-layout compose [
                    bas (to-word color-name)
                ]
            ]
            append color-layout [return]
            foreach color-name color-row [
                append color-layout compose [
                    txt (color-name)
                ]
            ]
            append color-layout [
                space 2x10
                return
            ]
        ]
        return color-layout
    ]
]
