Red [
	Title: "get-selected-object-info.red"
	Comment: "Imported from: <root-path>%experiments/get-selected-object-info/get-selected-object-info.red"
]
get-selected-object-info: function [
    {Returns a block with [ <selected object name> <after-state> <end-of-script-state> ] }
] [
    after-state: none
    if insert-method/selected = 2 [
        after-state: true
    ]
    if insert-method/selected = 1 [
        after-state: false
    ]
    either selected-object-field/text = dc-default-selected-object-string [
        either after-state [
            obj-name: get-vid-object-name/last vid-code/text
        ] [
            obj-name: get-vid-object-name/first vid-code/text
        ]
        end-of-script-state: either after-state [true] [false]
        return reduce [obj-name after-state end-of-script-state]
    ] [
        return reduce [selected-object-field/text after-state false]
    ]
]
