pro cmove_legend,dat,gparam=gparam,reset=reset
;; Moves the legend by click with the cursor
;; if dat is defined, it re-does the plot
  if keyword_set(reset) then begin
     ev_undefine_tag,plotp,'LEGLOC'
     return
  endif
  cursor,x1,y1,/down
  ev_add_tag,gparam,'LEGLOC',[x1,y1]
  if n_elements(dat) NE 0 then begin
     disp_plot,dat,gparam=gparam
  endif

end
