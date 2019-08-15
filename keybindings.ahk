﻿;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Move to q1
#+1:: MoveTo(1)

; Move to q2
#+2:: MoveTo(2)

; Move to q3
#+3:: MoveTo(3)

; Move to q4
#+4:: MoveTo(4)

; Move to h1
#+§:: MoveTo(1.5)

; Move to h2
#+5:: MoveTo(2.5)

; Select and cycle through q1
#1:: SelectAndCycle(1)

; Select and cycle through q2
#2:: SelectAndCycle(2)

; Select and cycle through q3
#3:: SelectAndCycle(3)

; Select and cycle through q4
#4:: SelectAndCycle(4)

; Select and cycle through h1
#§:: SelectAndCycle(1.5)

; Select and cycle through h2
#5:: SelectAndCycle(2.5)

; Selects an untiled window
#v:: SelectAndCycle(0)

; Walk left to right, row by row, to select windows
#tab:: SelectNext()

; Walk right to left, row by row, to select windows
#+Tab:: SelectPrev()

; Next virtual desktop
; #n:: Send, #^{Right}

; Previous virtual desktop
; Is it appropriate? It is hard to reach with one hand
; #+n:: Send, #^{Left}

; Close the active window
#q:: WinClose, A

; Todo: implement windows-desktop-switcher

; Maximize
; Todo: For min and max, implement restore
#f:: WinMaximize, A

; Super full-screen
#+f::
RemoveDecoration()
WinMaximize, A
return

; Minimize
#m:: WinMinimize, A

; Turns on decoration
#h:: RemoveDecoration()

; Turns off decoration
#+h:: RestoreDecoration()

; Toggle automatic decoration control
; #g::
; ToggleDecoration()
; ChangeAllDecoration()

; Alt Tab
LWin & c::AltTab

; Reload the script
#+r:: Reload

; Exit script
#+x:: ExitApp

