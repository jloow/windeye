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

getNearestEdge(searchDirection, searchFrom := "middle", id := "", returnWhat := "id", oneEdge := false) {

  if (!id)
    WinGet, id, ID, A
  
  WinGet, win, List ; Get a list of all available windows

  WinGetPos, currentX, currentY, currentWidth, currentHeight, A ; Get position of current window
  current := {x: currentX, y: currentY, w: currentWidth, h: currentHeight}
  
  best := {point: ((searchDirection == "east" || searchDirection == "south") ? 9999 : 0), id: ""}

  if (searchFrom == "left")
    point := current.x
  else if (searchFrom == "right")
    point := current.x + current.w
  else if (searchFrom == "top")
    point := current.y
  else if (searchFrom == "bottom")
    point := current.y + current.h
  else if (searchFrom == "middle") {
    if (searchDirection == "west" || searchDirection == "east")
      point := (current.x*2 + current.w) / 2
    else if (searchDirection == "north" || searchDirection == "south")
      point := (current.y*2 + current.h) / 2
  }
  else
    return ""
  
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
    next := {x: nextX, y: nextY, w: nextWidth, h: nextHeight}

    left   := next.x
    right  := next.x + next.w
    top    := next.y
    bottom := next.y + next.h
      
    if (searchDirection == "west") {
      if (!windowsOverlap("y", current, next))
        continue
      if (point > right && best.point < right) {
        best.point := right
        best.id    := thisWin
      }
      else if (point > left && best.point < left && !oneEdge) {
        best.point := left
        best.id    := thisWin
      }
    }
    
    else if (searchDirection == "east") {
      if (!windowsOverlap("y", current, next))
        continue
      ; MsgBox % "Current x: " . current.x . "`nCurrent y: " . current.y . "`nPoint: " . point . "`nLeft: " . left . "`nRight: " . right
      if (point < left && best.point > left) {
        best.point := left
        best.id    := thisWin
      }
      else if (point < right && best.point > right && !oneEdge) {
        best.point := right
        best.id    := thisWin
      }
    }

    else if (searchDirection == "north") {
      if (!windowsOverlap("x", current, next))
        continue
      if (point > bottom && best.point < bottom) {
        best.point := bottom
        best.id    := thisWin
      }
      else if (point > top && best.point < top && !oneEdge) {
        best.point := top
        best.id    := thisWin
      }
    }
    
    else if (searchDirection == "south") {
      if (!windowsOverlap("x", current, next))
        continue
      if (point < top && best.point > top) {
        best.point := top
        best.id    := thisWin
      }
      else if (point < bottom && best.point > bottom && !oneEdge) {
        best.point := bottom
        best.id    := thisWin
      }
    }
  }

  if (best.id) {
    if (returnWhat == "id")
      return best.id
    else if (returnWhat == "edge")
      return best.point
    else
      return ""
  }
  else
    return ""
}

windowsOverlap(dimension, currentWindow, nextWindow) {
  if (dimension == "y") {
    return (  (   currentWindow.y <= nextWindow.y    + nextWindow.h
               && currentWindow.y + currentWindow.h >= nextWindow.y)
           || (   nextWindow.y <= currentWindow.y + currentWindow.h
               && nextWindow.y + nextWindow.h    >= currentWindow.y)  )
  }
  else if (dimension == "x") {
    return (  (   currentWindow.x <= nextWindow.x    + nextWindow.w
               && currentWindow.x + currentWindow.w >= nextWindow.x)
           || (   nextWindow.x <= currentWindow.x + currentWindow.w
               && nextWindow.x + nextWindow.w    >= currentWindow.x)  )
  }
  else
    return false
}

isContainedByTargetWindow(targetWindow, currentWindow := "") {
  if (!currentWindow)
    WinGet, currentWindow, ID, A
  WinGetPos, tx, ty, tw, th, ahk_id %targetWindow%
  WinGetPos, cx, cy, cw, ch, ahk_id %currentWindow%
  ; Is the upper left corner contained?
  upperLeft  := cx >= tx      && cx <= tx + tw      && cy >= ty && cy <= ty + th
  ; Is the upper right corner contained?
  upperRight := cx + cw >= tx && cx + cw <= tx + tw && cy >= ty && cy <= ty + th
  ; Is the lower left corner contained?
  lowerLeft  := cx >= tx      && cx <= tx + tw      && cy + ch >= ty && cy + ch <= ty + th
  ; Is the lower right corner contained?
  lowerRight := cx + cw >= tx && cx + cw <= tx + tw && cy + ch >= ty && cy + ch <= ty + th
  return (upperLeft || upperRight || lowerLeft || lowerRight)
}

moveFocus(searchDirection, searchFrom) {
  next := getNearestEdge(searchDirection, searchFrom, , , true)
  if next
    WinActivate, ahk_id %next%
  else
    selectAndCycle()
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
  WinGet, currentWin, ID, A
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

moveToEdge(searchDirection, searchFrom) {
  
  if (isMaximised())
    toggleMax()
  
  next := getNearestEdge(searchDirection, searchFrom, , "edge")
  if !next {
    if (searchDirection == "west" || searchDirection == "north")
      next := 0
    else if (searchDirection == "east")
      next := A_ScreenWidth
    else if (searchDirection == "south")
      next := A_ScreenHeight
  }
  
  WinGetPos, x, y, w, h, A
  
  if (searchDirection == "east") {
    WinMove, A, , next - w
  }
  else if (searchDirection == "west") {
    WinMove, A, , next
  }
  else if (searchDirection == "north") {
    WinMove, A, , , next
  }
  else if (searchDirection == "south") {
    WinMove, A, , , next - h
  }
}

resizeToEdge(searchDirection, searchFrom, how := "grow") {
  
  if (isMaximised())
    toggleMax()

  next := getNearestEdge(searchDirection, searchFrom, , "edge")
  if !next {
    if (searchDirection == "west" || searchDirection == "north")
      next := 0
    else if (searchDirection == "east")
      next := A_ScreenWidth
    else if (searchDirection == "south")
      next := A_ScreenHeight
  }
  
  WinGetPos, x, y, w, h, A
  
  if (searchDirection == "east") {
    if (how == "shrink")
      WinMove, A, , next, , w + x - next
    else
      WinMove, A, , x, , next - x
  }
  else if (searchDirection == "west") {
    if (how == "shrink")
      WinMove, A, , x, , next - x
    else
      WinMove, A, , next, , w + x - next
  }
  else if (searchDirection == "north") {
    if (how == "shrink")
      WinMove, A, , , , , next - y
    else
      WinMove, A, , , next, , h + y - next
  }
  else if (searchDirection == "south") {
    if (how == "how")
      WinMove, A, , , next, , h + y - next
    else
      WinMove, A, , , , , next - y
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
}


moveCurrentWindowToPreviousDesktop(){
  WinGet, winId, ID, A
  DllCall(MoveWindowToDesktopNumberProc, UInt, winId, UInt, getCurrentDesktopNumber()-2)
  goToPrevDesktop()
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
