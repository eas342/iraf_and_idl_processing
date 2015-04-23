pro get_mask,filen,plotp,linep,maskp
;  newbox = find_click_box(filen,plotp=plotp,/struct)
  newbox = find_click_box(/struct)
  if n_elements(maskp) NE 0 then begin
     maskp = [maskp,newbox]
  endif else maskp=newbox

end
