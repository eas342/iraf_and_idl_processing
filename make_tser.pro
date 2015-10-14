pro make_tser,norm=norm
;; Takes the photometry data, which is separated by star, and merges
;; all the star data for each image together to plot time series &
;; other trends
;; norm - divide each pair of stars & normalized by the median to show
;;        corrected time series

restore,'ev_phot_data.sav'

nphot = n_elements(photdat)
flist = photdat[uniq(photdat.filen)]
nimg = n_elements(flist)
tags = tag_names(photdat)
ntag = n_elements(tags)
nsource = nphot/nimg

oidat = photdat[0] ;; one image data for all sources
for j=0l,ntag-1l do begin
   ev_add_tag,oidat,tags[j],replicate(photdat[0].(j),nsource)
endfor
aidat = replicate(oidat,nimg)

;photP = ['BACKG','PEAK','MAFWHM','MIFWHM','XCEN','YCEN','THETA','RACEN',$
;         'DECCEN']
for i=0l,nimg-1l do begin
   for j=0l,ntag-1l do begin
      aidat[i].(j) = photdat[i * nsource:((i+1l) * nsource - 1l)].(j)
   endfor
endfor

;; Add a counter index
ev_add_tag,aidat,'AINDEX',findgen(nimg)

;; Make an array of structures where each tag has one value (useful
;; for the genplot procedure)
;; it is called otdat
for j=0l,ntag-1l do begin
   for k=0l,nsource-1l do begin
      current = aidat.(j)[k]
      newTagNm = tags[j] + string(k,format='("_",i02)')
      if j EQ 0 and k EQ 0 then begin
         ;; make the structure the first time through
         oidat2 = create_struct(newTagNm,current[0]) ;; another kind of one image array
         otdat = replicate(oidat2,nimg)
         otdat.(0) = current
         addtag = 0b
      endif else begin
         if k EQ 0 then begin
            ;; Always add the first source's info
            addtag = 1b
         endif else begin
            if array_equal(lastArr,current) then begin
               ;; do not add next source if it's the same as
               ;; the first one
               addtag = 0b
            endif else addtag=1b ;; add if different from first
         endelse
      endelse
      if addtag then ev_add_tag,otdat,newTagNm,current
      lastArr = current
   endfor
endfor

FluxTags = ['APFLUX','PEAK']
RatioTags = ['FRATIO','PRATIO']
nFluxTags = n_elements(FluxTags)

if keyword_set(norm) then begin
   ottags= tag_names(otdat)
   ;phottags = where(strmid(ottags,0,5) EQ 'APFLUX')
   for m=0l,nFluxTags-1l do begin
      for i=0l,nsource-1l do begin
         for j=i + 1l,nsource-1l do begin
            
            ;;Find the tags
            toptag = FluxTags[m]+string(i,format='("_",i02)')
            topThere = tag_exist(otdat,toptag,ind=topind)
            bottag = FluxTags[m]+string(j,format='("_",i02)')
            botThere = tag_exist(otdat,bottag,ind=botind)
            ;;Calc ratio and add to array of structures
            ratioF = otdat.(topind) / otdat.(botind)
            normF = ratioF / float(median(ratioF))
            ratioTag = RatioTags[m]+string(i,j,format='("_",i02,"_",i02)')
            ev_add_tag,otdat,ratioTag,normF
         endfor
      endfor
   endfor
endif

save,otdat,filename='ev_phot_data_tser.sav'

end
