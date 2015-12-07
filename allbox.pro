pro allbox,fileL,lineP=lineP,plotp=plotp
;; Goes through all files and finds the box statistics

if file_exists('box_stats.sav') then file_delete,'box_stats.sav'
nfile = n_elements(fileL)
for i=0l,nfile-1l do begin
   es_box_stats,fileL[i],lineP=lineP,plotp=plotp
end

restore,'box_stats.sav'
write_csv,'box_stats.csv',statdat,header=tag_names(statdat)

end
