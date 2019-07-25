﻿;------------;
; SOME NOTES ;
;------------;

; I've tried using `SendInput` in favor of `Send` but this seems
; to work less frequently. I don't know why.

; The general idea is the following. The screen is divided into
; quadrants, like such:
;
; +---+---+
; | 1 | 2 |
; +---+---+
; | 3 | 4 |
; +---+---+

;------------;
; SOME SETUP ;
;------------;

; Because the positions of the tiled windows do not always rounded
; to e.g. exactly half of the monitor resolution (it happens that a
; top-tiled windows has an x-coordinate of -4, for example) we must
; define an area in which a window is considered tiled, even if it
; is not. This is the `Grace` variable

Grace = 20

;----------------;
; DEFINE HOTKEYS ;
;----------------;

; Move to q1
#+1:: ; Win+Shift+1
  MoveTo(1)
return

; Move to q2
#+2:: ; Win+Shift+2
  MoveTo(2)
return

; Move to q3
#+3:: ; Win+Shift+3
  MoveTo(3)
return

; Move to q4
#+4:: ; Win+Shift+4
  MoveTo(4)
return

; Move to h1
#+§:: ; Win+Shift+§
  MoveTo(1.5)
return

; Move to h2
#+5:: ; Win+Shift+5
  MoveTo(2.5)
return

; Select in and cycle through q1
#1:: ; Win+1
  SelectCycle(1)
return

; Select in and cycle through q2
#2:: ; Win+2
  SelectCycle(2)
return

; Select in and cycle through q3
#3:: ; Win+3
  SelectCycle(3)
return

; Select in and cycle through q4
#4:: ; Win+4
  SelectCycle(4)
return

; Select in and cycle through h1
#§:: ; Win+§
  SelectCycle(1.5)
return

; Select in and cycle through h2
#5:: ; Win+5
  SelectCycle(2.5)
return

; Next virtual desktop
#n:: ; Win+n
  Send, #^{Right}
return

; Previous virtual desktop
#+n:: ; Win+Shift+n -- is it appropriate?
  Send, #^{Left}
return

; Close the active window
#q:: ; Win+q
  WinClose, A
return

; Todo: Create new virtual desktop if it doesn't exist (Win+Shift+d creates new)

;; Maximize
#f:: ; Win+f
  WinMaximize, A
return

;; Minimize  
#m:: ; Win+m
  WinMinimize, A
return

;------------------------;
; CHECK AND MOVE WINDOWS ;
;------------------------;
; Returns the current location
CurrentLocation(id := "") {
  ; Top left (1st q)
  if (IsTiledLeft(id) and IsTiledTop(id) and !TouchesBottom(id))
    return 1
  ; Top right (2nd q)
  else if (IsTiledRight(id) and IsTiledTop(id) and !TouchesBottom(id))
    return 2
  ; Bottom left (3rd q)
  else if (IsTiledLeft(id) and IsTiledBottom(id))
    return 3
  ; Bottom right (4th q)
  else if (IsTiledRight(id) and IsTiledBottom(id))
    return 4
  ; Left half-screen (1st and 3rd q)
  else if (IsTiledLeft(id) and IsTiledTop(id))
    return 1.5
  ; Right half-screen (2nd and 4th q)
  else if (IsTiledRight(id) and IsTiledTop(id))
    return 2.5
  ; If floating or otherwise
  else
    return 0
}

; Is the window at the correct side of the screen?
CorrectSide(d) {
  c := CurrentLocation()
  if ((c == 1 or c == 1.5 or c == 3) and (d == 1 or d == 1.5 or d == 3))
    return true
  else if ((c == 2 or c == 2.5 or c == 4) and (d == 2 or d == 2.5 or d == 4))
    return true
  else
    return false    
  ; Left side is represented by odd numbers and the right
  ; side by even numbers. Thus, as long as the destination
  ; and current location aren't 0, by divinding these
  ; by two and comparing the "rest" we can determine
  ; if we are on the same. This could be made to work
  ; with `Floor`
}

; Moves the windows to the desired location
MoveTo(d) {
  WinGetTitle, title, A
  Loop {  
    if (CorrectSide(d)) {
      c := CurrentLocation()
      a := c - d

      ; Let's assume half-screen is denoted by the upper
      ; quadrant plus .5 and that a negative results means
      ; the window goes down and a positive that it goes
      ; up
      ;
      ; | Cur. pos. | Dest. | Calc. | Res. dir. | Des. dir. |
      ; +-----------+-------+-------+-----------+-----------+
      ; | 1         | 3     | -2    | Down      | Down      |
      ; | 2         | 4     | -2    | Down      | Down      |
      ; | 3         | 1     | 2     | Up        | Up        |
      ; | 4         | 2     | 2     | Up        | Up        |
      ; | 1.5       | 1     | 0.5   | Up        | Up        |
      ; | 2.5       | 2     | 0.5   | Up        | Up        |
      ; | 1         | 1.5   | -0.5  | Down      | Down      |
      ; | 2         | 2.5   | -0.5  | Down      | Down      |
      ; | 3         | 1.5   | 2.5   | Up        | Up        |
      ; | 4         | 1.5   | 2.5   | Up        | Up        |

      ; If we are in the right position, do nothing
      if (a == 0) ; This may not be needed as the `Until`-conditions should prevent such a situation
        return
      ; Diff positive, move up
      else if (a > 0)
        Send, #{Up}
      ; Diff negative, move down
      else if (a < 0)
        Send, #{Down}
    }
    ; If we are not at the correct side, send either left or right
    else if (Mod(d, 2) == 0) {
      Send, #{Left}
    }
    else if (Mod(d, 2) > 0) {
      Send, #{Right}
    }
    Send, {Esc}
  }
  Until (CurrentLocation() == d)
  ; Sometimes after tiling, we are asked if we automatically
  ; want to tile another window relative to it. We do not.
  ; The loop below fixes this.
  Loop {
    WinActivate, %title% ; For this and similar situations it might be better to use ahk_id
  }
  Until (WinActive(title))
}

; Select the top window in a quadrant or side; cycle through the
; section if a window in the section is already selected
SelectCycle(q) {
  WinGet, win, List
  firstLap := true
  if (q == CurrentLocation())
    skipFirst := true
  Loop, %win% {
    this_win := win%A_Index%
    if (Selectable(this_win, q)) {
      if (skipFirst) {
        skipFirst := false
        continue
      }
      WinActivate, ahk_id %this_win%
      break
    }
  }
}

; Determines if a window should be selectable
Selectable(id, q) {
  ; Floating windows etc. shouldn't aren't eligable
  if (CurrentLocation(id) == q)
    return true
  else 
    return false
}

;----------------------;
; `IS TILED` FUNCTIONS ;
;----------------------;
; Currently, these functions can only identify quarter tiles. Half-screen
; tiles show up as top plus right or left.
; Todo: Fix so that large but untiled windows are identified correctly

; Left
IsTiledLeft(id := "") {
  global Grace
  if (id)
    WinGetPos, X, Y, W, H, ahk_id %id%
  else
    WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((X+W <= MonRight/2+Grace and X+W > MonRight/2-Grace) and (X <= 0 and X > 0-Grace))
}

; Right
IsTiledRight(id := "") {
  global Grace
  if (id)
    WinGetPos, X, Y, W, H, ahk_id %id%
  else
    WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((X+W >= MonRight and X+W < MonRight+Grace) and (X+Grace >= MonRight/2 and X < MonRight/2+Grace))
}

; Top
IsTiledTop(id := "") {
  global Grace
  if (id)
    WinGetPos, X, Y, W, H, ahk_id %id%
  else
    WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return (Y <= 0 and (Y+H >= MonBottom/2-Grace and Y+H <= Y+H <= MonBottom/2+Grace))
}

; Bottom
IsTiledBottom(id := "") {
  global Grace
  if (id)
    WinGetPos, X, Y, W, H, ahk_id %id%
  else
    WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  return ((Y >= MonBottom/2 and  Y < MonBottom/2+Grace) and (Y+H >= MonBottom and Y+H < MonBottom+Grace))
}

; Touches bottom?
;; This function is to determine if the window touches to bottom of the
;; screen. It is used to determined if a windows covers half the screen.
TouchesBottom(id := "") {
  if (id)
    WinGetPos, X, Y, W, H, ahk_id %id%
  else
    WinGetPos, , Y, , H, A
  SysGet, Mon, Monitor
  return (Y+H >= MonBottom)
}

;-------------;
; OTHER STUFF ;
;-------------;
; Random tests
#t::
  TLeft := IsTiledLeft()
  TRight := IsTiledRight()
  TTop := IsTiledTop()
  TBottom := IsTiledBottom()
  TsBottom := TouchesBottom()
  CL := CurrentLocation()
  WinGetTitle, title, A
  MsgBox, Left: %TLeft%`nRight: %TRight%`nTop: %TTop%`nBottom: %TBottom%`nTouchesBottom: %TsBottom%`nCurrentLocation: %CL%`nTitle: %title%
  id := ""
  if (id)
    MsgBox, id
return

; Reload the script
#r::
  Reload
return

; Exit script
#x::
  Exit
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
