function ev_tag_exist,struct,tag,index=index


;; Tests if a tag exists, but first checks if the structure is defined
if n_elements(struct) EQ 0 then begin
   result=byte(0)
endif else begin
   if size(struct,/type) NE 8 then begin
       message,'Warning, structure not correct variable types'
       return,0
    endif

    if size(tag,/type) NE 7 then begin
       message,'Warning, tag not correct variable types'
       return,0
    endif
    
   
    result = tag_exist(struct,tag,index=index)
endelse
return,result
end
