Red [
    Needs: View
    Title: "request-message"
    tabs: 4
]

request-message: func [ 
    message [ string! ] {Message to display}
    /size area-size {The size of the text area}
][ 
    ret-val: copy ""
    if not size [ area-size: 400x200 ]
    rre: layout compose [
        title "User Message..."
        area (area-size) message font-size 12
        return 
        button "OK" 100x24 [
            ret-val: true
            unview/only rre 
        ]
        button "CANCEL" 100x24 [
            ret-val: false
            unview/only rre
        ]
    ] 
    view rre
    return ret-val
]