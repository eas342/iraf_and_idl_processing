pro disp_plot,X,Y,gparam=gparam,restore=restore
;; Generalized plotter that is flexible and doesn't require
;; re-writing code
;; Ideally everything is in a structure data and all plot parameters
;; are stored in gparam, but it will also take x,y if both are specified
;; EXAMPLE
;;gparam = create_struct('PKEYS',['WAVEL','SUM'],$
;;                       'TITLES',['Wavelength (um)','Flux (W/m^2)',''],$
;;                       'SERIES','ORD','SLABEL','Order')
;;disp_plot,yp,gparam=gparam
;; will plot spectra colored by series

;; If asked to restore previous settings
if keyword_set(restore) then begin
   fileList = file_search('ev_local_pparams.sav')
   if fileList NE '' then begin
      restore,'ev_local_pparams.sav'
   endif
endif


;; Set up postscript, PDF and PNG plots
if ev_tag_true(gparam,'PS')then begin
   set_plot,'ps'
   !p.font=0
   if not ev_tag_exist(gparam,'FILENAME') then begin
      plotprenm='unnamed_genplot'
   endif else begin
      plotprenm=gparam.filename
   endelse
   if ev_tag_true(gparam,'PSSMALL') then begin
      PSxsize=14.2
      PSysize=10
;      PSxsize=10
;      PSysize=7 ;; extra small - good for presentations
   endif else begin
      PSxsize=20
      PSysize=9
   endelse
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=PSxsize, ysize=PSysize,decomposed=1,/color
   thick=2
   xmarginLeg = [11,24]
   xmarginSimp = [11,4]
   legCharsize =0.7
endif else begin
   thick=1
   xmarginLeg = [15,30]
   xmarginSimp = [15,4]
   legCharsize =1
endelse

if ev_tag_true(gparam,'NOMARGLEG') then begin
   xmargin = xmarginSimp
endif else xmargin = xmarginLeg

npt = n_elements(X)
type = size(X,/type)

if type NE 8 then begin
   ;; Make a structure if X and y are input
   if n_elements(Y) EQ 0 then begin
      ;; if only one array is input, assume that x is an index array
      ;; and y is the input array
      dat = struct_arrays(create_struct('INDEX',findgen(npt),'ARR',X))
      ev_add_tag,gparam,'PKEYS',['INDEX','ARR']
   endif else begin
      dat = struct_arrays(create_struct('X',X,'Y',Y))
      ev_add_tag,gparam,'PKEYS',['X','Y']
   endelse
endif else begin
   dat = x
   if n_elements(Y) NE 0 then edat = Y
endelse
tags = tag_names(dat)

if not ev_tag_exist(gparam,'PKEYS') then begin
   ev_add_tag,gparam,'PKEYS',[tags[0],tags[1]]
   ;; plot keys to describe tags to plot
endif
if not ev_tag_exist(gparam,'TITLES') then begin
   ev_add_tag,gparam,'TITLES',[gparam.PKEYS,'']
endif

XInd = where(gparam.PKEYS[0] EQ tags)
YInd = where(gParam.PKEYS[1] EQ tags)
if ev_tag_exist(gparam,'YERR') then begin
   YerrInd = where(gparam.yerr EQ tags)
endif
if ev_tag_exist(gparam,'XERR') then begin
   XerrInd = where(gparam.xerr EQ tags)
endif

if not ev_tag_exist(gparam,'GFLAG') then begin
   gflag = intarr(npt) + 1
endif else gflag = gparam.gflag
gInd = where(gflag EQ 1);; good indices
if gInd EQ [-1] then begin
   print,'No valid points to plot'
endif

dat = dat[gInd]

if ev_tag_exist(gparam,'ZOOMBOX') then begin
   myXrange = gparam.zoombox[0:1,0]
   myYrange = gparam.zoombox[0:1,1]
endif else begin
   if ev_tag_exist(gparam,'XTHRESH') then begin
      myXrange = threshold(dat.(Xind),mult=0.1)
   endif else myXrange = [min(dat.(Xind)),max(dat.(Xind))]
   if ev_tag_exist(gparam,'YTHRESH') then begin
      myYrange = threshold(dat.(Yind))
   endif else myYrange = [min(dat.(Yind)),max(dat.(Yind))]
endelse

if ev_tag_exist(gparam,'XLOG') then Xlog=1 else xlog=0
if ev_tag_exist(gparam,'YLOG') then Ylog=1 else Ylog=0

plot,dat.(Xind),dat.(Yind),$
     ystyle=1,xstyle=1,$
     xtitle=gparam.TITLES[0],$
     ytitle=gparam.TITLES[1],$
     title=gparam.TITLES[2],$
     xrange=myXrange,$
     yrange=myYrange,/nodata,$
     xmargin=xmargin,thick=thick,$
     xthick=thick,ythick=thick,$
     xlog=xlog,ylog=ylog

if not ev_tag_exist(gparam,'SERIES') then begin
   ;; if no series specified, use all points
   ev_add_tag,gparam,'SERIES','ALLPT'
endif
if gparam.series EQ 'ALLPT' then begin
;; If all points then make a series description for all points
   ev_add_tag,dat,'ALLPT',intarr(npt) + 1
   tags = tag_names(dat)
endif
serTag = where(gParam.SERIES EQ tags)
if serTag EQ [-1] then begin
   print,'********Series tag not found**********'
   return
endif
nser = max(dat.(serTag)) - min(dat.(serTag)) + 1;; number of series
serArr = indgen(nser + 1) + min(dat.(serTag))
;; later I may have it specified differently for non-integers

colArr = myarraycol(nser,psversion=ev_tag_true(gparam,'PS'))

if ev_tag_exist(gparam,'PSYM') then begin
   plotsym,0
   if gparam.psym[0] EQ 1 then begin
      mypsym=8 + fltarr(nser)
   endif else begin
      mypsym=gparam.psym
   endelse
endif else mypsym=fltarr(nser)

;; Plot the data as a function of series
for i=0l,nser-1l do begin
   serInd = where(dat.(serTag) GE serArr[i] and $
                  dat.(serTag) LT serArr[i+1])
   nserInd = n_elements(serInd)
   if serInd NE [-1] then begin
      oplot,dat[serInd].(Xind),dat[serInd].(Yind),$
           color=colArr[i],thick=thick,psym=mypsym[i]
      if ev_tag_exist(gparam,'YERR') OR ev_tag_exist(gparam,'XERR') then begin
         if not ev_tag_exist(gparam,'XERR') then begin
            xerr = fltarr(nserInd)
         endif else xerr = dat[serInd].(XerrInd)
         if not ev_tag_exist(gparam,'YERR') then begin
            yerr = fltarr(nserInd)
         endif else yerr = dat[serInd].(YerrInd)
         oploterror,dat[serInd].(Xind),dat[serInd].(Yind),$
                    xerr,yerr,$
               color=colArr[i],thick=thick
      endif
   endif
endfor

;; Make a legend for the series of plots
if nser GT 1 or ev_tag_exist(gparam,'SLABEL') then begin
   if ev_tag_exist(gparam,'SLABEL') then begin
      serLab = gparam.slabel
   endif else serLab = strtrim(serArr[0:nser-1l],1)
   if ev_tag_exist(gparam,'LEGLOC') then begin
      legPos = gparam.legloc
   endif else begin
      ;; Default on the top right, unless margin is shrunk
      if ev_tag_true(gparam,'NOMARGLEG') then begin
         legPos = [!x.crange[0],!y.crange[1]]
      endif else begin
         legPos = [!x.crange[1],!y.crange[1]]
      endelse
      if xlog then legPos[0] = 10E^(legPos[0])
      if ylog then legPos[1] = 10E^(legPos[1])
   endelse
   al_legend,serLab,$
             linestyle=0,thick=thick,bthick=thick,$
             color=colArr,charsize=LegCharsize,$
             position=legPos
endif

;; Draw extra lines from the edat (extra data structure)
for j=0l,1l do begin
   if j EQ 0 then begin
      linetag = 'VERTLINES' 
      lstyletag = 'VERTSTYLES'
   endif else begin
      linetag='HORLINES'
      lstyletag='HORSTYLES'
   endelse
   if ev_tag_exist(edat,linetag,index=lineindex) then begin
      nline = n_elements(edat.(lineindex))
      lineCols = myarraycol(nline,psversion=ev_tag_true(gparam,'PS'))
      if ev_tag_exist(edat,lstyletag,index=styleindex) then begin
         mylstyle = edat.(styleindex)
      endif else mylstyle = lonarr(nline)
      for i=0l,nline-1l do begin
         if j EQ 0 then begin
            xdraw = edat.(lineindex)[i] * [1D,1D]
            ydraw = !y.crange
         endif else begin
            xdraw = !x.crange
            ydraw = edat.(lineindex)[i] * [1D,1D]
         endelse
         if xlog then xdraw = 10E^(xdraw)
         if ylog then ydraw = 10E^(ydraw)
         oplot,xdraw,ydraw,color=linecols[i],$
            linestyle=mylstyle[i]
      endfor
   endif
endfor


if ev_tag_true(gparam,'PS') then begin
   device, /close
   cgPS2PDF,plotprenm+'.eps'
   spawn,'convert -density 300% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif
end
