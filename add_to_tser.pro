pro add_to_tser
;; Reads throught the photometry data and will allow you to add
;; another FITS keyword (I often forget to specify MJD_OBS)

restore,'ev_phot_data.sav'

nphot = n_elements(photdat)

choose_key,photdat[0].filen,choosestruct
newkey = choosestruct.keydisp[0]

for i=0l,nphot-1l do begin
   head = headfits(photdat[i].filen)
   value = fxpar(head,newkey)
   if i EQ 0 then begin
      valuearr = value
   endif else valuearr = [valuearr,value]
endfor

newkey = struct_tag_clean(newkey)
ev_add_tag,photdat,newkey,valuearr

save,photdat,filename='ev_phot_data.sav'

end
