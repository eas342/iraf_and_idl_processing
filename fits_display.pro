pro fits_display,input,findscale=findscale,$
                 plotp=plotp,$
                 message=message,lineP=lineP
;; This script displays a fits image and allows you to set the scaling
;; If the input is a data array, it uses that
;; if the input is a string, it reads the file
;; with right right mouse click and exit the scaling with a left click
;; findscale - directs fits_display to find a scaling
;; plotp - plot parameters including the scaling
;;           plotp.scaling - directs fits_display to use a specific histogram
;;            scaling. It is a 6 element array. [xbL,xtR,ybL,ytL,low,high]
;;           plotp.zoomBox - a region to zoom in on the image
;;           plotp.rot - the rotation of the image
;; message - a message to the display in the title
;; lineP - load in and display previous line and box parameters
;; rot - the rotation of an image

type = size(input,/type)
a = mod_rdfits(input,0,header,plotp=plotp)

if n_elements(a) LT 2 then begin
   print,"Less than 2 pixels in image!"
   if type EQ 7 then print,'(For image ',input,')'
   return
endif

case 1 of
   n_elements(message) NE 0: Ftitle=message 
   type EQ 7: Ftitle = input
   else: Fitle = ''
endcase


if keyword_set(findscale) then begin
;; start cursor
   xcur = 0.3
   ycur = 0.8
   message = 'Click lower left corner of box for scaling and then right'
   if ev_tag_exist(plotp,'ZOOMBOX') then begin
      myXrange = fltarr(2)
      myYrange = fltarr(2)
      myXrange[0] = min(plotp.zoombox[*,0])
      myXrange[1] = max(plotp.zoombox[*,0])
      myYrange[0] = min(plotp.zoombox[*,1])
      myYrange[1] = max(plotp.zoombox[*,1])
      maxImgRange = 0
   endif else begin
      asize = size(a)
      myYrange = [0,asize[2] - 1l]
      myXrange = [0,asize[1] - 1l]
   endelse

   if ev_tag_exist(plotp,'FULLSCALE') then begin
      myPrange=[min(a),max(a)]
   endif else myPrange=threshold(a,low=xcur,high=ycur)


   plotimage,a,range=myPrange,$
             xrange=myXrange,yrange=myYrange,$
             title='Draw lower Left corner of box for scaling and left click',$
             pixel_aspect_ratio=1.0
   cursor,xboxBL,yboxBL,/down
   plotimage,a,range=myPrange,$
             xrange=myXrange,yrange=myYrange,$
             title='Draw Upper Right corner of box for scaling and left click',$
             pixel_aspect_ratio=1.0
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
                title='Scaling Mode L click to scale, R click to exit',$
                xrange=myXrange,yrange=myYrange,$
                pixel_aspect_ratio=1.0
      plots,boxArrX,boxarrY,color=mycol('green'),thick=1.8
      cursor,xcur,ycur,/normal,/down
      ev_add_tag,plotp,'scale',usescale
      ev_undefine_tag,plotp,'FULLSCALE'
   endwhile
   !MOUSE.button=1
endif

if ev_tag_exist(plotp,'FULLSCALE') then begin
   scaleNums = [min(a),max(a)]
endif else begin
   if ev_tag_exist(plotp,'scale') then begin
      maxX = n_elements(a[*,0]) - 1l
      maxY = n_elements(a[0,*]) - 1l
      if maxX LT plotp.scale[0] then plotp.scale[0] =maxX
      if maxX LT plotp.scale[1] then plotp.scale[1] =maxX
      if maxY LT plotp.scale[2] then plotp.scale[2] =maxY
      if maxY LT plotp.scale[3] then plotp.scale[3] =maxY
      
      scaleNums = threshold(a[plotp.scale[0]:plotp.scale[1],$
                              plotp.scale[2]:plotp.scale[3]],$
                            low=plotp.scale[4],high=plotp.scale[5])
   endif else begin
      scaleNums = threshold(a,low=0.3,high=0.7)
   endelse
endelse

if ev_tag_exist(plotp,'zoombox') then begin
   myXrange = fltarr(2)
   myYrange = fltarr(2)
   myXrange[0] = min(plotp.zoombox[*,0])
   myXrange[1] = max(plotp.zoombox[*,0])
   myYrange[0] = min(plotp.zoombox[*,1])
   myYrange[1] = max(plotp.zoombox[*,1])
   plotimage,a,range=scaleNums,title=Ftitle,$
             xrange=myXrange,yrange=myYrange,$
             pixel_aspect_ratio=1.0
endif else begin
   plotimage,a,range=scaleNums,title=Ftitle,pixel_aspect_ratio=1.0
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

;; Show the mask
if type EQ 7 then begin
   filenInside = clobber_dir(input,/exten,dir=dir)
   maskFile = 'mask_for_'+filenInside+'.fits'
   fileFind = file_search(maskFile)
   if fileFind NE '' then begin
      b = mod_rdfits(fileFind,0,maskhead)
      contour,b,/overplot,color=mycol('blue'),levels=[0,1]
   endif

endif

end
