pro imcombine,listname,median=median,outname=outname,$
              linep=linep,normalize=normalize
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
      szFirst = size(a)
      totalA = a
      totalA[*] = 0
      outA = fltarr(szFirst[1],szFirst[2]) ;; output array for the average
      countA = fltarr(szFirst[1],szFirst[2]) ;; array for counting number of points
      outhead = head
      fullA = fltarr(szFirst[1],szFirst[2],nfile)
   endif
   
   sz = size(a)
   if sz[1] EQ szFirst[1] and sz[2] EQ szFirst[2] then begin
      fullA[*,*,i] = a[*,*]
   endif
   ;; If asked to, normalize each image
   if keyword_set(normalize) then begin
      xcoor = [680,780]
      ycoor = [180,380]
      thresh = 2E
      rangeX = checkrange(round(xcoor[0:1]),0,sz[1]-1l)
      rangeY = checkrange(round(ycoor[0:1]),0,sz[2]-1l)
      normpt = a[rangeX[0]:rangeX[1],rangeY[0]:rangeY[1]]
      rsig = robust_sigma(normpt)
      goodp = where(abs(normpt - median(normpt)) LT thresh * rsig)
      if goodp EQ [-1] then begin
         message,"No Valid Normalization Points"
         normalization = 1E
      endif else begin
         normalization = mean(normpt[goodp])
      endelse
      fullA[*,*,i] = fullA[*,*,i]/float(normalization)
      a = float(a)/float(normalization)
      writefits,'norm_for_'+filel[i],a,head
;      showX = [rangeX[0],rangeX[1],rangeX[1],rangeX[0],rangeX[0]]
;      showY = [rangeY[0],rangeY[0],rangeY[1],rangeY[1],rangeY[0]]
;      fits_display,a
;      oplot,showX,showY,color=mycol('blue')
   endif
   

   filenInside = clobber_dir(filel[i],/exten,dir=dir)
   maskFile = 'mask_for_'+filenInside+'.fits'
   fileFind = file_search(maskFile)
   if fileFind NE '' then begin
      b = mod_rdfits(fileFind,0,maskhead)
      whereGood = where(b EQ 0)
      if whereGood NE [-1] then begin
         totalA[whereGood] = totalA[whereGood] + a[whereGood]
         countA[whereGood] = countA[whereGood] + 1E
      endif
   endif else begin
      totalA = totalA + a
      countA = countA + 1E
   endelse
   fxaddpar,outhead,'AVFILE'+strtrim(i,1),clobber_dir(filel[i]),$
            'File used in making average'
   
endfor

nonZ = where(countA GT 0)
if nonZ NE [-1] then outA[nonZ] = totalA[nonZ]/countA[nonz]

if n_elements(outname) EQ 0 then outname='es_average.fits'
fileFind = file_search(outname)
if fileFind NE '' then outname=dialog_pickfile(/write,filter='*.fits',$
                                               default_extension='.fits')
fxaddpar,outhead,'AVERAGE',1,'File is average of others'
writefits,outname,outA,outhead

end
