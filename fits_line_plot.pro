pro fits_line_plot,fileL,lineP=lineP,current=current
  ;; This plots a line drawin with fits line draw
if n_elements(lineP) EQ 0 then begin
   print,'No line drawn to plot'
   return
endif

nfile = n_elements(filel)
type = size(filel[0],/type)
if n_elements(current) EQ 0 then i=0l else i = current
firsttime = 1
while (!mouse.button NE 4) do begin
   if type EQ 7 then begin
      a = mrdfits(fileL[i],0,header)
      Ftitle = filel[i]
   endif else begin 
      a=filel[0]
      Ftitle = ''
   endelse
   if LineP.direction EQ 'x' then begin
      xplot = min(Linep.xcoor) + lindgen(abs(LineP.xcoor[1] - LineP.xcoor[0]))
      yplot = a[xplot,LineP.ycoor[0]]
   endif else begin
      xplot = min(Linep.ycoor) + lindgen(abs(LineP.ycoor[1] - Linep.ycoor[0]))
      yplot = a[LineP.xcoor[0],xplot]
   endelse
   plot,xplot,yplot,ystyle=16,$
        title=Ftitle,$
        xtitle=lineP.direction+' coordinate',psym=10

   cursor,xcur,ycur,/normal,/down
   if xcur LT 0.5 then begin
      i = wrap_mod((i - 1l),nfile)
   endif else begin
      i = wrap_mod((i + 1l),nfile)
   endelse

endwhile
!Mouse.button=1

end
