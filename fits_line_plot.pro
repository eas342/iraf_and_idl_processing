pro fits_line_plot,fileL,lineP=lineP,current=current,$
                   median=median,makestop=makestop,$
                   overplot=overplot
;; This plots a line or box depending on input
;; lineP - a structure of line coordinates
;; boxC - a structure of box coordinates
;; median - do a median instead of an average
;; overplot - makes an over-plot

if n_elements(lineP) EQ 0 then begin
   print,'No line drawn to plot'
   return
endif

nfile = n_elements(filel)
type = size(filel[0],/type)
if n_elements(current) EQ 0 then i=0l else i = current
firsttime = 1
counter=0
while (!mouse.button NE 4) do begin
   if type EQ 7 then begin
      a = mod_rdfits(fileL[i],0,header)
      Ftitle = filel[i]
   endif else begin 
      a=filel[0]
      Ftitle = ''
   endelse
   ;; Get the plot abscissa axis
   if LineP.direction EQ 'x' then begin
      xplot = min(Linep.xcoor) + lindgen(abs(LineP.xcoor[1] - LineP.xcoor[0]))
   endif else begin
      xplot = min(Linep.ycoor) + lindgen(abs(LineP.ycoor[1] - Linep.ycoor[0]))
   endelse
   ;; Get the ordinate axis
;   case 1 of 
;      LineP.type EQ 'line': begin
   if keyword_set(median) then begin
      if LineP.direction EQ 'x' then begin
         yplot = median(a[xplot,LineP.ycoor[0]:LineP.ycoor[1]],dimension=2)
      endif else begin
         yplot = median(a[LineP.xcoor[0]:LineP.xcoor[1],xplot],dimension=1)
      endelse
   endif else begin
      if LineP.direction EQ 'x' then begin
         yplot = total(a[xplot,LineP.ycoor[0]:LineP.ycoor[1]],2)
         yplot = yplot / float(LineP.ycoor[1] - LineP.ycoor[0] + 1l) ;; renormalize for avg
      endif else begin
         yplot = total(a[LineP.xcoor[0]:LineP.xcoor[1],xplot],1)
         yplot = yplot / float(LineP.xcoor[1] - LineP.xcoor[0] + 1l) ;; renormalize for avg
      endelse
   endelse

   if counter GT 0 and keyword_set(overplot) then begin
      colorArr = myarraycol(counter+1)
      oplot,xplot,yplot,color=colorArr[counter],psym=10
   endif else begin
      plot,xplot,yplot,ystyle=16,$
           title=Ftitle,$
           xtitle=lineP.direction+' coordinate',psym=10
   endelse
   if keyword_set(makestop) then stop
   cursor,xcur,ycur,/normal,/down
   if xcur LT 0.5 then begin
      i = wrap_mod((i - 1l),nfile)
   endif else begin
      i = wrap_mod((i + 1l),nfile)
   endelse
   counter = counter + 1
endwhile
!Mouse.button=1

end
