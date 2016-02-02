pro box_stats,input,lineP=lineP,plotp=plotp
;; Finds the statistics of the zoombox

  if not ev_tag_exist(Linep,'type') then begin
     message,'No defined box/line structure found!',/cont
     return
  endif else begin
     if LineP.type NE 'box' then begin
        message,'No box parameter found.',/cont
        return
     endif
  endelse

  a = mod_rdfits(input,0,header,plotp=plotp,fileDescrip=fileDescrip)

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
  goodp = where(abs(subArr - medVal) LT 5E * rsigma,ngood)
  if ngood GT 0 then begin
     rmean = mean(subArr[goodp],/nan)
  endif else rmean = !values.f_nan
  
  ;; Statistics in for one image and box
  stat = create_struct('FILEN',clobber_dir(fileDescrip),$
                       'CEN_X',mean(lineP.Xcoor),$
                       'CEN_Y',mean(lineP.Ycoor),$
                       'LEN_X',xend - xstart,$
                       'LEN_Y',yend - ystart,$
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
  print,descrip,format='(A15,5A13)'
  showNm = clobber_dir(stat.filen)
  lenName = strlen(showNm)

  print,strmid(showNm,LenName-15,LenName),$
        float(stat.min),float(stat.max),$
        float(stat.median),$
        float(stat.rstdev),float(stat.rmean),$
        format='(A15,5G13)'

  boxFile = 'es_box_stats.sav'

  prevFile = file_search(boxFile)
  if prevFile NE '' then begin
     restore, boxFile
     statdat = [statdat,stat]
  endif else begin
     statdat = stat
   endelse
   save,statdat,filename=boxFile

  
end
