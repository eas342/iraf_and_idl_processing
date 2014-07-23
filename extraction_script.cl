## Load the requisite commands
noao
imred
ccdred

noao
imred
specred

noao
imred
ccdred

# Make a list of all spectral extractions
# First, get the prefixes of the file names
!awk '{sub(/\......../, "", $1)} 1' ../edited/proc_science_images.txt | awk '{sub(/.....$/, "", $1)} 1' > science_prefixes.txt
# Next add ms.fits to the prefixes
!awk -F, '{$1=$1 ".ms.fits";}1' science_prefixes.txt > extracted_speclist.txt
# Make a proc_science_images.txt file in the proc folder
!awk -F, '{$1=$1 ".fits";}1' science_prefixes.txt > proc_science_images.txt
# Make a straight_science_images.txt file in the proc folder
!awk -F, '{$1=$1 "_straight.fits";}1' science_prefixes.txt > straight_science_images.txt

# Make a local list of arc images
# First, get the prefixes of the file names
!awk '{sub(/\......../, "", $1)} 1' ../edited/proc_arclist.txt | awk '{sub(/.....$/, "", $1)} 1' > arc_prefixes.txt
# Make a proc_arclist.txt file in the proc folder
!awk -F, '{$1=$1 ".fits";}1' arc_prefixes.txt > proc_arclist.txt

# Make a master arc
combine ("@proc_arclist.txt",
"masterarc.fits", plfile="", sigma="", ccdtype="", subsets=no, delete=no,
clobber=no, combine="average", reject="avsigclip", project=no, outtype="real",
offsets="none", masktype="none", maskvalue=0., blank=0., scale="none",
zero="none", weight="none", statsec="", lthreshold=INDEF, hthreshold=INDEF,
nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="18",
gain="13", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0)

## Find the shift values for the masterarc image & use those to straighten the rest
#!echo "ev_compile_red & find_shift_values,custarc='masterarc.fits',custshiftFile='arc_shifts.txt',arcshift='masterarc_straight.fits'" | idl
#!echo "ev_compile_red & straighten_spec,'proc_science_images.txt','straight_science_images.txt',shiftlist='arc_shifts.txt',/dodivide" | idl

#straighten images to a common image (the middle image in the sequence
!echo "ev_compile_red & shift_to_common,/onefunc" | idl
#!echo "ev_compile_red & shift_to_common" | idl

# Shift the arc just like the master common image
ls masterarc.fits > masterArclist.txt
!echo "masterarc_straight.fits" > straight_masterarcList.txt
!echo "ev_compile_red & straighten_spec,'masterArclist.txt','straight_masterarcList.txt',shiftlist='master_shifts.txt',/dodivide" | idl

#Temporarily use the un-straightened images
#!mv proc_science_images.txt straight_science_images.txt

# Find the apertures, these commands help it from hanging up on groups of bad pixels
#apfind ("@straight_science_images.txt",
#2, apertures="", references="", interactive=no, find=yes, recenter=yes,
#resize=no, edit=yes, line=INDEF, nsum=-60, minsep=100., maxsep=10000.,
#order="increasing")

# Extract the reference spectrum
apall ("@ap_reference.txt",
2, output="extracted_ap_ref_spec", apertures="", format="multispec",
references="", profiles="", interactive=no, find=yes, recenter=yes, resize=yes,
edit=yes, trace=yes, fittrace=no, extract=yes, extras=yes, review=no,
line=INDEF, nsum=-60, lower=-7., upper=7., apidtable="", b_function="legendre",
b_order=(i), b_sample=(s1), b_naverage=1, b_niterate=3,
b_low_reject=5., b_high_rejec=5., b_grow=0., width=5., radius=10.,
threshold=0., minsep=(j), maxsep=(k), order="increasing", aprecenter="",
npeaks=INDEF, shift=yes, llimit=(x), ulimit=(y), ylevel=(z), peak=yes, bkg=yes,
r_grow=0., avglimits=yes, t_nsum=10, t_step=10, t_nlost=3,
t_function="spline3", t_order=1, t_sample="*", t_naverage=1, t_niterate=1,
t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1,
weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise="13",
gain="13", lsigma=3., usigma=3., nsubaps=1)

# Extract spectra
apall ("@straight_science_images.txt",
2, output="@extracted_speclist.txt", apertures="", format="multispec",
references="@ap_reference.txt", profiles="", interactive=no, find=yes, recenter=yes, resize=no,
edit=yes, trace=no, fittrace=no, extract=yes, extras=yes, review=no,
line=INDEF, nsum=-60, lower=-7., upper=7., apidtable="", b_function="legendre",
b_order=15, b_sample="-200:-11,11:200", b_naverage=1, b_niterate=3,
b_low_reject=5., b_high_rejec=5., b_grow=0., width=5., radius=10.,
threshold=0., minsep=(j), maxsep=(k), order="increasing", aprecenter="",
npeaks=INDEF, shift=yes, llimit=-9., ulimit=9., ylevel=0.1, peak=yes, bkg=yes,
r_grow=0., avglimits=yes, t_nsum=10, t_step=10, t_nlost=3,
t_function="legendre", t_order=2, t_sample="*", t_naverage=1, t_niterate=1,
t_low_reject=3., t_high_rejec=3., t_grow=0., background="fit", skybox=1,
weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise="13",
gain="13", lsigma=3., usigma=3., nsubaps=1)


# Use the master arc with the first spectral file
!head -n 1 straight_science_images.txt > first_spectrum.txt

# Use the apertures from the first file for wavelength calibration
apall ("masterarc_straight.fits",
2, output="first_wavecal", apertures="", format="multispec",
references="@first_spectrum.txt", profiles="", interactive=no, find=no,
recenter=no, resize=no, edit=yes, trace=no, fittrace=no, extract=yes,
extras=yes, review=no, line=INDEF, nsum=10, lower=-7., upper=7., apidtable="",
b_function="legendre", b_order=3, b_sample="-90:-11,11:90", b_naverage=1,
b_niterate=3, b_low_reject=5., b_high_rejec=5., b_grow=0., width=5.,
radius=10., threshold=0., minsep=100., maxsep=100000., order="increasing",
aprecenter="", npeaks=INDEF, shift=yes, llimit=-9., ulimit=9., ylevel=0.1,
peak=yes, bkg=yes, r_grow=0., avglimits=yes, t_nsum=10, t_step=10, t_nlost=3,
t_function="spline3", t_order=1, t_sample="*", t_naverage=1, t_niterate=1,
t_low_reject=3., t_high_rejec=3., t_grow=0., background="none", skybox=1,
weights="variance", pfit="fit1d", clean=yes, saturation=INDEF, readnoise="13",
gain="13", lsigma=3., usigma=3., nsubaps=1)

# Put in this parameter to deal with a bug where logfile and log are indistinguishable
bool log

#Identify lines in the arc spectrum at star locations
identify ("first_wavecal.fits",section="line 1,line 2",
databas="database", coordli="linelists$argon.dat", units="", nsum=10,
match=-3, maxfeat=50, zwidth=300, ftype="emission", fwidth=4,
cradius=5, thresho=0, minsep=2, functio="spline3", order=1,
sample="*", niterat=0, low_rej=3, high_re=3, grow=0, autowri=no,
graphic="stdgraph", cursor="", aidpars="", mode="ql")


#Reference all spectra to first_wavecal
ccdhedit ("@extracted_speclist.txt",
"REFSPEC1", "first_wavecal.fits", type="string")

#Generate a list of all dispersion corrected spectra
!awk -F, '{$1=$1 ".ms.d.fits";}1' science_prefixes.txt > full_disp_list.txt

#Assign wavelengths to all spectra
dispcor ("@extracted_speclist.txt",
"@full_disp_list.txt", linearize=yes, database="database", table="", w1=8000.,
w2=26360., dw=35., nw=INDEF, log=no, flux=yes, blank=0., samedisp=no,
global=no, ignoreaps=no, confirm=no, listonly=no, verbose=yes, logfile="")


