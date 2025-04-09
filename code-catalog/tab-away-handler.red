Red []

tab-away-handler: func [
    face [object!]
    event [event!]
][
	if all [
		(event/key = #"^-") ((event/type = 'key-down))
	][
		if all [
			find face/extra 'on-tab-away-do-enter 
			face/extra/on-tab-away-do-enter = 'true 
		][
			do-actor face none 'enter 
		]
		if find face/extra 'on-tab-away [
			do bind face/extra/on-tab-away 'face
		]			
	]
	return none
]
	
insert-event-func 'tab-away-handler :tab-away-handler	