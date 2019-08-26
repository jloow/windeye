;----------------;
; DEFINE HOTKEYS ;
;----------------;

#s:: ToggleTransparency()

; Move up
#+Up:: Send, #{Up}

; Move down
#+Down:: Send, #{Down}

; Move left
#+Left:: Send, #{Left}

; Move right
#+Right:: Send, #{Right}


; Move up
#Up:: MoveTo(-2)

;Move down
#Down:: MoveTo(2)

;Move left
#Left:: MoveTo(-1)

;Move right
#Right:: MoveTo(1)

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

; Close the active window
#q:: WinClose, A

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

; Decrease transparency
#j:: DecreaseTransparency()

; Increase transparency
#k:: IncreaseTransparency()

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


