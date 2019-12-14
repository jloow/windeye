;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Move focus
!h::      moveFocus("left")
!j::      moveFocus("down")
!k::      moveFocus("up")
!l::      moveFocus("right")

!left::   moveFocus("left") 
!down::   moveFocus("down") 
!up::     moveFocus("up") 
!right::  moveFocus("right")

; Move window
+!l::      moveWindow(80, 0)
+!h::      moveWindow(-80, 0)
+!k::      moveWindow(0, -80)
+!j::      moveWindow(0, 40)

+!right::  moveWindow(80, 0) 
+!left::   moveWindow(-80, 0) 
+!up::     moveWindow(0, -80) 
+!down::   moveWindow(0, 80)

; Resize window
^+!l::     resizeWindow(80, 0)
^+!h::     resizeWindow(-80, 0)
^+!k::     resizeWindow(0, -80)
^+!j::     resizeWindow(0, 80)

^!right::  resizeWindow(80, 0) 
^!left::   resizeWindow(-80, 0) 
^!up::     resizeWindow(0, -80) 
^!down::   resizeWindow(0, 80)

; Tile windows
^!h::     tileCurrentWindow("Left")
^!l::     tileCurrentWindow("Right")

^!left::  tileCurrentWindow("Left")
^!right:: tileCurrentWindow("Right")

; Maximise/minimise
^!k::    toggleMax()
^!j::    toggleMin()

^!up::   toggleMax()
^!down:: toggleMin()

!x:: untileCurrentWindow()
!r:: cascadeCurrentDesktop()

; Modify tiling area width
!+,:: modifyWidth(-80)
!+.:: modifyWidth(80)

; !v:: selectAndCycle(0) Disabled untiled improved

; Desktop switching
!n:: goToNextDesktop()
!b:: goToPrevDesktop()

; Todo: Implement using the DLL
!+n:: Send, #^d
; !+q::deletevirtualDesktop()
!^n:: moveCurrentWindowToNextDesktop()
!^b:: moveCurrentWindowToPreviousDesktop()

; Close the active window
!q::
  WinClose, A
  removeWindowFromArray()
  autoTile()
Return

; Alt Tab
<!c::AltTab

; Reload the script
!+r:: 
  Reload
  cascadeAll()
return

; Exit script
#+x:: ExitApp
