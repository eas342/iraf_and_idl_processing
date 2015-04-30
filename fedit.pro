pro fedit,filel,plotp=plotp,action=action
;; Opens a file list for viewing

if keyword_set(action) then txtnm='action_list.txt' else begin
   txtnm = 'ev_local_display_filelist.txt'
endelse
  if ev_tag_exist(plotp,'KEYDISP') then begin
     nfile = n_elements(filel)
     HeadArr = strarr(nfile)
     openw,1,txtnm
     for i=0l,nfile-1l do begin
        temphead = headfits(filel[i])
        if n_elements(temphead) GT 1 then begin
           HeadArr[i] = string(fxpar(temphead,plotp.keydisp))
           printf,1,filel[i],headArr[i],format='(A," ",A)'
        endif else begin
           print,'Bad header found'
           printf,1,filel[i]
        endelse
     endfor
     close,1
  endif else begin
     forprint,filel,textout=txtnm,/silent,$
              /nocomment
  endelse
  spawn,'open '+txtnm
end
