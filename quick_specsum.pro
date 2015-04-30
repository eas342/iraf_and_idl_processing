pro quick_specsum,filen
restore,reduction_dir()+'/data/ts4_order_coeff.sav'

plotp = create_struct('ROT',1)
yp = spec_sum(filen,4,0,plotp=plotp,/showap)

np = n_elements(yp)
xshow = findgen(oArr.nord * oArr.xsize)
;ev_add_tag,yp,'xshow',xshow
rough_wavecal,yp,oArr

gparam = create_struct('PKEYS',['WAV','SUM'],$
                       'TITLES',['Wavelength (um)','Sum Flux',''],$
                       'SERIES','ORD');,'SLABEL','Order')
genplot,yp,gparam=gparam

end
