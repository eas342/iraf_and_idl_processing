pro box_stats,input,lineP=lineP,plotp=plotp,silent=silent,backparams=backparams
;; Finds the statistics of the zoombox
;; silent - doesn't spit out values of box stats
;; backparams - back parameters structure. The robust-sigma is found only
;;               for points out of a given pixel radius from cen_x and
;;               cen_y. This is subtracted from all the box pixels



  if not ev_tag_exist(Linep,'type') then begin
     message,'No defined box/line structure found!',/cont
     return
  endif else begin
     if LineP.type NE 'box' then begin
        message,'No box parameter found.',/cont
        return
     endif
  endelse

  a = mod_rdfits(input,0,header,plotp=plotp,fileDescrip=fileDescrip,/silent)

  sz = size(a)

  xcoor = float(checkrange(floor(LineP.xcoor),0,sz[1]-1l))
  ycoor = float(checkrange(floor(LineP.ycoor),0,sz[2]-1l))
  xstart = min(xcoor)
  xend = max(xcoor)
  ystart = min(ycoor)
  yend = max(ycoor)

  subArr = a[xstart:xend,ystart:yend]
  medVal = median(subArr)
  rsigma = robust_sigma(subArr)
  if ev_tag_exist(backparams,'RADIUS') then begin
     xdim = xend - xstart + 1l
     ydim = yend - ystart + 1l
     subArrX = rebin(lindgen(xdim),xdim,ydim) + xstart
     subArrY = rebin(transpose(reverse(lindgen(ydim))),xdim,ydim) + ystart
     dist = sqrt((subArrX - backparams.cen_x)^2 + $
                 (subArrY - backparams.cen_y)^2)
     goodp = where(dist GT backparams.radius and $
                   abs(subArr - medVal) LT 5E * rsigma,ngood)
  endif else begin
     goodp = where(abs(subArr - medVal) LT 5E * rsigma,ngood)
  endelse

  if ngood GT 0 then begin
     rmean = mean(subArr[goodp],/nan)
     if ev_tag_exist(backparams,'SHOWPT') then begin
        oplot,subArrx[goodp],subarry[goodp],psym=4,color=mycol('red')
     endif
     if ev_tag_true(backparams,'SUBTRACT') then begin
        subArr = subArr - rmean
     endif
  endif else begin
     rmean = !values.f_nan
     print,'Not enough valid points for robust mean'
  endelse

  ;; Statistics in for one image and box
  stat = create_struct('FILEN',clobber_dir(fileDescrip),$
                       'CEN_X',mean(lineP.Xcoor),$
                       'CEN_Y',mean(lineP.Ycoor),$
                       'LEN_X',xend - xstart + 1E,$
                       'LEN_Y',yend - ystart + 1E,$
                       'MIN',min(subArr,/nan),$
                       'MAX',max(subarr,/nan),$
                       'MEDIAN',MedVal,$
                       'MEAN',mean(subArr,/nan),$
                       'Total',total(subArr,/nan),$
                       'STDEV',stddev(subArr,/nan),$
                       'RSTDEV',rsigma,$
                       'RMEAN',rmean,$
                       'FULLDIR',fileDescrip)

  if ev_tag_exist(plotp,'KEYDISP') then begin
     nkey = n_elements(plotp.KEYDISP)
     for i=0l,nkey-1l do begin
        ev_add_tag,stat,$
                   strtrim(plotp.KEYDISP[i],1),fxpar(header,plotp.KEYDISP[i])
     endfor
  endif
  


  descrip = ["File","Min","Max","Median","Robust Sig",$
             "Robust Mean"]
  showNm = clobber_dir(stat.filen)
  lenName = strlen(showNm)

  if not keyword_set(silent) then begin
     print,descrip,format='(A15,5A13)'
     print,strmid(showNm,LenName-15,LenName),$
           float(stat.min),float(stat.max),$
           float(stat.median),$
           float(stat.rstdev),float(stat.rmean),$
           format='(A15,5G13)'
  endif

  boxFile = 'es_box_stats.sav'

  prevFile = file_search(boxFile)

  
  if ev_tag_exist(stat,'TFRAME') then begin
     ;; Ran into a type conversion error with TFrame float vs Double
     oldTFrame = stat.tframe
     ev_undefine_tag,stat,'TFRAME'
     ev_add_tag,stat,'TFRAME',double(oldTFrame)
  endif

  if prevFile NE '' then begin
     restore, boxFile
     statdat = [statdat,stat]
  endif else begin
     statdat = stat
   endelse
   save,statdat,filename=boxFile

  
end
