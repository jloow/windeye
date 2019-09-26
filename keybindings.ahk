;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Make CapsLock useful
CapsLock::Esc

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

; Transparency
!,:: DecreaseTransparency()
!.:: IncreaseTransparency()

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

; Move to quadrants/half-screens
!+1:: MoveTo(1)

; Move to q2
!+2:: MoveTo(2)

; Move to q3
!+3:: MoveTo(3)

; Move to q4
!+4:: MoveTo(4)

; Untile
!+w:: MoveTo(0)

; Move to h1
!+`:: MoveTo(1.5)

; Move to h2
!+5:: MoveTo(2.5)

; Select and cycle through q1
!1:: SelectAndCycle(1)

; Select and cycle through q2
!2:: SelectAndCycle(2)

; Select and cycle through q3
!3:: SelectAndCycle(3)

; Select and cycle through q4
!4:: SelectAndCycle(4)

; Select and cycle through h1
!`:: SelectAndCycle(1.5)

; Select and cycle through h2
!5:: SelectAndCycle(2.5)

; Selects an untiled window
!v:: SelectAndCycle(0)

; Desktop switcher stuff
!n:: Send, #^{Right}
!b:: Send, #^{Left}
!+n:: Send, #^d
; !+q::deleteVirtualDesktop()
!^n::MoveCurrentWindowToNextDesktop()
!^b::MoveCurrentWindowToPreviousDesktop()

; Walk left to right, row by row, to select windows
!tab:: SelectNext()

; Walk right to left, row by row, to select windows
!+Tab:: SelectPrev()

!a:: KeyboardHelp()

; Close the active window
!q:: WinClose, A

; Maximize
; Todo: For min and max, implement restore
!f:: WinMaximize, A

; Super full-screen
#+f::
RemoveDecoration()
WinMaximize, A
return

; Minimize
!m:: WinMinimize, A

; Turns on decoration
!h:: RemoveDecoration()

; Alt Tab
<!c::AltTab

; Reload the script
#+r:: Reload

; Exit script
#+x:: ExitApp


