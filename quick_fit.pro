pro quick_fit,dat,y,gparam=gparam,gaussian=gaussian,$
              customfunc=customfunc,polyord=polyord
;; Default mode: Quickly fits a parabola and finds the min or max
;; Gaussian mode - fit a Gaussian instead

minp = 4 ;; minimum number of points allowed

disp_plot,dat,y,gparam=gparam,dat=dat,edat=edat,/preponly
DataInd = key_indices(dat,gparam)

fulltempst = dat

;; Trim the data if asked to
if ev_tag_exist(gparam,'FITREGION') then begin
   dopoint = where(fulltempst.(DataInd[0]) GT gparam.fitregion[0] and $
                   fulltempst.(DataInd[0]) LT gparam.fitregion[1])
   if n_elements(dopoint) LT minp then begin
      message,'Fewer than ',minp,' to fit',/cont
      return
   endif
   tempst = dat[dopoint]
endif else tempst=dat

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
         name='Gaussian'
      end
      else: start = [0,0]
   endcase
endif else begin
   name='Polynomial (order '+strtrim(long(polyord),2)+')'
endelse 

fitpol = ev_robust_poly(xtofit,ytofit,polyord,nsig=3,customfunc=customfunc,start=start)
xmodel = findgen(npmod)/float(npmod-1) * (max(xtofit) - min(xtofit)) + min(xtofit)
if n_elements(customfunc) EQ 0 then begin
   ymodel = poly(xmodel,fitpol)
   case polyord of
      1: begin
         print,'Intercept = ',fitpol[0]
         print,'Slope = ',fitpol[1]
      end
      2: begin
         maxX = -fitpol[1]/(2E * fitpol[2])
         maxY = fitpol[0] - fitpol[1]^2/(4E * fitpol[2])
         edata = create_struct('VERTLINES',maxX)
         print,'Max/min, x =',maxX
         print,'Max/min, y =',maxY
      end
      else: print,fitpol
   endcase
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
ev_oplot,fulltempst,xmodel,ymodel,gparam=tempParam
if ev_tag_exist(tempParam,'SLABEL') then begin
   ev_add_tag,tempParam,'SLABEL',[tempParam.slabel,name]
endif else begin
   ev_add_tag,tempParam,'SLABEL',['Data',name]
endelse

disp_plot,fulltempst,edata,gparam=tempParam

end
