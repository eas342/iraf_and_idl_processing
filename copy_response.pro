pro copy_response
;; Copies the response file but with the original file dimensions

;; Get the trim region
openr,1,'local_red_params.cl'

junk = ""
trimReg = ""
readf,1,junk
readf,1,junk
readf,1,trimReg
close,1
split1 = strsplit(trimReg,':',/extract)
split2 = strsplit(split1[0],'[',/extract)
x1 = long(split2[1]) - 1l
split3 = strsplit(split1[1],',',/extract)
x2 = long(split3[0]) - 1l 
y1 = long(split3[1]) - 1l
split4 = strsplit(split1[2],']',/extract)
y2 = long(split4[0]) -1l 
;; Subtract 1 for zero based counting

a = mrdfits('response.fits',0,rheader)
f = mrdfits('masterflat.fits',0,fheader)

xlength = fxpar(fheader,'NAXIS1')
ylength = fxpar(fheader,'NAXIS2')
outArray = fltarr(xlength,ylength)
outhead = rheader
sxaddpar,outhead,'NAXIS1',xlength
sxaddpar,outhead,'NAXIS2',ylength
sxaddpar,outhead,'Expanded',1,'Expanded Respone to full image size'

;; Change the WCS stuff
sxaddpar,outhead,'LTV1',0l
sxaddpar,outhead,'LTV2',0l

outarray[x1:x2,y1:y2] = a
writefits,'full_response.fits',outarray,outhead

end
