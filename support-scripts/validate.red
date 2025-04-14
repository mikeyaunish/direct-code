Red [
	Title: "validate.red"
	Comment: "Imported from: <root-path>%experiments/validate/validate.red"
]
set 'validate function [
    "Validates a target against a provided test"
    target [string! file! none!]
    validator [block!]
    retry-message [block!]
] [
    if none? target [return none]
    bind retry-message 'target
    msg: rejoin retry-message
    if file? target [
        set [file-path file-name] split-path target
    ]
    if results: do bind validator 'target [
        return results
    ]
    while [not results] [
        if results = false [
            return false
        ]
        either req-results: prompt/text/win-title msg "Data Entry Error" [
            if file? target [
                req-results: to-file rejoin [file-path req-results]
            ]
            results: validate req-results validator retry-message
        ] [
            return false
        ]
    ]
    return results
]
set 'validate-file function [
    target [file! string!]
    msg-block [block!]
] [
    results: validate target [if (not exists? to-file target) [to-file target]] msg-block
    return results
]
set 'validate-all function [
    target [string!]
    validation-list [block!]
] [
    test-condition: 1
    retry-message: 2
    either not results: validate target validation-list/1/:test-condition validation-list/1/:retry-message [
        return false
    ] [
        target: results
    ]
    if ((length? validation-list) > 1) [
        foreach validate-message skip validation-list 1 [
            either not results: validate target validate-message/:test-condition validate-message/:retry-message [
                return false
            ] [
                if results <> target [
                    return validate-all results validation-list
                ]
            ]
        ]
    ]
    return target
]
set 'validate-string function [
    value
] [
    to-safe-string value
]
set 'validate-logic function [
    value
] [
    all-to-logic value
]
set 'validate-file function [
    value
] [
    to-valid-file value
]
set 'validate-color function [
    value
] [
    value
]
set 'validate-pair function [
    value
] [
    to-string to-safe-pair value
]
set 'validate-date function [
    value
] [
    to-string to-date load to-string value
]
set 'validate-integer function [
    value
] [
    to-safe-integer value
]
set 'validate-word function [
    value [string! none!]
    /return-string
] [
    if any [
        value = ""
        none? value
    ] [
        return either return-string [""] [false]
    ]
    results: validate-all value [
        [
            [
                if (not value? (to-word target)) [
                    target
                ]
            ]
            ["The word '" target "' is already in use. Please try another word."]
        ]
        [
            [
                refresh-style-catalog
                if any [
                    ((to-string second split-path current-file) = rejoin [value "-style.red"])
                    (not find dc-catalog-styles target)
                ] [
                    target
                ]
            ]
            ["The word '" target {' is used in the Style Catalog. Please try another word or click 'Cancel' to IGNORE this error.}]
        ]
        [
            [
                refresh-scenario-catalog
                if any [
                    ((to-string second split-path current-file) = rejoin [value "-scenario.red"])
                    (not find dc-scenarios target)
                ] [
                    target
                ]
            ]
            ["The word '" target {' is used in the Scenario Catalog. Please try another word or click 'Cancel' to IGNORE this error.}]
        ]
        [
            [
                local-styles: collect [foreach [x y] (get-styles vid-code/text) [keep x]]
                if (not find local-styles to-word trim target) [
                    target
                ]
            ]
            ["The word '" target {' is in use as a local style. Please try another word or click 'Cancel' to IGNORE this error.}]
        ]
    ]
    return either return-string [to-safe-string results] [results]
]
