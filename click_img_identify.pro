pro click_img_identify,data,Y,gparam=gparam
;; Identifies a point when you click on it
;; If there is a FITS image associated with that point, it will
;; display the FITS image 

  xLength = (!x.crange[1] - !x.crange[0])
  yLength = (!y.crange[1] - !y.crange[0])
  xspacing = 0.005 * xlength ;; spacing for text
  yspacing = 0.03 * ylength ;; spacing for text
  ;; Plot the wavelengths of specified points

  ;; Get the tags that are selected

  DataInd = key_indices(data,gparam)
;  deal_with_strings,data,gparam,dataInd,tags
  xin = data.(dataInd[0])
  yin = data.(dataInd[1])

  ;; If there's an image list, get it
  trytags = ['FILEN','FILEN_00']
  ;; Try these file names and check for .fits files
  listfound = 0
  for i=0l,n_elements(trytags)-1l do begin
     if ev_tag_exist(data,trytags[i],index=fileindex) then begin
        ndata = n_elements(data.(fileindex))
        if total(strmatch(data.(fileindex),'*.fits',/fold_case)) EQ ndata OR $
           total(strmatch(data.(fileindex),'*.fit',/fold_case)) EQ ndata then begin
           filel = data.(fileindex)
           listfound = 1
        endif
     endif
  endfor


  WHILE (!MOUSE.button NE 4) DO BEGIN
     cursor,xcur,ycur,/down
     ;; Find the closest point to click
     sqrdist = (xcur - xin)^2/xlength^2 + (ycur - yin)^2/ylength^2
     minDist = min(sqrdist,iclickX,/nan)

     xNear = xin[iclickX]
     yNear = yin[iclickX]
;     tlabel = label[iclickX]
     oplot,[xNear],[yNear],$
           psym=4,color=mycol('red'),symsize=2
     if listfound then begin
        adjust_pwindow,type='FITS Window'
        fits_display,filel[iclickX]
        adjust_pwindow,type='Plot Window'
     endif else tlabel=''

     print,xNear,ynear,tlabel
;     xyouts,xNear + xspacing,yNear + yspacing,strtrim(tlabel,1),$
;            orientation=45,charsize=1.5


     if n_elements(xout) EQ 0 then begin
        xout = xNear
        yout = yNear
;        tout = tlabel
     endif else begin
        xout = [xout,xNear]
        yout = [yout,yNear]
;        tout = [tout,tlabel]
     endelse
  end
  !MOUSE.button = 1



end
