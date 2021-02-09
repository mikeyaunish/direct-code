Red [
	Title: "direct-code-help.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
    help-data: [
        
    "Direct Manipulation of Objects" 
    ;----------------------------------------------------------------


{The ultimate aim of 'Direct Code' is to provide a robust code manipulation
environment that allows code modifications to take place through any of the
following techniques:

1.) Changes in the source code
2.) Direct manipulation of the visual object
3.) Modification of object values (through the VID Object Editor)

All three techniques are linked so that changes in one area are 
interactively reflected in the others.

To activate the 'VID Object Editor' just select a named object (it must be
named) as detailed below.

SELECTING AN OBJECT TO ACTIVATE THE 'VID OBJECT EDITOR'
-------------------------------------------------------
In order to select a named object you can do one of following:
1.) Middle mouse button click on the object
2.) Move the mouse over the object and press Control and '~' key 
    (that is: Control and Tilde key) 
    
These unusual key combinations were specifically chosen so that they 
would not interfere with your programs' normal operations.    

USING THE VID OBJECT EDITOR
---------------------------

The editor is simply a way to change the attributes of a VID object and have
those changes take place interactively in your code. All fields that are NOT
grayed out can be modified. To learn how to use the Vid Object Editor select 
the menu item: 'Help/Quick Start Guide'

Values that require pairs like the size and offset of an object have a unique
modifier tool. It is an icon picturing four arrows. To have it modify the pair
value just click down on the icon and drag the mouse. You can also move the
object a pixel at a time by clicking on the arrows.

If you click on the object name the object will be highlighted in the code
editor (you may have to scroll to see the object if it is off screen)


} 
    "How is code modified?"

{Code modification are triggered when the actual Red object is changed. What
this does is de-couple the GUI that changes the object from the functions that
rewrite the Red source code. As long as the specific field in an object is being
tracked (which is happening whenever the VID Object Editor is open) then those
changes made to the object will be reflected in the source code. What this means
is that anyone can make a custom GUI to modify the VID objects and the source
code will be generated for you automatically. (more on how to use this in the
future.)

Right now, only a few fields of any Red object can generate changes to the
source code. In the future this will expand. }

    "Limitations on modifying code"
    ;-----------------------------------------------------------------
{If you make changes to complex text strings via the 'Vid Obect Editor' or 
directly in the object itself (in fields and areas) you may bump up against
a problem with Direct Code not being able to handle the text that you are
trying to input. If this happens it is best to make the changes in the 
'Setup Code' or "Layout Code" source files directly.
}
    "Running The Interpreter" 
    ;-----------------------------------------------------------------
{You can run the Red interpreter in one of 4 ways:
    
1.) Via the 'Live Update' check box (in the top left corner)
    The interpreter is run continuously so you can always see the 
    results of your efforts. 
2.) Pressing the Right Control Key (If 'Live Update' isn't checked)
3.) Pressing the F5 Key
4.) Clicking on the file name displayed (to the right of 'File:')

These unusual key combinations were specifically chosen so that they 
would not interfere with your programs' normal operations.
}
    
    "Run in separate window" 
    ;------------------------------------------------------------------
{You can launch your Red program in a separate window by selecting 
the following Menu Item: 'File/Run Separately' or use the F9 key

All Red programs created with Direct Code are stand alone Red programs. If you
use some of the special functions built into Direct Code you may need to include
them in your program for stand alone use. (See 'Stand Alone Program' in the help
topics) Future version will have a way to handle '#include' files elegantly.


    }
    
    "External Text Editor" 
    ;-----------------------------------------------------------------

{You can configure an external text editor via the Menu Item: 'Settings/External
Editor'

The external editor can then be used as the primary code editor. Once you open
your red program with an external editor (through the menu item: 'File/Open with
External Editor') and save the file it will automatically be reloaded into the
Direct Code environment.

You can also manually activate Auto Reload of the file through the Menu Item:
'File/Reload/Reload When Changed ON' or by clicking on the 'File:' label.

When the source file is being actively monitored the color of the 'File:' label
will turn green.

Then whenever you save the file with your external text editor it will be
automatically reloaded and run through the Red interpreter.

When you are using an external editor it is important to remember to save
the file whenever you make changes before interacting with your program 
in the Direct Code environment because your file will be over written 
as soon as any changes are made. 

When modifying your code with an external editor the 'Live Update'
check box isn't necessary
    }
    
    "Assistance with face creation" 
    ;-----------------------------------------------------------------

{Through the Menu Item: 'Insert' you can add faces to your program.
This feature is very rudimentary right now. User customization of this
feature will be implemented in the future.}

    "Object Browser" 

{A Red system object browser is available via the 
Menu Item: 'Object/Object Browser'.

This uses Gregg Irwin's Object Browser - Thanks Gregg}  

    "Debugging Features" 
    ;-----------------------------------------------------------------
{The following debugging facilities are available:

RED COMMAND LINE
----------------
    There is a Red command line (identified by the 'RED>>' button) 
    that allows you to type in any Red command. Depending on 
    their context some values may not be visible by the 
    Red commands that you run here. To re-run a command you
    have already entered just click on the 'RED>>' button.

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
       Menu Item: 'Debug/View Log File'.
       This logging feature can be turned on and off through the
       Menu Item: 'Debug/Logging/Logging OFF' or 'Debug/Logging/Logging ON'
       
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
    Which can be used to move from one Red program to another, similar
    to moving from one web page to another. Very useful for creating 
    multi-page documentation. In this case it would be a 
    multi-program document. With this one command you can create 
    your own 'Hyper Card' type program.
}    
    ]
    help-topic-data: collect [ foreach [ x y ] help-data [ keep x ] ]
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view direct-code-help-layout: [
title "Direct Code Help"
h3 "Help Topics" 200x40
base 1x40 
h3 "Topic Details" center return 
top
topic-list: text-list font-size 11 200x200 data :help-topic-data "Direct Manipulation of Objects"
    on-change[ 
        details-area/text: pick help-data (topic-list/selected * 2 )
    ] 

details-area: area "" font-size 12 font-name "Fixedsys" 660x400  
return 
do [
	topic-list/selected: 1
    details-area/text: pick help-data 2
]
]
