Red [
	Title: "print-table.red"
	Comment: "Imported from: <root-path>%experiments/print-table/print-table.red"
]
is-flat-block?: func [blk] [
    return either (block? blk/1) [false] [true]
]
series-to-blocks: func [
    series block-size
] [
    results: copy []
    forskip series block-size [
        new-blk: copy/part series block-size
        append/only results new-blk
    ]
    return results
]
pt: print-table: function [
    'table-blk "variable name containing the table. Version: 12 "
    /width column-width [integer! block!]
    /max-width max-wide [integer!] {Maximum width of any column.Only applies when /width is not used.}
    /output
    /name named-table [string!]
    /columns num-of-cols
    /column-names col-names-blk [block!]
] [
    outstring: copy ""
    either output [
        tprin: function [s] [
            append outstring reduce s
        ]
        tprint: function [s] [
            append outstring reduce s
            append outstring newline
        ]
    ] [
        tprin: :prin
        tprint: :print
    ]
    either ((type? table-blk) = word!) [
        table-name: to-word table-blk
        table-block: get table-blk
        if none? table-block [table-block: []]
    ] [
        table-name: "<input block>"
        table-block: copy table-blk
    ]
    if name [
        table-name: copy named-table
    ]
    tprint rejoin ["---------------------- Table: '" table-name "' ----------------------"]
    to-block-in-block: function [blk] [
        either ((type? blk/1) <> block!) [reduce [blk]] [blk]
    ]
    set 'get-widest-column function [blk [block!] column-block [block!]] [
        either ((length? column-block) > 1) [
            widest-col: length? to-string (pck: pick (first blk) column-block/1)
            sec-col: column-block/2
        ] [
            widest-col: 0
            sec-col: column-block/1
        ]
        foreach i blk [
            len: length? to-string (pick i sec-col)
            if (len > widest-col) [widest-col: len]
        ]
        return widest-col
    ]
    either all [(is-flat-block? table-block) columns] [
        table-block: series-to-blocks table-block num-of-cols
    ] [
        table-block: to-block-in-block table-block
    ]
    max-wide: either max-width [max-wide] [60]
    width-list: copy []
    pad-size: either width [column-width] [10]
    either columns [
        cols-in-table: num-of-cols
    ] [
        cols-in-table: ((length? table-block/1) / 2)
        col-headings: first table-block
    ]
    either width [
        either ((type? column-width) = block!) [
            width-list: copy column-width
        ] [
            loop cols-in-table [
                append width-list column-width
            ]
        ]
    ] [
        ndx: 1
        loop cols-in-table [
            either columns [
                wc: get-widest-column table-block reduce [ndx]
                if column-names [
                    wc: max wc (length? (pick col-names-blk ndx))
                ]
            ] [
                wc: get-widest-column table-block reduce [(ndx * 2 - 1) (ndx * 2)]
            ]
            wc: either ((wc + 1) > max-wide) [max-wide] [wc]
            append width-list (wc + 1)
            ndx: ndx + 1
        ]
    ]
    if columns [
        col-headings: copy []
        ndx: 1
        either column-names [
            loop num-of-cols [
                col-name: (pick col-names-blk ndx)
                head-max-wide: pick width-list ndx
                if (length? col-name) > head-max-wide [
                    col-name: copy/part col-name (head-max-wide - 2)
                    append col-name to-char 187
                ]
                append col-headings col-name
                append col-headings ""
                ndx: ndx + 1
            ]
        ] [
            loop num-of-cols [
                append col-headings to-string to-char (64 + ndx)
                append col-headings ""
                ndx: ndx + 1
            ]
        ]
    ]
    ndx: 1
    tprin " "
    foreach [x y] col-headings [
        pad-size: (pick width-list ndx)
        tprin [pad x pad-size]
        ndx: ndx + 1
    ]
    tprint ""
    ndx: 1
    loop cols-in-table [
        pad-size: (pick width-list ndx)
        tprin pad/with (copy " ") pad-size #"-"
        ndx: ndx + 1
    ]
    tprint ""
    foreach entry table-block [
        ndx: 1
        tprin " "
        either columns [
            skip-count: 1
        ] [
            entry: copy skip entry 1
            skip-count: 2
        ]
        forskip entry skip-count [
            y: first entry
            pad-size: (pick width-list ndx)
            ndx: ndx + 1
            z: copy mold-no-quote to-string y
            if (length? z) > (pad-size - 1) [
                z: copy/part z (pad-size - 2)
                append z to-char 187
            ]
            tprin rejoin [pad z pad-size]
        ]
        tprint ""
    ]
    if output [return outstring]
]
