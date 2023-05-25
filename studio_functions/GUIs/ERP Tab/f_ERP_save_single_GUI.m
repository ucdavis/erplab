%%This function is GUI that is used to save single ERP







function ERP_OUT = f_ERP_save_single_GUI(ERP_In)


global observe_ERPDAT;

try
    % %     ERP_In = evalin('base','ERP');
    ERP_In = ERP_In;
    %     %     Suffix = varargin{2};
catch
    ERP_In = evalin('base','ERP');
end


% varargout = {};
f_ERP_save_single = figure( 'Name', 'Save ERPset GUI for single file', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Toolbar', 'none', ...
    'HandleVisibility', 'off');
f_ERP_save_single.Position(3:4) = [600 200];

% global gui_erp_save_single;
ERP_OUT = [];
% varargout{1} = f_ERP_save_single;

erp_blc_dt_adv_gui(ERP_In);
% varargout{1} = ERP_basecorr_detrend_box;
%%********************Draw the GUI for ERP measurement tool*****************
    function erp_blc_dt_adv_gui(ERP_In)
        gui_erp_save_single.erp_file_name = uiextras.VBox('Parent',f_ERP_save_single,'Spacing',1);
        
        gui_erp_save_single.erpname_title = uiextras.HBox('Parent',gui_erp_save_single.erp_file_name,'Spacing',1);
        uicontrol('Style', 'text','Parent', gui_erp_save_single.erpname_title,...
            'String',['Your active erpset is #', num2str(observe_ERPDAT.CURRENTERP)],'fontsize',16);
        
        
        gui_erp_save_single.erpname_sec = uiextras.Grid('Parent',gui_erp_save_single.erp_file_name,'Spacing',1);
        gui_erp_save_single.erpname_save = uicontrol('Style', 'radiobutton','Parent', gui_erp_save_single.erpname_sec,...
            'String','ERPname','callback',@erpname_radio,'Value',1);
        %         uiextras.Empty('Parent',  gui_erp_save_single.erpname_sec);
        gui_erp_save_single.erpname_str = uicontrol('Style', 'edit','Parent', gui_erp_save_single.erpname_sec,...
            'String',ERP_In.erpname,'callback',@erpname_str);
        
        gui_erp_save_single.erpname_filename = uicontrol('Style', 'pushbutton','Parent', gui_erp_save_single.erpname_sec,...
            'String','save as filename','callback',@erpname_filename,'Enable','off');
        
        set(gui_erp_save_single.erpname_sec, 'ColumnSizes',[80 400 115],'RowSizes',[40]);
        
        
        
        
        %%Save as
        gui_erp_save_single.filename_sec = uiextras.Grid('Parent',gui_erp_save_single.erp_file_name,'Spacing',1);
        gui_erp_save_single.filename_save = uicontrol('Style', 'radiobutton','Parent', gui_erp_save_single.filename_sec,...
            'String','Save ERP as','callback',@filename_radio,'Value',0);
        gui_erp_save_single.filename_str = uicontrol('Style', 'edit','Parent', gui_erp_save_single.filename_sec,...
            'String','','Enable','off');
        
        gui_erp_save_single.filename_browse = uicontrol('Style', 'pushbutton','Parent', gui_erp_save_single.filename_sec,...
            'String','Browse','callback',@filename_browse,'Enable','off');
        
        set(gui_erp_save_single.filename_sec, 'ColumnSizes',[100 410 85],'RowSizes',[40]);
        
        
        %%Cancel and Run
        
        gui_erp_save_single.other_option = uiextras.HBox('Parent',gui_erp_save_single.erp_file_name,'Spacing',1);
        uiextras.Empty('Parent', gui_erp_save_single.other_option);
        gui_erp_save_single.cancel = uicontrol('Style','pushbutton','Parent',gui_erp_save_single.other_option,...
            'String','Cancel','callback',@cancel_blc_dt);
        uiextras.Empty('Parent', gui_erp_save_single.other_option);
        gui_erp_save_single.run = uicontrol('Parent',gui_erp_save_single.other_option,'Style','pushbutton',...
            'String','Ok','callback',@run_blc_dt);
        uiextras.Empty('Parent', gui_erp_save_single.other_option);
        set(gui_erp_save_single.other_option,'Sizes',[80 170 100 170 80]);
        
        set(gui_erp_save_single.erp_file_name,'Sizes',[30 60 60 40]);
    end

%%------------------------------------------------------------------------%%
%%----------------------------Subfunction---------------------------------%%
%%------------------------------------------------------------------------%%

%%----------------Setting for 'save ERPname" Radio-----------------------------------------
    function erpname_radio(~,~)
        gui_erp_save_single.erpname_save.Value = 1;
    end


%%---------------Setting for filename--------------------------------------
    function erpname_str(Source,~)
        if gui_erp_save_single.filename_save.Value ==1
            gui_erp_save_single.filename_str.String  = gui_erp_save_single.erpname_str.String;
        else
            gui_erp_save_single.filename_str.String = '';
        end
    end

%%--------------Save erpname as filename-----------------------------------
    function erpname_filename(~,~)
        fileName = gui_erp_save_single.filename_str.String;
        [px, fname, ext] = fileparts(fileName);
        gui_erp_save_single.erpname_str.String = fname;
    end


%%--------------------Select "Save ERP as"-----------------------------------
    function filename_radio(Source,~)
        if Source.Value == 0
            gui_erp_save_single.filename_str.String = '';
            gui_erp_save_single.filename_str.Enable = 'off';
            gui_erp_save_single.filename_browse.Enable = 'off';
            gui_erp_save_single.erpname_filename.Enable = 'off';
        else
            gui_erp_save_single.filename_str.String = gui_erp_save_single.erpname_str.String;
            gui_erp_save_single.filename_str.Enable = 'on';
            gui_erp_save_single.filename_browse.Enable = 'on';
            gui_erp_save_single.erpname_filename.Enable = 'on';
        end
    end



%%--------------------------Path-------------------------------------------

    function filename_browse(~,~)
        fileName = gui_erp_save_single.filename_str.String;
        if ~isempty(fileName)
            [px, fname1, ext] = fileparts(fileName);
            
            [filename, filepath,filterindex] = uiputfile({'*.erp'; '*.mat'}, ...
                'Save Output file as',fname1);
        else
            [filename, filepath] = uiputfile({'*.erp'; '*.mat'}, ...
                'Save Output file as');
        end
        
        if isequal(filename,0)
            disp('User selected Cancel');
            return
        else
            [px, fname, ext] = fileparts(filename);
            if strcmp(ext,'')
                if filterindex==1 || filterindex==3
                    ext   = '.erp';
                else
                    ext   = '.mat';
                end
            end
            gui_erp_save_single.filename_str.String =[filepath,fname ext];
        end
    end






%%-----------------------Cancel section-----------------------------------
    function cancel_blc_dt(Source_localp_cancel,~)
        Values_localp_cancel = Source_localp_cancel.Value;
        if ~isempty(Values_localp_cancel)
            beep;
            disp('User selected Cancel');
            ERP_OUT = ERP_In;
            close(f_ERP_save_single);
            
            ERPName = ERP_In.erpname;
            px_fn = ERP_In.filepath;
            fileName_save = ERP_In.filename;
            erpworkingmemory('f_ERP_save_single_file',{ERPName,fileName_save,px_fn,0});
            return;
        end
    end

%%-----------------------Run selection-------------------------------------
    function run_blc_dt(Source_localp_run,~)
        Values_localp_run = Source_localp_run.Value;
        if ~isempty(Values_localp_run)
            ERPName = gui_erp_save_single.erpname_str.String;
            
            if isempty(ERPName)
                ERP_In.erpname =  ERP_In.erpname;
                ERPName = ERP_In.erpname;
            else
                ERP_In.erpname = ERPName;
            end
            
            if gui_erp_save_single.filename_save.Value ==1
                FileName = gui_erp_save_single.filename_str.String;
                [px_fn, fname_fn, ext_fn] = fileparts(FileName);
                
                fileName_save = [fname_fn ext_fn];
                
                if strcmp(ext_fn,'.erp')
                    ERP_In.filename = fileName_save;
                    ERP = ERP_In;
                    [ERP, issave, erpcom] = pop_savemyerp( ERP,'filename', fileName_save, 'filepath', px_fn);
                    
                elseif strcmp(ext_fn,'.mat')
                    ERP = ERP_In;
                    save([px_fn,filesep,fileName_save],'ERP');
                end
                fileName_save =  [fname_fn '.erp'];
            else
                px_fn = ERP_In.filepath;
                fileName_save = ERP_In.filename;
            end
            
            
            
            erpworkingmemory('f_ERP_save_single_file',{ERPName,fileName_save,px_fn,1});
            ERP_OUT = ERP_In;
            close(f_ERP_save_single);

            return;
        end
    end



end