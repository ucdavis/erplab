% PURPOSE:  pop_rename2chan.m is to change the channel names
%
%

% FORMAT   :
%
% pop_rename2chan(ALLEEG, CURRENTSET, parameters);
%

% ALLEEG        - structure array of EEG structures
% CURRENTSET    - Index for current EEGset



% The available parameters are as follows:
%
%ChanArray      -index(es) for the selected channels
%Chanlabels     - new names for the selected channels



%%Output
%%EEG         -EEG structure with the changed names of the selected channels


%%Example:
%EEG =  pop_rename2chan( ALLEEG, 2, 'ChanArray', [1  2  3], 'Chanlabels', {'FP1-1' , 'F3-2' , 'F7-3' }, 'History', 'implicit' );



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023



function [EEG,eegcom] = pop_rename2chan(ALLEEG,CURRENTSET,varargin)

eegcom = '';
if nargin < 1
    help pop_rename2chan
    return;
end

if isempty(ALLEEG)%%
    beep;
    disp('ALLEEG is empty');
    return;
end

if nargin< 3
    %%Do we need to create a GUI that the user can use it to define the
    %%desired parameters?
    
    if nargin< 2 || isempty(CURRENTSET) || numel(CURRENTSET)~=1 || CURRENTSET>length(ALLEEG) || CURRENTSET<=0
        CURRENTSET = length(ALLEEG);
    end
    EEG = ALLEEG(CURRENTSET);
    if ~isfield(EEG,'chanlocs')
        beep;
        disp('The current dataset donot have chanlocs field');
        return;
    end
    chanlocs = EEG.chanlocs;
    if ~isfield(chanlocs,'labels')
        beep;
        disp('There is no labels for chanlocs for the current dataset');
        return;
    end
    
    ChanArray = [1:length(EEG.chanlocs)];
    [eloc, Chanlabelsold, theta, radius, indices] = readlocs( chanlocs);
    
    
    def =  erpworkingmemory('pop_rename2chan');
    if isempty(def)
        def = Chanlabelsold;
    end
    erplab_studio_default_values;
    version = erplabstudiover;
    titleName= ['Dataset',32,num2str(CURRENTSET),': ERPLAB',32,num2str(version), 32,'Change Channel Name'];
    Chanlabelsnew= f_change_chan_name_GUI(Chanlabelsold,def,titleName);
    
    if isempty(Chanlabelsnew)
        disp('User selected Cancel')
        return
    end
    erpworkingmemory('pop_rename2chan',Chanlabelsnew);
    %%add suffix
    try
        ALLEEG(CURRENTSET).setname = [ALLEEG(CURRENTSET).setname,'_rnchan'];
    catch
        ALLEEG(CURRENTSET).erpname = [ALLEEG(CURRENTSET).erpname,'_rnchan'];
    end
    [EEG, eegcom] = pop_rename2chan(ALLEEG,CURRENTSET,'ChanArray',ChanArray,'Chanlabels',Chanlabelsnew,'History', 'gui');
    pause(0.1);
    return;
end


%
% Parsing inputs
%
% colordef = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};% default colors
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLEEG');
p.addRequired('CURRENTSET');

%Option(s)
p.addParamValue('ChanArray',[],@isnumeric);
p.addParamValue('Chanlabels','', @iscell);

p.addParamValue('History', '', @ischar); % history from scripting

p.parse(ALLEEG,CURRENTSET,varargin{:});

p_Results = p.Results;

if strcmpi(p_Results.History,'command')
    shist = 4;%%Show  Maltab command only and donot plot the wave
elseif strcmpi(p_Results.History,'implicit')
    shist = 3; % implicit
elseif strcmpi(p_Results.History,'script')
    shist = 2; % script
elseif strcmpi(p_Results.History,'gui')
    shist = 1; % gui
else
    shist = 0; % off
end


if isempty(ALLEEG)%%
    beep;
    disp('ALLEEG is empty');
    return;
end


if isempty(CURRENTSET) || numel(CURRENTSET)~=1 || CURRENTSET>length(ALLEEG) || CURRENTSET<=0
    CURRENTSET = length(ALLEEG);
end

EEG = ALLEEG(CURRENTSET);
if ~isfield(EEG,'chanlocs')
    beep;
    disp('The current dataset donot have chanlocs field');
    return;
end
chanlocs = EEG.chanlocs;
if ~isfield(chanlocs,'labels')
    beep;
    disp('There is no labels for chanlocs for the current dataset');
    return;
end


%%channel array
qchanArray = p_Results.ChanArray;
nbchan = length(EEG.chanlocs);
if isempty(qchanArray) ||  min(qchanArray(:))>nbchan ||  max(qchanArray(:))>nbchan  ||  min(qchanArray(:))<=0
    qchanArray = [1:nbchan];
end



%%IC array (the default is empty, that is, donot display ICs)
qChanlabelsnew = p_Results.Chanlabels;
if isempty(qChanlabelsnew)
    disp('Chanlabels is empty');
    return;
end

%
%%adjust the number of channels and channel names
for Numofchan = 1:numel(qchanArray)
    try
        if isempty(char(qChanlabelsnew{Numofchan}))
            qChanlabelsnew{Numofchan,1}  = EEG.chanlocs(qchanArray(Numofchan)).labels;
            fprintf(2,['\n Warning: name for channel ',32,num2str(qchanArray(Numofchan)),32,' was empty, we threfore used its original name',32,qChanlabelsnew{Numofchan,1},'.\n']);
        else
            qChanlabelsnew{Numofchan,1}  = char(qChanlabelsnew{Numofchan});
        end
    catch
        qChanlabelsnew{Numofchan,1}  = EEG.chanlocs(qchanArray(Numofchan)).labels;
        fprintf(2,['\n Warning: name for channel ',32,num2str(qchanArray(Numofchan)),32,'was not defined, we threfore used its original name',32,qChanlabelsnew{Numofchan,1},'.\n']);
    end
end


%%--------------change the channel names-----------------------------------
for Numofchan = 1:numel(qchanArray)
    fprintf(['Chan',32,num2str(qchanArray(Numofchan)),':',32,EEG.chanlocs(qchanArray(Numofchan)).labels,32,'was changed to',32,qChanlabelsnew{Numofchan,1},'.\n']);
    EEG.chanlocs(qchanArray(Numofchan)).labels = char(qChanlabelsnew{Numofchan,1});
end



%%history
fn = fieldnames(p.Results);
skipfields = {'ALLEEG','CURRENTSET'};
if isfield(EEG,'datatype') && strcmpi(EEG.datatype,'ERP')
   eegcom     = sprintf( 'ERP = pop_rename2chan( %s %s', 'ALLERP,',num2str(CURRENTSET)); 
else
eegcom     = sprintf( 'EEG = pop_rename2chan( %s %s', 'ALLEEG,',num2str(CURRENTSET));
end
for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off')
                    eegcom = sprintf( '%s, ''%s'', ''%s''', eegcom, fn2com, fn2res);
                end
            elseif iscell(fn2res)
                nn = length(fn2res);
                eegcom = sprintf( '%s, ''%s'', {''%s'' ', eegcom, fn2com, fn2res{1});
                for ff=2:nn
                    eegcom = sprintf( '%s, ''%s'' ', eegcom, fn2res{ff});
                end
                eegcom = sprintf( '%s}', eegcom);
            elseif isnumeric(fn2res)
                
                if size(fn2res,1)==1
                    fn2res_trans = char(num2str(fn2res));
                else
                    fn2res_trans = char(num2str(fn2res(1,:)));
                    for ii = 2:size(fn2res,1)
                        fn2res_trans  =  char(strcat(fn2res_trans,';',num2str(fn2res(ii,:))));
                    end
                end
                fn2res = fn2res_trans;
                eegcom = sprintf( '%s, ''%s'', [%s', eegcom,fn2com,fn2res);
                eegcom = sprintf( '%s]', eegcom);
            else
                %                 if ~ismember_bc2(fn2com,{'xscale','yscale'})
                %                     eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                %                 else
                %                     xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                %                     eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, xyscalestr);
                %                 end
            end
        end
    end
end

eegcom = sprintf( '%s );', eegcom);
% get history from script. ERP
% shist = 1;
switch shist
    case 1 % from GUI
        displayEquiComERP(eegcom);
    case 2 % from script
        for i=1:length(ALLEEG)
            ALLEEG(i) = erphistory(ALLEEG(i), [], eegcom, 1);
        end
    case 3
        % implicit
    case 4
        displayEquiComERP(eegcom);
        
    otherwise %off or none
        eegcom = '';
        return
end

return;