pro save_phot
;; Read in the IDL structure and save as a CSV file

  prevFile = file_search('ev_phot_data.sav')
  if prevFile NE '' then begin
     restore,'ev_phot_data.sav'
  endif

 write_csv,'ev_phot_data.csv',photdat,header=tag_names(photdat)

end
