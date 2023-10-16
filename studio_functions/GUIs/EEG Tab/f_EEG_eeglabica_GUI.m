%%This function is to do the works about ICA in EGELAB

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_eeglabica_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_eeglab_ica = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_eeglab_ica;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_eeglab_ica = uiextras.BoxPanel('Parent', fig, 'Title', 'EEGLAB ICA (works on one selected dataset)', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_eeglab_ica = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGLAB ICA (works on one selected dataset)', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_eeglab_ica = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGLAB ICA (works on one selected dataset)', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_event2bin_eeg(FonsizeDefault)
varargout{1} = EStudio_box_eeglab_ica;

    function drawui_event2bin_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_eegtab_eeglab_ica.DataSelBox = uiextras.VBox('Parent', EStudio_box_eeglab_ica,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%About this dataset and dataset information
        EStduio_eegtab_eeglab_ica.decomp_labelic_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_ica.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_eeglab_ica.icadecomp_eeg = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.decomp_labelic_title,...
            'String','Decompose data','callback',@icadecomp_eeg,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_ica.inslabel_ics = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.decomp_labelic_title,...
            'String','Inspect/label ICs','callback',@inslabel_ics,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        
        %%Edit eeg events and channel locations
        EStduio_eegtab_eeglab_ica.event_chanlocs_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_ica.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_ica.classifyics_iclabel = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.event_chanlocs_title,...
            'String','Classify IC by ICLabel','callback',@classifyics_iclabel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_ica.remove_ics = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.event_chanlocs_title,...
            'String','Remove ICs','callback',@remove_ics,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%Plot channel function
        EStduio_eegtab_eeglab_ica.plotic_title1 = uiextras.HBox('Parent', EStduio_eegtab_eeglab_ica.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', EStduio_eegtab_eeglab_ica.plotic_title1,...
            'String','Plot independent components:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_eeglab_ica.plotic_title2 = uiextras.HBox('Parent', EStduio_eegtab_eeglab_ica.DataSelBox, 'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_ica.eeg_spcetra_map = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.plotic_title2,...
            'String','Spectra & maps','callback',@eeg_spcetra_map,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_ica.ic_maps_2d = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.plotic_title2,...
            'String','Maps (2-D)','callback',@maps_2d,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_ica.ic_maps_3d = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.plotic_title2,...
            'String','Maps (3-D)','callback',@maps_3d,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        EStduio_eegtab_eeglab_ica.plotic_title3 = uiextras.HBox('Parent', EStduio_eegtab_eeglab_ica.DataSelBox, 'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_ica.eeg_ic_prop = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.plotic_title3,...
            'String','IC Properties','callback',@eeg_ic_prop,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_ica.eeg_ic_tfr = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_ica.plotic_title3,...
            'String','IC Time-frequency','callback',@eeg_ic_tfr,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set(EStduio_eegtab_eeglab_ica.DataSelBox,'Sizes',[30 30 20 30 30])
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-----------------Decompose the data by ICA-------------------------------
    function icadecomp_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Decompose data');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Decompose data: Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
            Source.Enable = 'off';
            return;
        end
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_ica');
        if isempty(Answer)
            beep;
            disp('User selected Cancel');
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_advance(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                %%Run ICA
                [EEG, LASTCOM]  =pop_runica( EEG);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Decompose data: Please check you data or you selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    return;
                end
                EEG = eegh(LASTCOM, EEG);
                fprintf(['\n',LASTCOM,'\n']);
                if Save_file_label
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                fprintf(['\n ICA was done for eeg dataset (No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            return;
        end
    end


%%--------------------Inspect/label ICs------------------------------------
    function inslabel_ics(Source,~)%%Need to check again
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Inspect/label ICs');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Inspect/label ICs:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Inspect/label ICs*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                [~,LASTCOM] =  pop_selectcomps(EEG);%%somthing goes wrong
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Inspect/label ICs:User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    return;
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            assignin('base','EEG',observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)));
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Inspect/label ICs');
            observe_EEGDAT.eeg_panel_message =2;
            erpworkingmemory('eegicinspectFlag',1);
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            erpworkingmemory('eegicinspectFlag',0);
            return;
        end
        
    end

%%-----------------Classify ICs by ICLabel---------------------------------
    function classifyics_iclabel(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Classify IC by ICLabel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Classify IC by ICLabel:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*Classify IC by ICLabel*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                EEG = f_estudio_iclabel(EEG,EEGArray(Numofeeg));
                if isempty(EEG)
                    observe_EEGDAT.eeg_panel_message =4;
                    return;
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Classify IC by ICLabel');
            observe_EEGDAT.eeg_panel_message =2;
        catch
            
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
        
    end

%%-------------------Remove ICs--------------------------------------------
    function remove_ics(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Remove ICs');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Remove ICs:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_rmic');
        if isempty(Answer)
            beep;
            disp('User selected Cancel');
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_advance = Answer{1};
            Save_file_label = Answer{2};
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_advance(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf( ['**Remove ICs**\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                
                if ~isempty(EEG.reject.gcompreject)
                    components = find(EEG.reject.gcompreject == 1);
                    components = components(:)';
                    %promptstr    = { ['Components to subtract from data' 10 '(default: pre-labeled components to reject):'] };
                else
                    components = [];
                end
                uilist    = { { 'style' 'text' 'string' 'Note: for group level analysis, remove components in STUDY' } ...
                    { 'style' 'text' 'string' 'List of component(s) to remove from data' } ...
                    { 'style' 'edit' 'string' int2str(components) } ...
                    { 'style' 'text' 'string' 'Or list of component(s) to retain' } ...
                    { 'style' 'edit' 'string' '' } ...
                    };
                geom = { 1 [2 0.7] [2 0.7] };
                result       = inputgui( 'uilist', uilist, 'geometry', geom, 'helpcom', 'pophelp(''pop_subcomp'')', ...
                    'title', ['eegset',32,num2str(EEGArray(Numofeeg)),':Remove IC -- pop_subcomp()']);
                if length(result) == 0
                    disp('User selected cancel');
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                components   = eval( [ '[' result{1} ']' ] );
                if ~isempty(result{2})
                    componentsOld = components;
                    components   = eval( [ '[' result{2} ']' ] );
                    if isequal(components, componentsOld)
                        components = [];
                    end
                    keepcomp = 1; %components  = setdiff_bc([1:size(EEG.icaweights,1)], components);
                else
                    keepcomp = 0;
                end
                plotag = 0;
                [EEG, LASTCOM] = pop_subcomp( EEG, components, plotag, keepcomp);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > Remove ICs:User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    return;
                end
                EEG = eegh(LASTCOM, EEG);
                fprintf(['\n',LASTCOM,'\n']);
                if Save_file_label
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                if keepcomp==1
                    components  = setdiff_bc([1:size(EEG.icaweights,1)], components);
                end
                [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
                fprintf(['\n ICs [',32,num2str(components),32, '] have been removed from eeg dataset (No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end
            
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =2;
        catch
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is errros in processing procedure
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            return;
        end
        
    end

%%---------------------IC maps 2D------------------------------------------
    function maps_2d(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 2-D');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 2-D:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            Source.Enable = 'off';
            return;
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*IC maps in 2-D*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                LASTCOM= pop_topoplot(EEG, 0);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 2-D:User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                set(gcf,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': IC maps in 2-D for',32,EEG.setname],'NumberTitle', 'off');
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            try  observe_EEGDAT.eeg_panel_message =2; catch end;
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            try observe_EEGDAT.eeg_panel_message =3; catch  end;%%There is erros in processing procedure
            return;
        end
        
    end


%%---------------------IC maps 3D------------------------------------------
    function maps_3d(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 3-D');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 3-D:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            Source.Enable = 'off';
            return;
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*IC maps in 3-D*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                [~, LASTCOM] = pop_headplot( EEG,0);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC maps in 3-D:User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                set(gcf,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': IC maps in 3-D for',32,EEG.setname],'NumberTitle', 'off');
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            observe_EEGDAT.eeg_panel_message =2;
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
    end



%%----------------------Spectra and maps-----------------------------------
    function eeg_spcetra_map(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC spectra and maps');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC spectra and maps:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            Source.Enable = 'off';
            return;
        end
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*IC spectra and maps*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                LASTCOM= pop_spectopo(EEG,0);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC spectra and maps:User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    return;
                end
                set(gcf,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': IC spectra and maps for',32,EEG.setname],'NumberTitle', 'off');
                LASTCOM = LASTCOM(8:end);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            observe_EEGDAT.eeg_panel_message =2;
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end 
    end


%%---------------------Channel properties----------------------------------
    function eeg_ic_prop(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC properties');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC properties:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            Source.Enable = 'off';
            return;
        end
        try
            EEG = observe_EEGDAT.EEG;
            typecomp = 0;    % defaults
            chanorcomp = 0;
            commandchan = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on'', ''selectionmode'', ''single''); set(findobj(gcbf, ''tag'', ''chan''), ''string'',tmpval); clear tmp tmpchanlocs tmpval';
            uitext = { { 'style' 'text' 'string' fastif(typecomp,'Channel index(ices) to plot:','Component index(ices) to plot:') } ...
                { 'style' 'edit' 'string' '1', 'tag', 'chan' } ...
                { 'style' 'pushbutton' 'string'  '...', 'enable' fastif(~isempty(EEG(1).chanlocs) && typecomp, 'on', 'off') 'callback' commandchan } ...
                { 'style' 'text' 'string' 'Spectral options (see spectopo() help):' } ...
                { 'style' 'edit' 'string' '''freqrange'', [2 50]' } {} };
            uigeom = { [2 1 0.5 ] [2 1 0.5] };
            result = inputgui('geometry', uigeom, 'uilist', uitext, 'helpcom', 'pophelp(''pop_prop'');', ...
                'title', fastif( typecomp, 'IC properties - pop_prop()', 'Component properties - pop_prop()'));
            if size( result, 1 ) == 0
                erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC properties:User selected cancel');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                return;
            end
            
            chanoristr = result{1};
            try
                chanorcomp   = eeg_decodechan(EEG.chanlocs, result{1} );
            catch
                fprintf( 2,['\n EEGLAB Tools > IC properties: IC index out of range, we therefore set it to 1.\n']);
                chanorcomp = 1;
            end
            
            spec_opt     = eval( [ '{' result{2} '}' ] );
            if isempty(chanorcomp)
                erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > IC properties:Please define IC index(ices)');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                return;
            end
            
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                if typecomp == 0 && isempty(EEG.icaweights)
                    Messa = ['eegset',32,num2str(EEGArray(Numofeeg)),':No ICA weights recorded for this dataset -- first run ICA on it'];
                    erpworkingmemory('f_EEG_proces_messg',Messa);
                    observe_EEGDAT.eeg_panel_message =4; %%Marking for the procedure has been started.
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    return;
                end
                if min(chanorcomp(:)) > numel(EEG.icachansind) || max(chanorcomp(:)) > numel(EEG.icachansind)
                    fprintf( ['\n One or more defined IC index(ices) cannot be found, we therefore set it to 1\n']);
                    chanorcomp = 1;
                end
                
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*IC properties*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                for Numofchan = 1:numel(chanorcomp)
                    LASTCOM =  pop_prop( EEG, 0, chanorcomp(Numofchan), NaN, spec_opt);
                    set(gcf,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': IC properties for',32,EEG.setname],'NumberTitle', 'off');
                end
                LASTCOM = sprintf('pop_prop( EEG, %d, %s, NaN, %s);', typecomp, ['[',num2str(chanorcomp),']'], vararg2str( { spec_opt } ) );
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC properties');
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            observe_EEGDAT.eeg_panel_message =2;
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
    end


%%------------------------Time-frequency-----------------------------------
    function eeg_ic_tfr(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC Time-frequency');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC Time-frequency:Only works on one selected dataset');
            observe_EEGDAT.eeg_panel_message =4;
            Source.Enable = 'off';
            return;
        end
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['*IC time-frequency*',32,32,32,32,datestr(datetime('now')),'\n']);
                fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
                
                LASTCOM =  pop_newtimef(EEG,0);
                if isempty(LASTCOM)
                    erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC Time-frequency: User selected cancel');
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n',repmat('-',1,100) '\n']);
                    return;
                end
                set(gcf,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': IC Time-frequency for',32,EEG.setname],'NumberTitle', 'off');
                LASTCOM =LASTCOM(8:end);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
                fprintf( ['\n',repmat('-',1,100) '\n']);
            end%%end loop for subject
            %             observe_EEGDAT.count_current_eeg=1;%%donot need to replot eeg
            %         wave in the main GUI
            erpworkingmemory('f_EEG_proces_messg','EEGLAB ICA > IC Time-frequency');
            observe_EEGDAT.eeg_panel_message =2;
        catch
            %             observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_panel_message =3;%%There is erros in processing procedure
            return;
        end
        
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            EStduio_eegtab_eeglab_ica.icadecomp_eeg.Enable  = 'off';
            EStduio_eegtab_eeglab_ica.inslabel_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.classifyics_iclabel.Enable= 'off';
            EStduio_eegtab_eeglab_ica.remove_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_spcetra_map.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_2d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_3d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_prop.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_tfr.Enable= 'off';
            return;
        end
        
        if observe_EEGDAT.count_current_eeg ~=10
            return;
        end
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)~=1
            EStduio_eegtab_eeglab_ica.icadecomp_eeg.Enable  = 'off';
            EStduio_eegtab_eeglab_ica.inslabel_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.classifyics_iclabel.Enable= 'off';
            EStduio_eegtab_eeglab_ica.remove_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_spcetra_map.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_2d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_3d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_prop.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_tfr.Enable= 'off';
            observe_EEGDAT.count_current_eeg=11;
            return;
        end
        
        if isempty(observe_EEGDAT.EEG.icachansind)
            EStduio_eegtab_eeglab_ica.icadecomp_eeg.Enable  = 'on';
            EStduio_eegtab_eeglab_ica.inslabel_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.classifyics_iclabel.Enable= 'off';
            EStduio_eegtab_eeglab_ica.remove_ics.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_spcetra_map.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_2d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.ic_maps_3d.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_prop.Enable= 'off';
            EStduio_eegtab_eeglab_ica.eeg_ic_tfr.Enable= 'off';
        else
            EStduio_eegtab_eeglab_ica.icadecomp_eeg.Enable  = 'on';
            EStduio_eegtab_eeglab_ica.inslabel_ics.Enable= 'on';
            EStduio_eegtab_eeglab_ica.classifyics_iclabel.Enable= 'on';
            EStduio_eegtab_eeglab_ica.remove_ics.Enable= 'on';
            EStduio_eegtab_eeglab_ica.eeg_spcetra_map.Enable= 'on';
            EStduio_eegtab_eeglab_ica.ic_maps_2d.Enable= 'on';
            EStduio_eegtab_eeglab_ica.ic_maps_3d.Enable= 'on';
            EStduio_eegtab_eeglab_ica.eeg_ic_prop.Enable= 'on';
            EStduio_eegtab_eeglab_ica.eeg_ic_tfr.Enable= 'on';
        end
        %%CHECK IF ICLABEL EXISTS
        if ~exist('ICLabel','dir') && ~exist('eegplugin_iclabel', 'file')
            fprintf(2, 'Warning: ICLabel default plugin missing (probably due to downloading zip file from Github). Install manually.\n');
            EStduio_eegtab_eeglab_ica.classifyics_iclabel.Enable= 'off';
        end
        observe_EEGDAT.count_current_eeg=11;
    end
end