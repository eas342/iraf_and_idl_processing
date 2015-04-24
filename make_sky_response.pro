pro make_sky_response,lampVersion=lampVersion
;; Takes the sky image and makes a response function (just like the
;; response function from the lamp flat frames)

find_shift_values,custarc='skycombine.fits',custshiftfile='skycombine_shifts.txt',$
                  arcshift='straight_skycombine.fits'

;straighten_spec,'skycombine.fits','straight_skycombine.fits',$
;                shiftlist='../proc/master_shifts.txt',/oneImage,/overWrite

if keyword_set(lampVersion) then begin
   straighten_spec,'trimflat.fits','trimflat_straight.fits',$
                   shiftlist='skycombine_shifts.txt',/oneImage,/overWrite
   a1 = mrdfits('trimflat_straight.fits',0,skyHead)
endif else begin
   a1 = mrdfits('straight_skycombine.fits',0,skyHead)
endelse

  medSpec = median(a1,dimension=2)
  medSImg = rebin(medspec,fxpar(skyHead,'NAXIS1'),fxpar(skyHead,'Naxis2'))
;  secondFlat = a1 / medSimg
  writefits,'straight_skycombine_spec.fits',medSImg,skyHead

  ;; Reverse the shift process on the median spectrum to unstraighten
straighten_spec,'straight_skycombine_spec.fits','curved_sky_median.fits',$
                shiftlist='skycombine_shifts.txt',/reverse,/oneImage,/overWrite
;                shiftlist='../proc/master_shifts.txt',/reverse,/oneImage,/overWrite
a2 = mrdfits('curved_sky_median.fits',0,headcuvedM)
if keyword_set(lampVersion) then begin
   sMedian = mrdfits('trimflat.fits',0,skyHeadOrig)
endif else begin
   sMedian = mrdfits('skycombine.fits',0,skyHeadOrig)
endelse

skyFlat = sMedian / a2
if keyword_set(lampVersion) then begin
   finalFile='lamp_response1.fits'
endif else begin
   finalFile = 'sky_response2.fits'
endelse
writefits,finalFile,skyFlat,skyHeadOrig

end

