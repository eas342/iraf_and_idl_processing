pro multi_image_viewer
;; Displays multiple fits files and lets you go between them

actions = ['(q)uit','(r)ead new file','set (s)cale',$
           '(t)oggle image mode','(d)raw a line',$
           '(p)lot a line',$
          '(b)ox draw mode','(c)lear previous seetings']
naction = n_elements(actions)

;; Load in previous preferences, if it finds the right file
cd,current=currentD
FindPref = file_search(currentD+'/ev_local_display_params.sav')
if findPref NE '' then begin
   restore,currentD+'/ev_local_display_params.sav'
   if n_elements(filel) NE 0 then status='nothing' else status = 'r'
endif else status = 'r'

while status NE 'q' and status NE 'Q' do begin
   nfile = n_elements(fileL)
   skipaction = 0
   if n_elements(slot) EQ 0 then slot = nfile-1l
   case 1 of
      status EQ 'r' OR status EQ 'R': begin
         print,'Choose a FITS file'
         filen = choose_file(filetype='fits')
         fits_display,filen,usescale=currentScale
         if n_elements(fileL) EQ 0 then begin
            fileL = filen
         endif else fileL = [fileL,filen]
         slot = n_elements(fileL)-1l
      end
      status EQ 's' OR status EQ 'S': begin
         fits_display,filel[slot],/findscale,outscale=CurrentS
      end
      status EQ 't' OR status EQ 'T': begin
         slot = toggle_fits(fileL,usescale=currentS)
      end
      status EQ 'c' OR status EQ 'C': begin
         undefine,fileL
         undefine,currentS
         undefine,slot
         status = 'r'
         skipaction=1
      end
      status EQ 'p' OR status EQ 'P': begin
         fits_line_plot,fileL,lineP=lineP,current=slot
      end
      status EQ 'd' OR status EQ 'D': begin
         lineP = fits_line_draw(fileL[slot],useScale=currentS)
      end
      status EQ 'nothing': begin
      end
      else: print,'Unrecognized Action'
   endcase
   
   print,'Choose an action'
   for i=0l,naction-1l do begin
      print,actions[i]+' ',format='(A,$)'
   endfor
   print,''
   if not skipaction then read,'Action: ',status
;   status = get_kbrd()

endwhile
save,currentS,fileL,slot,lineP,$
     filename='ev_local_display_params.sav'


end
