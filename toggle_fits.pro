function toggle_fits,fileL,usescale=usescale
;; Toggles between FITS files with clicks
;; It returns the last index the user stopped with

  i = 0l
  nFile = n_elements(fileL)
  while (!mouse.button NE 4) do begin
     fits_display,fileL[i],usescale=usescale
     slot = i

     cursor,xcur,ycur,/normal,/down
     if xcur LT 0.5 then begin
        i = wrap_mod((i - 1l),nfile)
     endif else begin
        i = wrap_mod((i + 1l),nfile)
     endelse

  endwhile
  !MOUSE.button=1
return,slot

end
