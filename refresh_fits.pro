pro refresh_fits,nfile,fileL,plotp,linep,slot,display=display

allfits = file_search('*.fits')
ntot = n_elements(allfits)
startf = max([ntot - nfile,0l])
endF = ntot -1l
filel = allfits[startf:endF]
slot = n_elements(filel) -1l

if keyword_set(display) then begin
   fits_display,filel[slot],plotp=plotp,linep=linep
endif

end
