% PURPOSE  : 	Makes a figure with artifact detection summary
%
% FORMAT   :
%
% Pop_summary_rejectfields(EEG)
%
% EXAMPLE  :
%
% Pop_summary_rejectfields(EEG)
%
% INPUTS   :
%
% EEG	- EVENTLIST structure added to current EEG structure or workspace
%
% OUTPUTS  :
%
% Figure of Artifact Detection Summary
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
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

function  [EEG, goodbad, histeEF, histoflagsAR,  com] = pop_summary_rejectfields(EEG, varargin)
com = '';
goodbad      = [];
histoflagsAR = [];
histeEF      = [];

if nargin<1
        help pop_summary_rejectfields
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        mtitle = 'ERPLAB: multiple inputs';
        errorfound(msgboxText, mtitle);
        return
end
if isempty(EEG.epoch)
        msgboxText =  'summary_rejectfields() only works with bin-epoched dataset.';
        mtitle     = 'ERPLAB: summary_rejectfields';
        errorfound(msgboxText, mtitle);
        return
end

F = fieldnames(EEG.reject);
sfields1 = regexpi(F, '\w*E$', 'match');
sfields2 = [sfields1{:}];
rfields  = regexprep(sfields2,'E','');
nfield   = length(sfields2);
histE    = zeros(EEG.nbchan, EEG.trials);
histT    = zeros(1, EEG.trials);
fonts    = 10;

for i=1:nfield
        fieldnameE = char(sfields2{i});
        fieldnameT = char(rfields{i});
        
        if ~isempty(EEG.reject.(fieldnameE))
                histE = histE | [EEG.reject.(fieldnameE)]; %electrodes
                histT = histT | [EEG.reject.(fieldnameT)]; %trials (epochs)
        end
end

hfAR = sum(summary_rejectflags(EEG),1);
histoflagsAR = fliplr(hfAR(1:8));

figure('Name',['ERPLAB: ARTIFACT DETECTION SUMMARY >> ' EEG.setname],'NumberTitle','off','Color', [1 1 1])
histeEF = sum(histE,2)';
histeTF = sum(histT,2);
K   = 0.5;
x   = [1 2];
y1  = [EEG.trials-histeTF 0];
y2  = [0 histeTF];

goodbad = [y1(1) y2(2)];
Ttop = EEG.trials;

%--------------------------------------------------------------------------------------------------
subplot(3,1,1)
bar1 = bar(x, y1, 'FaceColor', 'b', 'EdgeColor', 'k');
ylabel('# of epochs')
set(bar1,'BarWidth',K);
nacce = y1(1);
pacce = (nacce/Ttop)*100;
text(0.9,y1(1)+Ttop*0.05,[sprintf('%g (%.1f)', nacce, pacce) '%'],'FontSize',11)
hold on;
bar2 = bar(x, y2, 'FaceColor', 'r', 'EdgeColor', 'k');
set(bar2,'BarWidth',K);

nrej = y2(2);
prej = (nrej/Ttop)*100;
text(1.9,y2(2)+Ttop*0.05,[sprintf('%g (%.1f)',nrej, prej) '%'],'FontSize',11)
legend('Accepted','Rejected')
axis([0 3 0 Ttop*1.1])
ylabel('% of total epochs')
set(gca,'FontSize',fonts,'TickLength', [0 0])
title('Summary','FontSize',16)

%--------------------------------------------------------------------------------------------------
subplot(3,1,2)
bar(1:EEG.nbchan, histeEF, 'FaceColor', [1  0  0], 'EdgeColor', 'k')
ylabel('# of epochs')
axis([0 EEG.nbchan+1 0 Ttop*1.1])
set(gca,'XTick',1:EEG.nbchan,'TickLength', [0 0])
try chalab = {EEG.chanlocs.labels}; catch chalab = cellstr(num2str(1:EEG.nbchan)); end
set(gca,'XTickLabel', chalab)
set(gca,'FontSize',fonts)
title('Amount of  marked epochs per channel','FontSize',16)
legend('Channel with artifacts')
for c=1:EEG.nbchan
        text(c-K/2,histeEF(c)+Ttop*0.05,[sprintf('%.1f',(histeEF(c)/Ttop)*100) '%'],'FontSize',fonts)
end

%--------------------------------------------------------------------------------------------------
nflag = 8; % for Artifact detection -> only lower 8 flags
subplot(3,1,3)
bar(1:nflag, histoflagsAR);
ylabel('# of epochs')
axis([0 nflag+1 0 Ttop])
set(gca,'XTick',1:nflag,'TickDir', 'out')
F = num2cell(nflag:-1:1); flaglab = eval(['{' sprintf('''Flag%g'' ',F{:}) '};']);
set(gca,'XTickLabel', flaglab,'TickLength', [0 0])
set(gca,'FontSize',fonts)
title('Amount of flaged epochs per flag','FontSize',16)
legend('Flags')

for c=1:nflag
        nfx = histoflagsAR(c);
        pp  = (nfx/Ttop)*100;
        text(c-K/2,histoflagsAR(c)+Ttop*0.05,[sprintf('%g (%.1f)', nfx, pp) '%'],'FontSize',fonts)
end

set(gcf,'PaperPositionMode','auto')
com = sprintf('pop_summary_rejectfields(%s)', inputname(1));
% com = sprintf('%s %% %s', com, datestr(now));

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
                %EEG = erphistory(EEG, [], com, 1);
                %fprintf('%%%Equivalent command:\n%s\n\n', com);
        otherwise %off or none
                com = '';
                return
end

%
% Completion statement
%
msg2end
return