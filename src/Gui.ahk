global lastEdgeModeState := edgeMode
global lastDesktop       := getCurrentDesktopNumber()
update()

update() {
  if (lastEdgeModeState != edgeMode) {
    lastEdgeModeState := edgeMode
    displayEdgeMode()
  }
  if (getCurrentDesktopNumber() != lastDesktop) {
    lastDesktop := getCurrentDesktopNumber()
    displayDesktopInfo()
  }
  SetTimer, update, 50
}

undisplayEdgeMode() {
  SplashImage, Off, , , , edgeModeGui
}

displayEdgeMode() {
  txt := edgeMode ? "ON" : "OFF"
  SplashImage, , B X20 Y20 WM400 WS700 FS12, %txt%, Edge Mode, edgeModeGui
  ; change := ""
  ; Loop, 25 {
  ;   change := A_Index * 10 + 5
  ;   WinSet, Transparent, %change%, edgeModeGui
  ;   Sleep, 5
  ; }
  SetTimer, undisplayEdgeMode, 1500
  ; ; WinSet, Transparent, Off, edgeModeGui
  ; Loop, 25 {
  ;   change -= (A_Index-1) * 10
  ;   WinSet, Transparent, %change%, edgeModeGui
  ;   Sleep, 50
  ; }
}

undisplayDesktopInfo() {
  SplashImage, Off, , , , desktopInfoGui
}

displayDesktopInfo() {
  numberOfDesktops     := getNumberOfDesktops()
  currentDesktopNumber := getCurrentDesktopNumber()
  txt := ""
  Loop, % numberOfDesktops {
    if (A_Index == currentDesktopNumber)
      txt .= "□"
    else
      txt .= "■"
  }
  SplashImage, , B WM400 WS700 FS12, %txt%, Desktop, desktopInfoGui
  SetTimer, undisplayDesktopInfo, 1000
}
