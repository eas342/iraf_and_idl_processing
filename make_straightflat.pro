pro make_straightflat
;; Makes a flat image from the straighted sky images

  a1 = mrdfits('skymedian.fits',0,skyHead)
  medSpec = median(a1,dimension=2)
  medSImg = rebin(medspec,fxpar(skyHead,'NAXIS1'),fxpar(skyHead,'Naxis2'))
  secondFlat = a1 / medSimg
  writefits,'secondflat.fits',secondFlat,skyHead


end
