Red [
	Title: "modify-facet.red"
	Comment: "Imported from: <root-path>%experiments/modify-facet/modify-facet.red"
]
modify-facet-ctx: context [
    facet-modify-map: [
        name [[set-word!] new-value]
        text [[string!] new-value]
        offset [[word! "at"] new-value]
        size [[pair!] new-value]
        color [[tuple!] new-value]
        loose [[word! "loose"] 'loose]
        hidden [[word! "hidden"] 'hidden]
        disabled [[word! "disabled"] 'disabled]
        focus [[word! "focus"] 'focus]
        all-over [[word! "all-over"] 'all-over]
        password [[word! "password"] 'password]
        tri-state [[word! "tri-state"] 'tri-state]
        left [[word! "left"] 'left]
        center [[word! "center"] 'center]
        right [[word! "right"] 'right]
        top [[word! "top"] 'top]
        middle [[word! "middle"] 'middle]
        bottom [[word! "bottom"] 'bottom]
        wrap [[word! "wrap"] 'wrap]
        no-wrap [[word! "no-wrap"] 'no-wrap]
        no-border [[word! "no-border"] 'no-border]
        hint [[word! "hint"] new-value]
        font-name [[word! "font-name"] new-value]
        font-size [[word! "font-size"] new-value]
        font-color [[word! "font-color"] new-value]
        bold [[word! "bold"] 'bold]
        italic [[word! "italic"] 'italic]
        underline [[word! "underline"] 'underline]
        strike [[word! "strike"] 'strike]
        anti-alias [[word! "font"] [anti-alias?: true]]
        cleartype [[word! "font"] [anti-alias?: 'Cleartype]]
        file [[file!] new-value]
        draw [[word! "draw"] new-value]
        layout-block [[block!] new-value]
        options [[word! "options"] new-value]
        data [[word! "data"] new-value]
        select [[word! "select"] new-value]
        true [[word! "true"] 'true]
        date [[date!] new-value]
        percent [[percent!] new-value]
        default-string [[word! "default"] new-value]
        extra [[word! "extra"] new-value]
        with [[word! "with"] new-value]
        rate [[word! "rate"] new-value]
        url [[url!] new-value]
        react [[word! "react"] new-value]
    ]
    set 'modify-facet function [
        "Modifies the source code provided."
        source-code [string!] "Full source of code you want to alter"
        object-name [string!] "Object name to alter"
        facet [word!] {lit-word name of the facet to alter. LIST OF FLAG FACETS: all-over anti-alias bold bottom center cleartype disabled focus hidden italic left loose middle no-border no-wrap password right strike top tri-state true underline wrap. WARNING: Some flags are mutually exclusive, you will need to deal with that. FACETS THAT NEED VALUES: color data options date default-string draw extra file font-color font-name font-size hint layout-block name offset on-<actor> percent rate react select size text url with}
        /value new-value [any-type!] {value of facets that aren't FLAGS. Ignored if using the /delete refinement.}
        /delete "Removes the facet indicated."
        /extern dc-actor-list facet-modify-map
    ] [
        if value [
        ]
        either not translate: select facet-modify-map facet [
            facet-string: to-string facet
            arg1: either (copy/part facet-string 3) = "on-" [
                either find dc-actor-list facet-string [
                    to-block reduce [word! facet-string]
                ] [
                    return none
                ]
            ] [
                (reduce bind translate/1 'new-value)
            ]
            arg2: copy new-value
        ] [
            arg1: (reduce bind translate/1 'new-value)
            arg2: either block? translate/2 [
                translate/2
            ] [
                reduce bind translate/2 'new-value
            ]
        ]
        if facet = 'name [arg2: to-valid-set-word arg2]
        modify-source/:delete source-code object-name arg1 arg2
    ]
]
