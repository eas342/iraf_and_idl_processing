function toggle_fits,fileL,plotp=plotp,lineP=lineP,$
                     startslot=startslot
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  if n_elements(startslot) EQ 0 then i = 0l else i=startslot
  nFile = n_elements(fileL)
  while (!mouse.button NE 4) do begin
     fits_display,fileL[i],plotp=plotp,lineP=lineP
     if ev_tag_exist(plotp,'KEYDISP') then begin
        temphead = headfits(fileL[i])
        if n_elements(temphead) GT 1 then begin
           nkey = n_elements(plotp.keyDisp)
           for j=0l,nkey-1l do begin
              if j EQ nkey-1l then fmt='(A)' else fmt='(A," ",$)'
              print,fxpar(temphead,plotp.keyDisp[j]),format=fmt
           endfor
        endif else begin
           print,"Invalid header found"
        endelse
     endif
     slot = i

     cursor,xcur,ycur,/normal,/down
     if xcur LT 0.5 then begin
        i = wrap_mod((i - 1l),nfile)
     endif else begin
        i = wrap_mod((i + 1l),nfile)
     endelse

  endwhile
  !MOUSE.button=1
  ;; make sure slot is defined, otherwise it produces an IDl error
  if n_elements(slot) EQ 0 then slot=0 
return,slot

end
