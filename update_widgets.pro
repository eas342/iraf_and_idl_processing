pro update_widgets,base,dat,edat,gparam
;; Update the widget with the current data and plot parameters
;; base - top level widget ID
;; dat - genplot data structure
;; edat - genplot extra data structure
;; gparam - general plot parameters

  ;; Set the X choices and Y choices to current gparam
  dataInd = key_indices(dat,gparam)
  idXchoice = widget_info(base,find_by_uname="XCHOICE")
  idYchoice = widget_info(base,find_by_uname="YCHOICE")
  idSerchoice = widget_info(base,find_by_uname="SERCHOICE")
  dattags = tag_names(dat)
  widget_control,idXchoice,set_droplist_select=dataInd[0],set_value=dattags
  widget_control,idYchoice,set_droplist_select=dataInd[1],set_value=dattags
  widget_control,idSerchoice,set_droplist_select=dataInd[2],set_value=dattags
  
  idSerRound = widget_info(base,find_by_uname="ROUNDSER")
  if ev_tag_exist(gparam,'ROUNDSER') then begin
     widget_control,idSerRound,set_value=strtrim(gparam.roundser,1)
  endif else print,'No series rounding parameter set.'

end
