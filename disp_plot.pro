pro disp_plot,X,Y,gparam=gparam
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


if not ev_tag_exist(gparam,'PS') then begin
   ev_add_tag,gparam,'PS',0
endif
;; Set up postscript, PDF and PNG plots
if gparam.PS EQ 1 then begin
   set_plot,'ps'
   !p.font=0
   if not ev_tag_exist(gparam,'FILENAME') then begin
      plotprenm='unnamed_genplot'
   endif else begin
      plotprenm=gparam.filename
   endelse
   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=20, ysize=9,decomposed=1,/color
   thick=2
   xmargin = [11,24]
   legCharsize =0.7
endif else begin
   thick=1
   xmargin = [15,30]
   legCharsize =1
endelse

npt = n_elements(X)
type = size(X,/type)

if type NE 8 then begin
   ;; Make a structure if X and y are input
   oneSt = create_struct('X',X[0],'Y',Y[0])
   dat = replicate(oneSt,npt)
   dat.x = X
   dat.Y = Y
   ev_add_tag,gparam,'PKEYS',['X','Y']
endif else dat = x
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
   ev_add_tag,gparam,'GFLAG',intarr(npt) + 1
endif
gInd = where(gparam.gflag EQ 1);; good indices
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

plot,dat.(Xind),dat.(Yind),$
     ystyle=1,xstyle=1,$
     xtitle=gparam.TITLES[0],$
     ytitle=gparam.TITLES[1],$
     title=gparam.TITLES[2],$
     xrange=myXrange,$
     yrange=myYrange,/nodata,$
     xmargin=xmargin,thick=thick,$
     xthick=thick,ythick=thick

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

colArr = myarraycol(nser,psversion=gparam.ps)

;; Plot the data as a function of series
for i=0l,nser-1l do begin
   serInd = where(dat.(serTag) GE serArr[i] and $
                  dat.(serTag) LT serArr[i+1])
   nserInd = n_elements(serInd)
   if serInd NE [-1] then begin
      oplot,dat[serInd].(Xind),dat[serInd].(Yind),$
           color=colArr[i],thick=thick
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
   if not ev_tag_exist(gparam,'SLABEL') then begin
      ev_add_tag,gparam,'SLABEL',''
   endif
   if n_elements(gparam.slabel) EQ 1 then begin
      serLab = gparam.slabel+' '+strtrim(serArr[0:nser-1l],1)
   endif else serLab = gparam.slabel
   al_legend,serLab,$
             linestyle=0,thick=thick,bthick=thick,$
             color=colArr,charsize=LegCharsize,$
             position=[!x.crange[1],!y.crange[1]]
endif


if gparam.PS EQ 1 then begin
   device, /close
   cgPS2PDF,plotprenm+'.eps'
   spawn,'convert -density 300% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif
end
