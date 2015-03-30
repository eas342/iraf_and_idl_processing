pro refit_psf,filel,linep,plotp=plotp,bsize=bsize
;; Runs the fit_psf script over all previous photometry points
;; bsize - contains the box size

restore,'ev_phot_data.sav'
spawn,'mv ev_phot_data.sav ev_phot_data_backupfromRe.sav'
npt = n_elements(photdat)
nfile = n_elements(filel)

for j=0l,nfile-1l do begin
   for i=0l,npt-1l do begin
      custbox = create_struct('Xcoor',photdat[i].XCEN + [-bsize,bsize],$
                              'Ycoor',photdat[i].YCEN + [-bsize,bsize])
      xlist = custBox.Xcoor[[0,1,1,0,0]]
      ylist = custBox.Ycoor[[0,0,1,1,0]]
      plots,xlist,ylist,color=mycol('green')
      fit_psf,filel[j],linep,plotp=plotp,custbox=custbox
   endfor
endfor

end
