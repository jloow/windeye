;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Vim-like keybindings
!h:: MoveFocus("left")
!j:: MoveFocus("down")
!k:: MoveFocus("up")
!l:: MoveFocus("right")

+!l:: MoveWindow(80, 0)
+!h:: MoveWindow(-80, 0)
+!k:: MoveWindow(0, -80)
+!j:: MoveWindow(0, 40)

^+!l:: ResizeWindow(80, 0)
^+!h:: ResizeWindow(-80, 0)
^+!k:: ResizeWindow(0, -80)
^+!j:: ResizeWindow(0, 80)

^!h:: TileCurrentWindow("Left")
^!l:: TileCurrentWindow("Right")
^!k:: ToggleMax()
^!j:: ToggleMin()
^!x:: UntileCurrentWindow()
^!r:: CascadeAll()

!v:: SelectAndCycle(0)

; Transparency
!,:: DecreaseTransparency()
!.:: IncreaseTransparency()
; !+,:: DesktopDecreaseTransparency()
; !+.:: DesktopIncreaseTransparency()

; Non-vim backups
>!left:: Send, {Left} 
>!down:: Send, {Down} 
>!up:: Send, {Up} 
>!right:: Send, {Right}

<!left::  MoveFocus("left") 
<!down::  MoveFocus("down") 
<!up::    MoveFocus("up") 
<!right:: MoveFocus("right")

+<!right:: MoveWindow(40, 0) 
+<!left:: MoveWindow(-40, 0) 
+<!up:: MoveWindow(0, -40) 
+<!down:: MoveWindow(0, 40)

^<!right:: ResizeWindow(40, 0) 
^<!left:: ResizeWindow(-40, 0) 
^<!up:: ResizeWindow(0, -40) 
^<!down:: ResizeWindow(0, 40)

; Desktop switcher stuff
; Todo: Put this into a function
!n:: GoToNextDesktop()
  ; global CurrentDesktop
  ; updateGlobalVariables()
  ; if (CurrentDesktop == 9)
  ;   return
  ; WinActivate, ahk_class Shell_TrayWnd
  ; SwitchToDesktop(_GetNextDesktopNumber())
  ;if (!SelectAndCycle(0))
  ;  FocusNextZone()
  ;WinActivate
  ;ResetSuperZones()
  ;GenerateGrid()
!b:: GoToPrevDesktop()
  ; updateGlobalVariables()
  ; if (CurrentDesktop == 1)
  ;   return
  ; WinActivate, ahk_class Shell_TrayWnd
  ; SwitchToDesktop(_GetPreviousDesktopNumber())
  ; if (!SelectAndCycle(0))
  ;   FocusNextZone()
  ; WinActivate
  ; ResetZones()
  ; ResetSuperZones()
  ; GenerateGrid()

!+n:: Send, #^d
; !+q::deleteVirtualDesktop()
!^n:: MoveCurrentWindowToNextDesktop()
!^b:: MoveCurrentWindowToPreviousDesktop()

; Close the active window
!q::
  WinClose, A
  AutoTile()
Return

; Minimize
!m:: WinMinimize, A

; Turns on decoration
!f:: RemoveDecoration()
!+f:: RestoreDecoration()

; Alt Tab
<!c::AltTab

; Reload the script
!+r:: Reload

; Exit script
#+x:: ExitApp
