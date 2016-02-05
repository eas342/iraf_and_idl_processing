pro deal_with_strings,dat,gparam,dataInd,tags
;; Checks if the selected arrays are strings. If they are, convert to floats

for i=0l,1l do begin
   if size(dat.(dataInd[i]),/type) EQ 7 then begin
      if total(valid_num(dat.(dataInd[i]))) NE n_elements(dat) then begin
         message,'Attempted to plot invalid string',/cont
         return
      endif
      newArr = float(dat.(dataInd[i]))
      ev_undefine_tag,dat,gparam.pkeys[i],replace=newArr
;      ev_add_tag,dat,gparam.pkeys[i],newArr 
      ;; the undefining and re-adding the field will re-order the
      ;; indices so you need to redo them
      ;; find the new indices
      DataInd = key_indices(dat,gparam)
      tags = tag_names(dat)
   endif
endfor


end
