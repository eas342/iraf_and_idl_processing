function ev_tag_exist,struct,tag
;; Tests if a tag exists, but first checks if a 
if n_elements(struct) EQ 0 then begin
   result=byte(0)
endif else begin
   result = tag_exist(struct,tag)
endelse
return,result
end
