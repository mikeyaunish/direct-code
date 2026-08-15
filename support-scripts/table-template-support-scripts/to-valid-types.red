Red [ 
    Title: "to-valid-types.red"
]

cast-to-datatype: function [
	dtype [string! datatype!]
	val [any-type!]
][
	conv-func: get to-word rejoin [ "to-valid-" to-string dtype ]
	conv-func val
]

to-valid-integer: function [
    value [any-type!] /local attempt-result scan-type
][
    if unset? :value [return 0]
    if (attempt-result: attempt [to-integer value]) [
        return attempt-result
    ]
    if attempt-result: attempt [
        scan-type: scan value
        to-integer to :scan-type value
    ] [
        return attempt-result
    ]
    return 0
]

to-valid-pair: function [
    value [string! pair! point2D! none!] /local attempt-result scan-type
][
    if (attempt-result: attempt [to-pair value]) [
        return attempt-result
    ]
    if attempt-result: attempt [
        scan-type: scan value
        to-pair to :scan-type value
    ] [
        return attempt-result
    ]
    return 0x0
]

to-valid-string: function [s][
    return either any [
        (s = none)
        (s = false)
    ][
        ""
    ][
        to-string s
    ]
]

to-valid-tuple: function [ v [any-type!]][
	return either result: attempt [
		to-tuple v
	][
		result
	][
		128.128.128
	]
]

to-valid-logic: func [v][
    return switch/default (to-word type? v) [
        integer! [
            switch/default v [
                0 [false]
                1 [true]
            ] [
                true
            ]
        ]
        word! [
            switch/default v [
                true [true]
                false [false]
            ] [
                false
            ]
        ]
        string! [
            switch/default v [
                "true" [true]
                "false" [false]
                "0" [ false]
                "1" [ true ]
                "" [false]
            ] [
                true
            ]
        ]
        file! [
            switch/default v [
                %"" [false]
            ] [
                true
            ]
        ]
    ] [
        to-logic v
    ]
]

to-valid-float: function [ v [any-type!]][
	return either result: attempt [
		to-float v
	][
		result
	][
		0.0
	]
]

to-valid-money: function [ v [any-type!]][
	if string? v [ v: load v ]
	return either result: attempt [
		either float? v [
			to-money (round/to/ceiling v 0.01)
		][
			to-money v	
		]
	][
		result
	][
		$0
	]
]

to-valid-time: function [ v [any-type!]][
	return either result: attempt [
		to-time v
	][
		result
	][
		00:00:00
	]
]

to-valid-block: function [ v [any-type!]][
	return either result: attempt [
		to-block v
	][
		result
	][
		[]
	]
]

to-valid-char: function [ v [any-type!]][
	return either result: attempt [
		to-char v
	][
		result
	][
		#"-"
	]
]

to-valid-date: function [ v [any-type!]][
	v: either string? v [ load v ][ v ]
	return either result: attempt [
		to-date v
	][
		result
	][
		1-1-0001
	]
]

to-valid-percent: function [ v [any-type!]][
	return either result: attempt [
		to-percent v
	][
		result
	][
		0%
	]
]



