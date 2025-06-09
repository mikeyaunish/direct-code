Red [
	Title: "table-for-data-file-scenario.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
table-for-data-file-scenario-layout: [
	style table-for-data-file: panel "panel1" 128.128.128
		extra [
			setup-style: [
				[
					input [	;-- input-values/1
						prompt "Size"
						type "pair"
						detail {The size of the table. Use the pair format HHxWW . IE: 100x50 }
					]
				] [
					input [ ;-- input-values/2
						prompt "Data File"
						type "file"
						detail {The filename of the data you want to display in the table.}
					]
				]
				[
					input [  ;-- input-values/3
						prompt "Auto Column Headers"
						type "check"
						detail {Check the box to enable 'Automatic Column Headers' for the table.}
					]
				] [
					input [  ;-- input-values/4
						prompt "Auto Row Headers"
						type "check"
						detail {Check the box to enable 'Automatic Row Headers' for the table.}
					]
				][
					input [  ;-- input-values/5
						prompt "Auto Save"
						type "check"
						detail {Check the box to enable automatic data saving for the table. Only works with file data not block data. }
					]
				][
					action [
						opts: copy []
						if input-values/3 [ append opts compose [ auto-col: true ]]
						if input-values/4 [ append opts compose [ auto-row: true ]]
						if input-values/5 [ append opts compose [ auto-save: true ]]
						unique-obj-name: find-unused-object-name "table"
						options-block: either opts <> [] [
							compose/deep [ options [ (opts) ] ]
						][
							[]
						]
						alter-facet/value 'layout-block
						compose/deep [
							(to-set-word unique-obj-name ) table (to-pair input-values/1)
								(options-block)
								data (to-file input-values/2)
						]
						
					]
				]
			]
		]
	table-for-data-file1: table-for-data-file [
		table1: table 400x100 data []
	]
			
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view table-for-data-file-scenario-layout
]
