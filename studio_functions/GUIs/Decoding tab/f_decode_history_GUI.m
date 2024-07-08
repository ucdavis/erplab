%Author: Guanghui ZHANG & Steve Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%2024

% ERPLAB Studio

function varargout = f_decode_history_GUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

gui_decode_history = struct();
%-----------------------------Name the title----------------------------------------------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_decode_history = uiextras.BoxPanel('Parent', fig, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_decode_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_decode_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'History', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
drawui_decode_history(FonsizeDefault);
varargout{1} = box_decode_history;

    function drawui_decode_history(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %%--------------------channel and bin setting----------------------
        gui_decode_history.DataSelBox = uiextras.VBox('Parent', box_decode_history,'BackgroundColor',ColorB_def);
        
        ERP_history = [];
        if isempty(ERP_history)
            ERP_history = char('No history exist in the Pattern Classification Tab');
        end
        [~, total_len] = size(ERP_history);
        if total_len <500
            total_len =1000;
        end
        gui_decode_history.erp_history_table = uiextras.HBox('Parent', gui_decode_history.DataSelBox);
        gui_decode_history.uitable = uitable(  ...
            'Parent'        , gui_decode_history.erp_history_table,...
            'Data'          , strsplit(ERP_history(1,:), '\n')', ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        %%save the scripts
        gui_decode_history.save_history_title = uiextras.HBox('Parent', gui_decode_history.DataSelBox,'BackgroundColor',ColorB_def);
        gui_decode_history.save_script = uicontrol('Style','pushbutton','Parent',gui_decode_history.save_history_title,...
            'String','Save history script','callback',@savescript,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        gui_decode_history.show_cmd = uicontrol('Style','pushbutton','Parent',gui_decode_history.save_history_title,...
            'String','Show in cmd window','callback',@show_cmd,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        set(gui_decode_history.DataSelBox,'Sizes',[-1 30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%---------------------save history to script------------------------------
    function savescript(~,~)
        MessageViewer= char(strcat('Save history script for Pattern Classification Tab'));
        estudioworkingmemory('f_decode_proces_messg',MessageViewer);
        observe_DECODE.Process_messg=1;
        try
            erp_history = evalin('base','ALLCOM');
            erp_history = erp_history';
        catch
            return;
        end
        LASTCOM = pop_saveh(erp_history);
        fprintf(['\n',LASTCOM,'\n']);
        observe_DECODE.Process_messg=2;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=6
            return;
        end
        Enableflag = 'on';
        gui_decode_history.save_script.Enable = Enableflag;
        gui_decode_history.uitable.Enable = Enableflag;
        gui_decode_history.show_cmd.Enable = Enableflag;
        try
            ERP_history = evalin('base','ALLCOM');
            ERP_history = ERP_history';
        catch
            ERP_history = '';
        end
        if isempty(ERP_history)
            ERP_history = {'No command history was found for Pattern Classification Tab'};
        end
        ERP_history_display = {};
        count = 0;
        for Numofrow = size(ERP_history,1):-1:1
            count  = count+1;
            ERP_history_display{count,1} = ERP_history{Numofrow};
        end
        set(gui_decode_history.uitable,'Data',ERP_history_display);
        observe_DECODE.Count_currentMVPC=7;
    end

%%-------------show history to command window------------------------------
    function show_cmd(~,~)
        
        MessageViewer= char(strcat('History > Show in cmd window'));
        estudioworkingmemory('f_decode_proces_messg',MessageViewer);
        observe_DECODE.Process_messg=1;
        try
            ERP_history = evalin('base','ALLCOM');
        catch
            ERP_history = '';
        end
        if isempty(ERP_history)
            disp(['No command history for Pattern Classification Tab']);
            observe_DECODE.Process_messg=2;
            return;
        end
        fprintf( ['\n',repmat('-',1,100) '\n']);
        fprintf(['**Command history for current session**',32,datestr(datetime('now')),'\n\n']);
        for ii = length(ERP_history):-1:1
            disp([ERP_history{ii}]);
        end
        fprintf( [repmat('-',1,100) '\n\n']);
        observe_DECODE.Process_messg=2;
    end


    function Reset_best_panel_change(~,~)
        if observe_DECODE.Reset_Best_paras_panel~=6
            return;
        end
        try
            ERP_history =   evalin('base','ALLCOM');
        catch
            ERP_history = '';
        end
        
        if isempty(ERP_history)
            ERP_history = char('No history exist in the Pattern Classification Tab');
        end
        ERP_history_display = {};
        for Numofrow = size(ERP_history,1):-1:1
            ERP_history_display = [ERP_history_display,strsplit(ERP_history(Numofrow,:), '\n')];
        end
        set(gui_decode_history.uitable,'Data', ERP_history_display');
        
    end
end