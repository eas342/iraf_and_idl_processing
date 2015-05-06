pro plot_focus_curve,showp=showp
;; showp - show parabola plots at each star position?

;; read the photometry
   restore,'ev_phot_data.sav'

offset = 14000E ;; focus offset to get smaller numbers

ngroup = 8
sizeX = 900l
sizeY = 900l

ev_add_tag,photdat,'FTELFOCUS',float(photdat.telfocus)

minFWHM = 1 ;; don't include points smaller than this
maxFWHM = 15 ;; don't include points bigger than this

;; Prepare the bin sizes, starts and ends
binSz = float([sizeX,sizeY])/float(ngroup) ;; bin sizes (x,y)

binsta = rebin(findgen(ngroup),ngroup,2) $
        * rebin(transpose(binSz),ngroup,2)
binend = rebin(findgen(ngroup)+1E,ngroup,2) $
        * rebin(transpose(binSz),ngroup,2)
binMid = (binsta + binend)/2E

;; Number of points per model
npmod = 512

gparam = create_struct('PKEYS',['FTELFOCUS','MAFWHM'],'PSYM',[8,0],$
                       'XTHRESH',1,'YTHRESH',1,$
                       'TITLES',['Focus - '+strtrim(offset,1)+' um','FWHM',''],$
                       'NOMARGLEG',1,'SLABEL',['Data','Parabola'])


for i=0l,ngroup-1l do begin
   for j=0l,ngroup-1l do begin
      
      binp = where(photdat.xcen GT binsta[i,0] and $
                   photdat.xcen LE binend[i,0] and $
                   photdat.ycen GT binsta[j,1] and $
                   photdat.ycen LE binend[j,1] and $
                   photdat.MAFWHM GT minFWHM and $
                   photdat.MAFWHM LT maxFWHM)

      if n_elements(binp) GT 3 then begin

         tempst = photdat[binp]
         xshow = tempst.ftelfocus
         fitpol = ev_robust_poly(xshow,tempst.MAFWHM,2,nsig=3)
         xmodel = findgen(npmod)/float(npmod-1) * (max(xshow) - min(xshow)) + min(xshow)
         ymodel = poly(xmodel,fitpol)

         ev_oplot,tempst,xmodel,ymodel,gparam=gparam
         

         outdat = create_struct('xbin',binmid[i,0],'ybin',binmid[j,1],$
                                'bestfoc',-fitpol[1]/(2E * fitpol[2]),$
                                'bestFWHM',fitpol[0] - fitpol[1]^2/(4E * fitpol[2]))
         if n_elements(outstruct) EQ 0 then begin
            outstruct = outdat
         endif else begin
            outstruct = [outstruct,outdat]
         endelse
         
         print,'Best FWHM= ',outdat.bestFWHM
         print,'Best Focus= ',outdat.bestfoc
         ftext = ['Best Focus = '+strtrim(outdat.bestfoc,1),$
                 'Best FWHM = '+strtrim(outdat.bestFWHM,1)]
         edat = create_struct('TEXT',ftext,'XYTEXT',$
                              [[0.5,0.9],[0.5,0.8]])

         if keyword_set(showp) then begin
            genplot,tempst,edat,gparam=gparam
            if quit_caught() then return
         endif

      endif
   endfor
endfor

save,outstruct,offset,filename='focus_curves.sav'

end
