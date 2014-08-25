function mod_rdfits,filen,ext,header,trimReg=trimReg,silent=silent
;; Same as mrdfits, but if the image has been trimmed, this script
;; finds puts a section of 0s where the original image was (but only
;; in the short direction, since the long direction isn't known)
  a = mrdfits(filen,ext,header,silent=silent)
  ttrue = fxpar(header,"TRIM",count=count)
  if count GE 1 then begin ;; was it trimmed?
     ccdsec = fxpar(header,"CCDSEC",count=count2)
     if count2 LT 1 then begin
        print,"Warning, unknown trim keywords."
        return,a
     endif else begin
        trimReg = parse_iraf_regions(ccdsec)
        b = fltarr(trimReg[1]+1l,trimReg[3]+1l)
        b[trimReg[0]:trimReg[1],trimReg[2]:trimReg[3]] = a
     endelse
  endif else b=a
  return,b
end
