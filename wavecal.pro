function wavecal
;; Finds the wavelength versus pixel solution

Npoly = 2 ;; polynomial solution

;from the Argon line identification table, find a wavelength solution
openr,1,'database/idfirst_wavecal'
oneline = ''
while ~ EOF(1) do begin
   readf,1,oneline
   if strpos(oneline,'features') NE -1 then begin
      featuresLine = strsplit(oneline[0],'features',/extract)
      nfeatures = long(featuresLine[1])
      pixel = fltarr(nfeatures)
      wavel = fltarr(nfeatures)
      storageA = fltarr(6)
      for i=0l,nfeatures-1l do begin
         readf,1,oneline
         reads,oneline,storageA
         pixel[i] = storageA[0]
         wavel[i] = storageA[1]/1E4 ;; in microns
      endfor
   endif
endwhile
close,1

plot,pixel,wavel,psym=4,$
     xtitle='Pixels',$
     ytitle='Wavelength ('+cgGreek('mu')+'m)',$
     xrange=[0,max(pixel)]
polyMod = poly_fit(pixel,wavel,Npoly)
xshow = findgen(round(max(pixel)))
yshow = eval_poly(xshow,polyMod)

oplot,xshow,yshow,color=mycol('yellow')

return,PolyMod
end
