function mod_rdfits,filen,ext,header,trimReg=trimReg,silent=silent,$
                    plotp=plotp
;; Same as mrdfits, but if the image has been trimmed, this script
;; finds puts a section of 0s where the original image was (but only
;; in the short direction, since the long direction isn't known)
;; plotp - accepts the display parameters to put in image rotations
  
  type = size(filen,/type)
  if type NE 7 then begin
     c = filen
     return, c
     ;; Check if it's already an image
  endif

  a = mrdfits(filen,ext,header,silent=silent)
  if ev_tag_exist(plotp,'ROT') then begin
     a = rotate(a,plotp.rot)
  endif
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
  if ev_tag_exist(plotp,'FLATFILE') then begin
     f = mrdfits(plotp.flatfile,ext,flathead,silent=silent)
     nonz = where(f NE 0)
     b = float(b)
     if nonz NE [-1] then begin
        b[nonz] = b[nonz] / float(f[nonz])
     endif
  endif

  if fxpar(header,'NAXIS') EQ 3 then begin
     ;; For now we'll read spectra 3d data cubes for spsectra
     ;; as firsta aperture
     c = fltarr(fxpar(header,'NAXIS1'),fxpar(header,'NAXIS3'))
     c[*,*] = b[*,0,*]
  endif else c=b

  return,c
end
