% PURPOSE  : Taking N separate ERPsets, systematically computes grand averages on subsamples of N-1 ERPsets.
%            This means, each grand average has ommited 1 (different) ERPset.
%
% FORMAT   :
%
% ERP = pop_gaverager( ALLERP , Parameters);
%
%
% INPUTS   :
%
% ALLERP            - structure array of ERP structures (ERPsets)
%                     To read the ERPset from a list in a text file,
%                     replace ALLERP by the whole filename.
%
% The available parameters are as follows:
%
% 'Erpsets'         - index(es) pointing to ERP structures within ALLERP (only valid when ALLERP is specified)
% 'Criterion'       - Max allowed mean artifact detection proportion
% 'Weighted'        - 'on' means apply weighted-average, 'off' means classic average.
% 'SEM'           - Get standard deviation. 'on' or 'off'
% 'Erpname'         - name for being use at ERPset menu
% 'Filename         - file name for being saved at hard drive.
% 'Warning'         - Warning 'on' or 'off'
%
%
% OUTPUTS  :
%
% ALLERP            - data structure containing N+1 grand averages. First grand average (ALLERP(1)) contains the full grand average.
%                     The remaining N grand averages are coming from systematic subsamples of N-1 ERPsets.
%
%
% EXAMPLE  :
%
% ALLERP = pop_jkgaverager(ALLERP,'Erpsets',1:10,'Erpname','ERP_N1P1','Filename','ERP_N1P1','Warning','off')
%
% or
%
% ERP = pop_gaverager('C:\Users\Work\Documents\MATLAB\ERP_List.txt','Erpname','ERP_N1P1','Filename','ERP_N1P1','Warning', 'off')
%
%
% See also pop_gaverager
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Steven Luck
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

function [ALLERP, erpcom] = pop_jkgaverager(ALLERP, varargin)
erpcom = '';
if nargin<1
        help jkgaverager
        return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP');
% option(s)
p.addParamValue('ERPindex', []); % same as Erpsets
p.addParamValue('Erpsets', []);
p.addParamValue('Criterion', 1, @isnumeric); %  0-100 %
p.addParamValue('Weighted', 'off', @ischar);
p.addParamValue('SEM', 'off', @ischar);
p.addParamValue('Erpname', '', @ischar);
p.addParamValue('Filename', '', @ischar);
p.addParamValue('Warning', 'off', @ischar);

p.parse(ALLERP, varargin{:});

erpset = p.Results.Erpsets;
if isempty(erpset)
        erpset = p.Results.ERPindex;
end
cond1 = iserpstruct(ALLERP);
if isempty(erpset) && cond1
        error('ERPLAB says: "Erpsets" parameter was not specified.')
end
cond2 = isnumeric(erpset);

if cond1 && cond2 % either from GUI or script, when ALLERP exist and erpset indices were specified
        nfile   = length(erpset);
        optioni = 0; % from erpset menu or ALLERP struct
else
        optioni  = 1; % from file
        filelist = '';
        if iscell(ALLERP) % from the GUI, when ALLERP exist and user picks a list up as well
                filelist = ALLERP{2};
                ALLERP   = ALLERP{1};
        elseif ischar(ALLERP) % from script, when user picks a list.
                filelist = ALLERP;
                ALLERP   = [];
        else
                error('ERPLAB says: "Erpsets" parameter is not valid.')
        end
        if ~iscell(filelist) && ~isempty(filelist)
                disp(['For file-List, user selected ', filelist])
                
                %
                % open file containing the erp list
                %
                fid_list = fopen( filelist );
                formcell = textscan(fid_list, '%[^\n]','CommentStyle','#', 'whitespace', '');
                lista    = formcell{:};
                nfile    = length(lista);
                fclose(fid_list);
        else
                error('ERPLAB says: error at pop_appenderp(). Unrecognizable input ')
        end
end

% filelist = p.Results.Loadlist;

artcrite = p.Results.Criterion;
stdsstr  = p.Results.SEM;
erpname  = p.Results.Erpname;
filename = p.Results.Filename;
wavgstr  = p.Results.Weighted;

if ~isempty(filename)
        [pathstr, filename, ext] = fileparts(filename);
end

%
% Reads and sums ERPsets
%
preindex = length(ALLERP);
z0 = floor(log10(nfile)); % number of zeros

for k=0:nfile
        fprintf('\nWorking, please wait...\n');
        
        if optioni==1 % from file
                jklist   = lista(1:nfile~=k);
                nerp     = length(jklist);
                ALLERPX  = buildERPstruct([]);
                
                for m=1:nerp
                        ERPTX = load(jklist{m}, '-mat');                        
                        [ERPX, conti, serror] = olderpscan(ERPTX.ERP, 0);
                        
                        if serror || conti==0
                                msgboxText =  ['Your erpset %s is not compatible at all with the current ERPLAB version.\n'...
                                        'Please, try upgrading your ERP structure.'];
                                error(msgboxText);
                        end                       
                        ALLERPX(m)  = ERPX;
                end
                jkerpset = 1:nerp;                
                ERP = pop_gaverager(ALLERPX, 'Erpsets', jkerpset, 'Criterion', artcrite,...
                        'SEM', stdsstr, 'Weighted', wavgstr);
        else
                jkerpset = erpset(~ismember(1:nfile, k));
                ERP = pop_gaverager(ALLERP, 'Erpsets', jkerpset, 'Criterion', artcrite,...
                        'SEM', stdsstr, 'Weighted', wavgstr);
        end
        
        %
        % Erpname + suffix
        %
        if k>0
                zi    = z0 - floor(log10(k)); % number of characters - 1
                zstr  = repmat('0',1,zi);     % number of zeros to keep constant bin index lenght
                kindx = sprintf('%s%d', zstr, k);
        else
                kindx = repmat('0',1,z0+1);
        end
        
        ERP.erpname = sprintf('%s-%s', erpname, kindx);
        
        %
        % Save as
        %
        if ~isempty(filename)
                filenameHD = sprintf('%s-%s%s', filename, kindx, ext);
                fprintf('Saving ERPset #%d...\n', k);
                save(fullfile(pathstr, filenameHD), 'ERP');
        else
                fprintf('Uploading ERPset #%d...\n', k);
        end
        try
                if k==0 && isempty(ALLERP);
                        ALLERP = buildERPstruct([]);
                        ALLERP = ERP;
                else
                        ALLERP(k+1+preindex) = ERP;
                end
        catch
                msgboxText = 'A fatal problem was found while getting the ERPs';
                error('Error:jkgaverager', msgboxText);
        end
end

skipfields = {'ALLERP', 'Saveas', 'Warning','History'};
if isstruct(ALLERP) && optioni~=1 % from files
        DATIN =  inputname(1);
else
        %DATIN = ['''' ALLERP ''''];
        DATIN = sprintf('''%s''', filelist);
        skipfields = [skipfields, 'Erpsets'];
end
fn     = fieldnames(p.Results);
erpcom = sprintf( 'ALLERP = pop_jkgaverager( %s ', DATIN );
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
                                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        fnformat  = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat  = '%s';
                                end
                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);


