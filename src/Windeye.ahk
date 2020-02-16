; =====================================================================
;  AUTO-EXECUTE 
; =====================================================================

  #SingleInstance Force
  #NoEnv
  #Persistent

  SetWorkingDir %A_ScriptDir%
  SendMode, Input
  SetKeyDelay, -1
  SetBatchLines -1

  ; --------------------------------------------------------------------
  ;  Based on virtual-desktop-accessor and related projects; credits:
  ;  - https://github.com/pmb6tz/windows-desktop-switcher
  ;  - https://github.com/sdias/win-10-virtual-desktop-enhancer
  ;  - https://github.com/Ciantic/VirtualDesktopAccessor
  ; --------------------------------------------------------------------
  
  ; DLL-files are not included in the compiled version unless specified
  ; by FileInstall. It is then easiest if the dll is put in the same
  ; folder as the executable
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

  global theWindowsOnDesktop := Array()

  global edgeMode := false
  
  ; Includes
  #Include %A_ScriptDir%\Gui.ahk
  #Include %A_ScriptDir%\Keybindings.ahk

Return
; ======================================================================
;  AUTO-EXECUTE END
; ======================================================================

; =====================================================================
;  SELECT AND MOVE WINDWOS
; =====================================================================

toggleEdgeMode() {
  edgeMode := !edgeMode
}

getNearestWindowNarrow(direction, id := "") {

  if (!id)
    WinGet, id, ID, A ; Get id of current window
  
  WinGet, win, List ; Get a list of all available windows

  WinGetPos, currentX, currentY, currentWidth, currentHeight, A ; Get position of current window
  currentWindow := {x: currentX, y: currentY, w: currentWidth, h: currentHeight}
  
  ; Some variables to determine which window is closest to
  ; the current window
  candidatePointX := 0
  candidatePointY := 0
  candidateWindow := id
  firstLoop := true
  
  Loop, %win% {

    thisWin := win%A_Index%
    WinGet, mmStatus, MinMax, ahk_id %thisWin% ; Get min/max status of current window. Put in a function?

    ; Skip current window, if its not on current desktop or if
    ; it is minimised or maximised
    if (   windowIsOnDesktop(thisWin) != 1
        || id       == thisWin
        || mmStatus == -1
        || mmStatus == 1   )
      continue

    WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %thisWin% ; Get position of window
    nextWindow := {x: nextX, y: nextY, w: nextWidth, h: nextHeight}

    currentBest := ""

    ; Up
    if (direction == "up") {
      if (nextWindow.y + nextWindow.h <= currentWindow.y
          && windowsOverlap("x", currentWindow, nextWindow)) {
        if (firstLoop || currentBest < nextWindow.y + nextWindow.h) {
          firstLoop       := false
          candidateWindow := thisWin
          currentBest     := nextWindow.y + nextWindow.h
        }
      }
    }

    ; Down
    else if (direction == "down") {
      if (nextWindow.y >= currentWindow.y + currentWindow.h
          && windowsOverlap("x", currentWindow, nextWindow)) {
        if (firstLoop || currentBest > nextWindow.y) {
          firstLoop       := false
          candidateWindow := thisWin
          currentBest     := nextWindow.y
        }
      }
    }
    
    ; Right
    else if (direction == "right") {
      if (nextWindow.x >= currentWindow.x + currentWindow.w
          && windowsOverlap("y", currentWindow, nextWindow)) {
        if (firstLoop || currentBest > nextWindow.x + nextWindow.w) {
          firstLoop       := false
          candidateWindow := thisWin
          currentBest     := nextWindow.x + nextWindow.w
        }
      }
    }

    ; Left
    else if (direction == "left") {
      if (nextWindow.x + nextWindow.w <= currentWindow.x
          && windowsOverlap("y", currentWindow, nextWindow)) {
        if (firstLoop || currentBest < nextWindow.x + nextWindow.w) {
          firstLoop       := false
          candidateWindow := thisWin
          currentBest     := nextWindow.x + nextWindow.w        
        }
      }
    }
  }

  if (candidateWindow != id)
    return candidateWindow
  else
    return ""
}

windowsOverlap(dimension, currentWindow, nextWindow) {
  if (dimension == "y") {
    return (  (   currentWindow.y < nextWindow.y    + nextWindow.h
               && currentWindow.y + currentWindow.h > nextWindow.y)
           || (   nextWindow.y < currentWindow.y + currentWindow.h
               && nextWindow.y + nextWindow.h    > currentWindow.y)  )
  }
  else if (dimension == "x") {
    return (  (   currentWindow.x < nextWindow.x    + nextWindow.w
               && currentWindow.x + currentWindow.w > nextWindow.x)
           || (   nextWindow.x < currentWindow.x + currentWindow.w
               && nextWindow.x + nextWindow.w    > currentWindow.x)  )
  }
  else
    return false
}

getNearestWindowWide(direction) {

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
  firstLoop := true

  Loop, %win% {
    
    thisWin := win%A_Index%
    WinGet, mmStatus, MinMax, ahk_id %thisWin% ; Get min/max status of current window. Put in a function?

    ; Skip current window, if its not on current desktop or if
    ; it is minimised
    if (windowIsOnDesktop(thisWin) != 1
        or id == thisWin
        or mmStatus == -1)
    continue

    WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %thisWin% ; Get position of window

    nextPointX := nextX + nextWidth / 2
    nextPointY := nextY + nextHeight / 2

    ; Up
    if (direction == "up") {
      if (nextPointY < currentPointY) {
        if (firstLoop OR candidatePointY < nextPointY) {
          firstLoop       := false
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }

    ; Down
    else if (direction == "down") {
      if (nextPointY > currentPointY) {
        if (firstLoop OR candidatePointY > nextPointY) {
          firstLoop       := false
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }

    ; Right
    else if (direction == "right") {
      if (nextPointX > currentPointX) {
        if (firstLoop OR candidatePointX > nextPointY) {
          firstLoop       := false
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }

    ; Left
    else if (direction == "left") {
      if (nextPointX < currentPointX) {
        if (firstLoop OR candidatePointX < nextPointY) {
          firstLoop       := false
          candidateWindow := thisWin
          candidatePointY := nextPointY
        }
      }
    }
  }

  if (candidateWindow != id)
    return candidateWindow
  else
    return ""
}

; Can be implemented more efficiently
moveFocus(direction) {
  narrow := getNearestWindowNarrow(direction)
  wide := getNearestWindowWide(direction)
  if (narrow)
    WinActivate, ahk_id %narrow%
  else if (wide)
    WinActivate, ahk_id %wide%
}

selectAndCycle() {
  
  WinGet, listOfAllWindows, List
  windowsOnDesktop := Array()

  ; Create a list of all windows on the current desktop
  Loop, %listOfAllWindows% {
    thisWin := listOfAllWindows%A_Index%
    if (windowIsOnDesktop(thisWin) == 1)
      windowsOnDesktop.Push(thisWin)
  }

  ; Compare this list to our old list
  ; (This solution is needed because, as far as I know, there is no way
  ; of getting or setting the window's "z-value", beyond top or bottom.)
  found := False
  if (theWindowsOnDesktop.Length() == windowsOnDesktop.Length()) {
    Loop, % theWindowsOnDesktop.Length() {
      found := False
      theWindow := theWindowsOnDesktop[A_Index]
      Loop, % windowsOnDesktop.Length() {
        window := windowsOnDesktop[A_Index]
        if (window == theWindow) {
          found := True
          break
        }
      }
      ; If the lists are not the same, then replace
      ; the old list
      if !found {
        theWindowsOnDesktop := windowsOnDesktop
        break
      }
    }
  }
  else
    theWindowsOnDesktop := windowsOnDesktop

  ; Move the first window to the bottom of the list
  ; and activate the window that is next in line
  topWindow := theWindowsOnDesktop.RemoveAt(1)
  theWindowsOnDesktop.Push(topWindow)
  nextWindow := theWindowsOnDesktop[1]
  WinActivate, ahk_id %nextWindow%
}

selectPrevious() {
  WinGet, listOfAllWindows, List
  WinGet, currentWin, ID, A ; Get id of current window
  Loop, %listOfAllWindows% {
    thisWin := listOfAllWindows%A_Index%
    if (currentWin == thisWin)
      continue
    else if (windowIsOnDesktop(thisWin) == 1) {
      WinActivate, ahk_id %thisWin%
      break
    }
  }
}

desktopIsEmpty() {
  WinGet, wndws, List
  Loop, %wndws% {
    thisWin := wndws%A_Index%
    WinGetTitle, t, ahk_id %thisWin%
    if (t == "")
      continue
    windowIsOnDesktop(window)
    if (windowIsOnDesktop == 1)
      return false
  }
  return true
}

moveWindow(deltaX, deltaY) {
  if (isMaximised())
    toggleMax()
  WinGetPos, x, y, , , A
  x := x + deltaX
  y := y + deltaY
  WinMove, A, , x, y
}

resizeWindow(top, bottom, left, right) {
  if (isMaximised())
    toggleMax()
  WinGetPos, x, y, w, h, A
  x := x - left
  w := w + right + left
  y := y - top
  h := h + bottom + top
  WinMove, A, , x, y, w, h
}

getNearestEdge(direction, id := ""){
  if (!id)
    WinGet, id, ID, A
  WinGetPos, x, y, w, h, ahk_id %id%
  nearest := getNearestWindowNarrow(direction)
  if (!nearest)
    return ""
  WinGetPos, edgeX, edgeY, edgeW, edgeH, ahk_id %nearest%
  if (   (direction == "right" && edgeX         == x + w)
      || (direction == "left"  && edgeX + edgeW == x    )
      || (direction == "up"    && edgeY + edgeH == y    )
      || (direction == "down"  && edgeY         == y + h) )
    getNearestEdge(direction, nearest)
  else
    return nearest
}

moveToEdge(direction) {
  
  if (isMaximised())
    toggleMax()
  
  nearest := getNearestEdge(direction)
  if (!nearest) 
    useDesktopEdges := True
  
  WinGetPos, x, y, w, h, A
  
  if (direction == "right") {
    if (useDesktopEdges)
      edgeX := A_ScreenWidth
    else
      WinGetPos, edgeX, , , , ahk_id %nearest%
    WinMove, A, , edgeX - w
  }
  else if (direction == "left") {
    if (useDesktopEdges)
      edgeX := 0, edgeW := 0
    else
      WinGetPos, edgeX, , edgeW, , ahk_id %nearest%
    WinMove, A, , edgeX + edgeW
  }
  else if (direction == "up") {
    if (useDesktopEdges)
      edgeY := 0, edgeH := 0
    else
      WinGetPos, , edgeY, , edgeH, ahk_id %nearest%
    WinMove, A, , , edgeY + edgeH
  }
  else if (direction == "down") {
    if (useDesktopEdges)
      edgeY := A_ScreenHeight
    else
      WinGetPos, , edgeY, , , ahk_id %nearest%
    WinMove, A, , , edgeY - h
  }
}

resizeToEdge(direction) {
  
  if (isMaximised())
    toggleMax()

  nearest := getNearestEdge(direction)
  if (!nearest) 
    useDesktopEdges := True
  
  WinGetPos, x, y, w, h, A
  
  if (direction == "right") {
    if (useDesktopEdges)
      edgeX := A_ScreenWidth
    else
      WinGetPos, edgeX, , , , ahk_id %nearest%
    WinMove, A, , , , edgeX - x
  }
  else if (direction == "left") {
    if (useDesktopEdges)
      edgeX := 0, edgeW := 0
    else
      WinGetPos, edgeX, , edgeW, , ahk_id %nearest%
    WinMove, A, , edgeX + edgeW, , w + x - edgeX - edgeW
  }
  else if (direction == "up") {
    if (useDesktopEdges)
      edgeY := 0, edgeH := 0
    else
      WinGetPos, , edgeY, , edgeH, ahk_id %nearest%
    WinMove, A, , , edgeY + edgeH, , h + y - edgeY - edgeH
  }
  else if (direction == "down") {
    if (useDesktopEdges)
      edgeY := A_ScreenHeight
    else
      WinGetPos, , edgeY, , , ahk_id %nearest%
    WinMove, A, , , , , edgeY - y
  }
}

isMaximised() {
  WinGet, status, MinMax, A
  return status == 1
}

toggleMax() {
  WinGet, win, ID, A
  if (isMaximised())
    WinRestore, ahk_id %win%
  else
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

; =====================================================================
;  DESKTOP SWITCHING ETC.
; =====================================================================
changeDesktop(n := 1) {
  if (n == 0)
    n := 10
  DllCall(GoToDesktopNumberProc, Int, n - 1)
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
  changeDesktop(getNextDesktopNumber())
  if (!desktopIsEmpty()) {
    selectAndCycle()
  }
}

goToPrevDesktop() {
  currentDesktop := getCurrentDesktopNumber()
  if (CurrentDesktop == 1)
    return
  if (!desktopIsEmpty())
    WinActivate, ahk_class Shell_TrayWnd
  changeDesktop(GetPreviousDesktopNumber())
  if (!desktopIsEmpty()) {
    selectAndCycle()
  }
}

moveCurrentWindowToNextDesktop(){
  WinGet, winId, ID, A
  DllCall(MoveWindowToDesktopNumberProc, UInt, winId, UInt, getCurrentDesktopNumber())
  goToNextDesktop()
  WinMove, ahk_id %winId%, , 100, 100
}


moveCurrentWindowToPreviousDesktop(){
  WinGet, winId, ID, A
  DllCall(MoveWindowToDesktopNumberProc, UInt, winId, UInt, getCurrentDesktopNumber()-2)
  goToPrevDesktop()
  WinMove, ahk_id %winId%, , 100, 100
}

windowIsOnDesktop(window){
  return DllCall(IsWindowOnDesktopNumberProc, UInt, Window, UInt, getCurrentDesktopNumber() - 1)
}

; =====================================================================
;  GENERAL THINGS
; =====================================================================
closeWindow() {
  WinClose, A
}

reloadScript() {
  Reload
}
