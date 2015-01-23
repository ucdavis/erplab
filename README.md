
ERPLAB
======

ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with EEGLAB Toolbox, extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users.  



ERPLAB 4.0.3.0 Changes
======
UTILITIES
* Convert and Epoch dataset into a continuous one: After using this tool, users have the option of using a second tool to recover the original event codes from bin labels. This tool is called Recover event codes from bin labels. 

* When using Recover event codes from bin labels user can also apply a multiplier to the recovered event codes in order to make them different from the original ones. For instance, let's say that the code 14 was part of a bin that was looking for fast-response trials. This means that there will be a subset of event codes 14 that were not captured because they had a larger button press time. So, in a case like this user can apply a multiplier of 10 in such a way that the recovered event codes will be multiplied by 10, in this way, for instance, recovered codes 14 will appear as 140 in the converted-to-continuous dataset.

PLOT ERP
* At ERP Plotting GUI: Users can now invert the background from white to black and vice-versa (font color automatically adjusts to the opposite background color).
* At ERP Plotting GUI: User will find an upgraded Line Specifications GUI (after clicking on LINE SPEC button). This small GUI now allows an easier and faster organization of colors and styles of the the lines used for drawing the waveforms.

ERP VIEWER
* When selecting a single bin to plot, the report window will show the full name of the bin (bin description), otherwise (selecting multiple bins) the report window will show the bin indices only. This behavior is also valid for selected channels and selected files.

COMPUTE AVERAGED ERPs
* This tool now also has the capability of getting the Total Power Spectrum or the Evoked Power Spectrum underlaying the epochs you use for getting your ERP waveforms. Any selection criterion you used on your epochs for getting the ERPs will be used for getting these types of spectrums. Basically, for getting the Total Power Spectrums the same single-trial epochs selected for obtaining the ERPs are transformed (optionally tapered with a Hamming window) via fast-Fourier transform (FFT) to power spectra , and then the average across all spectra is derived for each bin. For getting the Evoked Power Spectrum the final ERP waveforms are transformed via fast-Fourier transform (FFT) to power spectrums.

FILTER & FREQUENCY TOOLS
* ERPLAB also allows to obtain the Evoked Power Spectrum directly from an existing averaged ERP. See Compute Power Spectrum from current ERPset.

ERP structure
* In this new version, and in order to identify the type of data across ERPsets, the ERP structure has a new field called datatype. This field will contain the string 'ERP' when having averaged waveforms in the time domain (classic ERPs), or, for the frequency domain, the string 'TFFT' when Total Power Spectrums data are contained, and 'EFFT' for Evoked Power Spectrums.

COMPATIBILITY WITH MATLAB R2013 (AND LATER)
* This version has been updated to be compatible with the changes implemented in Matlab R2013.

MINOR BUGS FIXED
* Bug reported up to date has been fixed in this version.
