PRO quick_adist_event, ev
  WIDGET_CONTROL, ev.TOP, GET_UVALUE=textwids
  WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve the event uvalue
  WIDGET_CONTROL, textwids[3], combobox_index=units ;; 
  units = widget_info(textwids[3],/combobox_gettext)

  CASE uval of
;     'UNITS': print,'Units not yet working'        
     'CALC': begin
        widget_control,textwids[0],get_value=c1
        widget_control,textwids[1],get_value=c2
        widget_control,textwids[2],set_value=string(find_adist(c1,c2,units))+' '+units
     end
     'DONE': begin
        WIDGET_CONTROL, ev.TOP, /DESTROY
        spawn,'open -a Terminal'
        return
     end
  ENDCASE
END

pro quick_adist
;; Quickly finds the distace between two sets of coordinates

  base = WIDGET_BASE(/column) ;; base to store groups of buttons

  ;; Star 1 coordinates
  wstar1 = widget_base(base,/column,frame=2)
  star1Text = widget_text(wstar1,value='Star 1 Coordinates:')
  star1Wcoor = widget_text(wstar1,value='33 45 23.22 +12 23 12.1',/editable,$
                        uvalue='CALC')

  ;; Star 2 coordinates
  wstar2 = widget_base(base,/column,frame=2)
  star2Text = widget_text(wstar2,value='Star 2 Coordinates:')
  star2Wcoor = widget_text(wstar2,value='33 45 23.22 +12 23 12.1',/editable,$
                        uvalue='CALC')
  
  ;; Distance
  distw = widget_base(base,/column,frame=2)
  units = widget_combobox(distw,UVALUE='CALC',$
                          VALUE=['arcsec','arcmin','deg','rad'],uname='CALC')
  distout = widget_text(distw,value='Dist:')
  
  ;; Sets up the control buttons
  deleteBoxB = WIDGET_BUTTON(base, VALUE='Calc', UVALUE='CALC')
  donebutton = WIDGET_BUTTON(base, VALUE='Done', UVALUE='DONE')
  WIDGET_CONTROL, base, SET_UVALUE=[star1Wcoor,star2Wcoor,distout,units]
  WIDGET_CONTROL, base, /REALIZE
  XMANAGER, 'quick_adist', base

end
