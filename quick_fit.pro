pro quick_fit,dat,y,gparam=gparam,gaussian=gaussian,$
              customfunc=customfunc
;; Default mode: Quickly fits a parabola and finds the min or max
;; Gaussian mode - fit a Gaussian instead

disp_plot,dat,y,gparam=gparam,dat=dat,edat=edat,/preponly
DataInd = key_indices(dat,gparam)

tempst = dat
tempParam = gparam

npmod = 512
if n_elements(polyord) EQ 0 then polyord=2

xtofit = tempst.(DataInd[0])
ytofit = tempst.(DataInd[1])

if n_elements(customfunc) NE 0 then begin
   case customfunc of
      'Gaussian(X,P)': begin
         start = fltarr(4)
         thresh = threshold(ytofit)
         start[0] = thresh[1]
         start[1] = median(xtofit)
         start[2] = (max(xtofit) - min(xtofit)) / 4E
         start[3] = thresh[0]
      end
      else: start = [0,0]
   endcase
endif

fitpol = ev_robust_poly(xtofit,ytofit,polyord,nsig=3,customfunc=customfunc,start=start)
xmodel = findgen(npmod)/float(npmod-1) * (max(xtofit) - min(xtofit)) + min(xtofit)
if n_elements(customfunc) EQ 0 then begin
   ymodel = poly(xmodel,fitpol)
   if polyord EQ 2 then begin
      maxX = -fitpol[1]/(2E * fitpol[2])
      maxY = fitpol[0] - fitpol[1]^2/(4E * fitpol[2])
      edata = create_struct('VERTLINES',maxX)
      print,'Max/min, x =',maxX
      print,'Max/min, y =',maxY
   endif
endif else begin
   ymodel = expression_eval(customfunc,xmodel,fitpol)
   case customfunc of
      'Gaussian(X,P)': begin
         print,'Max/min x = ',fitpol[1]
         print,'Max/min y = ',fitpol[0]
         print,'Sigma = ',fitpol[2]
         print,'Baseline = ',fitpol[3]
         edata = create_struct('VERTLINES',fitpol[1])
      end
      else: print,fitpol
   endcase

endelse
ev_oplot,tempst,xmodel,ymodel,gparam=tempParam
if ev_tag_exist(tempParam,'SLABEL') then begin
   ev_add_tag,tempParam,'SLABEL',[tempParam.slabel,'Parabola']
endif
disp_plot,tempst,edata,gparam=tempParam

end
