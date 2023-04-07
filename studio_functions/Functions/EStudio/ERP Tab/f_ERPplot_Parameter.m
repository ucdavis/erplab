%Purpose: This function is used to generate the parameters which are applied to get the waveforms of electrodes and bins of interest.


%FORMAT:
%
%      f_ERPplot_Parameter(ALLERP,Index_selectedERPset)

% INPUTS   :
%
% ALLERP        - structure array of ERP structures (ERPsets)
%                 To read the ERPset from a list in a text file,
%                 replace ALLERP by the whole filename.
%
% Index_selectedERPset - index of selected ERPset(s),e.g., 1 or [3,4]

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022




function S_erpplot = f_ERPplot_Parameter(ALLERP,Index_selectedERPset)


if nargin<1
    help f_ERPplot_Parameter
    return
end

if nargin==1
    try
        Index_selectedERPset = evalin('base','CURRENTERP');
    catch
        beep;
        disp('No CURRENTERP can be found from Matlab workspace')
        return;
    end
end


if Index_selectedERPset > length(ALLERP)
    beep;
    disp('The index of the input ERPset is larger than the length of ALLERPSET !!!');
    return;
end

if isempty(Index_selectedERPset)
    beep;
    disp('The ERPsets of interest can not be selected!!!');
    return;
end

S_ws = struct();

% checked_ERPset_Index_bin_chan = f_checkerpsets(ALLERP,Index_selectedERPset);

for NumofselectERP =1:length(Index_selectedERPset)
    
    if Index_selectedERPset(NumofselectERP)> length(ALLERP)% check if the index exceeds the length of ALLERPsets
        msgboxText =  'The selected ERPset does not exsit!!!';
        title = 'EStudio: Bin and Channel Selection';
        errorfound(msgboxText, title);
        return;
    end
    
    ERP = ALLERP(Index_selectedERPset(NumofselectERP));
    
    %             elec_list = cell(numel(ERP.chanlocs),1);
    for i=1:length(ERP.chanlocs)
        elec_list_get{i} = ERP.chanlocs(i).labels;
    end
    
    if length(elec_list_get)~= size(ERP.bindata,1)
        beep;
        title = 'EStudio: Bin and Channel Selection';
        msgboxText =  strcat('Number of channel''s labels is not equal to  number of first demension of ERP.bindata for imported datasets!!!');
        disp();
        errorfound(msgboxText, title);
        return;
        
    end
    
    elec_list{NumofselectERP} = elec_list_get;
    clear elec_list_get;
    Check_bin_chan = [0 0];
    first_elec(NumofselectERP) = 1;
    if length(ERP.chanlocs) <41
        elec_n(NumofselectERP) = numel(ERP.chanlocs);
        elecs_shown{NumofselectERP} = first_elec:first_elec+elec_n(NumofselectERP)-1;
    elseif length(ERP.chanlocs) >40
        elec_n(NumofselectERP) =40;
        elecs_shown{NumofselectERP} = 1:40;
        Check_bin_chan(1) =1;
    end
    
    timemin(NumofselectERP) = ERP.times(1);
    timemax(NumofselectERP) = ERP.times(end);
    timefirst(NumofselectERP) = timemin(NumofselectERP);
    
    
    %             bins = zeros(1,ERP.nbin);
    %%Dispay the first 20 bins if the number of bins is exceed 20.
    if ERP.nbin<21
        bins{NumofselectERP} =1:ERP.nbin;
        bin_n(NumofselectERP) = ERP.nbin;
    elseif ERP.nbin>=21
        bins{NumofselectERP} =1:20;
        bin_n(NumofselectERP) = 20;
        Check_bin_chan(2) =1;
    end
    
    
    min(NumofselectERP) = floor(ERP.times(1)/5)*5;
    max(NumofselectERP) = ceil(ERP.times(end)/5)*5;
    
    tmin(NumofselectERP) = (floor((min(NumofselectERP)-ERP.times(1))/2)+1);
    tmax(NumofselectERP) = (numel(ERP.times)+ceil((max(NumofselectERP)-ERP.times(end))/2));
    
    if tmin(NumofselectERP) < 1
        tmin(NumofselectERP) = 1;
    end
    
    if tmax(NumofselectERP) > numel(ERP.times)
        tmax(NumofselectERP) = numel(ERP.times);
        
    end
    
    if strcmpi(ERP.erpname,'No ERPset loaded')
       tmax(NumofselectERP) = 1; 
       max(NumofselectERP) =1;
    end
    min_vspacing(NumofselectERP) = 1.5;
    YScale = prctile((ERP.bindata(:)),95)*2/3;
    if YScale>= 0&&YScale <=0.1
        prct(NumofselectERP) = 0.1;
    elseif YScale< 0&& YScale > -0.1
        prct(NumofselectERP) = -0.1;
    else
        prct(NumofselectERP) = round(YScale);
    end
    timet_low(NumofselectERP) = floor(ERP.times(1)/5)*5;
    if strcmpi(ERP.erpname,'No ERPset loaded')
      timet_high = 1;  
      stepx =1;
    else
    timet_high(NumofselectERP) = ceil(ERP.times(end)/5)*5;
    [def stepx]= default_time_ticks_studio(ERP);
    end
  
    %     timet_step(NumofselectERP) = (ceil(ERP.times(end)/5)*5-floor(ERP.times(1)/5)*5)/5;
    timet_step(NumofselectERP) = stepx;
    fill_index(NumofselectERP) = 1;
    Positive_up_index(NumofselectERP) = 1;
    bins_chans(NumofselectERP) = 0;
    plot_column(NumofselectERP) = 1;
end




matlab_ver = version('-release');
matlab_ver = str2double(matlab_ver(1:4));


data_p_bin_chan = { elec_list, ...
    first_elec, ...
    elec_n, ...
    elecs_shown, ...
    timemin, ...
    timemax, ...
    timefirst, ...
    bins, ...
    bin_n, ...
    matlab_ver, ...
    bins_chans, ...
    min, ...
    max, ...
    timet_low, ...
    timet_high, ...
    timet_step, ...
    prct, ...
    min_vspacing, ...
    fill_index,...
    Positive_up_index,...
    plot_column};

erpvalues_variables = {'geterpplot','timemin',data_p_bin_chan{5},'timemax',data_p_bin_chan{6},'timefirst',data_p_bin_chan{7},...
    'min',data_p_bin_chan{12},'max',data_p_bin_chan{13},...
    'timet_low',data_p_bin_chan{14},'timet_high',data_p_bin_chan{15},...
    'timet_step',data_p_bin_chan{16},'yscale',data_p_bin_chan{17},...
    'min_vspacing',data_p_bin_chan{18},'fill',data_p_bin_chan{19},...
    'Positive_up',data_p_bin_chan{20},'Plot_column',data_p_bin_chan{end}};
S_erpplot = createrplabstudioparameters(S_ws,erpvalues_variables);

%%------------------------Chan and bin-------------------------------------

if strcmp(ALLERP(1).erpname,'No ERPset loaded')
    checked_curr_index = 1;
else
    checked_curr_index = 0;
end
checked_ERPset_Index = f_checkerpsets(ALLERP,Index_selectedERPset);


erpvalues_variables = {'geterpbinchan','elec_list',data_p_bin_chan{1},'first_elec',data_p_bin_chan{2},...
    'elec_n',data_p_bin_chan{3},'elecs_shown',data_p_bin_chan{4},...
    'bins',data_p_bin_chan{8},'bin_n',data_p_bin_chan{9},...
    'matlab_ver',data_p_bin_chan{10},'bins_chans',data_p_bin_chan{11},'Select_index',1,...
    'checked_ERPset_Index',checked_ERPset_Index,'checked_curr_index',checked_curr_index};
S_erpplot = createrplabstudioparameters(S_erpplot,erpvalues_variables);



return;