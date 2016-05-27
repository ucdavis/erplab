
# ERPLAB
ERPLAB Toolbox is a free, open-source Matlab package for analyzing ERP data.  It is tightly integrated with [EEGLAB Toolbox](http://sccn.ucsd.edu/eeglab/), extending EEGLAB’s capabilities to provide robust, industrial-strength tools for ERP processing, visualization, and analysis.  A graphical user interface makes it easy for beginners to learn, and Matlab scripting provides enormous power for intermediate and advanced users. 
<br/>
<br/>


## ERPLAB v5.1.1.0 - Download Latest Release Version


<p align="center" >
  <a href="https://github.com/lucklab/erplab/releases/download/5.1.1.0/erplab-5.1.1.0.zip"><img src="https://cloud.githubusercontent.com/assets/8988119/8532773/873b2af0-23e5-11e5-9869-c900726713a2.jpg">
<br/>
  
  <img src="https://cloud.githubusercontent.com/assets/5808953/8663301/1ff9a26a-297e-11e5-9e15-a7085569058f.png" width=300px >
 </a>
</p>

To install ERPLAB v5.1.1.0, download the zip file (linked above), unzip and place the folder in the 'plugins' folder of your existing EEGLAB installation (so something like /Users/steve/Documents/MATLAB/eeglab13_5_4b/plugins/erplab_5.1.1.0/eegplugin_erplab.m exists). [Additional installation help can be found here](https://github.com/lucklab/erplab/wiki).

To run ERPLAB, ensure that the correct EEGLAB folder is in your current Matlab path, and run **eeglab** as a command from the Matlab Command Window. [Find our tutorial here.](http://erpinfo.org/erplab/erplab-documentation).

We encourage most users to use this latest major version.

----
## ERPLAB compatibility

We anticipate that ERPLAB will work with most recent OSs, Matlab versions and EEGLAB versions.

We do recommend a 64 bit OS, 64 bit Matlab, and at least 4 GB RAM. Most modern computers meet this. The Matlab Signal Processing Toolbox is required.

The old v11 of EEGLAB is *not* recommended.

Find installation help [here](http://erpinfo.org/erplab)

### ERPLAB compatibility table

Here is a list of some confirmed-working environments for ERPLAB.

**ERPLAB v5.1.1.0**

**OS** | **Matlab** | **EEGLAB** | Working?
--- | --- | --- | ---
Mac OS X 10.11.4 'El Capitan'	| Matlab R2015a |	EEGLAB v13.5.4b |	✓
Mac OS X 10.11.4 'El Capitan' |	Matlab R2016a |	EEGLAB v13.5.4b	 | ✓ *
Windows 7	| Matlab R2014a | EEGLAB v13.5.4b |	✓
Windows 8.1 |	Matlab R2014a |	EEGLAB v13.5.4b	| ✓
Ubuntu 14.04 LTS |	Matlab R2014a |	EEGLAB v13.5.4b |	✓

``*`` - (but with some non-critical warnings)
<br/>
<br/>
<br/>
------


# ERPLAB v5.1.1.0 Release Notes

With ERPLAB v5.1.1.0, we include a variety of user-interface improvements, bug-fixes, and improvements to existing functions. Among these, we have:

### - Improved epoch subset selection tool

When selecting epochs for further analysis with 'Compute Average ERPs', the epoch 'Assitant' window can help choose specific epochs. This tool make it easier to do things like separately averaging the first and last halves of a session, or selecting random subsets of trials for split half comparisons.

This Assistant has been updated and bug-fixed, with new options to save a list of the non-selected epochs, write this to a file, revised GUI options, and clear instruction these functions do.



### - ERPLAB 'Working Memory' options

ERPLAB saves some data about user-interface settings in a 'Working Memory' structure. We include new functionality to save the state of this memory, and to load previously-saved erpmem. We have new GUI elements in ERPLAB -> Settings -> to clear, save or load erpmem state.


### - Fixed the ERP plot 'AutoYLim' problem

When plotting ERPs, there was an occasional issue where setting the YScale via the GUI options could give a plot with 'AutoYLim' being off, but the equivalent script command would leave 'AutoYLim' on.

A workaround for the this was to include 'AutoYLim', 'off' in the scripting command. We have now changed the default behaviour of pop_ploterps() to act more as expected, and so 'AutoYLim' is taken to be 'off' by default when Yscale is specified via script.

As such, 'AutoYLim', 'off' no longer needs to be set in scripts in cases like this, but scripts including these arguments will still work as expected.


### - ERPLAB system diagnostic

In order to check some requirements for ERPLAB, we have a simple new function to report the system status:
```matlab
[allok, systemchk_table] = systemchk_erplab
```

This can useful for bug reporting and verification that the current computer meets the requirements.


### - High-resolution displays

As well as interface scaling on Mac, the appearence is now also improved in non-Mac high-resolution displays.

----
### Bug Fixes

[Bug fixes as detailed here](https://github.com/lucklab/erplab/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aclosed)
