pro fedit,filel,plotp=plotp,action=action
;; Opens a file list for viewing

if keyword_set(action) then txtnm='action_list.txt' else begin
   txtnm = 'ev_local_display_filelist.txt'
endelse
  if ev_tag_exist(plotp,'KEYDISP') then begin
     nfile = n_elements(filel)
     openw,1,txtnm
     nkeys = n_elements(plotp.keydisp)
     nameLength = max(strlen(filel))
     for i=0l,nfile-1l do begin
        temphead = headfits(filel[i])
        printf,1,filel[i],format='(A'+strtrim(nameLength,1)+'," ",$)'
        if n_elements(temphead) GT 1 then begin
           for j=0l,nkeys-1l do begin
              if j EQ nkeys-1l then fmt='(A)' else fmt='(A,$)'
              HeadVal = string(fxpar(temphead,plotp.keydisp[j]))
              printf,1,headVal,format=fmt
           endfor
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
