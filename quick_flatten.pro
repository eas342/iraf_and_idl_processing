pro quick_flatten

  readcol,'ratio_list.txt',infile,format='(A)'
  readcol,'ratio_proclist.txt',outfile,format='(A)'

  flat = mrdfits('ratio_median.fits',0,flathead)

  for i=0l,n_elements(infile)-1l do begin
     a1 = mrdfits(infile[i],0,head)
     a2 = a1/flat
     writefits,outfile[i],a2,head
  endfor

end
