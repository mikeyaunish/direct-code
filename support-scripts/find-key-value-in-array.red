Red [
	Title: "find-key-value-in-array.red"
	Comment: "Imported from: <root-path>%experiments/find-key-value-in-array/find-key-value-in-array.red"
]
find-key-value-in-array: function [
    "v3 in find-key-value-in-array.red"
    block-array [block!]
    needle [block!] {<key> lit-word! <value> any-value! pair to search for. Can be multiple key/value pairs}
    /index "return index offset instead of data"
] [
    haystack: copy block-array
    forskip needle 2 [
        small-needle: copy/part needle 2
        haystack: get-key-value-match-in-array/:index haystack fix-dt small-needle
        if none? haystack [
            return none
        ]
    ]
    return haystack
]
get-key-value-match-in-array: function [
    block-array [block!]
    needle [block!] {<key> lit-word! <value> any-value! pair to search for. Only one key/value pair allowed }
    /index "return index offset instead of data"
] [
    results: copy []
    index-count: 0
    foreach block-item block-array [
        index-count: index-count + 1
        foreach [key-word value] needle [
            if not ((sel: select block-item key-word) = value) [
                break
            ]
            either index [
                append results index-count
            ] [
                append/only results block-item
            ]
        ]
    ]
    return either results = [] [
        none
    ] [
        results
    ]
]
