pro choose_flat,plotp
;; Choose a flat field

filech = dialog_pickfile(/read,filter='*.fits')

ev_add_tag,plotp,'FLATFILE',filech

end
