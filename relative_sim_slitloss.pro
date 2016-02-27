pro relative_sim_slitloss

  adjust_pwindow,type='Plot Window'
  restore,'lossdat.sav'
   uniqfile = uniq(lossdat.filen,sort(lossdat.filen))
   nuniqfile = n_elements(uniqfile)

   diffloss = fltarr(nuniqfile)
   for i=0l,nuniqfile-1l do begin
      thisfile = lossdat[uniqfile[i]].filen
      allfmatch = where(thisfile EQ lossdat.filen,nfmatch)
      case nfmatch of
         0: message,'File mysteriously not found.'
         1: begin
            message,'Warning, only 1 photometry point for this file'
         end
         else: begin
            middleX = mean(lossdat[allfmatch].xcen)
            leftp = where(lossdat[allfmatch].xcen LT middlex,complement=rightp)
            diffloss[i] = lossdat[allfmatch[leftp[0]]].loss - lossdat[allfmatch[rightp[0]]].loss
         end
      endcase
      onedloss = create_struct('XCEN_00',lossdat[allfmatch[leftp[0]]].xcen,$
                               'XCEN_01',lossdat[allfmatch[rightp[0]]].xcen,$
                               'YCEN_00',lossdat[allfmatch[leftp[0]]].ycen,$
                               'YCEN_01',lossdat[allfmatch[rightp[0]]].ycen,$
                               'LOSS_01',lossdat[allfmatch[leftp[0]]].loss,$
                               'LOSS_02',lossdat[allfmatch[rightp[0]]].loss,$
                               'FILEN',lossdat[allfmatch[leftp[0]]].filen,$
                               'DIFFLOSS',diffloss[i])
      if i EQ 0 then begin
         dlossdat = onedloss ;; differential loss structure
      endif else begin
         dlossdat = [dlossdat,onedloss]
      endelse
   endfor
   plot,diffloss
   print,'robust sigma differential loss = ',robust_sigma(diffloss) * 100E,' %'
   ev_add_tag,dlossdat,'count',findgen(n_elements(dlossdat))
   save,dlossdat,filename='dlossdat.sav'

   genplot,dlossdat,gparam=create_struct('PKEYS',['COUNT','DIFFLOSS'],'YTHRESH',1,'PSSMALL',1,'NOMARGLEG',1)

end
