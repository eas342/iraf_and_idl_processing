pro genhist,dat,gparam=gparam
;; General histogram plotter
;; takes a structure and plots the normalized histograms

dataInd = key_indices(dat,gparam)
tags = tag_names(dat)
if ev_tag_true(gparam,'NHISTBIN') then begin
   nbin = gparam.nhistbin
endif else nbin=20

serTag = dataInd[2]

serArr = prep_series(dat,gparam,serTag,rlist)
nser = n_elements(serArr)

for i=0,nser-1l do begin
   serInd = where(rlist EQ serArr[i])
   xdat = dat[serInd].(dataInd[0])
   if i EQ 0 then begin
      yhist = histogram(xdat,nbin=nbin,locations=xhist,/nan)
      ynorm = float(yhist)/float(max(yhist))
      histdat = struct_arrays(create_struct('xhist',xhist,$
                                            'yhist',ynorm))
   endif else begin
      yhist = histogram(xdat,nbin=nbin,min=min(xhist),/nan)
      ynorm = float(yhist)/float(max(yhist))
      ev_oplot,histdat,xhist,ynorm,gparam=histparam
   endelse
;   histDat = create_struct(tags[dataInd[0]],)
endfor

if ev_tag_exist(gparam,'SLABEL') then begin
   ev_add_tag,histparam,'SLABEL',gparam.slabel
endif

genplot,histdat,gparam=histparam

end
