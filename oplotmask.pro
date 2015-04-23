pro oplotmask,maskp
;; Over plots the mask boxes

nbox = n_elements(maskp)
for i=0l,nbox-1l do begin
   boxArrX = [maskp[i].xcoor[0],maskp[i].xcoor[0],maskp[i].xcoor[1],$
              maskp[i].xcoor[1],maskp[i].xcoor[0]]
   boxArrY = [maskp[i].ycoor[0],maskp[i].ycoor[1],maskp[i].ycoor[1],$
              maskp[i].ycoor[0],maskp[i].ycoor[0]]
   oplot,boxArrX,boxArrY,color=mycol('blue'),thick=2
endfor

end
