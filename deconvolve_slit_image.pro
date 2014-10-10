pro deconvolve_slit_image,narArNm,WideArcNm,showplots=showplot
;; De-convolves the slit image from the 3x60 arc image by using a
;; 0.3x60 arc image and my function slit_deconvolution

EndRow = 608
StartRow = 21

a = mrdfits('arc-00010.a.fits',0,headN)
b = mrdfits('arc-00034.a.fits',0,headW)
xlength = fxpar(headW,'NAXIS1')
ylength = fxpar(headW,'NAXIS2')
outimage = fltarr(xlength,ylength)

for i=startRow,EndRow do begin
   outImage[*,i] = slit_deconvolution(a[*,i],b[*,i],showplots=showplots)
endfor

writefits,'wide_slit_image.fits',outImage,headW

end
