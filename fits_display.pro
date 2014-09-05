pro fits_display,input,findscale=findscale,$
                 usescale=usescale,outscale=outscale,$
                 message=message,lineP=lineP,zoomBox=zoomBox
;; This script displays a fits image and allows you to set the scaling
;; If the input is a data array, it uses that
;; if the input is a string, it reads the file
;; with right right mouse click and exit the scaling with a left click
;; findscale - directs fits_display to find a scaling
;; usescale - directs fits_display to use a specific histogram
;;            scaling. It is a 6 element array. [xbL,xtR,ybL,ytL,low,high]
;; outscale  - a user variable to store the scale found with the mouse
;; message - a message to the display in the title
;; lineP - load in and display previous line and box parameters
;; zoomBox - a region to zoom in on the image

type = size(input,/type)

if type EQ 7 then begin
   a = mod_rdfits(input,0,header)
endif else a=input

case 1 of
   keyword_set(message): Ftitle=message 
   type EQ 7: Ftitle = input
   else: Fitle = ''
endcase


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
   if maxX LT usescale[0] then usescale[0] =maxX
   if maxX LT usescale[1] then usescale[1] =maxX
   if maxY LT usescale[2] then usescale[2] =maxY
   if maxY LT usescale[3] then usescale[3] =maxY
   
   scaleNums = threshold(a[usescale[0]:usescale[1],$
                          usescale[2]:usescale[3]],$
                         low=usescale[4],high=usescale[5])
endelse

if n_elements(zoombox) EQ 0 then begin
   plotimage,a,range=scaleNums,title=Ftitle
endif else begin
   myXrange = fltarr(2)
   myYrange = fltarr(2)
   myXrange[0] = min(zoombox[0,*])
   myXrange[1] = max(zoombox[0,*])
   myYrange[0] = min(zoombox[1,*])
   myYrange[1] = max(zoombox[1,*])
   plotimage,a,range=scaleNums,title=Ftitle,$
             xrange=myXrange,yrange=myYrange
endelse


!MOUSE.button = 1

if n_elements(lineP) NE 0 then begin
   if LineP.type EQ 'line' then begin
      oplot,LineP.xcoor,LineP.ycoor,color=mycol('red'),thick=2
   endif else begin
      boxArrX = [lineP.xcoor[0],lineP.xcoor[0],lineP.xcoor[1],lineP.xcoor[1],lineP.xcoor[0]]
      boxArrY = [lineP.ycoor[0],lineP.ycoor[1],lineP.ycoor[1],lineP.ycoor[0],lineP.ycoor[0]]
      oplot,boxArrX,boxArrY,color=mycol('red'),thick=2
      box_display,LineP
   endelse
endif

end
