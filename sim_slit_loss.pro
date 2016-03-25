pro sim_slit_loss,showbox=showbox,psplot=psplot,$
                  relative=relative,moffat=moffat,$
                  fixbox=fixbox,gauss=gauss
;; Although the PSF is likely different (and larger) in the optical than
;; IR, I'll simulate the slit loss with box photometry
;; This takes the MORIS data and calculates the expected slit loss for
;; a 3x60 arcsec slit by extracting a box around the source and then a
;; really wide one to see what kind of slit loss we'd expect
;; for the SpeX spectrograph with its wide slit.
;; OPTIONS
;; showbox - show the box on each fits image
;; showback - show background region used
;; moffat - fits stars with moffat profile to get slit loss without
;;           other sources or detector complications
;; fixbox - fixes the box center position at the median (X,Y) coordinate
;; gauss - does Gaussian profiles

restore,'ev_phot_data.sav'


;; Dimensions in arcseconds
slitdimX = 15E
slitdimY = 3E

;; Dimensions in arcseconds of wider simulated slit
widedimX = 15E
widedimY = 15E

;; Source avoidance radius in arc-seconds
avoidRadius = 6E


restore,'ev_local_display_params.sav'
;; Get the display parameters

if keyword_set(moffat) then begin
   if keyword_set(gaussian) then begin
      ev_add_tag,plotp,'MOFFAT',0
   endif else begin
      ev_add_tag,plotp,'MOFFAT',1
   endelse
   bsize = 20E
endif

nbox = n_elements(photdat)

for i=0l,nbox-1l do begin
   head = headfits(photdat[i].filen)
;   a = mod_rdfits(,0,head,plotp=plotp)
;   sz = size(a)
;   fits_display,photdat[i].filen,plotp=plotp

   ps = fxpar(head,'PLATE_SC')
   dateobs = fxpar(head,'DATE_OBS')

   if file_exists('es_box_stats.sav') then begin
      file_move,'es_box_stats.sav','es_box_stats_backup.sav',/overwrite
   endif

   for j=0l,1l do begin
      if j EQ 0 then begin
         boxdimX = slitdimX
         boxdimY = slitdimY
      endif else begin
         boxdimX = widedimX
         boxdimY = widedimY
      endelse
      
      dimXpx = boxdimX / ps
      dimYpx = boxdimY / ps

      if keyword_set(fixbox) then begin
         bxindx = photdat[i].xcen + [-0.5E,0.5E] * dimXpx
         bxindy = median(photdat.ycen) + [-0.5E,0.5E] * dimYpx
      endif else begin
         bxindx = photdat[i].xcen + [-0.5E,0.5E] * dimXpx
         bxindy = photdat[i].ycen + [-0.5E,0.5E] * dimYpx
      endelse
      
      linep = create_struct('type','box','direction','y',$
                            'xcoor',bxindx,'ycoor',bxindy)
      backparams = create_struct('RADIUS',avoidRadius / ps,$
                                 'CEN_X',photdat[i].xcen,$
                                 'CEN_Y',photdat[i].ycen,$
                                'SUBTRACT',1)

      if keyword_set(showbox) and not keyword_set(moffat) then begin
         if keyword_set(showback) then begin
            ev_add_tag,backparams,'SHOWPT',1
            fits_display,photdat[i].filen,plotp=plotp ;,linep=linep
         endif else begin
            fits_display,photdat[i].filen,plotp=plotp,linep=linep
         endelse
      endif
      if keyword_set(psplot) then begin
         imgpath = photdat[i].filen
         save_image,imgpath,plotp=plotp,linep=linep
         stop
      endif

      if keyword_set(moffat) then begin
         if keyword_set(gauss) then begin
            singlephot = photdat[i]
         endif else begin
            custbox = create_struct('XCOOR',photdat[i].xcen + [-bsize,bsize],$
                                    'YCOOR',photdat[i].ycen + [-bsize,bsize])
            fit_psf,photdat[i].filen,linep,plotp=plotp,custbox=custbox,/noplot
            ;; Set up simulated star image
            restore,'ev_phot_moffat.sav'
         endelse
         
         Theta = singlephot.OrigTheta
         xshowfit = singlephot.xcen
         yshowfit = singlephot.ycen
         simszX = fxpar(head,'NAXIS1')
         simszY = fxpar(head,'NAXIS2')
         
         X = FINDGEN(simszX) # REPLICATE(1.0, simszY)
         Y = REPLICATE(1.0, simszX) # FINDGEN(simszY)
         
         xprime = (X - xshowfit)*cos(Theta) - (Y - yshowfit)*sin(Theta)
         yprime = (X - xshowfit)*sin(Theta) + (Y - yshowfit)*cos(Theta)
         Ufit = (xprime/ singlephot.xsig)^2 + (yprime/ singlephot.ysig)^2
         if keyword_set(gauss) then begin
            Zmodel = singlephot.peak * myexp(-Ufit/2)
         endif else begin
            Zmodel = singlephot.peak * $
                     (Ufit + 1E)^(-singlephot.moffat)
         endelse
         ;; Don't add the backgroundsinglephot.backg) so we can
         ;; easily estimate slit loss
         
         if keyword_set(showbox) then begin
            mplotp = create_struct('scale',[xshowfit - 25,xshowfit + 25,$
                                            yshowfit - 25,yshowfit + 25,$
                                            0.0,0.45])
            ;mplotp = create_struct('FULLSCALE',1)
            fits_display,Zmodel,plotp=mplotp,linep=linep
         endif
         writefits,'moffat_model.fits',Zmodel
         box_stats,Zmodel,linep=linep,/silent

      endif else begin
         box_stats,photdat[i].filen,linep=linep,plotp=plotp,/silent,$
                   backparams=backparams
      endelse
      
      if keyword_set(showbox) then stop
      
;   plotboxX = [bxindx[0],bxindx[1],bxindx[1],bxindx[0],bxindx[0]]
;   plotboxY = [bxindy[0],bxindy[0],bxindy[1],bxindy[1],bxindy[0]]
;   plots,plotboxX,plotboxY,color=mycol('yellow'),thick=2
   endfor
   
   restore,'es_box_stats.sav'
   ;; Do a background subtraction for each
   for j=0l,1l do begin
      allflux = statdat[j].total
;      backfluxEst = statdat[j].rmean * statdat[j].len_x  * statdat[j].len_y
;      bsub_flux = allflux - backfluxEst
      bsub_flux = allflux
      if j EQ 0 then begin
         flux_source = bsub_flux
      endif else begin
         flux_wide = bsub_flux
      endelse
   endfor
   
   loss = (flux_wide - flux_source) / flux_source
   if keyword_set(showbox) then begin
      print,"loss = ",loss * 100E,"%",' ',dateobs
   endif
   
   onelossdat = create_struct('XCEN',photdat[i].XCEN,$
                              'YCEN',photdat[i].YCEN,$
                              'FILEN',photdat[i].filen,$
                              'FLUX_WIDE',flux_wide,$
                              'FLUX_SOURCE',flux_source,$
                              'LOSS',loss,'DATE_OBS',dateobs)
   if i EQ 0 then begin
      lossdat = onelossdat
   endif else begin
      lossdat = [lossdat,onelossdat]
   endelse
  
   if i mod floor(nbox/5E) EQ 0 then print,'Done with ',i,' of ',nbox

 ;  statdat[
endfor

uniqlist = uniq(lossdat.date_obs,sort(lossdat.date_obs))
nuniq = n_elements(uniqlist)

for i=0l,nuniq-1l do begin
   thisdate = lossdat[uniqlist[i]].date_obs
   alldmatch = where(thisdate EQ lossdat.date_obs,ndmatch)
   case ndmatch of
      0: message,'Date mysteriously not found.'
      1: begin
         message,'Warning, only one loss value for '+thisdate,/cont
         medianloss = lossdat[alldmatch].loss
      end
      else: begin
         medianloss = median(lossdat[alldmatch].loss)
      end
   endcase

   print,thisdate,' ',medianloss * 100E,'%'

endfor


save,lossdat,filename='lossdat.sav'

end
