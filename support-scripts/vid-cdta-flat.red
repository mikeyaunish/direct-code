Red [
	Title: "vid-cdta-flat.red"
	Comment: "Imported from: <root-path>%experiments/vid-cdta-flat/vid-cdta-flat.red"
]
dc-vid-cdta-flat: context [
    set 'vid-cdta-flat func [
        {get source code in 'Canonical Data' (cdta) format }
        source [string!]
        /no-panel
    ] [
        full-input: copy source
        last-scan: [event 'first]
        open-block: false
        res-chunks: copy []
        chunk-index: 0
        open-chunk-string: false
        current-object-name: copy ""
        block-count: 0
        layout-words: [
            across below return space origin pad do
        ]
        face-keywords: [
            left center right top midle bottom bold italic underline extra data draw font para wrap no-wrap font-size
            font-color font-name react loose all-over hidden disabled password tri-state select focus hint rate default
            with
        ]
        add-chunk: func [event-blk [block!]] [
            chunk-index: chunk-index + 1
            if event-blk/type = set-word! [
                either chunk-index > 1 [
                    prev-scan: pick res-chunks (chunk-index - 1)
                ] [
                    prev-scan: reduce ['index 'none 'object 'none 'input 'none 'type 'none 'token 'none 'line 'none]
                ]
                current-object-name: to-string to-word (trim copy event-blk/input)
                if (prev-scan/type = pair!) [
                    two-back: pick res-chunks (chunk-index - 2)
                    if ((trim copy two-back/input) = "at") [
                        prev-scan/object: current-object-name
                        two-back/object: current-object-name
                    ]
                ]
                if (prev-scan/input = "style") [
                    one-back: pick res-chunks (chunk-index - 1)
                    prev-scan/object: current-object-name
                    one-back/object: current-object-name
                ]
            ]
            change-object?: false
            trimmed-input: either event-blk/type <> file! [
                trim/tail/with trim/all copy event-blk/input "/"
            ] [
                copy event-blk/input
            ]
            if event-blk/type = word! [
                if find layout-words (to-word trimmed-input) [change-object?: true]
            ]
            recorded-object-name: copy current-object-name
            if any [
                (event-blk/type = 'comment)
                (trimmed-input = "")
                change-object?
            ] [
                recorded-object-name: copy ""
                if event-blk/type <> 'comment [
                    current-object-name: copy ""
                ]
            ]
            insert event-blk reduce ['index chunk-index]
            insert (skip event-blk 2) reduce ['object recorded-object-name]
            append event-blk reduce ['parent ""]
            return event-blk
        ]
        dc-lexer: function [
            event [word!]
            input [string! binary!]
            type [datatype! word! none!]
            line [integer!]
            token
            return: [logic!]
            /extern full-input last-scan open-block chunk-index current-object-name block-count open-chunk-string
        ] [
            [scan open close]
            open-square: "["
            close-square: "]"
            if all [(event = 'open) (type = string!)] [
                open-chunk-string: copy input
            ]
            chunk-string: either ((type? token) = pair!) [
                copy/part skip full-input (token/x - 1) (token/y - token/x + 1)
            ] [
                copy input
            ]
            last-scan-not-none: event-load: false
            either open-block [
                if all [(event = 'open) (chunk-string = "[") (open-block = [])] []
                if all [(event = 'open) (chunk-string = "[")] [
                    block-count: block-count + 1
                ]
                if all [(event = 'close) (type = block!)] [
                    block-count: block-count - 1
                    if (block-count = 0) [
                        append open-block token
                        block-data: copy/part skip full-input (open-block/2/x - 1) (open-block/3/y - open-block/2/x + 1)
                        chunk-index: chunk-index + 1
                        append/only res-chunks cls-blk: reduce ['index chunk-index 'object current-object-name 'input block-data 'type block! 'token (to-pair reduce [open-block/2/x open-block/3/y]) 'line (to-pair reduce [open-block/1 line]) 'parent ""]
                        open-block: false
                        open-chunk-string: FALSE
                    ]
                ]
            ] [
                either (type = block!) [
                    either chunk-string = "[" [
                        open-block: reduce [line token]
                        block-count: block-count + 1
                    ] []
                ] [
                    either any [
                        all [(last-scan <> none) (last-scan/event <> none)]
                        (last-scan/event = 'first)
                    ] [
                        if any [
                            (all [(event = 'close) (chunk-string <> close-square)])
                            (all [(event = 'open) (chunk-string <> open-square)])
                        ] [
                            return none
                        ]
                        switch/default (to-string type) [
                            "string" [
                                either open-chunk-string [
                                    input-str: trim/head/tail copy open-chunk-string
                                    input-str: copy/part input-str (token/y - token/x)
                                    open-chunk-string: FALSE
                                ] [
                                    input-str: trim/head/tail chunk-string
                                ]
                            ]
                            "file" [
                                input-str: to-file to-valid-file chunk-string
                            ]
                        ] [
                            input-str: trim-non-char (trim chunk-string)
                        ]
                        this-scan: reduce ['input input-str 'type type 'token token 'line line]
                        append/only res-chunks add-chunk this-scan
                    ] []
                ]
            ]
            last-scan: reduce ['event event 'input chunk-string 'type type 'token token 'line line]
            either event = 'error [input: next input no] [yes]
        ]
        transcode/trace source :dc-lexer
        return res-chunks
    ]
]
