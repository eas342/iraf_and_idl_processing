pro fedit,filel,plotp=plotp
;; Opens a file list for viewing

  if ev_tag_exist(plotp,'KEYDISP') then begin
     nfile = n_elements(filel)
     HeadArr = strarr(nfile)
     for i=0l,nfile-1l do begin
        temphead = headfits(filel[i])
        HeadArr[i] = string(fxpar(temphead,plotp.keydisp))
     endfor
     forprint,filel,headArr,textout='ev_local_display_filelist.txt',/silent,$
              /nocomment
  endif else begin
     forprint,filel,textout='ev_local_display_filelist.txt',/silent,$
              /nocomment
  endelse
  spawn,'open ev_local_display_filelist.txt'
end
