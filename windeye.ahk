;--------------;
; Auto execute ;
;--------------;

  ;--------------------------------------------------------------------
  ; VirtualDesktopAccessor, credits:
  ; - https://github.com/pmb6tz/windows-desktop-switcher
  ; - https://github.com/sdias/win-10-virtual-desktop-enhancer
  ; - https://github.com/Ciantic/VirtualDesktopAccessor
  ;--------------------------------------------------------------------
  hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", "VirtualDesktopAccessor.dll", "Ptr")
  global GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
  global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
  global GetDesktopCountProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetDesktopCount", "Ptr")
  ;--------------------------------------------------------------------

  ;--------------------------------------------------------------------
  ; WinArrange, credits:
  ; https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/
  ;--------------------------------------------------------------------
  global TILE        := 1                  ; for Param 1
  global CASCADE     := 2                  ; for Param 1
  global VERTICAL    := 0                  ; for Param 3
  global HORIZONTAL  := 1                  ; for Param 3
  global ZORDER      := 4                  ; for Param 3
  global CLIENTAREA  := "200|25|1000|700"  ; for Param 4
  ; ALLWINDOWS (Param 2), ARRAYORDER (Param 3), FULLSCREEN (Param 4) 
  ; are undeclared variables simulating NULL content.
  ;--------------------------------------------------------------------

  ; Split the screen in two
  global LEFT  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global RIGHT := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight

  ; Arrays for tiled windows. Support 9 virtual desktops
  global  arrayLeft1 := Array()
  global  arrayLeft2 := Array()
  global  arrayLeft3 := Array()
  global  arrayLeft4 := Array()
  global  arrayLeft5 := Array()
  global  arrayLeft6 := Array()
  global  arrayLeft7 := Array()
  global  arrayLeft8 := Array()
  global  arrayLeft9 := Array()
  global arrayRight1 := Array() 
  global arrayRight2 := Array()
  global arrayRight3 := Array() 
  global arrayRight4 := Array() 
  global arrayRight5 := Array() 
  global arrayRight6 := Array() 
  global arrayRight7 := Array() 
  global arrayRight8 := Array() 
  global arrayRight9 := Array() 

  #SingleInstance Force
  #NoEnv
  #Persistent
  SetWorkingDir %A_ScriptDir%
  SendMode, Input
  SetKeyDelay, -1
  SetBatchLines -1

  ; The amount of which to change transparency
  TrnspStep = 10

  ; Includes
  #Include %A_ScriptDir%\desktop_switcher.ahk ; Remove when dependency removed
  #Include %A_ScriptDir%\keybindings.ahk
  #Include %A_ScriptDir%\WinArrange.ahk

Return

;-------------------------;
; SELECT AND MOVE WINDWOS ;
;-------------------------;

MoveFocus(direction) {
  
  WinGet, id, ID, A ; Get id of current window
  WinGetPos, currentX, currentY, currentWidth, currentHeight, A ; Get position of current window
  WinGet, win, List ; Get a list of all available windows

  currentPointX := currentX + currentWidth / 2
  currentPointY := currentY + currentHeight / 2
  
  ; Some variables to determine which window is closest to
  ; the current window
  candidatePointX := 0
  candidatePointY := 0
  candidateWindow := id
  firstLoop := True
  
  ; First we try to make a narrow selection
  Loop, %win% {
    thisWin := win%A_Index%

    ; Correct desktop?
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, _GetCurrentDesktopNumber() - 1)
    if (windowIsOnDesktop != 1)
      continue

    ; Skip current window
    if (id == thisWin)
      continue

    WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %thisWin% ; Get position of window

    nextPointX := nextX + nextWidth / 2
    nextPointY := nextY + nextHeight / 2

    ; Go up
    if (direction == "up") {
      if (nextPointY < currentPointY AND nextPointX > currentX AND nextPointX < currentX + currentWidth) {
        if (firstLoop OR candidatePointY < nextPointY) {
          firstLoop := False
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }

    ; Go down
    else if (direction == "down") {
      if (nextPointY > currentPointY AND nextPointX > currentX AND nextPointX < currentX + currentWidth) {
        if (firstLoop OR candidatePointY > nextPointY) {
          firstLoop := False
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }

    ; Go right
    else if (direction == "right") {
      if (nextPointX > currentPointX AND nextPointY > currentY AND nextPointY < currentY + currentHeight) {
        if (firstLoop OR candidatePointX > nextPointX) {
          firstLoop := False
          candidateWindow := thisWin
          candidatePointX := nextPointX
        }
      }
    }

    ; Go left
    else if (direction == "left") {
      if (nextPointX < currentPointX AND nextPointY > currentY AND nextPointY < currentY + currentHeight) {
        if (firstLoop OR candidatePointX < nextPointX) {
          firstLoop := False
          candidateWindow := thisWin
          candidatePointX := nextPointX
        }
      }
    }
  }

  ; Lastly we are very loose with the criteria
  if (candidateWindow == id) {
    firstLoop := True
    Loop, %win% {
      thisWin := win%A_Index%

      ; Correct desktop?
      windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, CurrentDesktop - 1)
      if (windowIsOnDesktop != 1)
        continue

      ; Skip current window
      if (id == thisWin)
        continue
      
      WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %thisWin% ; Get position of window

      nextPointX := nextX + nextWidth / 2
      nextPointY := nextY + nextHeight / 2

      ; Go up
      if (direction == "up") {
        if (nextPointY < currentPointY) {
          if (firstLoop OR candidatePointY < nextPointY) {
            firstLoop := False
            candidateWindow := thisWin
            candidatePointY := nextPointY
          }
        }
      }

      ; Go down
      else if (direction == "down") {
        if (nextPointY > currentPointY) {
          if (firstLoop OR candidatePointY > nextPointY) {
            firstLoop := False
            candidateWindow := thisWin
            candidatePointY := nextPointY
          }
        }
      }

      ; Go right
      else if (direction == "right") {
        if (nextPointX > currentPointX) {
          if (firstLoop OR candidatePointX > nextPointY) {
            firstLoop := False
            candidateWindow := thisWin
            candidatePointY := nextPointY
          }
        }
      }

      ; Go left
      else if (direction == "left") {
        if (nextPointX < currentPointX) {
          if (firstLoop OR candidatePointX < nextPointY) {
            firstLoop := False
            candidateWindow := thisWin
            candidatePointY := nextPointY
          }
        }
      }
    }
  }
  WinActivate, ahk_id %candidateWindow%
}

; Select the top window in a quadrant or side; cycle through the
; section if a window in the section is already selected
; Todo: Is this needed in this implementation?
SelectAndCycle(Zone) {
  WinGet, win, List
  WinGet, CurrentWinId, ID, A
  NewSelected := False
  Loop, %win% {
    this_win := win%A_Index%
    ; Some windows are hidden and get selected. Thus
    ; if and the window has no title, we shouldn't select it.
    WinGetTitle, t, ahk_id %this_win%
    if (t == "")
      continue
    if (CurrentWinId == this_win) {
      ; If there are more than two windows we want the
      ; the one that was found first to get sent to          
      ; the bottom so that we don't just switch between                                          
      ; two windows                                                                              
      ; WinSet, Bottom, , ahk_id %this_win% 
      continue
    }
    ; The list contains all windows, regardless of which desktop they're
    ; on. Therefore we need to check if the window is on the correct desktop
    ; or not (borrowed from desktop_switcher.ahk)
    global CurrentDesktop
    updateGlobalVariables()
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop == 1) {
      WinActivate, ahk_id %this_win%
      NewSelected := True
      Break
    }
  }
  if (!NewSelected)
    WinActivate
}

DesktopIsEmpty() {
  WinGet, wndws, List
  Loop, %wndws% {
    thisWin := wndws%A_Index%
    WinGetTitle, t, ahk_id %thisWin%
    if (t == "")
      continue
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, _GetCurrentDesktopNumber() - 1)
    if (windowIsOnDesktop == 1)
      return False
  }
  return True
}

MoveWindow(deltaX, deltaY) {
  tiledStatus := GetTiledStatus()
  WinGetPos, x, y, , , A
  x := x+deltaX
  y := y+deltaY
  WinMove, A, , x, y
  RemoveWindowFromArray()
  AutoTile()
}

ResizeWindow(deltaW, deltaH) {
  TiledStatus := GetTiledStatus()
  WinGetPos, , , w, h, A
  w := w+deltaW
  h := h+deltaH
  WinMove, A, , x, y, w, h
  RemoveWindowFromArray()
  AutoTile()
}

ToggleMax() {
  WinGet, win, ID, A
  WinGet, status, MinMax, ahk_id %win%
  if (status == -1)
    WinRestore, ahk_id %win%
  else if (status == 0)
    WinMaximize, ahk_id %win%
}

ToggleMin() {
  WinGet, win, ID, A
  WinGet, status, MinMax, ahk_id %win%
  if (status == 1)
    WinRestore, ahk_id %win%
  else if (status == 0)
    WinMinimize, ahk_id %win%
}

;---------------------;
; TILER (THE CREATOR) ;
;---------------------;
TileCurrentWindow(side) {
  WinGet, win, ID, A
  currentDesktopNumber := _GetCurrentDesktopNumber()
  while (RemoveWindowFromArray()) {
  }
  ; For some reason, WinArrange does not work as it should
  ; unless the window ids are repeated
  Array%side%%currentDesktopNumber%.Push(win, win)
  TileWindows()
}

TileWindows() {
  currentDesktopNumber := _GetCurrentDesktopNumber()
  theLeftArray := MakeTheArray(arrayLeft%currentDesktopNumber%)
  if (theLeftArray != "")
    WinArrange(TILE, theLeftArray, HORIZONTAL, LEFT)
  theRightArray := MakeTheArray(arrayRight%currentDesktopNumber%)
  if (theRightArray != "")
    WinArrange(TILE, theRightArray, HORIZONTAL, RIGHT)
}

UntileCurrentWindow() {
  while (RemoveWindowFromArray()) {
  }
  WinMove, A, , 200, 200, 1000, 1000 ; Some cascading thing here?
  AutoTile()
}

RemoveWindowFromArray(win := ""){
  if (Win == "")
    WinGet, Win, ID, A
  currentDesktopNumber := _GetCurrentDesktopNumber()
  found := False
  Loop % arrayLeft%currentDesktopNumber%.Length() {
    if (arrayLeft%currentDesktopNumber%[A_Index] == Win) {
      found := True
      arrayLeft%currentDesktopNumber%.RemoveAt(A_Index)
    }
  }
  Loop % arrayRight%currentDesktopNumber%.Length() {
    if (arrayRight%currentDesktopNumber%[A_Index] == Win) {
      found := True
      arrayRight%currentDesktopNumber%.RemoveAt(A_Index)
    }
  }
  return found
}

MakeTheArray(a){
  theArray := ""
  Loop % a.Length(){
    if (A_Index == a.Length())
      theArray := theArray . a[A_Index]
    else
      theArray := theArray . a[A_Index] . "|"
  }
  return theArray
}

CascadeAll() {
  WinArrange(CASCADE, ALLWINDOWS, VERTICAL, FULLSCREEN)
}

AutoTile() {
  currentDesktopNumber := _GetCurrentDesktopNumber()
  theLeftArray := MakeTheArray(arrayLeft%currentDesktopNumber%)
  theRightArray := MakeTheArray(arrayRight%CurrentDesktopNumber%)
  if (theLeftArray != "")
    WinArrange(TILE, theLeftArray, HORIZONTAL, LEFT)
  if (theRightArray != "")
    WinArrange(TILE, theRightArray, HORIZONTAL, RIGHT)
}

GetTiledStatus(win := "") {
  if (win == "")
    WinGet, Win, ID, A
  
  leftLeft := 0
  leftRight := A_ScreenWidth / 2
  rightLeft := A_ScreenWidth / 2
  rightRight := A_ScreenWidth

  WinGetPos, x,  , w,  , A
  if (x == leftLeft and x+w == leftRight)
    return "Left"
  else if (x == rightLeft and x+w == rightRight)
    return "Right"
  else
    return ""
}

;--------------;
; VISUAL STUFF ;
;--------------;
; Todo: Go through to see if this is needed

RemoveDecoration(id := "") {
  if (id) {
    WinSet, Style, -0xC00000, ahk_id %id% ; Hide title bar
    ; WinSet, Style, -0x200000, ahk_id %id% ; Hide vertical scroll bar
    ; WinSet, Style, -0x100000, ahk_id %id% ; Hide horizontal scroll bar
  }
  else {
    WinSet, Style, -0xC00000, A
    ; WinSet, Style, -0x200000, A
    ; WinSet, Style, -0x100000, A
  }
  ; Sometimes the window dimensions change when removing decoration.
  ; Thus we need to make sure the window gets back to where it started
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

; Merge into one function, where the step and direction is given by
; the argument
IncreaseTransparency() {
  global TrnspStep
  WinGet, trnsp, Transparent, A
  if (!trnsp)
    trnsp := 255
  WinSet, Transparent, % trnsp + TrnspStep, A 
}

DecreaseTransparency() {
  global TrnspStep
  WinGet, trnsp, Transparent, A
  ; If a window has had its transparency modified, then `trnsp`
  ; is not 255 but rather undefined
  if (!trnsp)
    trnsp := 255 - TrnspStep
  WinSet, Transparent, % trnsp - TrnspStep, A 
}

DesktopIncreaseTransparency() {
  WinGet, win, List
  global TrnspStep
  global CurrentDesktop
  updateGlobalVariables()
  Loop, %win% {
    this_win := win%A_Index%
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop == 1) {
      WinGet, trnsp, Transparent, ahk_id %this_win%
      WinSet, Transparent, % trnsp - TrnspStep, ahk_id %this_win%
    }
  }
}
 
DesktopDecreaseTransparency() {
  WinGet, win, List
  global TrnspStep
  global CurrentDesktop
  updateGlobalVariables()
  Loop, %win% {
    this_win := win%A_Index%
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop == 1) {
      WinGet, trnsp, Transparent, ahk_id %this_win%
      if (!trnsp)
          trnsp := 255 - TrnspStep
      WinSet, Transparent, % trnsp + TrnspStep, ahk_id %this_win%
    }
  }
}

;--------------------------------------------------------------------
; Alternative implementation of desktop switching
;--------------------------------------------------------------------
; Todo: Put in a separate file?
_ChangeDesktop(n:=1) {
    if (n == 0) {
        n := 10
    }
    DllCall(GoToDesktopNumberProc, Int, n-1)
}

SwitchToDesktop(n:=1) {
    doFocusAfterNextSwitch=1
    _ChangeDesktop(n)
}

_GetNextDesktopNumber() {
    i := _GetCurrentDesktopNumber()
    i := (i == _GetNumberOfDesktops() ? i : i + 1)
    return i
}

_GetPreviousDesktopNumber() {
    i := _GetCurrentDesktopNumber()
    i := (i == 1 ? i : i - 1)
    return i
}

_GetCurrentDesktopNumber() {
    return DllCall(GetCurrentDesktopNumberProc) + 1
}

_GetNumberOfDesktops() {
    return DllCall(GetDesktopCountProc)
}

; My additions
GoToNextDesktop() {
  CurrentDesktop := _GetCurrentDesktopNumber()
  NumberOfDesktops := _GetNumberOfDesktops()
  if (CurrentDesktop == NumberOfDesktops)
    return
  if (!DesktopIsEmpty())
    WinActivate, ahk_class Shell_TrayWnd
  SwitchToDesktop(_GetNextDesktopNumber())
  if (!DesktopIsEmpty()) {
    SelectAndCycle(0)
    WinActivate
  }
  AutoTile()
}

GoToPrevDesktop() {
  CurrentDesktop := _GetCurrentDesktopNumber()
  if (CurrentDesktop == 1)
    return
  if (!DesktopIsEmpty())
    WinActivate, ahk_class Shell_TrayWnd
  SwitchToDesktop(_GetPreviousDesktopNumber())
  if (!DesktopIsEmpty()) {
    SelectAndCycle(0)
    WinActivate
  }
  AutoTile()
}
