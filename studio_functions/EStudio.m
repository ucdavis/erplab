% New GUI Layout - Simple ERP viewer 0.014
%
% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023

% ERPLAB Studio Toolbox
%

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

% Reqs:
% - data loaded in valid ERPset
% - GUI Layout Toolbox
% - ERPLAB


%
% Demo to explore an ERP Viewer using the new GUI Layout Toolbox
% Now with more in nested functions

function [] = EStudio()

EStudioversion = 9.0;
erplab_running_version('Version',EStudioversion,'tooltype','EStudio');


%%---------------ADD FOLDER TO PATH-------------------
pathName = which('EStudio','-all');
if length(pathName)>1
    fprintf('\nEStudio WARNING: More than one EStudio folder was found.\n\n');
end
pathName = pathName{1};
pathName= pathName(1:findstr(pathName,'EStudio.m')-1);
% add all ERPLAB subfolders
addpath(genpath(pathName));
SignalProcessingToolboxCheck;



Count_ERP = 1;
Count_currentERP =0;
% Sanity checks
try
    test = uix.HBoxFlex();
catch
    beep;
    disp('The GUI Layout Toolbox might not be installed. Quitting')
    return
end

%%close EEGLAB
try
    W_MAIN = findobj('tag', 'EEGLAB');
    close(W_MAIN);
    clearvars observe_ERPDAT;
catch
end

% global CURRENTERP;
global observe_ERPDAT;
global viewer_ERPDAT;
global EStudio_gui_erp_totl
viewer_ERPDAT = v_ERPDAT;
% global ERP;
ERP              = [];  % Start ERP Structure on workspace
ALLERP           = [];    %Start ALLERP Structure on workspace
% ALLERPCOM        = [];
CURRENTERP       = 1;

estudioworkingmemory('EStudioColumnNum',1);

assignin('base','ERP',ERP);
assignin('base','ALLERP', ALLERP);
% assignin('base','ALLERPCOM', ALLERPCOM);
assignin('base','CURRENTERP', CURRENTERP);


filepath =  which('dummy.erp');
[pathstr, fname, ext] = fileparts(filepath);
[ERP, ALLERP] = pop_loaderp('filename','dummy.erp', 'filepath',pathstr ,'History', 'off');
assignin('base','ALLERP',ALLERP);
% clc;

observe_ERPDAT = o_ERPDAT;
observe_ERPDAT.ALLERP = ALLERP;
observe_ERPDAT.CURRENTERP = CURRENTERP;
observe_ERPDAT.ERP = ERP;
observe_ERPDAT.Count_ERP = Count_ERP;
observe_ERPDAT.Count_currentERP = Count_currentERP;
observe_ERPDAT.Process_messg = 0;%0 is the default means there is no message for processing procedure;
%1 means the processign procedure is running
%2 means the processign procedure is done
%3 means there are some errors for processing procedure
observe_ERPDAT.Two_GUI = 0;


addlistener(observe_ERPDAT,'cerpchange',@indexERP);
addlistener(observe_ERPDAT,'drawui_CB',@onErpChanged);
addlistener(observe_ERPDAT,'erpschange',@allErpChanged);
addlistener(observe_ERPDAT,'Count_ERP_change',@CountErpChanged);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'Messg_change',@Process_messg_change_main);



% Initialize data and interface


%%Try to close existing GUI
% global EStudio_gui_erp_totl_Window
try
    close(EStudio_gui_erp_totl.Window);
catch
end
EStudio_gui_erp_totl = struct();

EStudio_gui_erp_totl = createInterface(observe_ERPDAT.ERP);

% Update the GUI with current data
% updateInterface();

f_redrawERP();

    function EStudio_gui_erp_totl = createInterface(ERP)
        
        try
            [version reldate] = geterplabstudioversion;
            erplabstudiover = version;
        catch
            erplabstudiover = '??';
        end
        currvers  = ['ERPLAB Studio ' erplabstudiover];
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        EStudio_gui_erp_totl = struct();
        % First, let's start the window
        EStudio_gui_erp_totl.Window = figure( 'Name', currvers, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off', 'tag', 'rollover');
        
        % set the window size
        %old_pos = get(EStudio_gui_erp_totl.Window, 'Position');
        new_pos = [1 1 1200 1200];
        set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
        
        
        % + File menu
        EStudio_gui_erp_totl.FileMenu = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'File');
        uimenu( EStudio_gui_erp_totl.FileMenu, 'Label', 'Exit', 'Callback', @onExit);
        
        % + View menu
        EStudio_gui_erp_totl.ViewMenu = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'ERPLAB Commands' );
        
        %%-----------Setting------------------------------------------------
        EStudio_gui_erp_totl.Setting = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'Setting');
        
        %%ERPStudio Memory
        EStudio_gui_erp_totl.set_ERP_memory = uimenu( EStudio_gui_erp_totl.Setting, 'Label', 'EStudio Memory Setting','separator','off');
        uimenu( EStudio_gui_erp_totl.set_ERP_memory, 'Label', 'Reset EStudio Working Memory', 'Callback', 'erplabstudioamnesia(1)','separator','off');
        uimenu( EStudio_gui_erp_totl.set_ERP_memory, 'Label', 'Save a copy of the current working memory as...', 'Callback', 'working_mem_save_load(1)','separator','off');
        comLoadWM = ['clear vmemoryerp; vmemoryerp = working_mem_save_load(2); assignin(''base'',''vmemoryerp'',vmemoryerp);'];
        uimenu( EStudio_gui_erp_totl.set_ERP_memory,'Label','Load a previous working memory file','CallBack',comLoadWM,'separator','off');
        
        
        %% Create tabs
        context_tabs = uiextras.TabPanel('Parent', EStudio_gui_erp_totl.Window, 'Padding', 5,'BackgroundColor',ColorB_def,'FontSize',14);
        %          context_tabs = uix.TabPanel('Parent', EStudio_gui_erp_totl.Window, 'Padding', 5,'BackgroundColor',ColorB_def);
        tab1 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        tab2 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        EStudio_gui_erp_totl.tabERP = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10,'BackgroundColor',ColorB_def);
        tab4 = uix.HBoxFlex( 'Parent', context_tabs, 'Spacing', 10 );
        
        context_tabs.TabNames = {'Continuous EEG','Epoched EEG','ERP', 'MVPA'};
        context_tabs.SelectedChild = 3;
        context_tabs.HighlightColor = [0 0 0];
        context_tabs.FontWeight = 'bold';
        context_tabs.TabSize = (new_pos(3)-20)/4;
        context_tabs.BackgroundColor = ColorB_def;
        %%set the layput for ERP Tab.
        EStudio_gui_erp_totl = ERPLAB_ERP_Tab(EStudio_gui_erp_totl,ColorB_def);
        
        %
        
        
    end % createInterface


%------------------------------------
    function onErpChanged( ~, ~ )
        assignin('base','ERP',observe_ERPDAT.ERP);
    end


    function indexERP( ~, ~ )
        assignin('base','CURRENTERP',observe_ERPDAT.CURRENTERP);
        if ~strcmp(observe_ERPDAT.CURRENTERP,CURRENTERP)
            CURRENTERP = observe_ERPDAT.CURRENTERP;
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
    end

    function allErpChanged(~,~)
        assignin('base','ALLERP',observe_ERPDAT.ALLERP);
    end


    function Count_currentERPChanged(~,~)
        S_ws_geterpset= estudioworkingmemory('selectederpstudio');
        if isempty(S_ws_geterpset)
            S_ws_geterpset = observe_ERPDAT.CURRENTERP;
            
            if isempty(S_ws_geterpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
        
        if length(S_ws_geterpset) ==1
            Enable_minus = 'off';
            Enable_plus = 'off';
        else
            if S_ws_getbinchan.Select_index ==1
                Enable_minus = 'off';
                Enable_plus = 'on';
            elseif  S_ws_getbinchan.Select_index == length(S_ws_geterpset)
                Enable_minus = 'on';
                Enable_plus = 'off';
            else
                Enable_minus = 'on';
                Enable_plus = 'on';
            end
        end
        
        EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
        EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
        
        try
            try
                S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
                S_ws_viewer = S_ws_geterpvalues.Viewer;
            catch
                S_ws_viewer = 'off';
            end
            moption = S_ws_geterpvalues.Measure;
            latency = S_ws_geterpvalues.latency;
            if strcmp(S_ws_viewer,'on')
                if isempty(moption)
                    msgboxText = ['EStudio says: User must specify a type of measurement.'];
                    title = 'EStudio: ERP measurement tool- "Measurement type".';
                    errorfound(msgboxText, title);
                    return;
                end
                if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                    if length(latency)~=1
                        msgboxText = ['EStudio says: ' moption ' only needs 1 latency value.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    end
                else
                    if length(latency)~=2
                        msgboxText = ['EStudio says: ' moption ' needs 2 latency values.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    else
                        if latency(1)>=latency(2)
                            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                            title = 'EStudio: ERP measurement tool-Measurement window';
                            errorfound(sprintf(msgboxText), title);
                            return
                        end
                    end
                end
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
            
        catch
            f_redrawERP();
        end
    end



% %%%Display the processing procedure for some panels (e.g., Filter)------------------------
    function Process_messg_change_main(~,~)
        
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %         ColorB_def = [1 1 1];
        %        EStudio_gui_erp_totl.Process_messg= erpworkingmemory('EStudio_proces_messg');
        %         EStudio_gui_erp_totl.Process_messg.ForegroundColor = [0 0 0];
        Processed_Method=erpworkingmemory('f_ERP_proces_messg');
        EStudio_gui_erp_totl.Process_messg.FontSize = 14;
        if observe_ERPDAT.Process_messg ==1
            EStudio_gui_erp_totl.Process_messg.String = strcat('1- ',Processed_Method,': Running....');
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [0 0 0];
        elseif observe_ERPDAT.Process_messg==2
            EStudio_gui_erp_totl.Process_messg.String = strcat('2- ',Processed_Method,': Complete');
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [0 0.5 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
            %             pause(2);
            %             EStudio_gui_erp_totl.Process_messg.String = '';
            %             EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
        elseif observe_ERPDAT.Process_messg ==3
            EStudio_gui_erp_totl.Process_messg.String = strcat('2- ',Processed_Method,': Error');
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [1 0 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
        elseif observe_ERPDAT.Process_messg ==4
            EStudio_gui_erp_totl.Process_messg.String = strcat('Warning: ',32,Processed_Method);
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [1 0 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
        else
            
        end
        pause(0.1);
        EStudio_gui_erp_totl.Process_messg.String = '';
        EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
        
    end

%%--------------------Function to close the toolbox------------------------
    function onExit(~,~)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Are you sure to quit EStudio?'];
        title = 'Exit';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        if strcmpi(button,'Yes')
            try
                close(EStudio_gui_erp_totl.Window);
            catch
                return;
            end
        else
            return;
        end
    end



%%%%%%%%%%%%%%%%%%%%%%%
end % end of the function