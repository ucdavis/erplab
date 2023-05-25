% PURPOSE: Finding the users defined path to save the file


% [S S_out]= f_erpset_geterpvalues(varargin)





%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio


function S_out= f_erpset_geterpvalues(varargin);

if nargin<1
    help f_erpset_geterpvalues
    return
end
S_out = {};

if isempty(varargin)
    CurrentERPSet = evalin('base','CURRENTERP');
    Current_ERP= evalin('base','ERP');
    %Adding chanArray
    erpset = num2str(CurrentERPSet);
    if   ~exist('S','var')
        S_in = {};
        erpvalues_variables = {'geterpvalues','latency','',...
            'binArray',[1:Current_ERP.nbin],...
            'chanArray', [1:Current_ERP.nchan],...
            'Erpsets', erpset,...
            'Measure','meanb1',...
            'Component',0,...
            'Resolution', [3],...
            'Baseline', 'pre',...
            'Binlabel', 'on',...
            'Peakpolarity','positive',...
            'Neighborhood', 5,...
            'Peakreplace', 'absolute',...
            'Filename', '',...
            'Warning','on',...
            'SendtoWorkspace', 'on',...
            'Append', '',...
            'FileFormat', 'wide',...
            'Afraction',0.5,...
            'Mlabel', '',...
            'Fracreplace', 'errormsg',...
            'IncludeLat', '',...
            'InterpFactor', 1,...
            'Viewer', 'off',...
            'PeakOnset',1,...
            'History', ''};
        S_OUT = createrplabstudioparameters(S_in,erpvalues_variables);
        assignin('base','S',S_OUT);
        S_out = S_OUT.geterpvalues;
    else %%If the S exists in the MATLAB workspace
        
        S_IN = evalin('base','S');
        count_geterpvalues = f_findstring(S_IN,'geterpvalues');
        
        if count_geterpvalues ==1
            S_out = S_IN.geterpvalues;
        else
            
            erpvalues_variables = {'geterpvalues','latency','',...
                'binArray',[1:Current_ERP.nbin],...
                'chanArray', [1:Current_ERP.nchan],...
                'Erpsets', erpset,...
                'Measure','meanb1',...
                'Component',0,...
                'Resolution', [3],...
                'Baseline', 'pre',...
                'Binlabel', 'on',...
                'Peakpolarity','positive',...
                'Neighborhood', 5,...
                'Peakreplace', 'absolute',...
                'Filename', '',...
                'Warning','on',...
                'SendtoWorkspace', 'on',...
                'Append', '',...
                'FileFormat', 'wide',...
                'Afraction',0.5,...
                'Mlabel', '',...
                'Fracreplace', 'errormsg',...
                'IncludeLat', '',...
                'InterpFactor', 1,...
                'Viewer', 'off',...
                'PeakOnset',1,...
                'History', '',...
                'ERPselect',1};
            S_OUT = createrplabstudioparameters(S_IN,erpvalues_variables);
            assignin('base','S',S_OUT);
            S_out = S_OUT.geterpvalues;
        end
        
    end
end

if ~isempty(varargin)
    S_out = varargin{1};
end

f_erpset_selection = figure( 'Name', 'ERP Measurement Tool', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off');
f_erpset_selection.Position(3:4) = [300 150];

Current_ERPset =  evalin('base','CURRENTERP');
ALLERP =  evalin('base','ALLERP');
ERP_selection_label = [1 0 0];

erpset_selection_gui()


    function  erpset_selection_gui()
        b1 = uiextras.VBox( 'Parent', f_erpset_selection);
        
        b11 = uiextras.HBox( 'Parent', b1 );
        
        b111 = uicontrol('Style','text','Parent', b11,'String','ERPset setting','fontsize',12);%,'FontWeight', 'bold');
        
        %%-------------------------------------------------------------------
        b12 = uiextras.HBox( 'Parent', b1 );
        
        
        %%--------------------------Current ERPset------------------------------
        b112= uicontrol('Style','radiobutton','Parent',b12,'String',['Current ERPSet:',32,'[',num2str(Current_ERPset),']',32,ALLERP(Current_ERPset).erpname],'callback',@currenterpset_toggle); % 1B
        uiextras.Empty('Parent',b12);
        
        set(b12,'Sizes',[250 50]);
        b_nonzero = find(ERP_selection_label);
        
        if ~isempty(b_nonzero)
            if ~ERP_selection_label(1)
                %                 set(b112,'enable','off', 'ForegroundColor', [.5 0.5 0.5]);
            else
                set(b112,'value',ERP_selection_label(1) ,'enable','on');
            end
        end
        %%------------------From Checked ERPsets-----------------------------------
        b14 = uiextras.HBox( 'Parent', b1);
        
        b141 = uicontrol('Style','radiobutton','Parent', b14,'String','Checked ERPsets','callback',@erpset_checked);%,'HandleVisibility','off'
        
        b142 = uicontrol('Style','pushbutton','Parent', b14,'String','Options');
        if ~isempty(b_nonzero)
            if ~ERP_selection_label(2)
                %                 set(b141,'enable','off', 'ForegroundColor', [.5 0.5 0.5]);
                set(b142,'enable','off', 'ForegroundColor', [.5 0.5 0.5]);
            else
                set(b141,'enable','on','value',ERP_selection_label(2) );
            end
        end
        %%----------------------------ERPsets menu---------------------------------
        b15 = uiextras.HBox( 'Parent', b1);
        
        b151 = uicontrol('Style','radiobutton','Parent', b15,'String','From ERPset menu','callback',@erpset_menu);
        
        b152 = uicontrol('Style','pushbutton','Parent', b15,'String','Options','callback',@erpset_menu_select);
        
        if ~isempty(b_nonzero)
            if ~ERP_selection_label(3)
                %                 set(b151,'enable','off', 'ForegroundColor', [.5 0.5 0.5]);
                set(b152,'enable','off', 'ForegroundColor', [.5 0.5 0.5]);
            else
                set(b151,'value',ERP_selection_label(3) ,'enable','on');
            end
        end
        %%------------------------Cancel and Run----------------------------------
        b16 = uiextras.HBox( 'Parent', b1);
        uicontrol( 'Parent', b16, 'String', 'Cancel','callback',@Local_cancel);
        uicontrol( 'Parent', b16, 'String', 'Run','callback',@Local_run);
    end


%%***********************************************************************
%%******************   subfunctions   ***********************************
%%***********************************************************************

%%------------------------Current ERPset-----------------------------------
    function currenterpset_toggle(source_current_erp,~)
        value_currenterp = source_current_erp.Value;
        if value_currenterp ==1
            ERP_selection_label(1) = value_currenterp;
            ERP_selection_label(2:end) =0;
        elseif value_currenterp == 0
            ERP_selection_label(1:end) =0;
        end
        erpset_selection_gui();
        S_out.Erpsets = Current_ERPset;
    end


%%------------------------Checked ERPset-----------------------------------
    function erpset_checked(Source_checked_ERP,~)
        
        value_checkederp = Source_checked_ERP.Value;
        
        if value_checkederp ==1
            ERP_selection_label(2) = value_checkederp;
            ERP_selection_label([1 3]) =0;
        elseif value_checkederp == 0
            ERP_selection_label(1:end) =0;
        end
        erpset_selection_gui();
        
    end

%%-----------------------ERPsets from menu---------------------------------
    function erpset_menu(Source_erp_menu,~)
        value_currenterp = Source_erp_menu.Value;
        if value_currenterp ==1
            ERP_selection_label(3) = value_currenterp;
            ERP_selection_label([1 2]) =0;
            S_out.Erpsets = [1:length(ALLERP)];
        elseif value_currenterp == 0
            ERP_selection_label(1:end) =0;
        end
        erpset_selection_gui();
    end

%%------------Select the ERPsets of interest from menu---------------------
    function erpset_menu_select(~,~)
        
        if ~isempty(ALLERP)
            for Numoferpset = 1:length(ALLERP)
                listb{Numoferpset}= ['Erpset',32,num2str(Numoferpset),':',32,ALLERP(Numoferpset).erpname];
            end
            indxlistb = 1:length(ALLERP);
            titlename = 'Select ERPset(s):';
            
            chan_label_select = browsechanbinGUI(listb, indxlistb, titlename);
            
            if ~isempty(chan_label_select)
                S_out.Erpsets = chan_label_select;
                
                if length(chan_label_select) ==1
                    disp(['ERPset(s):',num2str(chan_label_select),32,'will be used for next analysis'])
                else
                    disp(['ERPset(s):',num2str(chan_label_select(1:end-1)),32,'and',32,num2str(chan_label_select(end)),32,'will be used for next analysis'])
                end
            else
                beep;
                disp('User selected Cancel')
                return
            end
            
        else
            msgboxText =  'No ERPset information was found';
            title = 'EStudio: ERP measurement tool input';
            errorfound(msgboxText, title);
            return;
        end
    end

%%-------------------Cancel----------------------------------------------
    function Local_cancel(Source_localp_cancel,~)
        Values_localp_cancel = Source_localp_cancel.Value;
        if ~isempty(Values_localp_cancel)
            beep;
            disp('User selected Cancel');
            close(f_erpset_selection);
            S.geterpvalues = S_out;
            %             varargout{1} = S_out;
            return;
        end
    end
%%-----------------------Run-----------------------------------------------
    function Local_run(Source_localp_run,~)
        Values_localp_run = Source_localp_run.Value;
        if ~isempty(Values_localp_run)
            
            S= evalin('base','S');
            S.geterpvalues = S_out;
            assignin('base','S',S);
            close(f_erpset_selection);
            %             return;
        end
    end
%%%Program end
end
