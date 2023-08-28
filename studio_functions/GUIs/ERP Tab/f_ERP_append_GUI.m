%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_append_GUI(varargin)
global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@allErpChanged);
% addlistener(observe_ERPDAT,'ERP_change',@onErpChanged);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
% addlistener(observe_ERPDAT,'Process_messg_change',@Process_messg_change);

gui_erp_append = struct();

%-----------------------------Name the title----------------------------------------------
% global box_erp_history;

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_erp_history = uiextras.BoxPanel('Parent', fig, 'Title', 'Append ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erp_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Append ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_erp_history = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Append ERPsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
drawui_erp_append(FonsizeDefault);
varargout{1} = box_erp_history;

    function drawui_erp_append(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %%--------------------channel and bin setting----------------------
        gui_erp_append.DataSelBox = uiextras.VBox('Parent', box_erp_history,'BackgroundColor',ColorB_def);
        
        gui_erp_append.erpappend_select_title = uiextras.HBox('Parent', gui_erp_append.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent', gui_erp_append.erpappend_select_title);
        
        gui_erp_append.sameerpset = uicontrol('Style','radiobutton','Parent', gui_erp_append.erpappend_select_title,'String','Same as ERPset Panel',...
            'callback',@same_to_erpset,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',1); % 2F
        
        gui_erp_append.erpset_custom = uicontrol('Style','radiobutton','Parent',gui_erp_append.erpappend_select_title,'String','Custom',...
            'callback',@erpsetcutom,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Value',0);
        set(gui_erp_append.erpappend_select_title, 'Sizes',[50 145 70]);
        
        gui_erp_append.erp_append_title = uiextras.HBox('Parent', gui_erp_append.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_append.erp_h_all = uicontrol('Style','text','Parent',gui_erp_append.erp_append_title,'String','ERPsets',...
            'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'HorizontalAlignment','left'); % 2F
        gui_erp_append.erpset_edit = uicontrol('Style','edit','Parent', gui_erp_append.erp_append_title,'String',' ',...
            'callback',@erpset_edit,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'Enable','off'); % 2F
        set(gui_erp_append.erp_append_title, 'Sizes',[65 200]);
        
        
        gui_erp_append.advance_help_title = uiextras.HBox('Parent',gui_erp_append.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        %         uiextras.Empty('Parent', gui_erp_append.advance_help_title);
        uicontrol('Style', 'pushbutton','Parent',gui_erp_append.advance_help_title,'String','?','callback',@erpset_append_help,'Enable','on','FontSize',16);
        %         uiextras.Empty('Parent', gui_erp_append.advance_help_title);
        gui_erp_append.append_advance = uicontrol('Style', 'pushbutton','Parent',gui_erp_append.advance_help_title,...
            'String','Advanced','callback',@advance_erpappend,'FontSize',FonsizeDefault);
        gui_erp_append.append_run = uicontrol('Style', 'pushbutton','Parent',gui_erp_append.advance_help_title,'String','Run',...
            'callback',@append_run,'FontSize',FonsizeDefault);
        
        set(gui_erp_append.DataSelBox,'Sizes',[30 25 30]);
        
        if  strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        gui_erp_append.erpset_edit.Enable = Enableflag;
        gui_erp_append.erpset_option.Enable = Enableflag;
        gui_erp_append.append_advance.Enable = Enableflag;
        gui_erp_append.append_run.Enable = Enableflag;
        gui_erp_append.sameerpset.Enable = Enableflag;
        gui_erp_append.erpset_custom.Enable = Enableflag;
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------same_to_erpset----------------------------------
    function same_to_erpset(~,~)
        gui_erp_append.sameerpset.Value=1;
        gui_erp_append.erpset_custom.Value=0;
        gui_erp_append.erpset_edit.Enable = 'off';
        ERPArray = estudioworkingmemory('selectederpstudio');
        gui_erp_append.erpset_edit.String = num2str(ERPArray);
    end


%%-----------------erpsetcutom---------------------------------------------
    function erpsetcutom(~,~)
        gui_erp_append.sameerpset.Value=0;
        gui_erp_append.erpset_custom.Value=1;
        gui_erp_append.erpset_edit.Enable = 'on';
    end


%%-------------------------Append help------------------------------------
    function erpset_append_help(~,~)
        web('https://github.com/lucklab/erplab/wiki/Appending-ERPSETS','-browser');
    end


%%-------------------edit the ERPset to append-----------------------------
    function erpset_edit(Source,~)
        ERPArray = str2num(Source.String);
        if isempty(ERPArray) || numel(ERPArray)==1
            messgStr = strcat('Append ERPsets > You have to specify 2 ERPsets, at least.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if min(ERPArray) <=0
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than 0.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        
        if max(ERPArray) > length(observe_ERPDAT.ALLERP)
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than',32,num2str(length(observe_ERPDAT.ALLERP)),'.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
    end


%%-----------------Advance setting for ERPset append-----------------------
    function advance_erpappend(~,~)
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Append ERPsets');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        
        ERPArray = str2num(gui_erp_append.erpset_edit.String);
        if isempty(ERPArray) || numel(ERPArray)==1
            messgStr = strcat('Append ERPsets > You have to specify 2 ERPsets, at least.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if min(ERPArray) <=0
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than 0.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if max(ERPArray) > length(observe_ERPDAT.ALLERP)
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than',32,num2str(length(observe_ERPDAT.ALLERP)),'.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            beep;
            observe_ERPDAT.Process_messg=4;
            return;
        end
        %%check number of samples/channels, and data type
        messgStr  = check_ERPset(ERPArray);
        if ~isempty(messgStr)
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            beep;
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return
        end
        
        
        try
            ALLERP=  observe_ERPDAT.ALLERP;
            nloadedset = length(observe_ERPDAT.ALLERP);
            def  = estudioworkingmemory('pop_appenderp');
            if isempty(def)
                if isempty(observe_ERPDAT.ALLERP)
                    inp1   = 1; %from hard drive
                    erpset = [];
                    erpoption = 1;
                else
                    inp1   = 0; %from erpset menu
                    erpset = 1:length(ALLERP);
                    erpoption = 1;%% 1. same as ERPset panel; 2 custom define
                end
                isprefix   = 0;
                prefixlist = '';
                def = {inp1 erpoption, erpset prefixlist};
                %def = { erpset  prefixlist};
            else
                if ~isempty(ALLERP)
                    if isnumeric(def{2}) % JavierLC 11-17-11
                        [uu, mm] = unique_bc2(def{3}, 'first');
                        def{3}  = [def{3}(sort(mm))];
                    end
                end
            end
            
            ERPsetArraydef = str2num(gui_erp_append.erpset_edit.String);
            if isempty(ERPsetArraydef) || max(ERPsetArraydef)> length(observe_ERPDAT.ALLERP)
                ERPsetArraydef = observe_ERPDAT.CURRENTERP;
            end
            def{1} = 0;
            def{3} = ERPsetArraydef;
            def{2} = gui_erp_append.sameerpset.Value;
            ERPArrayERPpanel = estudioworkingmemory('selectederpstudio');
            def{5} = ERPArrayERPpanel;
            
            %
            % Call GUI
            %
            answer = f_appenderpGUI(nloadedset, def);
            if isempty(answer)
                disp('User selected Cancel')
                return
            end
            optioni    = answer{1}; %1 means from hard drive, 0 means from erpsets menu
            ERPsetop = answer{2};
            erpset     = answer{3};
            prefixlist = answer{4};
            
            
            estudioworkingmemory('pop_appenderp',answer);
            
            if optioni==1 % from files
                filelist = erpset;
                ALLERP   = {ALLERP, filelist}; % truco
            else % from erpsets menu
                %erpset  = erpset;
            end
            if isempty(prefixlist)
                prefixliststr   = ''; % do not include prefix
            elseif isnumeric(prefixlist)
                prefixliststr = 'erpname'; % use erpname instead
            else
                prefixliststr   = prefixlist; % include prefix from list
            end
            erpworkingmemory('pop_appenderp', { optioni, erpset, prefixlist });
            
            ALLERPCOM = evalin('base','ALLERPCOM');
            
            if optioni==0
                messgStr  = check_ERPset(erpset);
                if ~isempty(messgStr)
                    erpworkingmemory('f_ERP_proces_messg',messgStr);
                    beep;
                    fprintf(2,['\n Warning: ',messgStr,'.\n']);
                    observe_ERPDAT.Process_messg=4;
                    return
                end
                %%check prefixes
                
                if ~isempty(prefixliststr) && numel(erpset) ~= length(prefixliststr)
                    messgStr = strcat('Append ERPsets > prefixes must to be as large as ERPset indx');
                    erpworkingmemory('f_ERP_proces_messg',messgStr);
                    beep;
                    fprintf(2,['\n Warning: ',messgStr,'.\n']);
                    observe_ERPDAT.Process_messg=4;
                    return
                end
            end
            %
            % Somersault
            %
            if optioni==1 && ~isempty(erpset)
                if isempty(prefixliststr)
                    [ERP,ERPCOM] = pop_appenderp( erpset, 'Saveas', 'off', 'History', 'gui');
                else
                    fid_list = fopen( erpset );
                    formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                    lista    = formcell{:};
                    
                    if  numel(lista) ~= length(prefixliststr)
                        messgStr = strcat('Append ERPsets > prefixes must to be as large as ERPset indx');
                        erpworkingmemory('f_ERP_proces_messg',messgStr);
                        beep;
                        fprintf(2,['\n Warning: ',messgStr,'.\n']);
                        observe_ERPDAT.Process_messg=4;
                        return
                    end
                    
                    [ERP, ERPCOM] = pop_appenderp(erpset, 'Prefixes', prefixliststr, 'Saveas', 'off', 'History', 'gui');
                end
            else
                
                if isempty(prefixliststr)
                    [ERP, ERPCOM] = pop_appenderp(ALLERP, 'Erpsets', erpset, 'Saveas', 'off', 'History', 'gui');
                else
                    [ERP, ERPCOM] = pop_appenderp(ALLERP, 'Erpsets', erpset, 'Prefixes', prefixliststr, 'Saveas', 'off', 'History', 'gui');
                end
            end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);%%SAVE the command
            pathName_def =  erpworkingmemory('ERP_save_folder');
            if isempty(pathName_def)
                pathName_def =cd;
            end
            erpName_new = '';
            fileName_new = '';
            pathName_new = '';
            Save_file_label =0;
            
            Answer = f_ERP_save_single_file(strcat('append'),'',length(observe_ERPDAT.ALLERP)+1);
            if isempty(Answer)
                %                 erpName_new = strcat(num2str(length(observe_ERPDAT.ALLERP)+1),'append');
                %                 Save_file_label =0;
                disp('User selected Cancel.');
                return;
            end
            
            if ~isempty(Answer)
                ERPName = Answer{1};
                if ~isempty(ERPName)
                    erpName_new = ERPName;
                end
                fileName_full = Answer{2};
                if isempty(fileName_full)
                    fileName_new = '';
                    Save_file_label =0;
                elseif ~isempty(fileName_full)
                    
                    [pathstr, file_name, ext] = fileparts(fileName_full);
                    ext = '.erp';
                    if strcmp(pathstr,'')
                        pathstr = pathName_def;
                    end
                    fileName_new = [file_name,ext];
                    pathName_new = pathstr;
                    Save_file_label =1;
                end
            end
            
            ERP.erpname = erpName_new;
            ERP.filename = fileName_new;
            ERP.filepath = pathName_new;
            if Save_file_label==1
                ERP_save =ERP;
                ERP_save.filepath = pathName_new;
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP_save, 'erpname', ERP_save.erpname, 'filename', ERP_save.erpname, 'filepath',ERP_save.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            assignin('base','ERP',observe_ERPDAT.ERP);
            assignin('base','CURRENTERP',observe_ERPDAT.CURRENTERP);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Process_messg =2;
            estudioworkingmemory('selectederpstudio',observe_ERPDAT.CURRENTERP);
            OpValue = answer{2};
            gui_erp_append.sameerpset.Value = OpValue;
            gui_erp_append.erpset_custom.Value = ~OpValue;
            gui_erp_append.erpset_edit.String = num2str(answer{3});
            
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        catch
            observe_ERPDAT.Process_messg =3;
            return;
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end



%%--------------------------Run--------------------------------------------
    function append_run(~,~)
        
        %%Send message to Message panel
        erpworkingmemory('f_ERP_proces_messg','Append ERPsets');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        %%-------check the inputed ERPsetArray-----------------------------
        ERPArray = str2num(gui_erp_append.erpset_edit.String);
        if isempty(ERPArray) || numel(ERPArray)==1
            messgStr = strcat('Append ERPsets > You have to specify 2 ERPsets, at least.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if min(ERPArray) <=0
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than 0.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return;
        end
        if max(ERPArray) > length(observe_ERPDAT.ALLERP)
            messgStr = strcat('Append ERPsets > Index of inputs should not be larger than',32,num2str(length(observe_ERPDAT.ALLERP)),'.');
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            beep;
            observe_ERPDAT.Process_messg=4;
            return;
        end
        %%check number of samples/channels, and data type
        messgStr  = check_ERPset(ERPArray);
        if ~isempty(messgStr)
            erpworkingmemory('f_ERP_proces_messg',messgStr);
            beep;
            fprintf(2,['\n Warning: ',messgStr,'.\n']);
            observe_ERPDAT.Process_messg=4;
            return
        end
        ALLERPCOM = evalin('base','ALLERPCOM');
        ALLERP = observe_ERPDAT.ALLERP;
        prefixliststr = '';
        for Numoferpset = 1:numel(ERPArray)
            prefixliststr{Numoferpset}  = ALLERP(ERPArray(Numoferpset)).erpname;
            
        end
        
        try
            [ERP, ERPCOM] = pop_appenderp(ALLERP, 'Erpsets', ERPArray, 'Prefixes', prefixliststr, 'Saveas', 'off', 'History', 'gui');
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);%%SAVE the command
            pathName_def =  erpworkingmemory('ERP_save_folder');
            if isempty(pathName_def)
                pathName_def =cd;
            end
            erpName_new = '';
            fileName_new = '';
            pathName_new = '';
            Save_file_label =0;
            Answer = f_ERP_save_single_file(strcat('append'),'',length(observe_ERPDAT.ALLERP)+1);
            if isempty(Answer)
                disp('User selected Cancel.');
                return;
                %                 erpName_new = strcat(num2str(length(observe_ERPDAT.ALLERP)+1),'append');
                %                 Save_file_label =0;
            end
            if ~isempty(Answer)
                ERPName = Answer{1};
                if ~isempty(ERPName)
                    erpName_new = ERPName;
                end
                fileName_full = Answer{2};
                if isempty(fileName_full)
                    fileName_new = '';
                    Save_file_label =0;
                elseif ~isempty(fileName_full)
                    [pathstr, file_name, ext] = fileparts(fileName_full);
                    ext = '.erp';
                    if strcmp(pathstr,'')
                        pathstr = pathName_def;
                    end
                    fileName_new = [file_name,ext];
                    pathName_new = pathstr;
                    Save_file_label =1;
                end
            end
            ERP.erpname = erpName_new;
            ERP.filename = fileName_new;
            ERP.filepath = pathName_new;
            if Save_file_label==1
                ERP_save =ERP;
                ERP_save.filepath = pathName_new;
                [ERP, issave, ERPCOM] = pop_savemyerp(ERP_save, 'erpname', ERP_save.erpname, 'filename', ERP_save.erpname, 'filepath',ERP_save.filepath);
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Process_messg =2;
            estudioworkingmemory('selectederpstudio',observe_ERPDAT.CURRENTERP);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        catch
            observe_ERPDAT.Process_messg =3;
            return;
        end%% end try
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if  strcmp(observe_ERPDAT.ERP.erpname,'No ERPset loaded')
            Enableflag = 'off';
        else
            Enableflag = 'on';
        end
        gui_erp_append.erpset_edit.Enable = Enableflag;
        gui_erp_append.erpset_option.Enable = Enableflag;
        gui_erp_append.append_advance.Enable = Enableflag;
        gui_erp_append.append_run.Enable = Enableflag;
        gui_erp_append.sameerpset.Enable = Enableflag;
        gui_erp_append.erpset_custom.Enable = Enableflag;
        if gui_erp_append.sameerpset.Value ==1%%same to the
            %%selected erpsert as the "ERPset" panel.
            ERPArray = estudioworkingmemory('selectederpstudio');
            gui_erp_append.erpset_edit.String = num2str(ERPArray);
            gui_erp_append.erpset_edit.Enable = 'off';
        else
            gui_erp_append.erpset_edit.Enable = 'on';
        end
    end


%%-------------Check number of bin/channel, and data type------------------
    function msgboxText = check_ERPset(ERPArray)
        msgboxText = '';
        nfile = numel(ERPArray);
        if nfile >1
            numpoints = zeros(1,nfile);
            numchans  = zeros(1,nfile);
            chckdatatype = cell(1);
            ALLERP=   observe_ERPDAT.ALLERP;
            for j=1:nfile
                numpoints(j)    = ALLERP(ERPArray(j)).pnts;
                numchans(j)     = ALLERP(ERPArray(j)).nchan;
                chckdatatype{j} = ALLERP(ERPArray(j)).datatype;
                clear ERP1
            end
            if length(unique(numpoints))>1
                msgboxText = 'Append ERPsets > The selected ERPsets have different number of points';
            end
            
            if length(unique(numchans))>1
                msgboxText = 'Append ERPsets > The selected ERPsets have different number of channel';
            end
            if length(unique(chckdatatype))>1
                msgboxText = 'Append ERPsets > The selected ERPsets have different data type';
            end
        end
    end

end