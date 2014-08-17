function do_divide,img,origheader
;; This function divides an image by the number of non-destructive
;; reads (but not coadds since those have effectively a larger number
;; of photons). It also calculates the effective exposure time and
;; adjusts for correlated and uncorrelated signal referring to Garnett
;; & Forrest 1993
  
  
  NDR1 =  float(fxpar(origHeader,"NDR") )
  divisor = NDR1
  ;; the prefactor of ~1.5 is due to the read time improvement for
  ;; eta=1 Fowler sampling (Garnett and Forrest 1993)
  
  rtime1 = float(fxpar(origHeader,"TABLE_MS",count=count))/1000E   ;; read time, sec
  if count EQ 0 then rtime1 = float(fxpar(origHeader,"TABLE_SE"))  ;; newer array uses seconds keyword
  Teff1 = float(fxpar(origHeader,"ITIME"))           ;; integration time, sec
  eta = (NDR1 * 2E * rtime1)/(Teff1 + NDR1 * rtime1)
  nmax = (Teff1 + NDR1 * rtime1)/(2E * rtime1)
  prefactor = (1E - eta/2E) /$
              (1E - 2E * eta/3E + 1E/(6E * eta * nmax^2))
  
  outimg = img * prefactor / divisor
  return,outimg
end
