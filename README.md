ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users.

## ERPLAB v9.00

<p align="center" >
  <a href=""><img src="https://cloud.githubusercontent.com/assets/8988119/8532773/873b2af0-23e5-11e5-9869-c900726713a2.jpg">
<br/>

  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>


To install ERPLAB v9.00, download the zip file (linked above), unzip and place the folder in the 'plugins' folder of your existing [EEGLAB](https://sccn.ucsd.edu/eeglab/download.php) installation (e.g.  `/Users/Steve/Documents/MATLAB/eeglab2019_1/plugins/erplab/`). More [installation help can be found here](https://github.com/lucklab/erplab/wiki/Installation).

To run ERPLAB, ensure that the correct EEGLAB folder is in your current Matlab path, and run `eeglab` as a command from the Matlab Command Window. [Find our tutorial here.](https://github.com/lucklab/erplab/wiki/Tutorial)

We encourage most users to use this latest major version.


---
## ERPLAB compatibility

We anticipate that ERPLAB will work with most recent OSs, Matlab versions and EEGLAB versions.

- The Matlab Signal Processing Toolbox is required
- [EEGLAB v2021 or later](https://sccn.ucsd.edu/eeglab/download.php) is recommended.

Find [more ERPLAB installation help here](http://erpinfo.org/erplab).


### ERPLAB compatibility table

Here is a list of some confirmed-working environments for ERPLAB.

**ERPLAB v9.0+ works with...**
| **OS** | **Matlab** | **EEGLAB** | Working? |
| --- | --- | --- | --- |
| Mac OS 10.15.7 'Catalina' | Matlab R2020b | EEGLAB v2021.1 | ✓ |
| Mac OS 10.15 'Catalina' | Matlab R2016a | EEGLAB v2019_1  | ✓ | 
| Mac OS 10.13.5 'High Sierra' | Matlab R2018a | EEGLAB v14.1.2 | [✓ with Matlab update]
(https://www.mathworks.com/downloads/web_downloads/download_update?release=R2018a&s_tid=ebrg_R2018a_2_1757132&s_tid=mwa_osa_a) |
| Mac OS 10.13.5 'High Sierra' | Matlab R2015a | EEGLAB v14.1.2 | ✓ |
| Windows 10 | Matlab R2020b | EEGLAB v2021.1 | ✓ |
| Windows 10 | Matlab R2015a | EEGLAB v13.5.4b | ✓ |
| Windows 10 | Matlab R2016a | EEGLAB v2019_1 | ✓ |
| Ubuntu 18.04 LTS | Matlab R2019a | EEGLAB v2020 | ✓ |
| Ubuntu 18.04 LTS | Matlab R2019a | EEGLAB v2019_1 | ✓ |

ERPLAB should work with most modern OSs, Matlab versions, and EEGLAB releases. Let us know if you see any incompatibility.

<br/>
<br/>

## Release Notes
### ERPLAB v9.00 Release Notes
Note: ERPLAB v9.00 is the recommended version for use with best practices in ERP data processing and analyses as outlined in Dr. Steven J Luck's new Applied Event-Related Potential Data Analysis e-book [here](https://socialsci.libretexts.org/Bookshelves/Psychology/Book%3A_Applied_Event-Related_Potential_Data_Analysis_(Luck)).

_Now includes:_
Ability to low-pass filter prior to marking EEG segments with all artifact detection routines (data is not saved with the filter).

Ability to calculate Data Quality measures (e.g. analytic SME) on multiple binned and epoched EEGset files prior to creating ERPs. 
-More information about the SME can be found [here](https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics).
-See Applied Event-Related Potential Data Analysis e-book [here](https://socialsci.libretexts.org/Bookshelves/Psychology/Book%3A_Applied_Event-Related_Potential_Data_Analysis_(Luck)) for best-practices on this approach. 

Various fixes to the GUI layouts for many routines (e.g. "Delete Time Segments" for EEG processing). 

### ERPLAB v8.30 Release Notes
Now includes:

The ability to operate multiple Data Quality windows (See "Data Quality" introduced in v8.20). 

Data quality windows have newly added features (e.g. outliers in each channel and time window). 

Updated "Delete Time Segments" pre-processing tool to include the option to ignore boundary events. 

Post-Artifact Detection Epoch Interpolation feature. See [here](https://github.com/lucklab/erplab/wiki/Artifact-Detection-in-Epoched-Data#ERPLAB-Post-Artifact-Detection-Epoch-Interpolation).

Standard Measurement Error (SME) bootstrapping functions updated for use in custom scripts. 
-More information about the SME can be found [here ](https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics).

Various bug fixes with ERP plotting and measurements. 


### ERPLAB v8.02 Release Notes
ERPLAB v8.02 adds a colormap to help visualize the Data Quality Table info

### ERPLAB v8.01 Release Notes
ERPLAB v8.01 adds binorgEEG functions to v8.0

### ERPLAB v8.0 Release Notes

With ERPLAB v8.0, we include new tools for [assessing measures of Data Quality Metrics in EEG ERP data](https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics).

- Data Quality Metrics
   - The ERP Averager will calculate these Data Quality Metrics by default
   - A new submenu in the ERPLAB menu ('Data Quality options') allows access from the EEGLAB-ERPLAB GUI.
   - A new table interface to show all the data quality information from an ERP set with `DQ_Table_GUI(ERP)` or through the above GUI menu option.
   - These data quality metrics can be summarized on the Command Window, saved to Mat structure or exported to Excel, or plotted in the above interactive table.
   - The data quality information and metadata is stored in a new structure, ERP.dataquality
<br/>

- New options for calculating, viewing, and saving, frequency spectra, in the `compute_fourier(EEG)` [function](https://github.com/lucklab/erplab/wiki/Generate-Frequency-Spectra)

<br/>

- Various [bugfixes](https://github.com/lucklab/erplab/commits/master)

- Older [release Notes can be found here](https://github.com/lucklab/erplab/wiki/Release-Notes)


## ERPLAB Help

ERPLAB tutorial, manual, and other documentation can be found on the [ERPLAB wiki, here](https://github.com/lucklab/erplab/wiki).
