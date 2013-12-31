pro find_bad_diagonals
;; This script is designed to locate the weird lines of bad pixels in
;; SpeX images

a = mrdfits('run00_0005.a.fits',0,header)

plotimage,a,range=[500,1000]

xlength = fxpar(header,'NAXIS1')
ylength = fxpar(header,'NAXIS2')
Xcoors = rebin(lindgen(xlength),xlength,ylength)
Ycoors = transpose(rebin(lindgen(ylength),ylength,xlength))

;; Find the first diagonal
badDiag1 = where(Xcoors GE 938 and $
                 Ycoors LE 498 and $
                 Ycoors GE 355 and $
                 a LE 150)

;putBack = where(

badDiag2 = where(Xcoors GE 1000 and $
                 Ycoors LE 155 and $
                 Ycoors GE 110 and $
                 a LE 150)

mask = lonarr(xlength,ylength)
mask[badDiag1] = 2l
mask[badDiag2] = 2l
plotimage,mask,range=[0,2],xrange=[900,1024],yrange=[0,550]
;; Save the mask
writefits,'diagonal_mask.fits',mask,header

end
