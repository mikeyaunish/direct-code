Red [ 
    Name: "Direct Code Stand Alone Functions"
    Comment: "These functions will run in both Development and Deployment"
]

lprint: function [ s ] [
    write/append/lines %direct-code.log form reduce s    
]

bprint: function [ s ] [
    print s
    lprint s
]

set 'load-and-run function [ 
    filename [file!]
    /no-save
][ ;-- load-and-run:
    either (value? 'dc-initialized)  [ ;-- loading into the development environment
        dc-load-direct-code filename
        either no-save [
            run-and-save/no-save "no-save"    
        ][
            run-and-save "dev-init"
        ]
    ][  ;-- loading the file as a stand alone program
        filename: clean-path filename
        if (exists? filename)[
            unview/all
            do filename    
        ]
    ]
]
