; Start terminal
#r:: Run, pwsh

; Start double commander
#e:: Run, "C:\Program Files\Double Commander\doublecmd.exe"

; Start wsl through cmd
#w:: Run, pwsh /C wsl

; Start qutebrowser
#t:: Run, "C:\Program Files\qutebrowser\qutebrowser.exe"

; Start firefox
#+t:: Run, "C:\Program Files\Mozilla Firefox\firefox.exe"

; Start my common applications (and positions them the way I want?)
#o::
Run, outlook
Run, "C:\Program Files\Double Commander\doublecmd.exe"
Run, "C:\Program Files\qutebrowser\qutebrowser.exe"
Run, "C:\Program Files (x86)\Hughesoft\todotxt.net\todotxt.exe"
Return

; #IfWinActive, ahk_exe doublecmd.exe
;   l:: Send, {Right}
;   h:: Send, {Left}
;   j:: Send, {Down}
;   k:: Send, {Up}
;   /:: Send, ^f
;   !l:: Send, l
;   !h:: Send, h
;   !j:: Send, j
;   !k:: Send, k
; Return


