Read me for Downloading/Installing EEGLAB and ERPLAB

First Download EEGLAB online via the following link:
http://sccn.ucsd.edu/eeglab/install.html

Make sure you install the latest version on their FTP server.
On July 9th, 2010, their latest version was 8.0.3.5b

Then, download ERPLAB for the latest beta version via the site
http://www.erpinfo.org/

As of right now, the beta version is still being updated. If you would
like a copy of the ERPLAB toolbox, please give Javier Lopez an e-mail
at javlopez@ucdavis.edu.

Please indicate who you are and any additional information so that
Javier can respond to you in a timely fashion.

------------------------------------------------------------------------
Installing EEGLAB:
Unzip the file if necessary and then place the folder into the
applications folder or whichever the directory that the MATLAB folder
corresponds. You may also place this folder in your applications folder
if you have no direct MATLAB folder. 

E.g If you have MATLAB2010, you
are using a MAC, and can only view MATLAB's viewing the package contents
indirectly, then place the EEGLAB folder in your Applications folder. You will
have to set the path to here later

Installing ERPLAB:
Unzip the file if necessary and place the folder anywhere into EEGLAB's
"plugin" folder.

Replace: the eegplot.m in the directory of
eeglabxx/functions/sigprocfunc/

Check: If the folder version number of erplab matches version number in the file called eegplugin_erplab.m which located in ergplab_BETA_x.x.x.xx/eegplugin_erplab.m. 

	You can open this file using MATLAB. Go to line 191 and make sure that the version is the same as the folder. If not, you can either manually change this yourself, or if you think you received an older version than you were supposed to receive, please let us know.
       
Once you have done these couple of things, load MATLAB and do the following:
Go to File > Set Path...

Click on Default *Note, if you are using additional plug-ins, you will have to add them to your path as well

Click on Add with Subfolders...
Open the eeglabxx folder *where xx represents the version number

Highlight the eeglabxx\external (anything with external after it)

Click on Remove and Save

Restart up MATLAB again
------------------------------------------------------------------------

Document Created by  : Stanley Huang
Document Created on  : July 9th, 2010
Document Modified on : July 29th, 2010
Document Created in  : UC Davis Luck lab - 267 Cousteau Pl. Davis, CA 95616
