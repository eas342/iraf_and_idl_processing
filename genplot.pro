;  $Id: //depot/idl/IDL_71/idldir/examples/doc/widgets/doc_widget2.pro#1 $

;  Copyright (c) 2005-2009, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Creating Widget Applications"
; chapter of the _Building IDL Applications_ manual.
;
PRO genplot_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= dat ;; retrieve the data
;; Get the widget id of the widget base storing parameter info
idParam = widget_info(ev.top,find_by_uname="paramw")
widget_control, idParam, get_uvalue= gparam

;reftype = s.reftype

CASE uval of
    'REPLOT':  disp_plot,dat,gparam=gparam
    'PRINT' :  begin
       print,tag_names(s)
    end
    'PS'    :  disp_plot,dat,gparam=gparam,/psplot
    'ZOOM'  :  begin
;       get_zoom,plotp
       disp_plot,dat,gparam=gparam
    end
    'SCALE' : begin
       disp_plot,dat,gparam=gparam,/psplot
;       s.weight = ev.value
;       widget_control,ev.top, set_uvalue = s
    end
    'DONE': begin
       save,gparam,filename='ev_local_pparams.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
    end
  ENDCASE


END

PRO genplot,data,gparam=gparam
  base = WIDGET_BASE(/COLUMN) ;; base to store buttons?
  cntl = widget_base(base, /column) ;; another layer within the big base?
  paramw = widget_base(base,uname='paramw') ;; widget for storing parameters

  ;; Save the general plotting parameters ( I can't figure out how 
  
  ;; Describes a button to be created
  button0 = WIDGET_BUTTON(cntl, VALUE='Plot', UVALUE='REPLOT')
  button1 = WIDGET_BUTTON(cntl, VALUE='Postscript Plot', UVALUE='PS')
  button2 = WIDGET_BUTTON(cntl, VALUE='Zoom', UVALUE='ZOOM')
  button3 = WIDGET_BUTTON(cntl, VALUE='Set Scale', UVALUE='SCALE')
  button4 = WIDGET_BUTTON(cntl, VALUE='Disp Global',UVALUE='PRINT')

  ;; A radio button to choose the plot scale Type
  wBgroup1 = CW_BGROUP(cntl, ['Threshold', 'Full'], button_uvalue = [1,0],$
                       /ROW, /EXCLUSIVE, /RETURN_NAME, $
                      uvalue='ztype',set_value=0)
  ;; Quit button
  button5 = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')
  WIDGET_CONTROL, base, /REALIZE
;  widget_control, base, set_uvalue = {reftype:'references',weight:1}
  widget_control, paramw, set_uvalue = gparam
  widget_control, base, set_uvalue = data
  XMANAGER, 'genplot', base
END
