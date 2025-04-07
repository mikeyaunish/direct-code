Red [
	Title: "popup-help.red"
	Comment: "Imported from: <root-path>%experiments/popup-help/popup-help.red"
]
set 'popup-help func [
    {Displays a popup help message. By default message will show in one line. V2}
    message [string!] "Message to display"
    /offset the-offset
    /close
    /size message-size "Width or pair of message size"
    /box {Display message in a box. Good for longer messages}
] [
    if close [
        unview/only --popup-help-window--
        exit
    ]
    message-object: 'text
    if not size [
        message-size: either box [
            num-of-chars: length? message
            chars-per-line: 44
            num-of-lines: (round/ceiling num-of-chars / chars-per-line) + ((length? split message "^/") - 1)
            total-lines-needed: num-of-lines + 1
            height: round/ceiling total-lines-needed * 21.15
            to-pair reduce [400 height]
        ] [
            []
        ]
    ]
    either offset [
        view-options: compose [offset: (the-offset)]
    ] [
        view-options: copy []
    ]
    if box [
        message-object: 'area
    ]
    view/flags/options --popup-help-window--: layout/tight compose [
        backdrop 232.232.100
        (message-object) (message-size) message font-size 12 wrap
        return
    ] [
        popup no-title
    ]
    view-options
]
