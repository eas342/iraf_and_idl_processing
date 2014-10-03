pro make_sky_response
;; Takes the sky image and makes a response function (just like the
;; response function from the lamp flat frames)

straighten_spec,'sky_median_choice.txt','straight_sky_image.txt',$
                shiftlist='../proc/master_shifts.txt',/dodivide

a1 = mrdfits('straight_skymedian.fits',0,skyHead)

  medSpec = median(a1,dimension=2)
  medSImg = rebin(medspec,fxpar(skyHead,'NAXIS1'),fxpar(skyHead,'Naxis2'))
  secondFlat = a1 / medSimg
  writefits,'straight_skyresponse.fits',secondFlat,skyHead

  ;; Reverse the shift process to unstraighten
straighten_spec,'straight_skyresponsename.txt','curved_sky_responseName.txt',$
                shiftlist='../proc/master_shifts.txt',/reverse

end

