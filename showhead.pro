PRO showhead_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filen ;; retrieve the filename


CASE uval of
    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
       if !Version.OS EQ 'darwin' then spawn,'open -a Terminal'
       return
    end
    'SEARCH': begin
       ;; Retrieve the ID and text of the text widget
       idText = widget_info(ev.top,find_by_uname="TEXT")
       widget_control, idText, get_value= text
       sz = size(text)
       ;; Retrieve the ID and text of the search widget
       idsText = widget_info(ev.top,find_by_uname="STEXT")
       widget_control, idsText, get_value= sText
       matchTrue = strmatch(text,'*'+sText+'*',/fold_case)
       wherematch = where(matchTrue[*] GE 1,nmatch) ;; the * turns into 1 d array

       ;; Start all rows as white background
       colarr = intarr(3,sz[1] * sz[2]) + 255

       ;; Highlight the matched rows
       if nmatch GE 1 then begin
          colarr[*,wherematch] = rebin([255,255,0],3,nmatch)
       endif
       widget_control, idText, background_color=colarr

    end
 ENDCASE

END

PRO showhead,filen
;; Allows the user to view the header and quickly exit

hd = headfits(filen)
keys = gettok(hd,'=')

;; Pre-pend with the full path name
keys = ['File path','',keys]
hd = [filen,'',hd]

;; For comments stuffed into the file, display as values (not keys)
;; For example, Spextool spectra have comments written (but not as
;; keyword value pairs)
for i=0l,n_elements(keys)-1l do begin
   if strlen(keys[i]) GT 9 then begin
      hd[i] = keys[i]+hd[i]
      keys[i] = ''
   endif
endfor

outL = [transpose(keys),transpose(hd)]
  
  base = WIDGET_BASE(/column) ;; base to store groups of buttons
  cntl = widget_base(base, /row,/frame) ;; control widget
  txtb = widget_base(base, /frame) ;; Text widget

  screensize = get_screen_size()
  YscrollSize = screensize[1] - 100
  txtval = widget_table(txtb,value=outL,scr_ysize=yscrollsize,$
                       /scroll,background_color=[255,255,255],$
                       column_widths=[100,700],row_labels=keys,$
                        column_labels=['Value/comment'],/no_headers,$
                       uname='TEXT')
  ;; Allow a quit
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')
  ;; Search text field
  searchField = widget_text(cntl, VALUE='', UNAME='STEXT',/editable,uvalue='SEARCH')
  searchbutton = widget_button(cntl, value='Search', uvalue='SEARCH')

  WIDGET_CONTROL, base, /REALIZE

;  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  XMANAGER, 'showhead', base;,/no_block
END
