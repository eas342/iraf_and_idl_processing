pro average_shifts
;; This script takes the average shifts of all images to generate a
;; more complicated shifting function than would be obtained with
;; simply a single function and polynomial

cd,current=current
filel = file_search(current+'/run*_shifts.txt')
nfile = n_elements(filel)

for i=0l,nfile-1l do begin
   readcol,filel[i],row,fittedSh,measuredSh,$
           format='(F,F,F)',skipline=1,/silent
   if n_elements(AllShifts) EQ 0 then begin
      nrows = n_elements(row)
      AllShifts = fltarr(nrows,nfile)
      AllFitted = fltarr(nrows,nfile)
      RelShifts = fltarr(nrows,nfile)
      MedianShifts = fltarr(nfile)
   endif
   AllShifts[*,i] = measuredSh
   MedianShifts[i] = median(measuredSh)
   RelShifts[*,i] = measuredSh - MedianShifts[i]
   AllFitted[*,i] = fittedSh
endfor




;; Save as an image
writefits,'image_of_spectral_shifts.fits',AllShifts
writefits,'image_of_relative_spec_shifts.fits',RelShifts
writefits,'image_of__model_shifts.fits',Allfitted



medianShiftFunc = median(RelShifts,dimension=2)
StandardErrArr = fltarr(nrows)
for i=0l,nrows-1l do begin
   StandardErrArr[i] = robust_sigma(RelShifts[i,*])/sqrt(float(nfile - 1l))
endfor
medianFitted = median(AllFitted,dimension=2)

save,AllShifts,RelShifts,AllFitted,MedianShifts,$
     medianFitted,medianShiftFunc,StandardErrArr,$
     filename='shift_info.sav'
end
