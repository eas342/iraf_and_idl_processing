pro quick_response
;; Takes the trimmed flat and uses a simple median filter to remove 

  a1 = mrdfits('trimflat.fits',0,flathead)
  medianF = filter_image(a1,median=20,/all_pixels)
  div = a1 / medianF
  writefits,'median_response.fits',div,flatHead

end
