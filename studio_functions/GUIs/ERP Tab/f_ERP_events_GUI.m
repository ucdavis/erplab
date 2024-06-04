%%This function is operation for EventList

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024


function varargout = f_ERP_events_GUI(varargin)

global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
%---------------------------Initialize parameters------------------------------------

erptab_events = struct();

%-----------------------------Name the title----------------------------------------------
% global eegtab_events_box;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    eegtab_events_box = uiextras.BoxPanel('Parent', fig, 'Title', 'EventList', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    eegtab_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EventList', 'Padding', 5,...
        'BackgroundColor',ColorB_def);
else
    eegtab_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EventList', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @event_help
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

drawui_erp_events(FonsizeDefault)
varargout{1} = eegtab_events_box;

    function drawui_erp_events(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        erptab_events.DataSelBox = uiextras.VBox('Parent', eegtab_events_box,'BackgroundColor',ColorB_def);
        EnableFlag= 'off';
        
        %%Create Eventlist and Import
        erptab_events.create_rt_title = uiextras.HBox('Parent',erptab_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        erptab_events.imp_eventlist = uicontrol('Style', 'pushbutton','Parent', erptab_events.create_rt_title ,...
            'String','Import .txt','callback',@imp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        erptab_events.exp_eventlist = uicontrol('Style', 'pushbutton','Parent', erptab_events.create_rt_title,...
            'String','Export .txt','callback',@exp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        erptab_events.exp_rt = uicontrol('Style', 'pushbutton','Parent',  erptab_events.create_rt_title ,...
            'String','Export RTs','callback',@exp_rt,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%export eventlist
        erptab_events.imp_exp_title = uiextras.HBox('Parent',erptab_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        erptab_events.imp_eventlist_exc = uicontrol('Style', 'pushbutton','Parent', erptab_events.imp_exp_title ,...
            'String','Import .xls','callback',@imp_eventlist_exc,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        erptab_events.exp_eventlist_exc = uicontrol('Style', 'pushbutton','Parent', erptab_events.imp_exp_title,...
            'String','Export .xls','callback',@exp_eventlist_exc,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        erptab_events.vieweventlist = uicontrol('Style', 'pushbutton','Parent', erptab_events.imp_exp_title,...
            'String','View ','callback',@vieweventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        set(erptab_events.DataSelBox,'Sizes',[30 30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%----------------Export reaction times to text file-----------------------
    function exp_rt(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export RTs');
        observe_ERPDAT.Process_messg =1;
        
        if ~isfield(observe_ERPDAT.ERP,'EVENTLIST')
            msgboxText = ['EventList >  Export RTs: No EVETLIST, please create one first'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return;
        end
        
        def  = estudioworkingmemory('pop_rt2text');
        if isempty(def)
            def = {'' 'basic' 'on' 'off' 1};
        end
        
        e2 = length(observe_ERPDAT.ERP.EVENTLIST);
        
        %
        % Call Gui
        %
        param  = saveRTGUI(def, e2);
        
        if isempty(param)
            observe_ERPDAT.Process_messg =2;
            return
        end
        filenamei  = param{1};
        listformat = param{2};
        header     = param{3};  % 1 means include header (name of variables)
        arfilt     = param{4};  % 1 means filter out RTs with marked flags
        indexel    = param{5};  % index for eventlist
        [pathx, filename, ext] = fileparts(filenamei);
        if header==1
            headstr = 'on';
        else
            headstr = 'off';
        end
        if arfilt==1
            arfilter = 'on';
        else
            arfilter = 'off';
        end
        estudioworkingmemory('pop_rt2text', {fullfile(pathx, filename), listformat, headstr, arfilter, indexel});
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = [];  end
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        for Numoferp = 1:numel(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            if ~isfield(ERP, 'EVENTLIST')
                estudioworkingmemory('f_ERP_proces_messg','EventList >  Export RTs:EVENTLIST structure is empty');
                observe_ERPDAT.Process_messg =2;
            else
                filenameeeg = ERP.filename;
                [pathxeeg, filenameeeg, ext] = fileparts(filenameeeg);
                if isempty(filenameeeg)
                    filename = [num2str(ERPArray(Numoferp)),'_',filename,'.txt'];
                else
                    filename = strcat(filenameeeg,'_',filename,'.txt');
                end
                filename = fullfile(pathx, filename);
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current ERPset(No.',num2str(ERPArray(Numoferp)),'):',32,ERP.erpname,'\n\n']);
                fprintf(['The exported file name:',32,filename,'\n\n']);
                
                [ERP,values, ERPCOM] = pop_rt2text(ERP, 'filename', filename, 'listformat', listformat, 'header', headstr,...
                    'arfilter', arfilter, 'eventlist', indexel, 'History', 'gui');
                
                if ~isempty( values)
                    if Numoferp ==numel(ERPArray)
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                    else
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    end
                    observe_ERPDAT.ALLERP(ERPArray(Numoferp)) =ERP;
                else
                    fprintf(2,['Cannot export reaction times for:',32,ERP.erpname,'\n']);
                    fprintf( [repmat('-',1,100) '\n']);
                end
            end
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        try assignin('base','ERPCOM',ERPCOM);catch  end;
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export RTs');
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP=1;
    end


%%-------------------View eventlist----------------------------------------
    function vieweventlist(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        estudioworkingmemory('f_ERP_proces_messg','EventList >  View EventList');
        observe_ERPDAT.Process_messg =1;
        
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = [];  end
        
        ALLERP = observe_ERPDAT.ALLERP;
        [ALLERP, ERPCOM] = pop_erp_eventlist_view( ALLERP, 'ERPArray',ERPArray,...
            'Saveas', 'off', 'History', 'script');
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*ERP Tab>Eventlist>View*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf([ERPCOM]);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        for Numoferp = 1:numel(ERPArray)
            if Numoferp ==length(ERPArray)
                [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM, ERPCOM,2);
            else
                [observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(ERPArray(Numoferp)), ALLERPCOM, ERPCOM,1);
            end
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        observe_ERPDAT.Count_currentERP = 20;
        observe_ERPDAT.Process_messg =2;
    end


%%--------------------import EEG eventlist from text file--------------------
    function imp_eventlist(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Import');
        observe_ERPDAT.Process_messg =1;
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = '';  end
        ALLERP = observe_ERPDAT.ALLERP;
        ALLERP_out = [];
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(ERPArray(Numoferp)),'):',32,ERP.erpname,'\n\n']);
            
            %% Run pop_ command again with the inputs from the GUI
            [filename,pathname] = uigetfile({'*.txt*'},['Select a EVENTLIST file for erpset:',32,num2str(ERPArray(Numoferp))]);
            ELfullname = fullfile(pathname, filename);
            
            if isequal(filename,0)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                observe_ERPDAT.Process_messg =2;
                return
            else
                disp(['For read an EVENTLIST, user selected ', ELfullname])
            end
            [ERP, ERPCOM] = pop_importerpeventlist( ERP, ELfullname , 'ReplaceEventList', 'replace' , 'Saveas', 'off', 'History', 'gui');
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            fprintf([ERPCOM]);
            if Numoferp==1
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
            fprintf( ['\n',repmat('-',1,100) '\n\n']);
        end
        
        Save_file_label = 0;
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray), '_impel');
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
                if Numoferp ==numel(ERPArray)
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
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        
        observe_ERPDAT.ALLERP = ALLERP;
        try
            Selected_EEG_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_EEG_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_EEG_afd);
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end


%%--------------------export EEG eventlist to text file--------------------
    function exp_eventlist(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export eventlist');
        observe_ERPDAT.Process_messg =1;
        
        if ~isfield(observe_ERPDAT.ERP,'EVENTLIST') || isempty(observe_ERPDAT.ERP.EVENTLIST)
            msgboxText =  ['EventList >Export eventlist: Please check the current EEG.EVENTLIST'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return;
        end
        
        [fname, pathname] = uiputfile({'*.txt*'},'Save EVENTLIST file as (This will be suffix when using EStudio)');
        
        if isequal(fname,0)
            observe_ERPDAT.Process_messg =2;
            return
        end
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        [xpath, suffixstr, ext] = fileparts(fname);
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        
        
        for Numoferp = 1:numel(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            msgboxText = '';
            if isfield(ERP, 'EVENTLIST')
                if isempty(ERP.EVENTLIST)
                    msgboxText =  ['ERP.EVENTLIST structure is empty'];
                end
                if isfield(ERP.EVENTLIST, 'eventinfo')
                    if isempty(ERP.EVENTLIST.eventinfo)
                        msgboxText =  ['ERP.EVENTLIST.eventinfo structure is empty'];
                    end
                else
                    msgboxText =  ['ERP.EVENTLIST.eventinfo structure is empty'];
                end
            else
                msgboxText =  ['ERP.EVENTLIST structure is empty'];
            end
            
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current ERPset(No.',num2str(ERPArray(Numoferp)),'):',32,ERP.erpname,'\n\n']);
            if isempty(msgboxText)
                if numel(ERPArray) >1
                    filenameeg = ERP.filename;
                    [xpatheeg, filenameeg, exteeg] = fileparts(filenameeg);
                    if isempty(filenameeg)
                        filenameeg = strcat(num2str(ERPArray(Numoferp)),'_',suffixstr,'.txt');
                    else
                        filenameeg = strcat(filenameeg,'_',suffixstr,'.txt');
                    end
                else
                    filenameeg = [suffixstr,'.txt'];
                end
                filenameeg = fullfile(pathname, filenameeg);
                
                disp(['For EVENTLIST output user selected ', filenameeg])
                [ERP, ERPCOM] = pop_exporterpeventlist( ERP , 'ELIndex', 1, 'Filename', filenameeg,'History','gui');
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                assignin('base','ALLERPCOM',ALLERPCOM);
                assignin('base','ERPCOM',ERPCOM);
                observe_ERPDAT.ALLERP(ERPArray(Numoferp)) =ERP;
            else
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                fprintf(2,['Cannot export eventlist for:',32,ERP.erpname,'\n']);
                fprintf( [repmat('-',1,100) '\n']);
            end
        end
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export eventlist');
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP=1;
    end


%%--------------------import EEG eventlist from .xls file--------------------
    function imp_eventlist_exc(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Import');
        observe_ERPDAT.Process_messg =1;
        
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        
        try ALLERPCOM = evalin('base','ALLERPCOM'); catch  ALLERPCOM = [];end
        ALLERP = observe_ERPDAT.ALLERP;
        ALLERP_out = [];
        for Numoferp = 1:numel(ERPArray)
            ERP = ALLERP(ERPArray(Numoferp));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(ERPArray(Numoferp)),'):',32,ERP.erpname,'\n\n']);
            
            %% Run pop_ command again with the inputs from the GUI
            [filename,pathname] = uigetfile({'*.xls*';'*.xlsx*'},['Select a EVENTLIST file for erpset:',32,num2str(ERPArray(Numoferp))]);
            ELfullname = fullfile(pathname, filename);
            
            if isequal(filename,0)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                observe_ERPDAT.Process_messg =2;
                return
            else
                disp(['For read an EVENTLIST, user selected ', ELfullname])
            end
            
            [ERP, ERPCOM] = pop_importerpeventlist( ERP, ELfullname , 'ReplaceEventList', 'replace' , 'Saveas', 'off', 'History', 'gui');
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            if Numoferp==1
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
        end
        
        
        Save_file_label = 0;
        Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray), '_impel');
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
                if Numoferp ==numel(ERPArray)
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
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ALLERP = ALLERP;
        try
            Selected_EEG_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
        catch
            Selected_EEG_afd = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',Selected_EEG_afd);
        
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end

%%----------------------------Export eventlist to xls----------------------
    function exp_eventlist_exc(Source,~)
        if isempty(observe_ERPDAT.ERP)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export eventlist to .xls file');
        observe_ERPDAT.Process_messg =1;
        
        if ~isfield(observe_ERPDAT.ERP,'EVENTLIST') || isempty(observe_ERPDAT.ERP.EVENTLIST)
            msgboxText =  ['EventList >Export eventlist: Please check the current EEG.EVENTLIST'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        [fname, pathname] = uiputfile({'*.xls*';'*.xlsx*'},'Save EVENTLIST file as (This will be suffix when using EStudio)');
        if isequal(fname,0)
            observe_ERPDAT.Process_messg =2;
            return
        end
        ERPArray =  estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray) ||  any(ERPArray(:) > length(observe_ERPDAT.ALLERP)) ||  any(ERPArray(:) <1)
            ERPArray =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
        end
        [xpath, suffixstr, ext] = fileparts(fname);
        try ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM = []; end
        
        for Numoferp = 1:numel(ERPArray)
            ERP = observe_ERPDAT.ALLERP(ERPArray(Numoferp));
            msgboxText = '';
            if isfield(ERP, 'EVENTLIST')
                if isempty(ERP.EVENTLIST)
                    msgboxText =  ['ERP.EVENTLIST structure is empty'];
                end
                if isfield(ERP.EVENTLIST, 'eventinfo')
                    if isempty(ERP.EVENTLIST.eventinfo)
                        msgboxText =  ['ERP.EVENTLIST.eventinfo structure is empty'];
                    end
                else
                    msgboxText =  ['ERP.EVENTLIST.eventinfo structure is empty'];
                end
            else
                msgboxText =  ['ERP.EVENTLIST structure is empty'];
            end
            
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current ERPset(No.',num2str(ERPArray(Numoferp)),'):',32,ERP.erpname,'\n\n']);
            if isempty(msgboxText)
                if numel(ERPArray) >1
                    filenameeg = ERP.filename;
                    [xpatheeg, filenameeg, exteeg] = fileparts(filenameeg);
                    if isempty(filenameeg)
                        filenameeg = strcat(num2str(ERPArray(Numoferp)),'_',suffixstr,'.xls');
                    else
                        filenameeg = strcat(filenameeg,'_',suffixstr,'.xls');
                    end
                else
                    filenameeg = [suffixstr,'.xls'];
                end
                filenameeg = fullfile(pathname, filenameeg);
                
                disp(['For EVENTLIST output user selected ', filenameeg])
                [ERP, ERPCOM] = pop_exporterpeventlist( ERP , 'ELIndex', 1, 'Filename', filenameeg,'History','gui');
                
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                assignin('base','ALLERPCOM',ALLERPCOM);
                assignin('base','ERPCOM',ERPCOM);
                observe_ERPDAT.ALLERP(ERPArray(Numoferp)) =ERP;
            else
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                fprintf(2,['Cannot export eventlist for:',32,ERP.erpname,'\n']);
                fprintf( [repmat('-',1,100) '\n']);
            end
        end
        estudioworkingmemory('f_ERP_proces_messg','EventList >  Export eventlist');
        observe_ERPDAT.Count_currentERP=1;
        observe_ERPDAT.Process_messg =2;
    end



%%--------Settting will be modified if the selected was changed------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP ~=15
            return;
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_ERPDAT.ERP) || ~isfield(observe_ERPDAT.ERP,'EVENTLIST') || ViewerFlag==1
            EnableFlag = 'off';
            erptab_events.exp_rt.Enable=EnableFlag;
            erptab_events.imp_eventlist.Enable=EnableFlag;
            erptab_events.exp_eventlist.Enable=EnableFlag;
            erptab_events.vieweventlist.Enable=EnableFlag;
            erptab_events.imp_eventlist_exc.Enable=EnableFlag;
            erptab_events.exp_eventlist_exc.Enable=EnableFlag;
            observe_ERPDAT.Count_currentERP=16;
            return;
        end
        
        eegtab_events_box.Title = 'EventList';
        eegtab_events_box.ForegroundColor= [1 1 1];
        
        if ~isempty(observe_ERPDAT.ERP)
            EnableFlag ='on';
        else
            EnableFlag ='off';
        end
        
        %%export reaction times
        erptab_events.exp_rt.Enable=EnableFlag;
        %%Import and export eventlist
        erptab_events.imp_eventlist.Enable=EnableFlag;
        erptab_events.imp_eventlist_exc.Enable=EnableFlag;
        
        if isfield(observe_ERPDAT.ERP,'EVENTLIST') && ~isempty(observe_ERPDAT.ERP.EVENTLIST)
            erptab_events.vieweventlist.Enable='on';
            erptab_events.exp_eventlist.Enable='on';
            erptab_events.exp_eventlist_exc.Enable='on';
        else
            erptab_events.vieweventlist.Enable='off';
            erptab_events.exp_eventlist.Enable='off';
            erptab_events.exp_eventlist_exc.Enable='off';
        end
        observe_ERPDAT.Count_currentERP=16;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=1;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.set'];
if exist(filenamex, 'file')~=0
    msgboxText =  ['This EEG Data already exist.\n'...;
        'Would you like to overwrite it?'];
    title  = 'Estudio: WARNING!';
    button = askquest(sprintf(msgboxText), title);
    if strcmpi(button,'no')
        checkfileindex=0;
    else
        checkfileindex=1;
    end
end
end
