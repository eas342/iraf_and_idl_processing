pro fedit,filel,plotp=plotp,action=action,$
          custnm=custnm
;; Opens a file list for viewing

case 1 of
   n_elements(custnm) GT 0: txtnm=custnm
   keyword_set(action): txtnm='action_list.txt'
   else: txtnm = 'ev_local_display_filelist.txt'
endcase

  if ev_tag_exist(plotp,'KEYDISP') then begin
     nfile = n_elements(filel)
     openw,1,txtnm
     nkeys = n_elements(plotp.keydisp)
     nameLength = max(strlen(filel))
     for i=0l,nfile-1l do begin
        temphead = miv_headfits(plotp,filel[i])
        printf,1,filel[i],format='(A'+strtrim(nameLength,1)+'," ",$)'
        if n_elements(temphead) GT 1 then begin
           for j=0l,nkeys-1l do begin
              if j EQ nkeys-1l then fmt='(A)' else fmt='(A," ",$)'
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
