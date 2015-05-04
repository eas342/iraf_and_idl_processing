PRO emptywidget_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filen ;; retrieve the filename

;CASE uval of
;    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
;       return
;    end
; ENDCASE

END

PRO emptywidget
;; Empty widget to allow background widgets to close

  base = WIDGET_BASE(/column) ;; base to store groups of buttons

  WIDGET_CONTROL, base, /REALIZE

  XMANAGER, 'emptywidget', base,/no_block
  widget_control,base,/destroy
END
