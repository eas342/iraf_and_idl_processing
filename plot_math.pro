PRO plot_math_event, ev
common share1, outdat

WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
;widget_control, ev.top, get_uvalue= data ;; retrieve the data structure
opsW = widget_info(ev.top,find_by_uname="opsW")
widget_control, opsW, get_uvalue= ops ;; retrieve the operands and operators
opsTot = widget_info(ev.top,find_by_uname="opsTot")
widget_control, opsTot, get_uvalue= operators ;; retrieve the operands and operators

  datTags = tag_names(outdat)

nFile = n_elements(fileL)

CASE uval of
    'OP1CHOICE': ops.OP1CHOICE = dattags[ev.index]
    'OP2CHOICE': ops.OP2CHOICE = dattags[ev.index]
    'OPERATOR': ops.OPERATOR = operators[ev.index]
    'OUTNM': begin
       widget_control,ev.id,get_value=newNm
       ops.outname = strtrim(newNm,1)
    end
    'CALC': begin
       keyStruct = create_struct('PKEYS',[ops.OP1CHOICE,ops.OP2CHOICE],'SERIES',ops.OP1CHOICE)
       DataInd = key_indices(outdat,keyStruct)
       for i=0l,1l do begin
          if size(outdat.(Dataind[i]),/type) EQ 7 then begin
             ;; Try to convert to double
             if total(validnum(outdat.(DataInd[i]))) EQ n_elements(outdat.(DataInd[i])) then begin
                ev_add_tag,mathSt,'OP'+strtrim(i,1),double(outdat.(Dataind[i]))
             endif else begin
                message,'Unable to operate on string',/cont
                return
             endelse
          endif else ev_add_tag,mathSt,'OP'+strtrim(i+1,1),outdat.(Dataind[i])
       endfor

       case ops.OPERATOR of
          '+': calculated = mathSt.OP1 + mathSt.OP2
          '-': calculated = mathSt.OP1 - mathSt.OP2
          '/': calculated = mathSt.OP1 / mathSt.OP2
          'X': calculated = mathSt.OP1 * mathSt.OP2
          else: message,'Operator not found!'
       endcase
       ev_add_tag,outdat,ops.outname,calculated
    end
    'DONE': begin
       mathst = outdat
       save,mathst,filename='ev_local_math_params.sav'
       WIDGET_CONTROL, ev.TOP, /DESTROY
       return
    end
ENDCASE
;print,ops
  widget_control, ev.top, set_uvalue = data
widget_control, opsW, set_uvalue= ops ;; save the operands/operators

END

pro plot_math,data,y,gparam=gparam
;; Does simple math operands on data tags

 ;; common structure for the output 
common share1, outdat

  ;; Prepare the data correctly (like at parameter keys, create a data
  ;; structure, etc.)
  disp_plot,data,y,gparam=gparam,/preponly,dat=dat,edat=edat
  datTags = tag_names(dat)

  operators = ['/','-','+','X']

  base = WIDGET_BASE(/ROW) ;; base to store groups of buttons
  opsW = widget_base(base,uname='opsW') ;; base to store operators & operands
  opsTot = widget_base(base,uname='opsTot') ;; base to store the total operator choices
  op1W = widget_droplist(base,title='',$
                         UVALUE='OP1CHOICE',VALUE=dattags,uname='OP1CHOICE')
  operatorW  = widget_droplist(base,title='',$
                               UVALUE='OPERATOR',VALUE=operators,uname='OPERATOR')
  op2W = widget_droplist(base,title='',$
                         UVALUE='OP2CHOICE',VALUE=dattags,uname='OP2CHOICE')
  eqW = widget_text(base,value='=')
  outNmW = widget_text(base,value='MATH',uvalue='OUTNM',uname='OUTNM',/editable)
  calcbutton = WIDGET_BUTTON(base, VALUE='Calc', UVALUE='CALC')
  donebutton = WIDGET_BUTTON(base, VALUE='Done', UVALUE='DONE')

  defaultOps = create_struct('OP1CHOICE',dattags[0],$
                             'OP2CHOICE',dattags[0],$
                             'OPERATOR','/','OUTNAME','MATH')

  outdat = dat

  WIDGET_CONTROL, base, /REALIZE

  widget_control, base, set_uvalue = outdat
  widget_control, opsW, set_uvalue = defaultOps
  widget_control, opsTot, set_uvalue = operators
  XMANAGER, 'plot_math', base

  ;; Save the output data
  data = outdat

end
