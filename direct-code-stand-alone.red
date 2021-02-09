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

set 'load-and-run function [ filename /no-save] [ ; load-and-run: 
    either (value? 'dc-ctx) [
        dc-ctx/load-direct-code filename
        either no-save [
            dc-ctx/run-and-save/no-save    
        ][
            dc-ctx/run-and-save
        ]
    ][
        filename: clean-path filename
        if (exists? filename)[
            unview/all
            do filename    
        ]
    ]
]
