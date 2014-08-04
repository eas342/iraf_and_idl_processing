function norm_array,array,apsize,locs
;; normalize an array so that each profile's sum is equal to 1
nlocs = n_elements(locs)
npts = n_elements(array)
outarray = fltarr(npts)

for i=0l,nlocs-1l do begin
   startpt = max([locs[i] - apsize,0])
   endpt = min([locs[i] + apsize,npts-1l])
   totalVal = total(array[startpt:endpt])
   outarray[startpt:endpt] = array[startpt:endpt]/totalVal
endfor

return, outarray

end


