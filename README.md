
ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users.

## ERPLAB v6.1.3

<p align="center" >
  <a href="https://github.com/lucklab/erplab/releases/download/6.1.2/erplab6.1.2.zip"><img src="https://cloud.githubusercontent.com/assets/8988119/8532773/873b2af0-23e5-11e5-9869-c900726713a2.jpg">
<br/>

  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>

To install ERPLAB v6.1.3, download the zip file (linked above), unzip and place the folder in the 'plugins' folder of your existing [EEGLAB](https://sccn.ucsd.edu/eeglab/download.php) installation (e.g.  `~/Documents/MATLAB/eeglab13_6_4b/plugins/erplab6.1.3/`). [Additional installation help can be found here](https://github.com/lucklab/erplab/wiki/Installation).

To run ERPLAB, ensure that the correct EEGLAB folder is in your current Matlab path, and run **eeglab** as a command from the Matlab Command Window. [Find our tutorial here.](http://erpinfo.org/erplab/erplab-documentation).

We encourage most users to use this latest major version.

---

## ERPLAB compatibility

We anticipate that ERPLAB will work with most recent OSs, Matlab versions and EEGLAB versions.

We do recommend a 64 bit OS, 64 bit Matlab, and at least 4 GB RAM. Most modern computers meet this. The Matlab Signal Processing Toolbox is required.

Caution: EEGLAB v11 is _not_ recommended.

Find installation help [here](http://erpinfo.org/erplab)

### ERPLAB compatibility table

Here is a list of some confirmed-working environments for ERPLAB.

**ERPLAB v6.1.2**

| **OS** | **Matlab** | **EEGLAB** | Working? |
| --- | --- | --- | --- |
| Mac OS X 10.11.5 'El Capitan' | Matlab R2015a | EEGLAB v13.5.4b | ✓ |
| Mac OS X 10.11.4 'El Capitan' | Matlab R2016a | EEGLAB v13.5.4b | ✓ * |
| Windows 7 | Matlab R2014a | EEGLAB v13.5.4b | ✓ |
| Windows 8.1 | Matlab R2014a | EEGLAB v13.5.4b | ✓ |
| Windows 10 | Matlab R2015a | EEGLAB v13.5.4b | ✓ |
| Ubuntu 14.04 LTS | Matlab R2014a | EEGLAB v13.5.4b | ✓ |

`*` - (but with some non-critical warnings)
<br/>
<br/>

## <br/>

# ERPLAB v6.1.3 Patch
Minor bugfixes, including:
- Cleaned up the Measurement Viewer text and options
- Measurement Viewer helper text now only shown when relevant

# ERPLAB v6.1.2 Patch
Minor bugfixes, including:
- Fixed BDF Library url-link in BDF-Visualizer
- Swapped artifact and user-flag display in BDF-Visualizer

# ERPLAB v6.1.1 Patch
Minor bugfixes, including:
- Shift Event Codes GUI fix - now doesn't crash on launch.
- Adopted [Major].[Minor].[Patch] version numbers, this being v6.1.1, with backward-compatible file loading. Note - from v6.0, we no longer indicate the file type usage in the version number, and this is now always taken to be 1.


-----
# ERPLAB v6.1 Release Notes

## Shift Event Codes
The new Shift Event Codes tool has been updated so that when you shift event codes beyond a continuous EEG boundary marker (e.g. -99, "boundary" event codes) then that code will be deleted

## New Github-based documentation & ERPInfo.org website
We have fully migrated of all our ERPLAB documentation (i.e. manual, tutorial, etc) now to Github, and so have now updated the help links in ERPLAB.


-----


# ERPLAB v6.0 Release Notes

With ERPLAB v6.0, we include a variety of new features, user-interface improvements, bug-fixes, and improvements to existing functions. Among these, we have:


### - Current Source Density Tool

EEG or ERP data can be used to compute an estimate of the Current Source Density (CSD). We include new functions to take data loaded in ERPLAB (either EEG or ERP) and compute the CSD data. We use CSD methods from Jürgen Kayser (from the [CSD Toolbox](http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/)).

These tools can be found in the new 'ERPLAB -> Data Transformations' menu. A new ERPLAB dataset is generated, with CSD data in the place of EEG/ERP data.

Find [CSD documentation here](https://github.com/lucklab/erplab/wiki/Current-Source-Density-(CSD)-tool)


### - Fractional peak measurement can now be offset (post-peak) as well as onset (pre-peak)

In the ERP Measurement tool, ERPLAB can record measurements of local peaks and the time of a fractional peak, like 50% peak. Previously, this fractional peak measurement was taken from the 'onset' of the peak, before the peak. In v6.0, ERPLAB also has an option to measure the fractional peak 'offset', the 50% peak value after the peak.


### - ERPLAB documentation on GitHub

For more easy editing, ERPLAB documentation has been moved to a [wiki here](https://github.com/lucklab/erplab/wiki).

### - Continuous EEG Preprocessing tools

#### - Delete Time Segments tool
With the new `Delete Time Segments` tool you can now remove segments of irrelevant continuous EEG data, like data recorded during breaks in the experiment.

#### - Time delay event code shifting tool
With the new `Shift Event Codes` tool you can now time-shift specific event codes either to either earlier or later timepoints in the EEG data. This tool was created to counter the delay between visual stimulus onset on the monitor and its corresponding event code recorded in the EEG data.

#### - Selective Electrode Interpolation tool
The new `Selective Electrode Interpolation` tool is based off of EEGLAB's own interpolation function and adds the ability to specify which electrodes to use as input for interpolation.


----
### Bug Fixes

[Bug fixes as detailed here](https://github.com/lucklab/erplab/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aclosed)
