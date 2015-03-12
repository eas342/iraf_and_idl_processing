pro ev_add_tag,struct,tag,val
;; Adds a tag to and array.

if n_elements(struct) EQ 0 then begin
   struct = create_struct(tag,val)
endif else begin
   if tag_exist(struct,tag,index=index) then begin
      struct.(index) = val
   endif else begin
      struct = create_struct(struct,tag,val)
   endelse
endelse
;; If the structure does not exist, it makes one
;; if the structure exists but doesn't have a tag, it 
end
