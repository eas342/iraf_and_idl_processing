pro make_sky_response
;; Takes the sky image and makes a response function (just like the
;; response function from the lamp flat frames)

find_shift_values,custarc='skymedian.fits',custshiftfile='skymedian_shifts.txt',$
                  arcshift='straight_skymedian.fits'

;straighten_spec,'skymedian.fits','straight_skymedian.fits',$
;                shiftlist='../proc/master_shifts.txt',/oneImage,/overWrite

a1 = mrdfits('straight_skymedian.fits',0,skyHead)

  medSpec = median(a1,dimension=2)
  medSImg = rebin(medspec,fxpar(skyHead,'NAXIS1'),fxpar(skyHead,'Naxis2'))
;  secondFlat = a1 / medSimg
  writefits,'straight_skymedian_spec.fits',medSImg,skyHead

  ;; Reverse the shift process on the median spectrum to unstraighten
straighten_spec,'straight_skymedian_spec.fits','curved_sky_median.fits',$
                shiftlist='skymedian_shifts.txt',/reverse,/oneImage,/overWrite
;                shiftlist='../proc/master_shifts.txt',/reverse,/oneImage,/overWrite
a2 = mrdfits('curved_sky_median.fits',0,headcuvedM)
sMedian = mrdfits('skymedian.fits',0,skyHeadOrig)

skyFlat = sMedian / a2
writefits,'sky_response2.fits',skyFlat,skyHeadOrig

end

