Red [
	Title: "view-vertical-layout.red"
	Comment: "Imported from: <root-path>%experiments/view-vertical-layout/view-vertical-layout.red"
]
view-vertical-layout: func [
    lay [block!] "layout block"
    /title the-title [string!] "title of the layout window"
    /size the-size
    /offset the-offset
] [
    the-layout: copy lay
    if not title [the-title: "Generated Layout"]
    if not size [the-size: 200x200]
    if not offset [
        screen-size: system/view/screens/1/size
        the-offset: to-pair reduce [(screen-size/x / 2) (screen-size/y / 2)]
    ]
    options-block: compose/deep ([offset: (reduce the-offset)])
    view/options [
        title the-title
        style vsp-underlay: panel gray
        extra [
            vsp-viewport-panel: ""
        ]
        on-create [
            set 'move-vertical-scroll-panel func [vertical-scroll-panel [object!] /wheel wheel-data] [
                viewport-object: get to-word vertical-scroll-panel/extra/vsp-viewport-panel
                max-percent: (1 - (viewport-object/size/y / vertical-scroll-panel/size/y))
                scroller-object: get to-word vertical-scroll-panel/extra/vsp-scroller
                either wheel [
                    scroller-object/data: max ((min max-percent scroller-object/data - (wheel-data / (max-percent * 11)))) 0
                ] [
                    scroller-object/data: max (min max-percent scroller-object/data) 0
                ]
                vertical-scroll-panel/offset/y: to integer! negate vertical-scroll-panel/size/y * scroller-object/data
            ]
            set 'modify-scroll-panel func [vertical-scroll-panel [object!] layout-block [block!]] [
                vertical-scroll-panel/pane: layout/only layout-block
                vertical-scroll-panel/size: select layout layout-block 'size
                scroller-object: get to-word vertical-scroll-panel/extra/vsp-scroller
                viewport-object: get to-word vertical-scroll-panel/extra/vsp-viewport-panel
                scroller-object/selected: (viewport-object/size/y / vertical-scroll-panel/size/y)
                scroller-object/data: 0.0
                move-vertical-scroll-panel vertical-scroll-panel
            ]
            vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel
            face/size: vsp-viewport-panel-object/size + 26x6
        ]
        style vertical-scroll-panel: panel
        extra [
            vsp-scroller: ""
            vsp-viewport-panel: ""
        ]
        style vsp-viewport-panel: panel
        extra [
            vertical-scroll-panel: ""
            vsp-scroller: ""
        ]
        on-wheel [
            move-vertical-scroll-panel/wheel (get to-word face/extra/vertical-scroll-panel) event/picked
        ]
        style vsp-scroller: scroller 16x16
        extra [
            vertical-scroll-panel: ""
            vsp-viewport-panel: ""
        ]
        on-change [
            move-vertical-scroll-panel (get to-word face/extra/vertical-scroll-panel)
        ]
        on-create [
            vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel
            face/size: to-pair reduce [16 vsp-viewport-panel-object/size/y]
        ]
        on-created [
            vsp-viewport-panel-object: get to-word face/extra/vsp-viewport-panel
            vertical-scroll-panel-object: get to-word face/extra/vertical-scroll-panel
            face/selected: (vsp-viewport-panel-object/size/y / vertical-scroll-panel-object/size/y)
        ]
        on-wheel [
            move-vertical-scroll-panel/wheel (get to-word face/extra/vertical-scroll-panel) event/picked
        ]
        vvl-vsp-underlay: vsp-underlay
        with [
            extra/vsp-viewport-panel: "vvl-vsp-viewport"
        ]
        [
            origin 3x3
            vvl-vsp-viewport: vsp-viewport-panel the-size
            with [
                extra/vertical-scroll-panel: "vvl-vsp-panel"
                extra/vsp-scroller: "vvl-vsp-scroller"
            ]
            [
                vvl-vsp-panel: vertical-scroll-panel
                []
                with [
                    extra/vsp-scroller: "vvl-vsp-scroller"
                    extra/vsp-viewport-panel: "vvl-vsp-viewport"
                ]
                on-create [
                    modify-scroll-panel vvl-vsp-panel the-layout
                ]
            ]
            space 4x2
            vvl-vsp-scroller: vsp-scroller
            with [
                extra/vertical-scroll-panel: "vvl-vsp-panel"
                extra/vsp-viewport-panel: "vvl-vsp-viewport"
            ]
        ]
    ]
    options-block
]
