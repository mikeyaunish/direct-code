Red [
	Title: "dc-prettify.red"
	Comment: "Imported from: <root-path>%experiments/dc-prettify/dc-prettify.red"
]
prettify: none
dc-prettify-ctx: context [
    draw-commands: make hash! [
        line curve box triangle polygon circle ellipse text arc spline image
        matrix reset-matrix invert-matrix push clip rotate scale translate skew transform
        pen fill-pen font line-width line-join line-cap anti-alias
    ]
    shape-commands: make hash! [
        move hline vline line curv curve qcurv qcurve arc
    ]
    VID-styles: make hash! keys-of system/view/VID/styles
    VID-panels: make hash! [panel group-box tab-panel]
    set 'dc-prettify function [
        {direct-code Mod-V1. Reformat BLOCK with new-lines to look readable. Various modifications}
        block [block! paren! map!] "Modified in place, deeply"
        /data "Treat block as data (default: as code)"
        /draw "Treat block as Draw dialect"
        /spec "Treat block as f.unction spec"
        /parse "Treat block as Parse rule"
        /vid "Treat block as VID layout"
        /split-at split-val {How many characters needed before a line is split. 0 = split everything. Needed for short segements}
        /local body word
    ] [
        if empty? orig: block [return orig]
        unless map? block [new-line/all block no]
        limit: either split-at [split-val] [80]
        excluded-words: ["rejoin" "reduce"]
        case [
            map? block [
                block: values-of block
                while [block: find/tail block block!] [
                    dc-prettify/data block
                ]
            ]
            data [
                while [block: find/tail block block!] [
                    dc-prettify/data inner: block/-1
                ]
                if any [
                    inner
                    limit <= length? mold/part orig limit
                ] [
                    new-line/skip orig yes 2
                ]
            ]
            spec [
                if limit > length? mold/part orig limit [return orig]
                new-line orig yes
                forall block [
                    if all-word? :block/1 [new-line block yes]
                    if /local == :block/1 [break]
                ]
            ]
            parse [
                if limit > length? mold/part orig limit [return orig]
                new-line orig yes
                forall block [
                    case [
                        '| == :block/1 [new-line block yes]
                        block? :block/1 [dc-prettify/parse block/1]
                        paren? :block/1 [dc-prettify block/1]
                    ]
                ]
            ]
            vid [
                styles: copy VID-styles
                split: [(new-line split?: p yes)]
                system/words/parse block layout: [any [p:
                set word word! if (find styles word) split (style: word)
                | 'at pair! opt set-word! set style word! split
                | set-word! set style word! split
                | 'style set word set-word! set style word! split
                (append styles to word! word)
                | 'draw
                change only set block block! (dc-prettify/draw block)
                | ['data | 'extra]
                change only set block block! (dc-prettify/data block)
                | change only set block block! (
                    vid: to logic! find VID-panels style
                    dc-prettify/:vid block
                )
                | skip]]
                if split? [new-line orig not split? =? orig]
            ]
            draw [
                if limit > length? mold/part orig limit [return orig]
                split: [p: (new-line back p yes)]
                system/words/parse orig rule: [any [
                    ahead block! p: (new-line/all p/1 off) into rule
                    | set word word! [
                        'shape any [
                            set word word! if (find shape-commands word) split
                            | skip
                        ]
                        | if (find draw-commands word) split
                    ]
                    | skip
                ]]
            ]
            'code [
                code-hints!: make typeset! [any-word! any-path!]
                until [
                    new-line block yes
                    tail? block: preprocessor/fetch-next block
                ]
                system/words/parse orig [any [p:
                ahead word! ['function | 'func | 'has]
                set spec block! (
                    dc-prettify/spec spec
                )
                set body block! (
                    dc-prettify body
                )
                | set block block! (
                    unless empty? block [
                        part: min 50 length? block
                        case [
                            not find/part block code-hints! part [
                                if not find excluded-words (to-string first back p) [
                                    dc-prettify/data block
                                ]
                            ]
                            find/case/part block '| part [
                                dc-prettify/parse block
                            ]
                            'else [
                                if not find excluded-words (to-string first back p) [
                                    dc-prettify block
                                ]
                            ]
                        ]
                        if new-line? block [
                            new-line p no
                        ]
                    ]
                )
                | set block paren! (
                )
                |
                skip]]
            ]
        ]
        orig
    ]
]
set 'prettify-setup-style function [
    code [string!]
] [
    insert code "^/^-^-"
    double-open-square-replacement: "[^/^-^-^-["
    double-close-square-replacement: "]^/^-^-]^-"
    replace code "[[" double-open-square-replacement
    if fnd: find code double-open-square-replacement [
        replace/all (skip code ((index? fnd) + 1)) "^/" "^/^-^-^-^-"
    ]
    replace/all code "] [" "]["
    replace code "]]" double-close-square-replacement
    return code
]
