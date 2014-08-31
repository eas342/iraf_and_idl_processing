function cross_cor_find,x1,x2,nlagpt=nlagpt,fitsize=fitsize,$
                   showplot=showplot,npolyF=npolyf
;; This script takes two arrays and finds the shift between them from
;; the peak of the cross correlation
  
  if n_elements(nlagpt) EQ 0 then nlagpt = 15l
  if n_elements(fitsize) EQ 0 then fitsize=4l
  if n_elements(NpolyF) EQ 0 then NpolyF=2l
  lagarray = lindgen(nlagpt) - floor(nlagpt/2l)
  crosscor = c_correlate(x1,x2,lagarray)
  maxVal = max(crosscor,topInd)
  lowp = max([0l,topInd - fitsize])
  highp = min([nlagpt-1l,topInd + fitsize])
  PolyTrend = poly_fit(lagarray[lowp:highp],crosscor[lowp:highp],NpolyF)
  peak = -PolyTrend[1]/(2E * polyTrend[2])
  if keyword_set(showplot) then begin
     plot,lagarray,crosscor
     oplot,lagarray,eval_poly(lagarray,polytrend),color=mycol('yellow')
     oplot,peak * [1E,1E],!y.crange,color=mycol('green')
     stop
     plot,x1,ystyle=16
     oplot,shift_interp(x2,-peak),color=mycol('yellow')
     stop
  endif
return, peak
end
