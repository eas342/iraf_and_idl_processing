function find_click_box,filen,bcolor=bcolor,$
                        get_direction=get_direction,$
                        plotp=plotp,struct=struct
;; This function takes user input and draws a box
;; filen - an optional input to display the file
;; bcolor - an option to specify the color of the box
;; returns an array of 2 points x coordinates then y coordinates
;; [[xBL,yBL],[xTR,yTR]] for x,y bottom left and top right
;; get_direction - find out an X or Y direction for plotting. Then,
;;                 the output is a structure, direction, xcoor/ycoor etc.
;; struct - keyword that specifies whether to output an array or structure

  if n_elements(filen) NE 0 then begin
     fits_display,filen,plotp=plotp
  endif

  if n_elements(bcolor) EQ 0 then bcolor=mycol('green')

  print,'Draw lower left corner of box'
  cursor,x1,y1,/down
  print,'Draw upper right corner of box'
  cursor,x2,y2,/down

  xboxBL = min([x1,x2]) ;; ensure that BL and top Right are found
  xboxTR = max([x1,x2])
  yboxBL = min([y1,y2])
  yboxTR = max([y1,y2])

  boxW = xboxTR - xboxBL
  boxH = yboxTR - yboxBL
  boxArrX = [xboxBL,xboxBL,xboxTR,xboxTR,xboxBL]
  boxArrY = [yboxBL,yboxTR,yboxTR,yboxBL,yboxBL]

  if keyword_set(get_direction) or keyword_set(struct) then begin
     print,'Change direction w/ left mouse click. Right click when done'
     direction = 'x'
     outArray = create_struct('direction',direction,$
                              'Xcoor',[min(boxArrX),max(boxArrX)],$
                              'Ycoor',[min(boxArrY),max(boxArrY)],$
                              'type','box')
     while  (!mouse.button NE 4) and keyword_set(get_direction) do begin
        if outarray.direction EQ 'x' then outarray.direction = 'y' else begin
           outarray.direction = 'x'
        endelse
        fits_display,filen,plotp=plotp,lineP=outarray
;        plots,boxArrX,boxarrY,color=bcolor,thick=1.8
;        box_display,outarray
        cursor,xjunk,yjunk,/down,/normal
     endwhile
     !MOUSE.button=1
  endif else begin
     
     plots,boxArrX,boxarrY,color=bcolor,thick=1.8
     print,'Click again to exit'
     cursor,xjunk,yjunk,/down
     outArray = [[xboxBL,xboxTR],[yboxBL,yboxTR]]
  endelse

  return,outArray

end
