pro multi_image_viewer
;; Displays multiple fits files and lets you go between them

actions = ['(q)uit','(r)ead new file',$
           '(rf) read a file with filter',$
           '(rfa) read a set of files with a filter',$
           '(o)pen new file w/ browser','set (s)cale',$
           '(h)elp prints the commands',$
           '(t)oggle image mode','(d)raw a line',$
           '(p)lot a line or box','(pm) to plot median',$
           '(op) overplot line or box mode',$
           '(opd) overplot and divide by median',$
           '(ps) to plot and stop',$
          '(b)ox draw mode','(c)lear previous settings',$
           '(cf) to clear file list',$
           '(fedit) to export filelist to a text file for editing',$
           '(fread) to read filelist that was made by fedit',$
          '(l)oad another parameter file.',$
          '(z)oom in','(save) EPS of FITS image',$
          '(asave) to save all images in file list',$
          '(ckey) to choose a FITS keyword to print']
naction = n_elements(actions)

;; Load in previous preferences, if it finds the right file
cd,current=currentD
FindPref = file_search(currentD+'/ev_local_display_params.sav')
if findPref NE '' then begin
   restore,currentD+'/ev_local_display_params.sav'
   if n_elements(filel) NE 0 then status='nothing' else status = 'r'
endif else status = 'o'

while status NE 'q' and status NE 'Q' do begin
   nfile = n_elements(fileL)
   skipaction = 0
   if n_elements(slot) EQ 0 then slot = nfile-1l
   case 1 of
      status EQ 'r' OR status EQ 'R' OR $
         status EQ 'o' OR status EQ 'O' OR $
         status EQ 'rf' OR status EQ 'RF': begin
         case 1 of
            status EQ 'r' OR status EQ 'R': begin
               print,'Choose a FITS file'
               filen = choose_file(filetype='fits')
            end
            status EQ 'rf' OR status EQ 'RF': begin
               print,'Choose file filter'
               filter=''
               read,filter
               filen = choose_file(filetype=filter)
            end
            else: filen = dialog_pickfile(/read,filter='*.fits')
         endcase
         fits_display,filen,usescale=currentS,lineP=lineP,zoombox=zoombox
         if n_elements(fileL) EQ 0 then begin
            fileL = filen
         endif else fileL = [fileL,filen]
         slot = n_elements(fileL)-1l
      end
      status EQ 'rfa' OR status EQ 'RFA': begin
         prevFileL = fileL
         print,'Choose file filter'
         filter=''
         read,filter
         fileL = choose_file(filter=filter,/all)
         if fileL EQ [''] then fileL = prevFileL else begin
            slot = n_elements(fileL)-1l
            fits_display,filel[slot],usescale=currentS,lineP=lineP,zoombox=zoombox
         endelse
      end
      status EQ 's' OR status EQ 'S': begin
         fits_display,filel[slot],/findscale,outscale=CurrentS,lineP=lineP,zoombox=zoombox
      end
      status EQ 'fedit' OR status EQ 'FEDIT': begin
         forprint,filel,textout='ev_local_display_filelist.txt',/silent,$
                  /nocomment
         spawn,'open ev_local_display_filelist.txt'
      end
      status EQ 'fread' OR status EQ 'FREAD': begin
         readcol,'ev_local_display_filelist.txt',filel,format='(A)'
         if slot GT n_elements(filel) -1l then slot=0
      end
      status EQ 't' OR status EQ 'T': begin
         slot = toggle_fits(fileL,usescale=currentS,lineP=lineP,zoombox=zoombox,startslot=slot,$
                           keyDisp=keyDisp)
      end
      status EQ 'save' OR status EQ 'SAVE': begin
         save_image,fileL,usescale=currentS,lineP=lineP,zoombox=zoombox,startslot=slot
      end
      status EQ 'asave' OR status EQ 'ASAVE': begin
         for i=0l,n_elements(fileL)-1l do begin
            save_image,fileL,usescale=currentS,lineP=lineP,$
                       zoombox=zoombox,startslot=i
         endfor
      end
      status EQ 'c' OR status EQ 'C': begin
         confirm=''
         print,'Are you sure you want to delete all settings?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,currentS
            undefine,slot
            undefine,lineP
            undefine,zoombox
            status = 'o'
            skipaction=1
         endif
      end
      status EQ 'cf' OR status EQ 'CF': begin
         confirm=''
         print,'Are you sure you want to clear all file lists?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,slot
            status = 'o'
            skipaction=1
         endif
      end
      status EQ 'p' OR status EQ 'P': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot)
      end
      status EQ 'op' OR status EQ 'OP': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot)
      end
      status EQ 'opd' OR status EQ 'OPD': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,/normalize)
      end
      status EQ 'pm' OR status EQ 'PM': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/median)
      end
      status EQ 'ps' OR status EQ 'PS': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/makestop)
      end
      status EQ 'd' OR status EQ 'D': begin
         lineP = fits_line_draw(fileL[slot],useScale=currentS,zoombox=zoombox)
      end
      status EQ 'b' OR status EQ 'B': begin
         lineP = find_click_box(filel[slot],usescale=currentS,$
                               /get_direction,zoombox=zoombox)
      end
      status EQ 'bp' OR status EQ 'Bp': begin
         slot = fits_line_plot(fileL,boxP=boxC,current=slot)
      end
      status EQ 'l' OR status EQ 'L': begin
         print,'Choose a parameter file'
         paramfile = choose_file(filetype='sav')
         restore,paramfile
      end
      status EQ 'z' OR status EQ 'Z': begin
         zoomBox = find_click_box(filel[slot],usescale=currentS)
      end
      status EQ 'nothing': begin
      end
      status EQ 'h' OR status EQ 'H': begin
         for i=0l,naction-1l do begin
            print,actions[i]+' ',format='(A,$)'
         endfor
         print,''
      end
      status EQ 'ckey' OR status EQ 'CKEY': begin
         keypar = ''
         temphead = headfits(fileL[slot])
         nkeys = n_elements(temphead)
         for i=0l,nkeys-1l do begin
            print,string(i,format='(I03)'),' ',temphead[i]
         endfor
         print,'Choose a FITS keyword to print'
         read,keypar
         keyDisp = strtrim(strmid(temphead[keypar],0,7))
         print,'Will display KEYWORD: ',keyDisp
      end
      else: print,'Unrecognized Action'
   endcase
   
   print,'Choose an action or press (h) for help on actions'
   if not skipaction then read,'Action: ',status
;   status = get_kbrd()

endwhile
save,currentS,fileL,slot,lineP,zoomBox,keyDisp,$
     filename='ev_local_display_params.sav'


end
