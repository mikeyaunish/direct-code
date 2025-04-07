Red [
	Title: "duplicate-object.red"
	Comment: "Imported from: <root-path>%experiments/duplicate-object/duplicate-object.red"
]
set 'duplicate-object func [
    {V2 for new insert-code arg pattern. insert-before is the default}
    obj-name [string!]
    src-position [pair!]
    last-char
    target-obj [string!]
    after [logic!] "flag to do insert-after. default is insert-before"
] [
    current-code: copy/part (skip vid-code/text src-position/x - 1) (src-position/y - src-position/x + 1)
    loaded-code: load current-code
    current-set-words: get-set-words to-block vid-code/text
    obj-renames: get-object-renames current-set-words current-code
    new-obj-name: rejoin [obj-renames/1/2 ":"]
    foreach renaming obj-renames [
        replace current-code (rejoin [renaming/1 ":"]) rejoin [renaming/2 ":"]
    ]
    if loaded-code/at [
        replace current-code (rejoin ["at " to-string loaded-code/at " "]) ""
    ]
    insert-code/:after current-code target-obj
    run-and-save "duplicate-object"
    new-obj-name: (trim/with/tail new-obj-name ":")
    re-run-setup-style/new-object new-obj-name "" ""
]
