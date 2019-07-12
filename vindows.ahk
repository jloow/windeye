; Rebind the tiling system

; For these key bindings to for (specifically, Win+l), the windows
; lock workstation function must be disabled

; Because the positions of the tiled windows do not always round
; to e.g. exactly half of the monitor resolution (it happens that a
; top-tiled windows has an x-coordinate of -4, for example) we must
; definee an area in which a window is considered tiled, even if it
; is not.
Grace = 20

;----------------;
; MOVE WINDOW UP ;
;----------------;
; This functions in such a way that, depending on whether the window
; is on the left or right side already, it tiles it to that side and
; then tiles it up.
#k:: ; Win+K
  WinGetPos, X, Y, W, H, A ; Get the position and dimension of active
                           ; window
  SysGet, Mon, Monitor ; Get the screen resolution (assumes there is
                       ; only one screen)
  ; Todo: Fix a middle variable
  ; Todo: Fix so that  non-tiled windows that are partly outside the
  ;       screen are handled correctly
  ; If the window is already tiled, it does not have to be sent
  ; left or right
  if (X <= 0 or (X+W >= MonRight and X >= MonRight/2)) {
    ; However, if the windows is in ; a top corner, it should not be
    ; maximized. The minus 100 is arbetrary to correctly find the bottom
    ; edge
    if (Y <= 0 and H <= MonBottom-100) {      
      return
    }
    Send, #{Up}
  }
  ; In the last two cases, where windows are not tiled, we determine if
  ; they are mostly to the left or right side of the screen. The 
  ; windows are positioned accordingly
  else if (X <= MonRight/2) {
    Send, {Win up}
    Send, #{Left}#{Up}
  }
  else if (X > MonRight/2) {
    Send, {Win up}
    Send, #{Right}#{Up}
  }
return

;-------------------;
; MOVE WINDOW RIGHT ;
;-------------------;
#l:: ; Win+l
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  if (X+W >= MonRight and X >= MonRight/2) {
    return
  }
  Send, {Win up}
  Send, #{Right}
return

;------------------;
; MOVE WINDOW LEFT ;
;------------------;
#h:: ; Win+h
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  else if (X <= MonRight/2) {
    return
  }
  SendInput, #{Left}
return

;------------------;
; MOVE WINDOW DOWN ;
;------------------;
#j:: ; Win+j
  WinGetPos, X, Y, W, H, A
  SysGet, Mon, Monitor
  Send, {Win up}
  if ((Y >= MonBottom/2 and  Y < MonBottom/2+Grace) and (Y+H >= MonBottom and Y+H < MonBottom+Grace)
    return
  Send, #{Down}
return

;--------------;
; RANDOM TESTS ;
;--------------;
#t::
  MsgBox, %Grace%
return

;-------------------;
; RELOAD THE SCRIPT ;
;-------------------;
#r::
  Reload
return


; Some help and references
; 
; # 	Win (Windows logo key)
; ! 	Alt
; ^ 	Control
; + 	Shift
