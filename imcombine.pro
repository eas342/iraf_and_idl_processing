pro imcombine,listname,median=median,outname=outname,$
              linep=linep,normalize=normalize,plotp=plotp
;; Combines images with averaging or median, using masks
;; listname - list of files to average, median etc.
;; outname - specify the output name
;; FUTURE ADDED FUNCTIONALITY:
;; linep - contains a box where normalization should be performed
;; median - specifies that a median should be used

readcol,listname,filel,format='(A)'
nfile = n_elements(filel)

for i=0l,nfile-1l do begin
   a = mod_rdfits(filel[i],0,head,plotp=plotp)
   if i EQ 0 then begin
      szFirst = size(a)
      type = size(a,/type)
      if type EQ 2 then totalA = long(a) else totalA =A
      totalA[*] = 0
      outA = fltarr(szFirst[1],szFirst[2]) ;; output array for the average
      countA = fltarr(szFirst[1],szFirst[2]) ;; array for counting number of points
      outhead = head
      ;; full array for all data, default is NaN
      fullA = fltarr(szFirst[1],szFirst[2],nfile) * !values.f_nan
      totimgPts = szFirst[1] * szFirst[2]
   endif
   
   sz = size(a)
   if sz[1] EQ szFirst[1] and sz[2] EQ szFirst[2] then begin
                                ;fullA[*,*,i] = a[*,*]
   endif else begin
      message,'Detected a change in image size in imcombine',/cont
   endelse
   ;; If asked to, normalize each image
   if keyword_set(normalize) then begin
      
      if ev_tag_exist(linep,'TYPE') then begin
         if linep.type NE 'box' then begin
            message,'linep must be set to a box to normalize',/cont
            return
         endif
      endif else begin
         message,'linep must be set to a box to normalize',/cont
         return
      endelse
      xcoor = lineP.xcoor
      ycoor = lineP.ycoor
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
      a = float(a)/float(normalization)
;      shortfile = clobber_dir(filel[i],dir=dir)
;      writefits,dir+'/norm_for_'+shortfile,a,head
;      showX = [rangeX[0],rangeX[1],rangeX[1],rangeX[0],rangeX[0]]
;      showY = [rangeY[0],rangeY[0],rangeY[1],rangeY[1],rangeY[0]]
;      fits_display,a
;      oplot,showX,showY,color=mycol('blue')
   endif
   

   filenInside = clobber_dir(filel[i],/exten,dir=dir)
   maskFile = 'mask_for_'+filenInside+'.fits'
   fileFind = file_search(maskFile)
   if fileFind NE '' then begin
      b = mod_rdfits(fileFind,0,maskhead,plotp=plotp)
      whereGood = where(b EQ 0)
      if whereGood NE [-1] then begin
         
         totalA[whereGood] = totalA[whereGood] + a[whereGood]
         countA[whereGood] = countA[whereGood] + 1E
         ind = array_indices(a,whereGood)
         ;;
;        ;; fullA[ind[0,*],ind[1,*],i] = a[whereGood] ;; this is what
;        I want to do
         fullA[whereGood + i * totimgPts] = a[whereGood]
      endif
   endif else begin
      totalA = totalA + a
      countA = countA + 1E
      fullA[*,*,i] = a
   endelse
   fxaddpar,outhead,'AVFILE'+strtrim(i,1),clobber_dir(filel[i]),$
            'File used in making average'
   
endfor

;; save the median image
if keyword_set(median) then begin
   medhead = outhead
   fxaddpar,medhead,'MEDIAN',1,'File is a median of other images'
   medImg = median(fullA,dimension=3)
   if n_elements(medName) EQ 0 then medName='es_median.fits'
   fileFind = file_search(medName)
   print,'Saving median ...'
   if fileFind NE '' then medName=dialog_pickfile(/write,filter='*.fits',$
                                                  default_extension='.fits')
   writefits,medName,medImg,medhead
endif

nonZ = where(countA GT 0)
if nonZ NE [-1] then outA[nonZ] = totalA[nonZ]/countA[nonz]

if n_elements(outname) EQ 0 then outname='es_average.fits'
fileFind = file_search(outname)
print,'Saving average ...'
if fileFind NE '' then outname=dialog_pickfile(/write,filter='*.fits',$
                                               default_extension='.fits')
fxaddpar,outhead,'AVERAGE',1,'File is average of others'
writefits,outname,outA,outhead

end
