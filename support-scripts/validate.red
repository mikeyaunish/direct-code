Red [
	Title: "validate.red"
	Comment: "Imported from: <root-path>%experiments/validate/validate.red"
]
set 'validate function [
    "Validates a target against a provided test" 
    target [string!] 
    validator [block!] 
    retry-message [block!]
] [
    bind retry-message 'target 
    msg: rejoin retry-message 
    if results: do bind validator 'target [
        return results
    ] 
    while [not results] [
        if results = false [
            return false
        ] 
        either req-results: prompt/text/size msg 400x80 [
            results: validate req-results validator retry-message
        ] [
            return false
        ]
    ] 
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
