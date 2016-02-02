pro allbox,fileL,lineP=lineP,plotp=plotp
;; Goes through all files and finds the box statistics


  boxFile = 'es_box_stats.sav'
if file_exists(boxFile) then file_delete,boxFile
nfile = n_elements(fileL)
for i=0l,nfile-1l do begin
   box_stats,fileL[i],lineP=lineP,plotp=plotp
end

restore,boxFile
write_csv,'es_box_stats.csv',statdat,header=tag_names(statdat)

end
