pro fit_psf,input,lineP,plotp=plotp,custbox=custbox
;; FITS a PSF to an image given a zoombox
;; a - the image
;; zoombox - the BOX region to fit
;; plotp - plot parameters - necessary for rotated images

minsize=2 ;; minimum size for PSF fitting (below this there is not enough data to fit)
type = size(input,/type)

if type EQ 7 then begin
   a = mod_rdfits(input,0,header)
endif else a=input

if ev_tag_exist(plotp,'ROT') then begin
   a = rotate(a,plotp.rot)
end
               

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

if yend - ystart LT minsize OR xend - xstart LT minsize then begin
   print,'Not enough image data around location'
   return
endif

if keyword_set(usefunc) then begin
   sz = sz
endif else begin

   
   a2fit = a[xstart:xend,ystart:yend]

   result = gauss2dfit(a2fit,fitp,/tilt)
   fitp[4] = fitp[4] + xstart
   fitp[5] = fitp[5] + ystart
   
   ;; Set up contour plot
   X = FINDGEN(sz[1]) # REPLICATE(1.0, sz[2])
   Y = REPLICATE(1.0, sz[1]) # FINDGEN(sz[2])
   
   corTheta = fitp[6] * 57.2958E              ;; (180E/!pi)
   if abs(fitp[3]) GT abs(fitp[2]) then corTheta = corTheta + 90E
   if corTheta GT 90E then corTheta = corTheta - 180E     ;; using rot symmetry
   if corTheta LT -90E then corTheta = corTheta + 180E    ;; using rot symmetry
   majorF = max(abs(fitp[2:3])) * 2.35482E    ;; convert to FWHM and choose larger one
   minorF = min(abs(fitp[2:3])) * 2.35482E    ;; convert to FWHM


   if type EQ 7 then begin
      fileDescrip = input
   endif else fileDescrip = 'NONE'

   singlephot = create_struct('BACKG',fitp[0],$
                              'PEAK',fitp[1],$
                              'MaFWHM',majorF,$
                              'MiFWHM',minorF,$
                              'XCEN',fitp[4],$
                              'YCEN',fitp[5],'THETA',cortheta,$
                              'FILEN',fileDescrip)
   if ev_tag_exist(plotp,'KEYDISP') then begin
      nkey = n_elements(plotp.KEYDISP)
      for i=0l,nkey-1l do begin
         ev_add_tag,singlephot,$
                    strtrim(plotp.KEYDISP[i],1),fxpar(header,plotp.KEYDISP[i])
      endfor
   endif

   if not keyword_set(noplot) then begin
      xprime = (X - fitp[4])*cos(fitp[6]) - (Y - fitp[5])*sin(fitp[6])
      yprime = (X - fitp[4])*sin(fitp[6]) + (Y - fitp[5])*cos(fitp[6])
      Ufit = (xprime/fitp[2])^2 + (yprime/fitp[3])^2
      Ymodel = fitp[0] + fitp[1] * EXP(-Ufit/2)
      sig = fitp[3]
;            print,flist[i]
      descrip=["Back","Peak  ","Maj FWHM","Min FWHM",$
               "X cen","Y cen","Rot CW,d"]
      print,descrip,format='(2A15,5A9)'
      print,fitp[0],fitp[1],majorF,minorF,Fitp[4],fitp[5],corTheta,$
            format='(2G15,5F9.2)'
;            plotimage,a,range=[min(a),max(a)],pixel_aspect_ratio=1.0
      myLevelsUnsort = [0.2,0.5,0.8] * fitp[1]
      lsort = sort(myLevelsUnsort)
      mylevels = myLevelsUnsort[lsort]
      contour,ymodel,/overplot,color=mycol('red'),nlevels=3,levels=mylevels
;      print,"Fit Sigma = ",fitp[2]
;         c = contour(ymodel,/overplot,c_thick=[4],color='red')
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
