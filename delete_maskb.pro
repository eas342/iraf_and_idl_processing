pro delete_maskb,maskp
  print,'Click nearest to box to delete'
  cursor,x1,y1,/down
  
  nmask = n_elements(maskp)
  if nmask EQ 0 then begin
     message,'No Mask to delete!',/continue
  endif else begin
     boxCenX = 0.5E * (maskp.xcoor[0] + maskp.xcoor[1])
     boxCenY = 0.5E * (maskp.ycoor[0] + maskp.ycoor[1])
     dist = sqrt((x1 - boxCenX)^2 + (y1 - boxCenY)^2)
     if nmask EQ 1 then begin
        message,'Undefining maskp is not yet working ',/continue
        junk = size(temporary(maskp));undefine,maskp
     endif else begin
        mindist = min(dist,ind)
        others = where(lindgen(nmask) NE ind)
        print,'min index = ',ind
        print,'x positions = ',boxcenX
        print,'y positions = ',boxcenY
        print,'distances = ',dist
        newmask = maskp[others]
        maskp = newmask
     endelse
  endelse

end
