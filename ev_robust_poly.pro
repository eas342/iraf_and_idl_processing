function ev_robust_poly,x,y,npoly,mask=mask,niter=niter,$
                        showplot=showplot,Nsig=Nsig,sigma=sigma,$
                        gaussian=gaussian,customfunc=customfunc,$
                        start=start,quiet=quiet
;; Fits a robust polynomial to a set of coordinates (x,y) with
;; polynomial order npoly
;; mask -- allows you to specify which points are masked
;; niter - number of iterations for sigma clipping
;; showplot -- shows a plot of the fit
;; Nsig - the sigma clipping level
;; sigma - an OUTPUT that gives the robust sigma of the residuals
;; gaussian - fit a 2D Gaussian instead of Polynomial
;; customfunc - does a custom functional fit
;; start - the intial guess for points in a functional fit
;; quiet - passed on to mpfitfun to suppress output

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
     if rsigma EQ 0E then begin
        goodp = where(mask EQ 0,complement=badp)
     endif else begin
        goodp = where(abs(resid) LT Nsig * rsigma and $
                      mask EQ 0,complement=badp)
     endelse
     if goodp NE [-1] then begin
        if keyword_set(customfunc) then begin
           yerr = fltarr(n_elements(goodp)) + rsigma
           polyMod = mpfitexpr(customfunc,x[goodp],y[goodp],yerr,start,/quiet)
           modelY = expression_eval(customfunc,x,polyMod)
        endif else begin
           polyMod = poly_fit(x[goodp],y[goodp],Npoly)
           modelY = eval_poly(x,polyMod)
        endelse
     endif else begin
        polyMod = fltarr(Npoly)
        modelY = fltarr(Xlength)
     endelse
  endfor
  finalResid = y - modelY
  if goodp NE [-1] then sigma = robust_sigma(finalResid[goodp]) else sigma = !values.f_nan
  if keyword_set(showplot) then begin
     plot,x,y,/nodata,xstyle=1,$
          yrange=threshold(y)
     oplot,x[goodp],y[goodp],psym=4
     if badp NE [-1] then oplot,x[badp],y[badp],psym=5,color=mycol('yellow')
     oplot,x,modelY,color=mycol('lblue')
     stop
  endif

return,polyMod
end
