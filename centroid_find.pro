function centroid_find,a,fwhm=fwhm
;; Find the centroid within a boxin the x & y directions
;; a -- the 2d data array
;; fwhm - stellar FWHM

  
cursor,xcur,ycur,/down
cntrd,a,xcur,ycur,xcen,ycen,fwhm,/keepcenter



;; Also do a straight centroid around cursor
boxSize = fwhm * 2E
subWind = a[xcur-boxSize:xcur+boxSize,ycur-boxSize:ycur+boxSize]
;; Try a gaussian fit
;coeff = ev_robust_poly(subWind,/gaussian)
;result = gauss2dfit(subWind,coeff,/tilt)
;GcenX = coeff[4] + xcur - boxsize
;GcenY = coeff[5] + ycur - boxsize


;; My centroid, from D fanning https://www.idlcoyote.com/tips/centroid.html
s = size(subWind,/dimensions)
totalMass = total(subWind)
esXcen = total(total(subWind,2) * indgen(s[0]))/totalMass + xcur - boxsize
esYcen = total(total(subWind,1) * indgen(s[1]))/totalMass + ycur - boxsize

if xcen EQ -1 or ycen EQ -1 then begin
;   print,"WARNING: IDL's cntrd failed, using regular centroid"
;   xcen = esXcen
;   ycen = esYcen
;; if this routine fails, then just use the coordinats of the cursor
   print,'WARNING: CENTROID FAILED. Just using the clicked coordinates'
   xcen = xcur
   ycen = ycur
endif


print,'Centroid: ',xcen,' ',ycen;,' ES Centroid',esXcen,' ',esYcen
;print,'Centroid: ',strtrim(xcen,1),' ',strtrim(ycen,1),$
;      ' Gauss Cen ',strtrim(GcenX,1),' ',strtrim(GcenY,1)

;; Draw a box around the centroid
boxHW = fwhm * 0.7E
ndraw = 5
xbox = fltarr(ndraw) + xcen
ybox = fltarr(ndraw) + ycen
;xbox = fltarr(ndraw) + GcenX
;ybox = fltarr(ndraw) + GcenY
xbox[0] = xbox[0] - boxHW ;; bottom left
ybox[0] = ybox[0] - boxHW
xbox[1] = xbox[1] - boxHW ;; top left
ybox[1] = ybox[1] + boxHW
xbox[2] = xbox[2] + boxHW ;; top right
ybox[2] = ybox[2] + boxHW
xbox[3] = xbox[3] + boxHW ;; bottom right
ybox[3] = ybox[3] - boxHW
xbox[4] = xbox[0] ;; back to bottom left
ybox[4] = ybox[0]

plots,xbox,ybox,color=mycol('red'),thick=1.5

coor = [xcen,ycen]
return,coor

end
