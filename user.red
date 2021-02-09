Red [ Title: "user.red" ]

pe: func [ 'blk /deep /local x i] [
    x: 0
    print rejoin [ "0.) '" to-word blk "' ="]
    blk: get blk 
    foreach i blk [ 
        x: x + 1  
        either all [ ( (type? i) = block! ) deep  ][
            y: 1 
            print rejoin [ x ". )-----------" ]
            foreach j i [
                print rejoin [ " " x "." y ") " mold j]
                y: y + 1 
            ]
        ][
            print rejoin [ x ".) "  mold i ]
        ]
    ]
]
ua: does [ unview/all ]
dc: does [ do read-clipboard ]
closure: func [
    vars [block!] "Values to close over, in spec block format"
    spec [block!] "Function spec for closure func"
    body [block!] "Body of closure func; vars will be available"
][
    func spec compose [(bind body context vars)]
]
#include %support-scripts/delim-extract.red ;bprint
