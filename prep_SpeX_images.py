from astropy.io import fits, ascii
from astropy.table import Table, vstack
import glob
import os
from shutil import copyfile
import pdb
import numpy as np

class prepForPipe():
    """ Takes Raw IRTF and pre-processes them for the IRAF/IDL pipeline
    """
    def __init__(self,start_sci=48,end_sci=163,raw_dir='bigdog',
                start_sky=35,end_sky=44,edit_dir='edited'):
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
        
        self.sciTable = self.clean_names('run',start_ind=start_sci,end_ind=end_sci,
                                         usedName='spc')
        self.skyTable = self.clean_names('runsky',start_ind=start_sky,end_ind=end_sky,
                                         usedName='spc')
        self.flatTable = self.clean_names('flat',start_ind=21,end_ind=31)
        self.arcTable = self.clean_names('arc',start_ind=6,end_ind=12)
        self.darkTable = self.clean_names('dark',start_ind=370,end_ind=390,
                                          usedName='spc')
        self.allTables = vstack([self.sciTable,self.skyTable,self.flatTable,
                                self.arcTable,self.darkTable])
                                
        
    def clean_names(self,fileType,start_ind=0,end_ind=99999,start='sbd',
                    usedName=None):
        """ Cleans and prepares FITS file names for the pipeline
        Returns an astropy table with inList and outList
        """
        if usedName is None:
            usedName = fileType
        
        allList = glob.glob(self.raw_dir+'/sbd*.'+usedName+'*.fits')
        cleanList, outList = [], []
        for oneFile in allList:
            baseName = os.path.splitext(os.path.basename(oneFile))[0]
            splitPeriods = baseName.split(r".")
            imgNum = int(splitPeriods[-2])
            if (imgNum >= start_ind) & (imgNum <= end_ind):
                cleanList.append(oneFile)
                outList.append(fileType+'_'+r"_".join(splitPeriods)+'.fits')
        t = Table()
        t['inFile'] = np.array(cleanList,dtype='S150')
        t['outFile'] = np.array(outList,dtype='S150')
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
                os.mkdir(oneDir)
    
    def do_all(self):
        self.make_dirs()
        self.copy_files()
        self.make_runsky()
        
if __name__ == "__main__":
    p = prepForPipe()
    p.do_all()
