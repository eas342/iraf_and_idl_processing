function quit_caught
;; Tests if the genplot program produced a quit command (useful for
;; stopping a looping program that makes plots inside)
filen = 'ev_local_pparams.sav'
fs = file_search(filen)
if fs NE '' then begin
   restore,filen
   if ev_tag_exist(gparam,'QUIT') then begin
      return,1
   endif else return,0
endif else return,0

end
