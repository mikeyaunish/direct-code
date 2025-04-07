Red [
	Title: "convert-to-style.red"
	Comment: "Imported from: <root-path>%experiments/convert-to-style/convert-to-style.red"
]
set 'tail-position-of-styles function [
    source-code [string!]
] [
    style-list: get-styles to-block source-code
    if style-list = [] [
        return 0x0
    ]
    last-style: copy/part back back tail style-list 1
    obj-src: get-object-source/position/whitespace/with-newline (to-string last-style) source-code
    return third obj-src
]
set 'convert-to-style function [
    obj-name [string!] "Object name you want to apply the conversion to"
    source-code-widget [object!] "Name of the area containing the source code"
] [
    src-dets: get-object-source/position obj-name source-code-widget/text
    orig-obj: src-dets/1
    src-pos: src-dets/2
    offset-detail: none
    either none? target-obj: get-vid-object-name/next vid-code/text obj-name [
        end-of-script: true
        after: true
    ] [
        end-of-script: false
        after: false
    ]
    if (copy/part orig-obj 2) = "at" [
        offset-detail: split orig-obj " "
        replace orig-obj rejoin [offset-detail/1 " " offset-detail/2 " "] ""
        target-obj-offset: to-pair pick offset-detail 2
    ]
    obj-type: first parse (to-block orig-obj) [collect [any set-word! keep word! | skip]]
    style-name: request-text "Enter the name of the style you want to create."
    if not style-name [
        return ""
    ]
    style-name: validate-word style-name
    if not style-name [return ""]
    style-source: copy orig-obj
    replace style-source (rejoin [obj-name ":"]) rejoin ["style " style-name ":"]
    insert-style-code style-name style-source
    delete-vid-object obj-name
    either target-obj-offset [
        insert-vid-object/style/named/with-offset obj-type target-obj style-name obj-name target-obj-offset
    ] [
        insert-vid-object/style/named/:end-of-script/:after obj-type target-obj style-name obj-name
    ]
    close-object-editor obj-name
]
