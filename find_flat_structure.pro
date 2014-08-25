pro find_flat_structure,showplot=showplot
;; Fits the flat field line by line, subtracts it, shifts this
;; structure and puts it back in
;; showplot - shows the fits

nrowpoly = 1 ;; order of polynomial fitting a row
vertShift = 0
a= mrdfits('response.fits',0,header)

xlength = fxpar(header,'NAXIS1')
ylength = fxpar(header,'NAXIS2')
columNum = findgen(xlength)
;; Make a structure image
struct = fltarr(xlength,ylength)

for i=0l,ylength-1l do begin
   polyParam = ev_robust_poly(columNum,a[*,i],nrowpoly,showplot=showplot)
   struct[*,i] = eval_poly(columNum,polyParam)
endfor

ssubI = a - struct;; stripe subtracted image
shiftstruct = shift(struct,0,vertShift) ;; shift the structure
;; Put it back in
outimage = ssubI + shiftstruct
;outimage = shift(a,0,vertshift) ;; shift the entire flat image



sheader = header
fxaddpar,sheader,'STRIPE_FIT','TRUE','The result of each row fitted to a polynomial'
fxaddpar,sheader,'STRIPE_ORDER',nrowpoly,'Order of the polynomial fit to each row'
writefits,'stripes_image.fits',struct,sheader
pxheader = sheader
fxaddpar,pxheader,'STRIPE_SUBTRACTED','TRUE','Stripe image subtracted from response file'
writefits,'stripe_sub_image.fits',ssubI,pxheader

fxaddpar,sheader,'STRIPE_SHIFTED',vertShift,'The amount that each row was shifted before being added back'
writefits,'full_response.fits',outimage,sheader
end
