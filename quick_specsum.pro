pro quick_specsum,filen,ap,pos,hydr=hydr
;; Quickly extracts a spectrum for a given aperature size and position
;; hydr - show the hydrogen lines

if n_elements(ap) EQ 0 then ap=4E
if n_elements(pos) EQ 0 then pos=0E

restore,reduction_dir()+'/data/ts4_order_coeff.sav'

plotp = create_struct('ROT',1)
yp = spec_sum(filen,ap,pos,plotp=plotp,/showap)

np = n_elements(yp)
xshow = findgen(oArr.nord * oArr.xsize)
;ev_add_tag,yp,'xshow',xshow
rough_wavecal,yp,oArr

gparam = create_struct('PKEYS',['WAV','SUM'],$
                       'TITLES',['Wavelength (um)','Sum Flux',''],$
                       'SERIES','ORD');,'SLABEL','Order')


if keyword_set(hydr) then begin
   ryd = 13.6056925E ;; rydb
   hc = 1.23984193E ;; ev um
   nbot = 4E
   nhyd = 15
   ntop = 5E + findgen(nhyd)
   hwav = hc / (ryd * (1E/nbot^2 - 1E/ntop^2))
   showp = create_struct('VERTLINES',hwav,'VERTSTYLES',fltarr(nhyd)+1)
   print,'Adding hydrogen ...'
endif

genplot,yp,showp,gparam=gparam,/noinit

end
