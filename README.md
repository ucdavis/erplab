<img src="https://github.com/lucklab/erplab/blob/master/images/logoerplab6.jpg" 
 height="252px" width="180px" 
 alt="ERPLAB Logo"
 align="left" />

## ERPLAB
ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users. 
<br/>
<br/>
<br/>
### Requirements
- Matlab
  - We recommend versions 2010a, 2012a, 2014b, 2015
  - **Matlab's Signal Processing Toolbox is required.**

- EEGLAB Toolbox
  -ERPLAB has mainly been tested with versions 9.0.8.6b, and 12.01.0b of EEGLAB. We recommend versions 9 and 12.  
  - **Do not use version 11 of EEGLAB**

- Operating System
  - ERPLAB has mainly been tested with Mac OS X and Windows.  
  - It should work with Linux, but this has not been extensively tested.
  - EEGLAB and ERPLAB work best if you have plenty of RAM. We recommend at least 8 GB. Note, however, that your computer will not be able to take advantage of more than 4 GB of RAM unless you have a 64-bit version of Matlab installed (along with a 64-bit operating system).

<br/>
------
ERPLAB 5.0.0.0 Release Notes

<p align="center" >
  <a href="https://github.com/lucklab/erplab/releases/download/5.0.0.0/erplab-5.0.0.0.zip">
  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>

### Matlab 2014b/2015 Compatible
ERPLAB has been updated to handle Matlab's new graphics system that was introduced in Matlab R2014b and 2015. This fixes issues when plotting ERPs via `plot_erps`. 


</br>
----
### New BDF Visualizer tool
We're introducting a new tool to help you create and test your bin descriptor files (BDF-files). The `BDF Visualizer` tool allows you to write bin descriptor definitions and quickly see the results on an event-list. You can load in your own event lists through either EEG-sets or through your saved event-list files. 
![screen shot 2015-07-01 at 2 56 19 pm](https://cloud.githubusercontent.com/assets/5808953/8465785/58d2b404-2001-11e5-81e0-f048c0253962.png)


</br>
----
### New Power Spectrum Averaging
When averaging EEG data, you can now also calculate the power spectrum (total and evoked) using the same epochs selected for averaging. An optional Taper function was also added to minimize edge effects during FFT computation and/or selecting an epoch's subwindow to compute the power spectrum.
![averager-power_spectra_highlight](https://cloud.githubusercontent.com/assets/5808953/8528776/2b576160-23ca-11e5-89e2-e9dac4e801d1.png)


</br>
----
### New Plot Scalp Map Options
Plot Scalp Maps has more options for displaying the maps, legends, and electrodes labels.
![screen shot 2015-07-06 at 10 38 03 am](https://cloud.githubusercontent.com/assets/5808953/8528886/1e6bcce2-23cb-11e5-9beb-689b240a2f6e.png)

</br>
----
### Update PDF Exporting
Exporting ERPLAB's PDF images is now compatible with newer Matlab versions (2014b and above)


</br>
----
### Measurement Labelling
In the ERP Measurement Tool, a new measurement label field is now available for exporting measured values for both long and wide format.
![measurement_tool_-_output_format_highlighted](https://cloud.githubusercontent.com/assets/5808953/8529420/c4fa4b30-23ce-11e5-869e-a3b4419c0990.png)


</br>
----
### Bug Fixes

[12 bug fixes as detailed here](https://github.com/lucklab/erplab/issues?q=is%3Aissue+is%3Aclosed+milestone%3A%22ERPLAB+5.0.0.0%22)
