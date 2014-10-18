pro fix_sky_flattened,filen
;; Replace all sky fram points below a threshold and above a threshold

hiThresh = 1.5E
lowThresh = 0.5E

a1 = mrdfits(filen,0,head)
;; Re-normalize
a1 = a1 / median(a1)
splitNm = strsplit(filen,'.',/extract)
preNm = splitNm[0]
outNm = preNm+'_fixed.fits'
badp = where(a1 LT lowThresh OR a1 GT hiThresh)
if badp NE [-1] then begin
   a2 = replace_pixels(a1,badp)
endif else a2 = a1

sxaddpar,head,'FIXPIXRESPONSE','1','Pixels are fixed within response function'
sxaddpar,head,'FIXLOWTHRESH',lowThresh,'Low threshold above which all pixels are fixed'
sxaddpar,head,'FIXLOWTHRESH',hiThresh,'Hi threshold below which all pixels are fixed'

writefits,outNm,a2,head

end
