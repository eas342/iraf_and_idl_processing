pro adjust_pwindow,type=type

case type of
   'FITS Window': begin
      if not windowavailable(0) then begin
         window,0,title='FITS Window'
      endif
      wset,0
   end
   'Plot Window': begin
      if not windowavailable(1) then begin
         window,1,title='Plot Window'
      endif
      wset,1
   end
   else: message,'Unrecognized winow'
endcase

end
