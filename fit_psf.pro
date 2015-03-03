pro fit_psf,input,lineP
;; FITS a PSF to an image given a zoombox
;; a - the image
;; zoombox - the BOX region to fit

type = size(input,/type)

if type EQ 7 then begin
   a = mod_rdfits(input,0,header)
endif else a=input

               
if n_elements(lineP) EQ 0 then begin
   print,'No Line or Box Specified'
   return
endif
if LineP.type NE 'box' then begin
   print,'Box not specified'
   return
endif

sz = size(a)

if keyword_set(usefunc) then begin
   sz = sz
endif else begin
;      winsize = 11
;      refX = 65
;      refY = 66
   xstart = max([lineP.Xcoor[0],0])
   xend = min([lineP.Xcoor[1],sz[1]-1l])
   ystart = max([lineP.Ycoor[0],0])
   yend = min([lineP.Ycoor[1],sz[2]-1l])
   a2fit = a[xstart:xend,ystart:yend]

   result = gauss2dfit(a2fit,fitp,/tilt)
   fitp[4] = fitp[4] + xstart
   fitp[5] = fitp[5] + ystart
   
   ;; Set up contour plot
   X = FINDGEN(sz[1]) # REPLICATE(1.0, sz[2])
   Y = REPLICATE(1.0, sz[1]) # FINDGEN(sz[2])
   
   xprime = (X - fitp[4])*cos(fitp[6]) - (Y - fitp[5])*sin(fitp[6])
   yprime = (X - fitp[4])*sin(fitp[6]) + (Y - fitp[5])*cos(fitp[6])
   Ufit = (xprime/fitp[2])^2 + (yprime/fitp[3])^2
   Ymodel = fitp[0] + fitp[1] * EXP(-Ufit/2)

   if not keyword_set(noplot) then begin
      sig = fitp[3]
;            print,flist[i]
      print,"Constant, scale factor, X width, Y width, X cen, Y cen, Theta (CCW)"
      print,"Fit Param = ",fitp
;            plotimage,a,range=[min(a),max(a)],pixel_aspect_ratio=1.0
      contour,ymodel,/overplot,color=mycol('red'),nlevels=3,levels=[0.5 * fitp[1]]
;      print,"Fit Sigma = ",fitp[2]
;         c = contour(ymodel,/overplot,c_thick=[4],color='red')
   endif

endelse
   

end
