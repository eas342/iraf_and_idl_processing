pro save_image,fileL,usescale=usescale,lineP=lineP,zoombox=zoombox,$
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
   device,xsize=14, ysize=10,decomposed=1,/color

   fits_display,fileL[i],usescale=usescale,lineP=lineP,zoombox=zoombox,$
                message=''


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
