% erplab_interpolateElectrodes() - interpolate data channels
%
% Usage: EEG = erplab_interpolateElectrodes(ORIEEG, replace_elecs, ignore_elecs, method)
%
% Inputs:
%     EEG           - EEGLAB dataset
%     replace_elecs - [integer array] indices of channels to interpolate.
%                     For instance, these channels might be bad.
%                     [chanlocs structure] channel location structure containing
%                     either locations of channels to interpolate or a full
%                     channel structure (missing channels in the current
%                     dataset are interpolated).
%     ignore_elecs  - Do not include these electrodes as input for interopolation
%     method        - [string] method used for interpolation (default is 'spherical').
%                     'invdist'/'v4' uses inverse distance on the scalp
%                     'spherical' uses superfast spherical interpolation.
% Output:
%     EEGOUT        - data set with bad electrode data replaced by
%                     interpolated data
%
% Author: Jason Arita
%
% Built off of EEGLAB's eeg_interp.m by Arnoud Delorme

% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function EEG = erplab_interpolateElectrodes(ORIEEG, replace_elecs, ignore_elecs, method, varargin)

%% Error check input variables
if nargin < 2
    help erplab_interpolateElectrodes;
    return;
end;


% Error check: channel structure exists
tmplocs = ORIEEG.chanlocs;
if isempty(tmplocs) || isempty([tmplocs.X])
    error(sprintf('Missing Channel Locations:\n\nChannel locations are needed to interpolate. Add channel locations through EEGLAB > Edit > Channel locations')); %#ok<*SPERR>
end


% Error check: Overlapping electrode lists in replace_elecss and
% ignore_elecs
overlap_elec = intersect(replace_elecs, ignore_elecs);
if ~isempty(overlap_elec)
    error(sprintf('Replace/Ignore Electrode Overlap:\n\nThere is overlap in the replace electrodes and the ignore electrodes.\nFix the input to avoid this overlap.\n\nBad electrodes:\t\t%s\nIgnore electrodes:\t%s\nOverlapping electrodes:\t%s', ...
        num2str(replace_elecs), ...
        num2str(ignore_elecs), ...
        num2str(overlap_elec)));
end

% Error check: When the user inputs electrodes not found in the input EEG dataset
missing_replace_elecss = setdiff(replace_elecs, [ORIEEG.chanlocs.urchan]);
if(~isempty(missing_replace_elecss))
    error(sprintf('Missing Replace Electrodes:\n\nThe following electrodes entered as input were missing from the EEG dataset:\n\t\t%s', ...
        num2str(missing_replace_elecss)));
end

% Warning check: Missing ignored electrodes in EEG dataset
missing_ignore_elecs = setdiff(ignore_elecs, [ORIEEG.chanlocs.urchan]);
if(~isempty(missing_ignore_elecs))
    warning(sprintf('Missing Ignored Electrodes:\n\nThe following electrodes entered as input were missing from the EEG dataset:\n\t%s', ...
        num2str(missing_ignore_elecs))); %#ok<SPWRN>
end


%%
EEG = ORIEEG;

% If no method specified: Spherical interpolate default
if nargin < 4
    disp('Using spherical interpolation');
    method = 'spherical';
end

%% Handle optional input variables
optargs = {false}; % Default optional inputs

% Put defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;     % if vargin is empty, optargs keep their default values. If vargin is specified then it overwrites

% Place optional args into variable names
[displayEEG] = optargs{:};



%%
if isstruct(replace_elecs)
    
    % add missing channels in interpolation structure
    % -----------------------------------------------
    lab1 = { replace_elecs.labels };
    tmpchanlocs = EEG.chanlocs;
    lab2 = { tmpchanlocs.labels };
    [~, tmpchan] = setdiff_bc( lab2, lab1);
    tmpchan = sort(tmpchan);
    if ~isempty(tmpchan)
        newchanlocs = [];
        fields = fieldnames(replace_elecs);
        for index = 1:length(fields)
            if isfield(replace_elecs, fields{index})
                for cind = 1:length(tmpchan)
                    fieldval = getfield( EEG.chanlocs, { tmpchan(cind) },  fields{index});
                    newchanlocs = setfield(newchanlocs, { cind }, fields{index}, fieldval);
                end;
            end;
        end;
        newchanlocs(end+1:end+length(replace_elecs)) = replace_elecs;
        replace_elecs = newchanlocs;
    end;
    if length(EEG.chanlocs) == length(replace_elecs), return; end;
    
    lab1          = { replace_elecs.labels };
    tmpchanlocs   = EEG.chanlocs;
    lab2          = { tmpchanlocs.labels };
    [~, badchans] = setdiff_bc( lab1, lab2);
    
    fprintf('Interpolating %d channels...\n', length(badchans));
    
    if isempty(badchans), return; end;
    goodchans      = sort(setdiff(1:length(replace_elecs), badchans));
    
    % re-order good channels
    % ----------------------
    [~, tmp2, neworder] = intersect_bc( lab1, lab2 );
    [~, ordertmp2] = sort(tmp2);
    neworder = neworder(ordertmp2);
    EEG.data = EEG.data(neworder, :, :);
    
    % looking at channels for ICA
    % ---------------------------
    %[~, sorti] = sort(neworder);
    %{ EEG.chanlocs(EEG.icachansind).labels; replace_elecs(goodchans(sorti(EEG.icachansind))).labels }
    
    % update EEG dataset (add blank channels)
    % ---------------------------------------
    if ~isempty(EEG.icasphere)
        
        [~, sorti] = sort(neworder);
        EEG.icachansind = sorti(EEG.icachansind);
        EEG.icachansind = goodchans(EEG.icachansind);
        EEG.chaninfo.icachansind = EEG.icachansind;
        
        % TESTING SORTING
        %icachansind = [ 3 4 5 7 8]
        %data = round(rand(8,10)*10)
        %neworder = shuffle(1:8)
        %data2 = data(neworder,:)
        %icachansind2 = sorti(icachansind)
        %data(icachansind,:)
        %data2(icachansind2,:)
    end;
    % { EEG.chanlocs(neworder).labels; replace_elecs(sort(goodchans)).labels }
    %tmpdata                  = zeros(length(replace_elecs), size(EEG.data,2), size(EEG.data,3));
    %tmpdata(goodchans, :, :) = EEG.data;
    
    % looking at the data
    % -------------------
    %tmp1 = mattocell(EEG.data(sorti,1));
    %tmp2 = mattocell(tmpdata(goodchans,1));
    %{ EEG.chanlocs.labels; replace_elecs(goodchans).labels; tmp1{:}; tmp2{:} }
    %EEG.data      = tmpdata;
    
    EEG.chanlocs  = replace_elecs;
    
else
    badchans  = replace_elecs;
    goodchans = setdiff_bc(1:EEG.nbchan, badchans);
    oldelocs  = EEG.chanlocs;
    EEG       = pop_select(EEG, 'nochannel', badchans);
    EEG.chanlocs = oldelocs;
    disp('Interpolating missing channels...');
end;

% find non-empty good channels
% ----------------------------
origoodchans  = goodchans;
chanlocs      = EEG.chanlocs;
nonemptychans = find(~cellfun('isempty', { chanlocs.theta }));


%% Remove ignored channels from interpolation computation
nonemptychans = setdiff_bc(nonemptychans, ignore_elecs);

[~, indgood ] = intersect_bc(goodchans, nonemptychans);
goodchans = goodchans( sort(indgood) );
datachans = getdatachans(goodchans,badchans);
badchans  = intersect_bc(badchans, nonemptychans);
if isempty(badchans), return; end;


%% Error check: Less than 2 good channels for interpolation
if length(goodchans) < 2
    feedback_str = [ ...
        sprintf('Cannot interpolate \t%.2d channels:\t', length(badchans)) ...
        sprintf(' %2.2d', badchans) ...
        '\n'...
        sprintf('using only\t\t%.2d channel(s):\t', length(goodchans)) ...
        sprintf(' %2.2d', goodchans) ...
        '\n' ...
        sprintf('skipping\t%.2d channels:\t', length(ignore_elecs))...
        sprintf(' %2.2d', ignore_elecs) ...
        '\n'];
    fprintf(feedback_str);
    error('Cannot interpolate with %d channels.\nEither make sure data set contains more than 2 channels \nAND that you are not ignoring too many channels', length(goodchans));
else
    % Print feedback to command window if error check passes
    feedback_str = [ ...
        sprintf('Interpolating \t%.2d channels:\t', length(badchans)) ...
        sprintf(' %2.2d', badchans) ...
        '\n'...
        sprintf('with\t\t%.2d channels:\t', length(goodchans)) ...
        sprintf(' %2.2d', goodchans) ...
        '\n' ...
        sprintf('skipping\t%.2d channels:\t', length(ignore_elecs))...
        sprintf(' %2.2d', ignore_elecs) ...
        '\n'];
    fprintf(feedback_str);
end


%% Warning check: Ignored bad channels
flatlinechans = intersect(replace_elecs, ignore_elecs);
if(~isempty(flatlinechans))
    warning('Warning: %d channels contain no data because they are interpolated with ignored channels: %s', length(flatlinechans), int2str(flatlinechans));
end


% scan data points
% ----------------
if strcmpi(method, 'spherical')
    % get theta, rad of electrodes
    % ----------------------------
    tmpgoodlocs = EEG.chanlocs(goodchans);
    xelec       = [ tmpgoodlocs.X ];
    yelec       = [ tmpgoodlocs.Y ];
    zelec       = [ tmpgoodlocs.Z ];
    rad         = sqrt(xelec.^2+yelec.^2+zelec.^2);
    xelec       = xelec./rad;
    yelec       = yelec./rad;
    zelec       = zelec./rad;
    tmpbadlocs  = EEG.chanlocs(badchans);
    xbad        = [ tmpbadlocs.X ];
    ybad        = [ tmpbadlocs.Y ];
    zbad        = [ tmpbadlocs.Z ];
    rad         = sqrt(xbad.^2+ybad.^2+zbad.^2);
    xbad        = xbad./rad;
    ybad        = ybad./rad;
    zbad        = zbad./rad;
    
    EEG.data    = reshape(EEG.data, EEG.nbchan, EEG.pnts*EEG.trials);
    %[~, tmp2, tmp3 tmpchans] = spheric_spline_old( xelec, yelec, zelec, EEG.data(goodchans,1));
    %max(tmpchans(:,1)), std(tmpchans(:,1)),
    %[~, tmp2, tmp3 EEG.data(badchans,:)] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(goodchans,:));
    [~, ~, ~, badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(datachans,:));
    %max(EEG.data(goodchans,1)), std(EEG.data(goodchans,1))
    %max(EEG.data(badchans,1)), std(EEG.data(badchans,1))
    EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
elseif strcmpi(method, 'spacetime') % 3D interpolation, works but x10 times slower
    disp('Warning: if processing epoch data, epoch boundary are ignored...');
    disp('3-D interpolation, this can take a long (long) time...');
    
    tmpgoodlocs     = EEG.chanlocs(goodchans);
    tmpbadlocs      = EEG.chanlocs(badchans);
    [xbad ,ybad]    = pol2cart([tmpbadlocs.theta],[tmpbadlocs.radius]);
    [xgood,ygood]   = pol2cart([tmpgoodlocs.theta],[tmpgoodlocs.radius]);
    pnts            = size(EEG.data,2)*size(EEG.data,3);
    zgood           = 1:pnts;
    zgood           = repmat(zgood, [length(xgood) 1]);
    zgood           = reshape(zgood,prod(size(zgood)),1); %#ok<*PSIZE>
    xgood           = repmat(xgood, [1 pnts]);
    xgood           = reshape(xgood,prod(size(xgood)),1);
    ygood           = repmat(ygood, [1 pnts]);
    ygood           = reshape(ygood,prod(size(ygood)),1);
    tmpdata         = reshape(EEG.data, prod(size(EEG.data)),1);
    zbad            = 1:pnts;
    zbad            = repmat(zbad, [length(xbad) 1]);
    zbad            = reshape(zbad,prod(size(zbad)),1);
    xbad            = repmat(xbad, [1 pnts]); xbad = reshape(xbad,prod(size(xbad)),1);
    ybad            = repmat(ybad, [1 pnts]); ybad = reshape(ybad,prod(size(ybad)),1);
    badchansdata    = griddata(ygood, xgood, zgood, tmpdata,...
        ybad, xbad, zbad, 'nearest'); % interpolate data
else
    % get theta, rad of electrodes
    % ----------------------------
    tmpchanlocs     = EEG.chanlocs;
    [xbad ,ybad]    = pol2cart([tmpchanlocs( badchans).theta], ...
        [tmpchanlocs( badchans).radius]);
    [xgood,ygood]   = pol2cart([tmpchanlocs(goodchans).theta], ...
        [tmpchanlocs(goodchans).radius]);
    badchansdata = zeros(length(badchans), ...
        size(EEG.data,2)*size(EEG.data,3));
    fprintf('Points (/%d):', size(EEG.data,2)*size(EEG.data,3));
    
    for t=1:(size(EEG.data,2)*size(EEG.data,3)) % scan data points
        if mod(t,100) == 0, fprintf('%d ', t); end;
        if mod(t,1000) == 0, fprintf('\n'); end;
        
        %for c = 1:length(badchans)
        %   [h EEG.data(badchans(c),t)]= topoplot(EEG.data(goodchans,t),EEG.chanlocs(goodchans),'noplot', ...
        %        [EEG.chanlocs( badchans(c)).radius EEG.chanlocs( badchans(c)).theta]);
        %end;
        tmpdata = reshape(EEG.data, size(EEG.data,1), size(EEG.data,2)*size(EEG.data,3) );
        if strcmpi(method, 'invdist'), method = 'v4'; end;
        [~,~,badchansdata(:,t)] = griddata(ygood, xgood , double(tmpdata(datachans,t)'),...
            ybad, xbad, method); %#ok<GRIDD> % interpolate data
    end
    fprintf('\n');
end;

tmpdata               = zeros(length(replace_elecs), EEG.pnts, EEG.trials);
tmpdata(origoodchans, :,:) = EEG.data;
%if input data are epoched reshape badchansdata for Octave compatibility...
if length(size(tmpdata))==3
    badchansdata = reshape(badchansdata,length(badchans),size(tmpdata,2),size(tmpdata,3));
end
tmpdata(badchans,:,:) = badchansdata;
EEG.data = tmpdata;
EEG.nbchan = size(EEG.data,1);
EEG = eeg_checkset(EEG);


%% Display input EEG plot to user with rejection windows marked
% Needs to occur before actually deleting the time segments in EEG
if displayEEG
    % Plot EEG data with to-be-rejected time windows
    
    eegplotoptions = { ...
        'events',       EEG.event,          ...
        'srate',        EEG.srate,          ...
        'winlength',    10};
    
    % Display channel labels instead of numbers
    if ~isempty(EEG.chanlocs)
        eegplotoptions = [ eegplotoptions {'eloc_file', EEG.chanlocs}];
    end;
    
    eegplot(EEG.data, eegplotoptions{:});   
    
end



%% Nested functions

function datachans = getdatachans(goodchans, badchans)
% Get data channels

datachans = goodchans;
badchans  = sort(badchans);
for index = length(badchans):-1:1
    datachans(find(datachans > badchans(index))) = ...
        datachans(find(datachans > badchans(index)))-1; %#ok<FNDSB>
end;

%% spherical splines
function [x, y, z, Res] = spheric_spline_old( xelec, yelec, zelec, values) %#ok<*DEFNU>

SPHERERES              = 20;
[x,y,z]                = sphere(SPHERERES);
x(1:(length(x)-1)/2,:) = []; x = x(:)';
y(1:(length(y)-1)/2,:) = []; y = y(:)';
z(1:(length(z)-1)/2,:) = []; z = z(:)';

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(x,y,z,xelec,yelec,zelec);

% equations are
% Gelec*C + C0  = Potential (C unknow)
% Sum(c_i) = 0
% so
%             [c_1]
%      *      [c_2]
%             [c_ ]
%    xelec    [c_n]
% [x x x x x]         [potential_1]
% [x x x x x]         [potential_ ]
% [x x x x x]       = [potential_ ]
% [x x x x x]         [potential_4]
% [1 1 1 1 1]         [0]

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values);
values = values - meanvalues; % make mean zero
C = pinv([Gelec;ones(1,length(Gelec))]) * [values(:);0];

% apply results
% -------------
Res = zeros(1,size(Gsph,1));
for j = 1:size(Gsph,1)
    Res(j) = sum(C .* Gsph(j,:)');
end
Res = Res + meanvalues;
Res = reshape(Res, length(x(:)),1);

function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values)

newchans = length(xbad);
numpoints = size(values,2);

%SPHERERES = 20;
%[x,y,z] = sphere(SPHERERES);
%x(1:(length(x)-1)/2,:) = []; xbad = [ x(:)'];
%y(1:(length(x)-1)/2,:) = []; ybad = [ y(:)'];
%z(1:(length(x)-1)/2,:) = []; zbad = [ z(:)'];

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C
% ---------------------------------
meanvalues = mean(values);
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results
% -------------
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);

% compute G function
% ------------------
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +...
    (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
    (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
%dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end;
            L(:,:,icol) = tmpL;
        end;
    end;
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);

