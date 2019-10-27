;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Vim-like keybindings
>!h:: Send, {Left} 
>!j:: Send, {Down}
>!k:: Send, {Up}
>!l:: Send, {Right}

<!h:: Move("left")
<!j:: Move("down")
<!k:: Move("up")
<!l:: Move("right")

+<!l:: MoveWindow(40, 0)
+<!h:: MoveWindow(-40, 0)
+<!k:: MoveWindow(0, -40)
+<!j:: MoveWindow(0, 40)

^<!l:: ResizeWindow(40, 0)
^<!h:: ResizeWindow(-40, 0)
^<!k:: ResizeWindow(0, -40)
^<!j:: ResizeWindow(0, 40)

; Gridster
!e:: SetLayout()
!+e:: DrawZones() 

!+0:: MoveToZone(0)
!+1:: MoveToZone(1)
!+2:: MoveToZone(2)
!+3:: MoveToZone(3)
!+4:: MoveToZone(4)
!+5:: MoveToZone(5)
!+6:: MoveToZone(6)
!+7:: MoveToZone(7)
!+8:: MoveToZone(8)
!+9:: MoveToZone(9)

!v:: SelectAndCycle(0)
!^v:: SetSuperSelect()
!+v:: SelectSuperSelect()
!+z:: MoveToNextZone()
!z:: FocusNextZone()
!^z:: MoveToNextZone()

!1:: SelectAndCycle(1)
!2:: SelectAndCycle(2)
!3:: SelectAndCycle(3)
!4:: SelectAndCycle(4)
!5:: SelectAndCycle(5)
!6:: SelectAndCycle(6)
!7:: SelectAndCycle(7)
!8:: SelectAndCycle(8)
!9:: SelectAndCycle(9)

; Transparency
; !,:: DecreaseTransparency()
; !.:: IncreaseTransparency()
; !+,:: DesktopDecreaseTransparency()
; !+.:: DesktopIncreaseTransparency()

; Non-vim backups
>!left:: Send, {Left} 
>!down:: Send, {Down} 
>!up:: Send, {Up} 
>!right:: Send, {Right}

<!left:: Move("left") 
<!down:: Move("down") 
<!up:: Move("up") 
<!right:: Move("right")

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
!n::
  global CurrentDesktop
  updateGlobalVariables()
  if (CurrentDesktop == 9)
    return
  if (!DesktopIsEmpty()) {
    WinActivate, ahk_class Shell_TrayWnd
    Sleep, 100
    Send, #^{Right}
    Sleep, 100
    ; The following three lines are a hack to keep key from being stuck
    ; Revise at some point to make prettier
    if (!SelectAndCycle(0))
      FocusNextZone()
    WinActivate
  }
  else
    Send, #^{Right}
  ResetZones()
  ResetSuperZones()
  GenerateGrid()
return
!b::
  global CurrentDesktop
  updateGlobalVariables()
  if (CurrentDesktop == 1)
    return
  if (!DesktopIsEmpty()) {
    WinActivate, ahk_class Shell_TrayWnd
    Sleep, 100
    Send, #^{Left}
    Sleep, 100
    ; The following three lines are a hack to keep key from being stuck
    if (!SelectAndCycle(0))
      FocusNextZone()
    WinActivate
  }
  else
    Send, #^{Left}
  ResetZones()
  ResetSuperZones()
  GenerateGrid()
return

!+n:: Send, #^d
; !+q::deleteVirtualDesktop()
!^n::MoveCurrentWindowToNextDesktop()
!^b::MoveCurrentWindowToPreviousDesktop()

!a:: KeyboardHelp()

; Close the active window
!q:: WinClose, A

; Minimize
!m:: WinMinimize, A

; Turns on decoration
!f:: RemoveDecoration()
!+f:: RestoreDecoration()

; Alt Tab
<!c::AltTab

; Reload the script
#+r:: Reload

; Exit script
#+x:: ExitApp


