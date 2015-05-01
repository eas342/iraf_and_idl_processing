pro multi_fit_psf,filel,linep,plotp=plotp,bsize=bsize
;; Runs the fit_psf script but allows you to quickly click on a bunch
;; of points

print,'Click on points to find PSF fits'

if not ev_tag_exist(plotp,'BSIZE') then begin
   choose_bsize,plotp
endif
bsize = plotp.bsize


;start cursor
xcur = 0.3
ycur = 0.8
cursor,xPos,yPos,/down
while(!mouse.button NE 4) do begin
   custbox = create_struct('Xcoor',xPos + [-bsize,bsize],$
                           'Ycoor',yPos + [-bsize,bsize])
   xlist = custBox.Xcoor[[0,1,1,0,0]]
   ylist = custBox.Ycoor[[0,0,1,1,0]]
   plots,xlist,ylist,color=mycol('green')
   fit_psf,filel,linep,plotp=plotp,custbox=custbox
   cursor,xPos,yPos,/down
endwhile
!MOUSE.button=1

end
