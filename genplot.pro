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
idY = widget_info(ev.top,find_by_uname="ywidget")
widget_control, idY, get_uvalue= Y

CASE uval of
    'REPLOT':  disp_plot,dat,y,gparam=gparam
    'PS'    :  disp_plot,dat,y,gparam=gparam,/psplot
    'ZOOM'  :  get_zoom,dat,y,plotp=gparam,/plotmode
    'RZOOM' :  get_zoom,dat,y,plotp=gparam,/plotmode,/rzoom
    'SCALE' : begin
       disp_plot,dat,gparam=gparam,/psplot
    end
    'XZTYPE' : begin
       if ev.value EQ 1 then begin
          ev_add_tag,gparam,'XTHRESH',1
       endif else ev_undefine_tag,gparam,'XTHRESH'
    end
    'YZTYPE' : begin
       if ev.value EQ 1 then begin
          ev_add_tag,gparam,'YTHRESH',1
       endif else ev_undefine_tag,gparam,'YTHRESH'
    end
    'DONE': begin
       save,gparam,filename='ev_local_pparams.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
       return
    end
 ENDCASE
;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = dat
  widget_control, idParam, set_uvalue = gparam ;; save the plot parameters
  widget_control, idY, set_uvalue = y ;; save the y data


END

PRO genplot,data,y,gparam=gparam
  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons
  cntl = widget_base(base, /column) ;; another layer within the big base?
  paramw = widget_base(base,uname='paramw') ;; widget for storing parameters
  ywidget = widget_base(base,uname='ywidget') ;; widget for storing y value
  zoomW = widget_base(base,/column,yoffset=20) ;; base for zoom parameters

  ;; Save the general plotting parameters ( I can't figure out how 
  
  ;; Sets up the control buttons
  button0 = WIDGET_BUTTON(cntl, VALUE='Plot', UVALUE='REPLOT')
  button1 = WIDGET_BUTTON(cntl, VALUE='Postscript Plot', UVALUE='PS')
  button2 = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')

  button3 = WIDGET_BUTTON(zoomW, VALUE='Set Scale', UVALUE='SCALE')
  button4 = WIDGET_BUTTON(zoomW, VALUE='Click Zoom', UVALUE='ZOOM')
  button5 = WIDGET_BUTTON(zoomW, VALUE='Default Ranges',UVALUE='RZOOM')

  ;; A radio button to choose the plot scale Type
  wBgroup1 = CW_BGROUP(zoomW, ['Full','Threshold'], button_uvalue = [0,1],$
                       /ROW, /EXCLUSIVE, /RETURN_NAME, /NO_RELEASE, $
                      uvalue='XZTYPE',set_value=0,label_top='X Default')
  wBgroup1 = CW_BGROUP(zoomW, ['Full','Threshold'], button_uvalue = [0,1],$
                       /ROW, /EXCLUSIVE, /RETURN_NAME, /NO_RELEASE, $
                      uvalue='YZTYPE',set_value=0,label_top='Y Default')
  ;; Quit button

  WIDGET_CONTROL, base, /REALIZE
;  widget_control, base, set_uvalue = {reftype:'references',weight:1}
  widget_control, paramw, set_uvalue = gparam ;; save the plot parameters
  widget_control, base, set_uvalue = data
  widget_control, ywidget, set_uvalue = y ;; save the y data
  XMANAGER, 'genplot', base
END
