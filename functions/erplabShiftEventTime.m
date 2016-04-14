function [ outEEG ] = erplabShiftEventTime(inEEG, eventcodes, timeshift, sample_rounding,  displayFeedback)
%ERPLABSHIFTEVENTTIME In EEG data, shift the timing of user-specified event codes.
%
% FORMAT
%
%    EEG = erplabShiftEventTime(inEEG, eventcodes, timeshift)
%
% INPUT:
%
%    EEG              EEGLAB EEG dataset
%    eventcodes       list of event codes to shift
%    timeshift        time in sec. If timeshift is positive, the EEG event code time-values are shifted to the right (e.g. increasing delay).
%                       - If timeshift is negative, the event code time-values are shifted to the left (e.g decreasing delay).
%                       - If timeshift is 0, the EEG's time values are not shifted.
%    rounding         Type of rounding to use
%                       - 'nearest'    (default) Round to the nearest integer          
%                       - 'floor'      Round to nearest ingtowards positive infinity
%                       - 'ceiling'    Round to nearest integer towards negative infinity
% 
% OPTIONAL INPUT:
%
%    displayFeedback  Type of feedback to display at Command window
%                        - 'summary'   (default) Print summarized info to Command Window
%                        - 'detailed'  Print event table with latency differences
%                        - 'both'      Print both summarized & detailed info
%
% OUTPUT:
%
%    EEG               EEGLAB EEG dataset with latency shift.
%
%
% EXAMPLE:
%
%     eventcodes = {'22', '19'};
%     timeshift  = 0.015;
%     rounding   = 'floor';
%     outputEEG  = erplabShiftEventTime(inputEEG, eventcodes, timeshift, rounding);
%     
%
% Requirements:
%   - EEG_CHECKSET (eeglab function)
%
% See also eegtimeshift.m erptimeshift.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Jason Arita
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
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


% Fill in optional variable.
switch nargin
    case 3
        sample_rounding = 'floor';
        displayFeedback = 'summary';
    case 4
        displayFeedback = 'summary';
end



outEEG              = inEEG;

% Convert the shift time into samples to shift
switch sample_rounding
    case 'floor'
        % Round to nearest ingtowards positive infinity
        sample_shift = floor(timeshift * inEEG.srate);  
    case 'ceiling'
        % Round to nearest integer towards negative infinity
        sample_shift = ceil(timeshift * inEEG.srate);   
    case 'nearest'
        % Round to the nearest integer
        sample_shift = round(timeshift * inEEG.srate);  
    otherwise
        error('Rounding method is unspecified. Should be either "floor", "ceiling", "nearest".');
end
            

% Convert EEG.data structure to a Matlab table
% in order to select the user-specified event code latency
eventsTable            = struct2table(inEEG.event);

% Convert event codes to a categorical variable type for selection
eventsTable.type       = categorical(eventsTable.type);
eventcodes             = categorical(eventcodes);

% Select latencies of the user-specified events and shift them
rows                   = ismember(eventsTable.type, eventcodes);
vars                   = {'latency'};
eventsTable{rows,vars} = eventsTable{rows,vars}+sample_shift;

% Save the shifted events/latencies back into the EEGLAB EEG dataset
eventsTable.type       = char(eventsTable.type);
outEEG.event           = table2struct(eventsTable)';

% check for out of bound events / Re-sort ur events
outEEG = eeg_checkset(outEEG, 'eventconsistency', 'checkur');




%% Detailed Feedback
if(strcmpi(displayFeedback, 'detailed') || strcmpi(displayFeedback,'both'))
    eventtable_input            = struct2table(inEEG.event);
    eventtable_output           = struct2table(outEEG.event);
    eventtable_output.urevent   = [];
    eventtable_output.duration  = [];
    latency_diff                = (  eventtable_output.latency ...
        - eventtable_input.latency  );
    time_diff                   = latency_diff * (1/inEEG.srate);
    
    eventtable_output = [ eventtable_output ...
                         table(eventtable_input.latency ...
                         ,'VariableNames', {'original_latency'}) ...
                         table(latency_diff) ...
                         table(time_diff)  ];
    disp(eventtable_output);
end
    



%% Summarized Feedback
if(strcmpi(displayFeedback, 'summary') || strcmpi(displayFeedback, 'both'))
    numEventCodesShifted = height(eventsTable(rows,:));
    numEventCodes        = height(eventsTable);
    
    fprintf('%7d of %7d event codes shifted %+2.3f seconds\n\n' ...
        , numEventCodesShifted ...
        , numEventCodes ...
        , timeshift);
end




