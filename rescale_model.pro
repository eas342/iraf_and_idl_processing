function rescale_model,y,yerr,ymodel,xmodel,xdata,$
                       interpolated=interpolated
;; Rescales a model to match the data
;; if xdata and xmodel are supplied, it interpolate the model to data

if n_elements(xmodel) GT 0 then begin

   ycompar = interpol(ymodel,xmodel,xdata)

endif else ycompar = ymodel

scaleF = total(y * ycompar/yerr^2)/total(ycompar^2/yerr^2)


if n_elements(xmodel) GT 0 then begin
   interpolated = ycompar * scaleF
   return,ymodel * scaleF
endif else begin
   return,scaleF * ycompar
endelse
end
