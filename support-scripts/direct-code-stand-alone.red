Red [
	Title: "direct-code-stand-alone.red"
	Comment: "Imported from: <root-path>%experiments/direct-code-stand-alone/direct-code-stand-alone.red"
]
set 'load-and-run function [
    filename [file!]
    /no-save
] [
    either (value? 'dc-initialized) [
        dc-load-direct-code filename
        either no-save [
            run-and-save/no-save ""
        ] [
            run-and-save "devel-load-and-run"
        ]
    ] [
        filename: clean-path filename
        if (exists? filename) [
            unview/all
            do filename
        ]
    ]
]
