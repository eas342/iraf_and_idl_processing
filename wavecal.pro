function wavecal,origimg=origimg
;; Finds the wavelength versus pixel solution

Npoly = 5 ;; polynomial solution

if keyword_set(origimg) then begin
;; Check the original image for trim section and
   head = headfits('first_wavecal.fits')
   trimfo = fxpar(head,'TRIM',count=trimcount)
   if trimcount GE 1 then begin
      ccdsec = fxpar(head,"CCDSEC",count=seccount)
      if seccount LT 1 then begin
         print,"Warning, unknown trim keywords."
         return,a
      endif else begin
         trimReg = parse_iraf_regions(ccdsec)
      endelse
   endif
endif

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
         wavel[i] = storageA[2]/1E4 ;; in microns
      endfor
   endif
endwhile
close,1

if keyword_set(origimg) then begin
;; If the original arc lamp file was trimmed, you need to add in a
;; pixel offset to the IRAF coordinates which are in the trimmed
;; images reference frame.
   if seccount GE 1 then begin
      pixel = pixel + trimreg[0]
   endif
endif


!p.multi = [0,0,2]
plot,pixel,wavel,psym=4,$
     xtitle='Pixels',$
     ytitle='Wavelength ('+cgGreek('mu')+'m)',$
     xrange=[0,max(pixel)]

polyMod = poly_fit(pixel,wavel,Npoly)
xshow = findgen(round(max(pixel)))
yshow = poly(xshow,polyMod)

oplot,xshow,yshow,color=mycol('yellow')

resid = wavel - eval_poly(pixel,polyMod)

plot,wavel,resid,psym=4

!p.multi = 0

return,PolyMod
end
