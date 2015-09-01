pro update_widgets,base,dat,edat,gparam
;; Update the widget with the current data and plot parameters
;; base - top level widget ID
;; dat - genplot data structure
;; edat - genplot extra data structure
;; gparam - general plot parameters

  choiceNames = ['X','Y','SER'] ;; for looping around

  dattags = tag_names(dat)
  ;; Set the X, Y and series choices to current gparam
  dataInd = key_indices(dat,gparam)
  for i=0l,2l do begin
     idchoice = widget_info(base,find_by_uname=choiceNames[i]+"CHOICE")
     widget_control,idchoice,set_combobox_select=dataInd[i],set_value=dattags
  endfor

  ;; Set the threshold buttons to what gparam says
  for i=0l,1l do begin
     if ev_tag_true(gparam,choiceNames[i]+'THRESH') then begin
        idthresh = widget_info(base,find_by_uname=choiceNames[i]+"ZTYPE")
        widget_control,idThresh,set_value=1
     endif
  endfor
  idYthresh = widget_info(base,find_by_uname="YZTYPE")

  idSerRound = widget_info(base,find_by_uname="ROUNDSER")
  if ev_tag_exist(gparam,'ROUNDSER') then begin
     widget_control,idSerRound,set_value=strtrim(gparam.roundser,1)
  endif else print,'No series rounding parameter set.'

end
