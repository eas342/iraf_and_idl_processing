pro savemask_fits,filen,maskp
;; Saves a mask associated with the file

  nmask = n_elements(maskp)
  if nmask EQ 0 then begin
     print,'No mask to output!'
  endif else begin
     mask = mod_rdfits(filen,0,header)
     mask[*] = 0
     filenInside = clobber_dir(filen,/exten,dir=dir)
     maskFile = 'mask_for_'+filenInside+'.fits'
     fileFind = file_search(maskFile)
     if fileFind NE '' then begin
        maskFile = dialog_pickfile(/write,filter='*.fits',$
                                   default_extension='.fits')
     endif
     sz = size(mask)
     for i=0l,nmask-1l do begin
        rangeX = checkrange(round(maskp[i].xcoor[0:1]),0,sz[1]-1l)
        rangeY = checkrange(round(maskp[i].ycoor[0:1]),0,sz[2]-1l)
        mask[rangeX[0]:rangeX[1],$
             rangeY[0]:rangeY[1]] = 1
             
     endfor
     fxaddpar,header,'MASK',1,'This is a mask for the associated image'
     writefits,maskFile,mask,header
  endelse

end
