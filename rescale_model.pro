function rescale_model,y,yerr,ymodel,xmodel,xdata
;; Rescales a model to match the data
;; if xdata and xmodel are supplied, it interpolate the model to data

if n_elements(xmodel) GT 0 then begin

   ycompar = interpol(ymodel,xmodel,xdata)

endif else ycompar = ymodel

scaleF = total(y^2/yerr^2)/total(ycompar * y/yerr^2)

if n_elements(xmodel) GT 0 then begin
   return,scaleF * ymodel
endif else begin
   return,scaleF * ycompar
endelse

end
