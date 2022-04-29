% Purpose: Outputs DQ Table on Epoched Dataset (not ERP) 
%
% Format :
%
% pop_DQ_preavg(ALLEEG,parameters)
%
% INPUTS:
%
% EEG or ALLEEG     - input dataset
%
%


function pop_DQ_preavg(ALLEEG, varargin) 

%ERP = preloadERP; 

if nargin < 1
    help pop_DQ_preavg
    return
end

if isobject(ALLEEG) % eegobj 
    whenEEGisanObject
    return
end

if nargin == 1
    currdata = evalin('base', 'CURRENTSET');
    
    if currdata==0
        msgboxText =  'pop_DQ_preavg() error: cannot average an empty dataset!!!';
        title      = 'ERPLAB: No data';
        errorfound(msgboxText, title);
        return
    end
    
    % read values in memory for this function
    def  = erpworkingmemory('pop_DQ_preavg');   
    % def{1} - dataset indx, def{2} - artcrit, def{3} - wavg, def{4} - stderror, def{5} - exclude boundaries,
    % def{6} - ERP type, def{7} - wintaper type, def{8} - wintaper function,
    % def{9} - data quality flag, def{10} - DQ_spec_structure, 
    % def{11} - DQ pre-avg flag, def {12} - DQ_custom_wins
   
    
     if isempty(def) || numel(def)~=12
        % Should not be empty, and have exactly 12 elements. Else, fallback to:
        def = {1 1 1 1 1 0 0 [] 1 [] 1 0}; 
        
    end
    
    % epochs per dataset
    nepochperdata = zeros(1, length(ALLEEG));
    for k=1:length(ALLEEG)
        if isempty(ALLEEG(k).data)
            nepochperdata(k) = 0; % JLC.08/20/13
        else
            nepochperdata(k) = ALLEEG(k).trials;
        end
    end
    
    
    timelimits = 1000 * [ALLEEG(currdata).xmin ALLEEG(currdata).xmax]; % ms
    
    %
    % preAverager GUI
    %
    
    answer = DQ_preavg(currdata, def, nepochperdata, timelimits);
    
    
     
    if isempty(answer)
        disp('User selected Cancel')
        return
    end
    setindex = answer{1};   % datasets to average
    
    if numel(setindex) > 1
        disp('This tool cannot consider more than one .set file at a time!')
        return 
    end
    
   
    
    %
    % Artifact rejection criteria for averaging
    %
    %  artcrite = 0 --> averaging all (good and bad trials)
    %  artcrite = 1 --> averaging only good trials
    %  artcrite = 2 --> averaging only bad trials
    %  artcrite is cellarray  --> averaging only specified epoch indices
    artcrite  = answer{2};
    if ~iscell(artcrite)
        if artcrite==0
            artcritestr = 'all';
        elseif artcrite==1
            artcritestr = 'good';
        elseif artcrite==2
            artcritestr = 'bad';
        else
            artcritestr = artcrite;
        end
    else
        artcritestr = artcrite; % fixed bug. May 1, 2012
    end
    
    % Standard deviation option. 1= yes, 0=no
    stderror    = answer{4};
    
    % exclude epochs having boundary events
    excbound = answer{5};
    
    % Compute ERP, evoked power spectrum (EPS), and total power
    % spectrum (TPS).
    compu2do = answer{6}; % 0:ERP; 1:ERP+TPS; 2:ERP+EPS; 3:ERP+BOTH
    wintype  = answer{7}; % taper data with window: 0:no; 1:yes
    wintfunc = answer{8}; % taper function and (sub)window
    
    % Write the analytic Standardized Measurment Error info
    DQ_flag = answer{9};
    DQ_spec = answer{10};
    DQ_preavg_txt = answer{11}; 
    DQcustom_wins = answer{12};
    
    % store setting in erplab working memory
    def(1:12)    = {setindex, artcrite, 1, stderror, excbound, compu2do, wintype, wintfunc,DQ_flag,DQ_spec,DQ_preavg_txt,DQcustom_wins};
    erpworkingmemory('pop_DQ_preavg', def);
    
    if stderror==1
        stdsstr = 'on';
    else
        stdsstr = 'off';
    end
    if excbound==1
        excboundstr = 'on';
    else
        excboundstr = 'off';
    end
    if wintype==1
        wintypestr = wintfunc;
    else
        wintypestr = 'off';
    end
    
    %Here, use ERP_averager behind the scence
    
    [ERPpreavg, erpcom]  = pop_averager(ALLEEG, 'DSindex', setindex, 'Criterion', artcritestr,...
        'SEM', stdsstr, 'Saveas', 'off', 'Warning', 'off', 'ExcludeBoundary', excboundstr,...
        'DQ_flag',DQ_flag,'DQ_spec',DQ_spec, 'DQ_preavg_txt', DQ_preavg_txt,'DQ_custom_wins', DQcustom_wins, 'History', '');
    
    
    pause(0.1); 
    
    
    %Here, pass hidden ERP struct to DQTableGUI
    ALLERP = []; 
    CURRENTPREAVG = 1; 
    ERPpreavg.erpname = ALLEEG(setindex).setname; %setname instead of erpname in DQ Table
    
    DQ_Table_GUI(ERPpreavg,ALLERP,CURRENTPREAVG,1); 
    
    
end












end 