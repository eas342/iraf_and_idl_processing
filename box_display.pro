pro box_display,boxArr
;; Shows the current direction of a box (for line plotting, etc.) and


if boxArr.direction EQ 'x' then begin
   x1 = min(boxArr.Xcoor)
   x2 = max(boxArr.Xcoor)
   y1 = mean(boxArr.Ycoor)
   y2 = y1
endif else begin
   x1 = mean(boxArr.Xcoor)
   x2 = x1
   y1 = min(boxArr.Ycoor)
   y2 = max(boxArr.Ycoor)
endelse

arrow,x1,y1,x2,y2,hthick=2,thick=2,color=mycol('red'),/data
arrow,x2,y2,x1,y1,hthick=2,thick=2,color=mycol('red'),/data

end
