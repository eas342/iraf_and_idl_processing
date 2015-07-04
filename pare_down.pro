function pare_down,splitstatus,nfile,fileL,slot=slot
;; pares down a list of files
  if n_elements(splitstatus) LE 1 then pnum=5 else begin
     if valid_num(splitstatus[1]) then begin
        pnum = long(splitstatus[1])
     endif else begin
        message,'Invalid num, using 5',/cont
        pnum=5
     endelse
  endelse
  subCh = floor(findgen(pnum)/float(pnum-1) * float(nfile-1l))
  slot = pnum - 1l
  return,fileL[subCh]
  
end
