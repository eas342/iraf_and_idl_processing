function mod_rdfits,filen,ext,header,trimReg=trimReg,silent=silent
;; Same as mrdfits, but if the image has been trimmed, this script
;; finds puts a section of 0s where the original image was (but only
;; in the short direction, since the long direction isn't known)
  a = mrdfits(filen,ext,header,silent=silent)
  if n_elements(header) EQ 0 then begin
     print,"No Header found"
     return,[0]
  endif
  ttrue = fxpar(header,"TRIM",count=count)
  if count GE 1 then begin ;; was it trimmed?
     ccdsec = fxpar(header,"CCDSEC",count=count2)
     if count2 LT 1 then begin
        print,"Warning, unknown trim keywords."
        return,a
     endif else begin
        trimReg = parse_iraf_regions(ccdsec)
        b = fltarr(trimReg[1]+1l,trimReg[3]+1l)
        if fxpar(header,"NAXIS1") EQ (trimReg[1] - trimReg[0] + 1l) and $
           fxpar(header,"NAXIS2") EQ (trimReg[3] - trimReg[2] + 1l) then begin
           b[trimReg[0]:trimReg[1],trimReg[2]:trimReg[3]] = a
        endif else b =a
     endelse
  endif else b=a
  if fxpar(header,'NAXIS') EQ 3 then begin
     ;; For now we'll read spectra 3d data cubes for spsectra
     ;; as firsta aperture
     c = fltarr(fxpar(header,'NAXIS1'),fxpar(header,'NAXIS3'))
     c[*,*] = b[*,0,*]
  endif else c=b

  return,c
end
