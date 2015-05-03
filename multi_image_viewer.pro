pro multi_image_viewer
;; Displays multiple fits files and lets you go between them

actions = ['(q)uit','(r)ead new file',$
           '(rf) read a file with filter',$
           '(rfa) read a set of files with a filter',$
           '(o)pen new file w/ browser','set (s)cale',$
           '(fullscale) to use min/max for scaling',$
           '(h)elp prints the commands',$
           '(t)oggle image mode','(d)raw a line',$
           '(p)lot a line or box','(pm) to plot median',$
           '(op) overplot line or box mode',$
           '(opd) overplot and divide by median',$
           '(ps) to plot and stop',$
           '(b)ox draw mode','(c)lear previous settings',$
           '(cf) to clear file list',$
           '(cfolder) to open the current folder in finder',$
           '(fedit) to export filelist to a text file for editing',$
           '(fread) to read filelist that was made by fedit',$
           '(l)oad another parameter file.',$
           '(z)oom in','(save) EPS of FITS image',$
           '(zz)oom in from a zoomed',$
           '(rzoom) to reset the zoom',$
           '(cflat) to choose a flat','(qflat) to cancel a flat',$
           '(fitpsf) to fit a PSF',$
           '(mfit) to fit many PSFs',$
           '(sphot) to save the photomery',$
           '(refit) to fit many PSFs from previous file',$
           '(allfit) to fit many PSFs in all FITs files',$
           '(qspec) to extract a quick spectrum',$
           '(asave) to save all images in file list',$
           '(sparam) to save the display parameters as custom filename',$
           '(rot)ation change','(maskedit) mask edit',$
           '(imcombine) image combine','(aedit) Edit Action List',$
           '(nodsub) nod subtract image w/ next',$
           '(ckey) to choose a FITS keyword to print',$
           '(keyedit) to edit the FITS keywords',$
           '(keyread) to read the FITS keyword list']
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
         fits_display,filen,plotp=plotp,lineP=lineP
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
            fits_display,filel[slot],plotp=plotp,lineP=lineP
         endelse
      end
      status EQ 's' OR status EQ 'S': begin
         fits_display,filel[slot],/findscale,plotp=plotp,lineP=lineP
      end
      status EQ 'fedit' OR status EQ 'FEDIT': begin
         fedit,filel,plotp=plotp
      end
      status EQ 'aedit' OR status EQ 'AEDIT': begin
         fedit,filel,plotp=plotp,/action
      end
      status EQ 'fread' OR status EQ 'FREAD': begin
         readcol,'ev_local_display_filelist.txt',filel,format='(A)'
         if slot GT n_elements(filel) -1l then slot=0
      end
      status EQ 't' OR status EQ 'T': begin
         slot = toggle_fits(fileL,plotp=plotp,lineP=lineP,startslot=slot)
      end
      status EQ 'save' OR status EQ 'SAVE': begin
         save_image,fileL,plotp=plotp,lineP=lineP,startslot=slot
      end
      status EQ 'asave' OR status EQ 'ASAVE': begin
         for i=0l,n_elements(fileL)-1l do begin
            save_image,fileL,plotp=plotp,lineP=lineP,$
                       startslot=i
         endfor
      end
      status EQ 'nodsub' Or status EQ 'NODSUB': $
         nodsub,filel,plotp,lineP,slot
      status EQ 'maskedit' OR status EQ 'MASKEDIT': $
         maskedit,filel[slot],lineP,plotp
      status EQ 'imcombine' OR status EQ 'IMCOMBINE': $
         imcombine,'action_list.txt'
      status EQ 'sparam' OR status EQ 'SPARAM': check_idlsave,fileL,slot,lineP,plotp,$
         varnames=['fileL','slot','lineP','plotp']
      status EQ 'c' OR status EQ 'C': begin
         confirm=''
         print,'Are you sure you want to delete all settings?'
         read,confirm
         if confirm EQ 'y' or confirm EQ 'Y' or confirm EQ 'yes' $
            or confirm EQ 'Yes' then begin
            undefine,fileL
            undefine,slot
            undefine,lineP
            undefine,plotp
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
      status EQ 'cfolder' OR status EQ 'CFOLDER': begin
         spawn,'open .'
      end
      status EQ 'p' OR status EQ 'P': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,plotp=plotp)
      end
      status EQ 'op' OR status EQ 'OP': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,plotp=plotp)
      end
      status EQ 'opd' OR status EQ 'OPD': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/overplot,$
                               /normalize,plotp=plotp)
      end
      status EQ 'pm' OR status EQ 'PM': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/median,plotp=plotp)
      end
      status EQ 'ps' OR status EQ 'PS': begin
         slot = fits_line_plot(fileL,lineP=lineP,current=slot,/makestop,plotp=plotp)
      end
      status EQ 'd' OR status EQ 'D': begin
         lineP = fits_line_draw(fileL[slot],plotp=plotp)
      end
      status EQ 'b' OR status EQ 'B': begin
         lineP = find_click_box(filel[slot],plotp=plotp,$
                               /get_direction)
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
         get_zoom,filel[slot],plotp=plotp,/restart
      end
      status EQ 'zz' OR status EQ 'ZZ': begin
         get_zoom,filel[slot],plotp=plotp
      end
      status EQ 'rzoom' OR status EQ 'RZOOM': begin
         get_zoom,filel[slot],plotp=plotp,/rzoom
      end
      status EQ 'rot' OR status EQ 'ROT': begin
         get_rotation,filel[slot],plotp=plotp,linep=linep
      end
      status EQ 'fullscale' OR status EQ 'FULLSCALE':begin
         ev_add_tag,plotp,'FULLSCALE',1
         fits_display,filel[slot],linep=linep,plotp=plotp
      end
      status EQ 'nothing': begin
      end
      status EQ 'h' OR status EQ 'H': begin
         midP = ceil(float(naction)/2E)
         for i=0l,midp-1l do begin
            print,actions[i],format='(A-38," ",$)'
            if i + midp LE naction-1l then begin
               print,actions[i + midp],format='(A-38)'
            endif
         endfor
         print,''
      end
      status EQ 'ckey' OR status EQ 'CKEY': $
         choose_key,fileL[slot],plotp
      status EQ 'keyedit' OR status EQ 'KEYEDIT': $
         if ev_tag_exist(plotp,'KEYDISP') then $
            fedit,plotp.keydisp,custnm='keyword_list.txt'
      status EQ 'keyread' OR status EQ 'KEYREAD': begin
         readcol,'keyword_list.txt',quickkey,format='(A)'
         ev_add_tag,plotp,'KEYDISP',quickkey
      end
      status EQ 'bsize' OR status EQ 'BSIZE': begin
         choose_bsize,plotp
      end
      status EQ 'fitpsf' OR status EQ 'FITPSF': begin
         fit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'mfit' OR status EQ 'MFIT': begin
         multi_fit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'sphot' OR status EQ 'SPHOT': begin
         save_phot
      end
      status EQ 'refit' OR status EQ 'REFIT': begin
         refit_psf,fileL[slot],LineP,plotp=plotp
      end
      status EQ 'allfit' OR status EQ 'ALLFIT': begin
         refit_psf,fileL,LineP,plotp=plotp
      end
      status EQ 'qspec' OR status EQ 'QSPEC': begin
         quick_specsum,filel[slot]
      end
      status EQ 'cflat' OR status EQ 'CFLAT': begin
         choose_flat,plotp
      end
      status EQ 'qflat' OR status EQ 'QFLAT': begin
         ev_undefine_tag,plotp,'FLATFILE'
      end
      else: print,'Unrecognized Action'
   endcase
   
   print,'Choose an action or press (h) for help on actions'
   if not skipaction then read,'Action: ',status
;   status = get_kbrd()

endwhile
save,fileL,slot,lineP,plotp,$
     filename='ev_local_display_params.sav'


end
