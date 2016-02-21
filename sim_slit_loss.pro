pro sim_slit_loss,showbox=showbox,psplot=psplot
;; Although the PSF is likely different (and larger) in the IR than
;; optical, I'll simulate the slit loss with box photometry
;; This takes the MORIS data and calculates the expected slit loss for
;; a 3x60 arcsec slit by extracting a box around the source and then a
;; really wide one to see what kind of slit loss we'd expect
;; for the SpeX spectrograph with its wide slit.
;; OPTIONS
;; showbox - show the box on each fits image
;; showback - show background region used

restore,'ev_phot_data.sav'


;; Dimensions in arcseconds
slitdimX = 15E
slitdimY = 3E

;; Dimensions in arcseconds of wider simulated slit
widedimX = 15E
widedimY = 10E

;; Source avoidance radius in arc-seconds
avoidRadius = 6E


restore,'ev_local_display_params.sav'
;; Get the display parameters


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

      bxindx = photdat[i].xcen + [-0.5E,0.5E] * dimXpx
      bxindy = photdat[i].ycen + [-0.5E,0.5E] * dimYpx
      
      linep = create_struct('type','box','direction','y',$
                            'xcoor',bxindx,'ycoor',bxindy)
      backparams = create_struct('RADIUS',avoidRadius / ps,$
                                 'CEN_X',photdat[i].xcen,$
                                 'CEN_Y',photdat[i].ycen,$
                                'SUBTRACT',1)

      if keyword_set(showbox) then begin
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

      box_stats,photdat[i].filen,linep=linep,plotp=plotp,/silent,$
                backparams=backparams
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
   onelossdat = create_struct('FILEN',photdat[i].filen,$
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
      else: medianloss = median(lossdat[alldmatch].loss)
   endcase

   print,thisdate,' ',medianloss * 100E,'%'

endfor

save,lossdat,filename='lossdat.sav'

end
