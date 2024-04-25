%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
% Dec. 2023

% ERPLAB Studio

function varargout = f_ERP_resample_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_between_panels_change',@erp_between_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

gui_erp_resample = struct();

%-----------------------------Name the title----------------------------------------------
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_erp_resample = uiextras.BoxPanel('Parent', fig, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erp_resample = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    box_erp_resample = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Sampling Rate & Epoch', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @resample_help
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
drawui_erp_resample(FonsizeDefault);
varargout{1} = box_erp_resample;

    function drawui_erp_resample(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.702,0.77,0.85];
        end
        
        gui_erp_resample.DataSelBox = uiextras.VBox('Parent', box_erp_resample,'BackgroundColor',ColorB_def);
        
        %%------------------current sampling rate--------------------------
        gui_erp_resample.csrate_title = uiextras.HBox('Parent', gui_erp_resample.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent', gui_erp_resample.csrate_title,'String','Current sampling rate:',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_resample.csrate_edit = uicontrol('Style','edit','Parent', gui_erp_resample.csrate_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style','text','Parent', gui_erp_resample.csrate_title,'String','Hz',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_resample.csrate_title,'Sizes',[130 110 30]);
        
        %%---------------------new sampling rate---------------------------
        gui_erp_resample.nwsrate_title = uiextras.HBox('Parent', gui_erp_resample.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_resample.nwsrate_checkbox = uicontrol('Style','checkbox','Parent', gui_erp_resample.nwsrate_title,'String','New sampling rate:',...
            'callback',@nwsrate_checkbox,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off');
        gui_erp_resample.nwsrate_checkbox.KeyPressFcn = @erp_resample_presskey;
        gui_erp_resample.Paras{1} = gui_erp_resample.nwsrate_checkbox.Value;
        gui_erp_resample.nwsrate_edit = uicontrol('Style','edit','Parent', gui_erp_resample.nwsrate_title,'String','',...
            'callback',@nwsrate_edit,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_erp_resample.Paras{2} = str2num(gui_erp_resample.nwsrate_edit.String);
        gui_erp_resample.nwsrate_edit.KeyPressFcn = @erp_resample_presskey;
        uicontrol('Style','text','Parent', gui_erp_resample.nwsrate_title,'String','Hz',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_resample.nwsrate_title,'Sizes',[130 110 30]);
        
        %%----------------current time-window------------------------------
        gui_erp_resample.ctimewindow_title = uiextras.HBox('Parent', gui_erp_resample.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',gui_erp_resample.ctimewindow_title,...
            'String','Current epoch','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_resample.ctimewindow_editleft = uicontrol('Style','edit','Parent', gui_erp_resample.ctimewindow_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style', 'text','Parent',gui_erp_resample.ctimewindow_title,...
            'String','ms, to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_resample.ctimewindow_editright = uicontrol('Style','edit','Parent', gui_erp_resample.ctimewindow_title,'String','',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        uicontrol('Style', 'text','Parent',gui_erp_resample.ctimewindow_title,...
            'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_resample.ctimewindow_title,'Sizes',[90 55  40 55 25]);
        
        %%--------------------new time window--------------------------------
        gui_erp_resample.nwtimewindow_title = uiextras.HBox('Parent', gui_erp_resample.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_resample.nwtimewindow_checkbox= uicontrol('Style', 'checkbox','Parent',gui_erp_resample.nwtimewindow_title,...
            'callback',@nwtimewindow_checkbox,'String','New epoch','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0,'Enable','off');
        gui_erp_resample.Paras{3} = gui_erp_resample.nwtimewindow_checkbox.Value;
        gui_erp_resample.nwtimewindow_checkbox.KeyPressFcn = @erp_resample_presskey;
        gui_erp_resample.nwtimewindow_editleft = uicontrol('Style','edit','Parent', gui_erp_resample.nwtimewindow_title,'String','',...
            'callback',@nwtimewindow_editleft,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_erp_resample.Paras{4} = str2num(gui_erp_resample.nwtimewindow_editleft.String);
        gui_erp_resample.nwtimewindow_editleft.KeyPressFcn = @erp_resample_presskey;
        uicontrol('Style', 'text','Parent',gui_erp_resample.nwtimewindow_title,...
            'String','ms, to','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_resample.nwtimewindow_editright = uicontrol('Style','edit','Parent', gui_erp_resample.nwtimewindow_title,'String','',...
            'callback',@nwtimewindow_editright,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off'); % 2F
        gui_erp_resample.Paras{5} = str2num(gui_erp_resample.nwtimewindow_editright.String);
        gui_erp_resample.nwtimewindow_editright.KeyPressFcn = @erp_resample_presskey;
        uicontrol('Style', 'text','Parent',gui_erp_resample.nwtimewindow_title,...
            'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        set(gui_erp_resample.nwtimewindow_title,'Sizes',[90 55  40 55 25]);
        
        %%------------------------cancel & apply-----------------------------
        gui_erp_resample.advance_help_title = uiextras.HBox('Parent',gui_erp_resample.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_resample.advance_help_title);
        gui_erp_resample.resample_cancel= uicontrol('Style', 'pushbutton','Parent',gui_erp_resample.advance_help_title,...
            'String','Cancel','callback',@resample_cancel,'Enable','off','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_resample.advance_help_title);
        
        gui_erp_resample.resample_run = uicontrol('Style', 'pushbutton','Parent',gui_erp_resample.advance_help_title,'String','Apply',...
            'callback',@resample_run,'FontSize',FonsizeDefault,'Enable','off','BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_resample.advance_help_title);
        set(gui_erp_resample.advance_help_title,'Sizes',[15 105  30 105 15]);
        set(gui_erp_resample.DataSelBox,'Sizes',[30 30 30 30 30]);
        estudioworkingmemory('ERPTab_resample',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------checkbox for new sampling rate------------------------
    function nwsrate_checkbox(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        gui_erp_resample.nwsrate_edit.BackgroundColor = [1 1 1];
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',1);
        gui_erp_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_run.ForegroundColor = [1 1 1];
        box_erp_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_cancel.ForegroundColor = [1 1 1];
        
        if Source.Value==1
            gui_erp_resample.nwsrate_edit.Enable = 'on';
            Newsrate = str2num(gui_erp_resample.nwsrate_edit.String);
            if isempty(Newsrate) || numel(Newsrate)~=1 || any(Newsrate<=0)
                try gui_erp_resample.nwsrate_edit.String = str2num(observe_ERPDAT.ERP.srate); catch end
            end
        else
            gui_erp_resample.nwsrate_edit.Enable = 'off';
        end
    end


%%-------------------------edit new sampling rate--------------------------
    function nwsrate_edit(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',1);
        gui_erp_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_run.ForegroundColor = [1 1 1];
        box_erp_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_cancel.ForegroundColor = [1 1 1];
        Newsrate = str2num(gui_erp_resample.nwsrate_edit.String);
        if isempty(Newsrate) || numel(Newsrate)~=1 ||any(Newsrate<=0)
            msgboxText='Sampling Rate & Epoch: New sampling rate must be a positive value';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
        end
    end

%%-------------------checkbox for new time window--------------------------
    function nwtimewindow_checkbox(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        gui_erp_resample.nwtimewindow_editleft.BackgroundColor = [1 1 1];
        gui_erp_resample.nwtimewindow_editright.BackgroundColor = [1 1 1];
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',1);
        gui_erp_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_run.ForegroundColor = [1 1 1];
        box_erp_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_cancel.ForegroundColor = [1 1 1];
        if Source.Value==1
            gui_erp_resample.nwtimewindow_editleft.Enable ='on';
            gui_erp_resample.nwtimewindow_editright.Enable = 'on';
            NewStart = str2num(gui_erp_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1 || any(NewStart>=observe_ERPDAT.ERP.times(end))
                gui_erp_resample.nwtimewindow_editleft.String = num2str(observe_ERPDAT.ERP.times(1));
            end
            Newend = str2num(gui_erp_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1 || any(Newend<=observe_ERPDAT.ERP.times(1))
                gui_erp_resample.nwtimewindow_editright.String = num2str(observe_ERPDAT.ERP.times(end));
            end
        else
            gui_erp_resample.nwtimewindow_editleft.Enable ='off';
            gui_erp_resample.nwtimewindow_editright.Enable = 'off';
        end
    end

%%--------------------------new epoch start--------------------------------
    function nwtimewindow_editleft(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',1);
        gui_erp_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_run.ForegroundColor = [1 1 1];
        box_erp_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_cancel.ForegroundColor = [1 1 1];
        NewStart = str2num(gui_erp_resample.nwtimewindow_editleft.String);
        if isempty(NewStart) || numel(NewStart)~=1
            msgboxText='Sampling Rate & Epoch: the left edge for the new time window must be a single value';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if NewStart>= observe_ERPDAT.ERP.times(end)
            msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than',32,num2str(observe_ERPDAT.ERP.times(end)),'ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if NewStart< observe_ERPDAT.ERP.times(1)
            msgboxText=['Sampling Rate & Epoch: we will set 0 for the additional time range because the left edge for the new time window is smaller than',32,num2str(observe_ERPDAT.ERP.times(1)),'ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        if NewStart>= 0
            msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than 0 ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        
    end


%%---------------------------new epoch stop--------------------------------
    function nwtimewindow_editright(Source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',1);
        gui_erp_resample.resample_run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_run.ForegroundColor = [1 1 1];
        box_erp_resample.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_resample.resample_cancel.ForegroundColor = [1 1 1];
        Newend = str2num(gui_erp_resample.nwtimewindow_editright.String);
        if isempty(Newend) || numel(Newend)~=1
            msgboxText='Sampling Rate & Epoch: the right edge for the new time window must be a single value';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if Newend<= observe_ERPDAT.ERP.times(1)
            msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than',32,num2str(observe_ERPDAT.ERP.times(1)),'ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        if Newend> observe_ERPDAT.ERP.times(end)
            msgboxText=['Sampling Rate & Epoch: we will set 0 for the additional time range because the right edge for the new time window is larger than',32,num2str(observe_ERPDAT.ERP.times(end)),'ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        
        if Newend<=0
            msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than 0 ms'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Source.String = '';
            return;
        end
        
        
    end

%%--------------------------cancel-----------------------------------------
    function resample_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_resample',0);
        gui_erp_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_run.ForegroundColor = [0 0 0];
        box_erp_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_cancel.ForegroundColor = [0 0 0];
        
        gui_erp_resample.csrate_edit.String = num2str(observe_ERPDAT.ERP.srate);
        gui_erp_resample.ctimewindow_editleft.String = num2str(observe_ERPDAT.ERP.times(1));
        gui_erp_resample.ctimewindow_editright.String = num2str(observe_ERPDAT.ERP.times(end));
        %%------------------new sampling rate--------------------------
        nwsrate_checkboxValue = gui_erp_resample.Paras{1};
        if isempty(nwsrate_checkboxValue) || numel(nwsrate_checkboxValue)~=1 || (nwsrate_checkboxValue~=0 && nwsrate_checkboxValue~=1)
            gui_erp_resample.Paras{1}=0;
            nwsrate_checkboxValue=0;
        end
        gui_erp_resample.nwsrate_checkbox.Value=nwsrate_checkboxValue;
        if nwsrate_checkboxValue==1
            gui_erp_resample.nwsrate_edit.Enable = 'on';
        else
            gui_erp_resample.nwsrate_edit.Enable = 'off';
        end
        gui_erp_resample.nwsrate_edit.String = num2str(gui_erp_resample.Paras{2});
        %%------------------------new-time window-------------------------
        newtwcheckboxValue =   gui_erp_resample.Paras{3};
        if isempty(newtwcheckboxValue) || numel(newtwcheckboxValue)~=1 || (newtwcheckboxValue~=0 && newtwcheckboxValue~=1)
            gui_erp_resample.Paras{3}=0;
            newtwcheckboxValue=0;
        end
        gui_erp_resample.nwtimewindow_checkbox.Value=newtwcheckboxValue;
        if newtwcheckboxValue==1
            gui_erp_resample.nwtimewindow_editleft.Enable ='on';
            gui_erp_resample.nwtimewindow_editright.Enable = 'on';
        else
            gui_erp_resample.nwtimewindow_editleft.Enable ='off';
            gui_erp_resample.nwtimewindow_editright.Enable = 'off';
        end
        gui_erp_resample.nwtimewindow_editleft.String = num2str(gui_erp_resample.Paras{4});
        gui_erp_resample.nwtimewindow_editright.String = num2str(gui_erp_resample.Paras{5});
    end

%%--------------------------Run--------------------------------------------
    function resample_run(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=14
            observe_ERPDAT.erp_between_panels = observe_ERPDAT.erp_between_panels+1;%%call the functions from the other panel
        end
        if gui_erp_resample.nwsrate_checkbox.Value==0 && gui_erp_resample.nwtimewindow_checkbox.Value==0
            msgboxText='Sampling Rate & Epoch: Please select "New sampling rate" or "New epoch"';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        %%Send message to Message panel
        estudioworkingmemory('f_ERP_proces_messg','Sampling Rate & Epoch');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        %%--------------------check new sampling rate----------------------
        Freq2resamp = str2num(gui_erp_resample.nwsrate_edit.String);
        if gui_erp_resample.nwsrate_checkbox.Value==1
            if isempty(Freq2resamp) || numel(Freq2resamp)~=1 ||any(Freq2resamp<=0)
                msgboxText='Sampling Rate & Epoch: New sampling rate must be a positive value';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
        else
            Freq2resamp = [];
        end
        
        %%----------------------------check new time window----------------
        if gui_erp_resample.nwtimewindow_checkbox.Value==1
            NewStart = str2num(gui_erp_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1
                msgboxText='Sampling Rate & Epoch: the left edge for the new time window must be a single value';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if NewStart>= observe_ERPDAT.ERP.times(end)
                msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than',32,num2str(observe_ERPDAT.times(end)),'ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            
            if NewStart>=0
                msgboxText=['Sampling Rate & Epoch: the left edge for the new time window should be smaller than 0 ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            Newend = str2num(gui_erp_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1
                msgboxText='Sampling Rate & Epoch: the right edge for the new time window must be a single value';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if Newend<= observe_ERPDAT.ERP.times(1)
                msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than',32,num2str(observe_ERPDAT.times(1)),'ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
            
            if Newend<= 0
                msgboxText=['Sampling Rate & Epoch: the right edge for the new time window should be larger than 0 ms'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                observe_ERPDAT.Process_messg =2;
                return;
            end
        else
            NewStart = [];
            Newend = [];
        end
        
        estudioworkingmemory('ERPTab_resample',0);
        gui_erp_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_run.ForegroundColor = [0 0 0];
        box_erp_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_cancel.ForegroundColor = [0 0 0];
        gui_erp_resample.Paras{1} = gui_erp_resample.nwsrate_checkbox.Value;
        gui_erp_resample.Paras{2} = str2num(gui_erp_resample.nwsrate_edit.String);
        gui_erp_resample.Paras{3} = gui_erp_resample.nwtimewindow_checkbox.Value;
        gui_erp_resample.Paras{4} = str2num(gui_erp_resample.nwtimewindow_editleft.String);
        gui_erp_resample.Paras{5} = str2num(gui_erp_resample.nwtimewindow_editright.String);
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        estudioworkingmemory('f_ERP_proces_messg','Sampling Rate & Epoch');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = [];  end
        ALLERP = observe_ERPDAT.ALLERP;
        ALLERP_out = [];
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            if gui_erp_resample.nwsrate_checkbox.Value==0
                Freq2resamp =  ERP.srate;
            end
            if gui_erp_resample.nwtimewindow_checkbox.Value==0
                TimeRange = [ERP.times(1),ERP.times(end)];
            else
                TimeRange = [NewStart,Newend];
            end
            [ERP, ERPCOM] = pop_resamplerp(ERP, 'Freq2resamp',Freq2resamp, 'TimeRange',TimeRange,...
                'Saveas', 'off', 'History', 'gui');
            if isempty(ERPCOM)
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if Numoferp == numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if Numoferp==1
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
        end
        
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_resampled');
        if isempty(Answer)
            observe_ERPDAT.Process_messg =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLERP_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP_out(Numoferp);
            if Save_file_label
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                if Numoferp == numel(ERPArray)
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                else
                    [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                end
            else
                ERP.filename = '';
                ERP.saved = 'no';
                ERP.filepath = '';
            end
            ALLERP(length(ALLERP)+1) = ERP;
        end
        observe_ERPDAT.ALLERP = ALLERP;
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        try
            Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=8
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        if ~isempty(observe_ERPDAT.ERP)
            gui_erp_resample.csrate_edit.String = num2str(observe_ERPDAT.ERP.srate);
            gui_erp_resample.ctimewindow_editleft.String = num2str(observe_ERPDAT.ERP.times(1));
            gui_erp_resample.ctimewindow_editright.String = num2str(observe_ERPDAT.ERP.times(end));
        else
            gui_erp_resample.csrate_edit.String = '';
            gui_erp_resample.ctimewindow_editleft.String = '';
            gui_erp_resample.ctimewindow_editright.String = '';
        end
        %%----------------------new sampling rate--------------------------
        gui_erp_resample.nwsrate_checkbox.Enable = Enableflag;
        gui_erp_resample.nwsrate_edit.Enable = Enableflag;
        if strcmp(Enableflag,'on') && gui_erp_resample.nwsrate_checkbox.Value==1
            gui_erp_resample.nwsrate_edit.Enable = 'on';
            Newsrate = str2num(gui_erp_resample.nwsrate_edit.String);
            if isempty(Newsrate) || numel(Newsrate)~=1 || any(Newsrate<=0)
                try gui_erp_resample.nwsrate_edit.String = str2num(observe_ERPDAT.ERP.srate); catch end
            end
        else
            gui_erp_resample.nwsrate_edit.Enable = 'off';
        end
        
        %%--------------------new tiem window------------------------------
        gui_erp_resample.nwtimewindow_checkbox.Enable = Enableflag;
        gui_erp_resample.nwtimewindow_editleft.Enable = Enableflag;
        gui_erp_resample.nwtimewindow_editright.Enable = Enableflag;
        gui_erp_resample.resample_run.Enable = Enableflag;
        gui_erp_resample.resample_cancel.Enable = Enableflag;
        if strcmp(Enableflag,'on') && gui_erp_resample.nwtimewindow_checkbox.Value==1
            gui_erp_resample.nwtimewindow_editleft.Enable ='on';
            gui_erp_resample.nwtimewindow_editright.Enable = 'on';
            NewStart = str2num(gui_erp_resample.nwtimewindow_editleft.String);
            if isempty(NewStart) || numel(NewStart)~=1 || any(NewStart>=observe_ERPDAT.ERP.times(end))
                gui_erp_resample.nwtimewindow_editleft.String = num2str(observe_ERPDAT.ERP.times(1));
            end
            Newend = str2num(gui_erp_resample.nwtimewindow_editright.String);
            if isempty(Newend) || numel(Newend)~=1 || any(Newend<=observe_ERPDAT.ERP.times(1))
                gui_erp_resample.nwtimewindow_editright.String = num2str(observe_ERPDAT.ERP.times(end));
            end
        else
            gui_erp_resample.nwtimewindow_editleft.Enable ='off';
            gui_erp_resample.nwtimewindow_editright.Enable = 'off';
        end
        gui_erp_resample.Paras{1} = gui_erp_resample.nwsrate_checkbox.Value;
        gui_erp_resample.Paras{2} = str2num(gui_erp_resample.nwsrate_edit.String);
        gui_erp_resample.Paras{3} = gui_erp_resample.nwtimewindow_checkbox.Value;
        gui_erp_resample.Paras{4} = str2num(gui_erp_resample.nwtimewindow_editleft.String);
        gui_erp_resample.Paras{5} = str2num(gui_erp_resample.nwtimewindow_editright.String);
        observe_ERPDAT.Count_currentERP=9;
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_resample_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_resample');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            resample_run();
            estudioworkingmemory('ERPTab_resample',0);
            gui_erp_resample.resample_run.BackgroundColor =  [1 1 1];
            gui_erp_resample.resample_run.ForegroundColor = [0 0 0];
            box_erp_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_resample.resample_cancel.BackgroundColor =  [1 1 1];
            gui_erp_resample.resample_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

%%--------------reset this panel with the default parameters---------------
    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=13
            return;
        end
        estudioworkingmemory('ERPTab_resample',0);
        gui_erp_resample.resample_run.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_run.ForegroundColor = [0 0 0];
        box_erp_resample.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_resample.resample_cancel.BackgroundColor =  [1 1 1];
        gui_erp_resample.resample_cancel.ForegroundColor = [0 0 0];
        if ~isempty(observe_ERPDAT.ERP)
            gui_erp_resample.csrate_edit.String = num2str(observe_ERPDAT.ERP.srate);
            gui_erp_resample.ctimewindow_editleft.String = num2str(observe_ERPDAT.ERP.times(1));
            gui_erp_resample.ctimewindow_editright.String = num2str(observe_ERPDAT.ERP.times(end));
        else
            gui_erp_resample.csrate_edit.String = '';
            gui_erp_resample.ctimewindow_editleft.String = '';
            gui_erp_resample.ctimewindow_editright.String = '';
        end
        gui_erp_resample.nwsrate_checkbox.Value=0;
        gui_erp_resample.nwsrate_edit.Enable = 'off';
        gui_erp_resample.nwsrate_edit.String='';
        gui_erp_resample.nwtimewindow_editleft.Enable ='off';
        gui_erp_resample.nwtimewindow_editright.Enable = 'off';
        gui_erp_resample.nwtimewindow_checkbox.Value=0;
        gui_erp_resample.nwtimewindow_editleft.String ='';
        gui_erp_resample.nwtimewindow_editright.String = '';
        observe_ERPDAT.Reset_erp_paras_panel=14;
    end

end