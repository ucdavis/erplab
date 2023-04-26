%%This function is to plot the panel for "Viewer properties".

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022


function varargout = f_ERP_otherset_waveviewer_GUI(varargin)

global viewer_ERPDAT;
addlistener(viewer_ERPDAT,'count_loadproper_change',@count_loadproper_change);
% addlistener(viewer_ERPDAT,'Process_messg_change',@Process_messg_change);
addlistener(viewer_ERPDAT,'count_twopanels_change',@count_twopanels_change);
addlistener(viewer_ERPDAT,'Reset_Waviewer_panel_change',@Reset_Waviewer_panel_change);


gui_otherset_waveviewer = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erplabelset_viewer_otherset;
[version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    box_erplabelset_viewer_otherset = uiextras.BoxPanel('Parent', fig, 'Title', 'Other', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12); % Create boxpanel
elseif nargin == 1
    box_erplabelset_viewer_otherset = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Other', 'Padding', 5,...
        'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w','FontSize',12);
else
    box_erplabelset_viewer_otherset = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Other', 'Padding', 5, ...
        'FontSize', varargin{2},'BackgroundColor',ColorBviewer_def,'TitleColor',[0.5 0.5 0.9],'ForegroundColor','w');
end
%-----------------------------Draw the panel-------------------------------------

drawui_otherset_waviewer();
varargout{1} = box_erplabelset_viewer_otherset;

    function drawui_otherset_waviewer()
        [version reldate,ColorB_def,ColorF_def,errorColorF_def,ColorBviewer_def] = geterplabstudiodef;
        
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            beep;
            disp('f_ERP_lineset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        gui_otherset_waveviewer.DataSelBox = uiextras.VBox('Parent', box_erplabelset_viewer_otherset,'BackgroundColor',ColorBviewer_def);
        %%----------Polarity Setting---------------------------------------
        Polaritylabel = 1;
        gui_otherset_waveviewer.polarity_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_otherset_waveviewer.polarity_title,'String','Polarity',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','left'); %,'FontWeight','bold'
        gui_otherset_waveviewer.polarity_up = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.polarity_title,'String','Positive up',...
            'callback',@polarup,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',Polaritylabel); %,'FontWeight','bold'
        gui_otherset_waveviewer.polarity_down = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.polarity_title,'String','Negative up',...
            'callback',@polardown, 'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',~Polaritylabel); %,'FontWeight','bold'
        set(gui_otherset_waveviewer.polarity_title,'Sizes',[50 90 90]);
        ERPwaviewer.polarity=gui_otherset_waveviewer.polarity_up.Value;
        
        %%----------------SEM of wave--------------------------------------
        SEMlabel = 0;
        SEMCustomValue = 0;
        gui_otherset_waveviewer.SEM_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_otherset_waveviewer.show_SEM = uicontrol('Style','checkbox','Parent', gui_otherset_waveviewer.SEM_title ,'String','Show standard error X',...
            'callback',@showSEM,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',SEMlabel); %
        SMEString = {'0','1','2','3','4','5','6','7','8','9','10'};
        gui_otherset_waveviewer.SEM_custom = uicontrol('Style','popupmenu','Parent', gui_otherset_waveviewer.SEM_title ,'String',SMEString,...
            'callback',@SEMerror,'FontSize',12,'BackgroundColor',[1 1 1],'Value',SEMCustomValue+1); %
        set(gui_otherset_waveviewer.SEM_title,'Sizes',[150 90]);
        ERPwaviewer.SEM.active =gui_otherset_waveviewer.show_SEM.Value;
        ERPwaviewer.SEM.error = gui_otherset_waveviewer.SEM_custom.Value-1;
        SEMtransValue = 0;
        gui_otherset_waveviewer.SEMtrans_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_otherset_waveviewer.SEMtrans_title ,'String','transoarency',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'HorizontalAlignment','right'); %
        SMEtransString = {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};
        gui_otherset_waveviewer.SEMtrans_custom = uicontrol('Style','popupmenu','Parent', gui_otherset_waveviewer.SEMtrans_title ,'String',SMEtransString,...
            'callback',@SEMtrans,'FontSize',12,'BackgroundColor',[1 1 1],'Value',SEMtransValue*10 +1); %
        set(gui_otherset_waveviewer.SEMtrans_title,'Sizes',[150 90]);
        if SEMlabel
            gui_otherset_waveviewer.SEM_custom.Enable = 'on';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'on';
        else
            gui_otherset_waveviewer.SEM_custom.Enable = 'off';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'off';
        end
        ERPwaviewer.SEM.trans = (gui_otherset_waveviewer.SEMtrans_custom.Value-1)/10;
        
        %%----------------baseline correction------------------------------
        blc_def = 'none';
        try
            blc_def = ERPwaviewer.baselinecorr;
        catch
            blc_def = 'none';
        end
        if numel(blc_def) ==2
            noneValue =0;
            preValue =0;
            postValue = 0;
            wholeValue =0;
            customValue = 1;
            customString = num2str(blc_def);
            customEnable = 'on';
        else
            if strcmpi(blc_def,'none')
                noneValue =1;
                preValue =0;
                postValue = 0;
                wholeValue =0;
                customValue = 0;
                customString = '';
                customEnable = 'off';
            elseif strcmpi(blc_def,'pre')
                noneValue =0;
                preValue =1;
                postValue = 0;
                wholeValue =0;
                customValue = 0;
                customString = '';
                customEnable = 'off';
            elseif strcmpi(blc_def,'post')
                noneValue =0;
                preValue =0;
                postValue = 1;
                wholeValue =0;
                customValue = 0;
                customString = '';
                customEnable = 'off';
            elseif  strcmpi(blc_def,'whole')
                noneValue =0;
                preValue =0;
                postValue = 0;
                wholeValue =1;
                customValue = 0;
                customString = '';
                customEnable = 'off';
            end
        end
        gui_otherset_waveviewer.bsl_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_otherset_waveviewer.bsl_title ,'String','Baseline Correction:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); %,'HorizontalAlignment','left'
        gui_otherset_waveviewer.bsl_title_1 = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_otherset_waveviewer.bsl_none = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.bsl_title_1 ,'String','None',...
            'callback',@bsl_none,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',noneValue);
        gui_otherset_waveviewer.bsl_pre = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.bsl_title_1 ,'String','Pre',...
            'callback',@bsl_pre,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',preValue); %,'HorizontalAlignment','left','FontWeight','bold'
        gui_otherset_waveviewer.bsl_post = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.bsl_title_1 ,'String','Post',...
            'callback',@bsl_post, 'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',postValue); %,'HorizontalAlignment','left','FontWeight','bold'
        gui_otherset_waveviewer.bsl_whole = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.bsl_title_1 ,'String','Whole',...
            'callback',@bsl_whole, 'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',wholeValue); %,'HorizontalAlignment','left','FontWeight','bold'
        gui_otherset_waveviewer.bsl_title_3 = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        gui_otherset_waveviewer.bsl_custom = uicontrol('Style','radiobutton','Parent', gui_otherset_waveviewer.bsl_title_3 ,'String','Custom',...
            'callback',@bsl_custom,'FontSize',12,'BackgroundColor',ColorBviewer_def,'Value',customValue); %,'HorizontalAlignment','left','FontWeight','bold'
        gui_otherset_waveviewer.bsl_customedit = uicontrol('Style','edit','Parent', gui_otherset_waveviewer.bsl_title_3 ,'String',customString,...
            'callback',@bsl_customedit, 'FontSize',12,'BackgroundColor',[1 1 1],'Enable',customEnable); %,'HorizontalAlignment','left','FontWeight','bold'
        set( gui_otherset_waveviewer.bsl_title_3,'Sizes',[80 155]);
        
        if gui_otherset_waveviewer.bsl_none.Value ==1
            ERPwaviewer.baselinecorr = 'none';
        elseif gui_otherset_waveviewer.bsl_pre.Value ==1
            ERPwaviewer.baselinecorr = 'pre';
        elseif gui_otherset_waveviewer.bsl_post.Value ==1
            ERPwaviewer.baselinecorr = 'post';
        elseif gui_otherset_waveviewer.bsl_whole.Value ==1
            ERPwaviewer.baselinecorr = 'whole';
        elseif gui_otherset_waveviewer.bsl_custom.Value ==1
            ERPwaviewer.baselinecorr = str2num(char(gui_otherset_waveviewer.bsl_customedit));
        else
            ERPwaviewer.baselinecorr = 'none';
        end
        
        %%Figure background color: the default is white
        bgColor = [1 1 1];
        gui_otherset_waveviewer.figurebakcolor_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uicontrol('Style','text','Parent', gui_otherset_waveviewer.figurebakcolor_title,'String','Figure Background Color:',...
            'FontSize',12,'BackgroundColor',ColorBviewer_def,'FontWeight','bold'); %,'HorizontalAlignment','left'
        gui_otherset_waveviewer.figurebakcolor = uicontrol('Style','edit','Parent', gui_otherset_waveviewer.figurebakcolor_title,'String',num2str(bgColor),...
            'callback',@figbackcolor,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        set(gui_otherset_waveviewer.figurebakcolor_title,'Sizes',[150 85]);
        ERPwaviewer.figbackgdcolor = str2num(gui_otherset_waveviewer.figurebakcolor.String);
        
        
        %%Apply and save the changed parameters
        gui_otherset_waveviewer.help_run_title = uiextras.HBox('Parent', gui_otherset_waveviewer.DataSelBox,'BackgroundColor',ColorBviewer_def);
        uiextras.Empty('Parent',   gui_otherset_waveviewer.help_run_title );
        uicontrol('Style','pushbutton','Parent',  gui_otherset_waveviewer.help_run_title,'String','Cancel',...
            'callback',@other_help,'FontSize',12,'BackgroundColor',[1 1 1]); %,'FontWeight','bold'%,'HorizontalAlignment','left'
        uiextras.Empty('Parent',   gui_otherset_waveviewer.help_run_title );
        gui_otherset_waveviewer.apply = uicontrol('Style','pushbutton','Parent',  gui_otherset_waveviewer.help_run_title ,'String','Apply',...
            'callback',@other_apply,'FontSize',12,'BackgroundColor',[1 1 1]); %,'HorizontalAlignment','left'
        uiextras.Empty('Parent', gui_otherset_waveviewer.help_run_title);
        set(gui_otherset_waveviewer.help_run_title,'Sizes',[40 70 20 70 20]);
        
        set(gui_otherset_waveviewer.DataSelBox,'Sizes',[25 25 25 20 20 25 25 25]);
        ALLERPwaviewer=ERPwaviewer;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------------Setting for Polarity up-------------------------
    function  polarup(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.polarity_up.Value = 1;
        gui_otherset_waveviewer.polarity_down.Value = 0;
    end

%%-------------------------Setting for Polarity down-----------------------
    function  polardown(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.polarity_up.Value = 0;
        gui_otherset_waveviewer.polarity_down.Value = 1;
    end

%%-------------------Show SEM----------------------------------------------
    function showSEM(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        Value = Str.Value;
        if Value ==1
            gui_otherset_waveviewer.SEM_custom.Enable = 'on';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'on';
        else
            gui_otherset_waveviewer.SEM_custom.Enable = 'off';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'off';
            gui_otherset_waveviewer.SEM_custom.Value = 1;
            gui_otherset_waveviewer.SEMtrans_custom.Value = 1;
        end
    end


%%----------------SEM error setting----------------------------------------
    function SEMerror(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
    end
%%---------------------------SEM trans.------------------------------------
    function SEMtrans(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
    end


%%--------------------Baseline correction:none-----------------------------
    function bsl_none(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.bsl_none.Value =1;
        gui_otherset_waveviewer.bsl_pre.Value =0;
        gui_otherset_waveviewer.bsl_post.Value =0;
        gui_otherset_waveviewer.bsl_whole.Value =0;
        gui_otherset_waveviewer.bsl_custom.Value = 0;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
    end


%%--------------------Baseline correction:pre-----------------------------
    function bsl_pre(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.bsl_none.Value =0;
        gui_otherset_waveviewer.bsl_pre.Value =1;
        gui_otherset_waveviewer.bsl_post.Value =0;
        gui_otherset_waveviewer.bsl_whole.Value =0;
        gui_otherset_waveviewer.bsl_custom.Value = 0;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
    end


%%--------------------Baseline correction:post-----------------------------
    function bsl_post(~,~)
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.bsl_none.Value =0;
        gui_otherset_waveviewer.bsl_pre.Value =0;
        gui_otherset_waveviewer.bsl_post.Value =1;
        gui_otherset_waveviewer.bsl_whole.Value =0;
        gui_otherset_waveviewer.bsl_custom.Value = 0;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
    end

%%--------------------Baseline correction:whole----------------------------
    function bsl_whole(~,~)
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.bsl_none.Value =0;
        gui_otherset_waveviewer.bsl_pre.Value =0;
        gui_otherset_waveviewer.bsl_post.Value =0;
        gui_otherset_waveviewer.bsl_whole.Value =1;
        gui_otherset_waveviewer.bsl_custom.Value = 0;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
    end

%%--------------------Baseline correction:custom---------------------------
    function bsl_custom(~,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        gui_otherset_waveviewer.bsl_none.Value =0;
        gui_otherset_waveviewer.bsl_pre.Value =0;
        gui_otherset_waveviewer.bsl_post.Value =0;
        gui_otherset_waveviewer.bsl_whole.Value =0;
        gui_otherset_waveviewer.bsl_custom.Value = 1;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'on';
    end
%%-------------------Custom define baseline period-------------------------
    function bsl_customedit(Str,~)
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        MessageViewer= char(strcat('Other > Baseline Correction > Custom'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer = ALLERPwaviewer;
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Other > Baseline Correction > Custom() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        bacselinePeriod = str2num(char(Str.String));
        if isempty(bacselinePeriod) || numel(bacselinePeriod)==1
            viewer_ERPDAT.Process_messg =3;
            Str.String = '';
            fprintf(2,'\n Other > Baseline Correction > Custom() error: \n Inputs must be two numbers.\n\n');
            return;
        end
        
        TimeRange = ERPwaviewer.ERP.times;
        if bacselinePeriod(1)<TimeRange(1)
            msgboxText =  strcat('Left edge of baseline period should not be smaller than',32,num2str(TimeRange(1)),'ms');
            viewer_ERPDAT.Process_messg =3;
            Str.String = '';
            fprintf(2,['\n Other > Baseline Correction > Custom() error: \n',32,msgboxText,'.\n\n']);
            return;
        end
        if bacselinePeriod(2)>TimeRange(end)
            msgboxText =  strcat('Right edge of baseline period should not be larger than',32,num2str(TimeRange(end)),'ms');
            viewer_ERPDAT.Process_messg =3;
            Str.String = '';
            fprintf(2,['\n Other > Baseline Correction > Custom() error: \n',32,msgboxText,'.\n\n']);
            return;
        end
        if bacselinePeriod(1)>=bacselinePeriod(end)
            msgboxText =  strcat('Right edge of baseline period should be smaller than left edge');
            viewer_ERPDAT.Process_messg =3;
            Str.String = '';
            fprintf(2,['\n Other > Baseline Correction > Custom() error: \n',32,msgboxText,'.\n\n']);
            return;
        end
    end


%%-------------------figure background color-------------------------------
    function figbackcolor(Str,~)
        
        [messgStr,viewerpanelIndex] = f_check_erpviewerpanelchanges();
        if ~isempty(messgStr) && viewerpanelIndex~=7
            viewer_ERPDAT.count_twopanels = viewer_ERPDAT.count_twopanels +1;
        end
        estudioworkingmemory('MyViewer_other',1);
        gui_otherset_waveviewer.apply.BackgroundColor =  [0.4940 0.1840 0.5560];
        gui_otherset_waveviewer.apply.ForegroundColor = [1 1 1];
        box_erplabelset_viewer_otherset.TitleColor= [0.4940 0.1840 0.5560];
        
        bgColor = str2num(Str.String);
        if isempty(bgColor)
            msgboxText =  strcat('Inputs are invalid and it should be,e.g., [1 1 1]');
            title = 'EStudio>ERP Wave Viewer>Other: Figure Background Color';
            errorfound(msgboxText, title);
            Str.String = num2str([1 1 1]);
            return;
        end
        
        if max(bgColor)>1 || min(bgColor) <0 ||  numel(bgColor)~=3
            msgboxText =  strcat('Inputs are invalid and it should be,e.g., [1 1 1]');
            title = 'EStudio>ERP Wave Viewer>Other: Figure Background Color';
            errorfound(msgboxText, title);
            Str.String = num2str([1 1 1]);
            return;
        end
    end

%%----------------------------Help-----------------------------------------
    function other_help(~,~)
        changeFlag =  estudioworkingmemory('MyViewer_other');
        if changeFlag~=1
            return;
        end
        
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\nOther > Cancel-f_ERP_otherset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        
        gui_otherset_waveviewer.polarity_up.Value=ERPwaviewer_apply.polarity;%% the polarity of wave
        gui_otherset_waveviewer.polarity_down.Value = ~ERPwaviewer_apply.polarity;
        %%SME
        SMEActiveFlag = ERPwaviewer_apply.SEM.active;
        gui_otherset_waveviewer.show_SEM.Value=SMEActiveFlag;
        gui_otherset_waveviewer.SEM_custom.Value=ERPwaviewer_apply.SEM.error +1;
        %%trans
        gui_otherset_waveviewer.SEMtrans_custom.Value = 10* ERPwaviewer_apply.SEM.trans +1;
        if SMEActiveFlag==1
            Enable = 'on';
        else
            Enable = 'off';
        end
        gui_otherset_waveviewer.SEM_custom.Enable = Enable;
        gui_otherset_waveviewer.SEMtrans_custom.Enable = Enable;
        gui_otherset_waveviewer.figurebakcolor.String=num2str(ERPwaviewer_apply.figbackgdcolor);
        %%baseline correction method
        BslMethod = ERPwaviewer_apply.baselinecorr;
        gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
        gui_otherset_waveviewer.bsl_customedit.String = '';
        if ischar(BslMethod)
            if strcmpi(BslMethod,'none')
                gui_otherset_waveviewer.bsl_custom.Value =0;
                gui_otherset_waveviewer.bsl_none.Value=1;
                gui_otherset_waveviewer.bsl_pre.Value=0;
                gui_otherset_waveviewer.bsl_post.Value=0;
                gui_otherset_waveviewer.bsl_whole.Value=0;
            elseif strcmpi(BslMethod,'pre')
                gui_otherset_waveviewer.bsl_custom.Value =0;
                gui_otherset_waveviewer.bsl_none.Value=0;
                gui_otherset_waveviewer.bsl_pre.Value=1;
                gui_otherset_waveviewer.bsl_post.Value=0;
                gui_otherset_waveviewer.bsl_whole.Value=0;
            elseif strcmpi(BslMethod,'post')
                gui_otherset_waveviewer.bsl_custom.Value =0;
                gui_otherset_waveviewer.bsl_none.Value=0;
                gui_otherset_waveviewer.bsl_pre.Value=0;
                gui_otherset_waveviewer.bsl_post.Value=1;
                gui_otherset_waveviewer.bsl_whole.Value=0;
            elseif strcmpi(BslMethod,'whole')
                gui_otherset_waveviewer.bsl_custom.Value =0;
                gui_otherset_waveviewer.bsl_none.Value=0;
                gui_otherset_waveviewer.bsl_pre.Value=0;
                gui_otherset_waveviewer.bsl_post.Value=0;
                gui_otherset_waveviewer.bsl_whole.Value=1;
                
            end
        elseif isnumeric(BslMethod)
            gui_otherset_waveviewer.bsl_custom.Value =1;
            gui_otherset_waveviewer.bsl_none.Value=0;
            gui_otherset_waveviewer.bsl_pre.Value=0;
            gui_otherset_waveviewer.bsl_post.Value=0;
            gui_otherset_waveviewer.bsl_whole.Value=0;
            gui_otherset_waveviewer.bsl_customedit.String = num2str(BslMethod);
            gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
        end
        estudioworkingmemory('MyViewer_other',0);
        gui_otherset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_otherset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erplabelset_viewer_otherset.TitleColor= [0.5 0.5 0.9];
        
    end


%%-------------------------Apply the changed parameters--------------------
    function other_apply(~,~)
        estudioworkingmemory('MyViewer_other',0);
        gui_otherset_waveviewer.apply.BackgroundColor =  [1 1 1];
        gui_otherset_waveviewer.apply.ForegroundColor = [0 0 0];
        box_erplabelset_viewer_otherset.TitleColor= [0.5 0.5 0.9];
        MessageViewer= char(strcat('Other > Apply'));
        erpworkingmemory('ERPViewer_proces_messg',MessageViewer);
        viewer_ERPDAT.Process_messg =1;
        try
            ALLERPwaviewer = evalin('base','ALLERPwaviewer');
            ERPwaviewer_apply = ALLERPwaviewer;
        catch
            viewer_ERPDAT.Process_messg =3;
            fprintf(2,'\n Other > Apply-f_ERP_otherset_waveviewer_GUI() error: Cannot get parameters for whole panel.\n Please run My viewer again.\n\n');
            return;
        end
        ERPwaviewer_apply.polarity = gui_otherset_waveviewer.polarity_up.Value;%% the polarity of wave
        %%SME
        ERPwaviewer_apply.SEM.active  = gui_otherset_waveviewer.show_SEM.Value;
        ERPwaviewer_apply.SEM.error = gui_otherset_waveviewer.SEM_custom.Value-1;
        %%trans
        ERPwaviewer_apply.SEM.trans = (gui_otherset_waveviewer.SEMtrans_custom.Value-1)/10;
        %%MGFP
        %         ERPwaviewer_apply.MGFP = gui_otherset_waveviewer.MGFP_on.Value;
        ERPwaviewer_apply.figbackgdcolor = str2num(gui_otherset_waveviewer.figurebakcolor.String);
        %%baseline correction method
        if gui_otherset_waveviewer.bsl_none.Value ==1
            ERPwaviewer_apply.baselinecorr = 'none';
        elseif gui_otherset_waveviewer.bsl_pre.Value ==1
            ERPwaviewer_apply.baselinecorr = 'pre';
        elseif gui_otherset_waveviewer.bsl_post.Value ==1
            ERPwaviewer_apply.baselinecorr = 'post';
        elseif gui_otherset_waveviewer.bsl_whole.Value ==1
            ERPwaviewer_apply.baselinecorr = 'whole';
        elseif gui_otherset_waveviewer.bsl_custom.Value ==1
            ERPwaviewer_apply.baselinecorr = str2num(char(gui_otherset_waveviewer.bsl_customedit.String));
            %checking the defined time-window for baselne correction
            if isempty(ERPwaviewer_apply.baselinecorr)|| numel(ERPwaviewer_apply.baselinecorr)==1
                msgboxText =  strcat('<Baseline Period> Inputs must be two numbers! If you donot change it, "none" will be used for baseline correction!');
                title = 'EStudio>ERP Wave Viewer: Baseline period for "Baseline Correction" on "Other"';
                errorfound(msgboxText, title);
                ERPwaviewer_apply.baselinecorr = 'none';
                return;
            end
            %%may check the left and right edges for the defined
            %%time=window
        else
            ERPwaviewer_apply.baselinecorr = 'none';
        end
        ALLERPwaviewer=ERPwaviewer_apply;
        assignin('base','ALLERPwaviewer',ALLERPwaviewer);
        f_redrawERP_viewer_test();
        viewer_ERPDAT.Process_messg =2;
    end

%%---------change this panel based on the loaded paras.--------------------
    function count_loadproper_change(~,~)
        if viewer_ERPDAT.count_loadproper ==0
            return;
        end
        try
            ERPwaviewer_apply = evalin('base','ALLERPwaviewer');
        catch
            beep;
            disp('f_ERP_otherset_waveviewer_GUI() error: Please run the ERP wave viewer again.');
            return;
        end
        
        PolirityValue = ERPwaviewer_apply.polarity;
        if PolirityValue ==1
            gui_otherset_waveviewer.polarity_up.Value = 1;
            gui_otherset_waveviewer.polarity_down.Value = 0;
        else
            gui_otherset_waveviewer.polarity_up.Value = 0;
            gui_otherset_waveviewer.polarity_down.Value = 1;
        end
        
        %
        %%SEM settings
        SEMValue =  ERPwaviewer_apply.SEM.active;
        if SEMValue==1
            gui_otherset_waveviewer.SEM_custom.Enable = 'on';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'on';
            ERRORValue = ERPwaviewer_apply.SEM.error;
            if isempty(ERRORValue) || ERRORValue<0 || ERRORValue>10
                ERRORValue = 0;
                ERPwaviewer_apply.SEM.error = 0;
            end
            gui_otherset_waveviewer.SEM_custom.Value =ERRORValue+1;
            SEMTrans = ERPwaviewer_apply.SEM.trans;
            if isempty(SEMTrans) || SEMTrans<0 || SEMTrans>1
                SEMTrans = 0;
                ERPwaviewer_apply.SEM.trans = 0;
            end
            gui_otherset_waveviewer.SEMtrans_custom.Value  = SEMTrans*10 +1;
        else
            gui_otherset_waveviewer.SEM_custom.Enable = 'off';
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'off';
            gui_otherset_waveviewer.SEM_custom.Value =1;
            gui_otherset_waveviewer.SEMtrans_custom.Value =1;
        end
        
        %
        %%Baseline settings
        BalineCorrection = ERPwaviewer_apply.baselinecorr;
        if numel(BalineCorrection) ==2
            if ~isnumeric(BalineCorrection)
                gui_otherset_waveviewer.bsl_none.Value =1;
                gui_otherset_waveviewer.bsl_pre.Value =0;
                gui_otherset_waveviewer.bsl_post.Value =0;
                gui_otherset_waveviewer.bsl_whole.Value =0;
                gui_otherset_waveviewer.bsl_custom.Value = 0;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
                ERPwaviewer_apply.baselinecorr = 'none';
            else
                gui_otherset_waveviewer.bsl_none.Value =0;
                gui_otherset_waveviewer.bsl_pre.Value =0;
                gui_otherset_waveviewer.bsl_post.Value =0;
                gui_otherset_waveviewer.bsl_whole.Value =0;
                gui_otherset_waveviewer.bsl_custom.Value = 1;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'on';
                gui_otherset_waveviewer.bsl_customedit.String = num2str(BalineCorrection);
            end
        else
            
            if strcmpi(BalineCorrection,'pre')
                gui_otherset_waveviewer.bsl_none.Value =0;
                gui_otherset_waveviewer.bsl_pre.Value =1;
                gui_otherset_waveviewer.bsl_post.Value =0;
                gui_otherset_waveviewer.bsl_whole.Value =0;
                gui_otherset_waveviewer.bsl_custom.Value = 0;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
            elseif strcmpi(BalineCorrection,'post')
                gui_otherset_waveviewer.bsl_none.Value =0;
                gui_otherset_waveviewer.bsl_pre.Value =0;
                gui_otherset_waveviewer.bsl_post.Value =1;
                gui_otherset_waveviewer.bsl_whole.Value =0;
                gui_otherset_waveviewer.bsl_custom.Value = 0;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
            elseif strcmpi(BalineCorrection,'all')
                gui_otherset_waveviewer.bsl_none.Value =0;
                gui_otherset_waveviewer.bsl_pre.Value =0;
                gui_otherset_waveviewer.bsl_post.Value =0;
                gui_otherset_waveviewer.bsl_whole.Value =1;
                gui_otherset_waveviewer.bsl_custom.Value = 0;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
            else
                gui_otherset_waveviewer.bsl_none.Value =1;
                gui_otherset_waveviewer.bsl_pre.Value =0;
                gui_otherset_waveviewer.bsl_post.Value =0;
                gui_otherset_waveviewer.bsl_whole.Value =0;
                gui_otherset_waveviewer.bsl_custom.Value = 0;
                gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
            end
        end
        
        %
        %%Background color
        try
            BackgroundColor =  ERPwaviewer_apply.figbackgdcolor;
        catch
            BackgroundColor = [1 1 1];
        end
        if isempty(BackgroundColor) ||  numel(BackgroundColor)~=3 || max(BackgroundColor)>1 ||min (BackgroundColor)<0
            BackgroundColor = [1 1 1];
        end
        gui_otherset_waveviewer.figurebakcolor.String = num2str(BackgroundColor);
        
        ERPwaviewer_apply.figbackgdcolor = BackgroundColor;
        assignin('base','ALLERPwaviewer',ERPwaviewer_apply);
    end


%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function count_twopanels_change(~,~)
        if viewer_ERPDAT.count_twopanels==0
            return;
        end
        changeFlag =  estudioworkingmemory('MyViewer_other');
        if changeFlag~=1
            return;
        end
        other_apply();
    end


%%-------------------------------------------------------------------------
%%-----------------Reset this panel with the default parameters------------
%%-------------------------------------------------------------------------
    function Reset_Waviewer_panel_change(~,~)
        if viewer_ERPDAT.Reset_Waviewer_panel==7
            try
                ERPwaviewerin = evalin('base','ALLERPwaviewer');
            catch
                beep;
                disp('f_ERP_otherset_waveviewer_GUI error: Restart ERPwave Viewer');
                return;
            end
            
            gui_otherset_waveviewer.polarity_up.Value =1;
            gui_otherset_waveviewer.polarity_down.Value =0;
            ERPwaviewerin.polarity = gui_otherset_waveviewer.polarity_up.Value;%% the polarity of wave
            
            %%SME
            gui_otherset_waveviewer.show_SEM.Value =0;
            ERPwaviewerin.SEM.active  = gui_otherset_waveviewer.show_SEM.Value;
            gui_otherset_waveviewer.SEM_custom.Value =1;
            gui_otherset_waveviewer.SEM_custom.Enable = 'off';
            ERPwaviewerin.SEM.error = gui_otherset_waveviewer.SEM_custom.Value-1;
            %%trans
            ERPwaviewerin.SEM.trans = (gui_otherset_waveviewer.SEMtrans_custom.Value-1)/10;
            gui_otherset_waveviewer.SEMtrans_custom.Value =1;
            gui_otherset_waveviewer.SEMtrans_custom.Enable = 'off';
            gui_otherset_waveviewer.bsl_none.Value =1;
            ERPwaviewerin.baselinecorr = 'none';
            gui_otherset_waveviewer.bsl_pre.Value =0;
            gui_otherset_waveviewer.bsl_post.Value =0;
            gui_otherset_waveviewer.bsl_whole.Value =0;
            gui_otherset_waveviewer.bsl_custom.Value =0;
            gui_otherset_waveviewer.bsl_customedit.String = '';
            gui_otherset_waveviewer.bsl_customedit.Enable = 'off';
            gui_otherset_waveviewer.figurebakcolor.String ='1,1,1';
            ERPwaviewerin.figbackgdcolor =[1 1 1];
            assignin('base','ALLERPwaviewer',ERPwaviewerin);
            gui_otherset_waveviewer.apply.BackgroundColor =  [1 1 1];
            gui_otherset_waveviewer.apply.ForegroundColor = [0 0 0];
            box_erplabelset_viewer_otherset.TitleColor= [0.5 0.5 0.9];
            %             viewer_ERPDAT.Reset_Waviewer_panel=3;
        end
    end

end