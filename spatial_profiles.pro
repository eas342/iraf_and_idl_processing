pro spatial_profiles,psplot=psplot,separation=separation,OverlayStars=OverlayStars,$
                     nProfiles=nProfiles,cumulativeFlux=cumulativeFlux,$
                     customIndex=customIndex,divideOut=divideOut
;; This script looks for any unusual aspects of the spatial background
;; profile that might affect one star differently from the other
;; psplot - generates a postscript plot
;; seperation - if set, lets you control the separation of the plots
;; OverlayStars - overlay the two stellar profiles
;; nProfiles - how many profiles to look at
;; cumulativeFlux -- show the total flux grows as a function of
;;                   aperture radius
;; divideOut -- divide out all profiles by the median


StarHalfRange = 30 ;; half the range to show if zooming in on star
BackgStart = 17 ;; distance from star to start background estimation

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   case 1 of
      keyword_set(cumulativeFlux): plotprenm='prof_cumulative'
      keyword_set(OverlayStars): plotprenm='prof_comparison_overlay'
      else:  plotprenm = 'prof_comparison'
   endcase
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=14, ysize=10,decomposed=1,/color
endif

readcol,'straight_science_images.txt',format='(A)',filen
nfiles = n_elements(filen)
startTherm = 435 ;; Where thermal emission starts to dominate
if n_elements(separation) EQ 0 then separation = 0.03

if keyword_set(customIndex) then begin
   fileIndex = customIndex
   nProfiles=1
endif else begin
   if n_elements(nProfiles) EQ 0 then nProfiles = 7
   fileIndex = round(findgen(nProfiles)/float(nProfiles) * float(nfiles))
endelse

;; color options between images
colorOptions = [!p.color,mycol(['red','blue','dgreen'])]
Ncoptions = n_elements(colorOptions)
colorArr = colorOptions[findgen(nProfiles) mod Ncoptions]

;; line style options between stars
StyleOpt = [0,2]

;for i=0l,nfiles-1l do begin
for i=0l,nProfiles-1 do begin
   a = mrdfits(filen[fileIndex[i]],0,header)
   ;; find the profile, excluding 
   prof = total(a[0:startTherm-1l,*],1)
   NormVal = median(Prof)
   normProf = prof/NormVal
   offset = separation * i
   date = fxpar(header,'DATE_OBS')
   Longtime = fxpar(header,'TIME_OBS')
   ;; Round the time to the nearest second
   splitTime = strsplit(Longtime,':',/extract)
   time = splitTime[0]+':'+splitTime[1]+':'+strtrim(round(float(splitTime[2])),1)

   Nrows = fxpar(header,'NAXIS2')
   RowArr = lindgen(Nrows)

   ;; Make an array for all profiles
   if n_elements(fullArray) EQ 0 then begin
      fullArray = fltarr(nProfiles,Nrows)
   endif

   if keyword_set(OverlayStars) then begin
      ;; Show the stars re-normalized on top of each other
;      oplot,Rowarr - 266.5,(normProf - median(NormProf)) * 1.6 +
;                     Median(NormProf)- offset - 0.08,linestyle=2
      profstruct = create_struct('data',[[RowArr],[normProf]])
      mc_findpeaks,profstruct,2,1,posit,apsign,/auto
      for j=0l,1l do begin
         Lowp = max([0,posit[j] - StarHalfRange])
         Highp = min([Nrows-1l,posit[j] + StarHalfRange])
         xplot = RowArr[Lowp:Highp] - posit[j]
         yclose = normprof[Lowp:Highp]
         backgPts = where(abs(xplot) GT backgStart)
         ybackg = yclose[backgPts]
         ;; Fit a line to the background
         coeff = robust_linefit(xplot[backgPts],yclose[backgPts])
         yfit = coeff[0] + coeff[1] * xplot 
         ysub = yclose - yfit ;; background subtraction

         ytotal = total(ysub)
         yplot = ysub/ytotal

         if keyword_set(cumulativeFlux) then begin
            ;; First 
            ycum = total(ysub,/cumulative)
            radiiArr = lindgen(floor(StarHalfRange))
            tabinv,xplot,0.0,FloatCenterIndex
            centerIndex = round(FloatcenterIndex)
            LowP = centerIndex - radiiArr
            HighP = centerIndex + radiiArr
            MaxP = ytotal
            NormFlux = (ycum[HighP] - ycum[Lowp])/ytotal
            if i EQ 0 and j EQ 0 then begin
               plot,radiiArr,NormFlux,$
                    xtitle='Radius (px)',$
                    ytitle='Flux Fraction - Offset',$
                    yrange = [0E - separation * (nProfiles-1),1.2E],$
                    xrange=[0E, 1.3E * float(starHalfRange)]
            endif else begin
               oplot,radiiArr,NormFlux - offset,color=colorArr[i],$
                     lineStyle=styleOpt[j]
            endelse
            lastY = 1.0 - offset
            xtext = 1.05 * float(starHalfRange)
            
         endif else begin
            if i EQ 0 and j EQ 0 then begin
               plot,xplot,yplot,$
                    xtitle='Spatial Pixels',$
                    ytitle='Normalized Flux',$
                    xrange = [-StarHalfRange,StarHalfRange * 1.4E],$
                    yrange=[0E - 0.05E - separation * nProfiles,0.2E],$
                    xstyle=1
               ;; Show Error Bar
               rsigma = robust_sigma(ybackg/ytotal)
               oploterror,[-StarHalfRange/2E],[separation * 0.5E],[0E],$
                          rsigma
            endif else begin
               oplot,xplot,yplot - offset,color=colorArr[i],$
                     lineStyle=styleOpt[j]
            endelse
            lastY = -offset + separation * 0.2E
            xtext = StarHalfRange * 1.02
         endelse
      endfor
      if i EQ nProfiles-1 then begin
         al_legend,/left,/bottom,$
                   ['Planet Host','Reference'],$
                   linestyle=styleOpt
      endif

      
   endif else begin
      if i EQ 0 then begin
         plot,RowArr,normprof,$
              xtitle='Row (spatial pixels)',$
              ytitle='Normalized Flux',$
              yrange=[1E - separation * 2E - separation * nProfiles,1E + separation],$
              xrange=[0,1.2E * Nrows]
      endif else begin
         oplot,RowArr,normProf - offset,color=colorArr[i]
      endelse
      lastY = normprof[Nrows-10l] - offset + separation * 0.3E ;; Y position for text output
      xtext = Nrows * 1.02
   endelse
   xyouts,xtext,lastY,time
   if i EQ nProfiles-1 then begin
      xyouts,xtext,lastY - separation,'('+date+')'
   endif
   fullArray[i,*] = normprof
            

endfor

if keyword_set(divideOut) then begin
   medianProf = median(fullArray,dimension=1)
   medianDup = rebin(transpose(medianProf),nProfiles,Nrows)
   Profratio = fullArray/medianDup
   for i=0l,Nprofiles-1l do begin
      offset = separation * i
   
      if i EQ 0 then begin
         plot,RowArr,Profratio[i,*],$
              xtitle='Row (spatial pixels)',$
              ytitle='Normalized, divided flux',$
              yrange=[1E - 2E * separation - separation * nProfiles,1E + 2E * separation],$
              xrange=[0,1.2E * Nrows]
      endif else begin
         oplot,rowArr,profRatio[i,*] - offset,color=colorArr[i]
      endelse
   endfor
endif

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


