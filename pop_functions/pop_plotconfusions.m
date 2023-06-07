

function pop_plotconfusions(ALLMVPC,varargin) 

MVPC = preloadMVPC; 

if nargin == 1 %GUI
    
    currdata = evalin('base','CURRENTMVPC'); 
    
    if currdata == 0 
        msgboxText =  'pop_plotconfusions() error: cannot work an empty dataset!!!';
        title      = 'ERPLAB: No MVPC data';
        errorfound(msgboxText, title);
        return
        
    end
    
    if ~iscell(ALLMVPC) && ~ischar(ALLMVPC)
%         if isstruct(ALLMVPC)
% %             iserp = iserpstruct(ALLMVPC(1));
% %             if ~iserp
% %                 ALLMVPC = [];
% %             end
%             actualnset = numel(ALLMVPC); %one MVPC at a time
%         else
%             ALLMVPC = [];
%             actualnset = 0;
%         end
        
        def  = erpworkingmemory('pop_plotconfusions');
        if isempty(def)
            def = {1 1};
            %def{1} = plot menu (1: tp confusion 2:mean confusion two
            %                           latency)
        end
        
        
        
%         if isnumeric(def{3}) && ~isempty(MVPC) %if ALLMVPC indexs are supplied
%             if max(def{3})>length(MVPC)
%                 def{3} = def{3}(def{3}<=length(MVPC));
%             end
%             if isempty(def{3})
%                 def{3} = 1;
%             end
%         end       
%           def{2} = 0; %aaron: until I fix lists, always load mvpcmenu

        %
        % Open Grand Average GUI
        %
        app = feval('plotConfusionGUI',ALLMVPC,currdata,def); 
        waitfor(app,'FinishButton',1);
        
        try
            answer = app.output; %NO you don't want to output BEST, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            disp('User selected Cancel')
            return
        end
    
        
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        
        plot_menu    = answer{1}; %plot_menu
        plot_cmap     = answer{2};%plot_colormap
        tp =   answer{3}; % 0;1
        %warnon    = answer {4}; 
        cmaps = {'jet','hsv', 'hot', 'cool', 'gray','viridis'}; 
        
%         if optioni==1 % from files
%             filelist    = mvpcset;
%             disp(['pop_gaverager(): For file-List, user selected ', filelist])
%             ALLMVPC = {ALLMVPC, filelist}; % truco
%         else % from mvpcsets menu
%             %mvpcset  = mvpcset;
%         end
        
        %def = {actualnset, optioni, mvpcset,stderror};
        def = {plot_menu, plot_cmap};
        erpworkingmemory('pop_plotconfusions', def);
%         if stderror==1
%             stdsstr = 'on';
%         else
%             stdsstr = 'off';
%         end
%         if warnon==1
%             warnon_str = 'on';
%         else
%             warnon_str = 'off';
%         end
            %
            % Somersault
            %
            %[ERP erpcom]  = pop_gaverager(ALLMVPC, 'mvpcsets', mvpcset, 'Loadlist', filelist,'Criterion', artcrite,...
            %        'SEM', stdsstr, 'Weighted', wavgstr, 'Saveas', 'on');
           pop_plotconfusions(ALLMVPC, 'MVPCindex', currdata, 'timepoint', tp,...
               'colormap', cmaps{plot_cmap}, 'Saveas','on','History', 'gui');
        pause(0.1)
        return
    else
        fprintf('pop_mvpcaverager() was called using a single (non-struct) input argument.\n\n');
    end
    
    
    
    
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLMVPC');
% option(s)
p.addParamValue('MVPCindex', []);               % same as Erpsets
%p.addParamValue('Mvpcsets', []);
p.addParamValue('timepoint', [], @isnumeric);        % 'on', 'off'
p.addParamValue('colormap', [], @ischar); 
p.addParamValue('Saveas', 'off', @ischar);     % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);    % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLMVPC, varargin{:});
mvpci = p.Results.MVPCindex; 
tp = p.Results.timepoint; 
cmap = p.Results.colormap; 

if isempty(mvpci) 
    MVPC = ALLMVPC; 
else
    MVPC = ALLMVPC(mvpci); 
end

cf_scores = MVPC.confusions.scores;
cf_labels = MVPC.confusions.labels; 
cf_strings = convertCharsToStrings(cf_labels); 

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Time conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%
times = MVPC.times; 

%tm = -500:steptp:1496;
% ms = epoched/Ntp;
% t1 = (t1 + 500)/ms;
% t2 = (t2 + 500)/ms;

time_ind = []; 
for i = 1:numel(tp) 
    time_ind(i) = find(tp(i) == times);  
end

cf_scores = cf_scores(:,:,time_ind);

%% plot

for p = 1:numel(time_ind)
    
    C = cf_scores(:,:,p); 
    h = heatmap(cf_strings,cf_strings,C);
    
    h.Title = ['Confusion Matrix @ time ', num2str(tp(p)), ' ms'];
    h.YLabel = 'True Labels';
%    h.YData = [NBins:-1:1]; %%%% only put if you use "FLIPUD(C)" argument (line 126)
    h.XLabel = 'Predicted Labels';
  %  h.ColorLimits = [0.02 0.12]; %this is arbitrary limits
    
  %  fname = ['h', num2str(Ntp_sel)];

end


end