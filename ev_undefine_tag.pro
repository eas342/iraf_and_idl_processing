pro ev_undefine_tag,struct,tag
;; This script undefines a tag in a structure
;; Does it by making a new structure without that tag

if n_elements(struct) EQ 0 then begin
   ;; Nothing to do if structure is undefined
endif else begin
   if tag_exist(struct,tag,index=index) then begin
      tagnm = tag_names(struct)
      ntags = n_elements(tagnm)
      tempStruct = struct
      undefine,struct
      ;; Only re-create the structure there is more than 1
      ;; remaining tag
      for i=0l,ntags-1l do begin
         if i NE index then begin
            if n_elements(struct) EQ 0 then begin
               struct = create_struct(tagnm[i],tempStruct.(i))
            endif else begin
               struct = create_struct(struct,tagnm[i],tempStruct.(i))
            endelse
         endif
      endfor
   endif
endelse

end
