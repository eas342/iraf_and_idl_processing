pro fits_display,input,findscale=findscale,$
                 usescale=usescale,outscale=outscale
;; This script displays a fits image and allows you to set the scaling
;; If the input is a data array, it uses that
;; if the input is a string, it reads the file
;; with right right mouse click and exit the scaling with a left click
;; findscale - directs fits_display to find a scaling
;; usescale - directs fits_display to use a specific histogram scaling
;; outscale  - a user variable to store the used scale

type = size(input,/type)

if type EQ 7 then a = mrdfits(input,0,header) else a=input

if keyword_set(findscale) then begin
;; start cursor
   xcur = 0.3
   ycur = 0.8
   plotimage,a,range=threshold(a,low=xcur,high=ycur),$
             title='Draw lower Left corner of box for scaling and left click'
   cursor,xboxBL,yboxBL,/down
   plotimage,a,range=threshold(a,low=xcur,high=ycur),$
             title='Draw Upper Right corner of box for scaling and left click'
   cursor,xboxTR,yboxTR,/down
   boxW = xboxTR - xboxBL
   boxH = yboxTR - yboxBL
   boxArrX = [xboxBL,xboxBL,xboxTR,xboxTR,xboxBL]
   boxArrY = [yboxBL,yboxTR,yboxTR,yboxBL,yboxBL]
   plots,boxArrX,boxarrY,color=mycol('green'),thick=1.8

   while(!mouse.button NE 4) do begin
      outscale = threshold(a[xboxBL:xboxTR,yboxBL:yboxTR],low=xcur,high=ycur)
      plotimage,a,range=outscale,$
                title='Scaling Mode L click to scale, R click to exit'
      plots,boxArrX,boxarrY,color=mycol('green'),thick=1.8
      cursor,xcur,ycur,/normal,/down
   endwhile
   usescale = outscale
endif
if n_elements(usescale) EQ 0 then usescale = [0.3,0.7]
plotimage,a,range=usescale
!MOUSE.button = 1


end
