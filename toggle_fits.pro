PRO toggle_fits_event, ev
common share1, slottemp,filetemp

WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= slot ;; retrieve the file list

;; Get the widget id of the widget base storing parameter info
paramw = widget_info(ev.top,find_by_uname="paramw")
widget_control, paramw, get_uvalue= plotp
linepW = widget_info(ev.top,find_by_uname="linepW")
widget_control, linepW, get_uvalue= linep

nFile = n_elements(filetemp)

CASE uval of
    'NEXT': slot = wrap_mod((slot + 1l),nfile)
    'PREV': slot = wrap_mod((slot - 1l),nfile)
    'REMOVE': begin
       remaining = where(strmatch(filetemp,filetemp[slot]) EQ 0,nremain)
       case nremain of
          nfile: begin
             message,'Current File not found in list strangely'
          end
          0: begin
             message,'File list would be destroyed, not removing '+filetemp[slot],/cont
          end
          else: begin
             filetemp = filetemp[remaining]
             slot = wrap_mod(slot,n_elements(filtemp))
          end
       endcase
    end
    'DONE': begin
       slottemp = slot
       WIDGET_CONTROL, ev.TOP, /DESTROY
       es_cmd_focus
       return
    end
ENDCASE

if ev_tag_exist(plotp,'KEYDISP') then begin
   temphead = headfits(filetemp[slot])
   if n_elements(temphead) GT 1 then begin
      nkey = n_elements(plotp.keyDisp)
      for j=0l,nkey-1l do begin
         if j EQ nkey-1l then fmt='(A)' else fmt='(A," ",$)'
         print,fxpar(temphead,plotp.keyDisp[j]),format=fmt
      endfor
   endif else begin
      print,"Invalid header found"
   endelse
endif
fits_display,filetemp[slot],plotp=plotp,linep=linep

;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = slot
  widget_control, paramw, set_uvalue = plotp ;; save the display parameters
  widget_control, linepW, set_uvalue = linep ;; save the line /box data
END

pro toggle_fits,fileL,plotp=plotp,lineP=lineP,$
                     slot=slot
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  common share1,slottemp,filetemp

  filetemp = filel

  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons

  paramw = widget_base(base,uname='paramw') ;; widget for storing plot parameters
  linepW = widget_base(base,uname='linepW') ;; widget for storing line parameters
  fileW = widget_base(base,uname='fileW') ;; widget for the mask parameters
  
  ;; Sets up the control buttons
  menuW = widget_button(base,value = 'File',/menu)
  donebutton = WIDGET_BUTTON(menuW, VALUE='Done', UVALUE='DONE',accelerator='Down')
  forwardButton = WIDGET_BUTTON(menuW, VALUE='Prev', UVALUE='PREV',accelerator='Left')
  reverseButton = WIDGET_BUTTON(menuW, VALUE='Next', UVALUE='NEXT',accelerator='Right')
  removeButton = WIDGET_BUTTON(menuW, VALUE='Remove from List',UVALUE='REMOVE',$
                               accelerator='Ctrl+R')

  fits_display,filetemp[slot],plotp=plotp,linep=linep

  WIDGET_CONTROL, base, /REALIZE

  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  widget_control, linepW, set_uvalue = linep ;; save the plot parameters
  widget_control, base, set_uvalue = slot
  XMANAGER, 'toggle_fits', base

  slot = slottemp
  filel = filetemp

end
