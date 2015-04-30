function order_pic,X,Y,ind=ind
;; Takes an array of (X,Y) points and finds their diffraction order
;; Requires a order_coeff save file
;; ieff - effective index of order

restore,reduction_dir()+'/data/ts4_order_coeff.sav'
npt = n_elements(x)
if n_elements(y) NE npt then begin
   print,'Array mismatch'
   return, 0
endif

ymod = fltarr(oArr.nord,npt)
outO = intarr(npt)
ind = intarr(npt)

for i=0l,oArr.nord-1l do begin
   ymod[i,*] = poly(x,oArr.mc[i,*])
endfor
for i=0l,npt-1l do begin
   minVal = min(abs(ymod[*,i] - y[i]),ieff)
   ind[i] = ieff
   outO[i] = oArr.orderL[ieff]
endfor

return,outO

end

