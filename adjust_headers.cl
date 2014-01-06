## Adjust the header files appropriately

# Make all exptime keyword equal to the ITIME keyword
hselect "*.fits" "$I,ITIME" "yes" > exptime_list.txt

list = "exptime_list.txt"
while (fscan (list,s1,s2) != EOF) {
      ccdhedit (s1,"exptime",s2)
}

# Make dark time keyword equal to ITIME for the darks
hselect "*dark*.fits" "$I,ITIME" "yes" > dark_list.txt
list = "dark_list.txt"
while (fscan (list,s1,s2) != EOF) {
      ccdhedit (s1,"darktime",s2)
}

# ... and zero for the flats
ccdhedit *flat*.fits darktime 0.000

ccdhedit ("*.fits",
"DISPAXIS", "1", type="string")

