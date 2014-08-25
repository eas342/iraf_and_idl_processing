pro fits_display,input,findscale=findscale,$
                 usescale=usescale,outscale=outscale
;; This script displays a fits image and allows you to set the scaling
;; If the input is a data array, it uses that
;; if the input is a string, it reads the file
;; with right right mouse click and exit the scaling with a left click
;; findscale - directs fits_display to find a scaling
;; usescale - directs fits_display to use a specific histogram
;;            scaling. It is a 6 element array. [xbL,xtR,ybL,ytL,low,high]
;; outscale  - a user variable to store the scale found with the mouse

type = size(input,/type)

if type EQ 7 then begin
   a = mrdfits(input,0,header)
   Ftitle = input
endif else begin 
   a=input
   Ftitle = ''
endelse

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
      usescale = [xboxBL,xboxTR,yboxBL,yboxTR,xcur,ycur]
      scaleNums = threshold(a[usescale[0]:usescale[1],$
                              usescale[2]:usescale[3]],$
                            low=usescale[4],high=usescale[5])
      plotimage,a,range=scaleNums,$
                title='Scaling Mode L click to scale, R click to exit'
      plots,boxArrX,boxarrY,color=mycol('green'),thick=1.8
      cursor,xcur,ycur,/normal,/down
      outscale = usescale
   endwhile
endif
if n_elements(usescale) EQ 0 then begin
   scaleNums = threshold(a,low=0.3,high=0.7)
endif else begin
   maxX = n_elements(a[*,0]) - 1l
   maxY = n_elements(a[0,*]) - 1l
   if maxX LT usescale[1] then usescale[1] =maxX
   if maxY LT usescale[3] then usescale[3] =maxY
   scaleNums = threshold(a[usescale[0]:usescale[1],$
                          usescale[2]:usescale[3]],$
                         low=usescale[4],high=usescale[5])
endelse

plotimage,a,range=scaleNums,title=Ftitle
!MOUSE.button = 1


end
