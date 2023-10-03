%%This function is to detect artifacts for epoched EEG.


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_arf_det_epoch_GUI(varargin)

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

Eegtab_EEG_art_det_sum = struct();

%-----------------------------Name the title----------------------------------------------
% global Eegtab_box_art_det_sum;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', fig, 'Title', 'Artifact Detection in epoched EEG', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection in epoched EEG', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    Eegtab_box_art_det_sum = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Artifact Detection in epoched EEG', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_art_det_sum_eeg(FonsizeDefault)
varargout{1} = Eegtab_box_art_det_sum;

    function drawui_art_det_sum_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        Eegtab_EEG_art_det_sum.DataSelBox = uiextras.VBox('Parent', Eegtab_box_art_det_sum,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%display original data?
        Eegtab_EEG_art_det_sum.art_det_title = uiextras.HBox('Parent', Eegtab_EEG_art_det_sum.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',Eegtab_EEG_art_det_sum.art_det_title,...
            'String','Dete. Algorithms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        Eegtab_EEG_art_det_sum.det_algo = uicontrol('Style', 'popupmenu','Parent',Eegtab_EEG_art_det_sum.art_det_title,...
            'String','','callback',@det_algo,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        Det_algostr = {'Simple voltage threshold','Moving window peak-to-peak threshold',...
            'Blink rejection (alpha version)','Step-like artifacts',...
            'Sample to sample voltage threshold','Rate of change-time derivative (alpha version)',...
            'Blocking & flat line'};
        Eegtab_EEG_art_det_sum.det_algo.String = Det_algostr;
        Eegtab_EEG_art_det_sum.det_algo.Value =1;
        set(Eegtab_EEG_art_det_sum.art_det_title, 'Sizes',[100 -1]);
        
        
        
        %         set(Eegtab_EEG_art_det_sum.DataSelBox,'Sizes',[25 30 30 30 30 30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------Artifact detection algorithms-------------------------
    function det_algo(Source,~)
        
        
        
        
    end




%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials ==1
            Eegtab_EEG_art_det_sum.det_algo.Enable= 'off';
             if observe_EEGDAT.EEG.trials ==1
               observe_EEGDAT.count_current_eeg=13;  
             end
            return;
        end
        
        if observe_EEGDAT.count_current_eeg ~=12
            return;
        end
        Eegtab_EEG_art_det_sum.det_algo.Enable= 'on';
        
        observe_EEGDAT.count_current_eeg=13;
    end

end