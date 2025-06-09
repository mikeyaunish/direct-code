Red [
	Title: "table-plain-style.red"
	Needs: View
	Comment: "Generated with Direct Code"
	Generator: "add-to-style-catalog"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
table-plain-style-layout: [
	style table-plain: table data [] 
		extra [
			setup-style: [
				[
					input [		;-- input-values/1
						prompt "Size"
						type "pair"
						detail {The size of the table. Use the pair format HHxWW . IE: 100x50 }
					]
					action [alter-facet/value 'size to-pair input-value]
				] [
					input [		;-- input-values/2
						prompt "Data File"
						type "file"
						detail {The filename of the data you want to display in the table.}
					]
					action [alter-facet/value 'data to-valid-file input-value]
				]
				[
					input [		;-- input-values/3
						prompt "Auto Column Headers"
						type "check"
						detail {Check the box to enable 'Automatic Column Headers' for the table.}
					]
				][
					input [		;-- input-values/4
						prompt "Auto Row Headers"
						type "check"
						detail {Check the box to enable 'Automatic Row Headers' for the table.}
					]
				][
					input [  	;-- input-values/5
						prompt "Auto Save"
						type "check"
						detail {Check the box to enable automatic data saving for the table. Only works with file data not block data. }
					]					
					action [
						opts: copy []
						if input-values/3 [ append opts compose [ auto-col: true ]]
						if input-values/4 [ append opts compose [ auto-row: true ]]
						if input-values/5 [ append opts compose [ auto-save: true ]]
						unique-obj-name: find-unused-object-name "table"
						if opts <> [] [
							alter-facet/value 'options compose/deep (opts)
						]
					]
				]
			]
		]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view table-plain-style-layout
]