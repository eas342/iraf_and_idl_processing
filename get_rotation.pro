pro get_rotation,filen,plotp=plotp,linep=linep
;; Gets the rotation desired by a user
  print,'0: none, 1:90deg CCW, 2:180 deg, 3:90deg CW'
  inrot = 0
  read,inrot
  if inrot LE 7 then begin
     ev_add_tag,plotp,'ROT',inrot
     fits_display,filen,plotp=plotp,linep=linep
  endif else print,'Invalid rotation number'
  

end
