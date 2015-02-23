pro deconvolve_slit_image,narArNm,WideArcNm,showplots=showplots,$
                          custom1=custom1,custom2=custom2
;; De-convolves the slit image from the 3x60 arc image by using a
;; 0.3x60 arc image and my function slit_deconvolution
;; custom1 - custom set of exposures
;; custom2 - save the intermediate de-convolved arc image step


if keyword_set(custom1) or keyword_set(custom2) then begin
   a = mrdfits('arc-00035-trimmed.fits',0,headW)
   b = mrdfits('arc-00023-trimmed.fits',0,headN)
   startrow = 0
   endrow= 584
endif else begin
   EndRow = 608
   StartRow = 21
   a = mrdfits('arc-00010.a.fits',0,headN)
   b = mrdfits('arc-00034.a.fits',0,headW)
endelse

xlength = fxpar(headW,'NAXIS1')
ylength = fxpar(headW,'NAXIS2')
outimage = fltarr(xlength,ylength)
interImage = fltarr(xlength,ylength) ;; intermediate step image of the de-convolved arc image

case 1 of 
   keyword_set(custom1): begin
;   custrow = 327 - 2
      custrow = 327 - 1
      startRow = custrow
      endRow = startRow
      for i=startRow,EndRow do begin
         outImage[*,i] = slit_deconvolution(a[*,i],b[*,i],showplots=1,psplot=0,useplain=0,deconvstep=1)
;      outImage[*,i] = slit_deconvolution(a[*,i],b[*,i],showplots=1,psplot=1,/useplain,deconvstep=deconvstep)
;      outImage[*,i] =
;      slit_deconvolution(a[*,i],b[*,i],showplots=1,psplot=1)
      endfor
      set_plot,'ps'
      !p.font=0
      !p.thick=2
      !x.thick=3
      !y.thick=3
      plotprenm='slit_fit'
      device,encapsulated=1, /helvetica,$
             filename=plotprenm+'.eps'
      device,xsize=11, ysize=9,decomposed=1,/color
      plot,outimage[*,custrow],$
           xtitle='Column Number',ytitle='Slit Function',$
           xrange=[440,560]
      device, /close
;   cgPS2PDF,plotprenm+'.eps'
;   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
      device,decomposed=0
      set_plot,'x'
      !p.font=-1
      !p.thick=1
      !x.thick=1
      !y.thick=1
      yslit = outimage[*,custrow]
      xslit = findgen(n_elements(outimage[*,custrow]))+1
      forprint,xslit,yslit,textout='slit_function.txt',$
               comment='Column number in 1 based counting from [65:749,33:617] trim, Calculated slit function'
      
;   forprint,xslit,deconvstep,textout='arc_deconv_step.txt',$
;            comment='Column number in 1 based counting from [65:749,33:617] trim, Calculated slit function'
;   outImage = slit_deconvolution(a[*,i],b[*,i],showplots=showplots)
   end
   keyword_set(custom2): begin
      for i=startRow,EndRow do begin
         outImage[*,i] = slit_deconvolution(a[*,i],b[*,i],showplots=showplots)
         restore,'data/deconv_step_data.sav'
         imagePoints = where(xcolumn GT 0)
         interImage[*,i] = fulldeltas[imagePoints]
      endfor
      writefits,'data/intermediate_deconv_step.fits',interImage,headN
   end
   else: begin
      for i=startRow,EndRow do begin
         outImage[*,i] = slit_deconvolution(a[*,i],b[*,i],showplots=showplots)
         interImage[*,i] = fulldeltas[imagePoints]
      endfor
      writefits,'wide_slit_image.fits',outImage,headW
   end
endcase
   
end
