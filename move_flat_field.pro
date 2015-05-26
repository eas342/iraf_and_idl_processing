pro move_flat_field,showplot=showplot,psubreg=psubreg,spline=spline,$
                    twoDir=twoDir
;; Moves the structure in the flat field to best-fit the data's
;; flat field
;; responsefile - the iraf response file that has the flat field, but
;;                with the stripe structure subtracted from it
;; psubreg - show a sub-region of the line plots
;; spline - use spline interpolation
;; twoDir - shift the flat in two directions to account for two
;;          directional flexure

lagsize=15l ;; how far to look at the cross correlation

NpolyF = 2
statusrefresh=30l ;; how many images before showing the filename

;; stripeF - the file of the horizontal stripes in the images that
;;           appear more or less parallel with wavelength
stripeF = 'stripes_image.fits'
responseF = 'stripe_sub_image.fits'
readcol,'science_images_plain.txt',scienceList,format='(A)'

  ;; Get the local parameters
  readcol,'local_red_params.cl',skipline=3,$
          junk,varname,varvalue,format='(A,A,A)',delimiter=' '

  if varname[0] NE 'backbox' then begin
     print,'No backbox found for move_lat_field'
     return
  end else breg = parse_iraf_regions(varvalue[0])
  if keyword_set(twoDir) then begin
     sB = parse_iraf_regions(varvalue[1]) ;; background spectrum
     medSky = mod_rdfits('skycombine_untrim.fits',0,skyMedHead)
     medSubSpec = median(medSky[sB[0]:sB[1],sB[2]:sB[3]],dimension=2)
     fmsubspec = convol(medsubspec,digital_filter(0.15,0.3,50,10))
  endif

  fsizesearch = where(varname EQ 'fitsize')

  ;; Choose how far on either side of the peak to fit
  if fsizesearch NE [-1] then begin
     fitsize = long(varvalue[fsizesearch[0]])
  endif else fitsize=2

  s = mod_rdfits(stripeF,0,sheader,trimReg=strimReg)
  r = mod_rdfits(responseF,0,rheader,trimReg=rtrimReg)
  
  nfile=n_elements(scienceList)

  ;; First remove the pixel-to-pixel response
  subregionPixCor = s[breg[0]:breg[1],breg[2]:breg[3]]/r[breg[0]:breg[1],breg[2]:breg[3]]
  ;; median stripe structure in stripe image
  ssub = median(subregionPixCor,dimension=1)
;  rsub = median(r[breg[0]:breg[1],breg[2]:breg[3]],dimension=1)
  
  lagarray = lindgen(lagsize) - lagsize/2l

  for i=0l,nfile-1l do begin
     c = mod_rdfits(scienceList[i],0,cheader,/silent)
     ;; get the filename 
     splitname = strsplit(sciencelist[i],'.',/extract)
     shortname = splitname[0]

     ;; median spatial structure in science image
     csub = median(c[breg[0]:breg[1],breg[2]:breg[3]],dimension=1)
     crosscor = c_correlate(ssub,csub,lagarray)
     ;; Look in the viscinity of the peak
     maxVal = max(crosscor,topInd)
     lowp = max([0l,topInd - fitsize])
     highp = min([lagsize-1l,topInd + fitsize])
     PolyTrend = poly_fit(lagarray[lowp:highp],crosscor[lowp:highp],NpolyF)
     peak = -PolyTrend[1]/(2E * polyTrend[2])
     vertDir = peak
     if keyword_set(showplot) then begin
        tempdat = struct_arrays(create_struct('LAG',lagarray,'XCOR',crosscor))
        tempfit = create_struct('VERTLINES',peak)
        genplot,tempdat,tempfit
        if quit_caught() then return
     endif

     if keyword_set(twoDir) then begin
        ;; Median spectral structure
        csubSpec = median(c[sB[0]:sB[1],sB[2]:sB[3]],dimension=2)
        fcsubSpec = convol(csubspec,digital_filter(0.15,0.3,50,10))
        crosscor = c_correlate(fmsubspec,fcsubSpec,lagarray)
        maxVal = max(crosscor,topInd)
        lowp = max([0l,topInd - fitsize])
        highp = min([lagsize-1l,topInd + fitsize])
        PolyTrend = poly_fit(lagarray[lowp:highp],crosscor[lowp:highp],NpolyF)
        peak = -PolyTrend[1]/(2E * polyTrend[2])
;        plot,lagarray,crosscor,ystyle=16
;        oplot,[peak,peak],!y.crange,color=mycol('yellow')
        horizDir = peak
     endif else horizDir = 0

     ;; shift the flat field structure
     shiftstruct = s
     shiftstruct= shift_interp(s,[horizDir,vertDir],spline=spline)

     dividedFlat = r * shiftstruct ;; add in the pixel-to-pixel structure
     ;; Trim the flat to the same as the original response
     finalFlat = dividedflat[rtrimReg[0]:rtrimReg[1],rtrimReg[2]:rtrimReg[3]]
     outheader = rheader
     fxaddpar,outheader,'STRIPE_SUBTRACTED','FALSE'
     fxaddpar,outheader,'STRIPE_SHIFTED',peak,$
              'The amount that the stripe structure was shifted in this custom flat field.'
     writefits,'response_for_'+shortname+'.fits',finalFlat,outheader

     if i mod statusrefresh EQ 0 then print,'Completed Custom flat for ',shortname
     if keyword_set(showplot) then begin
        ;; show comparison of flat and science data
        if n_elements(psubreg) EQ 0 then subRange = lindgen(n_elements(csub)) else begin
           ;; subregion to zoom in on in plots
           subRange = psubreg[0] + lindgen(psubreg[1] - psubreg[0])
        endelse
        plot,csub[subrange]/median(csub[subrange]),psym=10,ystyle=16,title=shortname
        oplot,ssub[subrange]/median(ssub[subrange]),color=mycol('yellow'),psym=10
        al_legend,['Science','Stripe Image'],$
                  color=[!p.color,mycol('yellow')],/bottom,linestyle=[0,0]
        stop
        ;; show cross correlation peak finding
        plot,lagarray,crosscor,title=shortname
        oplot,peak * [1E,1E],!y.crange,color=mycol('lblue')
        oplot,lagarray,eval_poly(lagarray,PolyTrend),color=mycol('yellow')
        stop
        ;; show that a the shift has been performed
        plot,ssub[subrange]/median(ssub[subrange]),psym=10,ystyle=16,title=shortname
        shiftedSub = median(shiftstruct[breg[0]:breg[1],breg[2]:breg[3]],dimension=1)
        oplot,shiftedsub[subrange]/median(shiftedsub[subrange]),psym=10,color=mycol('yellow')
        al_legend,['Original Stripes','Shifted Stripes'],$
                  color=[!p.color,mycol('yellow')],/bottom,linestyle=[0,0]
        stop
        ;; Show the final flat field in comparison to the science
        ;; image
        outsub = median(dividedflat[breg[0]:breg[1],breg[2]:breg[3]],dimension=1)
        plot,csub[subrange]/median(csub[subrange]),psym=10,ystyle=16,title=shortname
        oplot,outsub[subrange]/median(outsub[subrange]),psym=10,color=mycol('yellow')
        al_legend,['Science Image','Custom Final Flat'],$
                  color=[!p.color,mycol('yellow')],/bottom,linestyle=[0,0]
        stop
        flattenedSub = c[breg[0]:breg[1],breg[2]:breg[3]]/dividedflat[breg[0]:breg[1],breg[2]:breg[3]]
;        fits_display,flattenedSub
        showMed = median(flattenedSub,dimension=1)
        plot,showMed[subRange],ystyle=16,psym=10
        al_legend,['Flattened Image']
        stop
     endif
     

  endfor

end
