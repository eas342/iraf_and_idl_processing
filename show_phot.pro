pro show_phot,singlephot,skyArr,aperRad,sz
;; Shows photometry for a given point (printing FWHM, etc.)

  xshowfit = singlephot.xcen
  yshowfit = singlephot.ycen

  es_circle,xshowfit,yshowfit,skyArr[0],ccolor=mycol('blue')
  es_circle,xshowfit,yshowfit,skyArr[1],ccolor=mycol('blue')
  for i=0l,n_elements(aperRad)-1l do begin
     es_circle,xshowfit,yshowfit,aperRad[i],ccolor=mycol('lblue')
  endfor
         
  ;; Set up contour plot
  X = FINDGEN(sz[1]) # REPLICATE(1.0, sz[2])
  Y = REPLICATE(1.0, sz[1]) # FINDGEN(sz[2])
  
  Theta = singlephot.OrigTheta
  xprime = (X - xshowfit)*cos(Theta) - (Y - yshowfit)*sin(Theta)
  yprime = (X - xshowfit)*sin(Theta) + (Y - yshowfit)*cos(Theta)
  Ufit = (xprime/ singlephot.xsig)^2 + (yprime/ singlephot.ysig)^2
  Ymodel = singlephot.backg + singlephot.peak * EXP(-Ufit/2)

  descrip=["Back","Peak  ","Maj FWHM","Min FWHM",$
           "X cen","Y cen","Rot CW,d"]
  print,descrip,format='(2A15,5A9)'
  print,singlephot.backg,singlephot.peak,singlephot.MaFWHM,singlephot.MiFWHM,$
        singlephot.xcen,singlephot.ycen,singlephot.theta,$
        format='(2G15,5F9.2)'

  myLevelsUnsort = [0.2,0.5,0.8] * singlephot.peak + singlephot.backg
  lsort = sort(myLevelsUnsort)
  mylevels = myLevelsUnsort[lsort]
  contour,ymodel,/overplot,color=mycol('red'),nlevels=3,levels=mylevels

end
