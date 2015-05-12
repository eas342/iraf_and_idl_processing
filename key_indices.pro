function key_indices,dat,gparam
;; Find out the index associated with the plot keys
  dattags = tag_names(dat)
  initKeys = intarr(3)

  if not ev_tag_exist(gparam,'PKEYS') then begin
     message,'No PKEYS parameters found!',/continue
     return,initKeys
  endif
  if not ev_tag_exist(gparam,'SERIES') then begin
     message,'No SERIES parameters found!',/continue
     return,initKeys
  endif

  for i=0l,2l do begin
     if i LE 1 then begin
        keyLookName = gparam.pkeys[i]
     endif else begin
        keyLookName = gparam.SERIES
     endelse
     keyfind = where(dattags EQ keyLookName)
     if keyFind EQ [-1] then begin
        message,'Key '+keyLookName+' not found',/continue
     endif else initKeys[i] = keyfind[0]
  endfor

  return,initKeys
end
