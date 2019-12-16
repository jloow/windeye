;--------------;
; Auto execute ;
;--------------;

  #SingleInstance Force
  #NoEnv
  #Persistent
  SetWorkingDir %A_ScriptDir%
  SendMode, Input
  SetKeyDelay, -1
  SetBatchLines -1

  ;--------------------------------------------------------------------
  ; VirtualDesktopAccessor, credits:
  ; - https://github.com/pmb6tz/windows-desktop-switcher
  ; - https://github.com/sdias/win-10-virtual-desktop-enhancer
  ; - https://github.com/Ciantic/VirtualDesktopAccessor
  ;--------------------------------------------------------------------
  if (A_IsCompiled == 1) {
    if !FileExist("VirtualDesktopAccessor.dll")
      FileInstall, ..\lib\VirtualDesktopAccessor.dll, %A_WorkingDir%\VirtualDesktopAccessor.dll
    hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", "VirtualDesktopAccessor.dll", "Ptr")
  }
  else
    hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", A_ScriptDir . "\..\lib\VirtualDesktopAccessor.dll", "Ptr")
  global GoToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GoToDesktopNumber", "Ptr")
  global GetCurrentDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetCurrentDesktopNumber", "Ptr")
  global GetDesktopCountProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "GetDesktopCount", "Ptr")
  global MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "MoveWindowToDesktopNumber", "Ptr")
  global IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", Ptr, hVirtualDesktopAccessor, AStr, "IsWindowOnDesktopNumber", "Ptr")

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
  ; ALLWINDOWS (Param 2), ARRAYORDER (Param 3), FULLSCREEN (Param 4) 
  ; are undeclared variables simulating NULL content.
  ;--------------------------------------------------------------------

  ; Initially split the screen in two
  global Left1  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left2  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left3  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left4  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left5  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left6  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left7  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left8  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Left9  := "0|0|" . A_ScreenWidth / 2 . "|" . A_ScreenHeight
  global Right1 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right2 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right3 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right4 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right5 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right6 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right7 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right8 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  global Right9 := A_ScreenWidth / 2 . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight

  ; Arrays for tiled windows. Support 9 virtual desktops
  global arrayLeft1  := Array()
  global arrayLeft2  := Array()
  global arrayLeft3  := Array()
  global arrayLeft4  := Array()
  global arrayLeft5  := Array()
  global arrayLeft6  := Array()
  global arrayLeft7  := Array()
  global arrayLeft8  := Array()
  global arrayLeft9  := Array()
  global arrayRight1 := Array() 
  global arrayRight2 := Array()
  global arrayRight3 := Array() 
  global arrayRight4 := Array() 
  global arrayRight5 := Array() 
  global arrayRight6 := Array() 
  global arrayRight7 := Array() 
  global arrayRight8 := Array() 
  global arrayRight9 := Array() 

  cascadeAll()

  ; Includes
  #Include %A_ScriptDir%\Keybindings.ahk
  #Include %A_ScriptDir%\..\lib\WinArrange.ahk

Return

;-------------------------;
; SELECT AND MOVE WINDWOS ;
;-------------------------;

moveFocus(direction) {

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
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, GetCurrentDesktopNumber() - 1)
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
      windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, GetCurrentDesktopNumber() - 1)
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
selectAndCycle(Zone) {
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
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, GetCurrentDesktopNumber() - 1)
    if (windowIsOnDesktop == 1) {
      WinActivate, ahk_id %this_win%
      NewSelected := True
      Break
    }
  }
  if (!NewSelected)
    WinActivate
}

desktopIsEmpty() {
  WinGet, wndws, List
  Loop, %wndws% {
    thisWin := wndws%A_Index%
    WinGetTitle, t, ahk_id %thisWin%
    if (t == "")
      continue
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, thisWin, UInt, GetCurrentDesktopNumber() - 1)
    if (windowIsOnDesktop == 1)
      return False
  }
  return True
}

moveWindow(deltaX, deltaY) {
  tiledStatus := getTiledStatus()
  WinGetPos, x, y, , , A
  x := x+deltaX
  y := y+deltaY
  WinMove, A, , x, y
  removeWindowFromArray()
  autoTile()
}

resizeWindow(deltaW, deltaH) {
  TiledStatus := getTiledStatus()
  WinGetPos, , , w, h, A
  w := w+deltaW
  h := h+deltaH
  WinMove, A, , x, y, w, h
  removeWindowFromArray()
  autoTile()
}

toggleMax() {
  WinGet, win, ID, A
  WinGet, status, MinMax, ahk_id %win%
  if (status == -1)
    WinRestore, ahk_id %win%
  else if (status == 0)
    WinMaximize, ahk_id %win%
}

toggleMin() {
  WinGet, win, ID, A
  WinGet, status, MinMax, ahk_id %win%
  if (status == 1)
    WinRestore, ahk_id %win%
  else if (status == 0)
    WinMinimize, ahk_id %win%
}

;-------;
; TILER ;
;-------;
tileCurrentWindow(side) {
  WinGet, win, ID, A
  currentDesktopNumber := getCurrentDesktopNumber()
  while (removeWindowFromArray()) {
  }
  ; For some reason, WinArrange does not work as it should
  ; unless the window ids are repeated
  Array%side%%currentDesktopNumber%.push(win, win)
  tileWindows()
}

tileWindows() {
  currentDesktopNumber := getCurrentDesktopNumber()
  theLeftArray := makeTheArray(arrayLeft%currentDesktopNumber%)
  if (theLeftArray != "")
    WinArrange(TILE, theLeftArray, HORIZONTAL, Left%currentDesktopNumber%)
  theRightArray := makeTheArray(arrayRight%currentDesktopNumber%)
  if (theRightArray != "")
    WinArrange(TILE, theRightArray, HORIZONTAL, Right%currentDesktopNumber%)
}

untileCurrentWindow() {
  while (removeWindowFromArray()) {
  }
  WinMove, A, , 200, 200, 1000, 1000 ; Some cascading thing here?
  autoTile()
}

removeWindowFromArray(win := ""){
  if (win == "")
    WinGet, win, ID, A
  currentDesktopNumber := getCurrentDesktopNumber()
  found := False
  Loop % arrayLeft%currentDesktopNumber%.Length() {
    if (arrayLeft%currentDesktopNumber%[A_Index] == win) {
      found := True
      arrayLeft%currentDesktopNumber%.RemoveAt(A_Index)
    }
  }
  Loop % arrayRight%currentDesktopNumber%.Length() {
    if (arrayRight%currentDesktopNumber%[A_Index] == win) {
      found := True
      arrayRight%currentDesktopNumber%.RemoveAt(A_Index)
    }
  }
  return found
}

makeTheArray(a){
  theArray := ""
  Loop % a.Length(){
    if (A_Index == a.Length())
      theArray := theArray . a[A_Index]
    else
      theArray := theArray . a[A_Index] . "|"
  }
  return theArray
}

cascadeAll() {
  WinArrange(CASCADE, ALLWINDOWS, VERTICAL, FULLSCREEN)
}

cascadeCurrentDesktop() {
  WinGet, Win, List
  CurrentDesktop := getCurrentDesktopNumber()
  TheWindows := Array()
  Loop, %Win% {
    ThisWin := Win%A_Index%
    if (windowIsOnDesktop(ThisWin) == 1)
      TheWindows.push(ThisWin, ThisWin)
  }
  TheArray := makeTheArray(TheWindows)
  WinArrange(CASCADE, TheArray, VERTICAL, FULLSCREEN)
}

autoTile() {
  currentDesktopNumber := getCurrentDesktopNumber()
  theLeftArray := makeTheArray(arrayLeft%currentDesktopNumber%)
  theRightArray := makeTheArray(arrayRight%CurrentDesktopNumber%)
  if (theLeftArray != "")
    WinArrange(TILE, theLeftArray, HORIZONTAL, left%currentDesktopNumber%)
  if (theRightArray != "")
    WinArrange(TILE, theRightArray, HORIZONTAL, right%currentDesktopNumber%)
}

getTiledStatus(win := "") {
  if (win == "")
    WinGet, win, ID, A
  
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

modifyWidth(delta) {
  currentDesktop := getCurrentDesktopNumber()
  left := left%CurrentDesktop%
  divide := ""
  Loop, Parse, left, |
    if (A_Index == 3)
      divide := A_LoopField + delta
  left%currentDesktop% := "0|0|" . divide . "|" . A_ScreenHeight
  right%currentDesktop% := divide . "|0|" . A_ScreenWidth . "|" . A_ScreenHeight
  tileWindows()
}

;--------------------------------------------------------------------
; Alternative implementation of desktop switching
;--------------------------------------------------------------------
; Todo: Put in a separate file?
changeDesktop(n:=1) {
    if (n == 0) {
        n := 10
    }
    DllCall(GoToDesktopNumberProc, Int, n-1)
}

switchToDesktop(n:=1) {
    doFocusAfterNextSwitch=1
    changeDesktop(n)
}

getNextDesktopNumber() {
    i := getCurrentDesktopNumber()
    i := (i == getNumberOfDesktops() ? i : i + 1)
    return i
}

getPreviousDesktopNumber() {
    i := getCurrentDesktopNumber()
    i := (i == 1 ? i : i - 1)
    return i
}

getCurrentDesktopNumber() {
    return DllCall(GetCurrentDesktopNumberProc) + 1
}

getNumberOfDesktops() {
    return DllCall(GetDesktopCountProc)
}

; My additions
goToNextDesktop() {
  currentDesktop := getCurrentDesktopNumber()
  numberOfDesktops := getNumberOfDesktops()
  if (currentDesktop == numberOfDesktops)
    return
  if (!desktopIsEmpty())
    WinActivate, ahk_class Shell_TrayWnd
  switchToDesktop(getNextDesktopNumber())
  if (!desktopIsEmpty()) {
    selectAndCycle(0)
    WinActivate
  }
  autoTile()
}

goToPrevDesktop() {
  CurrentDesktop := getCurrentDesktopNumber()
  if (CurrentDesktop == 1)
    return
  if (!desktopIsEmpty())
    WinActivate, ahk_class Shell_TrayWnd
  switchToDesktop(GetPreviousDesktopNumber())
  if (!desktopIsEmpty()) {
    selectAndCycle(0)
    WinActivate
  }
  autoTile()
}

moveCurrentWindowToNextDesktop(){
  WinGet, winId, ID, A
  DllCall(MoveWindowToDesktopNumberProc, UInt, winId, UInt, GetCurrentDesktopNumber())
}


moveCurrentWindowToPreviousDesktop(){
  WinGet, winId, ID, A
  DllCall(MoveWindowToDesktopNumberProc, UInt, winId, UInt, GetCurrentDesktopNumber()-2)
}

windowIsOnDesktop(Window){
  return DllCall(IsWindowOnDesktopNumberProc, UInt, Window, UInt, GetCurrentDesktopNumber() - 1)
}
