; Layout takes on a value between -1 and 333 (at the moment, as there
; initially is only support for 9 zones). In the first instance, 
; however, only number up to 44 are considered. The 10s represent the
; left-most "super zone", while the single digits represent the right-
; most one. Only when layout >= 100 does the 100s represent the left-
; most super zone and the 10s the middle. -1 means there will only be
; large zone.

Padding := 20
Layout := -1

; Automaticaly generate arrays for nine zones
Loop, 9 {
  Zone%A_Index% := {
    X: -1,
    Y: -1,
    W: -1,
    H: -1,
    IsActive: False,
    HasWindow: False
  }
}

Loop, 3 {
  SuperZone%A_Index% := {
    Start: -1,
    End: -1,
    IsActive: False,
  }
}

SetLayout() {
  global Layout
  OutputDebug, I'm asking the user to specify the layout

  ; Promt the user for layout
  Inpur, UsrInput, BIL3T5, {Enter}{Space}

  ; Check if input is numeric (Abs returns an empty string if it
  ; is not
  if (Abs == "") {
    OutputDebug, The user didn't enter only numbers
    return
  }
  ; We don't accept more than 4 vertical zones
  if (UsrInput > 44 AND UsrInput < 100) {
    OutputDebug, I changed the layout to 44 (was %UsrInput%)
    Layout := 44
  }
  else {
    Layout := UsrInput
    OutputDebug, Layout is now%Layout%
  }
}

GenerateGrid() {
  SysGet, Mon, Monitor
  OutputDebug, I'm trying to generate some super zones
  ; Generate super zones
  if (GetNumberZonesHor() == 2){
    SuperZone1.Start := MonLeft
    SuperZone1.End := MonRight / 2
    SuperZone1.IsActive := True
    SuperZone3.Start := MonRight / 2 + 1
    SuperZone3.End := MonRight
    SuperZone3.IsActive := True
    SuperZone2.IsActive := False
  }
  else {
    SuperZone1.Start := MonLeft
    SuperZone1.End := MonRight / 3
    SuperZone2.Start := MonRight / 3 + 1
    SuperZone2.End := MonRight * (2 / 3)
    SuperZone3.Start := MonRight * (2 / 3) + 1
    SuperZone3.End := MonRight
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
      ; We need to work padding into this
      Zone%Nr%.X := SuperZone%SprZone%.Start
      Zone%Nr%.W := Zone%A_Index%.X - SuperZone%SprZone%.End
      Zone%Nr%.Y := MonBottom * (NrVert - (NrVert - Nr + 1))
      Zone%Nr%.Y := Zone%Nr%.Y + MonBottom / NrVert
      OutputDebug % "Zone" . Nr . " has the following values:"
      OutputDebug % "X: " . Zone%Nr%.X
      OutputDebug % "Y: " . Zone%Nr%.Y
      OutputDebug % "W: " . Zone%Nr%.W
      OutputDebug % "H: " . Zone%Nr%.H
    }
    LastZone := Nr
    OutputDebug, LastZone is now %LastZone%
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
  if (SuperZone == 2) ; middle
    return SubStr(Layout, 2, 1)
  else if (SuperZone == 3) ; right
    return SubStr(Layout, 0)
  else if (SuperZone == 1) ; left
    return SubStr(Layout, -1, 1)
}
