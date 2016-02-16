pro clear_phot
  if file_exists('ev_phot_data.sav') then begin
     file_move,'ev_phot_data.sav','ev_phot_data_backupfromRe.sav',/overwrite
  endif
end
