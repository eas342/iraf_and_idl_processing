# IRTF and General Reduction Tools
This repository contains some IRAF scripts and IDL scripts for viewing and processing spectrograph and image files.
It includes a pipeline for reducing IRTF SpeX prism data in time series modes.
The IRTF SpeX prism data should have 2 sources - a target and reference star that are imaged on the slit simultaneously.
The pipeline is designed to work with data taken with the 3x60'' slit.
The pipeline will take raw data and apply the following:

 - Correct linearity, trim data
 - Apply flat and dark corrections
 - Shift images to account for pointing errors
 - Rectify the spectra
 - Correct for bad pixels
 - Extract spectral with optimal extraction techniques
This refereed paper describes the pipeline: <a href="http://adsabs.harvard.edu/abs/2014ApJ...783....5S">http://adsabs.harvard.edu/abs/2014ApJ...783....5S</a>

# Requirements
There is a hefty list of code requirements for this pipeline.
Be prepared that installing all these pieces may take a long time unless you already have experience with them.

 - `IRAF`
 - `IDL`
 - <a href="https://idlastro.gsfc.nasa.gov">The IDL Astronomy User's Library</a>
 - E Schlawin's <a href="https://github.com/eas342/added_idl_scripts">IDL Routines </a>
 - Put this code repository in the IDL path

My preferred way to add to the IDL path is to edit my `.bash_profile`:

    export IDL_PATH='<IDL_DEFAULT>:'+/path1/astron.dir
    export IDL_PATH=$IDL_PATH:+/path2/added_scripts
    export IDL_PATH=$IDL_PATH:+/path3/reduction_scripts
where `path1` is to the <a href="https://idlastro.gsfc.nasa.gov">The IDL Astronomy User's Library</a>, `path2` is to E Schlawin's <a href="https://github.com/eas342/added_idl_scripts">IDL Routines </a> and `path3` is the directory containing this code repository.


# Instructions
These are intended as reminders to oneself and not a complete set of instructions for a new user.

## A: Prepare data
 - Put all data into a directory called `edited` - this will contain a duplicate of all raw data
 - All data files should be called `run*.fits` (it’s OK if they’re sky images called `runsky*.fits`)
 - All flat images (with relevant 3x60 slit) should be `flat*.fits`
 - All dark images should be `dark*.fits`
 - All arc images (only the 0.3 x 60 slit) should be arc*.fits
 - All sky files (if using) should be listed in sky_choices.txt
 - Get rid of all periods except for the ending of files may be file.a.fits or file.b.fits
 - Remove all files not explicitly described in this list
 - Make a `proc` directory adjacent to the edited folder
 - You may have to modify permissions to the fits files (for example, the files may be set to read-only). This can be accomplished with `chmod 755 *`

## B: Load the necessary NOAO procedures
Start by opening IRAF:

	cd ~/iraf
	xgterm -sb
(Now in xgterm)

	cl
	cd /data/OBJECT5/bigdog/
	noao
	imred
	specred
	ccdred
where `/data/OBJECT5/bigdog/` is the location of the IRTF SpeX prism spectrograph data.
You may get a warning with my IRAF about camera.dat.
A solution is available here:
<http://iraf.net/forum/viewtopic.php?showtopic=1467939>

    setinst
Choose `camera.dat`

## C: Load all IRAF scripts

	
These can also be placed in the `login.cl` file so they are loaded with each log-in.

    task $adjust_headers=path_to_reduction_scripts/adjust_headers.cl
    task $reduction_script=path_to_reduction_scripts/reduction_script.cl
    task $reset_reduction=path_to_reduction_scripts/reset_reduction.cl
    task $extraction_script=path_to_reduction_scripts/extraction_script.cl
    task $reset_extraction=path_to_reduction_scripts/reset_extraction.cl
    task $cleanup_dup_files=path_to_reduction_scripts/cleanup_dup_files.cl
where `path_to_reduction_scripts` is the path to this repository.

## D: Reduce data from the “edited” directory
The reduction steps will apply linearity corrections (optional), flat fields, bad pixel masks, dark subtractions and accounts for flexure of the telescope, which 
causes the spectra and background to shift positions.

 - Navigate to the `edited` directory which contains a copy of all relevant raw files.
Edit the <a href="example_params/local_red_params.cl">`local_red_params.cl`</a> file to have the correct parameters for your file.
You will need to set a trim region the default is `s1 = "[65:749,33:607]"`
Open the image to locate the sources. Make sure that the background box and background spectrum region are between the two sources.
X,Y coordinates are from the bottom left corner.
If you have local `b1 = yes`, it will use the sky flats. You’ll need to select a set of sky images to combine (called `sky_choices.txt`).
You can also have optional `mask_for_runsky005.fits` files to specify where to mask out sources.
If you are not using sky flats, set `b1 = no`
 - Run `adjust_headers` which will set all the `darktime` and other parameters needed by IRAF.
 - (optional) Correct for non-linearity with `IDL`. This can be done within `IRAF` with the following command: `!echo “correct_linearity” | idl`
 - Set the local parameters with custom values with `cl < local_red_params.cl`
 - Run the reduction script with `reduction_script`
 - If at any time, you need to re-run the script, use `reset_reduction` to clear out any previously created files. Note that this will wipe files from the `../proc` directory.

## E: Initial Spectral Extraction
This step will rectify the images, extract spectra from each source, do background subtraction.
It first uses the `IRAF` `apall` routines, but then can be run again with custom optimal extraction techniques.
The resulting files are FITS images with flux and background as function of wavelength for each star.

 - Navigate to the `proc` directory.
 - Start by going through the images in the middle of the time series to be used as a reference aperture-finding.
Select an image with few artifacts, cosmic rays or star-like blemishes due to alpha particles from a Th-containing coating on the optics. After choosing the reference image, write the name of it to a file with `ls run_image_spc_00187.a.fits > ap_reference.txt` where in this example it is image 187.
 - Next create a <a href="example_params/local_extract_params.cl">`local_extract_params.cl`</a> file where you will set the distance range between the sources and background fitting parameters (polynomial order).
You can copy a previous file, but will need to be sure that the distance range between the source apertures includes the true value.
 - The Argon line identification is a very tedious process. It is easier to start by copying the <a href='example_params/idfirst_wavecal'>Wavelength ID file</a> from a previous extraction.

		mkdir database
		cp ~/reduction_code/example_params/idfirst_wavecal database/

	where `~/reduction_code/` is the path to this repository.

 - Load in the extraction parameters with `cl < local_extract_parameters.cl`
 - Create an initial `IRAF` extractions on the data by running `extraction_script`
 - If the first time running, edit the identification file so that the coefficients for Aperture 1 and Aperture 2 are identical and run again: `emacs database/idfirst_wavecal`
 - If at any time you need to re-run the extraction, first run `reset_extraction` to wipe the previously created files.
 - A useful map of the wavelength identification is included in <a href="example_params/labeled_argon_lines_nist.png">example\_params/labeled\_argon\_lines\_nist.png</a>

## F: Run the custom IDL extraction routine with:
This step has IDL routines to do optimal extraction and also gives more control over the background subtraction process.

 - Navigate to the `proc` directory
 - Make and edit a <a href="example_params/es_local_parameters.txt">`es_local_parameters.txt`</a>. For exampe `cp ~/reduction_code/example_params/es_local_parameters.txt .` The name must be exactly `es_local_parameters.txt`. In many cases the default parameters will be OK. You may need to adjust the size of the background aperture size (`BackSize`) if the sources are close.
 - Run the backsub command from idl
		
    	idl
    	ev_backsub

One can run `es_backsub,/saveSteps` to save the individual steps and view background-subtracted fits images to test the residuals.
Since this multiplies the amount of data by the number of steps, it only runs on 10 images by default.

Also, if the wavelength identification is updated, one may run `redo_wavecal` without re-extracting.

## G: Troubleshooting.
 - `Error in image section specification` - usually it happens when I haven’t loaded the local parameters in (either `cl < local_red_parameters.cl` in the “edited” directory or `cl < local_parameters.cl` in the “processed” directory).
 - `Cannot find sky_choices.txt` - didn't make a sky choices file
 - You get the following error in `ev_backsub`:
 
		% CROSS_COR_FIND: Inputs to cross-cor find not the same length
		% EV_BACKSUB: Bad shift returned from cross_cor_find
		                   $MAIN$
	This could be that the aperture finding failed. You may notice that after `extraction_script`, you see something like `Trace of aperture 1 in run_2017A013_170704_spc_00281.a lost at column 388.` Try choosing another aperture reference file, as described in Section E. Also, make sure that `nfind=2` when running `epar apall`
 - `ERROR: run_2017A013_170704_spc_00167.a.ms.fits - Missing reference for aperture 3`. It may have found 3 apertures instead of 2. Try choosing another aperture reference file, as described in Section E. Also, make sure that `nfind=2` when running `epar apall`
 - `ERROR: HDMGETR: No value found  "sample="*", naverage=1, nit`. This may arise if you have not run `adjust_headers` first.