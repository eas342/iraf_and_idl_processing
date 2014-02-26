pro backg_profiles,psplot=psplot,separation=separation,OverlayStars=OverlayStars
;; This script looks for any unusual aspects of the spatial background
;; profile that might affect one star differently from the other
;; psplot - generates a postscript plot
;; seperation - if set, lets you control the separation of the plots
;; OverlayStars - overlay the two stellar profiles

;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   !p.thick=2
   !x.thick=3
   !y.thick=3
   plotprenm = 'profile_comparison'
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=14, ysize=10,decomposed=1,/color
endif

readcol,'straight_science_images.txt',format='(A)',filen
nfiles = n_elements(filen)
startTherm = 435 ;; Where thermal emission starts to dominate
if n_elements(separation) EQ 0 then separation = 0.03

nProfiles = 7
fileIndex = round(findgen(nProfiles)/float(nProfiles) * float(nfiles))

colorOptions = [!p.color,mycol(['red','blue','dgreen'])]
Ncoptions = n_elements(colorOptions)
colorArr = colorOptions[findgen(nProfiles) mod Ncoptions]

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

   if keyword_set(OverLayStars) then begin
      ;; Show the stars re-normalized on top of each other
;      oplot,Rowarr - 266.5,(normProf - median(NormProf)) * 1.6 +
;                     Median(NormProf)- offset - 0.08,linestyle=2
      profstruct = create_struct('data',[[indices],[smoothprof]])
      mc_findpeaks,profstruct,2,1,posit,apsign,/auto
   endif else begin
      if i EQ 0 then begin
         Nrows = fxpar(header,'NAXIS2')
         RowArr = lindgen(Nrows)
         plot,RowArr,normprof,$
              xtitle='Row (spatial pixels)',$
              ytitle='Normalized Flux',$
              yrange=[1E - 0.05E - separation * nProfiles,1E + 0.05E],$
              xrange=[0,1.2E * Nrows]
      endif else begin
         oplot,RowArr,normProf - offset,color=colorArr[i]
      endelse
      lastY = normprof[Nrows-10l] - offset + separation * 0.3E ;; Y position for text output
      xyouts,Nrows * 1.02,lastY,time
      if i EQ nProfiles-1 then begin
         xyouts,Nrows * 1.02,lastY - separation,'('+date+')'
      endif
   endelse
   
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


