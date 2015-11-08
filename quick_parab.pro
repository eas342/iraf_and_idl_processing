pro quick_parab,dat,y,gparam=gparam
;; Quickly fits a parabola and finds the min or max

disp_plot,dat,y,gparam=gparam,dat=dat,edat=edat,/preponly
DataInd = key_indices(dat,gparam)

tempst = dat
tempParam = gparam

npmod = 512
xtofit = tempst.(DataInd[0])
ytofit = tempst.(DataInd[1])
         fitpol = ev_robust_poly(xtofit,ytofit,2,nsig=3)
         xmodel = findgen(npmod)/float(npmod-1) * (max(xtofit) - min(xtofit)) + min(xtofit)
         ymodel = poly(xmodel,fitpol)
         
         maxX = -fitpol[1]/(2E * fitpol[2])
         maxY = fitpol[0] - fitpol[1]^2/(4E * fitpol[2])

         edata = create_struct('VERTLINES',maxX)
         ev_oplot,tempst,xmodel,ymodel,gparam=tempParam
         if ev_tag_exist(tempParam,'SLABEL') then begin
            ev_add_tag,tempParam,'SLABEL',[tempParam.slabel,'Parabola']
         endif
         disp_plot,tempst,edata,gparam=tempParam
         print,'Max/min, x =',maxX
         print,'Max/min, y =',maxY
end
