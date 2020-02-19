global lastMode          := ""
global lastDesktop       := getCurrentDesktopNumber()
update()

update() {
  if (mode != lastMode) {
    lastMode := mode
    displayMode()
  }
  if (getCurrentDesktopNumber() != lastDesktop) {
    lastDesktop := getCurrentDesktopNumber()
    displayDesktopInfo()
  }
  SetTimer, update, 50
}

undisplayMode() {
  SplashImage, Off, , , , modeGui
}

displayMode() {
  SplashImage, , B1 X20 Y20 WM400 WS700 FS12, % mode . " Mode", , modeGui
  SetTimer, undisplayMode, Delete
  SetTimer, undisplayMode, 1500
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
  SplashImage, , B1 WM400 WS700 FS12, %txt%, Desktop, desktopInfoGui
  SetTimer, undisplayDesktopInfo, 1000
}
