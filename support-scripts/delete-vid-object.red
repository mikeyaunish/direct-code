Red [
	Title: "delete-vid-object.red"
	Comment: "Imported from: <root-path>%experiments/delete-vid-object/delete-vid-object.red"
]
set 'delete-vid-object function [
    "V2 remove VID object from vid-code/text"
    obj-name [string!]
] [
    obj-info: get-object-source/whitespace/position/with-newline obj-name vid-code/text
    skipping-amt: part-amt: 1
    full-src: copy/part (skip vid-code/text obj-info/3/x - skipping-amt) (obj-info/3/y - obj-info/3/x + skipping-amt)
    if all [
        any [
            (first head full-src) = #" "
            (first head full-src) = #"^-"
        ]
        (back tail full-src) = " "
    ] [
        skipping-amt: 0
        part-amt: 0
    ]
    full-src: copy/part (skip vid-code/text obj-info/3/x - skipping-amt) (obj-info/3/y - obj-info/3/x + part-amt)
    remove/part (skip vid-code/text (obj-info/3/x - skipping-amt)) (obj-info/3/y - obj-info/3/x + part-amt)
    return reduce [full-src (obj-info/3/x - skipping-amt)]
]
