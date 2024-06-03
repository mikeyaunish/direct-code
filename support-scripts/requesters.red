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
        msg 
        /text "Include a text box for a simple, typed response" 
        /prefill prefill-text "text entry field prefilled value" 
        /size msg-size [pair!]
    ] [
        message-size: either size [
            msg-size
        ] [
            350x40
        ] 
        view/options compose [
            title "User Input Required" 
            across 
            text font-size 12 (message-size) (form msg) 
            return 
            (
                either text [
                    [
                        f-fld: field 350 [
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
    set 'request-color function [
        "Display a simple color picker" 
        /size sz [pair!] 
        /title txt [string!] 
        /over ctr [object!] "Center over this face" 
        /offset pos [pair!] "Top-left offset of window"
    ] [
        sz: any [sz 150x150] 
        palette: make image! sz 
        draw palette compose [
            pen off 
            fill-pen linear red orange yellow green aqua blue purple 
            box 0x0 (sz) 
            fill-pen linear white transparent black 0x0 (as-pair 0 sz/y) 
            box 0x0 (sz)
        ] 
        spec: compose [
            title (any [txt ""]) 
            image palette all-over on-down [dn?: true] 
            on-up [
                if dn? [
                    res: pick palette to-pair event/offset 
                    unview
                ]
            ] 
            on-over []
        ] 
        opts: copy/deep std-dialog-opts 
        if pair? pos [append opts compose [offset: (pos)]] 
        if ctr [init: [center-face/with face ctr]] 
        show-dialog/options/with spec opts init 
        res
    ]
]
