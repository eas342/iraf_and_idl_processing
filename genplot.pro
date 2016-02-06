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
       es_cmd_focus
       return
    end
    'SAVEDAT': check_idlsave,data,y,gparam,filename='es_plot_data.sav',$
                            varnames=['dat','y','gparam']
    'MOVELEG': cmove_legend,data,gparam=gparam
    'MARGLEG': begin
       ev_add_tag,gparam,'NOMARGLEG',1 - ev.value
    end
    'CFOLDER': begin
       if not ev_tag_exist(gparam,'FILENAME') then begin
          plotprenm='unnamed_genplot'
       endif else begin
          plotprenm=gparam.filename
       endelse
       spawn,'open -R '+plotprenm+'.eps'
    end
    'XCHOICE': begin
       gparam.PKEYS[0] = dattags[ev.index]
       gparam.TITLES[0] = gparam.PKEYS[0]
    end
    'YCHOICE': begin
       gparam.PKEYS[1] = dattags[ev.index]
       gparam.TITLES[1] = gparam.PKEYS[1]
    end
    'SWITCHXY': begin
       prevkeys = gparam.PKEYS
       gparam.PKEYS = reverse(gparam.PKEYS)
       gparam.TITLES[0:1] = reverse(gparam.TITLES[0:1])
    end
    'HISTX': begin
       genhist,data,gparam=gparam
    end
    'SERCHOICE': begin
       gparam.SERIES = dattags[ev.index]
    end
    'LINFIT': begin
       quick_fit,dat,edat,gparam=gparam,polyord=1
    end
    'PARAB': begin
       quick_fit,dat,edat,gparam=gparam
    end
    'GAUSS': begin
       quick_fit,dat,edat,gparam=gparam,customfunc='Gaussian(X,P)'
    end
    'PLOTSYM': begin
       ev_add_tag,gparam,'PSYM',1
    end
    'ALLLINE': begin
       ev_add_tag,gparam,'PSYM',0
    end
    'MATH': begin
       plot_math,data,Y,gparam=gparam
    end
    'GETMATH': if file_exists('ev_local_math_params.sav') then begin
       restore,'ev_local_math_params.sav'
       data = mathst
       update_widgets,ev.top,data,edat,gparam
    endif
    'CLICKID': begin
       ;; Retrieve the FITS plotting parameters, if specified
       ;; widget for storing MIV (multi-image viewer parameters, if
       ;; specified. plotp
       idplotparam = widget_info(ev.top,find_by_uname="mivparams")
       widget_control, idplotparam, get_uvalue= plotp
       click_img_identify,data,Y,gparam=gparam,plot=plotp
    end
    'ALLPOINTS': ev_undefine_tag,gparam,'FITREGION'
    'FITREGION': begin
       zoomBox = find_click_box()
       ev_add_tag,gparam,'FITREGION',[min(zoombox[*,0]),max(zoombox[*,0])]
    end
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

       return
    end
 ENDCASE
;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = data
  widget_control, idParam, set_uvalue = gparam ;; save the plot parameters
  widget_control, idY, set_uvalue = y ;; save the y data
  update_widgets,ev.top,dat,edat,gparam

END

PRO genplot,data,y,gparam=gparam,help=help,restore=restore,$
            noinit=noinit,linep=linep,plotp=plotp
;; General plotter
;; gparam contains all the general plotting parameters
;; help - calls up the help file
;; restore - restores the previous parameter settings

  if keyword_set(help) then begin
     spawn,'open '+reduction_dir()+'/genplot_help.txt'
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

  if n_elements(data) LE 1 then begin
     message,'Not enough data to plot',/cont
     return
  endif
  disp_plot,data,y,gparam=gparam,/preponly,dat=dat,edat=edat
  datTags = tag_names(dat)

  base = WIDGET_BASE(/column) ;; base to store groups of buttons

  topR = widget_base(base,/row) ;; base to store top row of controls
  cntl = widget_base(topR, /column,/frame) ;; Plot control widget
  zoomW = widget_base(topR,/column,/frame) ;; base for zoom parameters
  legW = widget_base(topR,/column,/frame) ;; base for legend parameters
  psW = widget_base(topR,/column,/frame) ;; base for postscript/png output options
  plotPW = widget_base(topR,/column,/frame) ;; base for plot point options

  nextR = widget_base(base,/row) ;; base to store next row of controls
  fitW = widget_base(base,/row) ;; base for fitting lines
  clickW = widget_base(base,/row) ;; base for the clicking options

  ;; Allow the user to choose data points
  xychoiceB = widget_base(nextR,/column,/frame) ;; base for x, y plot control
  nch = 3
  choiceWidg = lonarr(nch)
  choicelabel = lonarr(nch)
  choiceSelector = lonarr(nch)
  cPref = ['X','Y','SER']
  cName = ['X','Y','Series']
  for i=0l,nch-1l do begin
     choiceWidg[i] = widget_base(xyChoiceB,/row);; each choice gets its own widget base
     choicelabel[i] = widget_text(choiceWidg[i],value=cName[i]+' Choice:')
     choiceSelector[i] = widget_combobox(choiceWidg[i],$
                                      UVALUE=cPref[i]+'CHOICE',VALUE=dattags,$
                                      uname=cPref[i]+'CHOICE')
     if cPREF[i] EQ 'SER' then begin
        roundSer = widget_text(choiceWidg[i],value='1',uvalue='ROUNDSER',uname='ROUNDSER',/editable)
     endif
  endfor
  ;; Button to switch X and Y axes
  choiceSwitch = widget_button(xyChoiceB,Value='Switch X/Y',UVALUE='SWITCHXY')
  ;; Button to 
  histButton = widget_button(xyChoiceB,Value='Histogram X',UVALUE='HISTX')

  ywidget = widget_base(base,uname='ywidget') ;; widget for storing y value
  paramw = widget_base(base,uname='paramw') ;; widget for storing parameters
  ;; widget for storing MIV (multi-image viewer parameters, if specified. plotp
  mivparams = widget_base(base,uname='mivparams') 
  
  ;; Sets up the control buttons
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')
  button0 = WIDGET_BUTTON(cntl, VALUE='Re-Plot', UVALUE='REPLOT')
  dsavebutton = WIDGET_BUTTON(cntl, VALUE='Save Data', UVALUE='SAVEDAT')
  qlbutton = WIDGET_BUTTON(cntl, VALUE='Quit Loop', UVALUE='SQUIT')

  button4 = WIDGET_BUTTON(zoomW, VALUE='Click Zoom', UVALUE='ZOOM')
  button5 = WIDGET_BUTTON(zoomW, VALUE='Default Ranges',UVALUE='RZOOM')

  ;; A radio button to choose the plot scale Type
  for i=0l,1l do begin
     wBgroup1 = CW_BGROUP(zoomW, ['Full','Threshold'], button_uvalue = [0,1],$
                          /ROW, /EXCLUSIVE, /RETURN_NAME, /NO_RELEASE, $
                          uvalue=cPref[i]+'ZTYPE',set_value=0,$
                          label_top=cPref[i]+' Default',/frame,$
                          uname=cPref[i]+'ZTYPE')
  endfor

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

  ;; Buttons for changing the plot symbols
  psymWidget = widget_button(plotPW,UVALUE='PLOTSYM',VALUE='No Lines')
  lineWidget = widget_button(plotPW,UVALUE='ALLLINE',VALUE='All Lines')

  ;; Buttons for fitting
  fitMenu = widget_button(fitW,value = 'Fit',/menu)
  parabW = WIDGET_BUTTON(fitMenu, VALUE='Linear Fit', UVALUE='LINFIT',accelerator='Ctrl+I')
  parabW = WIDGET_BUTTON(fitMenu, VALUE='Parabola Fit', UVALUE='PARAB',accelerator='Ctrl+A')
  gaussW = WIDGET_BUTTON(fitMenu, VALUE='Gaussian Fit', UVALUE='GAUSS',accelerator='Ctrl+U')

  ;; Button to choose fit region
  allptBt = widget_button(fitW,value='Allpt',UVALUE='ALLPOINTS')
  regionBt = widget_button(fitW,value='Fit Reg',uvalue='FITREGION')


  ;; Button for doing math
  mathW = widget_button(fitW,value='Math',UVALUE='MATH')
  mathGW = widget_button(fitW,value='Get Math',UVALUE='GETMATH')

  ;; Button to identify FITS image
  clickIdentify = widget_button(clickW,value='Click Identify',UVALUE='CLICKID')

  WIDGET_CONTROL, base, /REALIZE

  if not keyword_set(noinit) then disp_plot,data,y,gparam=gparam

  widget_control, paramw, set_uvalue = gparam ;; save the plot parameters
  widget_control, mivparams, set_uvalue = plotp
  widget_control, base, set_uvalue = data
  widget_control, ywidget, set_uvalue = y ;; save the y data

  ;; Start the initial parameters correctly

  update_widgets,base,dat,edat,gparam

  XMANAGER, 'genplot', base
END
