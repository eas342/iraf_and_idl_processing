pro refit_psf,filel,linep,plotp=plotp,bsize=bsize,redo=redo
;; Runs the fit_psf script over all previous photometry points
;; bsize - contains the box size

if ev_tag_exist(plotp,'BSIZE') then begin
   bsize = plotp.bsize
endif else begin
   choose_bsize,plotp
endelse

fn = 'ev_phot_data.sav'
if file_exists(fn) then restore,fn else begin
   print,'no previous phot file found'
   return
endelse
clear_phot

npt = n_elements(photdat)
nfile = n_elements(filel)

for j=0l,nfile-1l do begin
   if keyword_set(redo) then begin
      startp = j
      endp = j
   endif else begin
      startp = 0l
      endp = npt-1l
   endelse
   for i=startp,endp do begin
      fits_display,filel[j],plotp=plotp,linep=linep
      custbox = create_struct('Xcoor',photdat[i].XCEN + [-bsize,bsize],$
                              'Ycoor',photdat[i].YCEN + [-bsize,bsize])
      xlist = custBox.Xcoor[[0,1,1,0,0]]
      ylist = custBox.Ycoor[[0,0,1,1,0]]
      plots,xlist,ylist,color=mycol('green')
      fit_psf,filel[j],linep,plotp=plotp,custbox=custbox
   endfor
endfor

end
