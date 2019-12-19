; Automatically get version number from changelog
Loop, Read, ..\CHANGELOG.md 
{
  ;str := StrSplit(A_LoopReadLine
  if (SubStr(A_LoopReadLine, 1, 4) == "## [") {
    str := StrSplit(SubStr(A_LoopReadLine, 5), "]")
    if (str[1] == "Unreleased")
      continue
    else {
      ver := str[1]
      break
    }
  }
}

; Build latest version
Run, Ahk2Exe.exe /in ..\src\Windeye.ahk /out ..\out\Windeye-%ver%.exe
