Red [ 
    Title: "direct-code-includes.red"
]

all-files: read to-file get-current-dir
remove-each file all-files [  
	(file = %LICENSE) 				    or 
	(file = %direct-code-includes.red)  or 
	(file = %voe-layout-template.red)   or
	(file = %style-template.red) 	    
]
foreach file all-files [
	#include file
]

