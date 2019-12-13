;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Move focus
!h::      MoveFocus("left")
!j::      MoveFocus("down")
!k::      MoveFocus("up")
!l::      MoveFocus("right")

!left::  MoveFocus("left") 
!down::  MoveFocus("down") 
!up::    MoveFocus("up") 
!right:: MoveFocus("right")

; Move window
+!l::      MoveWindow(80, 0)
+!h::      MoveWindow(-80, 0)
+!k::      MoveWindow(0, -80)
+!j::      MoveWindow(0, 40)

+!right::  MoveWindow(80, 0) 
+!left::   MoveWindow(-80, 0) 
+!up::     MoveWindow(0, -80) 
+!down::   MoveWindow(0, 80)

; Resize window
^+!l::     ResizeWindow(80, 0)
^+!h::     ResizeWindow(-80, 0)
^+!k::     ResizeWindow(0, -80)
^+!j::     ResizeWindow(0, 80)

^!right::  ResizeWindow(80, 0) 
^!left::   ResizeWindow(-80, 0) 
^!up::     ResizeWindow(0, -80) 
^!down::   ResizeWindow(0, 80)

; Tile windows
^!h::     TileCurrentWindow("Left")
^!l::     TileCurrentWindow("Right")

^!left::  TileCurrentWindow("Left")
^!right:: TileCurrentWindow("Right")

; Maximise/minimise
^!k::    ToggleMax()
^!j::    ToggleMin()

^!up::   ToggleMax()
^!down:: ToggleMin()

!x:: UntileCurrentWindow()
!r:: CascadeCurrentDesktop()

; Modify tiling area width
!+,:: ModifyWidth(-80)
!+.:: ModifyWidth(80)

; !v:: SelectAndCycle(0) Disabled untiled improved

; Desktop switching
!n:: GoToNextDesktop()
!b:: GoToPrevDesktop()

; Todo: Implement using the DLL
!+n:: Send, #^d
; !+q::deleteVirtualDesktop()
!^n:: MoveCurrentWindowToNextDesktop()
!^b:: MoveCurrentWindowToPreviousDesktop()

; Close the active window
!q::
  WinClose, A
  RemoveWindowFromArray()
  AutoTile()
Return

; Alt Tab
<!c::AltTab

; Reload the script
!+r:: 
  Reload
  CascadeAll()
return

; Exit script
#+x:: ExitApp
