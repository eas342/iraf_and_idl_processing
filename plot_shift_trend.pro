pro plot_shift_trend,psplot=psplot
;; Plot the trend in wavelength shift over time
;; psplot - save a postscript plot

restore,'shift_info.sav'
;; medianShifts

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   plotprenm = 'medianshift_trend'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=14, ysize=10,decomposed=1,/color
endif

plot,medianShifts,$
     xtitle='Image Number',$
     ytitle='Median Shift in Spectrum (px)'

if keyword_set(psplot) then begin
   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif


end
