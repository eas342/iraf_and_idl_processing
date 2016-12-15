function miv_headfits,plotp,filename
   ;; This function is a wrapper for headfits the only difference is that it
      ;; finds the extension based on the CHOOSEEXTEN tag of the plotp structure
   
   if ev_tag_exist(plotp,'CHOOSEEXTEN') then begin
      ;; Reads the extension of chooseexten
      exten = plotp.chooseexten
   endif else exten=0
   head = headfits(filename,exten=exten)
   return, head

end