%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Mar. 2023

% ERPLAB Studio

function varargout = f_ERP_simulation_panel(varargin)

% global gui_erp_simulation;
global observe_ERPDAT;
global EStudio_gui_erp_totl;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);
%%---------------------------gui-------------------------------------------
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_simulation_box = uiextras.BoxPanel('Parent', fig, 'Title', 'Create Artificial ERP Waveform',...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_simulation_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Create Artificial ERP Waveform',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    ERP_simulation_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Create Artificial ERP Waveform',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @simuerp_help
end

gui_erp_simulation = struct();
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
erp_blc_dt_gui(FonsizeDefault);
varargout{1} = ERP_simulation_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_gui(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        Enable_label = 'off';
        def   = erpworkingmemory('pop_ERP_simulation');
        if isempty(def)
            def  = {1,1,100,50,0,-200,799,1,1000,0,1,0,1,0,1,10};
        end
        try
            BasFunLabel = def{1};
        catch
            BasFunLabel =1;
        end
        if isempty(BasFunLabel)|| ~isnumeric(BasFunLabel)
            BasFunLabel =1;
        end
        if numel(BasFunLabel)~=1
            BasFunLabel=BasFunLabel(1);
        end
        gui_erp_simulation.bsfun_box = uiextras.VBox('Parent',ERP_simulation_box,'Spacing',1,'BackgroundColor',ColorB_def);
        %%-----------------------Plot axis---------------------------------
        gui_erp_simulation.plotasix_op = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        
        gui_erp_simulation.plot_erp    =  axes( 'Parent', gui_erp_simulation.plotasix_op);%, 'ActivePositionProperty', 'Position'
        
        %%----------------------information for Real data------------------
        gui_erp_simulation.realdata_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.realdata_title,...
            'String','Basic Information for Real Data','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        
        gui_erp_simulation.realdatamatch_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.realerp_check = uicontrol('Style', 'checkbox','Parent', gui_erp_simulation.realdatamatch_title,...
            'callback',@erpcheckbox,'String','Compare with Real Data','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def,'Value',0);
        gui_erp_simulation.realerp_check.KeyPressFcn= @erp_simuls_presskey;
        uiextras.Empty('Parent', gui_erp_simulation.realdatamatch_title);
        set(gui_erp_simulation.realdatamatch_title, 'Sizes',[200 70]);
        gui_erp_simulation.Paras{1}=gui_erp_simulation.realerp_check.Value;
        %%ERPset for real data
        gui_erp_simulation.erpset_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.erpset_title,...
            'String','ERPset:','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.erpsetedit = uicontrol('Style', 'edit','Parent', gui_erp_simulation.erpset_title,...
            'callback',@erpsetedit,'String','','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        gui_erp_simulation.Paras{2} = str2num(gui_erp_simulation.erpsetedit.String);
        gui_erp_simulation.erpsetedit.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.erpsetpopup = uicontrol('Style', 'pushbutton','Parent', gui_erp_simulation.erpset_title,...
            'callback',@erpsetpopup,'String','Browse','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        
        %%Channel for real data
        gui_erp_simulation.erpsetchan_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.erpsetchan_title,...
            'String','Channel:','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.channeledit = uicontrol('Style', 'edit','Parent', gui_erp_simulation.erpsetchan_title,...
            'callback',@channeledit,'String','','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        gui_erp_simulation.channeledit.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{3} = str2num(gui_erp_simulation.channeledit.String);
        
        gui_erp_simulation.channelpopup = uicontrol('Style', 'pushbutton','Parent', gui_erp_simulation.erpsetchan_title,...
            'callback',@channelpopup,'String','Browse','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        %%bin for real data
        gui_erp_simulation.erpsetbin_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.erpsetbin_title,...
            'String','Bin:','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.binedit = uicontrol('Style', 'edit','Parent', gui_erp_simulation.erpsetbin_title,...
            'callback',@binedit,'String','','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        gui_erp_simulation.binedit.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{4} = str2num(gui_erp_simulation.binedit.String);
        gui_erp_simulation.binpopup = uicontrol('Style', 'pushbutton','Parent', gui_erp_simulation.erpsetbin_title,...
            'callback',@binpopup,'String','Browse','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1],'Enable','off');
        if isempty(observe_ERPDAT.ALLERP)
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
        end
        %%--------------------Basic information----------------------------
        gui_erp_simulation.asif_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.asif_title,...
            'String','Basic Information for Simulation','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.epoch_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.epoch_title,...
            'String','Epoch: Start','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        try
            epochStart = def{6};
        catch
            epochStart = -200;
        end
        gui_erp_simulation.epoch_start = uicontrol('Style', 'edit','Parent',  gui_erp_simulation.epoch_title,...
            'callback',@epochstart,'String',num2str(epochStart),'FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1]);
        gui_erp_simulation.epoch_start.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{5} = str2num(gui_erp_simulation.epoch_start.String);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.epoch_title,...
            'String','Stop','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        try
            epochStop = def{7};
        catch
            epochStop = 799;
        end
        gui_erp_simulation.epoch_stop = uicontrol('Style', 'edit','Parent',  gui_erp_simulation.epoch_title,...
            'callback',@epocstop,'String',num2str(epochStop),'FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1]);
        gui_erp_simulation.epoch_stop.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{6} = str2num(gui_erp_simulation.epoch_stop.String);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.epoch_title,...
            'String','ms','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        set(gui_erp_simulation.epoch_title, 'Sizes',[80 60 40 60 25]);
        
        try
            srateop = def{8};
        catch
            srateop = 1;
        end
        gui_erp_simulation.srate_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.srate=uicontrol('Style', 'radiobutton','Parent',  gui_erp_simulation.srate_title,...
            'callback',@srateop,'String','Sampling rate','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.Paras{7} = gui_erp_simulation.srate.Value;
        gui_erp_simulation.srate.KeyPressFcn= @erp_simuls_presskey;
        try
            srate = def{9};
        catch
            srate = 1000;
        end
        gui_erp_simulation.srateedit =uicontrol('Style', 'edit','Parent',  gui_erp_simulation.srate_title,...
            'callback',@srateedit,'String', '','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1]);
        gui_erp_simulation.srateedit.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{8} = str2num(gui_erp_simulation.srateedit.String);
        if srateop==1
            gui_erp_simulation.srate.Value =1;
            gui_erp_simulation.srateedit.Enable = 'on';
            gui_erp_simulation.srateedit.String = num2str(srate);
        else
            gui_erp_simulation.srate.Value =0;
            gui_erp_simulation.srateedit.Enable = 'off';
            gui_erp_simulation.srateedit.String = num2str(1000/srate);
        end
        
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.srate_title,...
            'String','Hz','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.srate_title);
        set(gui_erp_simulation.srate_title, 'Sizes',[120 80 25 40]);
        
        gui_erp_simulation.speriod_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.srateperiod=uicontrol('Style', 'radiobutton','Parent',  gui_erp_simulation.speriod_title,...
            'callback',@srateperiod,'String','Sampling period','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        gui_erp_simulation.srateperiod.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.srateperiodedit =uicontrol('Style', 'edit','Parent',  gui_erp_simulation.speriod_title,...
            'callback',@srateperiodedit,'String', '','FontSize',FonsizeDefault ,'BackgroundColor',[1 1 1]);
        gui_erp_simulation.srateperiodedit.KeyPressFcn= @erp_simuls_presskey;
        if srateop==1
            gui_erp_simulation.srateperiod.Value =0;
            gui_erp_simulation.srateperiodedit.Enable = 'off';
            gui_erp_simulation.srateperiodedit.String = num2str(1000/srate);
        else
            gui_erp_simulation.srateperiod.Value =1;
            gui_erp_simulation.srateperiodedit.Enable = 'on';
            gui_erp_simulation.srateperiodedit.String = num2str(srate);
        end
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.speriod_title,...
            'String','ms','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.speriod_title);
        set(gui_erp_simulation.speriod_title, 'Sizes',[120 80 25 40]);
        
        
        %%----------------------Basic Function title type-------------------
        gui_erp_simulation.bsfun_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.bsfun_title,...
            'String','Basic Function for Simulation','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        
        %%ExGaussian Function
        gui_erp_simulation.exguafun_option = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.exgua_op = uicontrol('Style', 'radiobutton','Parent', gui_erp_simulation.exguafun_option,...
            'String','ExGaussian','callback',@exguass_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.exgua_op.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{9} = gui_erp_simulation.exgua_op.Value;
        
        if BasFunLabel==1
            gui_erp_simulation.exgua_op.Value =1;
            ExgauEnable = 'on';
        else
            gui_erp_simulation.exgua_op.Value =0;
            ExgauEnable = 'off';
        end
        uicontrol('Style', 'text','Parent', gui_erp_simulation.exguafun_option,...
            'String','Peak amplitude','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try
            Exgau_amp = def{2};
        catch
            Exgau_amp =0;
        end
        if isempty(Exgau_amp)|| ~isnumeric(Exgau_amp)
            Exgau_amp =0;
        end
        if numel(Exgau_amp)~=1
            Exgau_amp = Exgau_amp(1);
        end
        gui_erp_simulation.exgua_peakamp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.exguafun_option,...
            'String',num2str(Exgau_amp),'callback',@exgau_peakamp,'Enable',ExgauEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.exguafun_option,...
            'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.exgua_peakamp.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{10} = str2num(gui_erp_simulation.exgua_peakamp.String);
        uiextras.Empty('Parent', gui_erp_simulation.exguafun_option);
        set(gui_erp_simulation.exguafun_option, 'Sizes',[90 90 60 30 15]);
        
        gui_erp_simulation.exguafun_setting = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.exguafun_setting);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.exguafun_setting,...
            'String','Gaussian mean','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try
            Exgau_mean = def{3};
        catch
            Exgau_mean =100;
        end
        if isempty(Exgau_mean) || ~isnumeric(Exgau_mean)
            Exgau_mean =100;
        end
        gui_erp_simulation.exgua_mean = uicontrol('Style', 'edit','Parent', gui_erp_simulation.exguafun_setting,...
            'String',num2str(Exgau_mean),'callback',@exgau_mean,'Enable',ExgauEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        gui_erp_simulation.exgua_mean.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{11} = str2num(gui_erp_simulation.exgua_mean.String);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.exguafun_setting,...
            'String','SD','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try
            ExGauSD = def{4};
        catch
            ExGauSD =50;
        end
        if isempty(ExGauSD) || ~isnumeric(ExGauSD)
            ExGauSD =50;
        end
        gui_erp_simulation.exgua_sd = uicontrol('Style', 'edit','Parent', gui_erp_simulation.exguafun_setting,...
            'String',num2str(ExGauSD),'callback',@exgau_sd,'Enable',ExgauEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(gui_erp_simulation.exguafun_setting, 'Sizes',[15 90 50 40 50]);
        gui_erp_simulation.exgua_sd.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{12} = str2num(gui_erp_simulation.exgua_sd.String);
        gui_erp_simulation.exguafun_setting1 = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.exguafun_setting1);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.exguafun_setting1,...
            'String','Exponential tau','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        try
            ExGauTau = def{5};
        catch
            ExGauTau =0;
        end
        if isempty(ExGauTau) || ~isnumeric(ExGauTau)
            ExGauTau =0;
        end
        gui_erp_simulation.exgua_tau = uicontrol('Style', 'edit','Parent', gui_erp_simulation.exguafun_setting1,...
            'String',num2str(ExGauTau),'callback',@exgau_tau,'Enable',ExgauEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_simulation.exguafun_setting1);
        uiextras.Empty('Parent', gui_erp_simulation.exguafun_setting1);
        set(gui_erp_simulation.exguafun_setting1, 'Sizes',[15 90 50 40 50]);
        gui_erp_simulation.exgua_tau.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{13} = str2num(gui_erp_simulation.exgua_tau.String);
        %%Impulse function
        gui_erp_simulation.impulse_option = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.impulse_op = uicontrol('Style', 'radiobutton','Parent', gui_erp_simulation.impulse_option,...
            'String','Impulse','callback',@impulse_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        if BasFunLabel==2
            ImpulseEnable ='on';
            gui_erp_simulation.impulse_op.Value =1;
        else
            ImpulseEnable = 'off';
            gui_erp_simulation.impulse_op.Value =0;
        end
        gui_erp_simulation.impulse_op.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{14} = gui_erp_simulation.impulse_op.Value;
        uicontrol('Style', 'text','Parent', gui_erp_simulation.impulse_option,...
            'String','Peak amplitude','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.impulse_peakamp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.impulse_option,...
            'String','','callback',@impulse_peakamp,'Enable',ImpulseEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.impulse_option,...
            'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.impulse_peakamp.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{15} = str2num(gui_erp_simulation.impulse_peakamp.String);
        if BasFunLabel==2
            try
                impulsePeakamp = def{2};
            catch
                impulsePeakamp = 1;
            end
            if isempty(impulsePeakamp) ||  ~isnumeric(impulsePeakamp)
                impulsePeakamp =1;
            end
            gui_erp_simulation.impulse_peakamp.String = num2str(impulsePeakamp);
        end
        uiextras.Empty('Parent', gui_erp_simulation.impulse_option);
        set( gui_erp_simulation.impulse_option, 'Sizes',[80 100 60 30 15]);
        gui_erp_simulation.impulse_setting = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.impulse_setting);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.impulse_setting,...
            'String','Latency','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.impulse_latency = uicontrol('Style', 'edit','Parent', gui_erp_simulation.impulse_setting,...
            'String','','callback',@impulse_latency,'Enable',ImpulseEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.impulse_setting,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.impulse_latency.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{16} = str2num(gui_erp_simulation.impulse_latency.String);
        if BasFunLabel==2
            try
                impulselat = def{3};
            catch
                impulselat = 100;
            end
            if isempty(impulselat) || ~isnumeric(impulselat)
                impulselat = 100;
            end
            gui_erp_simulation.impulse_latency.String = num2str(impulselat);
        end
        uiextras.Empty('Parent', gui_erp_simulation.impulse_setting);
        set(gui_erp_simulation.impulse_setting, 'Sizes',[80 100 60 30 15]);
        %%Boxcar function
        gui_erp_simulation.square_option = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_op = uicontrol('Style', 'radiobutton','Parent', gui_erp_simulation.square_option,...
            'String','Boxcar','callback',@square_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_op.KeyPressFcn= @erp_simuls_presskey;
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_option,...
            'String','Peak amplitude','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.Paras{17} =gui_erp_simulation.square_op.Value;
        if BasFunLabel==3
            squareEnable = 'on';
        else
            squareEnable = 'off';
        end
        gui_erp_simulation.square_peakamp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.square_option,...
            'String','','callback',@square_peakamp,'Enable',squareEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_option,...
            'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.square_option);
        gui_erp_simulation.square_peakamp.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{18} =str2num(gui_erp_simulation.square_peakamp.String);
        if BasFunLabel==3
            try
                sqaurePeakamp = def{2};
            catch
                sqaurePeakamp = 1;
            end
            if isempty(sqaurePeakamp) ||  ~isnumeric(sqaurePeakamp)
                sqaurePeakamp =1;
            end
            gui_erp_simulation.square_peakamp.String = num2str(sqaurePeakamp);
            gui_erp_simulation.square_op.Value =1;
        else
            gui_erp_simulation.square_op.Value =0;
        end
        set( gui_erp_simulation.square_option, 'Sizes',[80 100 60 30 15]);
        gui_erp_simulation.square_setting = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.square_setting);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_setting,...
            'String','Onset','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_onset = uicontrol('Style', 'edit','Parent', gui_erp_simulation.square_setting,...
            'String','','callback',@square_onset,'Enable',squareEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_setting,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_onset.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{19} =str2num(gui_erp_simulation.square_onset.String);
        if BasFunLabel==3
            try
                Onsetlat = def{3};
            catch
                Onsetlat = 100;
            end
            if isempty(Onsetlat) ||  ~isnumeric(Onsetlat)
                Onsetlat =100;
            end
            gui_erp_simulation.square_onset.String = num2str(Onsetlat);
        end
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_setting,...
            'String','Offset','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_offset = uicontrol('Style', 'edit','Parent', gui_erp_simulation.square_setting,...
            'String','','callback',@square_offset,'Enable',squareEnable,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.square_setting,'String','ms','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.square_offset.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{20} =str2num(gui_erp_simulation.square_offset.String);
        if BasFunLabel==3
            try
                Offsetlat = def{4};
            catch
                Offsetlat = 50;
            end
            if isempty(Offsetlat) ||  ~isnumeric(Offsetlat)
                Offsetlat =50;
            end
            gui_erp_simulation.square_offset.String = num2str(Offsetlat);
        end
        set(  gui_erp_simulation.square_setting, 'Sizes',[15 40 60 25 40 60 25]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%-----------------------noise ------------------------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        gui_erp_simulation.noisefun_title = uiextras.HBox('Parent',  gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',  gui_erp_simulation.noisefun_title,...
            'String','Noise Function for Simulation','FontWeight','bold','FontSize',FonsizeDefault ,'BackgroundColor',ColorB_def);
        %%sin noise
        gui_erp_simulation.sin_option = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.sin_op = uicontrol('Style', 'checkbox','Parent', gui_erp_simulation.sin_option ,...
            'String','Sinusoidal','callback',@sinoise_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.sin_op.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{21} = gui_erp_simulation.sin_op.Value;
        try
            sinop = def{14};
        catch
            sinop =0;
        end
        if isempty(sinop)
            sinop =0;
        end
        if sinop==1
            gui_erp_simulation.sin_op.Value=1;
            sinEnable = 'on';
        else
            gui_erp_simulation.sin_op.Value=0;
            sinEnable = 'off';
        end
        gui_erp_simulation.sin_amp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.sin_option ,...
            'String',' ','callback',@sin_amp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',sinEnable);
        gui_erp_simulation.sin_amp.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{22} = str2num(gui_erp_simulation.sin_amp.String);
        try
            sinamp = def{15};
        catch
            sinamp =0;
        end
        if isempty(sinamp) ||~isnumeric(sinamp)
            sinamp =0;
        end
        gui_erp_simulation.sin_amp.String = num2str(sinamp);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.sin_option,...
            'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.sin_fre = uicontrol('Style', 'edit','Parent', gui_erp_simulation.sin_option ,...
            'String',' ','callback',@sinoise_fre,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',sinEnable);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.sin_option,...
            'String','Hz','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.sin_fre.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{23} = str2num(gui_erp_simulation.sin_fre.String);
        try
            sinfre = def{16};
        catch
            sinfre =10;
        end
        if isempty(sinfre) ||~isnumeric(sinfre) || sinfre<=0
            sinfre =10;
        end
        gui_erp_simulation.sin_fre.String = num2str(sinfre);
        set(gui_erp_simulation.sin_option, 'Sizes',[90 60 30 60 30]);
        %%white noise
        gui_erp_simulation.white_title = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.white_op = uicontrol('Style', 'checkbox','Parent', gui_erp_simulation.white_title ,...
            'String','White','callback',@whitenoise_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.white_op.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{24} = gui_erp_simulation.white_op.Value;
        try
            whiteop =def{10};
        catch
            whiteop=0;
        end
        if isempty(whiteop) || ~isnumeric(whiteop)
            whiteop=0;
        end
        if whiteop==1
            gui_erp_simulation.white_op.Value =1;
            whitEnable = 'on';
        else
            gui_erp_simulation.white_op.Value =0;
            whitEnable = 'off';
        end
        gui_erp_simulation.white_amp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.white_title ,...
            'String',' ','callback',@white_amp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',whitEnable);
        gui_erp_simulation.white_amp.KeyPressFcn= @erp_simuls_presskey;
        uicontrol('Style', 'text','Parent', gui_erp_simulation.white_title,'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.white_title);
        uiextras.Empty('Parent', gui_erp_simulation.white_title);
        gui_erp_simulation.Paras{25} = str2num(gui_erp_simulation.white_amp.String);
        try
            whiteamp =def{11};
        catch
            whiteamp=0;
        end
        if isempty(whiteamp)
            whiteamp=0;
        end
        gui_erp_simulation.white_amp.String = num2str(whiteamp);
        set(gui_erp_simulation.white_title, 'Sizes',[90 60 30 60 30]);
        
        %%pink noise
        gui_erp_simulation.pink_title = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        gui_erp_simulation.pink_op = uicontrol('Style', 'checkbox','Parent', gui_erp_simulation.pink_title ,...
            'String','Pink','callback',@pinknoise_op,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        gui_erp_simulation.pink_op.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{26} = gui_erp_simulation.pink_op.Value;
        try
            pinkeop =def{12};
        catch
            pinkeop=0;
        end
        if isempty(pinkeop) || ~isnumeric(pinkeop)
            pinkeop=0;
        end
        if pinkeop==1
            gui_erp_simulation.pink_op.Value =1;
            pinkEnable = 'on';
        else
            gui_erp_simulation.pink_op.Value =0;
            pinkEnable = 'off';
        end
        gui_erp_simulation.pink_amp = uicontrol('Style', 'edit','Parent', gui_erp_simulation.pink_title ,...
            'String',' ','callback',@pink_amp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable',pinkEnable);
        gui_erp_simulation.pink_amp.KeyPressFcn= @erp_simuls_presskey;
        gui_erp_simulation.Paras{27} = str2num(gui_erp_simulation.pink_amp.String);
        try
            pinkAmp = def{13};
        catch
            pinkAmp=0;
        end
        gui_erp_simulation.pink_amp.String = num2str(pinkAmp);
        uicontrol('Style', 'text','Parent', gui_erp_simulation.pink_title,'String','μV','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.pink_title);
        uiextras.Empty('Parent', gui_erp_simulation.pink_title);
        set(gui_erp_simulation.pink_title, 'Sizes',[90 60 30 60 30]);
        
        %%update noise if needed New Noise
        %%seeds for white and pink noise
        gui_erp_simulation.SimulationSeed = erpworkingmemory('SimulationSeed');
        rng(1,'twister');
        SimulationSeed = rng;
        erpworkingmemory('SimulationSeed',SimulationSeed);
        %phase for sin noise
        gui_erp_simulation.SimulationPhase = erpworkingmemory('SimulationPhase');
        SimulationPhase = 0;
        erpworkingmemory('SimulationPhase',SimulationPhase);
        
        gui_erp_simulation.newnoise_option = uiextras.HBox('Parent', gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.newnoise_option);
        gui_erp_simulation.newnoise_op = uicontrol('Style', 'pushbutton','Parent', gui_erp_simulation.newnoise_option ,...
            'String','Re-randomize noise','callback',@newnoise_op,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Value',0);
        uiextras.Empty('Parent', gui_erp_simulation.newnoise_option);
        set(gui_erp_simulation.newnoise_option, 'Sizes',[70 130 70]);
        
        %%Cancel and advanced
        gui_erp_simulation.other_option = uiextras.HBox('Parent',gui_erp_simulation.bsfun_box,'Spacing',1,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_simulation.other_option,'BackgroundColor',ColorB_def);
        gui_erp_simulation.simulation_cancel = uicontrol('Parent',gui_erp_simulation.other_option,'Style','pushbutton',...
            'String','Cancel','callback',@simulation_cancel,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_simulation.other_option);
        gui_erp_simulation.apply = uicontrol('Style','pushbutton','Parent',gui_erp_simulation.other_option,...
            'String','Create ERPset','callback',@simulation_apply,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent', gui_erp_simulation.other_option);
        set(gui_erp_simulation.other_option, 'Sizes',[15 105  30 105 15]);
        set(gui_erp_simulation.bsfun_box, 'Sizes',[200 20 25 25 25 25 20 25 25 25 20 25 25 25 25 25 25 25 20 25 25 25 25 25]);
        plot_erp_simulation();
        
        estudioworkingmemory('ERPTab_stimulation',0);
    end
%%****************************************************************************************************************************************
%%*******************   Subfunctions   ***************************************************************************************************
%%****************************************************************************************************************************************

%%---------------------------Help------------------------------------------
%     function simuerp_help(~,~)
%         web('https://github.com/ucdavis/erplab/wiki/Create-an-Artificial-ERP-Waveform','-browser');
%     end

%%---------------------Match with real ERP?--------------------------------
    function erpcheckbox(Str,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        
        Value = Str.Value;
        if Value ==1
            EnableFlag = 'on';
        else
            EnableFlag = 'off';
        end
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            Str.Enable = 'off';
            EnableFlag = 'off';
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            return;
        end
        gui_erp_simulation.erpsetedit.Enable = EnableFlag;
        gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
        gui_erp_simulation.channeledit.Enable = EnableFlag;
        gui_erp_simulation.channelpopup.Enable = EnableFlag;
        gui_erp_simulation.binedit.Enable = EnableFlag;
        gui_erp_simulation.binpopup.Enable = EnableFlag;
        if Value ==1
            EnableFlagn = 'off';
        else
            EnableFlagn = 'on';
        end
        gui_erp_simulation.epoch_start.Enable = EnableFlagn;
        gui_erp_simulation.epoch_stop.Enable = EnableFlagn;
        gui_erp_simulation.srate.Enable = EnableFlagn;
        gui_erp_simulation.srateedit.Enable = EnableFlagn;
        gui_erp_simulation.srateperiod.Enable = EnableFlagn;
        gui_erp_simulation.srateperiodedit.Enable = EnableFlagn;
        if Value ==0
            if gui_erp_simulation.srate.Value ==1
                gui_erp_simulation.srate.Value = 1;
                gui_erp_simulation.srateedit.Enable = 'on';
                gui_erp_simulation.srateperiod.Value = 0;
                gui_erp_simulation.srateperiodedit.Enable = 'off';
            else
                gui_erp_simulation.srate.Value = 0;
                gui_erp_simulation.srateedit.Enable = 'off';
                gui_erp_simulation.srateperiod.Value = 1;
                gui_erp_simulation.srateperiodedit.Enable = 'on';
            end
        end
        plot_erp_simulation();
    end

%%------------------------ERPset edit--------------------------------------
    function erpsetedit(Str,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        ERPArray = str2num(Str.String);
        if  ~isempty(observe_ERPDAT.ALLERP)
            if ~isempty(ERPArray) && any(ERPArray>0)
                if numel(ERPArray) ~=1
                    ERPArray = ERPArray(1);
                end
                if ERPArray> length(observe_ERPDAT.ALLERP)
                    msgboxText =  'Create Artificial ERP Waveform -Real ERP: Input should be smaller than the length of ALLERP';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    Str.String = '';
                    return;
                end
                gui_erp_simulation.erpsetedit.String = num2str(ERPArray);
                ERP =observe_ERPDAT.ALLERP(ERPsetArray);
                if ~strcmpi(ERP.erpname,'No ERPset loaded')
                    EpochStart =[];
                    EpochStop = [];
                    srate =[];
                    try
                        EpochStart = ERP.times(1);
                        EpochStop = ERP.times(end);
                        srate = ERP.srate;
                    catch
                    end
                    if ~isempty(EpochStart) && ~isempty(EpochStop) && ~isempty(srate)
                        gui_erp_simulation.epoch_start.String = num2str(EpochStart);
                        gui_erp_simulation.epoch_stop.String = num2str(EpochStop);
                        if srate~=0
                            gui_erp_simulation.srateedit.String = num2str(srate);
                            gui_erp_simulation.srateperiodedit.String = num2str(1000/srate);
                        end
                    end
                end
            else
                msgboxText =  'Create Artificial ERP Waveform -Real ERP: Index of ERPset should be a positive numeric';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                Str.String = '';
                return;
            end
        else
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            msgboxText =  'Create Artificial ERP Waveform -Real ERP: ALLERPset is empty and cannot match simulation with it';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '';
            return;
        end
        plot_erp_simulation();
    end


%%-----------------------ERPset popup--------------------------------------
    function erpsetpopup(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        ERPArray = str2num(gui_erp_simulation.erpsetedit.String);
        if ~isempty(ERPArray)
            if numel(ERPArray)~=1
                ERPArray = ERPArray(1);
            end
            if ERPArray< 0 || ERPArray>  length(observe_ERPDAT.ALLERP)
                ERPArray = length(observe_ERPDAT.ALLERP);
            end
            gui_erp_simulation.erpsetedit.String = num2str(ERPArray);
            if ~isempty(observe_ERPDAT.ALLERP)
                for Numoferpset = 1:length(observe_ERPDAT.ALLERP)
                    listname{Numoferpset} = char(strcat(num2str(Numoferpset),'.',observe_ERPDAT.ALLERP(Numoferpset).erpname));
                end
                indxlistb  =ERPArray;
                
                titlename = 'Select one ERPset:';
                ERPsetArray = browsechanbinGUI(listname, indxlistb, titlename);
                if ~isempty(ERPsetArray)
                    if numel(ERPsetArray)~=1
                        ERPsetArray =ERPsetArray(1);
                    end
                    CURRENTERP = ERPsetArray;
                    ALLERP = observe_ERPDAT.ALLERP;
                    handles.CURRENTERP = ERPsetArray;
                    ERP =observe_ERPDAT.ALLERP(ERPsetArray);
                    if ~strcmpi(ERP.erpname,'No ERPset loaded')
                        EpochStart =[];
                        EpochStop = [];
                        srate =[];
                        if  ~isempty(CURRENTERP) && CURRENTERP >0 && CURRENTERP<= length(ALLERP)
                            ERP = ALLERP(CURRENTERP);
                        else
                            ERP =  ALLERP(length(ALLERP));
                        end
                        try
                            EpochStart = ERP.times(1);
                            EpochStop = ERP.times(end);
                            srate = ERP.srate;
                        catch
                        end
                        if ~isempty(EpochStart) && ~isempty(EpochStop) && ~isempty(srate)
                            gui_erp_simulation.epoch_start.String = num2str(EpochStart);
                            gui_erp_simulation.epoch_stop.String = num2str(EpochStop);
                            if srate~=0
                                gui_erp_simulation.srateedit.String = num2str(srate);
                                gui_erp_simulation.srateperiodedit.String = num2str(1000/srate);
                            end
                        end
                        gui_erp_simulation.erpsetedit.String = num2str(CURRENTERP);
                    end
                else%%the user did not select one ERPset
                    msgboxText =  'Create Artificial ERP Waveform -Real ERP: User selected cancel';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
                
            end
        end
        plot_erp_simulation();
    end


%%------------------------channel edit-------------------------------------
    function channeledit(Str,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        channelArray = str2num(Str.String);
        if ~isempty(observe_ERPDAT.ALLERP)
            if isempty(channelArray)
                msgboxText =  'Create Artificial ERP Waveform -Real ERP: Please input one positive numeric for "Channel"';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                Str.String = '1';
                return;
            end
            if numel(channelArray)~=1
                channelArray = channelArray(1);
            end
            if channelArray<=0
                msgboxText =  'Create Artificial ERP Waveform -Real ERP: Please input one positive numeric for "Channel"';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                Str.String = '1';
                return;
            end
            Str.String = num2str(channelArray);
        else
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            msgboxText =  'Create Artificial ERP Waveform -Real ERP: ALLERPset is empty and cannot match simulation with it';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '1';
            return;
        end
        plot_erp_simulation();
    end

%%------------------------channel popup------------------------------------
    function channelpopup(~,~)
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        if ~isempty(observe_ERPDAT.ALLERP)
            ERPsetArray =  str2num(gui_erp_simulation.erpsetedit.String);
            if ~isempty(ERPsetArray)
                if numel(ERPsetArray)~=1
                    ERPsetArray = ERPsetArray(1);
                end
                if ERPsetArray> length(observe_ERPDAT.ALLERP)
                    ERPsetArray = length(observe_ERPDAT.ALLERP);
                end
                gui_erp_simulation.erpsetedit.String = num2str(ERPsetArray);
                channelArray = str2num(gui_erp_simulation.channeledit.String);
                if isempty(channelArray)
                    channelArray=1;
                end
                if numel(channelArray)~=1
                    channelArray = channelArray(1);
                end
                if channelArray<=0
                    channelArray=1;
                end
                ERP = observe_ERPDAT.ALLERP(ERPsetArray);
                if max(channelArray(:)) >ERP.nchan
                    channelArray =1;
                end
                
                for Numofchan = 1:observe_ERPDAT.ALLERP(ERPsetArray).nchan
                    listb{Numofchan}= strcat(num2str(Numofchan),'.',observe_ERPDAT.ALLERP(ERPsetArray).chanlocs(Numofchan).labels);
                end
                titlename = 'Select One Channel:';
                channelArray = browsechanbinGUI(listb, channelArray, titlename);
                
                if ~isempty(channelArray)
                    if numel(channelArray)~=1
                        channelArray = channelArray(1);
                    end
                    gui_erp_simulation.channeledit.String = num2str(channelArray);
                else
                    msgboxText =  'Create Artificial ERP Waveform-Real ERP: User selected cancel';
                    titlNamerro = 'Warning for ERP Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    return;
                end
            end
        end
        plot_erp_simulation();
    end

%%------------------------bin edit-----------------------------------------
    function binedit(Str,~)
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            Str.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        binArray = str2num(Str.String);
        if  ~isempty(observe_ERPDAT.ALLERP)
            if isempty(binArray)
                msgboxText =  'Create Artificial ERP Waveform -Real ERP: Please input one positive numeric for "Bin"';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if numel(binArray)~=1
                binArray = binArray(1);
            end
            if binArray<=0
                msgboxText =  'Create Artificial ERP Waveform -Real ERP: Please input one positive numeric for "Bin"';
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                Str.String = '1';
                return;
            end
            Str.String = num2str(binArray);
        else
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            msgboxText =  'Create Artificial ERP Waveform -Real ERP: ALLERPset is empty and cannot match simulation with it';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '1';
            return;
        end
        plot_erp_simulation();
    end


%%-----------------------bin popup-----------------------------------------
    function binpopup(Str,~)
        if isempty(observe_ERPDAT.ALLERP) || isempty(observe_ERPDAT.ERP)
            Str.Enable = 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        if ~isempty(observe_ERPDAT.ALLERP)
            ERPsetArray =  str2num(gui_erp_simulation.erpsetedit.String);
            if ~isempty(ERPsetArray)
                if numel(ERPsetArray)~=1
                    ERPsetArray = ERPsetArray(1);
                end
                if ERPsetArray> length(observe_ERPDAT.ALLERP)
                    ERPsetArray = length(observe_ERPDAT.ALLERP);
                end
                gui_erp_simulation.erpsetedit.String = num2str(ERPsetArray);
                binArray = str2num(gui_erp_simulation.binedit.String);
                if isempty(binArray)
                    binArray=1;
                end
                if numel(binArray)~=1
                    binArray = binArray(1);
                end
                if binArray<=0
                    binArray=1;
                end
                ERP = observe_ERPDAT.ALLERP(ERPsetArray);
                if max(binArray(:)) >ERP.nchan
                    binArray =1;
                end
                
                for Numofchan = 1:observe_ERPDAT.ALLERP(ERPsetArray).nbin
                    listb{Numofchan}= strcat(num2str(Numofchan),'.',observe_ERPDAT.ALLERP(ERPsetArray).bindescr{Numofchan});
                end
                titlename = 'Select One Bin:';
                binArray = browsechanbinGUI(listb, binArray, titlename);
                
                if ~isempty(binArray)
                    if numel(binArray)~=1
                        binArray = binArray(1);
                    end
                    gui_erp_simulation.binedit.String = num2str(binArray);
                else
                    return;
                end
            end
        else
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            msgboxText =  'Create Artificial ERP Waveform -Real ERP: ALLERPset is empty and cannot match simulation with it';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '1';
            return;
        end
        plot_erp_simulation();
    end


%%----------------------------epoch start----------------------------------
    function epochstart(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        epochStart = str2num( gui_erp_simulation.epoch_start.String);
        epochStop = str2num( gui_erp_simulation.epoch_stop.String);
        if epochStart>=epochStop
            msgboxText =  ['Create Artificial ERP Waveform - The value for epoch start should be smaller than epoch stop'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '';
            return;
        end
        plot_erp_simulation();
    end

%%----------------------------epoch stop-----------------------------------
    function epocstop(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        epochStart = str2num( gui_erp_simulation.epoch_start.String);
        epochStop = str2num( gui_erp_simulation.epoch_stop.String);
        if epochStart>=epochStop
            msgboxText =  ['Create Artificial ERP Waveform - The value for epoch start should be smaller than epoch stop'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        plot_erp_simulation();
    end

%%---------------------Sampling rate option--------------------------------
    function srateop(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        gui_erp_simulation.srate.Value =1;
        gui_erp_simulation.srateedit.Enable = 'on';
        gui_erp_simulation.srateperiod.Value =0;
        gui_erp_simulation.srateperiodedit.Enable = 'off';
        plot_erp_simulation();
    end


%%--------------Edit sampling rate-----------------------------------------
    function srateedit(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        srate = str2num(Str.String);
        if ~isempty(srate) && numel(srate)==1 && srate>0
            gui_erp_simulation.srateperiodedit.String = num2str(1000/srate);
        else
            msgboxText =  ['Create Artificial ERP Waveform>sampling rate- the input should be a positive numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_simulation.srateperiodedit.String = '';
            return;
        end
        plot_erp_simulation();
    end

%%---------------------Sampling period-------------------------------------
    function srateperiod(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        gui_erp_simulation.srate.Value =0;
        gui_erp_simulation.srateedit.Enable = 'off';
        gui_erp_simulation.srateperiod.Value =1;
        gui_erp_simulation.srateperiodedit.Enable = 'on';
        plot_erp_simulation();
    end

%%----------------------Edit sampling period-------------------------------
    function srateperiodedit(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        srateperiod = str2num(Str.String);
        if ~isempty(srateperiod) && numel(srateperiod)==1 && srateperiod>0
            gui_erp_simulation.srateedit.String = num2str(1000/srateperiod);
        else
            msgboxText =  ['Create Artificial ERP Waveform>sampling period- the input should be a positive numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            gui_erp_simulation.srateedit.String = '';
            return;
        end
        plot_erp_simulation();
    end

%%--------------------------------Select ex-gaussian function--------------
    function exguass_op(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        gui_erp_simulation.exgua_op.Value =1;
        gui_erp_simulation.exgua_peakamp.Enable = 'on';
        gui_erp_simulation.exgua_mean.Enable = 'on';
        gui_erp_simulation.exgua_sd.Enable = 'on';
        gui_erp_simulation.exgua_tau.Enable = 'on';
        gui_erp_simulation.impulse_op.Value = 0;
        gui_erp_simulation.impulse_peakamp.Enable = 'off';
        gui_erp_simulation.impulse_latency.Enable = 'off';
        gui_erp_simulation.square_op.Value = 0;
        gui_erp_simulation.square_onset.Enable = 'off';
        gui_erp_simulation.square_offset.Enable = 'off';
        gui_erp_simulation.square_peakamp.Enable = 'off';
        plot_erp_simulation();
    end


%%---------------Peak amplitude for ex-Gaussian function-------------------
    function exgau_peakamp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        PeakAmp = str2num(Str.String);
        if isempty(PeakAmp) || numel(PeakAmp)~=1
            msgboxText =  ['Create Artificial ERP Waveform> peak amplitude for Ex-Gaussian should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%------------------Guasssian mean-----------------------------------------
    function exgau_mean(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        Mean = str2num(Str.String);
        if isempty(Mean) || numel(Mean)~=1
            msgboxText =  ['Create Artificial ERP Waveform> Gaussian mean for Ex-Gaussian should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%-----------------SD for Ex-Gaussian function-----------------------------
    function exgau_sd(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        SD = str2num(Str.String);
        if isempty(SD) || numel(SD)~=1
            msgboxText =  ['Create Artificial ERP Waveform> SD for Ex-Gaussian should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end


%%----------------Tau for Ex-Gaussian function-----------------------------
    function exgau_tau(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        Tau = str2num(Str.String);
        if isempty(Tau) || numel(Tau)~=1
            msgboxText =  ['Create Artificial ERP Waveform> Exponential tau for Ex-Gaussian should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end


%%--------------------------------impulse function-------------------------
    function impulse_op(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        gui_erp_simulation.exgua_op.Value =0;
        gui_erp_simulation.exgua_peakamp.Enable = 'off';
        gui_erp_simulation.exgua_mean.Enable = 'off';
        gui_erp_simulation.exgua_sd.Enable = 'off';
        gui_erp_simulation.exgua_tau.Enable = 'off';
        gui_erp_simulation.impulse_op.Value = 1;
        gui_erp_simulation.impulse_peakamp.Enable = 'on';
        gui_erp_simulation.impulse_latency.Enable = 'on';
        gui_erp_simulation.square_op.Value = 0;
        gui_erp_simulation.square_onset.Enable = 'off';
        gui_erp_simulation.square_offset.Enable = 'off';
        gui_erp_simulation.square_peakamp.Enable = 'off';
        plot_erp_simulation();
    end

%%-------------Impulse peak amplitude--------------------------------------
    function impulse_peakamp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        peakAmp = str2num(Str.String);
        if isempty(peakAmp)
            msgboxText =  ['Create Artificial ERP Waveform>Impulse- peak amplitude should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%-------------------Latency for impluse-----------------------------------
    function impulse_latency(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        peakLat = str2num(Str.String);
        if isempty(peakLat)
            msgboxText =  ['Create Artificial ERP Waveform>Impulse- Latency should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%--------------------------------square function--------------------------
    function square_op(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        gui_erp_simulation.exgua_op.Value =0;
        gui_erp_simulation.exgua_peakamp.Enable = 'off';
        gui_erp_simulation.exgua_mean.Enable = 'off';
        gui_erp_simulation.exgua_sd.Enable = 'off';
        gui_erp_simulation.exgua_tau.Enable = 'off';
        gui_erp_simulation.impulse_op.Value = 0;
        gui_erp_simulation.impulse_peakamp.Enable = 'off';
        gui_erp_simulation.impulse_latency.Enable = 'off';
        gui_erp_simulation.square_op.Value = 1;
        gui_erp_simulation.square_onset.Enable = 'on';
        gui_erp_simulation.square_offset.Enable = 'on';
        gui_erp_simulation.square_peakamp.Enable = 'on';
        plot_erp_simulation();
    end


%%--------------Peak amplitude for square function-------------------------
    function square_peakamp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        peakAmp = str2num(Str.String);
        if isempty(peakAmp)
            msgboxText =  ['Create Artificial ERP Waveform>Square- peak amplitude should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%------------------Square onset latency-----------------------------------
    function square_onset(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        onsetlat = str2num(Str.String);
        if isempty(onsetlat)
            msgboxText =  ['Create Artificial ERP Waveform>Boxcar- Onset latency should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        offsetLat = str2num(gui_erp_simulation.square_offset.String);
        if onsetlat>offsetLat
            msgboxText =  ['Create Artificial ERP Waveform>Boxcar- Onset latency should be smaller than',32,num2str(offsetLat)];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%------------------Boxcar offset latency----------------------------------
    function square_offset(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        offsetlat = str2num(Str.String);
        if isempty(offsetlat)
            msgboxText =  ['Create Artificial ERP Waveform>Boxcar- Offset latency should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        onsetlat = str2num(gui_erp_simulation.square_onset.String);
        if offsetlat<onsetlat
            msgboxText =  ['Create Artificial ERP Waveform>Boxcar- Offset latency should be larger than',32,num2str(onsetlat)];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%-----------------update new noise if needed------------------------------
    function newnoise_op(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        %%reset the phase for sin signal
        SimulationPhase = rand(1);
        erpworkingmemory('SimulationPhase',SimulationPhase);
        
        %%reset seeds for white or pink noise
        SimulationSeed = erpworkingmemory('SimulationSeed');
        try
            SimulationSeed.Type = 'philox';
            SimulationSeed.Seed = SimulationSeed.Seed+1;
        catch
            SimulationSeed.Type = 'twister';
            SimulationSeed.Seed = 1;
        end
        erpworkingmemory('SimulationSeed',SimulationSeed);
        gui_erp_simulation.SimulationSeed = SimulationSeed;
        gui_erp_simulation.SimulationPhase = SimulationPhase;
        plot_erp_simulation();
    end

%%-----------------check box of sin function-------------------------------
    function sinoise_op(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        Value = Str.Value;
        if Value==1
            Enable = 'on';
        else
            Enable = 'off';
        end
        gui_erp_simulation.sin_amp.Enable = Enable;
        gui_erp_simulation.sin_fre.Enable = Enable;
        plot_erp_simulation();
    end

%%---------------Peak amplitude for sin noise------------------------------
    function sin_amp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        peakAmp = str2num(Str.String);
        if isempty(peakAmp)
            msgboxText =  ['Create Artificial ERP Waveform>Sinusoidal noise- peak amplitude should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%------------------Frequency for sin noise--------------------------------
    function sinoise_fre(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        Fresin = str2num(Str.String);
        if isempty(Fresin) || Fresin<=0
            msgboxText =  ['Create Artificial ERP Waveform>Sinusoidal noise- frequency should be a positive numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '';
            return;
        end
        plot_erp_simulation();
    end

%%------------checkbox for white noise-------------------------------------
    function whitenoise_op(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        if Str.Value ==1
            gui_erp_simulation.white_amp.Enable ='on';
        else
            gui_erp_simulation.white_amp.Enable ='off';
        end
        plot_erp_simulation();
    end

%%-------------------Peak amplitude for white noise------------------------
    function white_amp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        peakAmp = str2num(Str.String);
        if isempty(peakAmp)
            msgboxText =  ['Create Artificial ERP Waveform>White noise- peak amplitude should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%--------------------check box for pink noise-----------------------------
    function pinknoise_op(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        if Str.Value ==1
            gui_erp_simulation.pink_amp.Enable = 'on';
        else
            gui_erp_simulation.pink_amp.Enable = 'off';
        end
        plot_erp_simulation();
    end

%%------------------peak amplitude of pink noise---------------------------
    function pink_amp(Str,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        peakAmp = str2num(Str.String);
        if isempty(peakAmp)
            msgboxText =  ['Create Artificial ERP Waveform>Pink noise- peak amplitude should be a numeric'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            Str.String = '0';
            return;
        end
        plot_erp_simulation();
    end

%%-----------------------Help----------------------------------------------
    function simulation_cancel(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_simulation.apply.ForegroundColor = [0 0 0];
        ERP_simulation_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [1 1 1];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_stimulation',0);
        
        
        try gui_erp_simulation.realerp_check.Value = gui_erp_simulation.Paras{1};catch gui_erp_simulation.realerp_check.Value=0; end
        gui_erp_simulation.erpsetedit.String = num2str(gui_erp_simulation.Paras{2});
        if gui_erp_simulation.realerp_check.Value==0
            Enable1 = 'off';
            Enable2 = 'on';
        else
            Enable1 = 'on';
            Enable2 = 'off';
        end
        %%chan
        gui_erp_simulation.erpsetpopup.Enable = Enable1;
        gui_erp_simulation.erpsetedit.Enable = Enable1;
        gui_erp_simulation.channeledit.String = num2str(gui_erp_simulation.Paras{3});
        gui_erp_simulation.channeledit.Enable = Enable1;
        gui_erp_simulation.channelpopup.Enable = Enable1;
        %%bin
        gui_erp_simulation.binedit.String= num2str(gui_erp_simulation.Paras{4});
        gui_erp_simulation.binedit.Enable = Enable1;
        gui_erp_simulation.binpopup.Enable = Enable1;
        %%start and end for the epoch
        gui_erp_simulation.epoch_start.String = num2str(gui_erp_simulation.Paras{5});
        gui_erp_simulation.epoch_stop.String = num2str(gui_erp_simulation.Paras{6});
        gui_erp_simulation.epoch_start.Enable = Enable2;
        gui_erp_simulation.epoch_stop.Enable = Enable2;
        %%sampling rate
        gui_erp_simulation.srate.Value = gui_erp_simulation.Paras{7};
        gui_erp_simulation.srateedit.String = num2str( gui_erp_simulation.Paras{8});
        if gui_erp_simulation.srate.Value==1
            gui_erp_simulation.srateedit.Enable = 'on';
            gui_erp_simulation.srateperiod.Value=0;
            if ~isempty(gui_erp_simulation.Paras{8}) && gui_erp_simulation.Paras{8}~=0
                gui_erp_simulation.srateperiodedit = num2str(1000/gui_erp_simulation.Paras{8});
            end
        else
            gui_erp_simulation.srateedit.Enable = 'off';
            gui_erp_simulation.srateperiod.Value=1;
            if ~isempty(gui_erp_simulation.Paras{8}) && gui_erp_simulation.Paras{8}~=0
                gui_erp_simulation.srateperiodedit.String = num2str(1000/gui_erp_simulation.Paras{8});
            end
        end
        if gui_erp_simulation.realerp_check.Value==1
            gui_erp_simulation.srate.Enable = Enable2;
            gui_erp_simulation.srateedit.Enable = Enable2;
            gui_erp_simulation.srateperiod.Enable = Enable2;
            gui_erp_simulation.srateperiodedit.Enable = Enable2;
        end
        %%exgaussian
        gui_erp_simulation.exgua_op.Value= gui_erp_simulation.Paras{9};
        if gui_erp_simulation.exgua_op.Value==1
            Enableflag = 'on';
        else
            Enableflag = 'off';
        end
        gui_erp_simulation.exgua_peakamp.String = num2str(gui_erp_simulation.Paras{10});
        gui_erp_simulation.exgua_mean.String = num2str(gui_erp_simulation.Paras{11});
        gui_erp_simulation.exgua_sd.String= num2str(gui_erp_simulation.Paras{12});
        gui_erp_simulation.exgua_tau.String= num2str(gui_erp_simulation.Paras{13});
        gui_erp_simulation.exgua_peakamp.Enable = Enableflag;
        gui_erp_simulation.exgua_mean.Enable = Enableflag;
        gui_erp_simulation.exgua_sd.Enable = Enableflag;
        gui_erp_simulation.exgua_tau.Enable = Enableflag;
        
        %%impulse
        gui_erp_simulation.impulse_op.Value = gui_erp_simulation.Paras{14};
        if gui_erp_simulation.impulse_op.Value==1
            Enableflag = 'on';
        else
            Enableflag = 'off';
        end
        gui_erp_simulation.impulse_peakamp.String = num2str(gui_erp_simulation.Paras{15});
        gui_erp_simulation.impulse_latency.String=num2str(gui_erp_simulation.Paras{16});
        gui_erp_simulation.impulse_peakamp.Enable = Enableflag;
        gui_erp_simulation.impulse_latency.Enable = Enableflag;
        
        %%boxcar
        gui_erp_simulation.square_op.Value=gui_erp_simulation.Paras{17};
        gui_erp_simulation.square_peakamp.String = num2str(gui_erp_simulation.Paras{18});
        gui_erp_simulation.square_onset.String= num2str(gui_erp_simulation.Paras{19});
        gui_erp_simulation.square_offset.String= num2str(gui_erp_simulation.Paras{20});
        if gui_erp_simulation.square_op.Value==1
            Enableflag = 'on';
        else
            Enableflag = 'off';
        end
        gui_erp_simulation.square_peakamp.Enable = Enableflag;
        gui_erp_simulation.square_onset.Enable = Enableflag;
        gui_erp_simulation.square_offset.Enable = Enableflag;
        
        %%sinusoidal signal
        gui_erp_simulation.sin_op.Value = gui_erp_simulation.Paras{21};
        gui_erp_simulation.sin_amp.String =num2str(gui_erp_simulation.Paras{22});
        gui_erp_simulation.sin_fre.String=num2str(gui_erp_simulation.Paras{23});
        if gui_erp_simulation.sin_op.Value
            Enableflag = 'on';
        else
            Enableflag = 'off';
        end
        gui_erp_simulation.sin_amp.Enable = Enableflag;
        gui_erp_simulation.sin_fre.Enable = Enableflag;
        
        %%white noise
        gui_erp_simulation.white_op.Value=gui_erp_simulation.Paras{24};
        gui_erp_simulation.white_amp.String = num2str(gui_erp_simulation.Paras{25});
        if gui_erp_simulation.white_op.Value==1
            gui_erp_simulation.white_amp.Enable = 'on';
        else
            gui_erp_simulation.white_amp.Enable = 'off';
        end
        
        %%pink noise
        gui_erp_simulation.pink_op.Value=gui_erp_simulation.Paras{26};
        gui_erp_simulation.pink_amp.String = num2str(gui_erp_simulation.Paras{27});
        if gui_erp_simulation.pink_op.Value==1
            gui_erp_simulation.pink_amp.Enable = 'on';
        else
            gui_erp_simulation.pink_amp.Enable = 'off';
        end
    end


%%----------------------apply----------------------------------------------
    function simulation_apply(~,~)
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=13
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_simulation.apply.ForegroundColor = [1 1 1];
        ERP_simulation_box.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_stimulation',1);
        
        erpworkingmemory('f_ERP_proces_messg','Create Artificial ERP waveform');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        ALLERPCOM = evalin('base','ALLERPCOM');
        
        EpochStart = str2num(gui_erp_simulation.epoch_start.String);
        EpochStop = str2num(gui_erp_simulation.epoch_stop.String);
        if gui_erp_simulation.srate.Value
            Srate = str2num(gui_erp_simulation.srateedit.String);
            if isempty(Srate) || numel(Srate)~=1
                msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for sampling rate'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateedit.String = '';
                return;
            end
            if Srate<=0
                msgboxText =  ['Create Artificial ERP Waveform>Sampling rate must be a positive numeric'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateedit.String = '';
                return;
            end
        else%% sampling period
            Speriod =  str2num(gui_erp_simulation.srateperiodedit.String);
            if isempty(Speriod) || numel(Speriod)~=1
                msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for sampling period'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateperiodedit.String = '';
                return;
            end
            if Speriod<=0
                msgboxText =  ['Create Artificial ERP Waveform>Sampling period must be a positive numeric'];
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                gui_erp_simulation.srateperiodedit.String = '';
                return;
            end
            Srate = 1000/Speriod;
        end
        if isempty(EpochStart) || numel(EpochStart)~=1
            msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for epoch start'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if isempty(EpochStop) || numel(EpochStop)~=1
            msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for epoch stop'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if EpochStop<=EpochStart
            msgboxText =  ['Create Artificial ERP Waveform> Start time of epoch must be smaller than stop time of epoch'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if 1000/Srate>= (EpochStop-EpochStart)
            msgboxText =  ['Create Artificial ERP Waveform> Please sampling period must be much smaller than ',32,num2str(EpochStop-EpochStart)];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        %%---------------------------Simulated signal------------------------------
        ExGauTau =0;
        SDOffset =50;
        MeanLatOnset =0;
        if gui_erp_simulation.exgua_op.Value ==1
            BasFuncName = 'ExGaussian';
            BasPeakAmp =   str2num(gui_erp_simulation.exgua_peakamp.String);
            if isempty(BasPeakAmp) || numel(BasPeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            MeanLatOnset = str2num(gui_erp_simulation.exgua_mean.String);
            if isempty(MeanLatOnset) || numel(MeanLatOnset)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "Gaussian mean" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            ExGauTau =  str2num(gui_erp_simulation.exgua_tau.String);
            if isempty(ExGauTau) || numel(ExGauTau)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "Tau" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            SDOffset = str2num(gui_erp_simulation.exgua_sd.String);
            if isempty(SDOffset) || numel(SDOffset)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "SD" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        elseif  gui_erp_simulation.impulse_op.Value ==1
            BasFuncName = 'Impulse';
            BasPeakAmp =   str2num(gui_erp_simulation.impulse_peakamp.String);
            if isempty(BasPeakAmp) || numel(BasPeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of impulse function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            MeanLatOnset = str2num(gui_erp_simulation.impulse_latency.String);
            if isempty(MeanLatOnset) || numel(MeanLatOnset)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "latency" of impulse function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        elseif gui_erp_simulation.square_op.Value ==1
            BasFuncName = 'Boxcar';
            BasPeakAmp =   str2num(gui_erp_simulation.square_peakamp.String);
            if isempty(BasPeakAmp) || numel(BasPeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            MeanLatOnset = str2num(gui_erp_simulation.square_onset.String);
            if isempty(MeanLatOnset) || numel(MeanLatOnset)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "onset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            SDOffset = str2num(gui_erp_simulation.square_offset.String);
            if isempty(SDOffset) || numel(SDOffset)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "offset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if SDOffset< MeanLatOnset
                msgboxText =  ['Create Artificial ERP Waveform> Please "offset" should be larger than "onset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        end
        %%---------------------------Noise signal----------------------------------
        if gui_erp_simulation.sin_op.Value==1
            SinoiseAmp =   str2num(gui_erp_simulation.sin_amp.String);
            if isempty(SinoiseAmp) || numel(SinoiseAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "amplitude" of sinusoidal noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            SinoiseFre =  str2num(gui_erp_simulation.sin_fre.String);
            if isempty(SinoiseFre) || numel(SinoiseFre)~=1 || SinoiseFre<=0
                msgboxText =  ['Create Artificial ERP Waveform> Please define one positive numeric for "frequency" of sinusoidal noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            SinoiseAmp =0;
            SinoiseFre =10;
        end
        if gui_erp_simulation.white_op.Value==1
            WhiteAmp =   str2num(gui_erp_simulation.white_amp.String);
            if isempty(WhiteAmp) || numel(WhiteAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform>  Please define one numeric for "amplitude" of white noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            WhiteAmp =0;
        end
        
        if gui_erp_simulation.pink_op.Value==1
            PinkAmp =   str2num(gui_erp_simulation.pink_amp.String);
            if isempty(PinkAmp) || numel(PinkAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "amplitude" of pink noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
        else
            PinkAmp = 0;
        end
        NewnoiseFlag = gui_erp_simulation.newnoise_op.Value;
        
        gui_erp_simulation.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_simulation.apply.ForegroundColor = [0 0 0];
        ERP_simulation_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [1 1 1];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_stimulation',0);
        
        gui_erp_simulation.Paras{1}=gui_erp_simulation.realerp_check.Value;
        gui_erp_simulation.Paras{2} = str2num(gui_erp_simulation.erpsetedit.String);
        gui_erp_simulation.Paras{3} = str2num(gui_erp_simulation.channeledit.String);
        gui_erp_simulation.Paras{4} = str2num(gui_erp_simulation.binedit.String);
        gui_erp_simulation.Paras{5} = str2num(gui_erp_simulation.epoch_start.String);
        gui_erp_simulation.Paras{6} = str2num(gui_erp_simulation.epoch_stop.String);
        gui_erp_simulation.Paras{7} = gui_erp_simulation.srate.Value;
        gui_erp_simulation.Paras{8} = str2num(gui_erp_simulation.srateedit.String);
        gui_erp_simulation.Paras{9} = gui_erp_simulation.exgua_op.Value;
        gui_erp_simulation.Paras{10} = str2num(gui_erp_simulation.exgua_peakamp.String);
        gui_erp_simulation.Paras{11} = str2num(gui_erp_simulation.exgua_mean.String);
        gui_erp_simulation.Paras{12} = str2num(gui_erp_simulation.exgua_sd.String);
        gui_erp_simulation.Paras{13} = str2num(gui_erp_simulation.exgua_tau.String);
        gui_erp_simulation.Paras{14} = gui_erp_simulation.impulse_op.Value;
        gui_erp_simulation.Paras{15} = str2num(gui_erp_simulation.impulse_peakamp.String);
        gui_erp_simulation.Paras{16} = str2num(gui_erp_simulation.impulse_latency.String);
        gui_erp_simulation.Paras{17} =gui_erp_simulation.square_op.Value;
        gui_erp_simulation.Paras{18} =str2num(gui_erp_simulation.square_peakamp.String);
        gui_erp_simulation.Paras{19} =str2num(gui_erp_simulation.square_onset.String);
        gui_erp_simulation.Paras{20} =str2num(gui_erp_simulation.square_offset.String);
        gui_erp_simulation.Paras{21} = gui_erp_simulation.sin_op.Value;
        gui_erp_simulation.Paras{22} = str2num(gui_erp_simulation.sin_amp.String);
        gui_erp_simulation.Paras{23} = str2num(gui_erp_simulation.sin_fre.String);
        gui_erp_simulation.Paras{24} = gui_erp_simulation.white_op.Value;
        gui_erp_simulation.Paras{25} = str2num(gui_erp_simulation.white_amp.String);
        gui_erp_simulation.Paras{26} = gui_erp_simulation.pink_op.Value;
        gui_erp_simulation.Paras{27} = str2num(gui_erp_simulation.pink_amp.String);
        ALLERP = [];
        [ERP, ERPCOM] =  pop_ERP_simulation(ALLERP,BasFuncName,'EpochStart',EpochStart,'EpochStop',EpochStop,'Srate',Srate,'BasPeakAmp',BasPeakAmp,'MeanLatencyOnset',MeanLatOnset,'SDOffset',SDOffset,...
            'ExGauTau',ExGauTau,'SinoiseAmp',SinoiseAmp,'SinoiseFre',SinoiseFre,'WhiteAmp',WhiteAmp,'PinkAmp',PinkAmp,'NewnoiseFlag',NewnoiseFlag,'Saveas', 'off','History', 'gui');
        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
        
        Answer = f_ERP_save_single_file(strcat(ERP.erpname),ERP.filename,length(observe_ERPDAT.ALLERP)+1);
        if isempty(Answer)
            beep;
            return;
        end
        if ~isempty(Answer)
            ERPName = Answer{1};
            if ~isempty(ERPName)
                ERP.erpname = ERPName;
            end
            fileName_full = Answer{2};
            if isempty(fileName_full)
                ERP.filename = ERP.erpname;
            elseif ~isempty(fileName_full)
                [pathstr, file_name, ext] = fileparts(fileName_full);
                ext = '.erp';
                if strcmp(pathstr,'')
                    pathstr = cd;
                end
                ERP.filename = [file_name,ext];
                ERP.filepath = pathstr;
                %%----------save the current sdata as--------------------
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
        end
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        if isempty(observe_ERPDAT.ALLERP)
            observe_ERPDAT.ALLERP = ERP;
        else
            observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
        end
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        estudioworkingmemory('selectederpstudio',observe_ERPDAT.CURRENTERP);
        erpworkingmemory('ERP_simulation',1);
        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
        
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%-------------------------------------------------------------------------
%%-----------------Plot ERP for the simulation-----------------------------
%%-------------------------------------------------------------------------
    function plot_erp_simulation(~,~)
        MatchFlag = gui_erp_simulation.realerp_check.Value;
        ALLERP = observe_ERPDAT.ALLERP;
        ERP = [];
        ERPArray = [];
        ChannelArray = [];
        binArray = [];
        if MatchFlag==1 && ~isempty(ALLERP)
            %%check ERPset
            ERPArray = str2num(gui_erp_simulation.erpsetedit.String);
            if ~isempty(ERPArray)
                if numel(ERPArray)~=1
                    ERPArray = ERPArray(1);
                end
                if ERPArray>0 && ERPArray <=length(ALLERP)
                else
                    ERPArray = length(ALLERP);
                end
            else
                ERPArray = length(ALLERP);
            end
            gui_erp_simulation.erpsetedit.String= num2str(ERPArray);
            ERP = ALLERP(ERPArray);
            %%check channels
            ChannelArray = str2num(gui_erp_simulation.channeledit.String);
            if isempty(ChannelArray)
                ChannelArray =1;
            else
                if numel(ChannelArray)~=1
                    ChannelArray = ChannelArray(1);
                end
                if ChannelArray>0 && ChannelArray<= ERP.nchan
                else
                    ChannelArray =1;
                end
            end
            gui_erp_simulation.channeledit.String = num2str(ChannelArray);
            %%check bins
            binArray =  str2num(gui_erp_simulation.binedit.String);
            if isempty(binArray)
                binArray =1;
            else
                if numel(binArray)~=1
                    binArray = binArray(1);
                end
                if binArray>0 && binArray<=ERP.nbin
                else
                    binArray =1;
                end
            end
            gui_erp_simulation.binedit.String = num2str(binArray);
        end
        
        EpochStart = str2num(gui_erp_simulation.epoch_start.String);
        EpochStop = str2num(gui_erp_simulation.epoch_stop.String);
        if gui_erp_simulation.srate.Value
            srate = str2num(gui_erp_simulation.srateedit.String);
            if isempty(srate) || numel(srate)~=1
                msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for sampling rate'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateedit.String = '';
                return;
            end
            if srate<=0
                msgboxText =  ['Create Artificial ERP Waveform>Sampling rate must be a positive numeric'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateedit.String = '';
                return;
            end
        else%% sampling period
            Speriod =  str2num(gui_erp_simulation.srateperiodedit.String);
            if isempty(Speriod) || numel(Speriod)~=1
                msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for sampling period'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateperiodedit.String = '';
                return;
            end
            if Speriod<=0
                msgboxText =  ['Create Artificial ERP Waveform>Sampling period must be positive numeric'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                gui_erp_simulation.srateperiodedit.String = '';
                return;
            end
            srate = 1000/Speriod;
        end
        if isempty(EpochStart) || numel(EpochStart)~=1
            msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for epoch start'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if isempty(EpochStop) || numel(EpochStop)~=1
            msgboxText =  ['Create Artificial ERP Waveform>Please define one numeric for epoch stop'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        if EpochStop<=EpochStart
            msgboxText =  ['Create Artificial ERP Waveform> Start time of epoch must be smaller than stop time of epoch'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if 1000/srate>= (EpochStop-EpochStart)
            msgboxText =  ['Create Artificial ERP Waveform> Please sampling period must be much smaller than ',32,num2str(EpochStop-EpochStart)];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        
        Times = [];
        if EpochStart>=0
            count =0;
            tIndex(1,1) =0;
            for ii = 1:10000
                count = count+1000/srate;
                if count<=EpochStop
                    tIndex(1,ii) = count;
                else
                    break;
                end
            end
            [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
            Times = tIndex(latsamp(1):end);
            if Times(1)<EpochStart
                Times(1) = [];
            end
        elseif EpochStop<=0
            count =0;
            tIndex(1,1) =0;
            for ii = 2:10000
                count = count-1000/srate;
                if count>=EpochStart
                    tIndex(1,ii) = count;
                else
                    break;
                end
            end
            tIndex = sort(tIndex);
            [xxx, latsamp, latdiffms] = closest(tIndex, [EpochStart,EpochStop]);
            
            Times = tIndex(1:latsamp(2));
            if Times(end)> EpochStop
                Times(end) = [];
            end
        elseif EpochStart<0 && EpochStop>0
            tIndex1(1,1)  = 0;
            count =0;
            for ii = 1:10000
                count = count-1000/srate;
                if count>=EpochStart
                    tIndex1(1,ii+1) = count;
                else
                    break;
                end
            end
            tIndex2=[];
            count1 =0;
            for ii = 1:10000
                count1 = count1+1000/srate;
                if count1<=EpochStop
                    tIndex2(1,ii) = count1;
                else
                    break;
                end
            end
            Times = [sort(tIndex1),tIndex2];
        end
        if ~isempty(ERP)
            Times= ERP.times;
        end
        [x1,y1]  = find(roundn(Times,-3)==roundn(EpochStart,-3));
        [x2,y2]  = find(roundn(Times,-3)==roundn(EpochStop,-3));
        if isempty(y1) || isempty(y2)
            msgboxText = 'Create Artificial ERP Waveform> The exact time periods you have specified cannot be exactly created with the specified sampling rate. We will round to the nearest possible time values when the ERPset is created.';
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
        end
        Desiredsignal = zeros(1,numel(Times));
        Desirednosizesin = zeros(1,numel(Times));
        Desirednosizewhite = zeros(1,numel(Times));
        Desirednosizepink = zeros(1,numel(Times));
        RealData = nan(1,numel(Times));
        %%---------------------------Simulated signal------------------------------
        if gui_erp_simulation.exgua_op.Value ==1
            Gua_PDF = zeros(1,numel(Times));
            PeakAmp =   str2num(gui_erp_simulation.exgua_peakamp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            Meanamp = str2num(gui_erp_simulation.exgua_mean.String);
            if isempty(Meanamp) || numel(Meanamp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "Gaussian mean" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            Tau =  str2num(gui_erp_simulation.exgua_tau.String);
            if isempty(Tau) || numel(Tau)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "Tau" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            
            SD = str2num(gui_erp_simulation.exgua_sd.String);
            if isempty(SD) || numel(SD)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "SD" of Ex-Gaussian function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            SD = SD/100;
            if Tau~=0
                Mu =  Meanamp/100-Times(1)/100;
                if Mu<0
                    Mu =  Meanamp/100;
                end
                if Tau<0
                    Mu = abs((Times(end)/100-Times(1)/100)-Mu);
                end
                LegthSig = (Times(end)-Times(1))/100;
                Sig = 0: LegthSig/numel(Times):LegthSig-LegthSig/numel(Times);
                Gua_PDF = f_exgauss_pdf(Sig, Mu, SD, abs(Tau));
                if Tau<0
                    Gua_PDF = fliplr(Gua_PDF);
                end
            elseif Tau==0 %%Gaussian signal
                Times_new = Times/1000;
                Gua_PDF = f_gaussian(Times_new,abs(PeakAmp),Meanamp/1000,SD/10);
            end
            Max = max(abs( Gua_PDF(:)));
            Gua_PDF = PeakAmp*Gua_PDF./Max;
            if PeakAmp~=0
                Desiredsignal = Gua_PDF;
            end
        elseif  gui_erp_simulation.impulse_op.Value ==1
            PeakAmp =   str2num(gui_erp_simulation.impulse_peakamp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of impulse function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            Latency = str2num(gui_erp_simulation.impulse_latency.String);
            if isempty(Latency) || numel(Latency)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "latency" of impulse function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if Latency<Times(1)
                Latency=Times(1);
            end
            if Latency>Times(end)
                Latency=Times(end);
            end
            [xxx, latsamp, latdiffms] = closest(Times, Latency);
            Desiredsignal(latsamp) = PeakAmp;
            
        elseif gui_erp_simulation.square_op.Value ==1
            PeakAmp =   str2num(gui_erp_simulation.square_peakamp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "peak amplitude" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            onsetLat = str2num(gui_erp_simulation.square_onset.String);
            if isempty(onsetLat) || numel(onsetLat)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "onset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            offsetLat = str2num(gui_erp_simulation.square_offset.String);
            if isempty(offsetLat) || numel(offsetLat)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "offset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            if offsetLat< onsetLat
                msgboxText =  ['Create Artificial ERP Waveform> Please "offset" should be larger than "onset" of Boxcar function'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            [xxx, latsamp, latdiffms] = closest(Times, [onsetLat,offsetLat]);
            Desiredsignal(latsamp(1):latsamp(2)) = PeakAmp;
        end
        
        %%---------------------------Noise signal----------------------------------
        %         SimulationSeed = erpworkingmemory('SimulationSeed');
        SimulationSeed= gui_erp_simulation.SimulationSeed ;
        try
            SimulationSeed_Type = SimulationSeed.Type;
            SimulationSeed_seed=SimulationSeed.Seed;
        catch
            SimulationSeed_Type = 'twister';
            SimulationSeed_seed = 1;
        end
        %phase for sin noise
        %         SimulationPhase = erpworkingmemory('SimulationPhase');
        SimulationPhase =  gui_erp_simulation.SimulationPhase;
        if isempty(SimulationPhase) ||  ~isnumeric(SimulationPhase)
            SimulationPhase = 0;
        end
        if numel(SimulationPhase)~=1
            SimulationPhase = SimulationPhase(1);
        end
        if SimulationPhase<0 || SimulationPhase>1
            SimulationPhase = 0;
        end
        if gui_erp_simulation.sin_op.Value==1
            PeakAmp =   str2num(gui_erp_simulation.sin_amp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "amplitude" of sinusoidal noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            FreHz =  str2num(gui_erp_simulation.sin_fre.String);
            
            if isempty(FreHz) || numel(FreHz)~=1 || FreHz<=0
                msgboxText =  ['Create Artificial ERP Waveform> Please define one positive numeric for "frequency" of sinusoidal noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            X =  Times/1000;
            Desirednosizesin = PeakAmp*sin(2*FreHz*pi*(X)+2*pi*SimulationPhase);
            
        end
        if gui_erp_simulation.white_op.Value==1
            PeakAmp =   str2num(gui_erp_simulation.white_amp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform>  Please define one numeric for "amplitude" of white noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            try
                rng(SimulationSeed_seed,SimulationSeed_Type);
            catch
                rng(1,'twister');
            end
            Desirednosizewhite =  randn(1,numel(Times));%%white noise
            Desirednosizewhite = PeakAmp*Desirednosizewhite./max(abs(Desirednosizewhite(:)));
        end
        
        if gui_erp_simulation.pink_op.Value==1
            PeakAmp =   str2num(gui_erp_simulation.pink_amp.String);
            if isempty(PeakAmp) || numel(PeakAmp)~=1
                msgboxText =  ['Create Artificial ERP Waveform> Please define one numeric for "amplitude" of pink noise'];
                titlNamerro = 'Warning for ERP Tab';
                estudio_warning(msgboxText,titlNamerro);
                return;
            end
            try
                rng(SimulationSeed_seed,SimulationSeed_Type);
            catch
                rng(1,'twister');
            end
            Desirednosizepink = f_pinknoise(numel(Times));
            Desirednosizepink = reshape(Desirednosizepink,1,numel(Desirednosizepink));
            Desirednosizepink = PeakAmp*Desirednosizepink./max(abs(Desirednosizepink(:)));
        end
        Sig = Desirednosizesin+Desiredsignal+Desirednosizepink+Desirednosizewhite;
        
        if ~isempty(ERP) && ~isempty(ChannelArray) && ~isempty(binArray)
            try
                RealData = squeeze(ERP.bindata(ChannelArray,:,binArray));
                plot(gui_erp_simulation.plot_erp,Times,[Sig;RealData],'linewidth',1.5);
                
            catch
            end
        else
            plot(gui_erp_simulation.plot_erp,Times,Sig,'k','linewidth',1.5);
        end
        %         gui_erp_simulation.plot_erp.FontSize =12;
        xlim(gui_erp_simulation.plot_erp,[Times(1),Times(end)]);
    end


%%-------enable the panel for real data------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=18
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;erpworkingmemory('ViewerFlag',0);
        end
        if isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP) || strcmp(observe_ERPDAT.ERP.datatype,'EFFT') || ViewerFlag==1
            gui_erp_simulation.realerp_check.Value =0;
            EnableFlag = 'off';
            gui_erp_simulation.realerp_check.Enable = EnableFlag;
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
        else
            gui_erp_simulation.realerp_check.Enable = 'on';
            if gui_erp_simulation.realerp_check.Value==1
                EnableFlag = 'on';
            else
                EnableFlag = 'off';
            end
            gui_erp_simulation.erpsetedit.Enable = EnableFlag;
            gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
            gui_erp_simulation.channeledit.Enable = EnableFlag;
            gui_erp_simulation.channelpopup.Enable = EnableFlag;
            gui_erp_simulation.binedit.Enable = EnableFlag;
            gui_erp_simulation.binpopup.Enable = EnableFlag;
            if gui_erp_simulation.realerp_check.Value==1
                EnableFlags = 'off';
            else
                EnableFlags = 'on';
            end
            gui_erp_simulation.epoch_start.Enable = EnableFlags;
            gui_erp_simulation.epoch_stop.Enable = EnableFlags;
            gui_erp_simulation.srateedit.Enable = EnableFlags;
            gui_erp_simulation.srateperiodedit.Enable = EnableFlags;
            gui_erp_simulation.srate.Enable = EnableFlags;
            gui_erp_simulation.srateperiod.Enable = EnableFlags;
            if strcmpi(EnableFlags,'on')
                if gui_erp_simulation.srate.Value ==1
                    gui_erp_simulation.srateedit.Enable = 'on';
                    gui_erp_simulation.srateperiod.Value =0;
                    gui_erp_simulation.srateperiodedit.Enable = 'off';
                else
                    gui_erp_simulation.srate.Value=0;
                    gui_erp_simulation.srateedit.Enable = 'off';
                    gui_erp_simulation.srateperiod.Value =1;
                    gui_erp_simulation.srateperiodedit.Enable = 'on';
                end
            end
            gui_erp_simulation.Paras{1}=gui_erp_simulation.realerp_check.Value;
            gui_erp_simulation.Paras{2} = str2num(gui_erp_simulation.erpsetedit.String);
            gui_erp_simulation.Paras{3} = str2num(gui_erp_simulation.channeledit.String);
            gui_erp_simulation.Paras{4} = str2num(gui_erp_simulation.binedit.String);
            gui_erp_simulation.Paras{5} = str2num(gui_erp_simulation.epoch_start.String);
            gui_erp_simulation.Paras{6} = str2num(gui_erp_simulation.epoch_stop.String);
            gui_erp_simulation.Paras{7} = gui_erp_simulation.srate.Value;
            gui_erp_simulation.Paras{8} = str2num(gui_erp_simulation.srateedit.String);
            gui_erp_simulation.Paras{9} = gui_erp_simulation.exgua_op.Value;
            gui_erp_simulation.Paras{10} = str2num(gui_erp_simulation.exgua_peakamp.String);
            gui_erp_simulation.Paras{11} = str2num(gui_erp_simulation.exgua_mean.String);
            gui_erp_simulation.Paras{12} = str2num(gui_erp_simulation.exgua_sd.String);
            gui_erp_simulation.Paras{13} = str2num(gui_erp_simulation.exgua_tau.String);
            gui_erp_simulation.Paras{14} = gui_erp_simulation.impulse_op.Value;
            gui_erp_simulation.Paras{15} = str2num(gui_erp_simulation.impulse_peakamp.String);
            gui_erp_simulation.Paras{16} = str2num(gui_erp_simulation.impulse_latency.String);
            gui_erp_simulation.Paras{17} =gui_erp_simulation.square_op.Value;
            gui_erp_simulation.Paras{18} =str2num(gui_erp_simulation.square_peakamp.String);
            gui_erp_simulation.Paras{19} =str2num(gui_erp_simulation.square_onset.String);
            gui_erp_simulation.Paras{20} =str2num(gui_erp_simulation.square_offset.String);
            gui_erp_simulation.Paras{21} = gui_erp_simulation.sin_op.Value;
            gui_erp_simulation.Paras{22} = str2num(gui_erp_simulation.sin_amp.String);
            gui_erp_simulation.Paras{23} = str2num(gui_erp_simulation.sin_fre.String);
            gui_erp_simulation.Paras{24} = gui_erp_simulation.white_op.Value;
            gui_erp_simulation.Paras{25} = str2num(gui_erp_simulation.white_amp.String);
            gui_erp_simulation.Paras{26} = gui_erp_simulation.pink_op.Value;
            gui_erp_simulation.Paras{27} = str2num(gui_erp_simulation.pink_amp.String);
        end
        plot_erp_simulation();
        observe_ERPDAT.Count_currentERP=19;
    end

%%-------execute "apply" before doing any change for other panels----------
%     function erp_two_panels_change(~,~)
%         if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('ERPTab_stimulation');
%         if ChangeFlag~=1
%             return;
%         end
%         simulation_apply();
%         gui_erp_simulation.apply.BackgroundColor =  [ 1 1 1];
%         gui_erp_simulation.apply.ForegroundColor = [0 0 0];
%         ERP_simulation_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
%         gui_erp_simulation.simulation_cancel.BackgroundColor =  [1 1 1];
%         gui_erp_simulation.simulation_cancel.ForegroundColor = [0 0 0];
%         estudioworkingmemory('ERPTab_stimulation',0);
%     end

%%--------------press return to execute "Apply"----------------------------
    function erp_simuls_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_stimulation');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            simulation_apply();
            gui_erp_simulation.apply.BackgroundColor =  [ 1 1 1];
            gui_erp_simulation.apply.ForegroundColor = [0 0 0];
            ERP_simulation_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_simulation.simulation_cancel.BackgroundColor =  [1 1 1];
            gui_erp_simulation.simulation_cancel.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_stimulation',0);
        else
            return;
        end
    end

%%--------------reset this panel with the default parameters---------------
    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=16
            return;
        end
        gui_erp_simulation.apply.BackgroundColor =  [ 1 1 1];
        gui_erp_simulation.apply.ForegroundColor = [0 0 0];
        ERP_simulation_box.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_simulation.simulation_cancel.BackgroundColor =  [1 1 1];
        gui_erp_simulation.simulation_cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_stimulation',0);
        gui_erp_simulation.realerp_check.Value=0;
        EnableFlag = 'off';
        gui_erp_simulation.erpsetedit.Enable = EnableFlag;
        gui_erp_simulation.erpsetedit.String = '';
        gui_erp_simulation.erpsetpopup.Enable = EnableFlag;
        gui_erp_simulation.channeledit.Enable = EnableFlag;
        gui_erp_simulation.channeledit.String = '';
        gui_erp_simulation.channelpopup.Enable = EnableFlag;
        gui_erp_simulation.binedit.Enable = EnableFlag;
        gui_erp_simulation.binedit.String = '';
        gui_erp_simulation.binpopup.Enable = EnableFlag;
        EnableFlagn = 'on';
        gui_erp_simulation.epoch_start.Enable = EnableFlagn;
        gui_erp_simulation.epoch_start.String = '-200';
        gui_erp_simulation.epoch_stop.Enable = EnableFlagn;
        gui_erp_simulation.epoch_stop.String = '799';
        gui_erp_simulation.srate.Enable = EnableFlagn;
        gui_erp_simulation.srate.Value=1;
        gui_erp_simulation.srateedit.Enable = EnableFlagn;
        gui_erp_simulation.srateedit.String = '1000';
        gui_erp_simulation.srateperiod.Enable = EnableFlagn;
        gui_erp_simulation.srateperiod.Value=0;
        gui_erp_simulation.srateperiodedit.Enable = EnableFlagn;
        gui_erp_simulation.srateperiodedit.String = '1';
        %%ex-Gaussian
        gui_erp_simulation.exgua_op.Value =1;
        gui_erp_simulation.exgua_peakamp.Enable = 'on';
        gui_erp_simulation.exgua_peakamp.String = '1';
        gui_erp_simulation.exgua_mean.Enable = 'on';
        gui_erp_simulation.exgua_mean.String = '100';
        gui_erp_simulation.exgua_sd.Enable = 'on';
        gui_erp_simulation.exgua_sd.String = '50';
        gui_erp_simulation.exgua_tau.Enable = 'on';
        gui_erp_simulation.exgua_tau.String = '0';
        gui_erp_simulation.impulse_op.Value = 0;
        gui_erp_simulation.impulse_peakamp.Enable = 'off';
        gui_erp_simulation.impulse_latency.Enable = 'off';
        gui_erp_simulation.square_op.Value = 0;
        gui_erp_simulation.square_onset.Enable = 'off';
        gui_erp_simulation.square_offset.Enable = 'off';
        gui_erp_simulation.square_peakamp.Enable = 'off';
        %%sin noise
        gui_erp_simulation.sin_op.Value=0;
        gui_erp_simulation.sin_amp.Enable = 'off';
        gui_erp_simulation.sin_fre.Enable = 'off';
        %%white noise
        gui_erp_simulation.white_op.Value=0;
        gui_erp_simulation.white_amp.Enable ='off';
        %%pink noise
        gui_erp_simulation.pink_op.Value=0;
        gui_erp_simulation.pink_amp.Enable = 'off';
        plot_erp_simulation();
        observe_ERPDAT.Reset_erp_paras_panel=17;
    end
end
%Progem end: ERP simulation