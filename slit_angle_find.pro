pro slit_angle_find,nosky=nosky,rescale=rescale,$
                    saveimgs=saveimgs,skyscale=skyscale
;; This script is designed to find the angle between two stars and the
;; slit
;;nosky - don't do sky subtraction
;; savimgs - saves the subtracted image & derivative image (for slit finding)
;; skyscale -- scales a previous sky image by the exposure time

fwhm=8E ;; star FWHM

;; Find the last run file
cd,current=currentd
runfileL = file_search(currentd+'/run*.fits')
nrunfile = n_elements(runfileL)
filen = runfileL[nrunfile-1l]
a = mrdfits(filen,0,header)

;; search for a sky image. If found, use it
skyFileL = file_search(currentd+'/sky*.fits')
if skyFileL NE '' and not keyword_set(nosky) then begin
   sky = mrdfits(skyFilel[0],0,skyheader)
   if keyword_set(skyscale) then begin
      ;; Scale by the relative exposure time
      expSky = fxpar(skyheader,'ITIME')
      expOrig = fxpar(header,'ITIME')
      skysub = a - sky * (expOrig/expSky)
   endif else skysub = a - sky
endif else skysub = a

if keyword_set(rescale) then begin
   fits_display,skysub,/findscale,outscale=scale1
endif else begin
   scale1 = threshold(skysub,low=0.1,high=0.9)
endelse

nstars = 2
plotimage,skysub,range=scale1,$
          title='Click on two stars, lower one first'
coord = fltarr(2,nstars)
for i=0l,nstars-1l do begin
   coord[*,i] = centroid_find(skysub,fwhm=fwhm)
endfor
DeltaY = coord[1,1] - coord[1,0]
DeltaX = coord[0,1] - coord[0,0]
AngleCW = atan(deltaY,deltaX) * 180E/!PI

print,'Star Angle = ',AngleCW

slitAngle = 90.1

print,'Slit Misalignment = ',(slitAngle - angleCW)

;; Find slit position
;slitMod = slit_position_find(a)


if keyword_set(saveimgs) then begin
   derivImg = a - shift(a,1,0)   
   plotimage,derivImg,range=threshold(derivImg)
   writefits,'subtracted.fits',skysub,header
   writefits,'deriv.fits',derivImg,header
endif

end
