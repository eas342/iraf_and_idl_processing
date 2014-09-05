function fits_line_draw,filen,useScale=usescale,zoombox=zoombox
;; Allows a user to draw a line on a fits image which can later be
;; plotted
  
  fits_display,filen,usescale=usescale,zoombox=zoombox
  cursor,xcur1,ycur1,/down
  cursor,xcur2,ycur2,/down
  deltaX = xcur2 - xcur1
  deltaY = ycur2 - ycur1
  if abs(deltaY) GE abs(deltaX) then begin
     xcur2 = xcur1
     direction = 'y'
  endif else begin
     ycur2 = ycur1
     direction = 'x'
  endelse

  xcoor = [xcur1,xcur2]
  ycoor = [ycur1,ycur2]
  lineP = create_struct('direction',direction,$
                        'XCOOR',xcoor,$
                        'YCOOR',ycoor,'type','line')
  oplot,xcoor,ycoor,color=mycol('red'),thick=2
  return, lineP

end
