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
  SetKeyDelay, -1 ; Todo: Experiment to find a good value
  SetBatchLines -1 ; Todo: experiment with this value

  KeyboardHelpActive := False

  ; Because the positions of the tiled windows do not always rounded
  ; to e.g. exactly half of the monitor resolution (it happens that a
  ; top-tiled windows has an x-coordinate of -4, for example) we must
  ; define an area in which a window is considered tiled, even if it
  ; is not. This is the `Grace` variable
  Grace = 20

  ; The amount of which to change transparency
  TrnspStep = 10

  ; Gridster-stuff
  Padding := 14
  Layout := 22

  ; Automaticaly generate arrays for nine zones
  Loop, 9 {
    Zone%A_Index% := { X: -1, Y: -1, W: -1, H: -1, IsActive: False, HasWindow: False }
  }

  Loop, 3 {
    SuperZone%A_Index% := { Start: -1, End: -1, IsActive: False }
  }

  GenerateGrid()

  #Include %A_ScriptDir%\desktop_switcher.ahk
  #Include %A_ScriptDir%\keybindings.ahk
  #Include %A_ScriptDir%\langhelper.ahk
  ;#Include %A_ScriptDir%\applications.ahk

Return

KeyboardHelp() {
  global KeyboardHelpActive
  if (KeyboardHelpActive) {
    SplashImage, Off
    KeyboardHelpActive := False
  }
  else if (!KeyboardHelpActive) {
    SplashImage, keyboard.gif, B
    KeyboardHelpActive := True
  }
}

;-------------------------;
; SELECT AND MOVE WINDWOS ;
;-------------------------;

Move(direction) {
  
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
  
  global CurrentDesktop
  updateGlobalVariables()

  ; First we try to make a narrow selection
  Loop, %win% {
    this_win := win%A_Index%

    ; Correct desktop?
    windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
    if (windowIsOnDesktop != 1)
      continue

    ; Skip current window
    if (id == this_win)
      continue
    
    WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %this_win% ; Get position of window

    nextPointX := nextX + nextWidth / 2
    nextPointY := nextY + nextHeight / 2

    ; Go up
    if (direction == "up") {
      if (nextPointY < currentPointY AND nextPointX > currentX AND nextPointX < currentX + currentWidth) {
        if (firstLoop OR candidatePointY < nextPointY) {
          firstLoop := False
          candidateWindow := this_win
          candidatePointY := nextPointY
        }
      }
    }

    ; Go down
    else if (direction == "down") {
      if (nextPointY > currentPointY AND nextPointX > currentX AND nextPointX < currentX + currentWidth) {
        if (firstLoop OR candidatePointY > nextPointY) {
          firstLoop := False
          candidateWindow := this_win
          candidatePointY := nextPointY
        }
      }
    }

    ; Go right
    else if (direction == "right") {
      if (nextPointX > currentPointX AND nextPointY > currentY AND nextPointY < currentY + currentHeight) {
        if (firstLoop OR candidatePointX > nextPointX) {
          firstLoop := False
          candidateWindow := this_win
          candidatePointX := nextPointX
        }
      }
    }

    ; Go left
    else if (direction == "left") {
      if (nextPointX < currentPointX AND nextPointY > currentY AND nextPointY < currentY + currentHeight) {
        if (firstLoop OR candidatePointX < nextPointX) {
          firstLoop := False
          candidateWindow := this_win
          candidatePointX := nextPointX
        }
      }
    }
  }

  ; Lastly we are very loose with the criteria
  if (candidateWindow == id) {
    firstLoop := True
    Loop, %win% {
      this_win := win%A_Index%

      ; Correct desktop?
      windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
      if (windowIsOnDesktop != 1)
        continue

      ; Skip current window
      if (id == this_win)
        continue
      
      WinGetPos, nextX, nextY, nextWidth, nextHeight, ahk_id %this_win% ; Get position of window

      nextPointX := nextX + nextWidth / 2
      nextPointY := nextY + nextHeight / 2

      ; Go up
      if (direction == "up") {
        if (nextPointY < currentPointY) {
          if (firstLoop OR candidatePointY < nextPointY) {
            firstLoop := False
            candidateWindow := this_win
            candidatePointY := nextPointY
          }
        }
      }

      ; Go down
      else if (direction == "down") {
        if (nextPointY > currentPointY) {
          if (firstLoop OR candidatePointY > nextPointY) {
            firstLoop := False
            candidateWindow := this_win
            candidatePointY := nextPointY
          }
        }
      }

      ; Go right
      else if (direction == "right") {
        if (nextPointX > currentPointX) {
          if (firstLoop OR candidatePointX > nextPointY) {
            firstLoop := False
            candidateWindow := this_win
            candidatePointY := nextPointY
          }
        }
      }

      ; Go left
      else if (direction == "left") {
        if (nextPointX < currentPointX) {
          if (firstLoop OR candidatePointX < nextPointY) {
            firstLoop := False
            candidateWindow := this_win
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
SelectAndCycle(Zone) {
  WinGet, win, List
  WinGet, CurrentWinId, ID, A
  Loop, %win% {
    this_win := win%A_Index%
    ; Some windows are hidden and get selected. Thus
    ; if and the window has no title, we shouldn't select it.
    WinGetTitle, t, ahk_id %this_win%
    if (t == "")
      continue
    if (WinInZone(this_win) == Zone) {
      if (CurrentWinId == this_win) {
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
      updateGlobalVariables()
      windowIsOnDesktop := DllCall(IsWindowOnDesktopNumberProc, UInt, this_win, UInt, CurrentDesktop - 1)
      if (windowIsOnDesktop == 1) {
        WinActivate, ahk_id %this_win%
        OutputDebug, I'm returning true
        return True
      }
    }
  }
  WinActivate
  return False
}

MoveWindow(deltaX, deltaY) {
  WinGetPos, X, Y, , , A
  X := X+deltaX
  Y := Y+deltaY
  WinMove, A, , X, Y
}

ResizeWindow(deltaW, deltaH) {
  WinGetPos, , , W, H, A
  W := W+deltaW
  H := H+deltaH
  WinMove, A, , X, Y, W, H
}

;----------;
; GRIDSTER ;
;----------;

MoveToZone(Nr) {
  global Zone1, Zone2, Zone3, Zone4, Zone5, Zone6, Zone7, Zone8, Zone9
  Zone := Zone%Nr%
  if (Zone.IsActive) {
    WinMove, A, , Zone.X, Zone.Y, Zone.W, Zone.H
    return True
  }
  return False
}

MoveToNextZone() {
  WinGet, Id, ID, A
  Zone := WinInZone(Id)
  Zone := Zone == 9 ? 1 : Zone + 1
  while (!MoveToZone(Zone))
    Zone := Zone == 9 ? 1 : Zone + 1
}

FocusNextZone() {
  WinGet, Id, ID, A
  CurrentZone := WinInZone(Id)
  Zone := CurrentZone == 9 ? 1 : CurrentZone + 1
  OutputDebug, I'm trying to focus windows %Zone% (current zone is %CurrentZone%)
  while (!SelectAndCycle(Zone)) {
    OutputDebug, I'm trying to focus windows %Zone%
    Zone := Zone == 9 ? 1 : Zone + 1
  }
}

WinInZone(Id) {
  global Zone1, Zone2, Zone3, Zone4, Zone5, Zone6, Zone7, Zone8, Zone9
  WinGetPos, X, Y, W, H, ahk_id %Id%
  Loop, 9 {
    if (X == Zone%A_Index%.X
        and Y == Zone%A_Index%.Y
        and W == Zone%A_Index%.W
        and H == Zone%A_Index%.H) {
      OutputDebug, This window is in zone %A_Index%
      return A_Index
    }
  }
  return 0
}

SetLayout() {
  ResetZones()
  ResetSuperZones()
  global Layout
  OutputDebug, I'm asking the user to specify the layout

  ; Promt the user for layout
  Input, UsrInput, B I L3 T5, {Enter}{Space}

  ; Check if input is numeric (Abs returns an empty string if it
  ; is not
  ;if (Abs == "") {
  ;  OutputDebug, The user didn't enter only numbers
  ;  return
  ;}
  ; We don't accept more than 4 vertical zones
  if (UsrInput > 44 AND UsrInput < 100) {
    OutputDebug, I changed the layout to 44 (was %UsrInput%)
    Layout := 44
  }
  else if (UsrInput > 333) {
    OutputDebug, I changed the layout to 333 (was %UsrInput%)
    Layout := 333
  }
  else {
    Layout := UsrInput
    OutputDebug, Layout is now %Layout%
  }
  GenerateGrid()
  DrawZones()
}

GenerateGrid() {
  global SuperZone1, SuperZone2, SuperZone3
  global Zone1, Zone2, Zone3, Zone4, Zone5, Zone6, Zone7, Zone8, Zone9
  global Padding
  SysGet, Mon, MonitorWorkArea
  OutputDebug, I'm trying to generate some super zones
  ; Generate super zones
  ; TODO: Do this programmatically
  if (GetNumberZonesHor() == 2){
    SuperZone1.Start := MonLeft
    SuperZone1.End := MonRight / 2
    SuperZone1.IsActive := True
    SuperZone3.Start := MonRight / 2 + 1
    SuperZone3.End := MonRight
    SuperZone3.IsActive := True
  }
  else {
    SuperZone1.Start := MonLeft
    SuperZone1.End := MonRight / 3
    SuperZone2.Start := MonRight / 3 + 1
    SuperZone2.End := MonRight * (2 / 3)
    SuperZone3.Start := MonRight * (2 / 3) + 1
    SuperZone3.End := MonRight
    SuperZone1.IsActive := True
    SuperZone2.IsActive := True
    SuperZone3.IsActive := True
  } 
  OutputDebug, I'm trying to generate zones inside the super zones
  ; Generate zones inside each super zone
  LastZone := 0
  Loop, 3 {
    if (!SuperZone2.IsActive AND A_Index == 2)
      continue
    SprZone := A_Index
    NrVert := GetNumberZonesVer(SprZone)
    OutputDebug, I will try to create %NrVert% zones in super zone %SprZone%
    Nr := 0
    Loop, %NrVert% {
      Nr := A_Index + LastZone
      Zone%Nr%.X := SuperZone%SprZone%.Start + Padding
      Zone%Nr%.W := SuperZone%SprZone%.End - SuperZone%SprZone%.Start - Padding
      Zone%Nr%.Y := MonBottom * ((A_Index - 1) / NrVert) + Padding
      Zone%Nr%.H := MonBottom / NrVert - Padding
      Zone%Nr%.IsActive := True
      OutputDebug % "Zone" . Nr . " has the following values:"
      OutputDebug % "X: " . Zone%Nr%.X
      OutputDebug % "W: " . Zone%Nr%.W
      OutputDebug % "Y: " . Zone%Nr%.Y
      OutputDebug % "H: " . Zone%Nr%.H
    }
    LastZone := Nr
    OutputDebug, LastZone is now %LastZone%
  }
}

DrawZones() {
  global Zone1, Zone2, Zone3, Zone4, Zone5, Zone6, Zone7, Zone8, Zone9
  Loop, 9 {
    X := Zone%A_Index%.X
    Y := Zone%A_Index%.Y
    H := Zone%A_Index%.H
    W := Zone%A_Index%.W
    SplashImage, %A_Index%: , B1 H%H% W%W% X%X% Y%Y%, %A_Index%
  }
  Sleep, 1000
  Loop, 9
    SplashImage, %A_Index%:Off
}

ResetZones() {
  global Zone1, Zone2, Zone3, Zone4, Zone5, Zone6, Zone7, Zone8, Zone9
  Loop, 9 {
    Zone%A_Index%.X := -1
    Zone%A_Index%.Y := -1
    Zone%A_Index%.W := -1
    Zone%A_Index%.H := -1
    Zone%A_Index%.IsActive := False
    Zone%A_Index%.HasWindow := False
  }
}

ResetSuperZones() {
  global SuperZone1, SuperZone2, SuperZone3
  Loop, 3 {
    SuperZone%A_Index%.Start := -1
    SuperZone%A_Index%.End := -1
    SuperZone%A_Index%.IsActive := False
  }
}

GetNumberZonesHor() {
  global Layout
  if (Layout == -1)
    return -1
  else if (Layout < 100) 
    return 2
  else
    return 3
}

; Get the number of zones that are to fit vertically in a given super
; zone
GetNumberZonesVer(SuperZone) {
  global Layout
  if (SuperZone == 2)
    return SubStr(Layout, 2, 1)
  else if (SuperZone == 3)
    return SubStr(Layout, 0)
  else if (SuperZone == 1)
    return SubStr(Layout, 1, 1)
}

;--------------;
; VISUAL STUFF ;
;--------------;

RemoveDecoration(id := "") {
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
