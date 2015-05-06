function key_indices,dat,gparam
;; Find out the index associated with the plot keys
  dattags = tag_names(dat)
  initKeys = intarr(2)

  if not ev_tag_exist(gparam,'PKEYS') then begin
     message,'No PKEYS parameters found!',/continue
     return,initKeys
  endif

  for i=0l,1l do begin
     keyfind = where(dattags EQ gparam.pkeys[i])
     if n_elements(initKeys EQ 0) then begin
        message,'Key ',gparam.pkeys[i],' not found',/continue
     endif else initKeys[i] = keyfind[0]
  endfor
  return,initKeys
end
