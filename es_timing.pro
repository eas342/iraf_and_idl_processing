function es_timing,a,message
;; Calculates the time and prints a message at that line
;; a  - optional input for the previous time

t = systime(1)

if n_elements(a) NE 0 then begin
   diff = t - a
   if n_elements(message) NE 0 then begin
      print,message,' t=',diff
   endif else begin
      print,'t=',diff
   endelse
endif

return,t

end
