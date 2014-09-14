pro backsub,showB=showB,showPFit=showPFit,saveSteps=saveSteps,$
            showCRplot=showCRplot,comparSpec=comparSpec,$
            allimages=allimages,showStarshift=showstarshift,$
            showRatioFit=showRatioFit
;; Subtracts the background spectrum for a spectrograph image
;; showB -- show a plot of the background subtraction
;; also it generates a profile image for generating a point spread
;; function
;; showPfit - show profile fitting procedure
;; saveSteps - saves all steps as FITS images (more data
;;                 intensive, so it only does 10 images)
;; showCR - show the cosmic ray rejection
;; comparSpec - compare the spectra extracted with variance
;;              weighted/profile/sum extraction
;; allimages - process all images (instead of subset, which is the
;;             default for savesteps
;; showStarshift - show the shifting of the two stars in creating a
;;                 ratio image
;; showRatioFit - show fitting the ratio of the two stars to a polynomial

openr, 1,'es_local_parameters.txt'
; Define a string variable:
tempstring = ''
; Loop until EOF is found:
while ~ eof(1) do begin
   readf,1,tempstring
   junk = execute(tempstring)
endwhile
close,1

;; Get the list of spectrograph images
readcol,'straight_science_images.txt',$
        straightlist,format='(A)'
nfile = n_elements(straightlist)
backsubNames = strarr(nfile)
mprofNames = strarr(nfile);; measured profile
fprofNames = strarr(nfile);; fitted profile
rprofNames = strarr(nfile);; source- subtracted images
cprofNames = strarr(nfile);; cosmic ray images
dprofNames = strarr(nfile);; star ratio images

;; Make these directories if they don't exist
;dirlist = ['m_profiles','f_profiles']
;if dir_exist('profiles') EQ 0 then junk = spawn('mkdir profiles')
;if dir_exist('p

posit = fltarr(nfile,Nap) ;; aperture positions

if keyword_set(saveSteps) then lastfile = 9 else lastfile=nfile-1l
if keyword_set(allimages) then lastfile = nfile-1l

for i=0l,lastfile do begin
   a = mrdfits(straightlist[i],0,header,/silent) * Gain ;; make everything in electrons
   ;; get the aperture center
   posit[i,*] = retrieve_apcenter(straightlist[i],Nap)
   Xlength =  fxpar(header,'NAXIS1')
   Ylength =  fxpar(header,'NAXIS2')

;   SubstractStart = 50 ;; column (X) to start doing background subtraction
;EndSubtract = 495 ;; column (X) to stop doing background subtraction
   SubtractStart = 0 ;; column (X) to start doing background subtraction
   EndSubtract = Xlength-1l ;; column (X) to stop doing background subtraction

   rowNum = findgen(Ylength)  ;; row number
   colNum = findgen(Xlength)  ;; column number
   outImage = a
   profImage = a
   fitImage = fltarr(xlength,ylength) ;; profile fits
   resImage = fltarr(xlength,ylength) ;; profile-subtracted (residuals)
   cosImage = intarr(xlength,ylength) ;; cosmic ray image
   varImage = fltarr(xlength,ylength) ;; variance image

   bandIDS = ['Optimal','Sum','Background','Sigma','ProfWeighted','Wavelength',$
              'StarRatio']
   NSpectypes = n_elements(bandIDs) ;; number of spectral types to save in extraction
   optflux = fltarr(Xlength,Nap) ;; optimal extraction of flux
   sumflux = fltarr(Xlength,Nap) ;; sum extraction (not optimal extraction)
   bflux = fltarr(Xlength,Nap) ;; background spectra
   sigflux = fltarr(Xlength,Nap) ;; uncertainty in optimally extracted flux
   proflux = fltarr(Xlength,Nap) ;; profile-weighted extraction (profile-weighted extraction, which applies in the case of background limited observations)
   fluxrat = fltarr(Xlength,Nap) + 1E;; ratio of the stars (stored in ap 0)
   bsigmas = fltarr(Xlength) ;; standard deviation in background

   MaskArray = intarr(Ylength)
   Lowp = lonarr(Nap)
   Highp = lonarr(Nap)
   for k=0l,Nap-1l do begin
      ;; Choose a region surrounding the aperture 
      LowP[k] = max([0l,posit[i,k] - Backsize])
      HighP[k] = min([Ylength-1l,posit[i,k] + Backsize])
      MaskArray[LowP[k]:HighP[k]] = 1
   endfor

   for m=0l,CRIter-1l do begin
      if m GT 0 then a = replace_pixels(a,badpix,showP=showCRplot)
      for j=SubtractStart,EndSubtract do begin
         
         ;; Fit background with a robust polynomial & subtract
         modelBParams = ev_robust_poly(rownum,transpose(a[j,*]),Bpoly,$
                                       mask=maskArray,niter=Fiter,$
                                       showplot=showB,Nsig=Nsig,sigma=backsigma)
         
         for k=0l,Nap-1l do begin
            ;; Save the background flux
            bflux[j,k] = eval_poly(posit[i,k],modelBParams)
         endfor
         
         ;; Save the background uncertainty
         bsigmas[j] = backsigma
         
         outImage[j,*] = a[j,*] - eval_poly(rownum,modelBParams)
         profimage[j,*] = norm_array(transpose(outimage[j,*]),apsize,posit[i,*])
         
         if keyword_set(showplot) and j GT 90 then begin
            plot,profimage[j,*]
         endif
      endfor
      ;; Fit the spatial profiles
      ApStart = lonarr(Nap)
      ApEnd = lonarr(Nap)
      
      ;; Make a mask below the shortest wavelengths and above the longest
      ProfileMask = fltarr(Xlength)
      ProfileMask[0l:ApXStart] = 1
      ProfileMask[ApXEnd:Xlength-1l] = 1
      ;; Fit the spatial profiles with smooth polynomials
      for k=0l,Nap-1l do begin
         ApStart[k] = max([posit[i,k] - apsize,0l])
         ApEnd[k] = min([posit[i,k] + apsize,Ylength-1l])
         for j=ApStart[k],ApEnd[k] do begin
            PPolyFits = ev_robust_poly(colnum,profImage[*,j],Spoly,showplot=showPfit,$
                                       mask=ProfileMask)
            fitImage[*,j] = eval_poly(colnum,PPolyFits)
         endfor
      endfor
      for j=SubtractStart,EndSubtract do begin
         ;; Renormalize row by row
         fitImage[j,*] = norm_array(transpose(fitimage[j,*]),apsize,posit[i,*])
      endfor
      
      ;; Find the sum extraction
      for k=0l,Nap-1l do begin
         sumFlux[*,k] = total(outimage[*,Apstart[k]:ApEnd[k]],2)
      endfor
      
      ;; Find the profile-weighted spectrum
      for k=0l,Nap-1l do begin
         proflux[*,k] = total(outimage[*,Apstart[k]:ApEnd[k]] * fitImage[*,Apstart[k]:ApEnd[k]],2) /$
                        total(fitImage[*,Apstart[k]:ApEnd[k]]^2,2)
      endfor
      
      ;; Find the variance estimator & variance-weighted optimal extraction
      varImage = rebin(bsigmas^2,xlength,ylength) + readN^2 ;; background & read noise
      for k=0l,Nap-1l do begin ;; now the source noise from the fitted profile
         varImage[*,Apstart[k]:ApEnd[k]] = varImage[*,Apstart[k]:ApEnd[k]] + $
                                              fitImage[*,Apstart[k]:ApEnd[k]] *$
                                           rebin(proflux[*,k],xlength,ApEnd[k] - Apstart[k]+1l)
         optflux[*,k] = total(outimage[*,Apstart[k]:ApEnd[k]] * fitImage[*,Apstart[k]:ApEnd[k]]/$
                              varImage[*,Apstart[k]:ApEnd[k]],2) /$
                        total(fitImage[*,Apstart[k]:ApEnd[k]]^2/$
                              varImage[*,Apstart[k]:ApEnd[k]],2)
      endfor


      ;; Save the wavelength solution (only the first time through)
      if i EQ 0 and m EQ 0 then begin
         wavelSol = wavecal() ;; get it from the firstwavecal database file
         lamgrid = eval_poly(findgen(Xlength),wavelSol)
      endif

      ;; optimal extraction error
      for k=0l,Nap-1l do begin
         variance = total(fitImage[*,Apstart[k]:ApEnd[k]],2)/$
                    total(fitImage[*,Apstart[k]:ApEnd[k]]^2 / varImage[*,Apstart[k]:ApEnd[k]],2)
         sigflux[*,k] = sqrt(variance)
      endfor

      
      ;; show the residuals
      resImage = outImage         ;; start with the background-subtracted image
      NApPixels = ApEnd - ApStart +1l ;; number of aperture pixels
      
      for k=0l,Nap-1l do begin
         resImage[*,ApStart[k]:ApEnd[k]] = outimage[*,Apstart[k]:ApEnd[k]] - $
                                           rebin(optflux[*,k],Xlength,NApPixels[k]) * fitimage[*,ApStart[k]:ApEnd[k]]
      endfor
      ;; Divide by sqrt(variance) for number of sigma away
      resImage = resImage / sqrt(varImage)
      ;; Find bad pixels from the residual image
      ;; for asymmetric distribution (like if there are
      ;; unsubtracted sources, it is better to use asymmetric sigmas
;         rsigma = robust_sigma(resImage)
      pospix = where(resImage GT 0,complement=negpix)
      highSig = median(resImage[pospix])
      lowSig = median(resImage[negpix])
      badpix = where(resImage GT CRsigma * highSig OR $
                     resImage LT CRsigma * lowSig)

      if keyword_set(showCRplot) then begin
         plothist,resImage,xrange=[lowSig,highSig] * 5E * CRsigma,/ylog
         oplot,CRsigma * highSig * [1E,1E],10E^!y.crange,color=mycol('yellow')
         oplot,CRsigma * lowSig * [1E,1E],10E^!y.crange,color=mycol('yellow')
         stop
      endif
      if badpix NE [-1] then cosImage[badpix]= 1l

      if keyword_set(comparSpec) then begin
         for k=0l,Nap-1l do begin
            colorArr = myarraycol(3)
            plot,sumflux[*,k],xtitle='Spectral pixel',$
                 ytitle='Flux',color=colorArr[0]
            oplot,proflux[*,k],color=colorArr[1]
            oplot,optflux[*,k],color=colorArr[2]
            al_legend,['Sum','Profile-Weighted','Optimal'],color=colorArr,linestyle=0
            stop
            endfor
      endif
      

      ;; Find the ratio image. Separate this from the Cosmic Ray
      ;; iteration loop
;      if i EQ 0 then begin
         fixApstart = Apstart
         fixApend = ApEnd
         ratioYSize = fixApend[0] - fixApstart[0] + 1l
         ratioYind = findgen(ratioYSize)
         midSubApYarr = ratioYsize/2
;      endif
      star1img = outimage[*,fixApstart[0]:fixApEnd[0]]
      star2img = outimage[*,fixApstart[1]:fixApEnd[1]]
;      star1img = fitimage[*,fixApstart[0]:fixApEnd[0]]
;      star2img = fitimage[*,fixApstart[1]:fixApEnd[1]]
      ;; Find the shift of the two stars, only the first time
;      if i EQ 0 then begin
         star1quickProf = total(fitImage[*,fixApstart[0]:fixApEnd[0]],1)
         star2quickProf = total(fitImage[*,fixApstart[1]:fixApEnd[1]],1)
      ;; shift to match the core and peak, not so much wings
         shiftAmt = cross_cor_find(star1quickProf,star2quickProf,$
                                   nlag=50l,fitsize=3l,showplot=showstarshift)
;      midAp = round(apsize)
;      corestart = MidAp - round(Apsize/2E)
;      coreend = midAp + round(Apsize/2E)
;      endif
      star2img = transpose(shift_interp(transpose(star2img),-shiftAmt))
      nonzeropt = where(star2img NE 0E,complement=zeropt)
      ratioImg = star1img
      if nonzeropt NE [-1] then $
         ratioImg[nonzeropt] = star1img[nonzeropt]/star2img[nonzeropt]
      if zeropt NE [-1] then $
         ratioImg[zeropt] = !values.f_nan
      ;; Find the variance in the ratio
      star1imgVar = varimage[*,fixApstart[0]:fixApEnd[0]]
      star2imgVar = varimage[*,fixApstart[1]:fixApEnd[1]]
      star2imgVar = transpose(shift_interp(transpose(star2imgVar),-shiftAmt))
      star2imgFErr = sqrt(star1imgVar)/abs(star2img)
      star1imgFErr = sqrt(star1imgVar)/abs(star1img)
      ratioImgErr = abs(ratioImg) * sqrt(star1imgFErr^2 + star2imgFErr^2)

      for j=0l,Xlength-1l do begin
         polyRatioFit = ev_robust_poly(ratioYind,transpose(ratioImg[j,*]),$
                                       0,showPlot=showRatioFit,$
                                       yerr=transpose(ratioImgErr[j,*]),$
                                      custYrange=[-2,2.5],nsig=2E)
         fluxrat[j,0] = eval_poly(midSubApYarr,polyRatioFit)
         if keyword_set(showRatioFit) then begin
            oplot,[midSubApYarr],[fluxrat[j,0]],psym=4,symsize=2,color=mycol('red')
            oploterr,ratioYind,transpose(ratioImg[j,*]),transpose(ratioImgErr[j,*])
            stop
         end
      endfor
      
      ;; Save the spectrum
      finalData = fltarr(Xlength,Nap,NSpecTypes)
      for k=0l,Nap-1l do begin
         finalData[*,k,0] = sumflux[*,k]
         finalData[*,k,1] = optflux[*,k]
         finalData[*,k,2] = bflux[*,k]
         finalData[*,k,3] = sigflux[*,k]
         finalData[*,k,4] = proflux[*,k]
         finalData[*,k,5] = lamgrid
         finalData[*,k,6] = fluxrat[*,k]
      endfor
      postpos = strpos(straightlist[i],'.fits')
      outprefix = strmid(straightlist[i],0,postpos)
      fluxhead = header
      
      sxaddpar,fluxhead,'NAXIS',3
      sxaddpar,fluxhead,'NAXIS2',Nap
      sxaddpar,fluxhead,'NAXIS3',NSpecTypes
      sxaddpar,fluxhead,'Extracted','TRUE','Fluxes are extracted'
      for l=0l,NSpecTypes-1l do begin
         sxaddpar,fluxhead,'BANDID'+strtrim(l+1,1),bandIDS[l],"Band explanation"
      endfor
      sxaddpar,fluxhead,'APNUM1','1 1 '+strtrim(ApStart[0],1)+' '+strtrim(ApEnd[0],1)
      writefits,outprefix+'_es_ms.fits',finalData,fluxhead
      
   endfor
   
   
   if keyword_set(saveSteps) then begin ;; save all steps as FITS images (data intensive)
      bheader = header                             ;; header for background
      pheader = header                             ;; header for profile measurement
      fheader = header                             ;; header for the normalized profile fit
      rheader = header                             ;; header for the profile-subtracted image
      cheader = header                             ;; header for the marked cosmic ray hits/bad pixels
      dheader = header                             ;; header for ratio image

      sxaddpar,bheader,'BACKSUB','TRUE','Background Subtraction performed'
      sxaddpar,pheader,'PROFILE','TRUE','Normalized profile'
      sxaddpar,pheader,'FITPROFILE','TRUE','Normalized fit profile'
      sxaddpar,sheader,'SourceSub','TRUE','Source subtracted'
      sxaddpar,cheader,'BadPix','TRUE','Bad Pixels/Cosmic Rays are marked'
      sxaddpar,cheader,'BITPIX',16,''
      sxaddpar,dheader,'NAXIS1',n_elements(ratioImg[*,0])
      sxaddpar,dheader,'NAXIS2',n_elements(ratioImg[0,*])
      sxaddpar,dheader,'Ratio','TRUE','Ratio of two stars'

      backsubNames[i] = outprefix+'_backsub.fits'
      mprofNames[i] = outprefix+'_m_profile.fits'
      fprofNames[i] = outprefix+'_f_profile.fits'
      rprofNames[i] = outprefix+'_subtracted.fits'
      cprofNames[i] = outprefix+'_c_ray.fits'
      dprofNames[i] = outprefix+'_ratio.fits'
      
      writefits,backsubNames[i],outImage,bheader
      writefits,mprofNames[i],profImage,pheader
      writefits,fprofNames[i],fitImage,fheader
      writefits,rprofNames[i],resImage,rheader
;      writefits,cprofNames[i],cosImage,cheader
      writefits,dprofNames[i],ratioImg,dheader
   endif
   
   ;; Print an update every 50 files
   if i mod 50 EQ 0 then print,'Image '+outprefix+' done'
endfor

forprint,backsubNames,textout='backsub_list.txt'

end
