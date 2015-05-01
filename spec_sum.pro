function spec_sum,inp,ap,pos,plotp=plotp,$
                  showAp=showAp
;; Reads in a file, rotates it correctly and extracts a spectrum with
;; the given aperture size in pixels
;; it expects to find a file "order_coeff.sav" which has the
;; polynomial coefficients for the orders
;; inp - either an array or file name
;; showAp - shows the aperture

restore,reduction_dir()+'/data/ts4_order_coeff.sav'

a = mod_rdfits(inp,0,header,plotp=plotp)

if keyword_set(showAp) then begin
   fits_display,inp,plotp=plotp
endif

oneStruct = create_struct('sum',0E,'nord',oArr.nord,$
                          'ord',0,'xp',0l)
sumArr = replicate(oneStruct,oArr.xsize * oArr.nord)
ymod = fltarr(oArr.nord,oArr.xsize)
xArr = findgen(oArr.xsize)

for i=0l,oArr.nord-1l do begin
   ymod[i,*] = poly(xArr,oArr.mc[i,*]) + pos
   startp = checkrange(ymod[i,*] - ap,0,oArr.ysize-1l)
   endp = checkrange(ymod[i,*] + ap,0,oArr.ysize-1l)
   if keyword_set(showAp) then begin
      oplot,xArr,startp,color=mycol('green')
      oplot,xArr,endp,color=mycol('green')
   endif
   for j=0l,oArr.xsize-1l do begin
      fI = i * oArr.xsize + j ;; full index
      sumArr[fI].xp = xArr[j]
      sumArr[fI].ord = oArr.orderL[i]
      sumArr[fI].sum = total(a[j,startp[j]:endp[j]])
   endfor
endfor
return,sumArr

end

