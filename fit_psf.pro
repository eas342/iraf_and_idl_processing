pro fit_psf,input,lineP,plotp=plotp
;; FITS a PSF to an image given a zoombox
;; a - the image
;; zoombox - the BOX region to fit
;; plotp - plot parameters - necessary for rotated images

type = size(input,/type)

if type EQ 7 then begin
   a = mod_rdfits(input,0,header)
endif else a=input

if ev_tag_exist(plotp,'ROT') then begin
   a = rotate(a,plotp.rot)
end
               
if n_elements(lineP) EQ 0 then begin
   print,'No Line or Box Specified'
   return
endif

sz = size(a)
if LineP.type NE 'box' then begin
   print,'Box not specified'
   return
endif else begin
   xstart = max([lineP.Xcoor[0],0])
   xend = min([lineP.Xcoor[1],sz[1]-1l])
   ystart = max([lineP.Ycoor[0],0])
   yend = min([lineP.Ycoor[1],sz[2]-1l])
endelse


if keyword_set(usefunc) then begin
   sz = sz
endif else begin
;      winsize = 11
;      refX = 65
;      refY = 66
   a2fit = a[xstart:xend,ystart:yend]

   result = gauss2dfit(a2fit,fitp,/tilt)
   fitp[4] = fitp[4] + xstart
   fitp[5] = fitp[5] + ystart
   
   ;; Set up contour plot
   X = FINDGEN(sz[1]) # REPLICATE(1.0, sz[2])
   Y = REPLICATE(1.0, sz[1]) # FINDGEN(sz[2])
   
   xprime = (X - fitp[4])*cos(fitp[6]) - (Y - fitp[5])*sin(fitp[6])
   yprime = (X - fitp[4])*sin(fitp[6]) + (Y - fitp[5])*cos(fitp[6])
   Ufit = (xprime/fitp[2])^2 + (yprime/fitp[3])^2
   Ymodel = fitp[0] + fitp[1] * EXP(-Ufit/2)

   if not keyword_set(noplot) then begin
      sig = fitp[3]
;            print,flist[i]
      corTheta = fitp[6] * 57.2958E ;; (180E/!pi)
      majorF = max(abs(fitp[2:3])) * 2.35482E ;; convert to FWHM and choose larger one
      minorF = min(abs(fitp[2:3])) * 2.35482E ;; convert to FWHM
      if abs(fitp[3]) GT abs(fitp[2]) then corTheta = corTheta + 90E
      if corTheta GT 90E then corTheta = corTheta - 180E ;; using rot symmetry
      if corTheta LT -90E then corTheta = corTheta + 180E ;; using rot symmetry
      descrip=["Back","Peak  ","Maj FWHM","Min FWHM",$
               "X cen","Y cen","Rot CW,d"]
      print,descrip,format='(2A15,5A9)'
      print,fitp[0],fitp[1],majorF,minorF,Fitp[4],fitp[5],corTheta,$
            format='(2G15,5F9.2)'
;            plotimage,a,range=[min(a),max(a)],pixel_aspect_ratio=1.0
      contour,ymodel,/overplot,color=mycol('red'),nlevels=3,levels=[0.2,0.5,0.8] * fitp[1]
;      print,"Fit Sigma = ",fitp[2]
;         c = contour(ymodel,/overplot,c_thick=[4],color='red')
   endif

   singlephot = create_struct('BACKG',fitp[0],$
                              'PEAK',fitp[1],$
                              'MaFWHM',majorF,$
                              'MiFWHM',minorF,$
                              'XCEN',fitp[4],$
                              'YCEN',fitp[5],'THETA',fitp[6])
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
