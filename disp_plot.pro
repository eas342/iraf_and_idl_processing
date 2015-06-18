pro disp_plot,X,Y,gparam=gparam,restore=restore,$
              preponly=preponly,dat=dat,edat=edat
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
;; Preponly will prepare the gparam and data correctly but do no
;; plotting

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
   case 1 of 
      ev_tag_true(gparam,'PSXSMALL'): begin
         PSxsize=9
         PSysize=6 ;; extra small - good for presentations
      end
      ev_tag_true(gparam,'PSSMALL'): begin
         PSxsize=14.2
         PSysize=10
      end
      else: begin
         PSxsize=20
         PSysize=9
      end
   endcase
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
if npt EQ 0 then begin
   message,'Input undefined.',/cont
   return
endif

type = size(X,/type)

if type NE 8 then begin
   ;; Make a structure if X and y are input
   if n_elements(Y) EQ 0 then begin
      ;; if only one array is input, assume that x is an index array
      ;; and y is the input array
      dat = struct_arrays(create_struct('INDEX',findgen(npt),'ARR',X))
      ev_add_tag,gparam,'PKEYS',['INDEX','ARR'],/noerase
   endif else begin
      dat = struct_arrays(create_struct('X',X,'Y',Y))
      ev_add_tag,gparam,'PKEYS',['X','Y'],/noerase
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
if not ev_tag_exist(gparam,'SERIES') then begin
   ;; if no series specified, use all points
   ev_add_tag,gparam,'SERIES','ALLPT'
endif
if gparam.series EQ 'ALLPT' then begin
;; If all points then make a series description for all points
   ev_add_tag,dat,'ALLPT',intarr(npt) + 1
   tags = tag_names(dat)
endif

DataInd = key_indices(dat,gparam)
if ev_tag_exist(gparam,'YERR') then begin
   YerrInd = where(gparam.yerr EQ tags)
endif
if ev_tag_exist(gparam,'XERR') then begin
   XerrInd = where(gparam.xerr EQ tags)
endif
; Check if the arrays are strings and if so convert them to floats
for i=0l,1l do begin
   if size(dat.(dataInd[i]),/type) EQ 7 then begin
      if total(valid_num(dat.(dataInd[i]))) NE n_elements(dat) then begin
         message,'Attempted to plot invalid string',/cont
         return
      endif
      newArr = float(dat.(dataInd[i]))
      ev_undefine_tag,dat,gparam.pkeys[i]
      ev_add_tag,dat,gparam.pkeys[i],newArr 
      ;; the undefining and re-adding the field will re-order the
      ;; indices so you need to redo them
      ;; find the new indices
      DataInd = key_indices(dat,gparam)
      tags = tag_names(dat)
   endif
endfor


if not ev_tag_exist(gparam,'GFLAG') then begin
   gflag = intarr(npt) + 1
endif else gflag = gparam.gflag
gInd = where(gflag EQ 1);; good indices
if gInd EQ [-1] then begin
   message,'No valid points to plot'
   return
endif
if n_elements(gInd) EQ 1 then begin
   message,'Only 1 valid point to plot'
   return
endif
stop
dat = dat[gInd]

if ev_tag_exist(gparam,'ZOOMBOX') then begin
   myXrange = gparam.zoombox[0:1,0]
   myYrange = gparam.zoombox[0:1,1]
endif else begin
   if ev_tag_exist(gparam,'XTHRESH') then begin
      myXrange = threshold(dat.(DataInd[0]),mult=0.1)
   endif else myXrange = $
      [min(dat.(DataInd[0]),/nan),max(dat.(DataInd[0]),/nan)]
   if ev_tag_exist(gparam,'YTHRESH') then begin
      myYrange = threshold(dat.(DataInd[1]))
   endif else myYrange = $
      [min(dat.(DataInd[1]),/nan),max(dat.(DataInd[1]),/nan)]
endelse

if ev_tag_exist(gparam,'XLOG') then Xlog=1 else xlog=0
if ev_tag_exist(gparam,'YLOG') then Ylog=1 else Ylog=0

serTag = dataInd[2]

if not ev_tag_exist(gparam,'ROUNDSER') then begin 
  ev_add_tag,gparam,'ROUNDSER',1 ;; default to rounding by 1
endif
if valid_num(gparam.roundser) then begin
   if size(gparam.roundser,/type) EQ 7 then begin
      ev_undefine_tag,gparam,'ROUNDSER'
      ev_add_tag,gparam,'ROUNDSER',float(gparam.roundser)
   endif
   if gparam.roundser EQ 0 then begin
      message,'Rounding value must be greater than 0'
      ev_undefine_tag,gparam,'ROUNDSER'
      ev_add_tag,gparam,'ROUNDSER',1
   endif
endif else begin
   message,"Invalid rounding value found",/cont
   ev_undefine_tag,gparam,'ROUNDSER'
   ev_add_tag,gparam,'ROUNDSER',1
endelse

;; Round and organize the groups of series to plot
rlist= ev_round(float(dat.(serTag)),gparam.roundser);; rounded list
srlist = rlist[sort(rlist)] ;; sorted, rounted list
uniql = uniq(srlist) ;; unique elements in the rounded sorted list
serArr = srlist[uniql] ;; final array that is unique, sorted and rounded
nser = n_elements(uniql)

colArr = myarraycol(nser,psversion=ev_tag_true(gparam,'PS'))

if ev_tag_exist(gparam,'PSYM') then begin
   plotsym,0,thick=thick
   if gparam.psym[0] EQ 1 then begin
      mypsym=8 + fltarr(nser)
   endif else begin
      mypsym=gparam.psym
   endelse
endif else mypsym=fltarr(nser)

;; Preponly will prepare the gparam and data correctly but do no plotting
if keyword_set(preponly) then return

;; Plot the data as a function of series
plot,dat.(DataInd[0]),dat.(DataInd[1]),$
     ystyle=1,xstyle=1,$
     xtitle=gparam.TITLES[0],$
     ytitle=gparam.TITLES[1],$
     title=gparam.TITLES[2],$
     xrange=myXrange,$
     yrange=myYrange,/nodata,$
     xmargin=xmargin,thick=thick,$
     xthick=thick,ythick=thick,$
     xlog=xlog,ylog=ylog

for i=0l,nser-1l do begin
   serInd = where(rlist EQ serArr[i])
   nserInd = n_elements(serInd)
   if serInd NE [-1] then begin
      oplot,[dat[serInd].(DataInd[0])],[dat[serInd].(DataInd[1])],$
           color=colArr[i],thick=thick,psym=mypsym[i]
      if ev_tag_exist(gparam,'YERR') OR ev_tag_exist(gparam,'XERR') then begin
         if not ev_tag_exist(gparam,'XERR') then begin
            xerr = fltarr(nserInd)
         endif else xerr = dat[serInd].(XerrInd)
         if not ev_tag_exist(gparam,'YERR') then begin
            yerr = fltarr(nserInd)
         endif else yerr = dat[serInd].(YerrInd)
         if total(xerr) GT 0E OR total(yerr) GT 0E then begin
            oploterror,dat[serInd].(DataInd[0]),dat[serInd].(DataInd[1]),$
                       xerr,yerr,$
                       color=colArr[i],thick=thick
         endif
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

   if tag_exist(gparam,'LEGTITLE') then legTitle=gparam.legtitle else begin
      if tag_exist(gparam,'SERIES') then legTitle=gparam.series else legTitle=''
   endelse
   al_legend,[legTitle,serLab],$
             linestyle=[-1,intarr(nser)],thick=thick,bthick=thick,$
             color=[!p.color,colArr],charsize=LegCharsize,$
             position=legPos,psym=[0,mypsym]
endif

;; Find the !x.cranges corrected for log scales

if xlog then myXcrange=10E^(!x.crange) else myXcrange=!x.crange
if ylog then myYcrange=10E^(!y.crange) else myYcrange=!y.crange


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
            ydraw = myYcrange
         endif else begin
            xdraw = myXcrange
            ydraw = edat.(lineindex)[i] * [1D,1D]
         endelse
         oplot,xdraw,ydraw,color=linecols[i],$
            linestyle=mylstyle[i]
      endfor
   endif
endfor

if ev_tag_exist(edat,'TEXT') then begin
   ntexts = n_elements(edat.text)
   if ev_tag_exist(edat,'XYTEXT') then begin
      if ntexts * 2 EQ n_elements(edat.xytext) then begin
         xtxt = (myXcrange[1] - myXcrange[0]) * edat.xytext[0,*] + myXcrange[0]
         ytxt = (myYcrange[1] - myYcrange[0]) * edat.xytext[1,*] + myYcrange[0]
         for i=0l,ntexts-1l do begin
            xyouts,xtxt,ytxt,edat.text
         endfor
      endif
   endif
endif

if ev_tag_true(gparam,'PS') then begin
   device, /close
   cgPS2PDF,plotprenm+'.eps'
   spawn,'convert -density 300% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif
end
