function fits_backsub,filen,lineP=lineP,plotp=plotp

  if not ev_tag_exist(Linep,'type') then begin
     message,'No defined box/line structure found!',/cont
     return,0
  endif else begin
     if LineP.type NE 'box' then begin
        message,'No box parameter found.',/cont
        return,0
     endif
  endelse
  
  a = mod_rdfits(filen,0,header,plotp=plotp,fileDescrip=fileDescrip)

  sz = size(a)
  xstart = max([lineP.Xcoor[0],0])
  xend = min([lineP.Xcoor[1],sz[1]-1l])
  ystart = max([lineP.Ycoor[0],0])
  yend = min([lineP.Ycoor[1],sz[2]-1l])

  subArr = a[xstart:xend,ystart:yend]

  medBack = median(subArr)
  b = a - medback
  outhead = header
  fxaddpar,outhead,'BACKSUB',1
  fxaddpar,outhead,'BACKSUB_VAL',medback

  outfileName = clobber_exten(filen,exten='.fits')+'_backsub.fits'
  writefits,outfileName,b,outhead
  return,outfileName

end


