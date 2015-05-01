pro nodsub,filel,plotp,linep,slot

  a1 = mod_rdfits(filel[slot],0,head1);,plotp=plotp)
  a2 = mod_rdfits(filel[slot+1l],0,head2);,plotp=plotp)

  nodsub = a1 - a2
  outnm = clobber_exten(filel[slot])+'_sub.fits'
  if file_exists(outnm) then begin
     message,outnm+' exists! Not overwriting with AB nod subtract',$
             /continue
     return
  endif else begin
     nhead = head1
     fxaddpar,nhead,'NODSUB',1,'Nod subtracted'
     fxaddpar,nhead,'NODSUB',clobber_dir(filel[slot+1l]),'Nod sub file'
     writefits,outnm,nodsub,nhead
     filel = [filel,outnm]
     slot = n_elements(filel) -1l
     fits_display,fileL[slot],plotp=plotp,lineP=lineP
  endelse

end
