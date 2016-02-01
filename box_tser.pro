pro box_tser,filen
;; Takes the statistics on the box total and makes a time series
;; filen - optional filename keyword

if n_elements(filen) EQ 0 then begin
   ;; Look for default file name
   filen = 'box_stats.sav'
endif

if file_exists(filen) then begin
   restore,filen
end else begin
   message,filen+' box statisics file found.',/cont
   return
endelse

npix = float(median(statdat.LEN_X)) * float(median(statdat.LEN_Y))

normFactor = float(median(statdat.total))
normFlux = statdat.total / normFactor
Gain = 1E ;;; for now, what is it really?
RN = 21E ;; for now from NIRCam pocket guide, what is it really?


ev_add_tag,statdat,'NORM_FLUX',normFlux

print,'Standard Dev= ',stddev(normFlux,/nan) * 1E6,' ppm'

;; Calculalte the expected SNR from gain, RN, Poisson, etc.
signalEst = Gain * normFactor
noiseEst = sqrt(Gain * normFactor + npix * RN^2)
errEst = noiseEst / signalEst
print,'Err from Flux= ',ErrEst * 1E6,' ppm'

;; Calculate the expectd SNR using the spatial stdev as a guide
spatialSt = float(median(statdat.RSTDEV)) ;; use robust-sigma
spatialN = sqrt(npix) * spatialSt
spatialS = normFactor
spatialErr = spatialN / spatialS

print,'Err from spatial Stdev= ',spatialErr * 1E6,' ppm'

gparam = create_struct('PKEYS',['AINDEX','NORM_FLUX'],$
                      'TITLES',['Image #','Normalized Flux',''],$
                      'FILENAME','box_time_ser')

adjust_pwindow,type='Plot Window'
genplot,statdat,gparam=gparam
adjust_pwindow,type='FITS Window'

end
