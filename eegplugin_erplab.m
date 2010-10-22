% Usage:
%   >> eegplugin_erplab(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
%
% -- Write erplab at command window for help --
%
% Notes:
% This plugins consist of the following Matlab files:
%
% pop/erp function                 |    GUI                           |   subroutine
% -----------------------------------------------------------------------------------------------
%
% pop_averager.m...................>>...averagerGUI.m.................>>...averager.m
% pop_basicfilter.m................>>...basicfilterGUI2.m.............>>...basicfilter.m / filter_tf.m
% pop_binlister.m..................>>...menuBinListGUI.m..............>>...binlister.m / parseles.m / decodebdf.m
% pop_binoperator.m................>>...binoperGUI.m..................>>...binoperator.m
% pop_creabasiceventlist.m.........>>...creabasiceventlistGUI.m.......>>...creaeventinfo.m / creaeventlist.m
% pop_creaeventlist.m..............>>...(none)........................>>...creaeventinfo.m / creaeventlist.m
% pop_editeventlist.m..............>>...assigncodesGUI.m..............>>...creaeventinfo.m / creaeventlist.m
% pop_eegchanoperator.m............>>...chanoperGUI.m.................>>...eegchanoperator.m
% pop_eraseventcodes.m.............>>...(none)........................>>...eraseventcodes.m
% pop_erp2asc.m....................>>...(none)........................>>...erp2asc.m
% pop_erpchanoperator.m............>>...chanoperGUI.m.................>>...erpchanoperator.m
% pop_erphelp.m....................>>...(none)........................>>...(none)
% pop_export2text.m................>>...export2textGUI.m..............>>...(none)
% pop_exporteegeventlist.m.........>>...(none)........................>>...creaeventlist.m
% pop_exporterpeventlist.m.........>>...(none)........................>>...exporterpeventlist.m
% pop_fig2pdf.m....................>>...(none)........................>>...save2pdf.m (**)
% pop_filterp.m....................>>...basicfilterGUI2.m.............>>...filterp.m
% pop_fourieeg.m...................>>...fourieegGUI.m.................>>...fourieeg.m
% pop_fourierp.m...................>>...fourieegGUI.m.................>>...fourierp.m
% pop_geterpvalues.m...............>>...geterpvaluesGUI.m.............>>...geterpvalues.m
% pop_importeegeventlist.m.........>>...(none)........................>>...readeventlist.m
% pop_importerpeventlist.m.........>>...eventlist2erpGUI..............>>...readeventlist.m
% pop_insertcodearound.m...........>>...insertcodearoundGUI.m.........>>...importerpeventlist.m / insertcodearound.m
% pop_insertcodeonthefly.m.........>>...insertcodeonthefly2GUI........>>...insertcodeonthefly.m
% pop_lindetrend.m.................>>...(none)........................>>...lindetrend.m / lindetrenderp.m
% pop_loadmerplabset.m.............>>...(none)........................>>...pop_loadset.m (*)
% pop_ploterps.m...................>>...ploterpGUI.m..................>>...ploterps.m
% pop_savemyerp.m..................>>...savemyerpGUI.m................>>...saveERP.m
% pop_scalplot.m...................>>...scalplotGUI.m.................>>...topoplot.m (*)
% pop_squeezevents.m...............>>...(none)........................>>...squeezevents.m
% pop_summarizebins.m..............>>...(none)........................>>...summarizebins.m
%
% pop_appenderp.m..................>>...appenderpGUI.m'...............>>...(none)
% pop_artbarb.m....................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artblink.m...................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artderiv.m...................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artdiff.m....................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artextval.m..................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artmwppth.m..................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_artstep.m....................>>...artifactmenuGUI...............>>...markartifacts.m
% pop_bdfrecovery.m................>>...(none)........................>>...(none)
% pop_blcerp.m.....................>>...blcerpGUI.m'..................>>...(none)
% pop_clearerpchanloc.m............>>...(none)........................>>...(none)
% pop_deleterpset.m................>>...(none)........................>>...(none)
% pop_epochbin.m...................>>...epochbinGUI.m'................>>...pop_epoch.m (*)
% pop_gaverager.m..................>>...grandaveragerGUI.m'...........>>...(none)
% pop_loaderp.m....................>>...(none)........................>>...(none)
% pop_overwritevent.m..............>>...overwriteventGUI.m'...........>>...update_EEG_event_field.m
% pop_resetrej.m...................>>...resetrejGUI.m'................>>...resetflag.m (optional)
% pop_rt2text.m....................>>...(none)........................>>...(none)
% pop_str2code.m...................>>...str2codeGUI.m'................>>...(none)
% pop_summary_AR_eeg_detection.m...>>...(none)........................>>...summary_rejectflags.m (auxiliar)
% pop_summary_AR_erp_detection.m...>>...(none)........................>>...(none)
% pop_summary_rejectfields.m.......>>...(none)........................>>...(none)
%
% (*)  EEGLAB's function
% (**) Gabe Hoffmann (Matlab Central)
%
%
% Additional auxiliary function
% -----------------------------------------------------------------------------------------------
%
% Bcolorerplab.m
% Fcolorerplab.m
% areaerp.m
% askquest.m
% askquest3.m
% askquestpoly.m
% avgbin.m
% avgchan.m
% bdf2struct.m
% bepoch2EL.m
% binitem2epoch.m
% borrowchanloc.m
% builtERPstruct.m
% changebinlabel.m
% checkERP.m
% checkchannel.m
% checkformulas.m
% ciplot.m (Raymond Reynolds. Modified by JLC)
% creabinlabel.m
% delerpchan.m
% deletechan.m
% derivaeeg.m
% dispcond.m
% doubleresponsekiller.m
% eegartifacts.m
% erp2memory.m
% erph.m
% erphistory.m
% erplab.m
% erplabworkspace.m
% erptimeshift.m
% erpworkingmemory.m
% errorfound.m
% errorhunter.m
% exportvalues.m
% exportvalues2xls.m
% getallerpstate.m
% geterplabcolor.m
% geterplabversion.m
% geteventinfo.m
% getlastformulas.m
% halfamp.m
% inputvalue.m
% insertcodeperi.m
% iseegstruct.m
% iserpstruct.m
% isrepeated.m
% loadrandimage.m
% mahaleeg.m
% medianbin.m
% mgfperp.m
% old2newerp.m
% olderpscan.m
% onlybinlabel.m
% painterplab.m
% pasteeventlist.m
% preloadERP.m
% resetflag.m
% save2pdf.m
% savelastformulas.m
% sgolayfilter.m
% shadedplot.m
% sorteegchannels.m
% sorteegeventfields.m
% sorterpstruct.m
% sorteventliststruct.m
% splitbrain.m
% stdbin.m
% strtrimx.m
% summary_rejectflags.m
% swapbindata.m
% swapbinlabel.m
% update_EEG_event_field.m
% update_events_at_EVENTLIST.m
% update_rejEfields.m
% updatemenuerp.m
% vect2colon.m
% vogue.m
% wavgbin.m
% window2sample.m
% zeroaxes.m (Andrew Knight. Modified by JLC)
%
%
% Author: Javier Lopez-Calderon & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2007-2010

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function currvers = eegplugin_erplab(fig, trystrs, catchstrs)

erplabver = '1.0.0.33'; % Tribute to the 33 Chilean Miners + Psalm95:4
currvers  = ['erplab_' erplabver];

if nargin < 3
        error('eegplugin_erplab requires 3 arguments');
end

%
% add folder to path
%
p = which('eegplugin_erplab', '-all');

if length(p)>1
        fprintf('\nERPLAB WARNING: More than one ERPLAB folder was found.\n\n');
end
p = p{1};
p = p(1:findstr(p,'eegplugin_erplab.m')-1);
if ~exist('pop_binlister.m','file')
        addpath([p currvers]);
end

%
% Check version number against folder name
%
foldernum = regexp(p,'erplab_(\d+\.+\d+\.+\d+\.+\d+)', 'tokens', 'ignorecase');
if ~strcmp(foldernum{:}, erplabver)
        fprintf('\nERPLAB WARNING: ERPLAB''s folder name does not match with the current version number.\n\n')
end

%
% Temp erplab files (backups)
%
dirTemp   = fullfile(p,'erplab_Temp');
filst     = dir(dirTemp);
filenames = {filst.name};

if length(filenames)>2
        recycle on;
        delete(fullfile(dirTemp,'*'))
        fprintf('\nERPLAB WARNING: Temporary files (from your last session) within erplab_Temp folder were sent to recycle bin.\n\n')
end

%-----------------------------memory----------------------------------------------------------------
if exist('memoryerp.erpm','file')==2
        ColorB = erpworkingmemory('ColorB');
        ColorF = erpworkingmemory('ColorF');
else
        ColorB = [0.552941176470588   0.615686274509804   0.741176470588235];
        ColorF = [0 0 0];
end
save(fullfile(p,'memoryerp.erpm'), 'erplabver', 'ColorB', 'ColorF'); % saves erplab version
%---------------------------------------------------------------------------------------------------

%
% struct and vars to workspace
%
ERP              = [];  % Start ERP Structure on workspace
ALLERP           = [];  % Start ALLERP Structure on workspace
ALLERPCOM        = [];
CURRENTERP       = 0;
plotset.ptime    = [];
plotset.pscalp   = [];

assignin('base','ERP',ERP);
assignin('base','ALLERP', ALLERP);
assignin('base','ALLERPCOM', ALLERPCOM);
assignin('base','CURRENTERP', CURRENTERP);
assignin('base','plotset', plotset);

%
% EEGLAB import multiple dataset (Biosig MENU)
%
e_try        = 'try,';
e_catch      = 'catch, eeglab_error; LASTCOM= ''''; clear EEGTMP ALLEEGTMP STUDYTMP; end;';
nocheck      = e_try;
storeallcall = [ 'if ~isempty(ALLEEG) & ~isempty(ALLEEG(1).data), ALLEEG = eeg_checkset(ALLEEG);' ...
        'EEG = eeg_retrieve(ALLEEG, CURRENTSET); eegh(''ALLEEG = eeg_checkset(ALLEEG); EEG = eeg_retrieve(ALLEEG, CURRENTSET);''); end;' ];
ifeeg        =  'if ~isempty(LASTCOM) & ~isempty(EEG),';
e_storeall_nh   = [e_catch 'eegh(LASTCOM);' ifeeg storeallcall 'disp(''Done.''); end; eeglab(''redraw'');'];
cb_loaderplabset     = [ nocheck '[ALLEEG EEG CURRENTSET LASTCOM] = pop_loadmerplabset(ALLEEG, EEG);' e_storeall_nh];

%
%  Create menu import multiple datasets
%
menu_import_erplab = findobj(fig, 'tag', 'import data');
uimenu( menu_import_erplab, 'Label', ['Load multiple EEGLAB/ERPLAB ' erplabver ' datasets'],...
        'CallBack', cb_loaderplabset, 'Separator', 'on');

%---------------------------------------------------------------------------------------------------
%
%                               ERPLAB NEST-MENU
%
% **** ERPLAB at the EEGLAB Main Menu ****
if ~ispc
        posmainfig = get(gcf, 'Position');
        hframe     = findobj('parent', gcf, 'tag', 'Frame1');
        posframe   = get(hframe, 'position');
        set(gcf, 'position', [posmainfig(1:2) posmainfig(3)*1.3 posmainfig(4)]);
        set(hframe, 'position', [posframe(1:2) posframe(3)*1.31 posframe(4)]);
end

menuERPLAB = findobj(fig, 'tag', 'EEGLAB');   % At EEGLAB Main Menu
%---------------------------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        MENU      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      CALLBACKS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic menu callbacks
%
%comTK1    = [trystrs.no_check '[EEG LASTCOM] = pop_polydetrend(EEG);' catchstrs.new_and_hist ];
%comTK2    = [trystrs.no_check '[EEG LASTCOM] = pop_eeglindetrend(EEG);' catchstrs.new_and_hist ];
%comTK3    = '[ERP ERPCOM]  = pop_erplindetrend(ERP); [ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);';
comCLF1   = [trystrs.no_check '[EEG LASTCOM] = pop_creabasiceventlist(EEG);' catchstrs.new_and_hist ];
comCLF2   = [trystrs.no_check '[EEG LASTCOM] = pop_editeventlist(EEG);' catchstrs.new_and_hist ];
comSMMRZ  = [trystrs.no_check '[LASTCOM]     = pop_squeezevents(EEG);' catchstrs.add_to_hist ];
comSLFeeg = [trystrs.no_check '[EEG LASTCOM] = pop_exporteegeventlist(EEG);' catchstrs.add_to_hist ];
comRLFeeg = [trystrs.no_check '[EEG LASTCOM] = pop_importeegeventlist(EEG);' catchstrs.new_and_hist];
comCBL    = [trystrs.no_check '[EEG LASTCOM] = pop_binlister(EEG);' catchstrs.store_and_hist]; % ERPLAB 1.1.920 and higher
comMEL    = [trystrs.no_check '[EEG LASTCOM] = pop_overwritevent(EEG);' catchstrs.new_and_hist];
comEB     = [trystrs.no_check '[EEG LASTCOM] = pop_epochbin(EEG);' catchstrs.new_and_hist];

%
% Channel Operation callback
%
comCHOP   = [trystrs.no_check '[EEG LASTCOM] = pop_eegchanoperator(EEG);' catchstrs.store_and_hist ]; % ERPLAB 1.1.718 and higher

%
% Artifact rejection menu callbacks
%
comAR0     = [trystrs.no_check '[EEG LASTCOM] = pop_artextval(EEG);' catchstrs.new_and_hist]; % Extreme Values
comAR1     = [trystrs.no_check '[EEG LASTCOM] = pop_artmwppth(EEG);' catchstrs.new_and_hist]; % Peak to peak window voltage threshold
comAR3     = [trystrs.no_check '[EEG LASTCOM] = pop_artblink(EEG);' catchstrs.new_and_hist];  % Blink
comAR4     = [trystrs.no_check '[EEG LASTCOM] = pop_artstep(EEG);' catchstrs.new_and_hist];   % Step-like artifacts
comAR6     = [trystrs.no_check '[EEG LASTCOM] = pop_artdiff(EEG);' catchstrs.new_and_hist];   % sample-to-sample diff
comAR7     = [trystrs.no_check '[EEG LASTCOM] = pop_artderiv(EEG);' catchstrs.new_and_hist];  % Rate of change
comAR8     = [trystrs.no_check '[EEG LASTCOM] = pop_artflatline(EEG);' catchstrs.new_and_hist];  % Blocking & flat line

comARSUMM  = [trystrs.no_check '[goodbad histeEF histoflags  LASTCOM] = pop_summary_rejectfields(EEG);' catchstrs.add_to_hist];
comARSUMM2 = [trystrs.no_check '[acce rej histoflags  LASTCOM] = pop_summary_AR_eeg_detection(EEG);' catchstrs.add_to_hist];
comRSTAR   = [trystrs.no_check '[EEG LASTCOM] = pop_resetrej(EEG);' catchstrs.new_and_hist];  % Rate of change

%
% Utilities  callbacks
%
%comEMGH    = [trystrs.no_check '[EEG LASTCOM] = pop_emghunter(EEG);' catchstrs.new_and_hist]; % EMG hunter
comEEC     = [trystrs.no_check '[EEG LASTCOM] = pop_eraseventcodes(EEG);' catchstrs.new_and_hist];
comICOF    = [trystrs.no_check '[EEG LASTCOM] = pop_insertcodeonthefly(EEG);' catchstrs.new_and_hist];
comICLA    = [trystrs.no_check '[EEG LASTCOM] = pop_insertcodearound(EEG);' catchstrs.new_and_hist];
comICTTL   = [trystrs.no_check '[EEG LASTCOM] = pop_insertcodeatTTL(EEG);' catchstrs.new_and_hist];
comEXRTeeg = [trystrs.no_check '[values LASTCOM] = pop_rt2text(EEG);' catchstrs.add_to_hist];
comEXRTerp = ['[values ERPCOM] = pop_rt2text(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];

comEEGBDR  = [trystrs.no_check '[LASTCOM]     = pop_bdfrecovery(EEG);' catchstrs.add_to_hist];
comBCOL    = 'Bcolorerplab' ;
comFCOL    = 'Fcolorerplab' ;

%
% Filter EEG callbacks
%
comBFCD    = [trystrs.no_check '[EEG LASTCOM] = pop_basicfilter(EEG);' catchstrs.new_and_hist];
comPAS     = [trystrs.no_check '[LASTCOM] = pop_fourieeg(EEG);' catchstrs.add_to_hist];

%
% ERP processing callbacks
%
comERPBDR  = ['[ERPCOM]     = pop_bdfrecovery(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comSLFerp  = ['[ERPCOM]     = pop_exporterpeventlist(ERP);'  '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comRLFerp  = ['[ERP ERPCOM] = pop_importerpeventlist(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comAPP     = ['[ERP ERPCOM] = pop_appenderp(ALLERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comRERPBL  = ['[ERP ERPCOM]= pop_blcerp(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comCERPch  = ['[ERP ERPCOM] = pop_clearerpchanloc(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comAVG     = ['[ERP ERPCOM] = pop_averager(ALLEEG);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comBOP     = ['[ERP ERPCOM] = pop_binoperator(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comCHOP2   = ['[ERP ERPCOM] = pop_erpchanoperator(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comPLOT    = ['[ERPCOM]     = pop_ploterps(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comSCALP   = ['[ERPCOM]     = pop_scalplot(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comSAVE    = ['[ERP issave ERPCOM]= pop_savemyerp(ERP,''gui'',''save'');' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comSAVEas  = ['[ERP issave ERPCOM]= pop_savemyerp(ERP, ''gui'',''saveas'');' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comDUPLI   = ['[ERP issave ERPCOM]= pop_savemyerp(ERP,''gui'',''erplab'');' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comEXPAVG  = ['[ERPCOM]     = pop_erp2asc(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comEXPUNI  = ['[ERPCOM]     = pop_export2text(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comLDERP   = ['[ERP ERPCOM] = pop_loaderp(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comDELERP  = ['[ALLERP ERPCOM] = pop_deleterpset(ALLERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comGAVG    = ['[ERP ERPCOM] = pop_gaverager(ALLERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comERPMT   = ['[Amp Lat ERPCOM]  = pop_geterpvalues(ALLERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comEXPPDF  = 'pop_fig2pdf;' ;
comhelpman = 'pop_erphelp;' ;

%
% Filter ERP callbacks
%
comFil    = ['[ERP ERPCOM] = pop_filterp(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comPASerp = ['LASTCOM = pop_fourierp(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];

%
% ERP AR summary callback
%
comARSUMerp1 = ['[tacce trej histoflags  ERPCOM] = pop_summary_AR_erp_detection(ERP);' '[ERP ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);'];
comARSinc1   = [trystrs.no_check '[EEG LASTCOM] = pop_sincroartifacts(EEG);' catchstrs.new_and_hist];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        MAIN      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        MENU      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create ERPLAB menu
%
submenu = uimenu( menuERPLAB, 'Label', 'ERPLAB', 'separator','on','tag','ERPLAB');
set(submenu, 'position', 6); % thanks Arno!

%
% EVENTLIST for EEG menu and submenu
%
ELmenu = uimenu( submenu, 'Label', 'EventList'  , 'tag','EventList'); %'CallBack', comCLF, 'separator', 'on');
uimenu( ELmenu, 'Label',  '<html>Create <b>EEG</b> EventList - Basic'  , 'CallBack', comCLF1);
uimenu( ELmenu, 'Label',  '<html>Create <b>EEG</b> EventList - Advanced'  , 'CallBack', comCLF2);
uimenu( ELmenu, 'Label',  '<html>Import <b>EEG</b> EventList from text file'  , 'CallBack', comRLFeeg);
uimenu( ELmenu, 'Label',  '<html>Export <b>EEG</b> EventList to text file'  , 'CallBack', comSLFeeg);
uimenu( ELmenu, 'Label',  '<html>Summarize current <b>EEG</b> event codes (output at command window)', 'CallBack', comSMMRZ);
mRTs = uimenu( ELmenu, 'Label',  'Export Reaction Times to Text'  , 'tag', 'ReactionTime','ForegroundColor', [0.6 0 0]); % Reaction Times
uimenu( mRTs, 'Label',  '<html>From <b>EEG</b>'  , 'CallBack', comEXRTeeg); % Reaction Times
uimenu( mRTs, 'Label',  '<html>From <b>ERP</b>'  , 'CallBack', comEXRTerp); % Reaction Times

%
% EVENTLIST for ERP submenu
%
uimenu( ELmenu, 'Label',  '<html>Import <b>ERP</b> EventList from text file'  , 'CallBack', comRLFerp, 'separator', 'on');
uimenu( ELmenu, 'Label',  '<html>Export <b>ERP</b> EventList to text file'  , 'CallBack', comSLFerp);
uimenu( submenu, 'Label', 'Assign Bins (BINLISTER)'     , 'CallBack', comCBL);
uimenu( submenu, 'Label', 'Transfer eventinfo to EEG.event (optional)', 'CallBack', comMEL, 'separator', 'on');
uimenu( submenu, 'Label', 'Extract Bin-based Epochs', 'CallBack', comEB, 'separator', 'on');

%
% Channel Operations and Artifact Rejection
%
uimenu( submenu, 'Label', '<html><b>EEG</b> Channel Operations'   , 'CallBack', comCHOP, 'separator','on' );

%
% Filter ERP submenus
%
mFI = uimenu( submenu,    'Label', 'Filter & Frequency Tools' , 'separator', 'on');
uimenu( mFI,'Label', '<html>Filters for <b>EEG</b> data'  , 'CallBack', comBFCD); %, 'separator', 'on');
uimenu( mFI,'Label', '<html>Plot Amplitude Spectrum for <b>EEG</b> data'  , 'CallBack', comPAS);
uimenu( mFI, 'Label', '<html>Filters for <b>ERP</b> data', 'CallBack', comFil, 'separator','on' );
uimenu( mFI,'Label', '<html>Plot Amplitude Spectrum for <b>ERP</b> data'  , 'CallBack', comPASerp);

%
% Artifact rejection submenus
%
mAR = uimenu( submenu,    'Label', 'Artifact Detection'  , 'tag','ART','separator','on');
uimenu( mAR, 'Label', 'Simple voltage threshold'  , 'CallBack', comAR0);
uimenu( mAR, 'Label', 'Moving window peak-to-peak threshold'  , 'CallBack', comAR1);
uimenu( mAR, 'Label', 'Blink rejection (alpha version)'  , 'CallBack', comAR3);
uimenu( mAR, 'Label', 'Step-like artifacts'  , 'CallBack', comAR4);
uimenu( mAR, 'Label', 'Sample to sample voltage threshold'  , 'CallBack', comAR6);
uimenu( mAR, 'Label', 'Rate of change  (time derivative, alpha version)'  , 'CallBack', comAR7);
uimenu( mAR, 'Label', 'Blocking & Flat line (alpha version)'  , 'CallBack', comAR8);
uimenu( mAR, 'Label', '<html><b>EEG</b> Artifact Detection Summary Table'  , 'CallBack', comARSUMM2, 'ForegroundColor', [0 0 0.6], 'separator','on');
uimenu( mAR, 'Label', '<html><b>EEG</b> Artifact Detection Summary Plot'  , 'CallBack', comARSUMM, 'ForegroundColor', [0 0 0.6]);
uimenu( mAR, 'Label', '<html>Clear Artifact Detection Marks on <b>EEG</b>'  , 'CallBack', comRSTAR, 'ForegroundColor', [0.6 0 0]);
uimenu( mAR, 'Label', '<html><b>ERP</b> Artifact Detection Summary Table'  , 'CallBack', comARSUMerp1, 'ForegroundColor', [0 0 0.6], 'separator','on');
uimenu( mAR, 'Label', 'Synchronize Artifact Info in EEG and EVENTLIST'  , 'CallBack', comARSinc1, 'separator','on');

%
% ERP structure managment
%
uimenu( submenu, 'Label', '<html>Compute Averaged <b>ERP</b>'   , 'CallBack', comAVG, 'separator', 'on');
uimenu( submenu, 'Label', '<html><b>ERP</b> Bin Operations'   , 'CallBack', comBOP );
uimenu( submenu, 'Label', '<html><b>ERP</b> Channel Operations'   , 'CallBack', comCHOP2);
uimenu( submenu, 'Label', '<html>Plot <b>ERP</b> Waveforms'   , 'CallBack', comPLOT);
uimenu( submenu, 'Label', '<html>Plot 2D <b>ERP</b> map'   , 'CallBack', comSCALP);
uimenu( submenu, 'Label', 'Export plotted figure to PDF/EPS', 'CallBack', comEXPPDF, 'separator', 'on');
uimenu( submenu, 'Label', '<html>Export <b>ERP</b> to Text (readable by ERPSS)', 'CallBack', comEXPAVG);
uimenu( submenu, 'Label', '<html>Export <b>ERP</b> to Text (universal)', 'CallBack', comEXPUNI);
uimenu( submenu, 'Label', 'Load existing ERPset', 'CallBack', comLDERP, 'separator', 'on');
uimenu( submenu, 'Label', 'Clear ERPset(s)', 'CallBack', comDELERP);
uimenu( submenu, 'Label', 'Save current ERPset'   , 'CallBack', comSAVE);
uimenu( submenu, 'Label', 'Save current ERPset as'   , 'CallBack', comSAVEas);
uimenu( submenu, 'Label', 'Duplicate or rename current ERPset'   , 'CallBack', comDUPLI);
uimenu( submenu, 'Label', 'Average Across ERPsets (Grand Average)', 'CallBack', comGAVG, 'separator', 'on');
uimenu( submenu, 'Label', '<html><b>ERP</b> Measurement Tool', 'CallBack', comERPMT, 'separator', 'on');

%
% Create Utilities submenu (Temporay)
%
mUTI = uimenu( submenu, 'Label', 'Utilities'  , 'tag','Utilities', 'separator', 'on');
%mTK     = uimenu( mUTI, 'Label', 'Trend Killer'  , 'tag','TrendK');
%uimenu( mTK, 'Label', 'Polynomial Detrending (continuous)'  , 'CallBack', comTK1);
%uimenu( mTK, 'Label', '<html><b>EEG</b> Linear Detrend'  , 'CallBack', comTK2);
%uimenu( mTK, 'Label', '<html><b>ERP</b> Linear Detrend'  , 'CallBack', comTK3, 'separator', 'on');
mINS = uimenu( mUTI, 'Label',  'Insert Event Codes'  , 'tag', 'insertcodes');
uimenu( mINS, 'Label',  '<html>Insert event codes using threshold (continuous <b>EEG</b>)'  , 'CallBack', comICOF);
uimenu( mINS, 'Label',  '<html>Insert event codes using latency(ies) (continuous <b>EEG</b>)'  , 'CallBack', comICLA);
uimenu( mINS, 'Label',  '<html>Insert event codes at TTL onsets (continuous <b>EEG</b>)'  , 'CallBack', comICTTL);
uimenu( mUTI, 'Label',  '<html>Erase undesired event codes (continuous <b>EEG</b>)'  , 'CallBack', comEEC, 'separator','on');
uimenu( mUTI, 'Label',  '<html>Recover bin descriptor file from <b>EEG</b>'  , 'CallBack', comEEGBDR, 'separator','on');
uimenu( mUTI, 'Label',  '<html>Recover bin descriptor file from <b>ERP</b>'  , 'CallBack', comERPBDR, 'separator','on');
uimenu( mUTI, 'Label',  'Append ERPsets'  , 'CallBack', comAPP, 'separator','on');
uimenu( mUTI, 'Label',  '<html>Remove <b>ERP</b> baseline'  , 'CallBack', comRERPBL);
uimenu( mUTI, 'Label',  '<html>Clear <b>ERP</b> channel location info'  , 'CallBack', comCERPch);
uimenu( mUTI, 'Label',  '<html>ERPLAB <FONT color="red" >Bac<FONT color="green" >kgro<FONT color="blue" >und <FONT color="black">Color', 'CallBack', comBCOL, 'separator','on');
uimenu( mUTI, 'Label',  '<html>ERPLAB <FONT color="red" >For<FONT color="green" >egro<FONT color="blue" >und <FONT color="black">Color', 'CallBack', comFCOL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        SUPPORT   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         MENU     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uimenu( submenu, 'Label', 'help', 'CallBack', comhelpman, 'separator', 'on');
uimenu( submenu, 'Label', 'About ERPLAB', 'CallBack', 'abouterplabGUI', 'separator', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        ERPSET    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         MENU     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% create erpset menu
%
erpmenu = uimenu( menuERPLAB, 'Label', 'ERPsets', 'separator','on','tag','erpsets');
set(erpmenu, 'position', 7);
set(erpmenu, 'enable', 'off');
