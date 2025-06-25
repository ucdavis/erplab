% PURPOSE:  pop_editdatachanlocs.m is to edit the channel locations
%
%

% FORMAT   :
%
% pop_editdatachanlocs(ALLEEG, CURRENTSET, parameters);
%

% ALLEEG        - structure array of ALLEEG/ERP structures
% CURRENTSET    - Index for current EEGset/ERPset



% The available parameters are as follows:
%
%ChanArray      -index(es) for the selected channels
%Chanlocs       - channel locations for the selected channels



%%Output
%%EEG         -EEG/ERP structure with the changed chan locations of the selected channels


%%Example:
%EEG =  pop_editdatachanlocs( ALLEEG, 2, 'ChanArray', [1  2  3], 'Chanlocs', chanlocs, 'History', 'implicit' );



% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023



function [EEG,eegcom] = pop_editdatachanlocs(ALLEEG,CURRENTSET,varargin)

eegcom = '';
if nargin < 1
    help pop_editdatachanlocs
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
        disp('The current dataset does not have Channel Location information. (see EEG -> chanlocs)');
        return;
    end
    chanlocs = EEG.chanlocs;
    if ~isfield(chanlocs,'labels')
        beep;
        disp('There are no labels for Channel Locations in the current dataset. (see EEG -> chanlocs)');
        return;
    end
    
    ChanArray = [1:length(EEG.chanlocs)];
    
    
    titleName= ['Dataset',32,num2str(CURRENTSET),': Add/Edit Channel locations'];
    EEGIN = EEG;
    EEGIN.chanlocs = EEG.chanlocs(ChanArray);
    app = feval('f_editchan_gui',EEGIN,titleName);
    waitfor(app,'Finishbutton',1);
    try
        EEGINOUT = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.5); %wait for app to leave
    catch
        disp('User selected Cancel')
        return
    end
    if isempty(EEGINOUT)
        disp('User selected Cancel')
        return
    end
    
    Chanlocs = EEGINOUT.chanlocs;
    %%add suffix
    try
        ALLEEG(CURRENTSET).setname = [ALLEEG(CURRENTSET).setname,'_editchan'];
    catch
        ALLEEG(CURRENTSET).erpname = [ALLEEG(CURRENTSET).erpname,'_editchan'];
    end
    [EEG, eegcom] = pop_editdatachanlocs(ALLEEG,CURRENTSET,'ChanArray',ChanArray,'Chanlocs',Chanlocs,'History', 'gui');
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
p.addParamValue('Chanlocs','', @isstruct);

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
    disp('The current dataset does not have Channel Location information. (see EEG -> chanlocs)');
    return;
end
chanlocs = EEG.chanlocs;
if ~isfield(chanlocs,'labels')
    beep;
    disp('There are no labels for Channel Locations in the current dataset. (see EEG -> chanlocs)');
    return;
end


%%channel array
qchanArray = p_Results.ChanArray;
nbchan = length(EEG.chanlocs);
if isempty(qchanArray) ||  min(qchanArray(:))>nbchan ||  max(qchanArray(:))>nbchan  ||  min(qchanArray(:))<=0
    qchanArray = [1:nbchan];
end



%%IC array (the default is empty, that is, donot display ICs)
qChanlocsnew = p_Results.Chanlocs;
if isempty(qChanlocsnew)
    disp('Chanlocs is empty');
    return;
end

%
%%adjust the number of channels and channel names
for Numofchan = 1:numel(qchanArray)
    try
        qChanlocsnew(Numofchan)  = qChanlocsnew(Numofchan);
    catch
        qChanlocsnew(Numofchan)  = EEG.chanlocs(qchanArray(Numofchan));
        fprintf(2,['\n Warning: Location for channel ',32,num2str(qchanArray(Numofchan)),32,'was not defined, we therefore used its original information.\n']);
    end
end


%%--------------change the channel names-----------------------------------
for Numofchan = 1:numel(qchanArray)
    fprintf(['Channel ',32,num2str(qchanArray(Numofchan)),': Location was edited.\n']);
    EEG.chanlocs(qchanArray(Numofchan)) = qChanlocsnew(Numofchan);
end



%%history
fn = fieldnames(p.Results);
skipfields = {'ALLEEG','CURRENTSET'};
if isfield(EEG,'datatype') && strcmpi(EEG.datatype,'ERP')
   eegcom     = sprintf( 'ERP = pop_editdatachanlocs( %s %s', 'ALLERP,',num2str(CURRENTSET)); 
else
eegcom     = sprintf( 'EEG = pop_editdatachanlocs( %s %s', 'ALLEEG,',num2str(CURRENTSET));
end
for q=1:length(fn)
    fn2com = fn{q}; % inputname
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com); %  input value
        if ~isempty(fn2res)
            if isstruct(fn2res)
                eegcom = sprintf( '%s, ''%s'', %s', eegcom, fn2com, fn2com);
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
                    fn2res_trans = vect2colon(fn2res);
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