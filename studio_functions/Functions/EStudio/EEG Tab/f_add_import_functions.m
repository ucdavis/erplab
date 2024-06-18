%%This function is to add the path for eeglab plugins that has not been
%%added to Matlab path. PS: thanks for eeglab team


% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% June 2024


function f_add_import_functions()

eeglabp = fileparts(mywhich('eeglab.m'));

% scan plugin folder
% ------------------
dircontent  = dir(fullfile(eeglabp, 'plugins'));
if ~isfield(dircontent, 'folder')
    [dircontent(:).folder] = deal(fullfile(eeglabp, 'plugins'));
end
pluginlist  = [];
plugincount = 1;

onearg = 'rebuild';

pluginstats = [];
option_checkversion =1;
if option_checkversion && ismatlab
%     disp('Retrieving plugin versions from server...');
    try
        [pluginTmp, eeglabVersionStatus] = plugin_getweb('startup', pluginlist);
    catch
%         disp('Issue with retrieving statistics for extensions');
        pluginTmp = [];
    end
    if ~isempty(pluginTmp) && isfield(pluginTmp, 'name') && isfield(pluginTmp, 'version')
        pluginstats.name    = { pluginTmp.name };
        pluginstats.version = { pluginTmp.version };
    end
end


for index = 1:length(dircontent)
    
    % find function
    % -------------
    funcname = '';
    pluginVersion = [];
    if exist(fullfile(dircontent(index).folder, dircontent(index).name), 'dir')
        if ~strcmpi(dircontent(index).name, '.') && ~strcmpi(dircontent(index).name, '..')
            tmpdir = dir(fullfile(dircontent(index).folder, dircontent(index).name, 'eegplugin*.m'));
            
            if ~isempty(tmpdir)
                %myaddpath(eeglabpath, tmpdir(1).name, newpath);
                funcname = tmpdir(1).name(1:end-2);
            end
            addpathifnotinlist(fullfile(dircontent(index).folder, dircontent(index).name));
            [ pluginName, pluginVersion ] = parsepluginname(dircontent(index).name, funcname(11:end));
            
            % special case of subfolder for Fieldtrip
            % ---------------------------------------
            if ~isempty(findstr(lower(dircontent(index).name), 'fieldtrip')) && isempty(findstr(lower(dircontent(index).name), 'rest'))
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'compat') , 'electrodenormalize' );
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'forward'), 'ft_sourcedepth.m');
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'utilities'), 'ft_datatype.m');
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'plotting'), 'ft_plot_mesh.m');
                ptopoplot  = fileparts(mywhich('cbar'));
                ptopoplot2 = fileparts(mywhich('topoplot'));
                if ~isequal(ptopoplot, ptopoplot2)
                    addpath(ptopoplot);
                end
                % remove folders which should not have been added
                if ismatlab
                    tmppath = fullfile(dircontent(index).folder, dircontent(index).name, 'external');
                    if ~isempty(findstr(path, tmppath))
                        allpaths = path;
                        indperiod = [0 find(allpaths == ':') length(allpaths)+1 ];
                        for iPath = 1:length(indperiod)-1
                            curpath = allpaths(indperiod(iPath)+1:indperiod(iPath+1)-1);
                            if contains(curpath, tmppath)
                                fprintf('Removing path %s\n', curpath);
                                rmpath(curpath);
                            end
                        end
                    end
                end
            end
            
            % special case of subfolder for BIOSIG
            % ------------------------------------
            if ~isempty(findstr(lower(dircontent(index).name), 'biosig')) && isempty(strfind(lower(dircontent(index).name), 'biosigplot'))
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'biosig', 't200_FileAccess'), 'sopen.m');
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'biosig', 't250_ArtifactPreProcessingQualityControl'), 'regress_eog.m' );
                addpathifnotexist( fullfile(dircontent(index).folder, dircontent(index).name, 'biosig', 'doc'), 'DecimalFactors.txt');
            end
            
        end
    else
    end
    
end


function res = ismatlab

res = exist('OCTAVE_VERSION', 'builtin') == 0;


% add path only if it is not already in the list
% ----------------------------------------------
function addpathifnotinlist(newpath)

comp = computer;
if strcmpi(comp(1:2), 'PC')
    newpathtest = [ newpath ';' ];
else
    newpathtest = [ newpath ':' ];
end
p = path;
ind = strfind(p, newpathtest);
if isempty(ind)
    if exist(newpath) == 7
        addpath(newpath);
    end
end


function res = mywhich(varargin)
try
    res = which(varargin{:});
catch
    fprintf('Warning: permission error accessing %s\n', varargin{1});
end

function [name, vers] = parsepluginname(dirName, funcname)
ind = find( dirName >= '0' & dirName <= '9' );
if isempty(ind)
    name = dirName;
    vers = '';
else
    ind = length(dirName);
    while ind > 0 && ((dirName(ind) >= '0' && dirName(ind) <= '9') || dirName(ind) == '.' || dirName(ind) == '_')
        ind = ind - 1;
    end
    name = dirName(1:ind);
    vers = dirName(ind+1:end);
    vers(vers == '_') = '.';
    if ~isempty(vers)
        if vers(1) == '.', vers(1) = []; end
    end
end

% check with function name and change version if necessary (for loadhdf5)
if nargin > 1 && ~isempty(strfind(dirName, funcname))
    name1 = funcname;
    vers2 = dirName(length(funcname)+1:end);
    if ~isempty(vers2)
        vers2(vers2 == '_') = '.';
        if ~isequal(vers, vers2) ... % differebt versions
                && (vers2(1) >= '0' && vers2(1) <= '9') % version 2 is numerical
            vers = vers2;
        end
    end
end


function addpathifnotexist(newpath, functionname)
tmpp = mywhich(functionname);

if isempty(tmpp)
    addpath(newpath);
end

