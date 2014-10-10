pro slit_deconvolution,filter=filter,psplot=psplot,$
                       useplainArgon=useplainArgon
;; Deconvolves a arc spectra to find the slit function
;; filter - does a low pass filter in Fourier domain
;; psplot - saves a postscript plot
;; useplainArgon - just use the 0.3x60 argon spectrum (don't
;;                 deconvolve it)

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   plotprenm='fft_deconv_argon_test'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=30, ysize=40,decomposed=1,/color
endif

!p.multi = [0,0,8]

Np = 2048l
midP = 512
;; Convolved one
restore,'slit3_arcspec.sav'
convolSD = fltarr(np)
nY = n_elements(yplot3)
convolSD[midP:(midP+nY-1)] = yplot3
sz = size(convolSD)

plot,convolSD,title='Convolution (3x60)',charsize=2

;; Delta functions
restore,'nar_slit_arcspec.sav'
;restore,'narrower_slit_arcspec_deconvol.sav'
;yplot = deltasDec
narArc = fltarr(Np)
narArc[midP:(midP+nY-1l)] = yplot
plot,narArc,title='Function (0.3x60)',charsize=2

if keyword_set(useplainArgon) then begin
   fulldeltas = narArc
endif else begin
   restore,'narrSKern.sav'
   normKern = narrSKern / total(NarrSkern)
   for i=0l,300 do Max_Likelihood, narArc, normkern, Narrdeconv,ft_psf=psf_ft
   fulldeltas = Narrdeconv
   plot,fulldeltas,title='De-convolved Argon',charsize=2
endelse
;fulldeltas[midP:(midP+nY-1l)] = yplot


;; Shifted Convolved

shiftConvolSD = shift(convolSD,-sz[1]/2)
plot,shiftConvolSD,title='Shifted Convolution (3x60)',charsize=2

fftconvolSD = fft(shiftConvolSD)/float(sz[1])
if keyword_set(filter) then begin
   filterAmt = 750l
   fftconvolSD[1024-filterAmt:1023+filterAmt] = complex(0E,0E)
endif
plot,fftconvolSD,title='FFT Shifted Convolution',charsize=2
oplot,imaginary(fftconvolSD),color=mycol('yellow')

fftdeltas = fft(fulldeltas)
if keyword_set(filter) then begin
   fftdeltas[1024-filterAmt:1023+filterAmt] = complex(0E,0E)
endif
plot,fftdeltas,title='FFT Function (0.3x60)',charsize=2
oplot,imaginary(fftdeltas),color=mycol('yellow')

nonZ = where(fftDeltas NE 0E)
fftDeconvol = complexarr(sz[1])
if nonz NE [-1] then fftDeconvol[nonz] = fftconvolSD[nonz]/fftDeltas[nonz]

plot,fftDeconvol,title='FFT Convolution / FFT Function',charsize=2
oplot,imaginary(fftDeconvol),color=mycol('yellow')

deconvol = fft(fftDeconvol,/inverse) * float(sz[1])
plot,deconvol,title='De-convolution (to get Kernel)',charsize=2

save,deconvol,filename='slit_func_estimate.sav'

;plot,fulldeltas,/nodata,yrange=[-.5,1.5],title='Function',charsize=2
;oplot,fulldeltas,color=mycol('red')
;
;;; Test the convolution with FFT
;
;fftconvolSD = fftSquare * fftDeltas
;plot,fftConvolSD,title='FFT Convolution',charsize=2
;oplot,imaginary(fftconvolsd),color=mycol('yellow')
;convolSDshift = fft(fftconvolSD,/inverse) * float(n_elements(square))
;plot,convolSDshift,title='Convolution (shifted by FFT)',charsize=2
;
;
;;oplot,square
!p.multi = 0

if keyword_set(psplot) then begin
   device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
   !p.thick=1
   !x.thick=1
   !y.thick=1
   
endif

end
