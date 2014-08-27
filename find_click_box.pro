function find_click_box,bcolor=bcolor
;; This function takes user input and draws a box
;; bcolor - an option to specify the color of the box
;; returns an array of 2 points x coordinates then y coordinates
;; [[xBL,yBL],[xTR,yTR]] for x,y bottom left and top right
  print,'Draw lower left corner of box'
  cursor,xboxBL,yboxBL,/down
  print,'Draw upper right corner of box'

  if n_elements(bcolor) EQ 0 then bcolor=mycol('green')
  cursor,xboxTR,yboxTR,/down
  boxW = xboxTR - xboxBL
  boxH = yboxTR - yboxBL
  boxArrX = [xboxBL,xboxBL,xboxTR,xboxTR,xboxBL]
  boxArrY = [yboxBL,yboxTR,yboxTR,yboxBL,yboxBL]
  plots,boxArrX,boxarrY,color=bcolor,thick=1.8
  outArray = [[xboxBL,yboxBL],[xboxTR,yboxTR]]

  print,'Click again to exit'
  cursor,xjunk,yjunk,/down
  return,outArray

end
