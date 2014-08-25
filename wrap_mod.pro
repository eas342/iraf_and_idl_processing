function wrap_mod,i,num
;; Performs a mod, but when the input is negative
if i LT 0 then begin
   ineg = abs(i) mod num
   result = (num - ineg) mod num
endif else result = i mod num
return,result
end
