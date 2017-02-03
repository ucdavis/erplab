% PURPOSE: tests compatibility of old ERPset (ERP structure format)
%
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

function [ERP, conti, serror] = olderpscan(ERP, menup)

serror = 0;
conti  = 1;

if nargin<1
    help  olderpscan
    return
end
if nargin<2
    menup = 1;
end
try
    dataversion = ERP.version;
catch
    try
        dataversion = ERP.EVENTLIST.version;
    catch
        dataversion = '0';
    end
end

%
% Split data version numbering
%
[pspliter, dvdigits] = regexp(dataversion, '\.','match','split');
ndd = length(dvdigits);

if str2num(dvdigits{1}) >= 6
    % since v6.1.1, expect 3 digits 
    d_new_vers = 1;
else
    % Old format fallback
    d_new_vers = 0;
end

if d_new_vers == 1
    % since v6.1.1
    dformat     = 1; 
    
    dmayor      = str2num(dvdigits{1});
    dminor      = str2num(dvdigits{2});
    
    if ndd==2
        dmaintenance = 0;
    else
        dmaintenance= str2num(dvdigits{3});
    end
    
    ndd = 4; % with 4 args set, set 4 here for backwards-compatibility
end


if d_new_vers == 0
    if ndd==3
        dmayor       = str2num(dvdigits{1});
        dminor       = 0;
        dformat      = 0;
        dmaintenance = str2num(dvdigits{3});
    elseif ndd==4
        dmayor       = str2num(dvdigits{1});
        dminor       = str2num(dvdigits{2});
        dformat      = str2num(dvdigits{3});
        dmaintenance = str2num(dvdigits{4});
    elseif ndd>4
        msgboxText   =  sprintf('The version of your erpset: %s does not match with the ERPLAB''s version numbering A.B.C.D.', dataversion);
        title = 'ERPLAB: UNKNOWN DATA VERSION';
        errorfound(msgboxText, title)
        serror = 1;
        return
    else
        % unknow or very ooooold version, when Javier used to be shy
        dmayor       = 0;
        dminor       = 0;
        dformat      = -1;
        dmaintenance = 0;
    end
end

%
% Split ERPLAB current version numbering
%
cversion     = geterplabversion; % current erplab version
if isempty(cversion); return;end
[pspliter, cvdigits] = regexp(cversion, '\.','match','split');
cmayor       = str2num(cvdigits{1}); % A
cminor       = str2num(cvdigits{2}); % B


% For after v6, take format to be 1
if cmayor >= 6
    cformat      = 1; % C
    cmaintenance = str2num(cvdigits{3}); % D
    
else  % if older, get format from version
    cformat      = str2num(cvdigits{3}); % C
    cmaintenance = str2num(cvdigits{4}); % D
end

%
% Greater allowed version number :  999999999.999999999.999999999.999999999
%
dvnum = 1E15*dmayor + 1E12*dminor + 1E10*dformat + dmaintenance; % data version
cvnum = 1E15*cmayor + 1E12*cminor + 1E10*cformat + cmaintenance; % current version
try
    if (cvnum~=dvnum && ndd==4) || ndd~=4
        if cvnum<dvnum && ndd==4
            wordcomp = 'a newer';
        else
            wordcomp = 'an older';
        end
        
        %title    = ['ERPLAB: erp_loaderp() for version: ' dataversion] ;
        cerpname = ERP.filename;
        
        if isempty(cerpname)
            cerpname = ERP.erpname;
            if iscell(cerpname)
                cerpname = cerpname{1};
            end
        end
        if cformat~= dformat % different ERP structure was found
            fprintf('WARNING: Erpset %s was created from %s ERPLAB version.\n', cerpname, wordcomp);
            fprintf('WARNING: ERPLAB will attempt to update the ERP structure...\n');
            ERP.filename = '';
            ERP.filepath = '';
            ERP.saved    = 'no';
        else
            fprintf('WARNING: Erpset %s was created from %s ERPLAB version.\n', cerpname, wordcomp);
        end
    else
        % all right
        % fprintf('Erpset''s version is ok. \n');
    end
    
    % always check
    ERP = old2newerp(ERP, dataversion);
    %
    % Version 1.0.0
    %
    [ERP, serror] = sorterpstruct(ERP);
catch
    serror = 0;
end
return