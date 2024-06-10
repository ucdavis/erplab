ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data. It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis. We have two versions: [ERPLAB Studio](https://github.com/ucdavis/erplab/wiki/ERPLAB-Studio-Manual) is a standalone package that provides an intuitive and easy-to-use graphical user interface. [ERPLAB Classic](https://github.com/ucdavis/erplab/wiki/Manual) is a plugin that runs inside the EEGLAB graphical user interface.
</p>
Click the Wiki icon at the top of the page for documentation, tutorials, and FAQs.
</p>
To ask questions, subscribe to the ERPLAB email list (https://erpinfo.org/erplab-email-list). Bug reports can be submitted via GitHub or by sending an email to erplab-bugreports@ucdavis.edu.

## ERPLAB v11

<p align="center" >
  <a href="https://github.com/ucdavis/erplab/releases/download/11/erplab11.zip"><img src="https://github.com/ucdavis/erplab/blob/master/images/erplab-and-studio-logo.png">
<br/>

  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>


This download contains both [ERPLAB Studio](./ERPLAB-Studio-Manual) (our standalone Matlab program) and [ERPLAB Classic](./Manual) (an EEGLAB plugin). If you are new to ERPLAB, we strongly recommend that you go through the [ERPLAB Studio Tutorial](./ERPLAB-Studio-Tutorial) or ERPLAB Classic Tutorial before trying to analyze your own data.

[Click here](./Installation) for installation instructions.

[Click here](./Compatability-and-Required-Toolboxes) for information about required Matlab toolboxes and compatibility with different versions of Matlab, EEGLAB, Windows, MacOS, and Linux.

We encourage most users to use this latest major version.

## Release Notes

### ERPLAB v11.0 Release Notes

ERPLAB can now be accessed from two different user interfaces: 
- [ERPLAB Classic](./Manual) (our original software, which operates as an EEGLAB plugin)
- [ERPLAB Studio](./ERPLAB-Studio-Manual) (a standalone application that provides a more user-friendly GUI)

ERPLAB Studio makes use of the same underlying code as EEGLAB and ERPLAB Classic. It is essentially a different user interface for the same functions. You will therefore get identical results with ERPLAB Studio and ERPLAB Classic, and scripting is the same for both packages. But ERPLAB Studio is much easier to use.

[Click here](https://www.youtube.com/watch?v=lIaKVQ9DD6E) for a 2-minute video overview of ERPLAB Studio. 

The most commonly used EEGLAB functions are available from within ERPLAB Studio. For example, you can import EEG data into ERPLAB Studio, filter the EEG, apply ICA for artifact correction, etc. If you need an EEGLAB function that is not implemented within ERPLAB Studio, you can apply that function using the EEGLAB GUI or a script.

If you are already familiar with ERPLAB, you can rapidly learn how to use ERPLAB Studio with our [Transition Guide](). If you are new to ERPLAB, please go through the [ERPLAB Studio Tutorial](./ERPLAB-Studio-Tutorial) before attempting to process your own data. Once you understand the basics of ERPLAB Studio, you can get detailed information about the individual processing steps in the [ERPLAB Studio Manual](./ERPLAB-Studio-Manual).


### ERPLAB v10.1 Release Notes
Now Includes:
Update to decoding toolbox. By default, beta weights will no longer be saved with MVPC files, dramatically reducing file size. 

MVPCset and BESTset commands will now be saved into EEG working memory history (shown when using the function eegh).

Various quality of life changes and bug fixes across ERPLAB.


### ERPLAB v10.04 Release Notes
Now Includes:

ERP Decoding routine: Users can now apply multivariate-pattern classification routines to binned and epoched ERP data. See [here](https://github.com/ucdavis/erplab/wiki/Decoding-Tutorial) for more information. 
- NOTE: These routines require at least MATLAB 2020a+ & EEGLAB 2023.1+ in order to work as expected.
- NOTE: These routines also require the following toolboxes: Matlab Statistics and Machine Learning Toolbox, Matlab Parallel Processing Toolbox (recommended)

Advanced ERP Wave Viewer: Plotting ERP waveforms are easier than ever using "ERP Wave Viewer". See:  ERPLAB > Plot ERPs > Advanced ERP Waveform Viewer (Beta) 


## ERPLABv9.20 Release Notes
Now Includes:
Create Artificial Waveform Viewer routine: Users can simulate a variety of waveforms to be saved as ERP files (.erp). See documentation [here](https://github.com/lucklab/erplab/wiki/Create-an-Artificial-ERP-Waveform). 

New options for adding noise to data via EEG and ERP channel operations (see [here](https://github.com/lucklab/erplab/wiki/EEG-and-ERP-Channel-Operations#example-of-adding-simulated-noise)). 

Users may now shift string event codes in time in addtion to numeric event codes (see Preprocess EEG > Shift Event Codes (continuous EEG)). 

Various bug fixes across ERPLAB.


### ERPLAB v9.10 Release Notes
Now includes: 
Updated Data Quality (DQ) metrics specifications on averaged ERP waveforms, including a new metric: SD across trials. 

A new DQ metric for continuous EEG: [Spectral Data Quality (continuous EEG)](https://github.com/lucklab/erplab/wiki/Spectral-Data-Quality-(continuous-eeg))

Various bug fixes concerning bootstrapped SMEs, filtering, and EEG channel operations. 

### ERPLAB v9.00 Release Notes
Note: ERPLAB v9.00 is the recommended version for use with best practices in ERP data processing and analyses as outlined in Dr. Steven J Luck's new Applied Event-Related Potential Data Analysis e-book [here](https://socialsci.libretexts.org/Bookshelves/Psychology/Book%3A_Applied_Event-Related_Potential_Data_Analysis_(Luck)).

_Now includes:_
Ability to low-pass filter prior to marking EEG segments with all artifact detection routines (data is not saved with the filter).

Ability to calculate Data Quality measures (e.g. analytic SME) on multiple binned and epoched EEGset files prior to creating ERPs. 
-More information about the SME can be found [here](https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics).
-See Applied Event-Related Potential Data Analysis e-book [here](https://socialsci.libretexts.org/Bookshelves/Psychology/Book%3A_Applied_Event-Related_Potential_Data_Analysis_(Luck)) for best-practices on this approach. 

Various fixes to the GUI layouts for many routines (e.g. "Delete Time Segments" for EEG processing). 

- Older [release Notes can be found here](https://github.com/lucklab/erplab/wiki/Release-Notes)


## ERPLAB Help

ERPLAB tutorial, manual, and other documentation can be found on the [ERPLAB wiki, here](https://github.com/lucklab/erplab/wiki).
