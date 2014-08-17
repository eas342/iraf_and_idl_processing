##List flat fields and save with extension 0
!for f in flat*.fits; do echo "$f[0]"; done > flatlist.txt

## Make master dark
combine ("*dark*.fits[0]",
"masterdark.fits", plfile="", sigma="", ccdtype="", subsets=no, delete=no,
clobber=no, combine="median", reject="avsigclip", project=no, outtype="real",
offsets="none", masktype="none", maskvalue=0., blank=0., scale="none",
zero="none", weight="none", statsec="", lthreshold=INDEF, hthreshold=INDEF,
nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="14",
gain="13", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0)

## Use the master dark to create a bad pixel mask
ccdmask ("masterdark.fits",
"mask_from_masterdark", ncmed=10, nlmed=10, ncsig=25, nlsig=25, lsigma=30.,
hsigma=30., ngood=3, linterp=2, cinterp=3, eqinterp=2)

## Merge this pixel mask with the known bad diagonals
imcopy ("mask_from_masterdark.pl",
"mask_from_masterdark.fits", verbose=yes)
!echo "ev_compile_red & combine_masks,'mask_from_masterdark.fits','/Users/bokonon/triplespec/iraf_scripts/diagonal_mask.fits'" | idl
imcopy ("combined_mask.fits[0]",
"combined_mask.pl", verbose=yes)

## Make master flat, first combine
combine ("@flatlist.txt",
"masterflat.fits", plfile="", sigma="", ccdtype="", subsets=no, delete=no,
clobber=no, combine="average", reject="avsigclip", project=no, outtype="real",
offsets="none", masktype="none", maskvalue=0., blank=0., scale="none",
zero="none", weight="none", statsec="", lthreshold=INDEF, hthreshold=INDEF,
nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="14",
gain="13", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0)

## Trim the flat for use by response
#imcopy masterflat.fits[0][510:1024,105:495] trimflat.fits
#imcopy masterflat.fits[0][80:878,24:615] trimflat.fits
ccdproc ("masterflat.fits[0]",
output="trimflat.fits", ccdtype="", max_cache=0, noproc=no, fixpix=no,
overscan=no, trim=yes, zerocor=no, darkcor=no, flatcor=no, illumcor=no,
fringecor=no, readcor=no, scancor=no, readaxis="line", 
fixfile="", biassec="",
trimsec=(s1), zero="", dark="",
flat="", illum="", fringe="", minreplace=0.2,
scantype="shortscan", nscan=1, interactive=no, function="legendre", order=1,
sample="*", naverage=1, niterate=1, low_reject=3., high_reject=3., grow=0.)

response ("trimflat",
"trimflat", "response", interactive=no, threshold=500, sample="*",
naverage=1, function="spline3", order=10, low_reject=3., high_reject=3.,
niterate=3, grow=0., graphics="stdgraph", cursor="")

## Make the response file a full image size b/c it will be trimmed by ccdproc
#imarith masterflat.fits[0] * 0. full_response.fits
#imarith full_response.fits[0] + 1. full_response.fits[0]
#imcopy response.fits[0] full_response.fits[0][510:1024,105:495]
#imcopy response.fits[0] full_response.fits[0][80:878,24:615]
#imarith full_response.fits[0] + response.fits[0] full_response.fits
imcopy response.fits full_response.fits
## Do this with an IDL script instead. Got frustrated trying to use CL variables
## Reads in the s1 parameter from local_red
#!echo "ev_compile_red & copy_response" | idl

# Make a list of all arc images and output images
ls *arc*.fits > arclist_orig.txt
!for f in *arc*.fits; do echo "$f[0]"; done > arclist.txt
!awk -F, '{$1="../proc/" $1;}1' arclist_orig.txt > proc_arclist.txt

# Process the arc images
ccdproc ("@arclist.txt",
output="@proc_arclist.txt", ccdtype="", max_cache=0, noproc=no, fixpix=yes,
overscan=no, trim=yes, zerocor=no, darkcor=yes, flatcor=yes, illumcor=no,
fringecor=no, readcor=no, scancor=no, readaxis="line", 
fixfile="combined_mask.pl", biassec="",
trimsec=(s1), zero="", dark="masterdark.fits",
flat="full_response.fits", illum="", fringe="", minreplace=0.2,
scantype="shortscan", nscan=1, interactive=no, function="legendre", order=1,
sample="*", naverage=1, niterate=1, low_reject=3., high_reject=3., grow=0.)

# Make a list of all the science images and output for the processed versions
!for f in *run*.fits; do echo "$f[0]"; done > science_images.txt
## PUT back in *run*lincor.fits eventually when doing linearity corrections!!!
ls *run*.fits > science_images_plain.txt
!awk -F, '{$1="../proc/" $1;}1' science_images_plain.txt > proc_science_images.txt

# Proces the science images
ccdproc ("@science_images.txt",
output="@proc_science_images.txt", ccdtype="", max_cache=0, noproc=no, fixpix=yes,
overscan=no, trim=yes, zerocor=no, darkcor=yes, flatcor=yes, illumcor=no,
fringecor=no, readcor=no, scancor=no, readaxis="line",
fixfile="combined_mask.pl", biassec="",
trimsec=(s1), zero="", dark="masterdark.fits[0]",
flat="full_response.fits[0]", illum="", fringe="", minreplace=0.2,
scantype="shortscan", nscan=1, interactive=no, function="legendre", order=1,
sample="*", naverage=1, niterate=1, low_reject=3., high_reject=3., grow=0.)
