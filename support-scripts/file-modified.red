Red [ Title: "file-modified.red"]

file-modified?: closure [
	track-files: [] [block!]
][
	filename [file!]
][
    split-filename: split-path filename
    local-path: to-local-file split-filename/1
    local-file: to-local-file split-filename/2
    filename: replace/all (replace/all (form filename) "/" "~") " " "_"
	filename-word: to-word filename
	last-stamp: track-files/:filename-word
	call-cmd: rejoin [ {forfiles /P } local-path " /M " local-file { /c "cmd /c echo @file @ftime"} ]
	call-output: copy ""
	call/output call-cmd call-output
	file-stamp: delim-extract/first call-output {" } "^/" 	

	either last-stamp [
		either last-stamp <> file-stamp [
			track-files/:filename-word: file-stamp
			return true	
		][	
			return false
		]
	][
		insert track-files reduce [ to-set-word filename file-stamp ]
		return false
	]
]
