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
    'PS'    :  begin
       ev_add_tag,gparam,'PS',1
       disp_plot,dat,y,gparam=gparam
       gparam.ps = 0
    end
    'PSSIZE':  ev_add_tag,gparam,'PSSMALL',ev.value
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
    'SQUIT': begin
       ev_add_tag,gparam,'QUIT',1
       save,gparam,filename='ev_local_pparams.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
       return
    end
    'SAVEDAT': check_idlsave,dat,y,gparam,filename='es_plot_data.save',$
                            varnames=['dat','y','gparam']
    'MOVELEG': cmove_legend,dat,gparam=gparam
    'MARGLEG': begin
       ev_add_tag,gparam,'NOMARGLEG',1 - ev.value
    end
    'CFOLDER': spawn,'open .'
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

PRO genplot,data,y,gparam=gparam,help=help,restore=restore,$
            noinit=noinit
;; General plotter
;; gparam contains all the general plotting parameters
;; help - calls up the help file
;; restore - restores the previous parameter settings

  if keyword_set(help) then begin
     spawn,'open /Users/bokonon/triplespec/iraf_scripts/genplot_help.txt'
     return
  endif

  if keyword_set(restore) then begin
     fileList = file_search('ev_local_pparams.sav')
     if fileList NE '' then begin
        restore,'ev_local_pparams.sav'
     endif
  endif
  
  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons
  cntl = widget_base(base, /column,/frame) ;; Plot control widget
  zoomW = widget_base(base,/column,/frame) ;; base for zoom parameters
  legW = widget_base(base,/column,/frame) ;; base for legend parameters
  psW = widget_base(base,/column,/frame) ;; base for postscript/png output options

  ywidget = widget_base(base,uname='ywidget') ;; widget for storing y value
  paramw = widget_base(base,uname='paramw') ;; widget for storing parameters

  
  ;; Sets up the control buttons
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')
  button0 = WIDGET_BUTTON(cntl, VALUE='Re-Plot', UVALUE='REPLOT')
  dsavebutton = WIDGET_BUTTON(cntl, VALUE='Save Data', UVALUE='SAVEDAT')
  qlbutton = WIDGET_BUTTON(cntl, VALUE='Quit Loop', UVALUE='SQUIT')

  button4 = WIDGET_BUTTON(zoomW, VALUE='Click Zoom', UVALUE='ZOOM')
  button5 = WIDGET_BUTTON(zoomW, VALUE='Default Ranges',UVALUE='RZOOM')

  ;; A radio button to choose the plot scale Type
  wBgroup1 = CW_BGROUP(zoomW, ['Full','Threshold'], button_uvalue = [0,1],$
                       /ROW, /EXCLUSIVE, /RETURN_NAME, /NO_RELEASE, $
                      uvalue='XZTYPE',set_value=0,label_top='X Default',/frame)
  wBgroup1 = CW_BGROUP(zoomW, ['Full','Threshold'], button_uvalue = [0,1],$
                       /ROW, /EXCLUSIVE, /RETURN_NAME, /NO_RELEASE, $
                      uvalue='YZTYPE',set_value=0,label_top='Y Default',/frame)


  ;; Adjust the legend with the legend widgets
  ;; Margin legend widget
  mLTog = cw_bgroup(legW,label_top='Margin for Legend?',$
                    ['YES','NO'],button_uvalue=[1,0],$
                    /exclusive, /return_name,uvalue='MARGLEG',$
                    set_value=[ev_tag_true(gparam,'MARGLEG')])
  mLegButton = widget_button(legW,value='Move Legend',uvalue='MOVELEG')

  ;; Buttons for saving postscript plots
  psSizeB = CW_BGROUP(psW, ['Small','Medium'], button_uvalue = [1,0],$
                       /ROW, /EXCLUSIVE, /NO_RELEASE, $
                      uvalue='PSSIZE',set_value=1 - ev_tag_true(gparam,'PSSMALL'),$
                      label_top='Export Size',/frame)
  psPlot = WIDGET_BUTTON(psW, VALUE='Postscript Plot', UVALUE='PS')
  psFold = WIDGET_BUTTON(psW, VALUE='Open in Finder', UVALUE='CFOLDER')

  WIDGET_CONTROL, base, /REALIZE

  if not keyword_set(noinit) then disp_plot,data,y,gparam=gparam

  widget_control, paramw, set_uvalue = gparam ;; save the plot parameters
  widget_control, base, set_uvalue = data
  widget_control, ywidget, set_uvalue = y ;; save the y data
  XMANAGER, 'genplot', base
END
