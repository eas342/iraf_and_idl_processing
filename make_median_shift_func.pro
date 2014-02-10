pro make_median_shift_func,psplot=psplot,npoly=npoly,polyOnly=polyOnly,$
                           custYrange=custYrange,eureqa=eureqa
;; Makes a median of the shift function to see if it's far from
;; a polynomial
;; psplot - make a postscript plot
;; npoly - order of the polynoial
;; polyOnly - only do the polynomial fitting (no extra fancy stuff
;;            like the sine of the polynomial!)
;; custYrange -- set a custom y range for the residuals
;; eureqa - use the function found from the eureqa program

if n_elements(npoly) EQ 0 then npoly = 5

restore,'shift_info.sav'

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   plotprenm = 'median_shift_func'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=7, ysize=10,decomposed=1,/color
endif

nrows = n_elements(medianShiftFunc)
x = findgen(nrows)

for i=0l,3l - 1l do begin
   if n_elements(goodp) EQ 0 then  begin
      ;; first time around
      goodp = lindgen(nrows)
   endif

   if i EQ 0 OR keyword_set(polyOnly) then begin
      ;; first time find the polynomial parameters
      expr = 'eval_poly(X,P[indgen('+strtrim(npoly,1)+')]) ' ;+'+$
      start = fltarr(npoly)
   endif else begin
      if keyword_set(eureqa) then begin
         expr = 'eureqa_func(X,P)'
         start = [7.013,5.233e-5,2.049,0.04938,-0.03555,$
                  0.0001568,0.1049]
      endif else begin
         expr = 'poly_and_sine(X,P,'+strtrim(Npoly,1)+')'
         if n_elements(start) EQ npoly then begin
            start = [result,fltarr(Npoly),fltarr(Npoly),0E,0E]
            start[Npoly *3] = 1E/100E ;; start with a period of 50 rows
            start[Npoly *3+1l] = 1E/100E ;; start with a period of 50 rows
            
            ;; use the previous polynomial parameters
         endif
      endelse
   endelse
;       'P[5] * cos(2E * eval_poly(X,P[indgen(5)]) + P[7])'
;start = [7.01,-0.05,5.7e-5,5.32e-8,-6.3e-11,0.1E,1.8E,0E]

;expr = 'eval_poly(X,P)'
   result = mpfitexpr(expr,x[goodp],medianShiftFunc[goodp],standardErrarr[goodp],start)
   yfit = expression_eval(expr,x,result)
   resid = MedianShiftFunc - yfit
   if i EQ 0 then begin
      goodp = where(abs(resid) LT standardErrarr * 10E,complement=badp)
      ;; I think I'm only going to do clipping on the polynomial
   endif

;Coeff = poly_fit(x,medianShiftFunc,npoly,yfit=yfit)
endfor

!p.multi=[0,1,3]
plot,x,MedianShiftFunc,$
     xtitle='Row (px)',$
     ytitle='Spectral Shift (px)',/nodata
xerr = fltarr(nrows)
oplot,x,MedianShiftFunc,psym=4
;oploterr,x,MedianShiftFunc,standardErrarr
oplot,x,yfit,color=mycol('blue')

case 1 of
   keyword_set(polyOnly): funcText = 'N_poly = '+strtrim(npoly,1)
   keyword_set(eureqa): funcText = 'Eureqa Func'
   else: funcText = 'Custom Func'
endcase
xyouts,(!x.crange[1] - !x.crange[0])*0.6E + !x.crange[0],$
       (!y.crange[1] - !y.crange[0])*0.7E + !y.crange[0],$
       funcText


if n_elements(custYrange) EQ 0 then custYrange = [0,0]
plot,x,resid,$
     xtitle='Row (px)',$
     ytitle='Residual (px)',/nodata,yrange=custYrange
;oplot,x,resid,psym=4
oploterror,x[goodp],resid[goodp],xerr[goodp],standardErrarr[goodp],psym=3
oploterror,x[badp],resid[badp],xerr[badp],standardErrarr[badp],$
           psym=3,color=mycol('blue')

Rshift = MedianShiftFunc ;; the rough shift
plot,Rshift[goodp],resid[goodp],$
     xtitle='Rough Shift',$
     ytitle='Shift Residual',/nodata,yrange=custYrange
;oplot,rshift[goodp],resid[goodp],psym=4
oploterror,Rshift[goodp],resid[goodp],xerr[goodp],standardErrarr[goodp],psym=3

!p.multi = 0

;; Save the plot points for use by Eureqa
everyOther = where(lindgen(n_elements(goodp)) mod 2 EQ 0)
chosenPoints = goodp[everyOther]
;; because they don't let you have more than 200 points in the trial version
write_csv,'shift_func_points_for_eureqa.csv',x[chosenPoints],medianShiftFunc[chosenPoints]

;; Save the resulting master shift function
forprint,x,yfit,MedianShiftFunc,standardErrArr,$
         textout='Functional_fit.txt',$
         comment='#Row  #Functional Fit #Measured Val #Standard Error'

if keyword_set(psplot) then begin
   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif


end
