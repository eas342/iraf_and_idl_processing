pro find_flat_structure,showplot=showplot,showskyfit=showskyfit
;; Fits the flat field line by line, subtracts it, shifts this
;; structure and puts it back in
;; showplot - shows the polynomial fits to the respone function
;; showkyfit - shows the polynomial fits to the sky image

nrowpoly = 0 ;; order of polynomial fitting a row in the response image
nskyrowpoly = 2 ;; order of the polynomial fit to the sky image

b = mod_rdfits('response.fits',0,header,trimReg=trimReg)
a = b[trimReg[0]:trimReg[1],trimREg[2]:trimReg[3]]

;; If sky images list is available, make an average sky
cd,current=currentD
skyList =file_search(currentD+'/sky_choices.txt')
if skyList EQ '' then begin
   print,'NO Sky choices found, so not using sky image in flat fielding...'
endif else begin
   readcol,'sky_choices.txt',skyNames,format='(A)'
   nSky = n_elements(skYNames)
   for i=0l,nSky-1l do begin
      tmpSky = mod_rdfits(skyNames[i],0,skyHead)
      if i EQ 0 then begin
         avgSky = tmpSky
      endif else avgSky = tmpSky + avgSky
   endfor
   avgSky = avgSky / float(nSky)
   trimSky = avgSky[trimReg[0]:trimReg[1],trimREg[2]:trimReg[3]]

   ;; This is will hold an image of the sky response within the box
   boxSky = fltarr(trimReg[1]-trimReg[0]+1l,trimReg[3]-trimReg[2]+1l) + 1E
;; Get the local sky box parameters

   readcol,'local_red_params.cl',skipline=3,$
           junk,varname,varvalue,format='(A,A,A)',delimiter=' '
   if varname[0] NE 'backbox' then begin
      print,'No backbox found for find_flat_structure'
      return
   end else breg = parse_iraf_regions(varvalue[0])
   boxRegL = breg[0] - trimReg[0] ;; account for offset due to trimming
   boxRegR = breg[1] - trimReg[0] ;; account for offset due to trimming
endelse



xlength = fxpar(header,'NAXIS1')
ylength = fxpar(header,'NAXIS2')
columNum = findgen(xlength)
;; Make a structure image
struct = fltarr(xlength,ylength)

;; Make a mask for some of the structure I won't fit
mask = intarr(xlength)
;mask[0l:85l] = 1l

for i=0l,ylength-1l do begin
   polyParam = ev_robust_poly(columNum,a[*,i],nrowpoly,showplot=showplot,mask=mask)
   struct[*,i] = eval_poly(columNum,polyParam)
endfor

if skyList NE '' then begin
   skyStruct = fltarr(ylength)
   for i=0l,ylength-1l do begin
      polyParam = ev_robust_poly(columNum[boxregL:boxregR],trimSky[boxregL:boxregR,i],$
                              nskyrowpoly,showplot=showskyfit,mask=mask)
      if n_elements(polyFit) EQ 0 then begin
         polyFit = eval_poly(columNum[boxregL:boxregR],polyParam)
      endif
;      trimSky = trimSky[boxregL:boxregR,i] / polyFit
      boxSky[boxregL:boxregR,i] = trimSky[boxregL:boxregR,i] / polyFit
      ;; evaluate the peak
;      skyStruct[i] = eval_poly(polyParam[1]/(-2E *
;      polyParam[2]),polyParam)
      skyStruct[i] = eval_poly_integral([boxregL,boxRegR],polyParam)

;      if keyword_set(showskyfit) then begin
;         oplot,!x.crange,[1E,1E]*skyStruct[i],color=mycol('yellow')
;         stop
;      endif
   endfor
   skyStruct = skyStruct/median(skystruct)
   skystripes = 1 ;; flat that sky stripes were used
   ;; Turn sky structure into an image
   skyStructImg = transpose(rebin(skystruct,ylength,xlength))
endif else skystripes=0

ssubI = a / struct;; stripe divided image

;; Put stripe structure back in
if skystripes then begin
   useStruct = skyStructImg
endif else useStruct = struct
outimage = ssubI * useStruct

sheader = header
fxaddpar,sheader,'STRIPE_FIT','TRUE','The result of each row fitted to a polynomial'
fxaddpar,sheader,'STRIPE_ORDER',nrowpoly,'Order of the polynomial fit to each row'
fxaddpar,sheader,'SKY_STRIPES',skystripes,'Was a sky image used to generate a stripe image?'
writefits,'stripes_image.fits',usestruct,sheader
pxheader = sheader
fxaddpar,pxheader,'STRIPE_SUBTRACTED','TRUE','Stripe image subtracted from response file'
writefits,'stripe_sub_image.fits',ssubI,pxheader

;fxaddpar,sheader,'STRIPE_SHIFTED',vertShift,'The amount that each row was shifted before being added back'
writefits,'full_response.fits',outimage,sheader

if skystripes then begin
   outSheader = header
   fxaddpar,outSheader,'SKYAVG','TRUE','Sky frame averaged from many images'
   fxaddpar,outSheader,'fitDivided','TRUE','Polynomial fit divided into the sky image'
   writefits,'sky_response_box.fits',boxSky,outSheader
endif

end
