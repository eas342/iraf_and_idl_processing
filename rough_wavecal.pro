pro rough_wavecal,dat,oArr
;; Does a rough wavelength calibration from the approximate endpoints
;; fo the array
np = n_elements(dat)
wav = fltarr(np)

;; Get the endpoints 

endPS = struct_arrays(ev_delim_read(reduction_dir()+$
                                    '/data/rough_wavecal.csv',delim=','))

for i=0l,oArr.nord -1l do begin
   iOrd = where(dat.ord EQ oArr.orderL[i])
   iEndS = where(endPS.order EQ oArr.orderL[i])
   wav[iOrd] = dat[iOrd].xp * $
               (endPS[iEndS].rightWav - endPS[iendS].leftWav)/(oArr.xsize)+$
               endPS[iendS].leftWav
end
ev_add_tag,dat,'WAV',wav

end
