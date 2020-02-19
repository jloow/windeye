; ======================================================================
;  GENERAL
; ======================================================================

; Select and cycle windows
!z::        selectAndCycle()
!+z::       selectPrevious()

; Desktop switching
!n::        goToNextDesktop()
!b::        goToPrevDesktop()
!+n::       newDesktop()
!+q::       deleteDesktop()
!^n::       moveCurrentWindowToNextDesktop()
!^b::       moveCurrentWindowToPreviousDesktop()

; Close the active window
!q::        closeWindow()

; Alt Tab
<!v::       AltTab
<!c::       ShiftAltTab

; Mininise/maximise windows
!m::        toggleMax()
!+m::       toggleMin()

; Reload the script
!+r::       reloadScript()

; Exit script
#+x::       ExitApp

; Move focus
!h::        moveFocus("west", "right")
!j::        moveFocus("south", "top")
!k::        moveFocus("north", "bottom")
!l::        moveFocus("east", "left")

!left::     moveFocus("west", "right")
!down::     moveFocus("south", "top")
!up::       moveFocus("north", "bottom")
!right::    moveFocus("east", "left")

; Toggle modes
!space::    toggleEdgeMode()
!g::        toggleGlueMode()

; ======================================================================
;  NORMAL MODE
; ======================================================================
#If mode == "Normal"

; Move window
+!l::       moveWindow(80, 0)
+!h::       moveWindow(-80, 0)
+!k::       moveWindow(0, -80)
+!j::       moveWindow(0, 80)

+!right::   moveWindow(80, 0) 
+!left::    moveWindow(-80, 0) 
+!up::      moveWindow(0, -80) 
+!down::    moveWindow(0, 80)

; Grow window
^!l::      resizeWindow(0, 0, 0, 80)
^!h::      resizeWindow( 0, 0, 80, 0)
^!k::      resizeWindow(80, 0, 0, 0)
^!j::      resizeWindow(0, 80, 0, 0)

^!right::  resizeWindow(0, 0, 0, 80)
^!left::   resizeWindow(0, 0, 80, 0)
^!up::     resizeWindow(80, 0, 0, 0)
^!down::   resizeWindow(0, 80, 0, 0)

; Shrink window
^+!l::     resizeWindow(0, 0, -80, 0)
^+!h::     resizeWindow(0, 0, 0, -80)
^+!k::     resizeWindow(0, -80, 0, 0)
^+!j::     resizeWindow(-80, 0, 0, 0)

^+!right:: resizeWindow(0, 0, -80, 0)
^+!left::  resizeWindow(0, 0, 0, -80)
^+!up::    resizeWindow(0, -80, 0, 0)
^+!down::  resizeWindow(-80, 0, 0, 0)

; ======================================================================
;  EDGEMODE
; ======================================================================
#If mode == "Edge"

; Move
+!h::      moveToEdge("west", "left")
+!j::      moveToEdge("south", "bottom")
+!k::      moveToEdge("north", "top")
+!l::      moveToEdge("east", "right")

+!left::   moveToEdge("west", "left")
+!down::   moveToEdge("south", "bottom")
+!up::     moveToEdge("north", "top")
+!right::  moveToEdge("east", "right")

; Grow
^!h::      resizeToEdge("west", "left")
^!j::      resizeToEdge("south", "bottom")
^!k::      resizeToEdge("north", "top")
^!l::      resizeToEdge("east", "right")

^!left::   resizeToEdge("west", "left")
^!down::   resizeToEdge("south", "bottom")
^!up::     resizeToEdge("north", "top")
^!right::  resizeToEdge("east", "right")

; Shrink
+^!h::      resizeToEdge("west", "right", "shrink")
+^!j::      resizeToEdge("south", "top", "shrink")
+^!k::      resizeToEdge("north", "bottom", "shrink")
+^!l::      resizeToEdge("east", "left", "shrink")

+^!left::  resizeToEdge("west", "right", "shrink")
+^!down::   resizeToEdge("south", "top", "shrink")
+^!up::     resizeToEdge("north", "bottom", "shrink")
+^!right::  resizeToEdge("east", "left", "shrink")

; ======================================================================
;  GLUE MODE
; ======================================================================

#If mode == "Glue"

; Move windows
+!l::       moveGluedWindows(80, 0)
+!h::       moveGluedWindows(-80, 0)
+!k::       moveGluedWindows(0, -80)
+!j::       moveGluedWindows(0, 80)

+!right::   moveGluedWindows(80, 0) 
+!left::    moveGluedWindows(-80, 0) 
+!up::      moveGluedWindows(0, -80) 
+!down::    moveGluedWindows(0, 80)

