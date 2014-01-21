pro find_shift_values,discreet=discreet,showfits=showfits,psplot=psplot,$
                      dec23=dec23,custarc=custarc,custshiftFile=custshiftFile,$
                      Arcshift=Arcshift,sincFit=sincFit,saveMasterSpec=saveMasterSpec,$
                      useMasterSpec=useMasterSpec,leaveEdges=leaveEdges
;; Straightens A Spectrum so that the X direction is wavelength
;; discreet - only move by discreet steps
;; showfits -- shows the fits to cross-correlations
;; dec23 -- looks at the Dec 23 data
;; sincFit -- fit the cross correlation to a sinc function (not just a polynomial)
;; saveMasterSpec -- save a master background spectrum so that other spectra are
;;                   shifted to a common reference
;; useMasterSpec -- use the master background spectrum so the current
;;                  one matches the master
;; leaveEdges -- leaved the edges as wrapped edges (otherwise it
;;               replaces with median of the column)

case 1 of 
   n_elements(custarc) NE 0: arcnm=custarc
   keyword_set(dec23): arcnm = '../IRTF_UT2011Dec23/proc/bigdog/masterarc.fits'
   else: arcnm = '../IRTF_UT2012Jan04/proc/bigdog/masterarc.fits'
endcase

img = mrdfits(arcnm,0,origHeader)

;; filter image
fimg = convol(img,digital_filter(0.15,0.3,50,10))

imgSize = size(img)
NX = imgSize[1]
NY = imgSize[2]
shiftArray = fltarr(NY)

;; Identify all bad pixels, which is easier with a filter?
;kernel = replicate(-1E,3,3)
;kernel[1,1] = 8E
;highpas = convol(img,kernel,/center,/edge_truncate)

recimg = fltarr(NX,NY) ;; where the rectified image goes

case 1 of
   keyword_set(saveMasterSpec): begin
      refspec = fimg[*,floor(NY/2)]
      masterSpec = refspec
      save,masterSpec,filename='masterRefSpec.sav'
   end
   keyword_set(useMasterSpec): begin
      restore,'masterRefSpec.sav'
      refspec = masterSpec
   end
   else: refspec = fimg[*,floor(NY/2)]
endcase


;; set the up the PS plot
if keyword_set(psplot) then begin
   set_plot,'ps'
   !p.font=0
   if keyword_set(showfits) then plotprenm = 'cross_cor' else begin
      plotprenm = 'curv_func'
   endelse

   device,encapsulated=1, /helvetica,$
          filename=plotprenm+'.eps'
   device,xsize=14, ysize=10,decomposed=1,/color
endif

;; Remove NaNs (set to 0)
badp = where(finite(fimg) NE 1)
if badp NE [-1] then fimg[badp] = 0 ;; remove NaNs

;lagsize = 30l
lagsize = 30l
lagarray = lindgen(lagsize) - lagsize/2l
;usefulpoints = lindgen(420) ;; ignore the thermal K band emission
usefulpoints = lindgen(200) + 125l ;; ignore the thermal K band emission
for i=0l,NY-1l do begin
   crosscor = c_correlate(refspec[usefulpoints],fimg[usefulpoints,i],lagarray)
   if keyword_set(discreet) then begin
      maxCross = max(crosscor,peakv)
   endif else begin
      fitExpr = 'P[0] * SinC(P[1] * (X -P[2])) + P[3] + P[4] *  EXP(-0.5E * ((X - P[2])/P[5])^2)'
;      fitExpr = 'P[0] * SinC(P[1] * (X -P[2])) * P[4] * EXP(-0.5E * ((X - P[2])/P[5])^2) + P[3]'
;      fitExpr = 'P[0] * SinC(P[1] * (X -P[2])) + P[3] + P[4] * X + P[5] * X^2

      if keyword_set(sincFit) then begin
         startParams = [1,0.3,5,8,0,3]
         result=mpfitexpr(fitExpr,lagarray,crosscor,fltarr(lagsize)+0.1,$
                          startparams,/quiet)
      endif

      ;; Fit a polynomial to the cross correlation
      
      NpolyF = 2
      ;; Look in the viscinity of the peak
      maxCross = max(crosscor,peakInd)
      Peaksize = 6l
      peakmask = lindgen(Peaksize) + peakInd - Peaksize/2l
      PolyTrend = poly_fit(lagarray[peakmask],crosscor[peakmask],NpolyF)
;      if keyword_set(showfits) or i GE 251 then begin
;      if keyword_set(showfits) then begin
      peak = -PolyTrend[1]/(2E * PolyTrend[2])
   endelse

   case 1 of
      keyword_set(discreet): shiftarray[i] = -lagarray[peakv]
      keyword_set(sinc): shiftarray[i] = -result[2]
      else: shiftarray[i] = -peak
   endcase
;stop
   if keyword_set(showfits) and i EQ 5 then begin
      if keyword_set(showfits) then begin
         PolyShow = fltarr(NY)
         for j=0l,NpolyF do begin
            PolyShow = PolyShow + PolyTrend[j] * lagarray^j
         endfor
         plot,lagarray,crosscor,ystyle=16,$
              xtitle='Lag (px)',ytitle='Cross Correlation'
         oplot,lagarray,PolyShow,color=mycol('red')
         ;; show the peak
         oplot,[peak,peak],!y.crange,color=mycol('blue')
;         plot,img[usefulpoints,i]
;         wait,0.1
      endif
      if keyword_set(sincFit) then begin
         oplot,[-shiftarray[i],-shiftarray[i]],!y.crange,color=mycol('red')
         if not keyword_set(discreet) then begin
            ;; Show the fitted peak if using interpolation
            oplot,lagarray,expression_eval(fitExpr,lagarray,result),color=mycol('blue')
;         plot,img[*,i],/noerase,xstyle=4,ystyle=4
         endif
         stop
      endif
   endif

endfor



;; Show the shifts
Pos = findgen(NY) ;; position
;; Fit a polynomial to the shift curve. Iterate 3 times to throw out
;; bad pixels and the 2 sources from affecting the wavelength shifts
nIter = 4
Thresh = 5E
keepPoints = lindgen(NY)
!p.multi = [0,1,2]
for i=0,nIter-1l do begin
   if not keyword_set(showfits) and i EQ nIter-1l then begin
      plot,Pos,shiftarray,xtitle='Row Number',ytitle='Shift Amount',/nodata
   endif
   Npoly = 3
   PolyTrend = poly_fit(pos[keepPoints],shiftarray[keepPoints],Npoly)
   PolyMod = fltarr(NY)
   for j=0l,Npoly do begin
      PolyMod = PolyMod + PolyTrend[j] * Pos^j
   endfor
   resid = PolyMod - shiftArray
   keepPoints = where(abs(resid) LT Thresh * robust_sigma(resid),complement=badPoints)
   if not keyword_set(showfits) and i EQ nIter-1l then begin
      oplot,Pos[keepPoints],shiftArray[keepPoints]
      if badPoints NE [-1] then oplot,Pos[badPoints],shiftArray[badPoints],color=mycol('red'),psym=4,symsize=0.5
      oplot,Pos,PolyMod,color=mycol('green')
      ;; Show the residuals
      plot,pos[keepPoints],shiftArray[keepPoints]-PolyMod[keepPoints],$
           xtitle='Row Number',ytitle='Residual (px)'
   endif
endfor
!p.multi=0




;; Save the spectral shift parameters
if n_elements(custshiftFile) EQ 0 then custshiftFile='data/shift_data/shift_vals_from_arc.txt'
forprint,Pos,PolyMod,comment='#Y Position (row)   Shift (px)',$
         textout=custshiftFile


if keyword_set(psplot) then begin
   device, /close
   cgPS2PDF,plotprenm+'.eps'
   spawn,'convert -density 160% '+plotprenm+'.pdf '+plotprenm+'.png'
   device,decomposed=0
   set_plot,'x'
   !p.font=-1
endif

case 1 of
   n_elements(Arcshift) NE 0: outFitsNm=Arcshift
   keyword_set(dec23): outFitsNm = '../IRTF_UT2011Dec23/proc/bigdog_rectified/masterarc.fits'
   else: outFitsNm = '../IRTF_UT2012Jan04/proc/bigdog_rectified/masterarc_cross_shift.fits'
endcase

;; Make a rectified image
for i=0l,NY-1l do begin
   if keyword_set(discreet) then begin
      recimg[*,i] = shift(img[*,i],-lagarray[peakv]) 
   endif else begin
      recimg[*,i] = shift_interp(img[*,i],Polymod[i])
   endelse
endfor


if not keyword_set(leaveEdges) then begin
   ;; Replace all the edges with the median edge value
   ;; This is needed because the shift procedure wraps the spectra
   ;; around, falsely putting K band data at 0.8um and vice versa
   medianLeft = median(img[0,*])
   medianRight = median(img[NX-1l,*])
   roundedShift = round(Polymod)
   for i=0l,NY-1l do begin
      if Polymod[i] GE 0 then begin
         recimg[0:roundedShift[i],i] = medianLeft
      endif else begin
         recimg[NX-1l+roundedShift[i]:NX-1l,i] = medianRight
      endelse
   endfor
endif

   
writefits,outFitsNm,recimg,origHeader
end
