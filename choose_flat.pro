pro choose_flat,plotp
;; Choose a flat field

filech = dialog_pickfile(/read,filter='*.fits')
exten=0

ev_undefine_tag,plotp,'FLATFILE'
flatimg = mod_rdfits(filech,exten,header,plotp=plotp)
medp = median(flatimg)
flatdata = float(flatimg)/medp
zerop = where(flatdata,nzero) EQ 0
if nzero GE 1 then flatdata[zerop]=100E
savename = 'flatdata_for_'+clobber_dir(filech,/exten)+'.sav'
save,flatdata,filename=savename

ev_add_tag,plotp,'FLATFILE',savename

end
