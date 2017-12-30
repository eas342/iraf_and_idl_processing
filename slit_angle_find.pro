pro slit_angle_find,nosky=nosky,rescale=rescale,$
                    saveimgs=saveimgs,skyscale=skyscale,$
                    reslit=reslit,restar=restar
;; This script is designed to find the angle between two stars and the
;; slit
;;nosky - don't do sky subtraction
;; savimgs - saves the subtracted image & derivative image (for slit finding)
;; skyscale -- scales a previous sky image by the exposure time when
;;             attempting a sky subtraction
;; reslit -- Reset the box in which to find the slit
;; restar -- reselect locations of the stars

fwhm=11E ;; star FWHM

;; Check for a previous set of preferences
saveFilen = 'ev_local_slit_angle_prefs.sav'
cd,current=currentD
FindPref = file_search(currentD+'/'+saveFilen)
if findPref NE '' then begin
   restore,currentD+'/'+saveFilen
endif

;; Find the last run file
cd,current=currentd
runfileL = file_search(currentd+'/sgd*.fits')
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
   fits_display,skysub,/findscale,plotp=plotp
endif

if n_elements(slitbox) EQ 0 OR keyword_set(reslit) then begin
   fits_display,skysub
   slitbox = find_click_box()
endif

nstars = 2

;slitAngle = 90.1
slitAngle = slit_find(a,slitbox,yfunc=slitpos);,/showp)

if keyword_set(restar) then begin
   starmessage = 'Click on two stars, lower one first'
endif else begin
   starmessage = 'Using star starting locations from previous file'
endelse

if file_exists('ev_local_display_params.sav') then begin
   restore,'ev_local_display_params.sav'
endif

fits_display,skysub,plotp=plotp,$
             message=starmessage
ycoord = findgen(n_elements(skysub[0,*]))
slitP = eval_poly(ycoord,slitpos)
plots,slitP,ycoord,color=mycol('blue')

coord = fltarr(2,nstars)

if keyword_set(restar) OR n_elements(coordstart) EQ 0 then begin
   for i=0l,nstars-1l do begin
      coord[*,i] = centroid_find(skysub,fwhm=fwhm)
   endfor
endif else begin
   ;; In the default mode, it just uses the previous star coordinates
   for i=0l,nstars-1l do begin
      coord[*,i] = centroid_find(skysub,fwhm=fwhm,startCoord=coordstart[*,i])
   endfor
endelse

DeltaY = coord[1,1] - coord[1,0]
DeltaX = coord[0,1] - coord[0,0]
AngleCW = atan(deltaY,deltaX) * 180E/!PI

;print,'Star Angle = ',AngleCW
print,'Star-Slit Angle = ',(angleCW - slitAngle),' deg CCW'

topStarDiff = coord[0,1] - slitP[coord[1,1]]
botStarDiff = coord[0,0] - slitP[coord[1,0]]
print,'Top Star    Diff = ',topStarDiff,' px right of slit cen'
print,'Bottom Star Diff = ',botStarDiff,' px right of slit cen'

;; Find slit position
;slitMod = slit_position_find(a)


if keyword_set(saveimgs) then begin
   derivImg = a - shift(a,1,0)   
   plotimage,derivImg,range=threshold(derivImg)
   writefits,'subtracted.fits',skysub,header
   writefits,'deriv.fits',derivImg,header
endif

coordstart = coord ; save the star locations for quicker analysis of future images
save,plotp,slitBox,coordstart,$
     filename=saveFilen

end
