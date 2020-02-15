; ======================================================================
;  GENERAL
; ======================================================================

; Select and cycle windows
!z::        selectAndCycle()
!+z::       selectPrevious()

; Desktop switching
!n::        goToNextDesktop()
!b::        goToPrevDesktop()

!+n::       Send, #^d ; Todo: Implement using the DLL
; !+q::deletevirtualDesktop()
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
!h::        moveFocus("left")
!j::        moveFocus("down")
!k::        moveFocus("up")
!l::        moveFocus("right")

!left::     moveFocus("left") 
!down::     moveFocus("down") 
!up::       moveFocus("up") 
!right::    moveFocus("right")

; Toggle mode
!space::    toggleEdgeMode()

; ======================================================================
;  NORMAL MODE
; ======================================================================
#If !edgeMode

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
#If edgeMode

escape:: toggleEdgeMode()

; Move
+!h::      moveToEdge("left")
+!j::      moveToEdge("down")
+!k::      moveToEdge("up")
+!l::      moveToEdge("right")

+!left::   moveToEdge("left")
+!down::   moveToEdge("down")
+!up::     moveToEdge("up")
+!right::  moveToEdge("right")

; Grow
^!h::      resizeToEdge("left")
^!j::      resizeToEdge("down")
^!k::      resizeToEdge("up")
^!l::      resizeToEdge("right")

^!left::   resizeToEdge("left")
^!down::   resizeToEdge("down")
^!up::     resizeToEdge("up")
^!right::  resizeToEdge("right")

; Shrink
+^!h::      resizeToEdge("right")
+^!j::      resizeToEdge("up")
+^!k::      resizeToEdge("down")
+^!l::      resizeToEdge("left")

+^!left::   resizeToEdge("right")
+^!down::   resizeToEdge("up")
+^!up::     resizeToEdge("down")
+^!right::  resizeToEdge("left")


