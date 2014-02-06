pro shift_to_common,onefunc=onefunc
;; Shifts all spectral imagees using a common reference spectrum
;; onefunc -- only use one straightening function for all images

;; Find images
cd,current=current
filel = file_search(current+'/run*lincor.fits')
nfile = n_elements(filel)

;; make a master common spectrum from the middle science file
midfile = filel[floor(nfile/2)]

;; All these lines are for finding the directory and output names
DirNames = strsplit(midfile,'/',/extract)
NDirs = n_elements(DirNames)
MfileName = DirNames[NDirs-1]
MDirPos = strpos(midfile,MfileName) ;; position where directory ends
Moutfile = strmid(midfile,0,MDirPos)+'master_straightened_'+MfileName+'.fits'
MshiftFile = strmid(midfile,0,MDirPos)+'master_shifts.txt'

find_shift_values,custarc=midfile,custshiftFile=MshiftFile,arcshift=Moutfile,/saveMasterSpec,/dodivide

if keyword_set(onefunc) then begin
   straighten_spec,'proc_science_images.txt','straight_science_images.txt',shiftlist='master_shifts.txt',/dodivide
endif else begin
;; Go through all the images and shift to a common reference
   for i=0l,nfile-1l do begin
      suffixPos = strpos(filel[i],'.fits') ;; position where the suffix starts
      ShiftedFileN = strmid(filel[i],0,suffixPos)+'_straight.fits'
      shiftsFileN = strmid(filel[i],0,suffixPos)+'_shifts.txt'
      find_shift_values,custarc=filel[i],custshiftFile=shiftsFileN,arcshift=ShiftedFileN,/useMasterSpec,$
                        /dodivide,/offsetonly
   endfor
endelse
   
end
