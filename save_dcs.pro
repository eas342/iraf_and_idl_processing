pro save_dcs,filel,lineP=lineP,plotp=plotp,$
                     slot=slot
;; Saves a FITS images of the current slot as a FITS file. Mostly
;; useful when you want to save a Double-correlated subtraction to be
;; used by DS9 or to save a much smaller file size than a full ramp

  if n_elements(slot) EQ 0 then slot=0
  namePrefix = clobber_dir(filel[slot],/exten)
  outname = namePrefix+'_dcs.fits'

  imgplane = mod_rdfits(filel[slot],0,header,plotp=plotp,/silent)
  writefits,outname,imgplane,header

end
