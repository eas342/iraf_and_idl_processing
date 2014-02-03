pro make_median_shift_func,psplot=psplot,npoly=npoly
;; Makes a median of the shift function to see if it's far from
;; a polynomial
;; psplot - make a postscript plot

if n_elements(npoly) EQ 0 then npoly = 3

restore,'shift_info.sav'

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   plotprenm = 'median_shift_func'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=18, ysize=15,decomposed=1,/color
endif

nrows = n_elements(medianShiftFunc)
x = findgen(nrows)
Coeff = poly_fit(x,medianShiftFunc,npoly,yfit=yfit)

!p.multi=[0,1,2]
plot,x,MedianShiftFunc,$
     xtitle='Row (px)',$
     ytitle='Spectral Shift (px)',/nodata
xerr = fltarr(nrows)
oplot,x,MedianShiftFunc,psym=4
;oploterr,x,MedianShiftFunc,standardErrarr
oplot,x,yfit,color=mycol('blue')

resid = MedianShiftFunc - yfit
plot,x,resid,$
     xtitle='Row (px)',$
     ytitle='Residual (px)',/nodata

oploterror,x,resid,xerr,standardErrarr,psym=3

!p.multi = 0

if keyword_set(psplot) then begin
   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif


end
