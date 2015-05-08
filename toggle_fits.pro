PRO toggle_fits_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filel ;; retrieve the file list
;; Get the widget id of the widget base storing parameter info
paramw = widget_info(ev.top,find_by_uname="paramw")
widget_control, paramw, get_uvalue= plotp
linepW = widget_info(ev.top,find_by_uname="linepW")
widget_control, linepW, get_uvalue= linep
slotw = widget_info(ev.top,find_by_uname="slotw")
widget_control, slotw, get_uvalue= slot

fits_display,filel[slot],plotp=plotp,linep=linep

nFile = n_elements(fileL)

if ev_tag_exist(plotp,'KEYDISP') then begin
   temphead = headfits(fileL[slot])
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

CASE uval of
    'NEXT': slot = wrap_mod((slot + 1l),nfile)
    'PREV': slot = wrap_mod((slot - 1l),nfile)
    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
       spawn,'open -a Terminal'
       return
    end
ENDCASE
;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = filel
  widget_control, paramw, set_uvalue = plotp ;; save the display parameters
  widget_control, linepW, set_uvalue = linep ;; save the y data
  widget_control, slotw, set_uvalue = slot ;; save the mask parameters

END

pro toggle_fits,fileL,plotp=plotp,lineP=lineP,$
                     slot=slot
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons

  paramw = widget_base(base,uname='paramw') ;; widget for storing plot parameters
  linepW = widget_base(base,uname='linepW') ;; widget for storing line parameters
  slotw = widget_base(base,uname='slotw') ;; widget for the mask parameters
  
  ;; Sets up the control buttons
  menuW = widget_button(base,value = 'File',/menu)
  donebutton = WIDGET_BUTTON(menuW, VALUE='Done', UVALUE='DONE',accelerator='Down')
  deleteBoxB = WIDGET_BUTTON(menuW, VALUE='Prev', UVALUE='PREV',accelerator='Left')
  newBoxB = WIDGET_BUTTON(menuW, VALUE='Next', UVALUE='NEXT',accelerator='Right')

  fits_display,filel[slot],plotp=plotp,linep=linep

  WIDGET_CONTROL, base, /REALIZE

  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  widget_control, linepW, set_uvalue = linep ;; save the plot parameters
  widget_control, base, set_uvalue = filel
  widget_control, slotw, set_uvalue = slot ;; save the mask parameters
  XMANAGER, 'toggle_fits', base




end
