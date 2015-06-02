pro ev_oplot,dat,x,y,xerr,yerr,gparam=gparam
;; Takes a data structure and adds data for over-plotting as a new
;; series. Doesn't actually plot anything but just adds to the data structure

tags = tag_names(dat)
np = n_elements(x)

if not tag_exist(dat,'EV_OPLOT_SER') then begin
   ev_add_tag,dat,'EV_OPLOT_SER',0
endif
oneStruct = dat[0]
addStruct = replicate(oneStruct,np)


if ev_tag_exist(gparam,'PKEYS') then begin
   XInd = where(gparam.PKEYS[0] EQ tags)
   YInd = where(gParam.PKEYS[1] EQ tags)
endif else begin
   Xind = 0
   Yind = 1
endelse
addStruct.(Xind) = x
addStruct.(Yind) = y

if ev_tag_exist(gparam,'GFLAG') then begin
   prevGflag = gparam.gflag
   ev_undefine_tag,gparam,'GFLAG'
   gparam = create_struct(gparam,'GFLAG',[prevGflag,intarr(np)+1])
endif

if ev_tag_exist(gparam,'XERR') then begin
   XerrInd = where(gparam.XERR EQ tags)
   if n_elements(xerr) GT 0 then addStruct.(XerrInd) = xerr else begin
      addStruct.(XerrInd) = 0E
   endelse
endif
if ev_tag_exist(gparam,'YERR') then begin
   YerrInd = where(gparam.YERR EQ tags)
   if n_elements(yerr) GT 0 then addStruct.(YerrInd) = yerr else begin
      addStruct.(YerrInd) = 0E
   endelse
endif

addStruct.ev_oplot_ser = max(dat.ev_oplot_ser) + 1
ev_add_tag,gparam,'SERIES','EV_OPLOT_SER'
dat = [dat,addStruct]

end
