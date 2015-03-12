pro ev_add_tag2,struct,tag,val
;; Takes an array of structures and adds a tag to all of them
;outS. USing Coyote GUIDE:
; http://www.idlcoyote.com/code_tips/addfield.html
;; if val is a 1 element array, it is repeated
;; if val is an array with as many elements as struct, they get added
;; to each structure

   if tag_exist(struct,tag,index=index) then begin
      struct.(index) = val
   endif else begin
      struct = create_struct(struct,tag,val)
   endelse

end
