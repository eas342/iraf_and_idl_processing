# Slit Angle Finding Instructions
Goal: Find the angle of teh IRTF SpeX slit so one can accurately align two stars along the slit

### Using the `slit_angle_find.pro` Script:

First time through:

1. Navigate to the directory containing the GuideDog images
2. Run `slit_angle_find.pro`
3. It will need an initial guess location for the guide box. Click on the lower left and upper right of the guide box. Click again to finish.
4. The slit center will appear as a blue line
5. Click on the lower and upper stars. The script will find the centers automatically
6. The script will print the angle in degrees

Subsequent times through:

* `slit_angle_find` will use the same guesses and run on the latest images
* `slit_angle_find,/restar` will allow you to guess new positions for the stars
* `slit_angle_find,/reslit` will find the slit center again
* `slit_angle_find,/rescale` will allow you to adjust the scaling - useful for finding stars once they are inside the slit

Using sky subtraction:

* Rename a file to be used in sky subtraction as `sky_extra_stuff_here.fits`
* `slit_angel_find,/nosky` will skip the sky subtraction
