%Author: Guanghui ZHANG & Steve Luck
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%2024

% ERPLAB Studio

function varargout = f_decode_mvpclass_GUI(varargin)
global observe_DECODE;
addlistener(observe_DECODE,'Count_currentMVPC_changed',@Count_currentMVPC_changed);
addlistener(observe_DECODE,'Reset_best_panel_change',@Reset_best_panel_change);

gui_decode_mvpclass = struct();
%-----------------------------Name the title----------------------------------------------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

if nargin == 0
    fig = figure(); % Parent figure
    box_decode_mvpclass = uiextras.BoxPanel('Parent', fig, 'Title', 'MVPCset Classes', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_decode_mvpclass = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'MVPCset Classes', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_decode_mvpclass = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'MVPCset Classes', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
varargout{1} = box_decode_mvpclass;

    function drawui_decode_history(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        %%--------------------channel and bin setting----------------------
        gui_decode_mvpclass.DataSelBox = uiextras.VBox('Parent', box_decode_mvpclass,'BackgroundColor',ColorB_def);
        
        
        ERP_history = '';
        [~, total_len] = size(ERP_history);
        total_len =1000;
        gui_decode_mvpclass.erp_history_table = uiextras.HBox('Parent', gui_decode_mvpclass.DataSelBox);
        gui_decode_mvpclass.uitable = uitable(  ...
            'Parent'        , gui_decode_mvpclass.erp_history_table,...
            'Data'          , ERP_history, ...
            'ColumnWidth'   , {total_len+2}, ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        set(gui_decode_mvpclass.DataSelBox,'Sizes',[150]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%



%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentMVPC_changed(~,~)
        if observe_DECODE.Count_currentMVPC~=5
            return;
        end
        Enableflag = 'on';
        gui_decode_mvpclass.save_script.Enable = Enableflag;
        
        
        if isempty(observe_DECODE.ALLMVPC)
            datastr = '';
            gui_decode_mvpclass.uitableColumnName=[];
        else
            count = 0;
            for Numofmvpc = 1:length(observe_DECODE.ALLMVPC)
                MVPC = observe_DECODE.ALLMVPC(Numofmvpc);
                for Numofclass = 1:MVPC.nClasses
                    count = count+1;
                    datastr{count,1}  = MVPC.mvpcname;
                    try
                        datastr{count,2}  = MVPC.classlabels{Numofclass};
                    catch
                        datastr{count,2} = ['Class',num2str(Numofclass)];
                    end
                    try
                        if strcmpi(MVPC.average_status,'grandaverage')
                            datastr{count,3} = ['grandavg'];
                        else
                            datastr{count,3}  = num2str(MVPC.n_trials_per_class(Numofclass));
                        end
                    catch
                        datastr{count,3} = [''];
                    end
                    gui_decode_mvpclass.uitable.ColumnName={'MVPC name','Class name','# trials per class'};
                    gui_decode_mvpclass.uitable.ColumnWidth = {70 70 100};
                end
            end
        end
        set(gui_decode_mvpclass.uitable,'Data',datastr);
        observe_DECODE.Count_currentMVPC=6;
    end



    function Reset_best_panel_change(~,~)
        if  observe_DECODE.Reset_Best_paras_panel~=5
            return;
        end
        Enableflag = 'on';
        gui_decode_mvpclass.save_script.Enable = Enableflag;
        if isempty(observe_DECODE.MVPC)
            datastr = '';
            gui_decode_mvpclass.uitableColumnName=[];
        else
            count = 0;
            for Numofmvpc = 1:length(observe_DECODE.ALLMVPC)
                MVPC = observe_DECODE.ALLMVPC(Numofmvpc);
                for Numofclass = 1:MVPC.nClasses
                    count = count+1;
                    datastr{count,1}  = MVPC.mvpcname;
                    try
                        datastr{count,2}  = MVPC.classlabels{Numofclass};
                    catch
                        datastr{count,2} = ['Class',num2str(Numofclass)];
                    end
                    try
                        if strcmpi(MVPC.average_status,'grandaverage')
                            datastr{count,3} = ['grandavg'];
                        else
                            datastr{count,3}  = num2str(MVPC.n_trials_per_class(Numofclass));
                        end
                    catch
                        datastr{count,3} = [''];
                    end
                    gui_decode_mvpclass.uitable.ColumnName={'MVPC name','Class name','# trials per class'};
                    gui_decode_mvpclass.uitable.ColumnWidth = {70 70 100};
                end
            end
        end
        set(gui_decode_mvpclass.uitable,'Data',datastr);
        observe_DECODE.Reset_Best_paras_panel=6;
    end
end