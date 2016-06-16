pro choose_bias,plotp
;; Choose a bias image to subtract while reading in images

filech = dialog_pickfile(/read,filter='*.fits')
exten=0

ev_undefine_tag,plotp,'BIASFILE'
biasimg = mod_rdfits(filech,exten,header,plotp=plotp)
savename = 'biasdata_for_'+clobber_dir(filech,/exten)+'.sav'
save,biasimg,filename=savename

ev_add_tag,plotp,'BIASFILE',savename

end
