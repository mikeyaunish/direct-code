Red [
	Title: "request-setup-facets.red"
	Comment: "Imported from: <root-path>%experiments/request-setup-facets/request-setup-facets.red"
]
setup-facets: [
    "text" [
        input [
            prompt "Text string"
            detail "The text that will display on the object created."
        ]
        action [
            alter-facet/value 'text input-value
        ]
    ]
    "name" [
        input [
            prompt "Object name"
            detail "The name given to the object created."
            validator "object-name"
        ]
        action [
            alter-facet/value 'name input-value
        ]
    ]
    "size" [
        input [
            prompt "Size"
            detail "The size of the object created."
        ]
        action [
            alter-facet/value 'size to-pair input-value
        ]
    ]
    "color" [
        input [
            prompt "Color"
            detail "Enter the color you wish to use on this object"
        ]
        action [
            alter-facet/value 'color to-tuple input-value
        ]
    ]
    "loose" [
        input [
            prompt "Loose Y/N?"
            detail "Loose allows the object to be dragged around"
        ]
        action [
            if (uppercase input-value) = "Y" [
                alter-facet 'loose
            ]
        ]
    ]
    "hidden" [
        input [
            prompt "Hidden Y/N?"
            detail "If the object is hidden or not."
        ]
        action [
            if (uppercase input-value) = "Y" [
                alter-facet 'hidden
            ]
        ]
    ]
    "with" [
        input [
            prompt "Save name"
            detail "Add custom data to the 'with' block."
        ]
        action [
            alter-facet/value 'with compose/deep [save-name: (input-value)]
        ]
    ]
    "draw" [
        input [
            prompt "Circle size"
            detail "The size of circle."
        ]
        action [
            object-size: get to-path reduce [to-word object-name 'size]
            object-center: object-size / 2
            alter-facet/value 'draw compose/deep [circle (object-center) (to-integer input-value)]
        ]
    ]
    "right" [
        input [
            prompt "Right alignment Y/N"
            detail "The zzzz of the object created."
        ]
        action [
            if (uppercase input-value) = "Y" [
                alter-facet 'right
            ]
        ]
    ]
    "font-size" [
        input [
            prompt "Size of font"
            detail "Specify the size of the font on the object."
        ]
        action [
            alter-facet/value 'font-size to-integer input-value
        ]
    ]
]
facet-list: copy []
get-facet-list: does [
    facet-list: load rejoin [root-path %settings/facet-setup-list.data]
    data: copy []
    data: collect [
        foreach [id block] facet-list [
            keep id
        ]
    ]
    return data
]
request-setup-facets: function [] [
    multi-msg: {Select the facets you want to include in your 'setup-style'}
    if not facets-picked: request-items multi-msg "Facets" "Facets Selected" get-facet-list [
        return none
    ]
    setup-blocks: copy []
    only: true
    foreach facet-item facets-picked [
        facet-picked: select facet-list facet-item
        facet-block: select facet-list facet-item
        if block? facet-block/1 [
            only: false
        ]
        append/:only setup-blocks new-line (select facet-list facet-item) true
    ]
    setup-style-text: copy "setup-style: "
    append setup-style-text mold setup-blocks
    only: true
    return prettify-setup-style setup-style-text
]
