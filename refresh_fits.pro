pro refresh_fits,nfile,fileL,plotp,linep,slot,display=display,$
                 pref=pref

if n_elements(pref) EQ 0 then pref=''
spawn,'ls -t '+pref+'*.fits > ev_sorted_filelist.txt'
readcol,'ev_sorted_filelist.txt',sortedF,format='(A)',/silent

if ev_tag_exist(plotp,'IGNORE_STR') then begin
   keepmatch = where(strmatch(sortedF,plotp.ignore_str) EQ 0,nkeep)
   if nkeep GT 0 then sortedF = sortedF[keepmatch] else begin
      message,'No files found after ignores',/cont
   endelse
endif

allfits = reverse(sortedF)
;allfits = file_search(pref+'*.fits')
ntot = n_elements(allfits)
startf = max([ntot - nfile,0l])
endF = ntot -1l
filel = allfits[startf:endF]
slot = n_elements(filel) -1l

if keyword_set(display) then begin
   fits_display,filel[slot],plotp=plotp,linep=linep
endif

end
