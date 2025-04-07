Red [
	Title: "get-styled-fields.red"
	Comment: "Imported from: <root-path>%experiments/get-styled-fields/get-styled-fields.red"
]
dc-styled-fields: context [
    set 'get-catalog-style function [
        "v2 of get-catalog-style"
        style-name
        /scenario "get a scenario style from the scenario catalog"
        /tree-block
        /extern dc-catalog-styles
    ] [
        if not find dc-catalog-styles style-name [
            return false
        ]
        all-source: read rejoin [dc-style-catalog-path rejoin [style-name "-style.red"]]
        style-source: select-text-block blank-out-comments/line all-source rejoin [style-name "-style-layout"]
        if ss: get-style-source/:tree-block style-name style-source [
            return ss
        ]
        return none
    ]
    compare-actors: function [
        {compares two actor objects. Returns a block like this [ equal [...] not-equal [...] ]}
        'a [word!]
        'b [word!]
    ] [
        equal: copy []
        not-equal: copy []
        a: get a
        b: get b
        words-of-a: words-of a
        words-of-b: words-of b
        foreach word words-of-a [
            if find words-of-b word [
                either (body-of :a/:word) = (body-of :b/:word) [
                    append equal reduce [word]
                ] [
                    append not-equal reduce [word]
                ]
            ]
        ]
        return reduce ['equal equal 'not-eqal not-equal]
    ]
    style-fields: [
        [size] size-label
        [text] text-label
        [image] image-label
        [color] color-label
        [data] data-label
        [enabled?] disabled-label
        [visible?] hidden-label
        [selected] selected-label
        [flags 'all-over] flags-all-over-label
        [flags 'tri-state] flags-tri-state-label
        [flags 'password] flags-password-label
        [flags 'no-border] flags-no-border-label
        [options drag-on 'down] options-drag-on-label
        [options hint] options-hint-label
        [options default] options-default-label
        [rate] rate-label
        [para align] para-h-align-label
        [para v-align] para-v-align-label
        [para wrap?] para-wrap?-label
        [font name] font-name-label
        [font size] font-size-label
        [font color] font-color-label
        [font style 'bold] font-bold-label
        [font style 'italic] font-italic-label
        [font style 'underline] font-underline-label
        [font style 'strike] font-strike-label
        [font anti-alias?] font-anti-alias?-label
        [actors] nil
        [extra] extra-label
        [draw] draw-label
        [dummy-entry] focus-label
    ]
    set 'get-styled-labels function [
        /extern style-fields
    ] [
        results: collect [
            foreach [x label] style-fields [
                keep label
            ]
        ]
        remove find results 'nil
        return results
    ]
    set 'get-style-source function [
        "V2 Return all source code for a specific style"
        style-name [string!]
        source-code [string!]
        /tree
        /tree-block
    ] [
        all-styles: get-styles source-code
        if not (find all-styles (to-set-word style-name)) [
            request-message rejoin ["Unable to find style: '" style-name "'^/within all current styles of:^/^-" mold all-styles]
            return none
        ]
        if tree [
            style-parents: get-style-parents style-name source-code
            results: copy ""
            foreach style style-parents [
                append results rejoin [(get-object-source (to-string style) source-code) newline]
            ]
            return results
        ]
        if tree-block [
            if not style-parents: get-style-parents style-name un-block-string copy source-code [
                style-parents: reduce [style-name]
            ]
            results: copy []
            foreach style style-parents [
                append results reduce [(to-string style) (get-object-source (to-string style) un-block-string copy source-code)]
            ]
            return results
        ]
        if return-val: get-object-source style-name un-block-string copy source-code [
            return return-val
        ]
        return none
    ]
    set 'get-fonts function [code-block [block!]] [
        return parse code-block [collect [any ['font-name keep string! | skip]]]
    ]
    set 'get-font-size function [
        code-block [block!]
        /all
    ] [
        return either all [
            parse code-block [collect [any ['font-size keep integer! | skip]]]
        ] [
            parse code-block [collect [to ['font-size keep integer!]]]
        ]
    ]
    set 'get-sizes function [code-block [block!]] [
        return parse code-block [collect [any [ahead pair! keep pair! | skip]]]
    ]
    set 'get-color function [code-block [block!]] [
        found-colors: parse code-block [
            collect [
                any [tuple! mark: keep (first back back mark) keep (first back mark) | skip]
            ]
        ]
        foreach [clr tag] reverse found-colors [
            if tag <> 'font-color [return clr]
        ]
        return none
    ]
    set 'get-styled-fields function [
        style-name [string!]
        style [object!]
        obj [word!]
        source-code [string!]
        /extern style-fields
    ] [
        highlight-fields: copy []
        collect-field: does [append highlight-fields (first next style-fields)]
        forskip style-fields 2 [
            fld: first style-fields
            obj-val: select-in-object (to-lit-word obj) fld
            style-val: select-in-object style fld
            either all [(obj-val = style-val) (obj-val <> none)] [
                style-tree: get-style-source/tree style-name source-code
                switch/default (to-string to-path fld) [
                    "color" [
                        the-color: get-color to-block style-tree
                        if obj-val = the-color [
                            collect-field
                        ]
                    ]
                    "size" [
                        sizes: get-sizes to-block style-tree
                        full-obj: get obj
                        obj-type: to-lit-word full-obj/type
                        if obj-val = last sizes [
                            collect-field
                        ]
                    ]
                    "enabled?" [
                        if obj-val = false [
                            collect-field
                        ]
                    ]
                    "visible?" [
                        if obj-val = false [
                            collect-field
                        ]
                    ]
                    "font/anti-alias?" [
                        if obj-val <> false [
                            collect-field
                        ]
                    ]
                    "font/name" [
                        style-fonts: get-fonts to-block style-tree
                        if (last style-fonts) = obj-val [
                            collect-field
                        ]
                    ]
                    "font/size" [
                        style-font-sizes: get-font-size/all to-block style-tree
                        if (last style-font-sizes) = obj-val [
                            collect-field
                        ]
                    ]
                    "para/wrap?" [
                        if obj-val <> false [
                            collect-field
                        ]
                    ]
                ] [
                    collect-field
                ]
            ] [
                if fld = [actors] [
                    a: select-in-object (to-lit-word obj) 'actors
                    b: select-in-object style 'actors
                    if all [(a <> none) (b <> none)] [
                        compare-results: compare-actors a b
                        foreach wrd compare-results/equal [
                            append highlight-fields (to-word rejoin ["actors-" wrd "-field"])
                        ]
                    ]
                ]
            ]
        ]
        return highlight-fields
    ]
]
