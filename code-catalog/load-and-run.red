Red [
	Title: "load-and-run.red"
]
load-and-run: function [
    filename [file!] 
    /no-save
][
    either (value? 'dc-initialized) [
        dc-load-direct-code filename 
        either no-save [
            run-and-save/no-save ""
        ] [
            run-and-save "dev-load-and-run"
        ]
    ] [
        filename: clean-path filename 
        if (exists? filename) [
            unview/all 
            do filename
        ]
    ] 
]