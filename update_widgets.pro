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
  widget_control,idXchoice,set_droplist_select=dataInd[0]
  widget_control,idYchoice,set_droplist_select=dataInd[1]

end
