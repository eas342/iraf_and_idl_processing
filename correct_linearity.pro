pro correct_linearity
;; Corrects images for linearity

;; Find images
cd,current=current
filel = file_search(current+'/bigdog*.a.fits')
nfile = n_elements(filel)

;; Get the nonlin coefficients
restore,filepath('lc_coeff.sav', ROOT=file_dirname(file_which('SpeX.dat'),/MARK))

;; Saturation level
satImg = lonarr(1024,1024) + 6000l

for i=0l,nfile-1l do begin
   a = mrdfits(filel[i],0,header)
   NDR = float(fxpar(header,'NDR'))
   divisor = float(fxpar(header,'DIVISOR'))
   itime = float(fxpar(header,'ITIME'))
   slowcnt = float(fxpar(header,'slowcnt'))


   correctimg = round(mc_spexlincor(a/divisor,itime,slowcnt,ndr,lc_coeff,satImg)*divisor)

   suffixpos = strpos(filel[i],'.fits')
   outfile = strmid(filel[i],0,suffixpos)+'_lincor.fits'
   fxaddpar,header,'NONLIN',1,'Have Non-linear corrections been done?'

   writefits,outfile,correctimg,header

end

end
