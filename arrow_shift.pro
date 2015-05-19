PRO arrow_shift_event, ev

WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= slot ;; retrieve the current slots

;; Get the widget id of the widget base storing parameter info
paramw = widget_info(ev.top,find_by_uname="paramw")
widget_control, paramw, get_uvalue= plotp
linepW = widget_info(ev.top,find_by_uname="linepW")
widget_control, linepW, get_uvalue= linep
fileW = widget_info(ev.top,find_by_uname="fileW")
widget_control, fileW, get_uvalue= filel
posW = widget_info(ev.top,find_by_uname="posW")
widget_control, posW, get_uvalue= pos

nFile = n_elements(fileL)
CASE uval of
    'NEXT': slot[1] = wrap_mod((slot[1] + 1l),nfile)
    'PREV': slot[1] = wrap_mod((slot[1] - 1l),nfile)
    'UP': pos[1] = pos[1] + 1l
    'DOWN': pos[1] = pos[1] - 1l
    'LEFT':pos[0] = pos[0] - 1l
    'RIGHT':pos[0] = pos[0] + 1l
    'SAVE': dosave = 1l
    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
       spawn,'open -a Terminal'
       return
    end
ENDCASE

;; If you did a motion, go back to the original slot that
;; you're shifting
if total(strmatch(['LEFT','RIGHT','UP','DOWN'],uval)) GT 0 then begin
   slot[1] = slot[0]
endif

aimg = mod_rdfits(fileL[slot[1]],0,temphead,plotp=plotp,/silent)
if slot[1] EQ slot[0] then begin
   ;; Only do shifting to the original slot image
   showImg = shift(aimg,pos[0],pos[1])
endif else showImg = aimg
if ev_tag_exist(plotp,'KEYDISP') then begin
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
fits_display,showImg,plotp=plotp,linep=linep,message=clobber_dir(fileL[slot[1]])

if n_elements(dosave) GT 0 then begin
   if dosave EQ 1 then begin
       fxaddpar,temphead,'SHIFTS',string(pos[0])+' '+string(pos[1])
       writefits,clobber_exten(filel[slot[0]])+'_shifted.fits',showImg,temphead
   endif
endif

;; Save changes to the data & plot parameters
  widget_control, ev.top, set_uvalue = slot
  widget_control, paramw, set_uvalue = plotp ;; save the display parameters
  widget_control, linepW, set_uvalue = linep ;; save the y data
  widget_control, posW, set_uvalue= pos ;; save the position

END

pro arrow_shift,fileL,plotp=plotp,lineP=lineP,$
                     slot=slot
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons

  paramw = widget_base(base,uname='paramw') ;; widget for storing plot parameters
  linepW = widget_base(base,uname='linepW') ;; widget for storing line parameters
  fileW = widget_base(base,uname='fileW') ;; widget for the mask parameters
  posW = widget_base(base,uname='posW') ;; widget for the shift positions
  
  ;; Sets up the control buttons
  menuW = widget_button(base,value = 'File',/menu)
  donebutton = WIDGET_BUTTON(menuW, VALUE='Done', UVALUE='DONE',accelerator='Ctrl+D')
  prevImg = WIDGET_BUTTON(menuW, VALUE='Prev', UVALUE='PREV',accelerator='Ctrl+K')
  nextImg = WIDGET_BUTTON(menuW, VALUE='Next', UVALUE='NEXT',accelerator='Ctrl+L')
  lefW = WIDGET_BUTTON(menuW, VALUE='Left', UVALUE='LEFT',accelerator='Left')
  rightW = WIDGET_BUTTON(menuW, VALUE='Right', UVALUE='RIGHT',accelerator='Right')
  upW = WIDGET_BUTTON(menuW, VALUE='Up', UVALUE='UP',accelerator='Up')
  downW = WIDGET_BUTTON(menuW, VALUE='Down', UVALUE='DOWN',accelerator='Down')
  saveW = WIDGET_BUTTON(menuW, VALUE='Save', UVALUE='SAVE',accelerator='Ctrl+S')

  fits_display,filel[slot],plotp=plotp,linep=linep

  WIDGET_CONTROL, base, /REALIZE

  origSlot = slot
  newSlot = slot

  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  widget_control, linepW, set_uvalue = linep ;; save the line parameters
  widget_control, base, set_uvalue = [origSlot,newslot] ;; save the original and current slots
  widget_control, fileW, set_uvalue = filel ;; save the file lists
  widget_control, posW, set_uvalue = [0,0] ;; save the mask parameters
  
  XMANAGER, 'arrow_shift', base


end
