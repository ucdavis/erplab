% PURPOSE: splits channel array into left and right channels
%
% FORMAT:
%
% varargout = splitbrain(ERP, varargin)
%
%
% INPUT :
% ERP        -  Event Related Potential structure
%
% OUTPUT :
% MatChan    - Left and Right channels matched homotopically
%             MatChan(:,1):  Left channels
%             MatChan(:,1):  Right channels
%
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

function varargout = splitbrain(ERP, varargin)
if isempty(ERP)
        varargout{1} = [];
        varargout{2} = [];
        varargout{3} = [];
        msgboxText{1} =  'splitbrain() error: cannot work with an empty erpset!';
        tittle = 'ERPLAB: No data';
        errorfound(msgboxText, tittle);
        return
end
if isempty(ERP)
        varargout{1} = [];
        varargout{2} = [];
        varargout{3} = [];
        msgboxText{1} =  'splitbrain() error: cannot work with an empty erpset!';
        tittle = 'ERPLAB: No data';
        errorfound(msgboxText, tittle);
        return
else        
        if isfield(ERP.chanlocs,'labels')
                if isempty([ERP.chanlocs.labels])
                        msgboxText{1} =  'splitbrain() error: cannot work without 10/20 system channel labels!';
                        tittle = 'ERPLAB: No data';
                        errorfound(msgboxText, tittle);
                        varargout{1} = [];
                        varargout{2} = [];
                        varargout{3} = [];
                        return
                end
        else
                msgboxText{1} =  'splitbrain() error: cannot work without 10/20 system channel labels!';
                tittle = 'ERPLAB: No data';
                errorfound(msgboxText, tittle);
                varargout{1} = [];
                varargout{2} = [];
                varargout{3} = [];
                return
        end
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP', @isstruct);
p.addParamValue('Connector', '&', @ischar);
p.parse(ERP, varargin{:});

nchan     = ERP.nchan; %Total channels in your ERP
chanArray = 1:nchan; % for now...

%
% Separates channels into Label, channel number, channel pointer. Also skips channels without a
% number, for instance middle line channels (Fz, Cz, Pz, Oz, Iz, etc)
%
%
elecMat = {[]};
j = 1;

for i=1:nchan        
        [mt tk] = regexp(ERP.chanlocs(chanArray(i)).labels, '([a-z]+)(\d+)','ignorecase', 'match', 'tokens');        
        if size([tk{:}],2)==2
                elecMat{j,1} = char(tk{1}{1}) ;
                elecMat{j,2} = str2double(char(tk{1}{2})) ;
                elecMat{j,3} = chanArray(i) ;
                j = j + 1;
        else
                fprintf('Warning: Channels %g = %s was skipped.\n', chanArray(i), ERP.chanlocs(chanArray(i)).labels)
                tk = cell(1);
        end
end

%
% Makes couples of channels by labels, and skip non-coupled channels. Organization for further
% substraction.
%
elecMatSorted = {[]};
s=1;

for i=1:j-1
        isfirst = 1;
        if ~isempty(elecMat{i,1})
                
                % load a husband channel
                label01 = char(elecMat{i,1});
                s0 = s;
                
                for k=i+1:j-1                        
                        label02 = char(elecMat{k,1});                        
                        if strcmpi(label01, label02)                                
                                if isfirst
                                        elecMatSorted{s,1}   = label01;
                                        elecMatSorted{s,2}   = elecMat{i,2};
                                        elecMatSorted{s,3}   = elecMat{i,3};
                                        elecMatSorted{s+1,1} = label02;
                                        elecMatSorted{s+1,2} = elecMat{k,2};
                                        elecMatSorted{s+1,3} = elecMat{k,3};
                                        s=s+2;
                                        isfirst = 0;
                                else
                                        elecMatSorted{s,1} = label02;
                                        elecMatSorted{s,2} = elecMat{k,2};
                                        elecMatSorted{s,3} = elecMat{k,3};
                                        s=s+1;
                                end
                                
                                %
                                % deleting successfully found wife channel from the searching list
                                %
                                elecMat{k,1} = [];
                                elecMat{k,2} = [];
                                elecMat{k,3} = [];
                        end                        
                end                
                if isfirst
                        fprintf('Warning: Channels %s%d was skipped because it had not a partner.\n', label01, elecMat{i,2})
                else
                        %
                        % Sorting channel indexes from lesser to greater
                        %
                        auxforsort   = elecMatSorted(s0:s-1,2);
                        auxforsort   = [auxforsort{:}];
                        [indx, indx] = sort(auxforsort);
                        modindx = indx + s0 - 1;
                        [elecMatSorted(s0:s-1, :)] = deal(elecMatSorted(modindx, :));
                        
                        %
                        % deleting successfully found husband channel from the searching list
                        %
                        elecMat{i,1} = [];
                        elecMat{i,2} = [];
                        elecMat{i,3} = [];                        
                end
        end
end

%
% Separates channels into 2 matrixes: right hemispher (RH) and left hemisfer (LF)
%
m  = 1;
k  = 1;
RH = [];
LH = [];
rchlabel = {[]};
lchlabel = {[]};
nschan = size(elecMatSorted,1); % number of coupled channels
if nschan>1
        for i=1:nschan                
                chnumber = elecMatSorted{i,2};                
                if ~mod(chnumber,2)   % is even?                        
                        RH(k)= elecMatSorted{i,3};
                        rchlabel{k} = ERP.chanlocs(elecMatSorted{i,3}).labels;
                        k = k+1;                        
                elseif mod(chnumber,2) % is odd?
                        LH(m) = elecMatSorted{i,3};
                        lchlabel{m} = ERP.chanlocs(elecMatSorted{i,3}).labels;
                        m = m+1;
                end
        end
else
        LH = [];
        RH = [];
end
if nargout==1
        MatChan{1}(:,1)= LH;
        MatChan{1}(:,2)= RH;        
        for i=1:k-1
                MatChan{2}{i}= regexprep([lchlabel{i} p.Results.Connector rchlabel{i} ],'\s+','');
        end        
        varargout{1} = MatChan;
elseif nargout==2
        varargout{1} = LH;
        varargout{2} = RH;
elseif nargout==3
        varargout{1} = LH;
        varargout{2} = RH;
        for i=1:k-1
                varargout{3}{i}= regexprep([lchlabel{i} p.Results.Connector rchlabel{i} ],'\s+','');
        end
else
        error('ERPLAB says: error at splitbrain. It only works with 1, 2, or 3 varargouts')
end


