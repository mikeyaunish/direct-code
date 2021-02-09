Red [ Title: "safe-object-copy.red"]
safe-object-copy: func [ obj ] [
	res-blk: copy []
	foreach [ var val ] ( body-of obj ) [
		if not any [
			(type? :val) = object! 
			(type? :val) = function! 
		][
			append res-blk reduce [ to-set-word :var :val ] 
		]
	]
	return object res-blk
]
