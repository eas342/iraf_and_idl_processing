PRO showhead_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filen ;; retrieve the filename

CASE uval of
    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
       spawn,'open -a Terminal'
       return
    end
 ENDCASE

END

PRO showhead,filen
;; Allows the user to view the header and quickly exit

hd = headfits(filen)
outL = [filen,hd]
  
  base = WIDGET_BASE(/column) ;; base to store groups of buttons
  cntl = widget_base(base, /row,/frame) ;; control widget
  txtb = widget_base(base, /frame) ;; Text widget

  screensize = get_screen_size()
  YscrollSize = screensize[1] - 100
  txtval = widget_text(txtb,value=outL,scr_ysize=yscrollsize,$
                       /scroll)
  ;; Allow a quit
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')

  WIDGET_CONTROL, base, /REALIZE

;  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  XMANAGER, 'showhead', base;,/no_block
END
