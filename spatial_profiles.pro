pro spatial_profiles,psplot=psplot,separation=separation,OverlayStars=OverlayStars,$
                     nProfiles=nProfiles
;; This script looks for any unusual aspects of the spatial background
;; profile that might affect one star differently from the other
;; psplot - generates a postscript plot
;; seperation - if set, lets you control the separation of the plots
;; OverlayStars - overlay the two stellar profiles
;; nProfiles - how many profiles to look at

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   plotprenm = 'prof_comparison'
   if keyword_set(OverlayStars) then plotprenm = plotprenm+'_overlay'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=14, ysize=10,decomposed=1,/color
endif

readcol,'straight_science_images.txt',format='(A)',filen
nfiles = n_elements(filen)
startTherm = 435 ;; Where thermal emission starts to dominate
if n_elements(separation) EQ 0 then separation = 0.03

if n_elements(nProfiles) EQ 0 then nProfiles = 7
fileIndex = round(findgen(nProfiles)/float(nProfiles) * float(nfiles))
StarHalfRange = 30 ;; half the range to show if zooming in on star
BackgStart = 17 ;; distance from star to start background estimation

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
         ysub = yclose - median(ybackg) ;; median background subtraction
         ytotal = total(ysub)
         yplot = ysub/ytotal
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
              yrange=[1E - 0.05E - separation * nProfiles,1E + 0.05E],$
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
   
endfor
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


