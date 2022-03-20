Red [
	Title: "direct-code-help.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup:[
    help-data: [
        
    "Direct Manipulation of Objects" 
    ;----------------------------------------------------------------
{The ultimate aim of 'Direct Code' is to provide a robust 
"Live Code" manipulation environment that allows code modifications 
to take place through either of the following techniques:

1.) Regular hand written changes to the source code
2.) Modification of VID object values (through the VID Object Editor)

Both techniques will work at the same time. Currently the VID Object Editor
has some limitations concerning variable names, named colors and how it
handles styles. Any of these limitation can be overcome by changing the 
Red code manually.

To activate the 'VID Object Editor' see the next topic:
"Using the VID Object Editor"
}    

"Using the VID Object Editor"
;---------------------------
{To activate the 'VID Object Editor' just select a named object (it must be
named) as detailed below.

The editor is simply a way to change the attributes of a VID object and have
those changes take place instantly and interactively in both the source code
and in the GUI layout.

The VID Object Editor can be activated from both the running GUI program and
from the VID source code as follows:

1.) From the GUI program
    1.1) Opening the normal VID Object Editor
        a) Press the middle mouse button on the GUI object in question
        b) Press the Control + '~' key when your mouse is over the GUI object 
           in question
        
    1.2) Open the VID Object Editor at the left edge of the window
        a) Hold down the left control key then press the middle mouse button 
           on the GUI object in question
        b) Press the Control + '1' key when your mouse is over the GUI 
           object in question

2.) From the VID code editor (bottom left side panel)          
    2.1) Opening the normal VID Object Editor
        a) Select at least one character of source code within the object in 
           question, then press the middle mouse button
        b) Select at least on character of source code within the object in 
           question, then press the Control + '~' 
           
    2.2) Opening the normal VID Object Editor at the left edge of the window
        a) Select at least one character of source code within the object in 
           question, then hold down the left Control key and press the 
           middle mouse  button
        b) Select at least on character of source code within the object in 
           question then press the Control + '1' 

Values that require pairs like the size and offset or a single integer value 
like the font size have a unique modifier tool which are the arrows that 
display right after the data entry field. Clicking on the arrows will change 
the value by one value (or pixel). Using the mouse scroll wheel will change 
the value by larger amounts and by clicking and dragging you can change the 
values freehand depending on where the mouse is.

There are also two fields that have unusual data entry options. That is the 
'Text' and 'Offset' fields. To the right of the field you will see an arrow 
pointing towards an empty box, this is to represent an "Import" action. 
If you change the 'Text' that a 'field' or 'area' contains by modifying 
it in the running GUI program itself,you can then press the import button 
and the source code will be updated to reflect that new value.

You can do the same with the 'offset' field. Make any object 'loose'
and drag it to where you want it, then press the import button to write it's 
new location to the source code.
} 
    "How is code modified?"

{Code modification has been completely re-written since the last version of
Direct Code. (Thanks to transcode). Once the 'modify-source' function has 
some miles and testing under it's belt, I would imagine that it could be 
easily reused by others. 

Any changes made through the VID Object Editor are designed to leave any of 
your hand written code untouched. 

Every field of any Red object can be modified through the VID Object Editor.}

    "Limitations of the VID Object Editor"
    ;-----------------------------------------------------------------
{-Complex string creation is no longer an issue in this version of Direct Code.

-Prettify-source will need to be added. "Prettifying" code is left to the user
 to do manually.

- A more robust multi-line code editor is needed. It's next on my list.

- The VID Editor doesn't currently handle variables used within the VID code.
  A system for dealing with this (like a link symbol) needs to be investigated.
  For the time being these situations can be handled through normal code 
  editing.

- Named colors are similar to variable and aren't handled satisfactorily 
  within the VID Editor.

- Static react blocks won't work within Direct Code - they only activate once 
  the program has been run separately (F9) from Direct Code. This is an 
  outstanding issue with Red and will work properly once this issue is fixed.
  
- To see your React blocks work properly in real time within Direct Code you 
  can add your React block to the 'on-create' block of the object in question. 

- Integration of other external text editors is possible, but right now only 
  5 text editors for the Window environment come preconfigured. 
  They are: UltraEdit, Visual Studio Code, Notepad, Notepad++ and RedEditor. 
  Others can be easily added via the %external-editor-settings.data file in 
  the support scripts folder. Right now only UltraEdit, NotePad++ and RedEditor
  are the only editors that properly locate source code via Direct Code.
}
    "Running The Interpreter" 
    ;-----------------------------------------------------------------
{You can run the Red interpreter in one of 4 ways:
    
1.) Via the 'Live Update' check box (in the top left corner)
    The interpreter is run continuously so you can always see the 
    results of your efforts. 
2.) Pressing the Right Control Key (If 'Live Update' isn't checked)
3.) Pressing the Control + "S" key
4.) Clicking on the file name displayed (to the right of 'File:')

These unusual key combinations were specifically chosen so that they 
would not interfere with your programs' normal operations.
}
    
    "Run Separately" 
    ;------------------------------------------------------------------
{You can launch your Red program in a separate window by selecting 
the following Menu Item: 'File/Run Separately' or use the F9 key.
The program is actually run through the command line so that there aren't
any residual dependencies from the Direct Code program interfering with your
program.

All Red programs created with Direct Code are stand alone Red programs. If you
use some of the special functions built into Direct Code you may need to include
them in your program for stand alone use. (See 'Stand Alone Program' in the help
topics) Future version will have a way to handle '#include' files better.
}

    "Do File Attached"
    ;-----------------
{This is an intriguing development that opens up a whole new world of program 
development via Direct Code. When you run your program like this, (as the 
"Run User Script" program is) you then have full access to all of the inner 
workings of Direct Code and of your own program as well. 

More documentation concerning this will come in the future. But it is enough to 
say that you can query and change almost any part of a running program via
another program that is run in this way.
}
    
    "External Text Editor" 
    ;-----------------------------------------------------------------

{You can configure an external text editor via the Menu Item: 'Settings/External
Editor'. To get your editor working properly edit the file 
%/support-script/external-editor-settings.data

The external editor can then be used as the primary code editor. Once you open
your red program with an external editor (through the menu item: 'File/Open with
External Editor') and save the file it will automatically be reloaded into the
Direct Code environment.

You can also manually activate Auto Reload of the file through the Menu Item:
'File/Reload/Reload When Changed ON' or by clicking on the 'File:' label.

When the source file is being actively monitored for changes the color of the 
'File:' label will turn green. This is only supported on Windows right now.

Whenever you save the file with your external text editor it will be
automatically reloaded and run through the Red interpreter.

When you are using an external editor it is important to remember to save
the file whenever you make changes before interacting with your program 
in the Direct Code environment because your file will be over written 
as soon as any changes are made in the Direct Code environment.

When modifying your code with an external editor the 'Live Update'
check box isn't necessary
}
    
    "Assistance with object creation" 
    ;-----------------------------------------------------------------

{By using the 'Insert' Menu Item you can add objects to your program.
There are two menu options:

1.) VID Object Inserter GUI
2.) Select the individual object from the 'Insert' menu
}

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
    There is a handy "Mk Btn" button just to the right of the
    command line field. It will "Make a Button" out of the 
    code that you have entered into the Red Command field. 
    This is handy for testing, discoverying and experimenting with 
    code that you need to understand.

RED CODE SNIPPET TESTING AREA
-----------------------------
    The 'Red Code Snippet Testing Area' can be opened by selecting
    the Menu: 'User/Run User Script' item. I have found that this is
    the most efficient way for me to test and explore smaller segments 
    of code without making changes to the program that I am building. 
    Because the 'User Script' is run as "Attached", you can monitor, 
    change and play with almost every part of the currently running 
    program.

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
       Or by pressing the F8 button.
       
    2) 'bprint' prints data to the screen as well as to 
        the log file.

RESTART DIRECT CODE
-------------------
    You can restart the 'Direct Code' program by selecting 
    the Menu Item: 'File/Restart Direct Code' (or F12).
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
"User Scripts"
{There is now an added 'User Script' Menu added to the main program.
You can either run or edit your 'User Script' here. There are a few tools
built into the published 'User Script'. But you are free to change it 
in any way to meet your needs. 
Check out the 'Red Code Snippet Testing Area' under the "Debuggin Features"
Help Topic. Using this simple tool has improved my coding efficiency many fold.

This User Script Menu  will be expanded 
in the future to handle more user customizable programs.
}   
    ]
    help-topic-data: collect [ foreach [ x y ] help-data [ keep x ] ]
]
;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
view direct-code-help-layout: [
title "Direct Code Help"
h3 "Help Topics" 225x40
base 1x40 
h3 "Topic Details" center return 
top
topic-list: text-list font-size 11 230x300 data [
    "Direct Manipulation of Objects" 
    "Using the VID Object Editor" 
    "How is code modified?" 
    "Limitations of the VID Object Editor" 
    "Running The Interpreter" 
    "Run Separately" 
    "Do File Attached" 
    "External Text Editor" 
    "Assistance with object creation" 
    "Object Browser" 
    "Debugging Features" 
    "Stand Alone Program" 
    "User Scripts"
] "Direct Manipulation of Objects"
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
