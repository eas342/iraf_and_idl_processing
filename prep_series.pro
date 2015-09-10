function prep_series,dat,gparam,serTag,rlist
;; Organizes the data structure into groups by the series keyword

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

return, serArr
end
