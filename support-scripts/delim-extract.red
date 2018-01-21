Red [
    Title: "delim-extract"
]


delim-extract: func [
    "returns a block of every string found that is surrounded by defined delimeters"
     source-str [string!] "Text string to extract from."
     left-delim [string!] "Text string delimiting the left side of the desired string."
     right-delim [string!] "Text string delimiting the right side of the desired string."
     /include-delimiters "Returned extractions will include the delimiters"
     /use-head "Head of string is used as left delimiter"
     /first "Return the first match found only"
     /pairs-only "Return only fully matched pairs of delimiters. Left and right delimiter need to be the same."
     /local tags tag i j paired-tags
]
[
    tag: ""
    tags: copy []
    if use-head [
        either include-delimiters [
            parse source-str [ copy tag thru right-delim ]
            insert head tag left-delim
        ][
            parse source-str [ copy tag to right-delim ]
        ]
        append tags tag
    ]
    either  include-delimiters [
        parse source-str [some [ [ thru left-delim copy tag to right-delim ] (append tags rejoin [ left-delim tag right-delim] )]]
    ][
        parse source-str [some [ [ thru left-delim copy tag to right-delim ] (append tags tag)]]
    ]
    either first [
    	either ((length? tags) = 0 ) [
    	    return none
    	][
    	    return tags/1
        ]
    ][
        either all [ pairs-only (left-delim = right-delim)][
            paired-tags: copy []
            foreach [ i j ] tags  [
                append paired-tags i
            ]
            return paired-tags
        ][
            return tags    
        ]
    ]
]