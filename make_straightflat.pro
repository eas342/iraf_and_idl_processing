pro make_straightflat,custfile=custfile
;; Makes a flat image from the straighted sky images

  if n_elements(custfile) EQ 0 then custfile='skymedian.fits'
  a1 = mrdfits(custfile,0,skyHead)
  medSpec = median(a1,dimension=2)
  medSImg = rebin(medspec,fxpar(skyHead,'NAXIS1'),fxpar(skyHead,'Naxis2'))
  secondFlat = a1 / medSimg
  writefits,'straight_median_spec_image.fits',medSimg,skyHead
  writefits,'secondflat.fits',secondFlat,skyHead


end
