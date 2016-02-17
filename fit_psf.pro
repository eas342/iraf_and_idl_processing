pro fit_psf,input,lineP,plotp=plotp,custbox=custbox
;; FITS a PSF to an image given a zoombox
;; a - the image
;; zoombox - the BOX region to fit
;; plotp - plot parameters - necessary for rotated images

minsize=2 ;; minimum size for PSF fitting (below this there is not enough data to fit)
type = size(input,/type)

if type EQ 7 then begin
   a = mod_rdfits(input,0,header,plotp=plotp)
endif else a=input

sz = size(a)

if n_elements(custbox) NE 0 then begin
   xstart = max([custbox.Xcoor[0],0])
   xend = min([custbox.Xcoor[1],sz[1]-1l])
   ystart = max([custbox.Ycoor[0],0])
   yend = min([custbox.Ycoor[1],sz[2]-1l])
endif else begin
   if n_elements(lineP) EQ 0 then begin
      print,'No Line or Box Specified'
      return
   endif
   if LineP.type NE 'box' then begin
      print,'Box not specified'
      return
   endif else begin
      xstart = max([lineP.Xcoor[0],0])
      xend = min([lineP.Xcoor[1],sz[1]-1l])
      ystart = max([lineP.Ycoor[0],0])
      yend = min([lineP.Ycoor[1],sz[2]-1l])
   endelse
endelse

;; Round the x start and xend to be clear about the box starts and
;; ends
xstart = ceil(xstart)
xend = ceil(xend)
ystart = ceil(ystart)
yend = ceil(yend)

if yend - ystart LT minsize OR xend - xstart LT minsize then begin
   message,'Not enough image data around location',/continue
   return
endif

if keyword_set(usefunc) then begin
   sz = sz
endif else begin

   
   a2fit = a[xstart:xend,ystart:yend]

   result = mpfit2dpeak(a2fit,fitp,/tilt)

   ;; Add the X/Ystart for the window
   ;; Add the 0.5 to be consistent with showing in plot image
   plotimgAdjustXY = 0.5
   fitp[4] = fitp[4] + float(xstart) + plotimgAdjustXY
   fitp[5] = fitp[5] + float(ystart) + plotimgAdjustXY
   xshowFit = fitp[4] 
   yshowFit = fitp[5] 


   
   corTheta = fitp[6] * 57.2958E              ;; (180E/!pi)
   if abs(fitp[3]) GT abs(fitp[2]) then corTheta = corTheta + 90E
   if corTheta GT 90E then corTheta = corTheta - 180E     ;; using rot symmetry
   if corTheta LT -90E then corTheta = corTheta + 180E    ;; using rot symmetry
   majorF = max(abs(fitp[2:3])) * 2.35482E    ;; convert to FWHM and choose larger one
   minorF = min(abs(fitp[2:3])) * 2.35482E    ;; convert to FWHM


   ;; Find the RA and dec if the WCS headers are found
   extast,header,astr,noparams
   if noparams EQ -1 then begin
      raCen = 0D
      decCen = 0D
   endif else begin
      xy2ad, fitp[4],fitp[5],astr,raCen,decCen
   endelse

   if type EQ 7 then begin
      fileDescrip = input
   endif else fileDescrip = 'NONE'

   get_phot_params,aperRad,skyArr

   ;; Ignore bad pixels
   badpix = where(finite(a) EQ 0,nbadpix)
   if nbadpix NE 0 then begin
      a[badpix] = 0
   endif
   aper,a,fitp[4],fitp[5],mags,errap,sky,skyerr,1E,aperRad,skyArr,[1,1],/flux,silent=keyword_set(noplot)

;   bigsky = where(skyArr[0]^2

   nAp = n_elements(aperRad)
   singlephot = create_struct('BACKG',fitp[0],$
                              'PEAK',fitp[1],$
                              'MaFWHM',majorF,$
                              'Xsig',fitp[2],$
                              'Ysig',fitp[3],$
                              'OrigTheta',fitp[6],$
                              'MiFWHM',minorF,$
                              'XCEN',fitp[4],$
                              'YCEN',fitp[5],'THETA',cortheta,$
                              'RACEN',raCen,'DecCEN',decCen,$
                              'FILEN',fileDescrip,$
                              'APSKY',sky)

   for i=0l,nAp-1l do begin
      ev_add_tag,singlephot,'AP'+string(i,format='(i02)')+'_FLUX',mags[i]
      ev_add_tag,singlephot,'AP'+string(i,format='(i02)')+'_ERR',errap[i]
   endfor

   if ev_tag_exist(plotp,'KEYDISP') then begin
      nkey = n_elements(plotp.KEYDISP)
      for i=0l,nkey-1l do begin
         ev_add_tag,singlephot,$
                    strtrim(plotp.KEYDISP[i],1),fxpar(header,plotp.KEYDISP[i])
      endfor
   endif

   if not keyword_set(noplot) then begin
      show_phot,singlephot,skyArr,aperRad,sz,plotp=plotp
   endif



   prevFile = file_search('ev_phot_data.sav')
   if prevFile NE '' then begin
      restore,'ev_phot_data.sav'
      photdat = [photDat,singlePhot]
   endif else begin
      photdat = singlePhot
   endelse
   save,photdat,filename='ev_phot_data.sav'

endelse
   

end
