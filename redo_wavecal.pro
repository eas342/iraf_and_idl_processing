pro redo_wavecal
;; Re-does the wavelength calibration for my extractions (which goes a
;; lot faster than ev_backsub

readcol,'straight_science_images.txt',$
        straightlist,format='(A)'

nfile = n_elements(straightlist)

update = 50

for i=0l,nfile-1l do begin
   esNm = clobber_exten(straightlist[i])+'_es_ms.fits'
   if not file_exists(esNm) then begin
      message,'spectrum for '+esNm+' not found'
   endif
   spec = mrdfits(esNm,0,head,/silent)
   if i EQ 0 then begin
      if fxpar(head,'BANDID6') NE 'Wavelength' then begin
         message,'BandID 6 not the correct band for wavelength'
      endif
      SImg = mrdfits(straightlist[i],0,shead,/silent)
      xlength = fxpar(shead,'NAXIS1')
      xInd = findgen(xlength) + 1E
      wavPol = transpose(wavecal()) ;; polynomial coefficients
      lambda = poly(xind,wavPol) ;; wavelength for all images
   endif
   ;; Ensure that the spectrum length is the same as the image
   if xlength NE fxpar(head,'NAXIS1') then begin
      message,'Master wavelength calibration not same length as extracted spectrum'
   endif
   nap = fxpar(head,'NAXIS2');; number of apertures
   newWavs = rebin(lambda,xlength,nap)
   spec[*,*,5] = newWavs
   writefits,esNm,spec,head
   if i mod update Eq 0 then begin
      print,i,' of ',nfile,' done'
   endif
endfor

end
