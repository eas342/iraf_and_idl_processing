pro genbin,X,Y,nbin,outX=outX,outY=outY,yerr=yerr,$
           stdevArr=stdevArr
;; General binner that bins into nbin and gives output outX and outY

npt = n_elements(x)
minX = min(X,/nan)
maxX = max(X,/nan)

;; Calculate the bin sizes
binSizes = dblarr(nbin) + (maxX - minX)/double(nbin)
;; starts of bins
startX = dindgen(nbin) * binsizes[0] + minX
outX =  startX + binsizes[0]/2E

if n_elements(yerr) EQ 0 then begin
   rsigma = robust_sigma(y)
   yerr = dblarr(npt) + rsigma
   SNR = y / yerr
endif

outY = avg_series(X,Y,SNR,startX,binsizes,weighted=weighted,oreject=oreject,$
                  eArr=eArr,silent=silent,stdevArr=stdevArr,errIn=yerr)


end
