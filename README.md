ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users. Click the Wiki icon at the top of the page for documentation, tutorials, and FAQs.
</p>
To ask questions, subscribe to the ERPLAB email list (https://erpinfo.org/erplab-email-list). Bug reports can be submitted via GitHub or by sending an email to erplab-bugreports@ucdavis.edu.

## ERPLAB v10.04

<p align="center" >
  <a href="https://github.com/ucdavis/erplab/releases/download/10.0/erplab10.04.zip"><img src="https://cloud.githubusercontent.com/assets/8988119/8532773/873b2af0-23e5-11e5-9869-c900726713a2.jpg">
<br/>

  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>


To install ERPLAB v10.04, download the zip file (linked above), unzip and place the folder in the 'plugins' folder of your existing [EEGLAB](https://sccn.ucsd.edu/eeglab/download.php) installation (e.g.  `/Users/Steve/Documents/MATLAB/eeglab2019_1/plugins/erplab/`). More [installation help can be found here](https://github.com/lucklab/erplab/wiki/Installation).

To run ERPLAB, ensure that the correct EEGLAB folder is in your current Matlab path, and run `eeglab` as a command from the Matlab Command Window. If you are new to ERPLAB, we strongly recommend that you go through the [ERPLAB Tutorial](https://github.com/lucklab/erplab/wiki/Tutorial) before using ERPLAB with your own data.

We encourage most users to use this latest major version.


---
## Compatibility and Required Toolboxes

We anticipate that ERPLAB will work with most recent OSs, Matlab versions and EEGLAB versions.

- The [Matlab Signal Processing Toolbox](https://www.mathworks.com/products/signal.html) is required.
- [EEGLAB v2021 or later](https://sccn.ucsd.edu/eeglab/download.php) is almost always necessary.

However, in order to use the latest MVPC routines (see [here](https://github.com/ucdavis/erplab/wiki/Decoding-Tutorial)), Matlab versions and EEGLAB versions must be recent. In addition, some MATLAB toolboxes are required. 
- Matlab 2020b + is REQUIRED for MVPC routines.
- EEGLAB 2023.1 + is REQUIRED for MVPC routines.
- The [Matlab Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html)
- The [Matlab Parallel Processing Toolbox](https://www.mathworks.com/products/parallel-computing.html) (recommended)

Find [more ERPLAB installation help here](http://erpinfo.org/erplab).


### ERPLAB compatibility table

Here is a list of some confirmed-working environments for ERPLAB.

**ERPLAB v10.0+ works with...**
| **OS** | **Matlab** | **EEGLAB** | Working? |
| --- | --- | --- | --- |
| Mac OS 14.2.1 'Sonoma'  | Matlab R 2023a | EEGLAB v2023.1 | ✓|
| Mac OS 11.7.6 'Big Sur'  | Matlab R 2020a | EEGLAB v2023.0 | ✓|
| Mac OS 10.15.7 'Catalina' | Matlab R2020b | EEGLAB v2023.0 | ✓ |
| Mac OS 10.15 'Catalina' | Matlab R2016a | EEGLAB v2019_1  | ✓ | 
(https://www.mathworks.com/downloads/web_downloads/download_update?release=R2018a&s_tid=ebrg_R2018a_2_1757132&s_tid=mwa_osa_a) |
| Mac OS 10.13.5 'High Sierra' | Matlab R2015a | EEGLAB v14.1.2 | ✓ |
| Windows 10 | Matlab R2021a | EEGLAB v2023.0 | ✓ |
| Windows 10 | Matlab R2020b | EEGLAB v2021.1 | ✓ |
| Ubuntu 18.04 LTS | Matlab R2019a | EEGLAB v2020 | ✓ |
| Ubuntu 18.04 LTS | Matlab R2019a | EEGLAB v2019_1 | ✓ |

ERPLAB should work with most modern OSs, Matlab versions, and EEGLAB releases. Let us know if you see any incompatibility.
**Starting in ERPLAB v10.0, MATLAB'S "App Designer" was the default GUI system used for the MVPC routines and require at least MATLAB 2020a+ & EEGLAB 2023.1+ in order to work as expected.** 

<br/>
<br/>

## Release Notes

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
