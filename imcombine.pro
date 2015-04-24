pro imcombine,listname,median=median,outname=outname,$
              linep=linep
;; Combines images with averaging or median, using masks
;; listname - list of files to average, median etc.
;; outname - specify the output name
;; FUTURE ADDED FUNCTIONALITY:
;; linep - contains a box where normalization should be performed
;; median - specifies that a median should be used

readcol,listname,filel,format='(A)'
nfile = n_elements(filel)

for i=0l,nfile-1l do begin
   a = mod_rdfits(filel[i],0,head)
   if i EQ 0 then begin
      outa = a
      outa[*] = 0
      countA = float(outa) ;; array for counting number of points
      outhead = head
   endif

   filenInside = clobber_dir(filel[i],/exten,dir=dir)
   maskFile = 'mask_for_'+filenInside+'.fits'
   fileFind = file_search(maskFile)
   if fileFind NE '' then begin
      b = mod_rdfits(fileFind,0,maskhead)
      whereGood = where(b EQ 0)
      if whereGood NE [-1] then begin
         outa[whereGood] = outa[whereGood] + a[whereGood]
         countA[whereGood] = countA[whereGood] + 1E
      endif
   endif else begin
      outa = outa + a
      countA = countA + 1E
   endelse
   fxaddpar,outhead,'AVFILE'+strtrim(i,1),clobber_dir(filel[i]),$
            'File used in making average'
endfor

nonZ = where(countA GT 0)
if nonZ NE [-1] then outA[nonZ] = outA[nonZ]/countA[nonz]

if n_elements(outname) EQ 0 then outname='es_average.fits'
fileFind = file_search(outname)
if fileFind NE '' then outname=dialog_pickfile(/write,filter='*.fits',$
                                               default_extension='.fits')
fxaddpar,outhead,'AVERAGE',1,'File is average of others'
writefits,outname,outA,outhead

end
