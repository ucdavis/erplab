%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Oct. 2023

% ERPLAB Studio

function varargout = f_EEG_history_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);


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
drawui_erp_history(FonsizeDefault);
varargout{1} = box_eeg_history;

    function drawui_erp_history(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %%--------------------channel and bin setting----------------------
        gui_eeg_history.DataSelBox = uiextras.VBox('Parent', box_eeg_history,'BackgroundColor',ColorB_def);
        
        gui_eeg_history.erp_history_title = uiextras.HBox('Parent', gui_eeg_history.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eeg_history.erp_h_all = uicontrol('Style','radiobutton','Parent',gui_eeg_history.erp_history_title,'String','Current EEGset',...
            'callback',@ERP_H_ALL,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        gui_eeg_history.erp_h_EEG = uicontrol('Style','radiobutton','Parent', gui_eeg_history.erp_history_title,'String','Current session',...
            'callback',@ERP_H_EEG,'Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def); % 2F
        
        try
            ERP_history =  observe_EEGDAT.EEG.history;
        catch
            ERP_history = [];
        end
        if isempty(ERP_history)
            ERP_history = char('No history exist in the current ERPset');
        end
        [~, total_len] = size(ERP_history);
        if total_len <500
            total_len =1000;
        end
        gui_eeg_history.erp_history_table = uiextras.HBox('Parent', gui_eeg_history.DataSelBox);
        gui_eeg_history.uitable = uitable(  ...
            'Parent'        , gui_eeg_history.erp_history_table,...
            'Data'          , strsplit(ERP_history(1,:), '\n')', ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , {'Function call'}, ...
            'RowName'       , []);
        
        %%save the scripts
         gui_eeg_history.save_history_title = uiextras.HBox('Parent', gui_eeg_history.DataSelBox,'BackgroundColor',ColorB_def);
        
         
        
        set( gui_eeg_history.DataSelBox,'Heights',[40 -1 30]);
        
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%--------History for both EEG and ERP data processing procedure------------
    function ERP_H_ALL(~,~)
        Source_value = 1;
        set(gui_eeg_history.erp_h_all,'Value',Source_value);
        set(gui_eeg_history.erp_h_EEG,'Value',~Source_value);
        
        %adding the relared history in dispaly panel
        hiscp_empty =0;
        try
            ERP_history =  observe_EEGDAT.EEG.history;
        catch
            ERP_history = [];
        end
        
        if isempty(ERP_history)
            ERP_history = char('No history exist in the current ERPset');
        end
        ERP_history_display = {};
        for Numofrow = 1:size(ERP_history,1)
            ERP_history_display = [ERP_history_display,strsplit(ERP_history(Numofrow,:), '\n')];
        end
        set(gui_eeg_history.uitable,'Data', ERP_history_display');
        set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
        set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
        
    end

%%------------------------ALLCOM-------------------------------------------
    function ERP_H_EEG(~,~)
        Source_value = 1;
        set(gui_eeg_history.erp_h_all,'Value',~Source_value);
        set(gui_eeg_history.erp_h_EEG,'Value',Source_value);
        %adding the relared history in dispaly panel
        try
            ERP_history = evalin('base','ALLCOM');
            ERP_history = ERP_history';
        catch
            ERP_history = {'No command history was found in the current session'};
        end
        if isempty(ERP_history)
            ERP_history = {'No command history was found in the current session'};
        end
        
        set(gui_eeg_history.uitable,'Data',ERP_history);
        set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
    end



%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=22
            return;
        end
        if  isempty(observe_EEGDAT.EEG)
            
            
        end
        
        
        if gui_eeg_history.erp_h_all.Value ==1
            
            try
                ERP_history =  observe_EEGDAT.EEG.history;
            catch
                ERP_history = [];
            end
            if isempty(ERP_history)
                ERP_history = char('No history exist in the current ERPset');
            end
            ERP_history_display = {};
            for Numofrow = 1:size(ERP_history,1)
                ERP_history_display = [ERP_history_display,strsplit(ERP_history(Numofrow,:), '\n')];
            end
            set(gui_eeg_history.uitable,'Data', ERP_history_display');
            set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
        else%% ALLERPCOM for current session
            
            try
                ERP_history = evalin('base','ALLERPCOM');
                ERP_history = ERP_history';
                set(gui_eeg_history.uitable,'Data',ERP_history);
            catch
                ERP_history = {'No command history was found in the current section'};
                set(gui_eeg_history.uitable,'Data',ERP_history);
            end
            if isempty(ERP_history)
                ERP_history = {'No command history was found in the current section'};
                set(gui_eeg_history.uitable,'Data',ERP_history);
            end
            
            set(gui_eeg_history.DataSelBox,'Heights',[40 -1]);
        end
        
    end



end