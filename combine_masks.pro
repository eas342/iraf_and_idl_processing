pro combine_masks,file1,file2
;; This script combines two pixel masks. For example, you can put in the
;; pixel mask from a dark image and a pixel mask where I know there
;; are diagonal lines of bad pixels in the SpeX detector

a = mrdfits(file1,0,header1)
b = mrdfits(file2,0,header2)

xlength = fxpar(header1,'NAXIS1')
ylength = fxpar(header1,'NAXIS2')
if fxpar(header1,'NAXIS1') EQ fxpar(header2,'NAXIS1') and $
   fxpar(header1,'NAXIS2') EQ fxpar(header2,'NAXIS2') then begin
   c = a or b
endif else c = a

;; Save the combined
writefits,'combined_mask.fits',c,header1

end
