function find_adist,full1,full2,units
;; Finds the angular distance between two coordinages
;; expects an RA + dec string in hours, degrees Sexagesimal for each coordinate

  c1 = strsplit(full1,' ',/extract)
  c2 = strsplit(full2,' ',/extract)
  gcirc,1,ten(c1[0],c1[1],c1[2]),ten(c1[3],c1[4],c1[5]),$
        ten(c2[0],c2[1],c2[2]),ten(c2[3],c2[4],c2[5]),dist

  if n_elements(units) EQ 0 then units='arcsec'
  case units of
     'rad': finaldist = dist / 206264.80624709636322D
     'deg': finaldist = dist / 3600D
     'arcmin': finaldist = dist / 60D
     else: finaldist = dist
  endcase

  return,finaldist

end
