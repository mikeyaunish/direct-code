Red [
	Title: "help-doc-v1.red"
	Needs: View
	Comment: "Generated with Direct Code"
]


do setup:[
    help-data: [
        
    "Direct Manipulation of Objects" 
    ;----------------------------------------------------------------
{The ultimate aim of 'Direct Code' is to provide a programming 
environment that allows direct manipulation of the visual objects,
that results in modifications to the source code. So that you can
develop your program using both source code and visual manipulations. 

The first 'Direct Manipulation' action available is: 'move-object'. 
What this means is that if you have a face that is named 
(it must be named) you can move it around and the source code will be 
modified to reflect the changes that you have made to the object.

SELECTING AN OBJECT
-------------------
In order to select a named object you can do one of these two things:
1.) Middle mouse button click on the object
2.) Move the mouse over the object and press Control and ~ key 
    (that is Control and tilde key) 

These unusual key combinations were specifically chosen so that they 
would not interfere with your programs' normal operations.    

MOVING A SELECTED OBJECT
------------------------
You can move an object with the mouse once you see the cross hairs show 
up over top of the selected object. Once you have released the mouse
button the cross hairs will disappear and the source code will be 
updated.
}
    
    "Running The Interpreter" 
    ;-----------------------------------------------------------------
{You can run the Red interpreter in one of 4 ways:
    
1.) Via the 'Live Update' check box (in the top left corner)
2.) Pressing the Right Control Key (If the 'Live Update' isn't checked)
3.) Pressing the F5 Key
4.) Clicking on the file name displayed (to the right of 'File:')

These unusual key combinations were specifically chosen so that they 
would not interfere with your programs normal operations.
}
    
    "Run in separate window" 
    ;------------------------------------------------------------------
{You can launch your Red program in a separate window by selecting 
the following Menu Item: 'File/Run Separately' or use the F9 key

All Red programs created with Direct Code are stand alone Red
programs. If you use some of the special functions built into 
Direct Code you may need to include them in your program for stand
alone use. (See 'Stand Alone Program' in the help topics)
Future version will have a way to handle '#include' files
elegantly.
    }
    
    "External Text Editor" 
    ;-----------------------------------------------------------------
{You can configure an external text editor via the Menu Item:
'Settings/External Editor'

The external editor can be used as the primary code editor
by activating Auto Reload of the file through the 
Menu Item: 'File/Reload/Reload When Changed ON' or by clicking 
on the 'File:' label.

When the source file is being actively monitored the 
color of the 'File:' label will turn green.

Then whenever you save the file with your external text
editor it will be automatically reloaded and run through
the Red interpreter.   

When modifying your code with an external editor the 'Live Update'
check box isn't necessary
    }
    
    "Assistance with face creation" 
    ;-----------------------------------------------------------------
{Through the Menu Item: 'Insert' you can add faces to your program. 
Right now this feature is quite rudimentary but will easily be improved 
upon once an object editor has been created.} 

    "Object Browser" 
{A Red system object browser is available via the Menu Item: 
'Tools/Object Browser' or by clicking on the 'Object:' label.

This uses Gregg Irwin's Object Browser - Thanks Gregg}  

    "Debugging Features" 
    ;-----------------------------------------------------------------
{The following debugging facilities are available:

RED SYSTEM/VIEW/DEBUG? FLAG
---------------------------
    Turn the internal Red system/view/debug? flag ON & OFF via 
    the Menu Item: 'Debug/System/...'
    This will print various pieces of information about Red as 
    your program runs.
    
SHOW NAMED OBJECTS
------------------    
    Through the Menu Item: 'Debug/Objects/Show Named Objects'
    you can see the entire list of objects that are properly
    named and eligible for manipulation.
    
DETAILS ABOUT THE NAMED OBJECT
------------------------------    
    Once you have selected a named object 
    (see 'Direct Manipulation of Objects' in the help topics)    
    you are able to see details about that object by clicking on 
    the object name that shows up to the right of the 'Object:' label.

HELPFUL PRINT FUNCTIONS
-----------------------    
    Two debugging print functions are supplied by the Direct Code 
    environment. (To use these in your stand alone Red program
    see the help topic 'Stand Alone Program' )
    
    1) 'lprint' which prints data to a log file called: 
       'direct-code.log'. This log file will be saved in the folder 
       that the program was run from. The log file is cleared 
       every time the Red script is restarted.
       You can view the log file by selecting the 
       Menu Item: 'Debug/View Log File'
       
    2) 'bprint' which prints data to the screen as well as to 
        the log file.

RESTART DIRECT CODE
-------------------
    You can restart the 'Direct Code' program by selecting 
    the Menu Item: 'File/Restart Direct Code'.
    This is useful if you run into a error that hangs the
    entire Direct Code environment.
}

    "Stand Alone Program"
    ;------------------------------------------------------------------
{The following functions are available within the 'Direct Code' 
environment. To include them within your runnable Red program 
use the Menu Item: 'Insert/Includes/direct-code-stand-alone'

1.) Two special 'print' functions are available:
    a) 'lprint' which prints data to a log file called: 'direct-code.log'
       This log file will be saved in the folder that the program was 
       run from.
    b) 'bprint' which prints data to the screen as well as the log.    

2.) The 'load-and-run' function 
    Which can be used to move from one Red program to another, like
    web pages. Very useful for creating multi-page documentation.
    In this case it would be a multi-program document. 
    This use case needs to be developed further.
}    
    ]
    help-topic-data: collect [ foreach [ x y ] help-data [ keep x ] ]
]


view/no-wait [
    title "Direct Code Help"
    h3 "Help Topics" 200x40
    base 1x40 
    h3 "Topic Details" center return 
    top
    topic-list: text-list font-size 11 200x200 data :help-topic-data "Direct Manipulation of Objects"
        on-change[ 
            details-area/text: pick help-data (topic-list/selected * 2 )
        ] 
    
	details-area: area font-size 12 font-name "Fixedsys" 600x400  
	return 
	do [
		topic-list/selected: 1
        details-area/text: pick help-data 2
	]
     
     
]
