Red [
    Needs: View
    Title: "request-a-file"
    tabs: 4
]

request-a-file: func [ 
    current-file [file! string!] {current file - if there is one, otherwise ""}
    message [ string! ] {Message to display}
    prompt [ string! ] {Prompt that appears in front of field}
][ 
    ret-val: copy ""
    return-val: func [ /cancel ][ 
        either cancel [
            ret-val: none
        ][
            ret-val: to-red-file any [ file-field/text "" ]    
        ]
        unview/only rre
    ]
    rre: layout [
        title "Select a File"
        across
        space 8x8
        text "" 120x24
        text message
        return
        text prompt right 120x24 font-size 10  space 0x8
        file-field: field 400x24 [ 
            return-val
        ]
        space 2x8 
        exec-pick: button "^^"  24x24 [
            if (filename: request-file ) [
                file-field/text: form to-local-file filename
            ]
        ]
        return 
        text "" 120x24
        button "OK" 100x24 [
            return-val 
        ]
        button "CANCEL" 100x24 [
            return-val/cancel
        ]
        do [
            file-field/text: form to-local-file current-file
        ]
    ] 
    view rre
    return ret-val
]
