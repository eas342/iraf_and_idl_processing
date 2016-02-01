PRO miv_help_event, ev
WIDGET_CONTROL, ev.ID, GET_UVALUE=uval ;; retrieve button stuff
widget_control, ev.top, get_uvalue= filen ;; retrieve the filename

CASE uval of
    'DONE': begin
       WIDGET_CONTROL, ev.TOP, /DESTROY
       spawn,'open -a Terminal'
       return
    end
 ENDCASE

END

PRO miv_help
;; Allows the user to view the Multi-Image Viewer (MIV) help and quickly exit


;; Only works if it correctly finds miv_help.pro 
;; but this seemed the best way to retrieve the filepath needed
;; to get to the help file
  mivhproname = clobber_dir(file_which('miv_help.pro'),dir=reddir)
  helppath = reddir+'data/miv_help.txt'
  nlines = file_lines(helppath)
  helpInfo = strarr(nlines)
  openr,1,helppath
  readf,1,helpInfo
  close,1
  
  
  base = WIDGET_BASE(/column) ;; base to store groups of buttons
  cntl = widget_base(base, /row,/frame) ;; control widget
  txtb = widget_base(base, /frame) ;; Text widget

  screensize = get_screen_size()
  YscrollSize = screensize[1] - 100
  txtval = widget_text(txtb,value=helpInfo,scr_ysize=yscrollsize,$
                       /scroll)
  ;; Allow a quit
  donebutton = WIDGET_BUTTON(cntl, VALUE='Done', UVALUE='DONE')

  WIDGET_CONTROL, base, /REALIZE

;  widget_control, paramw, set_uvalue = plotp ;; save the plot parameters
  XMANAGER, 'miv_help', base;,/no_block
END
