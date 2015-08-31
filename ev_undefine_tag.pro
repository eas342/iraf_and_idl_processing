pro ev_undefine_tag,struct,tag,replace=replace
;; This script undefines a tag in a structure
;; Does it by making a new structure without that tag

norig = n_elements(struct)

if norig EQ 0 then begin
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
         if i NE index OR n_elements(replace) GT 0 then begin
            if i EQ index then data = replace else data = tempStruct.(i)
            if n_elements(struct) EQ 0 then begin
               struct = create_struct(tagnm[i],data)
            endif else begin
               struct = create_struct(struct,tagnm[i],data)
            endelse
         endif
      endfor
      ;; Make sure it's an array of structures if that's what you
      ;; started with
      if norig GT 1 then struct = struct_arrays(struct)
   endif
endelse

end
