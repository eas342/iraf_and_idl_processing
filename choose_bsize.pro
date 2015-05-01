pro choose_bsize,plotp
;; Asks the user for a box size when doing PSF fitting
print,'Choose a box size for PSF fitting/photometry'
bz = 0
read,'Box size (px):',bz
ev_add_tag,plotp,'BSIZE',bz

end
