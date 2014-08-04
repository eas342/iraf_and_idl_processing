function ev_robust_poly,x,y,npoly,mask=mask,niter=niter,$
                        showplot=showplot,Nsig=Nsig,sigma=sigma
;; Fits a robust polynomial to a set of coordinates (x,y) with
;; polynomial order npoly
;; mask -- allows you to specify which points are masked
;; niter - number of iterations for sigma clipping
;; showplot -- shows a plot of the fit
;; Nsig - the sigma clipping level
;; sigma - an OUTPUT that gives the robust sigma of the residuals

Xlength = n_elements(x)
assert,Xlength,'=',n_elements(y),'X & Y Inputs to robust poly fitting not same length'  

if n_elements(mask) EQ 0 then mask = fltarr(Xlength)
if n_elements(niter) EQ 0 then niter=3
if n_elements(Nsig) EQ 0 then Nsig=4

;; Throw out anything more than N-sigma in background
;; subtraction & do niter iterations
  nonmask = where(mask EQ 0)
  goodp = nonmask
  modelY = median(y[goodp]) + fltarr(Xlength) ;; initial model is flat
  
  for l=0l,niter-1l do begin
     resid = y - modelY
     rsigma = robust_sigma(resid[goodp])
     goodp = where(abs(resid) LT Nsig * rsigma and $
                   mask EQ 0,complement=badp)
     polyMod = poly_fit(x[goodp],y[goodp],Npoly)
     modelY = eval_poly(x,polyMod)
  endfor
  finalResid = y - modelY
  sigma = robust_sigma(finalResid[goodp])
  if keyword_set(showplot) then begin
     plot,x,y,/nodata,xstyle=1,$
          yrange=threshold(y)
     oplot,x[goodp],y[goodp],psym=4
     oplot,x[badp],y[badp],psym=5,color=mycol('yellow')
     oplot,x,modelY,color=mycol('lblue')
     stop
  endif

return,polyMod
end
