pro get_zoom,input,y,plotp=plotp,restart=restart,$
             rzoom=rzoom,plotmode=plotmode
;; Gets a zoom with the cursor using
;; restart - start from the full frame
;; rzoom - reset the zoom to full frame
;; plotp - plot parameters
;; plotmode - works in the plotting mode which assumes a plot instead
;;            of an image

  if keyword_set(rzoom) then begin
     ev_undefine_tag,plotp,'ZOOMBOX'
  endif else begin
     if keyword_set(restart) then ev_undefine_tag,plotp,'ZOOMBOX'
     if keyword_set(plotmode) then begin
        zoomBox = find_click_box()
     endif else begin
        zoomBox = find_click_box(input,plotp=plotp)
     endelse
     ev_add_tag,plotp,'ZOOMBOX',zoombox
  endelse
  if keyword_set(plotmode) then begin
     disp_plot,input,y,gparam=plotp
  endif else fits_display,input,plotp=plotp

end
