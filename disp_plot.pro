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

npt = n_elements(X)

if n_elements(y) NE 0 then begin
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

if not ev_tag_exist(gparam,'GFLAG') then begin
   ev_add_tag,gparam,'GFLAG',intarr(npt) + 1
endif
gInd = where(gparam.gflag EQ 1);; good indices
if gInd EQ [-1] then begin
   print,'No valid points to plot'
endif

dat = dat[gInd]

if ev_tag_exist(gparam,'ZOOMBOX') then begin
   myXrange = transpose(gparam.zoombox[0,0:1])
   myYrange = transpose(gparam.zoombox[1,0:1])
endif else begin
   myXrange = [min(dat.(Xind)),max(dat.(Xind))]
   myYrange = [min(dat.(Yind)),max(dat.(Yind))]
endelse


plot,dat.(Xind),dat.(Yind),$
     ystyle=1,xstyle=1,$
     xtitle=gparam.TITLES[0],$
     ytitle=gparam.TITLES[1],$
     title=gparam.TITLES[2],$
     xrange=myXrange,$
     yrange=myYrange,/nodata,$
     xmargin=[15,30]

if not ev_tag_exist(gparam,'SERIES') then begin
   ev_add_tag,dat,'SERIES',intarr(npt) + 1
   ev_add_tag,gparam,'SERIES','SERIES'
   ;; if no series specified, create a series part of array for
   ;; plotting
   tags = tag_names(dat)
endif
serTag = where(gParam.SERIES EQ tags)
nser = max(dat.(serTag)) - min(dat.(serTag)) + 1;; number of series
serArr = indgen(nser + 1) + min(dat.(serTag))
;; later I may have it specified differently for non-integers

if not ev_tag_exist(gparam,'PS') then begin
   ev_add_tag,gparam,'PS',0
endif
colArr = myarraycol(nser,psversion=gparam.ps)

for i=0l,nser-1l do begin
   serInd = where(dat.(serTag) GE serArr[i] and $
                  dat.(serTag) LT serArr[i+1])
   if serInd NE [-1] then begin
      oplot,dat[serInd].(Xind),dat[serInd].(Yind),$
           color=colArr[i]
   endif
endfor
if nser GT 1 or ev_tag_exist(gparam,'SLABEL') then begin
   if not ev_tag_exist(gparam,'SLABEL') then begin
      ev_add_tag,gparam,'SLABEL',''
   endif
   al_legend,gparam.slabel+' '+strtrim(serArr[0:nser-2l],1),$
             linestyle=0,$
             color=colArr,$
             position=[!x.crange[1],!y.crange[1]]
endif

end
