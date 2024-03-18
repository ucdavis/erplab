%%This script is to save history for either current EEGset or current session.



%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Oct. 2023

% ERPLAB Studio

function varargout = f_EEG_history_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

gui_eeg_history = struct();

%-----------------------------Name the title----------------------------------------------
% global box_eeg_history;

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_eeg_history = uiextras.BoxPanel('Parent', fig, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_eeg_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_eeg_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

%-----------------------------Draw the panel-------------------------------------
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_eeg_history(FonsizeDefault);
varargout{1} = box_eeg_history;

    function drawui_eeg_history(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        
        FontSize_defualt = FonsizeDefault;
        %%--------------------channel and bin setting----------------------
        gui_eeg_history.DataSelBox = uiextras.VBox('Parent', box_eeg_history,'BackgroundColor',ColorB_def);
        
        gui_eeg_history.eeg_history_title = uiextras.HBox('Parent', gui_eeg_history.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_history.eeg_h_all = uicontrol('Style','radiobutton','Parent',gui_eeg_history.eeg_history_title,'String','Current EEGset',...
            'callback',@eeg_H_ALL,'Value',1,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag); % 2F
        gui_eeg_history.eeg_h_EEG = uicontrol('Style','radiobutton','Parent', gui_eeg_history.eeg_history_title,'String','Current session',...
            'callback',@eeg_H_EEG,'Value',0,'FontSize',FontSize_defualt,'BackgroundColor',ColorB_def,'Enable',EnableFlag); % 2F
        
        try
            eeg_history =  observe_EEGDAT.EEG.history;
        catch
            eeg_history = [];
        end
        if isempty(eeg_history)
            eeg_history = char('No history was found for the current eegset');
        end
        [~, total_len] = size(eeg_history);
        if total_len <500
            total_len =1000;
        end
        gui_eeg_history.eeg_history_table = uiextras.HBox('Parent', gui_eeg_history.DataSelBox);
        gui_eeg_history.uitable = uitable(  ...
            'Parent'        , gui_eeg_history.eeg_history_table,...
            'Data'          , strsplit(eeg_history(1,:), '\n')', ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , {'Function call'}, ...
            'RowName'       , [],'Enable',EnableFlag);
        
        %%save the scripts
        gui_eeg_history.save_history_title = uiextras.HBox('Parent', gui_eeg_history.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_history.save_script = uicontrol('Style','pushbutton','Parent',gui_eeg_history.save_history_title,...
            'String','Save history script','callback',@savescript,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        gui_eeg_history.show_cmd = uicontrol('Style','pushbutton','Parent',gui_eeg_history.save_history_title,...
            'String','Show in cmd window','callback',@show_cmd,'FontSize',FontSize_defualt,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set( gui_eeg_history.DataSelBox,'Sizes',[35 -1 30]);
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%--------History for both EEG and eeg data processing procedure------------
    function eeg_H_ALL(~,~)
        Source_value = 1;
        set(gui_eeg_history.eeg_h_all,'Value',Source_value);
        set(gui_eeg_history.eeg_h_EEG,'Value',~Source_value);
        
        %adding the relared history in dispaly panel
        hiscp_empty =0;
        try
            eeg_history =  observe_EEGDAT.EEG.history;
        catch
            eeg_history = [];
        end
        
        if isempty(eeg_history)
            eeg_history = char('No history exist in the current eegset');
            gui_eeg_history.save_script.Enable = 'off';
        else
            gui_eeg_history.save_script.Enable = 'on';
        end
        eeg_history_display = {};
        for Numofrow = 1:size(eeg_history,1)
            eeg_history_display = [eeg_history_display,strsplit(eeg_history(Numofrow,:), '\n')];
        end
        set(gui_eeg_history.uitable,'Data', eeg_history_display');
    end

%%------------------------ALLCOM-------------------------------------------
    function eeg_H_EEG(~,~)
        Source_value = 1;
        set(gui_eeg_history.eeg_h_all,'Value',~Source_value);
        set(gui_eeg_history.eeg_h_EEG,'Value',Source_value);
        %adding the relared history in dispaly panel
        try
            eeg_history = evalin('base','ALLCOM');
            eeg_history = eeg_history';
        catch
            eeg_history = [];
            gui_eeg_history.save_script.Enable = 'off';
        end
        if isempty(eeg_history)
            eeg_history = {'No command history was found in the current session'};
            gui_eeg_history.save_script.Enable = 'off';
        else
            gui_eeg_history.save_script.Enable = 'on';
        end
        set(gui_eeg_history.uitable,'Data',eeg_history);
    end

%%--------------------------------Save scripts-----------------------------
    function savescript(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable = 'off';
            return;
        end
        if gui_eeg_history.eeg_h_all.Value==1
            MessageViewer= char(strcat('Save history script for the current EEGset'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=1;
            LASTCOM = pop_saveh(observe_EEGDAT.EEG.history);
        else
            MessageViewer= char(strcat('Save history script for the current session'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_panel_message=1;
            try
                eeg_history = evalin('base','ALLCOM');
                eeg_history = eeg_history';
            catch
                return;
            end
            LASTCOM = pop_saveh(eeg_history);
            
        end
        fprintf(['\n',LASTCOM,'\n']);
        observe_EEGDAT.eeg_panel_message=2;
    end

%%--------Setting current eegset/session history based on the current updated eegset------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=26
            return;
        end
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            gui_eeg_history.save_script.Enable = 'off';
            gui_eeg_history.eeg_h_all.Enable = 'off';
            gui_eeg_history.eeg_h_EEG.Enable = 'off';
            gui_eeg_history.uitable.Enable = 'off';
            gui_eeg_history.show_cmd.Enable = 'off';
            eeg_history = char('No command history was found for the current eegset');
            set(gui_eeg_history.uitable,'Data', strsplit(eeg_history(1,:), '\n')');
            return;
        end
        gui_eeg_history.save_script.Enable = 'on';
        gui_eeg_history.eeg_h_all.Enable = 'on';
        gui_eeg_history.eeg_h_EEG.Enable = 'on';
        gui_eeg_history.uitable.Enable = 'on';
        gui_eeg_history.show_cmd.Enable = 'on';
        if gui_eeg_history.eeg_h_all.Value ==1
            try
                eeg_history =  observe_EEGDAT.EEG.history;
            catch
                eeg_history = [];
            end
            if isempty(eeg_history)
                eeg_history = char('No command history was found for the current eegset');
                gui_eeg_history.save_script.Enable = 'off';
            end
            eeg_history_display = {};
            for Numofrow = 1:size(eeg_history,1)
                eeg_history_display = [eeg_history_display,strsplit(eeg_history(Numofrow,:), '\n')];
            end
            set(gui_eeg_history.uitable,'Data', eeg_history_display');
            set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
        else%% ALLeegCOM for current session
            try
                eeg_history = evalin('base','ALLCOM');
                eeg_history = eeg_history';
                set(gui_eeg_history.uitable,'Data',eeg_history);
            catch
                eeg_history = {'No command history was found in the current session'};
                set(gui_eeg_history.uitable,'Data',eeg_history);
                gui_eeg_history.save_script.Enable = 'off';
            end
            if isempty(eeg_history)
                eeg_history = {'No command history was found in the current session'};
                set(gui_eeg_history.uitable,'Data',eeg_history);
                gui_eeg_history.save_script.Enable = 'off';
            end
        end
    end

%%-------------show history to command window------------------------------
    function show_cmd(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%for current history
        MessageViewer='History > Show in cmd window';
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_panel_message=1;
        
        if gui_eeg_history.eeg_h_all.Value ==1
            try
                eeg_history =  observe_EEGDAT.EEG.history;
            catch
                eeg_history = [];
            end
            if isempty(eeg_history)
                disp(['No command history for',32,observe_EEGDAT.EEG.setname]);
                observe_EEGDAT.eeg_panel_message=2;
                return;
            end
            eeg_history_display = {};
            for Numofrow = 1:size(eeg_history,1)
                eeg_history_display = [eeg_history_display,strsplit(eeg_history(Numofrow,:), '\n')];
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
            fprintf(['**Command history**',32,datestr(datetime('now')),'\n']);
            fprintf(['EEG name:',32,observe_EEGDAT.EEG.setname,'\n\n']);
            for ii = 1:length(eeg_history_display)
                disp([eeg_history_display{ii}]);
            end
            fprintf( [repmat('-',1,100) '\n\n']);
        else
            try
                eeg_history = evalin('base','ALLCOM');
            catch
                eeg_history = [];
            end
            if isempty(eeg_history)
                disp(['No command history for current session']);
                observe_EEGDAT.eeg_panel_message=2;
                return;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
            fprintf(['**Command history for current session**',32,datestr(datetime('now')),'\n\n']);
            for ii = 1:length(eeg_history)
                disp([eeg_history{ii}]);
            end
            fprintf( [repmat('-',1,100) '\n\n']);
        end
        observe_EEGDAT.eeg_panel_message=2;
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=21
            return;
        end
        set(gui_eeg_history.eeg_h_all,'Value',1);
        set(gui_eeg_history.eeg_h_EEG,'Value',0);
        
        %adding the relared history in dispaly panel
        hiscp_empty =0;
        try
            eeg_history =  observe_EEGDAT.EEG.history;
        catch
            eeg_history = [];
        end
        
        if isempty(eeg_history)
            eeg_history = char('No history exist in the current eegset');
            gui_eeg_history.save_script.Enable = 'off';
        else
            gui_eeg_history.save_script.Enable = 'on';
        end
        eeg_history_display = {};
        for Numofrow = 1:size(eeg_history,1)
            eeg_history_display = [eeg_history_display,strsplit(eeg_history(Numofrow,:), '\n')];
        end
        set(gui_eeg_history.uitable,'Data', eeg_history_display');
    end
end