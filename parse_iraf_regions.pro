function parse_iraf_regions,str
;; Reads in a string like '[65:749,33:617]' and returns an array like
;; [65,749,33,617] with numbers as longs. It also by default subtracts
;; one to convert from 1 based counting to 0-based counting
split1 = strsplit(str,':',/extract)
split2 = strsplit(split1[0],'[',/extract)
nsplit2 = n_elements(split2)
x1 = long(split2[nsplit2-1l]) - 1l
split3 = strsplit(split1[1],',',/extract)
x2 = long(split3[0]) - 1l 
y1 = long(split3[1]) - 1l
split4 = strsplit(split1[2],']',/extract)
y2 = long(split4[0]) -1l 
;; Subtract 1 for zero based counting

return,[x1,x2,y1,y2]

end
