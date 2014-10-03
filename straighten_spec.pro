pro straighten_spec,inlist,outlist,shiftlist=shiftlist,dodivide=dodivide,$
                    smooth=smooth,reverse=reverse
;; Straightens the spectra
;; inlist is a list of input images
;; outlist is a list of output images
;; dodivide -- use the divisor keyword to divide the frame by the
;;             number of reads
;; smooth - run a boxcar filter in the spectral direction

if n_elements(shiftlist) EQ 0 then shiftlist='data/shift_data/shift_vals_from_arc.txt'
;; Read in the straightening data
readcol,shiftlist,rowN,shiftMod,format='(F,F)',skipline=1

if keyword_set(reverse) then shiftMod = shiftMod * (-1D)

;; Read the list of spectra to straighten & their output file names
readcol,inlist,infiles,format='(A)'
readcol,outlist,outfiles,format='(A)'
nfiles = n_elements(infiles)
assert,nfiles,'=',n_elements(outfiles),'In/Out file lists are mismatched.'

for j=0l,nfiles-1l do begin
;   img =
;   mrdfits('../IRTF_UT2012Jan04/proc/bigdog/bigdog0001.a.fits',0,origHeader)
   img = mrdfits(infiles[j],0,origHeader)

   imgSize = size(img)
   NX = imgSize[1]
   NY = imgSize[2]
   assert,n_elements(rowN),'=',NY,"Shift row and image row numbers don't match"
   recimg = fltarr(NX,NY)

   if keyword_set(dodivide) then begin
      img = do_divide(img,origheader)
   endif
   
   for i=0l,NY-1l do begin
      recimg[*,i] = shift_interp(img[*,i],shiftMod[i])
   endfor
   
   if not keyword_set(leaveEdges) then begin
      ;; Replace all the edges with the median edge value
      ;; This is needed because the shift procedure wraps the spectra
      ;; around, falsely putting K band data at 0.8um and vice versa
      medianLeft = median(img[0,*])
      medianRight = median(img[NX-1l,*])
      roundedShift = round(shiftMod)
      for i=0l,NY-1l do begin
         if shiftMod[i] GE 0 then begin
            recimg[0:roundedShift[i],i] = medianLeft
         endif else begin
            recimg[NX-1l+roundedShift[i]:NX-1l,i] = medianRight
         endelse
      endfor
   endif

   if n_elements(smooth) GT 0 then begin
;      boxcar = fltarr(smooth) + 1E / float(smooth)
      Nterms = smooth
      Center = float(Nterms-1)/2E
      Width = float(Nterms)/2E
      GaussF = Gaussian(findgen(Nterms),[1E,Center,Width])
      GaussF = GaussF / total(GaussF) ;; normalize
      recimg = convol(recimg,GaussF)
   endif

   ;; Check if file exists so you don't overwrite anything!
   checkfile = findfile(outfiles[j],count=count)
   if count GE 1 then begin
      print,"Out File Exists!"
      stop
   endif else writefits,outfiles[j],recimg,origHeader
endfor



end
