function mod_rdfits,filen,ext,header,trimReg=trimReg,silent=silent,$
                    plotp=plotp,fileDescrip=fileDescrip
;; Same as mrdfits, but if the image has been trimmed, this script
;; finds puts a section of 0s where the original image was (but only
;; in the short direction, since the long direction isn't known)
;; plotp - accepts the display parameters to put in image rotations
  
  type = size(filen,/type)
  if not ev_tag_exist(plotp,'FSCALE') then fscale=1 else begin
     fscale=plotp.fscale
  endelse

  if ev_tag_exist(plotp,'CHOOSEEXTEN') then begin
     ;; This overrides the exten argument!!
     ;; I should probably adjust this
     ext = plotp.chooseexten
  endif

  if type NE 7 then begin
     c = filen
     fileDescrip = 'None'
     return, c
     ;; Check if it's already an image
  endif else fileDescrip=filen

  if ev_tag_true(plotp,'LRIS') then begin
     a = readmhdufits(filen,header=header)
  endif else begin
     fits_info,filen,N_ext=N_ext,/silent
     if ext GT (N_ext - 1) then begin
        message,'Only '+strtrim(N_ext,1)+' extensions in file. Reading 0',/cont
        ext = 0
     endif
     a = mrdfits(filen,ext,header,silent=silent,fscale=fscale)
  endelse
  
  if n_elements(a) LT 2 then begin
     message,'Extension '+strtrim(ext,1)+' not found, trying '+strtrim(ext+1l,1),/cont
     a = mrdfits(filen,ext+1,header,silent=silent,fscale=fscale)
  endif
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
  endif else begin
     if ev_tag_true(plotp,'JWSUB') then begin
        colcnr = fxpar(header,'COLCORNR')
        rowcnr = fxpar(header,'ROWCORNR')
        oNAXIS1 = fxpar(header,'NAXIS1')
        oNAXIS2 = fxpar(header,'NAXIS2')
        showRegX = [colcnr -1l,colcnr -2l + oNAXIS1]
        showRegY = [rowcnr -1l,rowcnr -2l + oNAXIS2]
        if fxpar(header,'NAXIS') EQ 3 then begin
           b = fltarr(oNAXIS1 + colcnr - 1l,oNAXIS2 + rowcnr - 1l,fxpar(header,'NAXIS3'))
           b[showRegX[0]:showRegX[1],showRegY[0]:showRegY[1],*] = a
        endif else begin
           b = fltarr(oNAXIS1 + colcnr - 1l,oNAXIS2 + rowcnr - 1l)
           b[showRegX[0]:showRegX[1],showRegY[0]:showRegY[1]] = a
        endelse
     endif else b=a
  endelse

  if fxpar(header,'NAXIS') EQ 3 then begin
     ;; For now we'll read spectra 3d data cubes for spsectra
     ;; as firsta aperture
     sz = size(b) ;; could be different from original array b/c of trimming/subarrays
     case 1 of
        ev_tag_true(plotp,'DCSsub'): begin
           if ev_tag_exist(plotp,'ChoosePlane') then begin
              cPlane = plotp.ChoosePlane
              if cPlane GE 0 and cPlane LT fxpar(header,'NAXIS3') then begin
                 minuendPlane = cPlane
              endif else begin
                 message,'Invalid Plane, using -1',/cont
                 minuendPlane = -1
              endelse
           endif else minuendPlane = -1
           c = fltarr(sz[1],sz[2])
           c[*,*] = b[*,*,minuendPlane] - b[*,*,0]
        end
        ev_tag_exist(plotp,'ChoosePlane'): begin
           plane = plotp.ChoosePlane

           if plane GE 0 and plane LT fxpar(header,'NAXIS3') then begin
              c = b[*,*,plotp.ChoosePlane]
           endif else begin
              message,'ChoosePlane is an invalid plane',/cont
              c=b
           endelse
        end
        else: begin
           c = fltarr(sz[1],sz[3])
           c[*,*] = b[*,0,*]
        end
     endcase
  endif else c=b

  if ev_tag_exist(plotp,'BIASFILE') then begin
     subName = clobber_exten(plotp.biasfile,exten=exten)
     if exten EQ '.sav' then begin 
        restore,plotp.biasfile
     endif else begin
        bias = mrdfits(plotp.biasfile,ext,biashead,silent=silent,fscale=fscale)
     endelse
     c = c - biasimg
  endif

  if ev_tag_exist(plotp,'FLATFILE') then begin
     subName = clobber_exten(plotp.flatfile,exten=exten)
     if exten EQ '.sav' then begin 
        restore,plotp.flatfile
        c = float(c) / flatdata
     endif else begin
        f = mrdfits(plotp.flatfile,ext,flathead,silent=silent,fscale=fscale)
        nonz = where(f NE 0)
        c = float(c)
        if nonz NE [-1] then begin
           c[nonz] = c[nonz] / float(f[nonz])
        endif
     endelse
     
  endif

  return,c
end
