pro fits_display,input,findscale=findscale,$
                 plotp=plotp,$
                 message=message,lineP=lineP
;; This script displays a fits image and allows you to set the scaling
;; 
;; IT USES ZERO-Based counting, to be consistent with IDL and plotimage
;;     2.0 +-----------+-----------+ 
;;         |           |           |  
;;         | IMG[0,1]  | IMG[1,1]  |  
;;     1.5 |     +     |     +     | 
;;         |           |           |  
;;         |           |           |  
;;     1.0 +-----------+-----------+ 
;;         |           |           |  
;;         | IMG[0,0]  | IMG[1,0]  |  
;;     0.5 |     +     |     +     | 
;;         |           |           |  
;;         |           |           |  
;;     0.0 +-----------+-----------+ 
;;        0.0   0.5   1.0   1.5   2.0
;;
;; This is different from SAOImage DS9, which uses (0.5, 0.5) for the
;; bottom left corner. 
;;
;; 
;;
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
if type EQ 7 then begin
   a = mod_rdfits(input,0,header,plotp=plotp,/silent)
endif else a = input

if n_elements(a) LT 2 then begin
   message,"Less than 2 pixels in image!"
   if type EQ 7 then print,'(For image ',input,')'
   return
endif

case 1 of
   ev_tag_exist(plotp,'IMGTITLEKEY'): begin
      if n_elements(header) GT 0 then begin
         Ftitle = fxpar(header,plotp.imgtitlekey,count=count)
         if count EQ 0 then message,'Keyword not found in header',/cont
      endif else begin
         message,'No header found',/cont
      endelse
   end
   n_elements(message) NE 0: Ftitle=message 
   type EQ 7: Ftitle = input
   else: Fitle = ''
endcase

if ev_tag_true(plotp,'STRETCH') EQ 0 then paspectR=1.0

if keyword_set(findscale) then begin
;; start cursor
   xcur = 0.3
   ycur = 0.8
   message = 'Click lower left corner of box for scaling and then right'
   asize = size(a)
   if ev_tag_exist(plotp,'ZOOMBOX') then begin
      myXrange = fltarr(2)
      myYrange = fltarr(2)
      myXrange[0] = min(plotp.zoombox[*,0])
      myXrange[1] = max(plotp.zoombox[*,0])
      myYrange[0] = min(plotp.zoombox[*,1])
      myYrange[1] = max(plotp.zoombox[*,1])
      maxImgRange = 0
   endif else begin
      myYrange = [0,asize[2] - 1l]
      myXrange = [0,asize[1] - 1l]
   endelse

   if ev_tag_exist(plotp,'FULLSCALE') then begin
      myPrange=[min(a),max(a)]
   endif else myPrange=threshold(a,low=xcur,high=ycur)


   plotimage,a,range=myPrange,$
             xrange=myXrange,yrange=myYrange,$
             title='Draw lower Left corner of box for scaling and left click',$
             pixel_aspect_ratio=paspectR
   cursor,xbox1,ybox1,/down
   plotimage,a,range=myPrange,$
             xrange=myXrange,yrange=myYrange,$
             title='Draw Upper Right corner of box for scaling and left click',$
             pixel_aspect_ratio=paspectR
   cursor,xbox2,ybox2,/down
   
   ;; Ensure that the bottom is bottom and top is top
   xboxBL = min([xbox1,xbox2])
   yboxBL = min([ybox1,ybox2])
   xboxTR = max([xbox1,xbox2])
   yboxTR = max([ybox1,ybox2])
   
   boxW = xboxTR - xboxBL
   boxH = yboxTR - yboxBL
   xboxBL = checkrange(xboxBL,0,asize[1]-1l)
   xboxTR = checkrange(xboxTR,0,asize[1]-1l)
   yboxBL = checkrange(yboxBL,0,asize[2]-1l)
   yboxTR = checkrange(yboxTR,0,asize[2]-1l)
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
                pixel_aspect_ratio=paspectR
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
   if (myXrange[1] - myXrange[0]) * 2 LT (myYrange[1] - myYrange[0]) then begin
      do2xtick=1
      myxtickformat='(A1)'
   endif
   if (myXrange[1] - myXrange[0])  GT 5 * (myYrange[1] - myYrange[0]) then begin
      do2ytick=1
      myytickformat='(A1)'
   endif
endif else begin
   imsize = size(a)
   if imsize[1] * 2 LT imsize[2] then begin
      do2xtick=1
      myxtickformat='(A1)'
   endif
   if imsize[1] GT 5 * imsize[2] then begin
      do2ytick=1
      myytickformat='(A1)'
   endif
endelse
ev_mplotimage,a,range=scaleNums,title=Ftitle,$
              xrange=myXrange,yrange=myYrange,$
              pixel_aspect_ratio=paspectR,$
              xtick_get=xtickvals,ytick_get=ytickvals,$
              xtickformat=myxtickformat,ytickformat=myytickformat

if n_elements(do2xtick) GT 0 then begin
   if do2xtick then twotick_labels,xtickvals,ytickvals,/noY,xorient=45
endif
if n_elements(do2ytick) GT 0 then begin
   if do2ytick then twotick_labels,xtickvals,ytickvals,/noX
endif


!MOUSE.button = 1

if n_elements(lineP) NE 0 then begin
   case LineP.type of
      'line': $
         oplot,LineP.xcoor,LineP.ycoor,color=mycol('red'),thick=2
      'points': begin
         plotsym,0
         oplot,lineP.xcoor,lineP.ycoor,psym=8,color=mycol('red')
      end
      'box': begin
         boxArrX = [lineP.xcoor[0],lineP.xcoor[0],lineP.xcoor[1],lineP.xcoor[1],lineP.xcoor[0]]
         boxArrY = [lineP.ycoor[0],lineP.ycoor[1],lineP.ycoor[1],lineP.ycoor[0],lineP.ycoor[0]]
         oplot,boxArrX,boxArrY,color=mycol('red'),thick=2
         box_display,LineP
      end
      else: print,'LineP type not found'
   endcase
endif

if ev_tag_true(plotp,'SHOWPHOT') then begin
   photfile = 'ev_phot_data.sav'
   if file_exists(photfile) and type EQ 7 then begin
      restore,photfile
      prevPhotpt = where(photdat.filen EQ input,count)
      get_phot_params,aperRad,skyArr
      if count NE 0 then begin
         for i=0l,count-1l do begin
            show_phot,photdat[prevPhotpt[i]],skyArr,aperRad,size(a),plotp=plotp
         endfor
      endif
   endif
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
