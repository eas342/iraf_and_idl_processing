pro quick_foc,filel,plotp,linep,slot
;; Quickly allows one to focus from a set of 7

clear_phot
fits_display,filel[slot],plotp=plotp,linep=linep
multi_fit_psf,fileL[slot],LineP,plotp=plotp
refit_psf,fileL,LineP,plotp=plotp
plot_focus_curve,/showp

end
