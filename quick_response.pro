pro quick_response,custfile=custfile
;; Takes the trimmed flat and uses a simple median filter to remove 

  if n_elements(custfile) EQ 0 then custfile = 'trimflat.fits'
  a1 = mrdfits(custfile,0,flathead)
  medianF = filter_image(a1,median=20,/all_pixels)
  div = a1 / medianF
  writefits,'median_filtered_response.fits',div,flatHead

end
