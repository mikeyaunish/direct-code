Red [Author: @toomasv Date: 7-Feb-2022]

style: function [name template /default 'actor /init body][
	system/view/VID/styles/:name: sty: compose/only [template: (copy/deep template)]
	if default [append sty compose [default-actor: (to-get-word actor)]]
	if init [append sty compose/only [init: (copy/deep body)]]
]
