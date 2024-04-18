% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2024

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Studio Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [ERP, erpcom] = pop_ERP_spectralanalysis(ERP, varargin)
erpcom = '';
if nargin < 1
    help pop_ERP_spectralanalysis
    return
end
if isfield(ERP(1), 'datatype')
    datatype = ERP.datatype;
else
    datatype = 'ERP';
end
if nargin==1
    title_msg  = 'ERPLAB: pop_ERP_spectralanalysis() error:';
    if isempty(ERP)
        ERP = preloadERP;
        if isempty(ERP)
            msgboxText =  'No ERPset was found!';
            
            errorfound(msgboxText, title_msg);
            return
        end
    end
    if isempty(ERP.bindata)
        msgboxText = 'cannot work with an empty ERP erpset';
        errorfound(msgboxText, title_msg);
        return
    end
    if ~strcmpi(datatype, 'ERP')
        msgboxText =  'This ERPset is already converted into frequency domain!';
        errorfound(msgboxText, title_msg);
        return
    end
    
    %
    % FFT points will be as much as needed
    % to get 1 point each 0.25 Hz, at least.
    % Users can change this value using scripting. Jav
    %
    def   = estudioworkingmemory('pop_ERP_spectralanalysis');
    if isempty(def)
        def = {1,1,[0,floor(ERP.srate/2)],ERP.srate};
        
    end
    
    app = feval('ERP_spectral_analysis_GUI.mlapp',def{1},def{2},def{3},def{4},ERP);
    waitfor(app,'Finishbutton',1);
    try
        def = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(def)
        return;
    end
    Amptypev = def{1};
    if Amptypev==2
        Amptype = 'phase';
    elseif Amptypev==3
        Amptype = 'power';
    elseif Amptypev==4
        Amptype = 'db';
    else
        Amptype = 'amp';
    end
    
    if def{2}==1
        TaperWindow = 'on';
    else
        TaperWindow = 'off';
    end
    estudioworkingmemory('pop_ERP_spectralanalysis',def);
    freqrange = def{3};
    if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(ERP.srate/2)) || any(freqrange(:)<0)
        freqrange = [0 floor(ERP.srate/2)];
    end
    
    ChanArray = def{6};
    if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
        ChanArray = [1:ERP.nchan];
    end
    BinArray = def{5};
    if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
        BinArray = 1:ERP.nbin;
    end
    
    erpcom = pop_ERP_spectralanalysis(ERP, 'Amptype',Amptype,'TaperWindow',TaperWindow,...
        'freqrange',freqrange,'BinArray',BinArray,'ChanArray',ChanArray,'Plotwave','on',...
        'Saveas', 'off','History','gui');
    return
end


%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
% option(s)
p.addParamValue('TaperWindow', 'on', @ischar);       % 'ERP': compute the average of epochs per bin;
p.addParamValue('Amptype', 'amp', @ischar);
p.addParamValue('freqrange', [], @isnumeric);
p.addParamValue('BinArray', [], @isnumeric);
p.addParamValue('ChanArray', [], @isnumeric);
p.addParamValue('Plotwave', 'on', @ischar);
p.addParamValue('Saveas', 'off', @ischar);  % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, varargin{:});

if iseegstruct(ERP)
    if length(ERP)>1
        msgboxText =  'ERPLAB says: Unfortunately, this function does not work with multiple ERPsets';
        error(msgboxText);
    end
end


% NFFT, iswindowed
if strcmpi(p.Results.TaperWindow,'off')
    iswindowed = 0;
elseif strcmpi(p.Results.TaperWindow,'on')
    iswindowed = 1;
else
    if ~isempty(p.Results.TaperWindow) && ischar(p.Results.TaperWindow)
        iswindowed = p.Results.TaperWindow;
    else
        error('Unknow value for "TaperWindow"')
    end
end

if ismember_bc2({p.Results.Saveas}, {'on','yes'})
    issaveas  = 1;
elseif ismember_bc2({p.Results.Saveas}, {'csv'})
    issaveas  = 2;
else
    issaveas  = 0;
end

ERP = f_getFFTfromERP(ERP,iswindowed);

%%--------------------------------display type-----------------------------
Amptype = p.Results.Amptype;
if strcmpi(Amptype,'phase')
    ERP.bindata  = angle(ERP.bindata);
    figure_name = ['Spectral analysis - Phase for ',32,ERP.erpname];
elseif strcmpi(Amptype,'power')
    ERP.bindata  = abs(ERP.bindata).^2;
    figure_name = ['Spectral analysis - Power for ',32,ERP.erpname];
elseif strcmpi(Amptype,'db')
    ERP.bindata  = 20*log10(abs(ERP.bindata));
    figure_name = ['Spectral analysis - dB for ',32,ERP.erpname];
else
    ERP.bindata  = abs(ERP.bindata);
    figure_name = ['Spectral analysis - Amplitude for ',32,ERP.erpname];
end


freqrange = p.Results.freqrange;

if isempty(freqrange) || numel(freqrange)~=2 || any(freqrange(:)>floor(ERP.srate/2)) || any(freqrange(:)<0)
    freqrange = [0 floor(ERP.srate/2)];
end

%%
ChanArray = p.Results.ChanArray;
if isempty(ChanArray) || any(ChanArray(:)>ERP.nchan) || any(ChanArray(:)<1)
    ChanArray = [1:ERP.nchan];
end

%%
BinArray = p.Results.BinArray;
if isempty(BinArray) || any(BinArray(:)>ERP.nbin) || any(BinArray(:)<1)
    BinArray = 1:ERP.nbin;
end


[xxx, latsamp, latdiffms] = closest(ERP.times, freqrange);
tmin = latsamp(1);
tmax = latsamp(2);
ERP.bindata = ERP.bindata(ChanArray,tmin:tmax,BinArray);
ERP.nbin = numel(BinArray);
ERP.bindescr = ERP.bindescr(BinArray);
ERP.times = ERP.times(tmin:tmax);
ERP.nchan =numel(ChanArray);
ERP.chanlocs = ERP.chanlocs(ChanArray);

if strcmpi(p.Results.Plotwave,'on')
    fig = figure('Name',figure_name);
    %             set(fig,'outerposition',get(0,'screensize'));
    
    FonsizeDefault = f_get_default_fontsize();
    FreqTick = default_time_ticks(ERP, freqrange);
    FreqTick = str2num(FreqTick{1});
    pbox = f_getrow_columnautowaveplot(ChanArray);
    try
        RowNum = pbox(1)+1;
        ColumnNum = pbox(2);
    catch
        RowNum = numel(ChanArray)+1;
        ColumnNum = 1;
    end
    count = 0;
    for Numofcolumn = 1:ColumnNum
        for Numofrow = 1:RowNum
            count = count+1;
            if ColumnNum*RowNum<5
                pause(1);
            end
            if count>ERP.nchan
                break;
            end
            p_ax = subplot(RowNum,ColumnNum,count);
            set(gca,'fontsize',FonsizeDefault);
            hold on;
            temp = squeeze(ERP.bindata);
            for Numofplot  = 1:ERP.nbin
                h_p(Numofplot) =  plot(p_ax,ERP.times,squeeze(ERP.bindata(count,:,Numofplot)),'LineWidth',1);
            end
            axis(p_ax,[floor(ERP.times(1)),ceil(ERP.times(end)), 1.1*min(temp(:)) 1.1*max(temp(:))]);
            xticks(p_ax,FreqTick);
            if count == 1
                title(p_ax,char(strrep(ERP.chanlocs(count).labels,'_','\_')),'FontSize',FonsizeDefault,'FontWeight','normal','Color','k','Interpreter','none'); %#ok<*NODEF>
            else
                title(p_ax,ERP.chanlocs(count).labels,'FontSize',FonsizeDefault,'FontWeight','normal','Color','k','Interpreter','none');
            end
            xlabel(p_ax,'Frequency/Hz','FontSize',FonsizeDefault,'FontWeight','normal','Color','k');
            
            if strcmpi(Amptype,'phase')
                ylabel(p_ax,'Angle/degree','FontSize',FonsizeDefault,'FontWeight','normal','Color','k');
            elseif strcmpi(Amptype,'power')
                ylabel(p_ax,'Power/\muV^2','FontSize',FonsizeDefault,'FontWeight','normal','Color','k');
            elseif strcmpi(Amptype,'db')
                ylabel(p_ax,'Decibels/dB','FontSize',FonsizeDefault,'FontWeight','normal','Color','k');
            else
                ylabel(p_ax,'Amplitude/\muV','FontSize',FonsizeDefault,'FontWeight','normal','Color','k');
            end
            
            for NUmoflabel = 1:length(ERP.times)
                X_label{NUmoflabel} = [];
            end
            set(gca,'TickDir','out');
            set(gca,'LineWidth',1);
            set(gca,'Color','w',...
                'XColor','k',...
                'YColor','k',...
                'ZColor','k');
        end
    end
    sh = subplot(RowNum+1, ColumnNum,[RowNum*ColumnNum+1:(RowNum+1)*ColumnNum],'align');
    axis(sh,'off');
    pos  = get(sh,'position');
    h_legend =  legend(sh,h_p,ERP.bindescr);
    legend(sh,'boxoff');
    set(h_legend, 'position', pos);
    qlegcolumns = ceil(sqrt(length(ERP.bindescr)));
    set(h_legend,'NumColumns',qlegcolumns);
    set(h_legend,'FontSize',FonsizeDefault);
    set(fig,'Color','w');
end



if strcmpi(p.Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
    shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end

%
% subroutine
%

%
% History
%
skipfields = {'ERP', 'History'};
fn     = fieldnames(p.Results);
erpcom = sprintf('%s = pop_ERP_spectralanalysis( %s ', inputname(1), inputname(1));

for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            else
                if iscell(fn2res)
                    if ischar([fn2res{:}])
                        fn2resstr = sprintf('''%s'' ', fn2res{:});
                    else
                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                    end
                    fnformat = '{%s}';
                else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                end
                
                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ERPset
%
if issaveas==1
    [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');
    if issave>0
        if issave==2
            erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
            msgwrng = '*** Your ERPset was saved on your hard drive.***';
        else
            msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
        end
    else
        msgwrng = 'ERPLAB Warning: Your changes were not saved';
    end
    try cprintf([1 0.52 0.2], '%s\n\n', msgwrng); catch,fprintf('%s\n\n', msgwrng);end ;
    
elseif issaveas==2
    def  = estudioworkingmemory('f_export2csvGUI');
    if isempty(def)
        def = {1, 1, 1, 3, ''};
    end
    ERPtooltype = erpgettoolversion('tooltype');
    if strcmpi(ERPtooltype,'estudio')
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =[pwd,filesep];
        end
    else
        pathName = [pwd,filesep];
    end
    def{5} = fullfile(pathName,ERP.filename);
    answer_export = f_export2csvGUI(ERP,def);
    estudioworkingmemory('f_export2csvGUI',answer_export);
    if isempty(answer_export)
        return;
    end
    BinArray = [1:ERP.nbin];
    decimal_num = answer_export{4};
    istime =answer_export{1} ;
    electrodes=answer_export{2} ;
    transpose=answer_export{3};
    filenamei = answer_export{5};
    [pathx, filename, ext] = fileparts(filenamei);
    ext = '.csv';
    if isempty(pathx)
        pathx =cd;
    end
    filename = [filename ext];
    mkdir([pathx,filesep]);
    try
        export2csv_spectranl_analysis(ERP,fullfile(pathx,filename), BinArray,istime, electrodes,transpose,  decimal_num);
    catch
        disp('Fail to save selected ERPset as ".csv"!!!');
    end
    
end
% get history from script. ERP
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        ERP = erphistory(ERP, [], erpcom, 1);
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end

%
% Completion statement
%
msg2end
return