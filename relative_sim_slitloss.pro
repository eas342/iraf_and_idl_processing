pro relative_sim_slitloss,avg=avg,gauss=gauss
;; Finds the relative slit loss between the target and reference star
;; avg - averages in time
;; gauss - look at the profiles for Gaussian profile fit

  adjust_pwindow,type='Plot Window'
  if keyword_set(gauss) then begin
     restore,'lossdat_gauss.sav'
  endif else begin
     restore,'lossdat.sav'
  endelse
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
;   plot,diffloss
   print,'robust sigma differential loss = ',robust_sigma(diffloss) * 100E,' %'
   ev_add_tag,dlossdat,'count',findgen(n_elements(dlossdat))
   save,dlossdat,filename='dlossdat.sav'

   if keyword_set(avg) then begin
      nbin = 40
      binsizes = max(dlossdat.count)/(nbin) + fltarr(nbin)
      xstart = findgen(nbin) * binsizes
      xmid = xstart + binsizes * 0.5E
      snr = fltarr(n_elements(dlossdat)) + 10E
      goodp = where(abs(dlossdat.diffloss) LT 2E) ;; reject all points missing stars and that give more than 200% slit loss (non-physical)
      yavg = avg_series(dlossdat[goodp].count,dlossdat[goodp].diffloss,snr[goodp],$
                        xstart,binsizes,oreject=3,stdevarr=stdevarr)
      avgstruct = create_struct('INDEX',xmid,'DIFFLOSS',yavg,'ERR',stdevarr)
      astruct = struct_arrays(avgstruct)
      genplot,astruct,gparam=create_struct('YERR','ERR','PKEYS',['INDEX','DIFFLOSS'],$
                                          'YTHRESH',1,'NOMARGLEG',1)
   endif else begin
      genplot,dlossdat,gparam=create_struct('PKEYS',['COUNT','DIFFLOSS'],'YTHRESH',1,$
                                            'PSSMALL',1,'NOMARGLEG',1)
   endelse

end
