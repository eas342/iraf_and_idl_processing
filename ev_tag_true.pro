function ev_tag_true,struct,tag
;; Tests if a tag is true. If the tag doesn't exist it counts as false
if ev_tag_exist(struct,tag) EQ 0 then begin
   result=byte(0)
endif else begin
   junk = tag_exist(struct,tag,index=index)
   result=byte(struct.(index))
endelse

return,result
end
