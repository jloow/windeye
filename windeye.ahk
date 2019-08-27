;------------;
; SOME NOTES ;
;------------;

; Currently, the script flips out if the taskbar is not hidden.
; I think this has to do with how the screen size is determined.

;------------;
; SOME SETUP ;
;------------;

  #SingleInstance Force
  #NoEnv
  #Persistent
  SetWorkingDir %A_ScriptDir%
  SendMode, Input
  SetKeyDelay, 20 ; Todo: Experiment to find a good value

  ; Because the positions of the tiled windows do not always rounded
  ; to e.g. exactly half of the monitor resolution (it happens that a
  ; top-tiled windows has an x-coordinate of -4, for example) we must
  ; define an area in which a window is considered tiled, even if it
  ; is not. This is the `Grace` variable
  Grace = 20

  ; The amount of which to change transparency
  TrnspStep = 10

  MakeTransparent := false

  #Include %A_ScriptDir%\desktop_switcher.ahk
  #Include %A_ScriptDir%\keybindings.ahk
  ;#Include %A_ScriptDir%\applications.ahk

Return

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

; The key is the following:
; up = -2 (because 3 - 2 = 1 and 4 - 2 = 2)
; down = 2 (because 1 + 2 = and 2 + 2 = 4)
; left = -1 (because 2 - 1 = 1 and 4 - 1 = 3)
; right = 1 (because 1 + 1 = 2 and 3 + 1 = 4)
MoveTo(d) {
  c := Floor(CurrentLocation())
  destination := c + d
  if (destination >= 1 and destination <= 4)
    SelectAndCycle(destination)
}

/* Lets disable this for now
; Moves the windows to the desired location
MoveTo(d) {
  WinGet, id, ID, A
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
      WinActivate, ahk_id %id% ; For this and similar situations it might be better to use ahk_id
    }
    Until (WinActive("ahk_id" . id))
  }
  Until (CurrentLocation() == d)
  ; Sometimes the tiling window still pop-up. Therefore we will try to
  ; wait a short while, and then check the location again
  Sleep, 1000
  if (CurrentLocation() != d)
    MoveTo(d)
}
*/

; Select the top window in a quadrant or side; cycle through the
; section if a window in the section is already selected
SelectAndCycle(q) {
  WinGet, win, List
  found := false
  if (q == CurrentLocation())
    skipFirst := true
  Loop, %win% {
    this_win := win%A_Index%
    if (CurrentLocation(this_win) == q) { 
      ; Some windows are hidden and get selected when q == 0. Thus
      ; if q == 0 and the window has no title, we shouldn't select it.
      if (q == 0) {
        WinGetTitle, t, ahk_id %this_win%
        if (t == "")
          continue
      }
      if (skipFirst) {
        skipFirst := false
        WinSet, Bottom, , ahk_id %this_win% ; If there are more than two windows we want the
                                            ; the one that was found first to get sent to
                                            ; the bottom so that we don't just switch between
                                            ; two windows 
        continue
      }
      ; The list contains all windows, regardless of which desktop they're
      ; on. Therefore we need to check if the window is on the correct desktop
      ; or not (borrowed from desktop_switcher.ahk)
      global CurrentDesktop
      windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
      if (windowIsOnDesktop == 1) {
        found := true
        WinActivate, ahk_id %this_win%
        break
      }
    }
  }
  ; If we get to this point, it means that there is no window in the quadrant.
  ; Sometimes, this is because a half-screened window is mistaken for a
  ; quarter-screened window. Thus, to be nice, we let ahk select the
  ; half-screen window
  if (q == Floor(q) and not found)
    SelectAndCycle(Mod(q, 2) == 0 ? 2.5 : 1.5)
  global MakeTransparent
  if (found and MakeTransparent)
    MakeAllTransparent()
}

SelectNext() {
  start := CurrentLocation()
  if (start == 0)
    start := 1
  n := start
  Loop {
    n := n == 4 ? 1 : n + 0.5
    SelectAndCycle(n) 
  }
  Until (n == start or n == CurrentLocation())
}

SelectPrev() {
  start := CurrentLocation()
  if (start == 0)
    start := 4
  n := start
  Loop {
    n := n == 1 ? 4 : n - 0.5
    SelectAndCycle(n) 
  }
  Until (n == start or n == CurrentLocation())
}

;-------------;
; FANCY STUFF ;
;-------------;
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
    ; WinSet, Style, +0x200000, ahk_id %id% ; Hide vertical scroll bar
    ; WinSet, Style, +0x100000, ahk_id %id% ; Hide horizontal scroll bar
  }
  else {
    WinSet, Style, +0xC00000, A
    ; WinSet, Style, +0x200000, A
    ; WinSet, Style, +0x100000, A
  }
}

IncreaseTransparency() {
  global TrnspStep
  WinGet, trnsp, Transparent, A
  WinSet, Transparent, % trnsp + TrnspStep, A 
}

DecreaseTransparency() {
  global TrnspStep
  WinGet, trnsp, Transparent, A
  WinSet, Transparent, % trnsp - TrnspStep, A 
}

ToggleTransparency() {
  global MakeTransparent
  if (MakeTransparent) {
    MakeTransparent := false
    MakeAllSolid()
    SetTimer, Update, Off
  }
  else {
    MakeTransparent := true
    MakeAllTransparent()
    SetTimer, Update, 1000
  }
}

MakeAllTransparent() {
  WinGet, win, List
  global CurrentDesktop
  WinGet, cWin, ID, A
  Loop, %win% {
    this_win := win%A_Index%
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop) {
      if (this_win == cWin)
        WinSet, Transparent, 240, ahk_id %cWin%
      else
        WinSet, Transparent, 200, ahk_id %this_win%
    }
  }
}

MakeAllSolid() {
  WinGet, win, List
  global CurrentDesktop
  Loop, %win% {
    this_win := win%A_Index%
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop) {
      WinSet, Transparent, 255, ahk_id %this_win%
      WinSet, Transparent, Off, ahk_id %this_win%
    }
  }
}

; ToggleDecoration() {
;   global Decoration
;   if (Decoration)
;     Decoration := false
;   else
;     Decoration := true
; }

; ChangeAllDecoration() {
;   WinGet, win, List
;   Loop, %win% {
;     this_win := win%A_Index%
;     if (Decoration)
;       RestoreDecoration(this_win)
;     else
;       RemoveDecoration(this_win)
;   }
; }

;-------------;
; OTHER STUFF ;
;-------------;
Update() {
  global MakeTransparent
  if (MakeTransparent)
    MakeAllTransparent()
  else
    MakeAllSolid()
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
#u::
  TLeft := IsTiledLeft()
  TRight := IsTiledRight()
  TTop := IsTiledTop()
  TBottom := IsTiledBottom()
  TsBottom := TouchesBottom()
  CL := CurrentLocation()
  WinGetTitle, title, A
  MsgBox, Left: %TLeft%`nRight: %TRight%`nTop: %TTop%`nBottom: %TBottom%`nTouchesBottom: %TsBottom%`nCurrentLocation: %CL%`nTitle: %title%
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
