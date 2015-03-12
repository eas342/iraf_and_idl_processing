pro get_zoom,filen,plotp=plotp,restart=restart,$
             rzoom=rzoom
;; Gets a zoom with the cursor using
;; restart - start from the full frame
;; rzoom - reset the zoom to full frame
;; plotp - plot parameters

  if keyword_set(rzoom) then begin
     ev_undefine_tag,plotp,'ZOOMBOX'
  endif else begin
     if keyword_set(restart) then ev_undefine_tag,plotp,'ZOOMBOX'
     zoomBox = find_click_box(filen,plotp=plotp)
     ev_add_tag2,plotp,'ZOOMBOX',zoombox
  endelse
  fits_display,filen,plotp=plotp

end
