;; Finds the center of the slit
function slit_position_find,a,xMod=xMod,yMod=yMod
  deriv = a - shift(a,1,0)
  subStartX = 223
  substartY = 9
  subWind = deriv[substartX:267,substartY:449]
  ylength = n_elements(subwind[0,*])
  centerX = fltarr(ylength)
  yVal = findgen(ylength) + float(substartY)
  for i=0l,ylength-1l do begin
     maxVal = max(subWind[*,i],indMax)
     minVal = min(subWind[*,i],indMin)
     centerX[i] = mean(float([indMax,indMin])) + substartX
  endfor

end
