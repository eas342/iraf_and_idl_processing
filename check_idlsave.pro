pro check_idlsave,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,$
                  filename=filename,varnames=varnames
varlist = ['a','b','c','d','e','f','g','h','i','j','k','l','m',$
           'n','o','p','q','r','s','t']


if n_elements(filename) EQ 0 then begin
   message,'No default File Name',/continue
   return
endif
;; Check if there's a previous file
fs = file_search(filename)
if fs EQ [''] then begin
   outName = filename
   print,'Saving variables/structures as ',outname
endif else outName=dialog_pickfile(/write,filter='*.sav',$
                                       default_extension='.sav')

nvar = n_elements(varnames)
varFlags = fltarr(nvar)
for i=0l,nvar-1l do begin
   junk = execute('varFlags[i] = n_elements('+varlist[i]+') GT 0')
   if varFlags[i] then junk = execute(varnames[i]+' = '+varlist[i])
endfor
goodVars = where(varFlags)
if goodVars EQ [-1] then begin
   message,'No input variables defined',/continue
endif else begin
   statement = 'save,'+strjoin(strtrim(varnames[goodVars]),',')+$
               ',filename="'+outName+'"'
   junk = execute(statement)
endelse

end
