pro shift_to_common

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

find_shift_values,custarc=midfile,custshiftFile=MshiftFile,arcshift=Moutfile,/saveMasterSpec

;; Go through all the images and shift to a common reference
for i=0l,nfile-1l do begin
   suffixPos = strpos(filel[i],'.fits') ;; position where the suffix starts
   ShiftedFileN = strmid(filel[i],0,suffixPos)+'_straight.fits'
   find_shift_values,custarc=filel[i],custshiftFile='temp_shifts.txt',arcshift=ShiftedFileN,/useMasterSpec
endfor

end