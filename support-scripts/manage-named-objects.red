Red [
	Title: "manage-named-objects.red"
	Comment: "Imported from: <root-path>%experiments/manage-named-objects/manage-named-objects.red"
]
set 'generate-named-object-pane function [
    object-list [block!]
] [
    resulting-pane: copy [
        space 2x2
        across
        text " Object Name" 180x24 210.200.210 center middle left bold
        return
    ]
    foreach obj object-list [
        obj-status: either (obj = "*unusable-no-name*") [
            'disabled
        ] [
            []
        ]
        append resulting-pane compose/deep [
            text (obj) right 180x24 210.210.210 center middle
            button "Edit Object" (obj-status) on-click [edit-vid-object (obj) "vid-code"]
            button "View Source / Set as Insertion Point" (obj-status) on-click [voe-menu-handler (obj) "highlight-source-object"]
            button "Highlight GUI Object" on-click [voe-menu-handler (obj) "highlight-gui-object"]
            button "Move to Insertion Point" on-click [voe-menu-handler (obj) "move-object"]
            button "Duplicate Object" (obj-status) on-click [voe-menu-handler (obj) "duplicate-object"]
            button "Delete Object" (obj-status) on-click [voe-menu-handler (obj) "delete-object"]
            return
        ]
    ]
]
set 'show-named-objects-gui function [
    obj-list [block!]
] [
    named-obj-pane: generate-named-object-pane obj-list
    at-window-bottom-offset: to-pair reduce [5 min 585 (--dc-mainwin-edge/y + 50)]
    view-vertical-layout/title/size/offset named-obj-pane "Object Manager" 970x400 at-window-bottom-offset
]
