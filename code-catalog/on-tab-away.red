Red []
on-tab-away: func [
    face [object!]
    event [event!]
][
	if all [
		(event/key = #"^-") ((event/type = 'key-down))
	][
		if find face/extra 'on-tab-away [
			do bind face/extra/on-tab-away 'face
		]
	]
	return none
]

insert-event-func 'on-tab-away :on-tab-away	
