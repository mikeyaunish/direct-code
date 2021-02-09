Red [ Title: "closure.red"]
closure: func [
    vars [block!] "Values to close over, in spec block format"
    spec [block!] "Function spec for closure func"
    body [block!] "Body of closure func; vars will be available"
][
    func spec compose [(bind body context vars)]
]