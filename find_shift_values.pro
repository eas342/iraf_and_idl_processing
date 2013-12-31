pro find_shift_values,discreet=discreet,showfits=showfits,psplot=psplot,$
                      dec23=dec23,custarc=custarc,custshiftFile=custshiftFile,$
                      Arcshift=Arcshift,sincFit=sincFit,saveMasterSpec=saveMasterSpec,$
                      useMasterSpec=useMasterSpec
;; Straightens A Spectrum so that the X direction is wavelength
;; discreet - only move by discreet steps
;; showfits -- shows the fits to cross-correlations
;; dec23 -- looks at the Dec 23 data
;; sincFit -- fit the cross correlation to a sinc function (not just a polynomial)
;; saveMasterSpec -- save a master background spectrum so that other spectra are
;;                   shifted to a common reference
;; useMasterSpec -- use the master background spectrum so the current
;;                  one matches the master

case 1 of 
   n_elements(custarc) NE 0: arcnm=custarc
   keyword_set(dec23): arcnm = '../IRTF_UT2011Dec23/proc/bigdog/masterarc.fits'
   else: arcnm = '../IRTF_UT2012Jan04/proc/bigdog/masterarc.fits'
endcase

img = mrdfits(arcnm,0,origHeader)

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
      masterSpec = refspec
      save,masterSpec,'masterRefSpec.sav'
   end
   keyword_set(useMsterSpec): begin
      restore,'masterRefSpec.sav'
      refspec = masterSpec
   end
   else: refspec = img[*,floor(NY/2)]
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
badp = where(finite(img) NE 1)
if badp NE [-1] then img[badp] = 0 ;; remove NaNs

;lagsize = 30l
lagsize = 30l
lagarray = lindgen(lagsize) - lagsize/2l
usefulpoints = lindgen(420) ;; ignore the thermal K band emission
for i=0l,NY-1l do begin
   crosscor = c_correlate(refspec[usefulpoints],img[usefulpoints,i],lagarray)
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
;      goodmask = where(Pos LT 140 OR $
;                       Pos GT 200)
      goodmask = lindgen(lagsize)
      PolyTrend = poly_fit(lagarray[goodmask],crosscor,NpolyF)
;      if keyword_set(showfits) or i GE 251 then begin
;      if keyword_set(showfits) then begin
      peak = -PolyTrend[1]/(2E * PolyTrend[2])
   endelse

   case 1 of
      keyword_set(discreet): shiftarray[i] = -lagarray[peakv]
      keyword_set(sinc): shiftarray[i] = -result[2]
      else: shiftarray[i] = -peak
   endcase

   if keyword_set(showfits) then begin
      plot,lagarray,crosscor,ystyle=16,$
           xtitle='Lag (px)',ytitle='Cross Correlation'
      if keyword_set(showfits) then begin
         PolyShow = fltarr(NY)
         for j=0l,NpolyF do begin
            PolyShow = PolyShow + PolyTrend[j] * lagarray^j
         endfor
         plot,lagarray,crosscor,ystyle=16
         oplot,lagarray,PolyShow,color=mycol('green')
         ;; show the peak
         oplot,[peak,peak],!y.crange,color=mycol('lblue')
;         plot,img[usefulpoints,i]
;         wait,0.3
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
   endif

endfor





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



writefits,outFitsNm,recimg,origHeader
end
