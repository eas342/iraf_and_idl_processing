function retrieve_apcenter,filen,Nap
;; Finds a database file associated with the image and retrieves the
;; aperture centers
posit = fltarr(Nap)

   ;; Find the aperture file name
   postpos = strpos(filen,'.fits')
   
   ;; Find out the aperture center
   apFilenm = 'database/ap'+strmid(filen,0,postpos)
   line=''
   j=0
   openr,1,apFilenm
   while not eof(1) and j LE Nap do begin
      readf,1,apFilenm,line
      if strpos(line,'center') NE -1 then begin
         centerArr = strsplit(line,' ',/extract)
         posit[j] = float(centerArr[1])
         j = j+1
      endif
   endwhile
   free_lun,1
return, posit

end
