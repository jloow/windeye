; Rebind the tiling system

;------------;
; SOME NOTES ;
;------------;

; I've tried using `SendInput` in favor of `Send` but this seems
; to work less frequently. I don't know why.

; Because the positions of the tiled windows do not always rounded
; to e.g. exactly half of the monitor resolution (it happens that a
; top-tiled windows has an x-coordinate of -4, for example) we must
; define an area in which a window is considered tiled, even if it
; is not. This is the `Grace` variable
Grace = 20

; The general idea is the following. The screen is divided into
; quadrants, like such:
;
; +---+---+
; | 1 | 2 |
; +---+---+
; | 3 | 4 |
; +---+---+
;
; Mod1+1, for example, sends the active window, regardless of its
; current location, to the first quadrant. Mod1+! sends a window to
; the first and third quandrant.

;------------------------;
; SEND TO FIRST QUADRANT ;
;------------------------;
#1:: ; Win+1
  MoveTo(1)
return

#2:: ; Win+2
  MoveTo(2)
return

#3:: ; Win+3
  MoveTo(3)
return

#4:: ; Win+4
  MoveTo(4)
return

#§:: ; Win+§
  MoveTo(13)
return

#5:: ; Win+5
  MoveTo(24)
return


;----------------;
; MOVE WINDOW UP ;
;----------------;
; This functions in such a way that, depending on whether the window
; is on the left or right side already, it tiles it to that side and
; then tiles it up. It also limits the ability to move the window
; if it is already tiled.
#k:: ; Win+k
  Send, {Win up}
  ; Todo: Fix so that  non-tiled windows that are partly outside the
  ;       screen are handled correctly
  ; If the windows is already "top-tiled", do nothing
  if (IsTiledTop() and (IsTiledLeft() or IsTiledRight()) not TouchesBottom)
    return
  ; Else, if it is tiled to the right or left (and to the bottom),
  ; send the windows "up" with out first sending it to either
  ; side
  else if (IsTiledLeft() or IsTiledRight())
    Send, #{Up}
  ; In the last two cases, where windows are not tiled, we determine if
  ; they are mostly to the left or right side of the screen. The
  ; windows are positioned accordingly
  ; Todo: Currently this is done by only evaulating the x coordinate; it
  ;       should determine if the whole windows is mostly to the right
  ;       or left
  else if (X <= MonRight/2) {
    Send, #{Left}#{Up}
  }
  else if (X > MonRight/2) {
    Send, #{Right}#{Up}
  }
  ; Sometimes when tiling up, Windows asks us if we want to tile another
  ; window. We do not...
  Send, {Esc}
return

;-------------------;
; MOVE WINDOW RIGHT ;
;-------------------;
#l:: ; Win+l
  Send, {Win up}
  if (IsTiledRight())
    return
  Send, #{Right}
  ; The "double-check" here and for moving window left is needed
  ; because Windows does not move the window from on side to
  ; another directly; first, the windows "floats". This does not
  ; work all the time
  if (!IsTiledRight())
    Send, #{Right}
return

;------------------;
; MOVE WINDOW LEFT ;
;------------------;
#h:: ; Win+h
  Send, {Win up}
  if (IsTiledLeft())
    return
  Send, #{Left}
  if (!IsTiledLeft())
    Send, #{Left}
return

;------------------;
; MOVE WINDOW DOWN ;
;------------------;
#j:: ; Win+j
  Send, {Win up}
  if (IsTiledBottom())
    return
  Send, #{Down}
return

; Maximizing and minimizing this way does not work reliably.

;-----------------;
; MAXIMIZE WINDOW ;
;-----------------;
#f:: ; Win+f
  Send, #{Up}#{Up}
return

;-----------------;
; MINIMIZE WINDOW ;
;-----------------;
#m:: ; Win+m
  Send, #{Down}#{Down}
return

CurrentLocation() {
  ; Top left (1st q)
  if (IsTiledLeft() and IsTiledTop() and !TouchesBottom())
    return 1
  ; Top right (2nd q)
  else if (ISTiledRight() and IsTiledTop() and !TouchesBottom())
    return 2
  ; Bottom left (3rd q)
  else if (IsTiledLeft() and IsTiledBottom())
    return 3
  ; Bottom right (4th q)
  else if (IsTiledRight() and IsTiledBottom())
    return 4
  ; Left half-screen (1st and 3rd q)
  else if (IsTiledLeft() and IsTiledTop())
    return 13
  ; Right half-screen (2nd and 4th q)
  else if (IsTiledRight() and IsTiledTop())
    return 24
  ; If floating or otherwise
  else
    return 0
}

MoveTo(q) {
  ; Move from floating
  if (CurrentLocation() == 0){
    if (q == 1) {
      Send, #{Left}
      Sleep, 10
      Send, #{Up}
    }
    else if (q == 2) {
      Send, #{Right}
      Sleep, 10
      Send, #{Up}
    }
    else if (q == 3) {
      Send, #{Left}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 4) {
      Send, #{Right}
      Sleep, 10
      Send, #{Bottom}
    }
    else if (q == 13) {
      Send, #{Left}
    }
    else if (q == 24) {
      Send, #{Right}
    }
  }
  ; Move from first quadrant
  else if (CurrentLocation() == 1){
    if (q == 1) {
      return ; For now, just return
    }
    else if (q == 2) {
      Send, #{Right}
    }
    else if (q == 3) {
      Send, #{Down}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 4) {
      Send, #{Right}
      Sleep, 10
      Send, #{Down}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 13) {
      Send, #{Down}
    }
    else if (q == 24) {
      Send, #{Right}
      Sleep, 10
      Send, #{Down}
    }
  }
  ; Move from 2nd quadrant
  else if (CurrentLocation() == 2){
    if (q == 1) {
      Send, #{Left}
    }
    else if (q == 2) {
      return
    }
    else if (q == 3) {
      Send, #{Left}
      Sleep, 10
      Send, #{Down}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 4) {
      Send, #{Down}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 13) {
      Send, #{Left}
      Sleep, 10
      Send, #{Down}
    }
    else if (q == 24) {
      Send, #{Down}
    }
  }
  ; Move from 3rd quadrant
  else if (CurrentLocation() == 3) {
    if (q == 1) {
      Send, #{Up}
      Sleep, 10
      Send, #{Up}
    }
    else if (q == 2) {
      Send, #{Up}
      Sleep, 10
      Send, #{Up}
      Sleep, 10
      Send, #{Right}
    }
    else if (q == 3) {
      return
    }
    else if (q == 4) {
      Send, #{Right}
    }
    else if (q == 13) {
      Send, #{Up}
    }
    else if (q == 24) {
      Send, #{Right}
      Sleep, 10
      Send, #{Up}
    }
  }
  ; Move from 4th quadrant
  else if (CurrentLocation() == 4) {
    if (q == 1) {
      Send, #{Up}
      Sleep, 10
      Send, #{Up}
      Sleep, 10
      Send, #{Left}
    }
    else if (q == 2) {
      Send, #{Up}
      Sleep, 10
      Send, #{Up}
    }
    else if (q == 3) {
      Send, {Left}
    }
    else if (q == 4) {
      return
    }
    else if (q == 13) {
      Send, #{Left}
      Sleep, 10
      Send, #{Up}
    }
    else if (q == 24) {
      Send, #{Up}
    }
  }
  ; Move from left half-screen
  else if (CurrentLocation() == 13) {
    if (q == 1) {
      Send, #{Up}
    }
    else if (q == 2) {
      Send, #{Up}
      Sleep, 10
      Send, #{Left}
    }
    else if (q == 3) {
      Send, #{Down}
    }
    else if (q == 4) {
      Send, #{Down}
      Sleep, 10
      Send, #{Right}
    }
    else if (q == 13) {
      return
    }
    else if (q == 24) {
      Send, #{Right}
      Sleep, 10
      Send, #{Right}
    }
  }
  ; Move from right half-screen
  else if (CurrentLocation() == 24) {
    if (q == 1) {
      Send, #{Up}
      Sleep, 10
      Send, #{Left}
    }
    else if (q == 2) {
      Send, #{Up}
    }
    else if (q == 3) {
      Send, #{Down}
      Sleep, 10
      Send, #{Left}
    }
    else if (q == 4) {
      Send, #{Down}
    }
    else if (q == 13) {
      Send, #{Left}
      Sleep, 10
      Send, #{Left}
    }
    else if (q == 24) {
      return
    }
  }
}

;--------------------;
; IS TILED FUNCTIONS ;
;--------------------;
; Currently, these functions can only identify quarter tiles. Half-screen
; tiles show up as top plus right or left.
; Todo: Fix so that large but untiled windows are identified correctly

;--LEFT--;
IsTiledLeft(){
  global Grace
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((X+W <= MonRight/2+Grace and X+W > MonRight/2-Grace) and (X <= 0 and X > 0-Grace))
}

;--RIGHT--;
IsTiledRight(){
  global Grace
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((X+W >= MonRight and X+W < MonRight+Grace) and (X+Grace >= MonRight/2 and X < MonRight/2+Grace))
}

;--TOP--;
IsTiledTop() {
  global Grace
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return (Y <= 0 and (Y+H >= MonBottom/2-Grace and Y+H <= Y+H <= MonBottom/2+Grace))
}

;--BOTTOM--;
IsTiledBottom() {
  global Grace
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((Y >= MonBottom/2 and  Y < MonBottom/2+Grace) and (Y+H >= MonBottom and Y+H < MonBottom+Grace))
}

;--TOUCHES BOTTOM?--;
; This function is to determine if the window touches to bottom of the
; screen. It is used to determined if a windows covers half the screen.
TouchesBottom() {
  WinGetPos, , Y, , H, A
  SysGet, Mon, Monitor
  return (Y+H >= MonBottom)
}

;--------------;
; RANDOM TESTS ;
;--------------;
#t::
  TLeft := IsTiledLeft()
  TRight := IsTiledRight()
  TTop := IsTiledTop()
  TBottom := IsTiledBottom()
  TsBottom := TouchesBottom()
  CL := CurrentLocation()
  MsgBox, Left: %TLeft%`nRight: %TRight%`nTop: %TTop%`nBottom: %TBottom%`nTouchesBottom: %TsBottom%`nCurrentLocation: %CL%

  ; WinGet, id, List
  ; Loop, %id% {
  ;   this_id := id%A_Index%
  ;   WinGetTitle, this_title, ahk_id %this_id%
  ;   MsgBox, %this_title%
  ; }
return

; This is how moving focus will work:
; 1. Determine if we want to move focus left, right, up or down (keypress)
; 2. Determine where we are, i.e. which quadrant. Depending on this, we
;    will exclude some options. First one half of the screen is exluded.
;    Then, all windows in the wrong direction (e.g. below when we want
;    to move focus up) are excluded.
; 3.

;-------------------;
; RELOAD THE SCRIPT ;
;-------------------;
#r::
  Reload
return


; Some help and references
;
; # 	Win (Windows logo key)
; ! 	Alt
; ^ 	Control
; + 	Shift

; Stuff that might get reused.
  ; TLeft := IsTiledLeft()
  ; TRight := IsTiledRight()
  ; TTop := IsTiledTop()
  ; TBottom := IsTiledBottom()
  ; TsBottom := TouchesBottom()
  ; MsgBox, Left: %TLeft%`nRight: %TRight%`nTop: %TTop%`nBottom: %TBottom%`nTouchesBottom: %TsBottom%
