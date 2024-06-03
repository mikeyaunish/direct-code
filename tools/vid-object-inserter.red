Red [
	Title: "test.red"
	Needs: View
	Comment: "Generated with Direct Code"
]

do setup: [

]

;Direct Code VID Code source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
vid-object-inserter-layout: [
title "VID Object Inserter"
heading: text font-size 12 "Click on a VID Object to insert it^/" bold underline
return 
space 6x6
text2: text "text" 229.231.236.0 center font-size 14 on-up [ insert-vid-object "text"]
base1: base "base" 80x25 font-size 12 font-color 255.255.255 on-up [ insert-vid-object "base"]
box1: box "box" 80x25 font-size 14 on-up [ insert-vid-object "box"]

return
rich-text1: image 80x25 %rich-text.png on-up [ insert-vid-object "rich-text"]
button1: button "button" 80x24 font-size 12 on-up [ insert-vid-object "button"]
check1: image %check.png on-up [ insert-vid-object "check"]

return
radio1: image %radio.png on-up [ insert-vid-object "radio"]
field1: image %field.png on-up [ insert-vid-object "field"]
area1: image %area.png on-up [ insert-vid-object "area"]

return 
text-list1: image %text-list.png on-up [ insert-vid-object "text-list"]
drop-list1: image %drop-list.png on-up [ insert-vid-object "drop-list"]
drop-down1: image %drop-down.png on-up [ insert-vid-object "drop-down"]

return
toggle1: toggle "toggle" 75x24 [insert-vid-object "toggle"]
image3: image "progress" %progress.png font-size 12 on-up [ insert-vid-object "progress"]
image4: image "   slider" %slider.png left font-size 12 on-up [ insert-vid-object "slider"]

return
drop-list2: drop-down hint "Headings" on-select [
    if face/text <> "Headings"[
        insert-vid-object face/text
    ]
] 80x24 data ["Headings" "H1" "H2" "H3" "H4" "H5"] select 1
image1: image "^/^/image" 80x80 %image.gif bold font-size 14 font-color 255.255.255.0 on-up [ insert-vid-object "image"]
image2: image "^/^/calendar" 80x80 %calendar.png center bold font-size 14 font-color 255.57.4.0 on-up [insert-vid-object "calendar"] on-up [ insert-vid-object "calendar"]
return
base2: base {^/^/^/camera} 80x80 255.255.255 %camera.gif font-size 12 font-color 3.0.5.0 on-up [ insert-vid-object "camera"]
base3: base 80x80 229.231.236.0 %panel.png font-size 12 on-up [ insert-vid-object "panel"]
group-box1: group-box "group-box" 80x80 on-up [ insert-vid-object "group-box"]
return 
tab-panel1: tab-panel "tab-panel1" 100x80 [ "a" [text "tab-panel" ] "b" []] on-up [insert-vid-object "tab-panel"]
]

;Direct Code Show Window source marker - DO NOT MODIFY THIS LINE OR THE NEXT LINE!
do show-window: [
	view/options vid-object-inserter-layout [ offset: 429x163 ]
]
