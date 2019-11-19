; This script is for launching different ahk scripts together and as admin

SetWorkingDir %A_ScriptDir%

Run *RunAs windeye.ahk

; Todo: make the script automatically click the confirm button on UAC, then exit the script
