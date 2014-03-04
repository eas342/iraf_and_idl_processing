pro correct_linearity
;; Corrects images for linearity
Gain = 12.1E ;; e-/s
;; according to Rayner 4 Years of Good SpeX paper
Saturation = 8500l ;; DN
;; according to Rayner 4 Years of Good SpeX paper

;; Find images
cd,current=current
fileData = file_search(current+'/run*.a.fits')
fileFlat = file_search(current+'/flat*.a.fits')
fileDark = file_search(current+'/dark*.a.fits')
fileArc = file_search(current+'/arc*.a.fits')
;filel = [fileData,fileFlat,FileDark,fileArc]
filel = [fileData]

nfile = n_elements(filel)

;; Get the nonlin coefficients
restore,filepath('lc_coeff.sav', ROOT=file_dirname(file_which('SpeX.dat'),/MARK))

;; Saturation level
satImg = lonarr(1024,1024) + 6000l

for i=0l,nfile-1l do begin
   a = long(mrdfits(filel[i],0,header,/fscale)) ;; force to be long integer
   ;; change bits to 32
   sxaddpar,header,'BITPIX',32

   NDR = float(fxpar(header,'NDR'))
   divisor = float(fxpar(header,'DIVISOR'))
   itime = float(fxpar(header,'ITIME'))
   slowcnt = float(fxpar(header,'slowcnt'))

   divided = a/divisor

   correctimg = round(mc_spexlincor(divided,itime,slowcnt,ndr,lc_coeff,satImg)*divisor)

   ;; Set all points < 0 and >saturation to 0. 
   outsidep = where(correctimg LT 0l or correctimg GT round(float(saturation) * float(divisor)* 1.2E))

   ;; For those points, set them equal to zero
   if outsidep NE [-1] then correctimg[outsidep] = 0l

   suffixpos = strpos(filel[i],'.fits')
   outfile = strmid(filel[i],0,suffixpos)+'_lincor.fits'
   fxaddpar,header,'NONLIN',1,'Have Non-linear corrections been done?'

   writefits,outfile,correctimg,header
;if i GE 6 then stop
end

end
