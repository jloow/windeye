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
    IsActive: "no",
    HasWindow: "no"
  }
}

setLayout() {
  ; Promt the user for layout
  ; ...

  ; Convert the 2 digit sequence to a correct 3 digit sequence
  if (Layout < 100)
    ; We don't accept more than 4 vertical zones
    if (Layout >= 44)
      Layout := 44

    ; Split the string


}

GenerateGrid() {
  SysGet, Mon, Monitor
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

; Get the number of zones that are to fit vertically in a given super zone
GetNumberZonesVer(SuperZone) {
  global Layout
  if (SuperZone == "middle")
    return Floor((Layout - Floor(Layout/100)*100) / 10)
}
