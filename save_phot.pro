pro save_phot,tser=tser
;; Read in the IDL structure and save as a CSV file

    if keyword_set(tser) then begin
        infile = 'ev_phot_data_tser.sav'
        outfile = 'ev_phot_data_tser.csv'
        dostruct = 'otdat'
    endif else begin
        infile = 'ev_phot_data.sav'
        outfile = 'ev_phot_data.csv'
        dostruct = 'photdat'
    endelse
    prevFile = file_search(infile)
    if prevFile NE '' then begin
       restore,infile
    endif
    
    junk = execute('outstruct = '+dostruct)
    write_csv,outfile,outstruct,header=tag_names(outstruct)

end
