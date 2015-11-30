function clobber_exten,f,exten=exten
;; Takes a directory name and clobbers the extension
;; turns ../dir1/file1.txt into ../dir/file1 so you can re-append
;; use clobber_dir to take away the directory 

st1 = strpos(f,'.',/reverse_search)
length = strlen(f)
s = strmid(f,0,st1)
exten = strmid(f,st1,length-1)

return,s
end
