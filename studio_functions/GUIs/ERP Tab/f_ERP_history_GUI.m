%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_history_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);
gui_erp_history = struct();
%-----------------------------Name the title----------------------------------------------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_erp_history = uiextras.BoxPanel('Parent', fig, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erp_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_erp_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
varargout{1} = box_erp_history;

    function drawui_erp_history(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %%--------------------channel and bin setting----------------------
        gui_erp_history.DataSelBox = uiextras.VBox('Parent', box_erp_history,'BackgroundColor',ColorB_def);
        gui_erp_history.erp_history_title = uiextras.HBox('Parent', gui_erp_history.DataSelBox,'BackgroundColor',ColorB_def);
        
        
        gui_erp_history.erp_h_all = uicontrol('Style','radiobutton','Parent',gui_erp_history.erp_history_title,'String','Current ERPset',...
            'callback',@ERP_H_ALL,'Value',1,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_erp_history.erp_h_current = uicontrol('Style','radiobutton','Parent', gui_erp_history.erp_history_title,'String','Current session',...
            'callback',@erp_h_current,'Value',0,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        ERP_history = [];
        if isempty(ERP_history)
            ERP_history = char('No history exist in the current ERPset');
        end
        [~, total_len] = size(ERP_history);
        if total_len <500
            total_len =1000;
        end
        gui_erp_history.erp_history_table = uiextras.HBox('Parent', gui_erp_history.DataSelBox);
        gui_erp_history.uitable = uitable(  ...
            'Parent'        , gui_erp_history.erp_history_table,...
            'Data'          , strsplit(ERP_history(1,:), '\n')', ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , {'Function call'}, ...
            'RowName'       , []);
        %%save the scripts
        gui_erp_history.save_history_title = uiextras.HBox('Parent', gui_erp_history.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_history.save_script = uicontrol('Style','pushbutton','Parent',gui_erp_history.save_history_title,...
            'String','Save history script','callback',@savescript,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        gui_erp_history.show_cmd = uicontrol('Style','pushbutton','Parent',gui_erp_history.save_history_title,...
            'String','Show in cmd window','callback',@show_cmd,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        set(gui_erp_history.DataSelBox,'Sizes',[40 -1 30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%--------History for both EEG and ERP data processing procedure------------
    function ERP_H_ALL(~,~)
        Source_value = 1;
        set(gui_erp_history.erp_h_all,'Value',Source_value);
        set(gui_erp_history.erp_h_current,'Value',~Source_value);
        %adding the relared history in dispaly panel
        hiscp_empty =0;
        try
            ERP_history =  observe_ERPDAT.ERP.history;
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
        set(gui_erp_history.uitable,'Data', ERP_history_display');
        
    end


    function erp_h_current(~,~)
        Source_value = 1;
        set(gui_erp_history.erp_h_all,'Value',~Source_value);
        set(gui_erp_history.erp_h_current,'Value',Source_value);
        %adding the relared history in dispaly panel
        try
            ERP_history = evalin('base','ALLERPCOM');
            ERP_history = ERP_history';
        catch
            ERP_history = {'No command history was found in the current session'};
        end
        if isempty(ERP_history)
            ERP_history = {'No command history was found in the current session'};
        end
        
        set(gui_erp_history.uitable,'Data',ERP_history);
    end

%%---------------------save history to script------------------------------
    function savescript(~,~)
        
        if gui_erp_history.erp_h_all.Value==1
            MessageViewer= char(strcat('Save history script for the current ERPset'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=1;
            LASTCOM = pop_saveh(observe_ERPDAT.ERP.history);
        else
            MessageViewer= char(strcat('Save history script for the current session'));
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_ERPDAT.Process_messg=1;
            try
                erp_history = evalin('base','ALLERPCOM');
                erp_history = erp_history';
            catch
                return;
            end
            LASTCOM = pop_saveh(erp_history);
        end
        fprintf(['\n',LASTCOM,'\n']);
        observe_ERPDAT.Process_messg=2;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=20
            return;
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT')
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        gui_erp_history.save_script.Enable = Enableflag;
        gui_erp_history.uitable.Enable = Enableflag;
        gui_erp_history.erp_h_all.Enable = Enableflag;
        gui_erp_history.erp_h_current.Enable = Enableflag;
        gui_erp_history.show_cmd.Enable = Enableflag;
        if gui_erp_history.erp_h_all.Value ==1
            try
                ERP_history =  observe_ERPDAT.ERP.history;
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
            set(gui_erp_history.uitable,'Data', ERP_history_display');
        else%% ALLERPCOM for current session
            try
                ERP_history = evalin('base','ALLERPCOM');
                ERP_history = ERP_history';
                set(gui_erp_history.uitable,'Data',ERP_history);
            catch
                ERP_history = {'No command history was found in the current section'};
                set(gui_erp_history.uitable,'Data',ERP_history);
            end
            if isempty(ERP_history)
                ERP_history = {'No command history was found in the current section'};
                set(gui_erp_history.uitable,'Data',ERP_history);
            end
        end
        if isempty(observe_ERPDAT.ERP)
            gui_erp_history.erp_h_all.String = 'Current ERPset';
        else
            gui_erp_history.erp_h_all.String = ['Current ERPset (',num2str(observe_ERPDAT.CURRENTERP),')'];
        end
    end

%%-------------show history to command window------------------------------
    function show_cmd(~,~)
        if isempty(observe_ERPDAT.ERP)
            return;
        end
        MessageViewer= char(strcat('History > Show in cmd window'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_ERPDAT.Process_messg=1;
        if gui_erp_history.erp_h_all.Value ==1
            try
                ERP_history =  observe_ERPDAT.ERP.history;
            catch
                ERP_history = [];
            end
            if isempty(ERP_history)
                disp(['No command history for',32,observe_ERPDAT.ERP.erpname]);
                observe_ERPDAT.Process_messg=2;
                return;
            end
            ERP_history_display = {};
            for Numofrow = 1:size(ERP_history,1)
                ERP_history_display = [ERP_history_display,strsplit(ERP_history(Numofrow,:), '\n')];
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
            fprintf(['**Command history**',32,datestr(datetime('now')),'\n']);
            fprintf(['ERP name:',32,observe_ERPDAT.ERP.erpname,'\n\n']);
            for ii = 1:length(ERP_history_display)
                disp([ERP_history_display{ii}]);
            end
            fprintf( [repmat('-',1,100) '\n\n']);
        else
            try
                ERP_history = evalin('base','ALLERPCOM');
            catch
                ERP_history = '';
            end
            if isempty(ERP_history)
                disp(['No command history for current session']);
                observe_ERPDAT.Process_messg=2;
                return;
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
            fprintf(['**Command history for current session**',32,datestr(datetime('now')),'\n\n']);
            for ii = 1:length(ERP_history)
                disp([ERP_history{ii}]);
            end
            fprintf( [repmat('-',1,100) '\n\n']);
        end
        
        if isempty(observe_ERPDAT.ERP)
            gui_erp_history.erp_h_all.String = 'Current ERPset';
        else
            gui_erp_history.erp_h_all.String = ['Current ERPset (',num2str(observe_ERPDAT.CURRENTERP),')'];
        end
        observe_ERPDAT.Process_messg=2;
    end




    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=17
            return;
        end
        set(gui_erp_history.erp_h_all,'Value',1);
        set(gui_erp_history.erp_h_current,'Value',0);
        %adding the relared history in dispaly panel
        hiscp_empty =0;
        try
            ERP_history =  observe_ERPDAT.ERP.history;
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
        set(gui_erp_history.uitable,'Data', ERP_history_display');
        if isempty(observe_ERPDAT.ERP)
            gui_erp_history.erp_h_all.String = 'Current ERPset';
        else
            gui_erp_history.erp_h_all.String = ['Current ERPset (',num2str(observe_ERPDAT.CURRENTERP),')'];
        end
    end
end