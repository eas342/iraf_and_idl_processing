pro save_image,fileL,lineP=lineP,plotp=plotp,$
                     startslot=startslot,all=all
;; Saves a FITS images of the current slot as an EPS file
;; It returns the last index the user stopped with
;; set the up the PS plot

if n_elements(startslot) EQ 0 then i=0l else i=startslot

splitFileN = strsplit(fileL[i],'/',/extract)
FullFitsName = splitFilen[n_elements(splitFileN)-1l]
splitPrefix = strsplit(FullFitsName,'.',/extract)
namePrefix = splitPrefix[0]


   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   plotprenm = namePrefix
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'

   if n_elements(zoombox) NE 0 then begin
      psXlength = max(zoombox[*,0]) - min(zoombox[*,0])
      psYlength = max(zoombox[*,1]) - min(zoombox[*,1])
      if psXlength GT psYlength then begin
         psXs = 14
         psYs = 14E * float(psYlength)/float(psXlength)
         if pSYs LT 4E then psYs = 3E
      endif else begin
         psYs = 10
         psXs = 10E * float(psXlength)/float(psYlength)
         if pSXs LT 4E then psXs = 4E
      endelse

   endif else begin
      psXs = 14
      psYs = 10
   end
   device,xsize=psXs, ysize=psYs,decomposed=1,/color

   fits_display,fileL[i],plotp=plotp,lineP=lineP,$
                message=namePrefix+'.fits'


   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
   !p.thick=1
   !x.thick=1
   !y.thick=1
   
end
