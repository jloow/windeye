﻿;------------;
; SOME SETUP ;
;------------;

; Because the positions of the tiled windows do not always rounded
; to e.g. exactly half of the monitor resolution (it happens that a
; top-tiled windows has an x-coordinate of -4, for example) we must
; define an area in which a window is considered tiled, even if it
; is not. This is the `Grace` variable

Grace = 20

#SingleInstance

SendMode, Input
SetKeyDelay, 10 ; Todo: Experiment to find a good value

Decoration := false

;----------------;
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
#1:: SelectCycle(1)

; Select and cycle through q2
#2:: SelectCycle(2)

; Select and cycle through q3
#3:: SelectCycle(3)

; Select and cycle through q4
#4:: SelectCycle(4)

; Select and cycle through h1
#§:: SelectCycle(1.5)

; Select and cycle through h2
#5:: SelectCycle(2.5)

; Selects an untiled window
#v:: SelectCycle(0)

; Next virtual desktop
#n:: Send, #^{Right}

; Previous virtual desktop
; Is it appropriate? It is hard to reach with one hand
#+n:: Send, #^{Left}

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
; return

; Start terminal
#r:: Run, pwsh

; Start double commander
#e:: Run, "C:\Program Files\Double Commander\doublecmd.exe"

; Start wsl through cmd
#w:: Run, pwsh /C wsl

; Start qutebrowser
#t:: Run, "C:\Program Files\qutebrowser\qutebrowser.exe"

; Start firefox
#+t:: Run, "C:\Program Files\Mozilla Firefox\firefox.exe"

; Alt Tab
LWin & c::AltTab

; Reload the script
#+r:: Reload

; Exit script
#+x:: Exit

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
  Send, {Win up}
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
    ; Sometimes after tiling, we are asked if we automatically
    ; want to tile another window relative to it. We do not.
    ; The loop below fixes this.
    Loop {
      WinActivate, %title% ; For this and similar situations it might be better to use ahk_id
    }
    Until (WinActive(title))
  }
  Until (CurrentLocation() == d)
}

; Select the top window in a quadrant or side; cycle through the
; section if a window in the section is already selected
SelectCycle(q) {
  WinGet, win, List
  if (q == CurrentLocation())
    skipFirst := true
  Loop, %win% {
    this_win := win%A_Index%
    if (CurrentLocation(this_win) == q) { 
      ; Some windows are hidden and get selected when q == 0. Thus
      ; if q == 0 and the window has no title, we shouldn't select it.
      ; Todo: Make it possible to cycle through un-tiled windows
      if (q == 0) {
        WinGetTitle, t, ahk_id %this_win%
        if (t == "")
          continue
      }
      if (skipFirst) {
        skipFirst := false
        continue
      }
      WinActivate, ahk_id %this_win%
      break
    }
  }
}

RemoveDecoration(id := "") {
  c := CurrentLocation(id)
  if (id) {
    WinSet, Style, -0xC00000, ahk_id %id% ; Hide title bar
    WinSet, Style, -0x200000, ahk_id %id% ; Hide vertical scroll bar
    WinSet, Style, -0x100000, ahk_id %id% ; Hide horizontal scroll bar
  }
  else {
    WinSet, Style, -0xC00000, A
    WinSet, Style, -0x200000, A
    WinSet, Style, -0x100000, A
  }
  ; Sometimes the window dimensions change when removing decoration.
  ; Thus we need to make sure the window gets back to where it started
  MoveTo(c)
}

RestoreDecoration(id := "") {
  if (id) {
    WinSet, Style, +0xC00000, ahk_id %id% ; Hide title bar
    WinSet, Style, +0x200000, ahk_id %id% ; Hide vertical scroll bar
    WinSet, Style, +0x100000, ahk_id %id% ; Hide horizontal scroll bar
  }
  else {
    WinSet, Style, +0xC00000, A
    WinSet, Style, +0x200000, A
    WinSet, Style, +0x100000, A
  }
}

ToggleDecoration() {
  global Decoration
  if (Decoration)
    Decoration := false
  else
    Decoration := true
}

ChangeAllDecoration() {
  WinGet, win, List
  Loop, %win% {
    this_win := win%A_Index%
    if (Decoration)
      RestoreDecoration(this_win)
    else
      RemoveDecoration(this_win)
  }
}

;----------------------;
; `IS TILED` FUNCTIONS ;
;----------------------;
; Currently, these functions can only identify quarter tiles. Half-screen
; tiles show up as top plus right or left.
; Todo: Fix so that large but untiled windows are identified correctly. Fkxed?
; Todo: Can SysGet be global?

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
#^t::
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
