pro get_phot_params,aperRad,skyArr
   ;; Find the aperture photometry
   if not file_exists('phot_params.txt') then begin
      aperRad = [10]
      skyArr = [16,22]
   endif else begin
      openr,1,'phot_params.txt'
      oneline = ''
      readf,1,oneline ;; comments
      readf,1,oneline ;; comments
      readf,1,oneline ;; aperture line
      aperRad = float(strsplit(oneline,',',/extract))
      readf,1,oneline ;; comments
      readf,1,oneline ;; Sky radii line
      skyArr = float(strsplit(oneline,',',/extract))
      close,1
      
   endelse

end
