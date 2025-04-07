Red [
	Title: "source-to-data.red"
	Comment: "Imported from: <root-path>%experiments/source-to-data/source-to-data.red"
]
source-to-data: function [
    code-block [block!]
    /root-object root-object-type [word!]
    /extern dc-default-action-list
] [
    results-vals: copy []
    store: func [blk] [
        append results-vals (to-set-word first blk)
        append/only results-vals reduce (skip blk 1)
    ]
    actor-block-owners: collect [
        foreach [evt evt-name] system/view/evt-names [
            keep evt-name
        ]
    ]
    trimmed-action-list: copy dc-default-action-list
    foreach item [panel tab-panel group-box] [
        fnd: find trimmed-action-list item
        remove/part fnd 2
    ]
    object-type: none
    parse-results: parse/case code-block [
        any [
            'left (store ['para-h-align 'left])
            | 'center (store ['para-h-align 'center])
            | 'right (store ['para-h-align 'right])
            | 'top (store ['para-v-align 'top])
            | 'middle (store ['para-v-align 'middle])
            | 'bottom (store ['para-v-align 'bottom])
            | 'bold (store ['font-bold true])
            | 'italic (store ['font-italic true])
            | 'underline (store ['font-underline true])
            | 'strike (store ['font-strike true])
            | 'extra mark: (store ['extra first mark]) skip
            | 'data mark: (store ['data first mark]) skip
            | 'draw mark: (store ['draw first mark]) skip
            | 'font mark: (
                if (first mark) = [anti-alias?: true] [
                    store ['font-anti-alias? true]
                ]
                if (first mark) = [anti-alias?: 'ClearType] [
                    store ['font-anti-alias? 'ClearType]
                ]
            ) skip
            | 'para mark: (store ['para first mark])
            | 'wrap (store ['para-wrap? "wrap"])
            | 'no-wrap (store ['para-wrap? "no-wrap"])
            | 'focus (store ['focus true])
            | 'font-name mark: (store ['font-name first mark]) skip
            | 'font-size mark: (store ['font-size first mark]) skip
            | 'font-color mark: (store ['font-color first mark]) skip
            | 'options mark: (store ['options first mark])
            | 'loose (store ['options-drag-on 'down])
            | 'all-over (store ['flags-all-over true])
            | 'password (store ['flags-password true])
            | 'tri-state (store ['flags-tri-state true])
            | 'scrollable (store ['scrollable true])
            | 'hidden (store ['hidden true])
            | 'disabled (store ['disabled true])
            | 'select mark: (store ['selected first mark]) skip
            | 'rate mark: (store ['rate first mark])
            | 'default mark: (store ['options-default first mark]) skip
            | 'no-border (store ['flags-no-border true])
            | 'space mark: (store ['space first mark])
            | 'hint mark: (store ['options-hint first mark])
            | 'cursor mark: (store ['cursor first mark])
            | 'init mark: (store ['init first mark])
            | 'with mark: (store ['with first mark]) skip
            | 'tight mark: (store ['tight true])
            | 'react mark: (store ['react first mark]) skip
            | 'style mark: (store ['options-style to-word (first mark)])
            | 'at mark: (store ['offset first mark]) skip
            | 'true mark: (
                store ['data true]
                store ['true-false true]
            )
            | 'false mark: (
                store ['data false]
                store ['true-false false]
            )
            | pair! mark: (store ['size first back mark])
            | block! mark: (
                block-text: first back back mark
                block-data: first back mark
                block-object-type: to-word first results-vals/type
                either find actor-block-owners block-text [
                    keyword: to-lit-word rejoin ["actors-" block-text]
                    store reduce [keyword block-data]
                ] [
                    if (not stock-style? block-object-type) [
                        block-object-type: root-object-type
                    ]
                    if block-text <> 'options [
                        either def-action: select trimmed-action-list block-object-type [
                            keyword: to-lit-word rejoin ["actors-" def-action]
                            store reduce [keyword block-data]
                        ] [
                            if stock-style? block-object-type [
                                store ['layout-block block-data]
                            ]
                        ]
                    ]
                ]
            )
            | file! mark: (store ['image first back mark])
            | set-word! mark: (
                store ['type first mark]
            )
            | string! mark: (store ['text first back mark])
            | url! mark: (store ['url first back mark])
            | integer! mark: (store ['size to-pair reduce [(first back mark) 0]])
            | date! mark: (
                store ['data first back mark]
                store ['date first back mark]
            )
            | percent! mark: (
                store ['data first back mark]
                store ['percent first back mark]
            )
            | tuple! mark: (store ['color first back mark])
            | skip
        ]
    ]
    return results-vals
]
