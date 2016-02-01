pro es_cmd_focus
;; Bringts the terminal to focus after adjusting windows. This is
;; helpful for sticking to the keyboard and not having to click
;; again. This works with Mac OS X using the open command, but
;; doesn't seem to in Linux. Haven't tried Windows.

  if !Version.OS EQ 'darwin' then begin
     spawn,'open -a Terminal'
  endif

end
