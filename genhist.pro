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
medShow = fltarr(nser)

for i=0,nser-1l do begin
   serInd = where(rlist EQ serArr[i])
   xdat = dat[serInd].(dataInd[0])
   goodp = where(finite(xdat))
   if goodp EQ [-1] then begin
      message,'No valid points in this series'
   endif
   if i EQ 0 then begin
      yhist = histogram(xdat,nbin=nbin,locations=xhist,/nan)
      ynorm = float(yhist)/float(max(yhist))
      histdat = struct_arrays(create_struct('xhist',xhist,$
                                            'yhist',ynorm))
      pop1 = xdat[goodp]
   endif else begin
      yhist = histogram(xdat,nbin=nbin,min=min(xhist),max=max(xhist),/nan)
      ynorm = float(yhist)/float(max(yhist))
      ev_oplot,histdat,xhist,ynorm,gparam=histparam
      if i EQ 1 then pop2 = xdat[goodp]
   endelse
;   histDat = create_struct(tags[dataInd[0]],)
   medShow[i] = median(xdat)
endfor
if nser GE 2 then begin
   kstwo,pop1,pop2,d,prob
   print,'KS Prob= ',prob
endif

edat = create_struct('VERTLINES',medShow,'VERTSTYLES',fltarr(nser)+1)
if ev_tag_exist(gparam,'SLABEL') then begin
   ev_add_tag,histparam,'SLABEL',gparam.slabel
endif
ev_add_tag,histparam,'TITLES',[tags[dataInd[0]],'Frequency','']

;genplot,histdat,edat,gparam=histparam
disp_plot,histdat,edat,gparam=histparam

end
