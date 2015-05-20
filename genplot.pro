;  $Id: //depot/idl/IDL_71/idldir/examples/doc/widgets/doc_widget2.pro#1 $

;  Copyright (c) 2005-2009, ITT Visual Information Solutions. All
;       rights reserved.
; 
; This program is used as an example in the "Creating Widget Applications"
; chapter of the _Building IDL Applications_ manual.
;
PRO genplot_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= data ;; retrieve the data
;; Get the widget id of the widget base storing parameter info
idParam = widget_info(ev.top,find_by_uname="paramw")
widget_control, idParam, get_uvalue= gparam
idY = widget_info(ev.top,find_by_uname="ywidget")
widget_control, idY, get_uvalue= Y
disp_plot,data,y,gparam=gparam,dat=dat,edat=edat,/preponly
dattags = tag_names(dat)


CASE uval of
    'REPLOT':  disp_plot,data,y,gparam=gparam
    'PS'    :  begin
       ev_add_tag,gparam,'PS',1
       disp_plot,data,y,gparam=gparam
       gparam.ps = 0
    end
    'PSSIZE':  ev_add_tag,gparam,'PSSMALL',ev.value
    'ZOOM'  :  get_zoom,data,y,plotp=gparam,/plotmode
    'RZOOM' :  get_zoom,data,y,plotp=gparam,/plotmode,/rzoom
    'SCALE' : begin
       disp_plot,data,gparam=gparam,/psplot
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
       spawn,'open -a Terminal'
       return
    end
    'SAVEDAT': check_idlsave,data,y,gparam,filename='es_plot_data.sav',$
                            varnames=['dat','y','gparam']
    'MOVELEG': cmove_legend,data,gparam=gparam
    'MARGLEG': begin
       ev_add_tag,gparam,'NOMARGLEG',1 - ev.value
    end
    'CFOLDER': spawn,'open .'
    'XCHOICE': begin
       gparam.PKEYS[0] = dattags[ev.index]
       gparam.TITLES[0] = gparam.PKEYS[0]
    end
    'YCHOICE': begin
       gparam.PKEYS[1] = dattags[ev.index]
       gparam.TITLES[1] = gparam.PKEYS[1]
    end
    'SERCHOICE': begin
       gparam.SERIES = dattags[ev.index]
    end
    'PARAB': begin
       quick_parab,dat,edat,gparam=gparam
    end
    'MATH': begin
       plot_math,data,Y,gparam=gparam
    end
    'GETMATH': if file_exists('ev_local_math_params.sav') then begin
       restore,'ev_local_math_params.sav'
       data = mathst
       update_widgets,ev.top,data,edat,gparam
    endif
    'ROUNDSER': begin
       widget_control,ev.id,get_value=newRound
       if valid_num(newRound) then begin
          if newRound NE 0E then begin
             ;; May re-define as float/int depending
             ev_undefine_tag,gparam,'ROUNDSER'
             ev_add_tag,gparam,'ROUNDSER',float(newRound[0])
             print,'rounding value = ',gparam.roundser
          endif else message,'Zero not allowed for round size',/cont
       endif else message,'Invalid round number',/cont
    end
    'DONE': begin
       save,gparam,filename='ev_local_pparams.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
;       spawn,'open -a Terminal'
       return
    end
 ENDCASE
;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = data
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
  
  ;; Prepare the data correctly (like at parameter keys, create a data
  ;; structure, etc.)

  disp_plot,data,y,gparam=gparam,/preponly,dat=dat,edat=edat
  datTags = tag_names(dat)

  base = WIDGET_BASE(/column) ;; base to store groups of buttons

  topR = widget_base(base,/row) ;; base to store top row of controls
  cntl = widget_base(topR, /column,/frame) ;; Plot control widget
  zoomW = widget_base(topR,/column,/frame) ;; base for zoom parameters
  legW = widget_base(topR,/column,/frame) ;; base for legend parameters
  psW = widget_base(topR,/column,/frame) ;; base for postscript/png output options

  nextR = widget_base(base,/row) ;; base to store next row of controls
  fitW = widget_base(base,/row) ;; base for fitting lines

  ;; Allow the user to choose data points
  xychoiceB = widget_base(nextR,/column,/frame) ;; base for x, y plot control
  xchoice = widget_droplist(xychoiceB,title='X Choice',$
                           UVALUE='XCHOICE',VALUE=dattags,uname='XCHOICE')
  ychoice = widget_droplist(xychoiceB,title='Y Choice',$
                           UVALUE='YCHOICE',VALUE=dattags,uname='YCHOICE')
  serWidg = widget_base(xychoiceB,/row)
  serChoice = widget_droplist(serWidg,title='Series Choice',$
                           UVALUE='SERCHOICE',VALUE=dattags,uname='SERCHOICE')
  
  roundSer = widget_text(serWidg,value='1',uvalue='ROUNDSER',uname='ROUNDSER',/editable)

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

  ;; Buttons for fitting
  fitMenu = widget_button(fitW,value = 'Fit',/menu)
  parabW = WIDGET_BUTTON(fitMenu, VALUE='Parabola Fit', UVALUE='PARAB',accelerator='Ctrl+A')

  ;; Button for doing math
  mathW = widget_button(fitW,value='Math',UVALUE='MATH')
  mathGW = widget_button(fitW,value='Get Math',UVALUE='GETMATH')

  WIDGET_CONTROL, base, /REALIZE

  if not keyword_set(noinit) then disp_plot,data,y,gparam=gparam

  widget_control, paramw, set_uvalue = gparam ;; save the plot parameters
  widget_control, base, set_uvalue = data
  widget_control, ywidget, set_uvalue = y ;; save the y data

  ;; Start the initial parameters correctly

  update_widgets,base,dat,edat,gparam

  XMANAGER, 'genplot', base
END
