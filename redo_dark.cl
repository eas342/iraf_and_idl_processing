ls flat*.fits > flatlist.txt

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

#ccdhedit ("*.fits",
#"DISPAXIS", "1", type="string")

## Adjust the header files appropriately

# Make all exptime keyword equal to the ITIME keyword
hselect "*.fits" "$I,ITIME" "yes" > exptime_list.txt

list = "exptime_list.txt"
#while (fscan (list,s1,s2) != EOF) {
#      ccdhedit (s1,"exptime",s2)
#}

# Make dark time keyword equal to ITIME for the darks
#hselect "*dark*.fits" "$I,ITIME" "yes" > dark_list.txt
#list = "dark_list.txt"
#while (fscan (list,s1,s2) != EOF) {
#      ccdhedit (s1,"darktime",s2)
#}

# ... and zero for the flats
#ccdhedit *flat*.fits darktime 0.000

## Make master dark
combine ("*dark*.fits",
"masterdark.fits", plfile="", sigma="", ccdtype="", subsets=no, delete=no,
clobber=no, combine="average", reject="avsigclip", project=no, outtype="real",
offsets="none", masktype="none", maskvalue=0., blank=0., scale="none",
zero="none", weight="none", statsec="", lthreshold=INDEF, hthreshold=INDEF,
nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="14",
gain="13", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0)

## Make master flat, first combine

combine ("*flat*.fits",
"masterflat.fits", plfile="", sigma="", ccdtype="", subsets=no, delete=no,
clobber=no, combine="average", reject="avsigclip", project=no, outtype="real",
offsets="none", masktype="none", maskvalue=0., blank=0., scale="none",
zero="none", weight="none", statsec="", lthreshold=INDEF, hthreshold=INDEF,
nlow=1, nhigh=1, nkeep=1, mclip=yes, lsigma=3., hsigma=3., rdnoise="14",
gain="13", snoise="0.", sigscale=0.1, pclip=-0.5, grow=0)
