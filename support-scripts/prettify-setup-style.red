Red [
	Title: "prettify-setup-style.red"
	Comment: "Imported from: <root-path>%experiments/prettify-setup-style/prettify-setup-style.red"
]
prettify-setup-style: function [
    code [string!]
] [
    insert code "^/^-^-" 
    double-open-square-replacement: "[^/^-^-^-[" 
    double-close-square-replacement: "]^/^-^-]^-" 
    replace code "[[" double-open-square-replacement 
    if fnd: find code double-open-square-replacement [
        replace/all (skip code ((index? fnd) + 1)) "^/" "^/^-^-^-^-"
    ] 
    replace/all code "] [" "][" 
    replace code "]]" double-close-square-replacement 
    return code
]
