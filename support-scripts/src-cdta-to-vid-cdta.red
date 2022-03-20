Red [
	Title: "src-cdta-to-vid-cdta.red"
	Comment: "Extracted from: <root-path>%experiments/src-cdta-to-vid-cdta/src-cdta-to-vid-cdta.red"
	Date: 19-Mar-2022
	Time: 20:41:08
]

    dc-src-cdta-to-vid-cdta: context [
        select-all-in-object: function [
            'obj [object! lit-word!] 
            the-path [word! block! lit-word!]
        ] [
            obj: get obj 
            set 'safe-select function [w p] [
                return either not ((got: select w p) = none) [
                    got
                ] [
                    none
                ]
            ] 
            either (block? the-path) [
                results: obj 
                foreach wrd the-path [
                    if (not (results: safe-select results wrd)) [
                        return none
                    ]
                ] 
                return results
            ] [
                return safe-select obj the-path
            ]
        ] 
        expand-actors: function [v] [
            actors-records: find-in-array-at/with-index v 1 'actors 
            if actors-records [
                actors-index: actors-records/2 
                either (actors-records/1/actors <> none!) [
                    actors-actions: body-of actors-records/1/3 
                    remove (skip v (actors-index - 1)) 
                    foreach [actor-name bdy] actors-actions [
                        actor-body: body-of select actors-actions (to-word actor-name) 
                        actor-name: to-word actor-name 
                        insert/only (skip v (actors-index - 1)) to-block (reduce [reduce ['actors actor-name] block! actor-body])
                    ]
                ] [
                    remove (skip v (actors-index - 1))
                ]
            ]
        ] 
        expand-flags: function [v] [
            flag-record: find-in-array-at/with-index v 1 'flags 
            if flag-record/1/2 <> none! [
                remove (skip v (flag-record/2 - 1)) 
                foreach f (if-single-to-block flag-record/1/3) [
                    insert/only (skip v (flag-record/2 - 1)) reduce [reduce ['flags f] logic! true]
                ]
            ]
        ] 
        expand-font-style: function [v] [
            style-record: find-in-array-at/with-index v 1 [font style] 
            either (style-record) [
            ] [
            ] 
            if not any [(style-record = false) (style-record/1/2 = none!)] [
                active-font-styles: style-record/1/3 
                active-font-styles: if-single-to-block active-font-styles 
                either active-font-styles [
                    remove (skip v (style-record/2 - 1)) 
                    foreach font-style active-font-styles [
                        insert/only (skip v (style-record/2 - 1)) to-block (reduce [reduce ['font font-style] logic! true])
                    ]
                ] [
                    remove (skip v (style-index - 1))
                ]
            ]
        ] 
        adjust-vid-cdta: function [
            {v01 Collect fields: 'focus,'image,'react and 'with 'date 'url from the source code. ^M^/             convert visible? to hidden and enabled? to disabled.^M^/             offset and size 'starting-values' so the GUI knows initial values^M^/             no-wrap from source ^M^/             block layout from source for: panel, group-box and tab-panel^M^/             get true/false } 
            output 
            object-name 
            source-code
        ] [
            src-info: second get-obj-info source-code (to-string object-name) [] 
            input-field: 6 
            type-field: 8 
            obj-type: pick (find-in-array-at output 1 'type) 3 
            focus-record: find-in-array-at src-info input-field "focus" 
            focus-state: either focus-record [true] [none] 
            append/only output reduce ['focus logic! focus-state] 
            image-record: find-in-array-at (head src-info) type-field file! 
            image-val: either image-record [(to-file image-record/input)] [none] 
            append/only output reduce ['image file! image-val] 
            react-word-pos: find-in-array-at/with-index src-info input-field "react" 
            react-val: either react-word-pos [
                val: copy/part (skip src-info react-word-pos/2) 1 
                load val/1/input
            ] [
                none
            ] 
            append/only output reduce ['react block! react-val] 
            with-word-record: find-in-array-at/with-index src-info input-field "with" 
            if with-word-record [
                append/only output reduce ['with block! load pick (pick src-info (with-word-record/2 + 1)) 6]
            ] 
            url-word-record: find-in-array-at/with-index src-info type-field url! 
            if url-word-record [
                append/only output reduce ['url url! (to-url url-word-record/1/6)]
            ] 
            if (visible?-record: find-in-array-at/with-index output 1 'visible?) [
                hidden-status: either visible?-record/1/3 [none] [true] 
                insert/only (remove skip output (visible?-record/2 - 1)) to-block (reduce ['hidden logic! hidden-status])
            ] 
            if (enabled?-record: find-in-array-at/with-index output 1 'enabled?) [
                disabled-status: either enabled?-record/1/3 [none] [true] 
                insert/only (remove skip output (enabled?-record/2 - 1)) to-block (reduce ['disabled logic! disabled-status])
            ] 
            either (obj-type = 'button) [
                size-adjust: 2x2 
                offset-adjust: -1x-1
            ] [
                size-adjust: 0x0 
                offset-adjust: 0x0
            ] 
            offset-record: find-in-array-at/with-index output 1 'offset 
            either first (offset-field: get-obj-info/with source-code (to-string object-name) [word! "at"] src-info) [
                insert/only (remove skip output (offset-record/2 - 1)) to-block reduce ['offset pair! ((to-pair offset-field/3) + offset-adjust)]
            ] [
                remove skip output (offset-record/2 - 1) 
                append/only output to-block reduce ['offset-starting-value pair! ((to-pair offset-record/1/3) + offset-adjust)]
            ] 
            size-record: find-in-array-at/with-index output 1 'size 
            either first (size-field: get-obj-info/with source-code (to-string object-name) [pair!] src-info) [
                insert/only (remove skip output (size-record/2 - 1)) to-block reduce ['size pair! ((to-pair size-field/2) + size-adjust)]
            ] [
                remove skip output (size-record/2 - 1) 
                append/only output to-block reduce ['size-starting-value pair! ((to-pair size-record/1/3) + size-adjust)]
            ] 
            if (calendar?: find-in-array-at/with-index src-info input-field "calendar") [] 
            if (date-record: find-in-array-at/with-index src-info type-field date!) [
                output-date-record: find-in-array-at/with-index output 1 'date 
                insert/only (remove skip output (output-date-record/2 - 1)) to-block (reduce ['date date! (string-to-date date-record/1/input)])
            ] 
            if (no-wrap-record: find-in-array-at src-info input-field "no-wrap") [
                append/only output to-block reduce ['para-no-wrap? logic! true]
            ] 
            if (select-record: find-in-array-at/with-index output 1 'selected) [
                if (select-record/1/3 = -1) [
                    remove skip output (select-record/2 - 1)
                ]
            ] 
            if not first (color-field: get-obj-info/with source-code (to-string object-name) [tuple!] src-info) [
                if (color-record: find-in-array-at/with-index output 1 'color) [
                    remove skip output (color-record/2 - 1)
                ]
            ] 
            data-field: get-obj-info/with source-code (to-string object-name) [word! "data"] src-info 
            either data-field/1 = none [
                data-record: find-in-array-at/with-index output 1 'data 
                style-type: pick (find-in-array-at output 1 [options style]) 3 
                if find [field text] style-type [
                    remove skip output (data-record/2 - 1)
                ]
            ] [
                valid-val: string-to-valid-type data-field/3 
                val-type: type? valid-val 
                if val-type = logic! [
                    append/only output to-block reduce ['data-logic val-type valid-val]
                ]
            ] 
            if any [
                (obj-type = 'panel) 
                (obj-type = 'group-box) 
                (obj-type = 'tab-panel)
            ] [
                if (panel-record: get-obj-info/with source-code (to-string object-name) [block!] src-info) [
                    panel-block-data: to-block de-block-string panel-record/2 
                    append/only output to-block reduce ['layout-block block! panel-block-data]
                ]
            ] 
            style-type: pick (find-in-array-at output 1 [options style]) 3 
            if find [h1 h2 h3 h4 h5] style-type [
                font-size-record: find-in-array-at/with-index output 1 [font size] 
                remove skip output (font-size-record/2 - 1) 
                append/only output to-block reduce ['font-size-starting-value pair! font-size-record/1/3]
            ]
        ] 
        set 'src-cdta-to-vid-cdta function [
            'vid-object 
            source-code
        ] [
            object-name: to-word vid-object 
            if not (value? vid-object) [
                return none
            ] 
            output: copy [] 
            object-name: to-word vid-object 
            obj: get vid-object 
            append/only output reduce ['name 'set-word! to-set-word object-name] 
            field-list: [
                type [options style] text color [options drag-on] visible? enabled? 
                flags 
                size offset 
                [options hint] 
                [para align] [para v-align] [para wrap?] 
                [font name] [font size] [font color] [font style] [font anti-alias?] 
                actors 
                draw 
                data [options default] extra selected rate 
                date percent
            ] 
            foreach fld field-list [
                val: select-all-in-object (to-lit-word vid-object) fld 
                if (fld = 'font) [
                    if val [val/parent: []]
                ] 
                append/only output reduce [fld type? val val]
            ] 
            expand-actors output 
            expand-font-style output 
            expand-flags output 
            adjust-vid-cdta output object-name source-code 
            return output
        ]
    ]
