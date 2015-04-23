;  $Id: //depot/idl/IDL_71/idldir/examples/doc/widgets/doc_widget2.pro#1 $

;  Copyright (c) 2005-2009, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Creating Widget Applications"
; chapter of the _Building IDL Applications_ manual.
;
PRO maskedit_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filen ;; retrieve the filename
;; Get the widget id of the widget base storing parameter info
paramw = widget_info(ev.top,find_by_uname="paramw")
widget_control, paramw, get_uvalue= plotp
linepW = widget_info(ev.top,find_by_uname="linepW")
widget_control, linepW, get_uvalue= linep

CASE uval of
    'NEWBOX':  begin
       print,'Draw Box'
    end
    'DELBOX': begin
       print,'Delete Box'
    end
    'DONE': begin
;       save,gparam,filename='ev_local_pparams.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
       return
    end
 ENDCASE
;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = filen
  widget_control, paramw, set_uvalue = plotp ;; save the display parameters
  widget_control, linepW, set_uvalue = linep ;; save the y data
END

PRO maskedit,filen,linep,plotp
;; Allows the user to draw masks in images when combining
;; gparam contains all the general plotting parameters

  maskFile = clobber_exten(filen)+'_mask.fits'
  fileFind = file_search('ev_local_pparams.sav')
  if fileFind NE '' then begin
     maskImg = mod_rdfits(fileFind,0,head,plotp=plotp)
  endif
  
  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons
  cntl = widget_base(base, /column,/frame) ;; Mask control widget

  paramw = widget_base(base,uname='paramw') ;; widget for storing plot parameters
  linepW = widget_base(base,uname='linepW') ;; widget for storing line parameters
  
  ;; Sets up the control buttons
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')
  newBoxB = WIDGET_BUTTON(cntl, VALUE='New Box', UVALUE='NEWBOX')
  deleteBoxB = WIDGET_BUTTON(cntl, VALUE='Delete Box', UVALUE='DELBOX')

  WIDGET_CONTROL, base, /REALIZE

;  disp_plot,data,y,gparam=gparam
  fits_display,filen,plotp=plotp,linep=linep

  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  widget_control, linepW, set_uvalue = linep ;; save the plot parameters
  widget_control, base, set_uvalue = filen
  XMANAGER, 'maskedit', base
END
