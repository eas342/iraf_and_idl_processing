from astropy.io import fits, ascii
from astropy.table import Table, vstack
import glob
import os
from shutil import copyfile

class prepForPipe():
    """ Takes Raw IRTF and pre-processes them for the IRAF/IDL pipeline
    """
    def __init__(self,start_sci=85,end_sci=99999,raw_dir='bigdog',
                start_sky=43,end_sky=57,edit_dir='edited'):
        """ 
        This Class Takes Raw IRTF and pre-processes them for the IRAF/IDL 
        Pipeline
        
        Parameters
        --------------
        start_sci: int
            The starting image number for science data
        end_sci: int
            The ending image number for science data
        raw_dir: str
            The raw directory for SpeX Spectrograph (Bigdog) images
        """
        self.start_sci = start_sci
        self.end_sci = end_sci
        
        self.raw_dir = raw_dir
        self.edit_dir = edit_dir
        
        allSciList = glob.glob(self.raw_dir+'/sbd*.run*.fits')
        self.sciTable = self.clean_names('run',start_ind=start_sci,end_ind=end_sci)
        self.skyTable = self.clean_names('runsky',start_ind=start_sky,end_ind=end_sky)
        self.flatTable = self.clean_names('flat',start_ind=31,end_ind=41)
        self.arcTable = self.clean_names('arc',start_ind=21,end_ind=27)
        self.darkTable = self.clean_names('dark',start_ind=1,end_ind=15)
        
        self.allTables = vstack([self.sciTable,self.skyTable,self.flatTable,
                                self.arcTable,self.darkTable])
                                
        
    def clean_names(self,fileType,start_ind=0,end_ind=99999,start='sbd'):
        """ Cleans and prepares FITS file names for the pipeline
        Returns an astropy table with inList and outList
        """
        allList = glob.glob(self.raw_dir+'/sbd*.'+fileType+'*.fits')
        cleanList, outList = [], []
        for oneFile in allList:
            baseName = os.path.splitext(os.path.basename(oneFile))[0]
            splitPeriods = baseName.split(r".")
            imgNum = int(splitPeriods[-2])
            if (imgNum >= start_ind) & (imgNum <= end_ind):
                cleanList.append(oneFile)
                outList.append(fileType+'_'+r"_".join(splitPeriods)+'.fits')
        t = Table()
        t['inFile'] = cleanList
        t['outFile'] = outList
        return t
    
    def copy_files(self,overwrite=False):
        """ Copies the files"""
        for oneRow in self.allTables:
            if (os.path.exists(oneRow['outFile']) == False) | (overwrite == True):
                copyfile(oneRow['inFile'],self.edit_dir+'/'+oneRow['outFile'])
    
    def make_runsky(self):
        with open(self.edit_dir+'/sky_choices.txt','w') as outFile:
            for oneRow in self.skyTable:
                outFile.write(oneRow['outFile']+"\n")
    
    def make_dirs(self):
        for oneDir in ['edited','proc']:
            if os.path.exists(oneDir) == False:
                os.path.mkdir(oneDir)
    
    def do_all(self):
        self.make_dirs()
        self.copy_files()
        self.make_runsky()
        
if __name__ == "__main__":
    p = prepForPipe()
    p.do_all()
