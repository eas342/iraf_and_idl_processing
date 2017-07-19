PRO choose_linep_event, ev
common share7,tempLineP

WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
linepW = widget_info(ev.top,find_by_uname="linepW") ;; retrieve the line plot data
widget_control, linepW, get_uvalue= linep

if (uval EQ 'XSTART') or (uval EQ 'XEND') or (uval EQ 'YSTART') or (uval EQ 'YEND') then begin
   textW = widget_info(ev.top,find_by_uname=uval)
   widget_control,textW,get_value=numtext
   numfloat = float(numtext)
endif
   

CASE uval of
   'GEOMETRY': ev_add_tag,linep,'type',ev.value
   'DIRECTION': ev_add_tag,linep,'direction',ev.value
   'XSTART': linep.xcoor[0] = numfloat
   'XEND': linep.xcoor[1] = numfloat
   'YSTART': linep.ycoor[0] = numfloat
   'YEND': linep.ycoor[1] = numfloat
   'DONE': begin
      tempLineP = linep
      WIDGET_CONTROL, ev.TOP, /DESTROY
      es_cmd_focus
      return
   end

ENDCASE

widget_control, linepW, set_uvalue= linep ;; save the line parameters

END

PRO choose_linep,lineP
;; This function allows the user to manually edit the line or box
;; parameters
;; lineP - original line Plot parameters

  common share7, tempLineP
  ;; Set the default parameters
  if not ev_tag_exist(lineP,'type') then begin
     ev_add_tag,lineP,'type','box'
  endif
  
  if not ev_tag_exist(lineP,'Xcoor') then begin
     ev_add_tag,lineP,'Xcoor',[0,10]
  endif

  if not ev_tag_exist(lineP,'Ycoor') then begin
     ev_add_tag,lineP,'Ycoor',[0,10]
  endif

  if not ev_tag_exist(lineP,'direction') then begin
     ev_add_tag,lineP,'direction','x'
  endif


;; Allows the user to view the Multi-Image Viewer (MIV) help and quickly exit
  
  base = WIDGET_BASE(/column) ;; base to store groups of buttons
  linepW = widget_base(base,uname='linepW') ;; widget for storing line parameters


  if linep.type EQ 'box' then begin
     button_value = 0
  endif else begin
     button_value = 1
  endelse
  button_uvalue = ['box','line']

  geometryToggle = cw_bgroup(base,label_top='Geometry',$
                    ['box','line'],button_uvalue=button_uvalue,$
                    /exclusive, /return_name,uvalue='GEOMETRY',$
                    set_value=button_value)

  if linep.direction EQ 'x' then button_value = 0 else button_value = 1
  button_uvalue = ['x','y']

  directionToggle = cw_bgroup(base,label_top='Direction',$
                             ['x','y'],button_uvalue=button_uvalue,$
                             /exclusive,/return_name,uvalue='DIRECTION',$
                             set_value=button_value)
  
  ;; x start
  x1TextB = widget_base(base,/column,frame=2)
  x1TextL = widget_text(x1TextB,value='x Start')
  x1TextE = widget_text(x1TextB,value=string(linep.xcoor[0]),/editable,uvalue='XSTART',uname='XSTART')

  ;; x end
  x2TextB = widget_base(base,/column,frame=2)
  x2TextL = widget_text(x2TextB,value='x End')
  x2TextE = widget_text(x2TextB,value=string(linep.xcoor[1]),/editable,uvalue='XEND',uname='XEND')

  ;; y start
  y1TextB = widget_base(base,/column,frame=2)
  y1TextL = widget_text(y1TextB,value='y Start')
  y1TextE = widget_text(y1TextB,value=string(linep.ycoor[0]),/editable,uvalue='YSTART',uname='YSTART')
  
  ;; y end
  y2TextB = widget_base(base,/column,frame=2)
  y2TextL = widget_text(y2TextB,value='y End')
  y2TextE = widget_text(y2TextB,value=string(linep.ycoor[1]),/editable,uvalue='YEND',uname='YEND')
  
  ;; Allow a quit
  donebutton = WIDGET_BUTTON(base, VALUE='Done', UVALUE='DONE')

  WIDGET_CONTROL, base, /REALIZE
  
  widget_control, linepW, set_uvalue=linep

  XMANAGER, 'choose_linep', base

  linep = tempLineP
  
END
