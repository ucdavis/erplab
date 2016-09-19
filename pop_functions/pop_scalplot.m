% PURPOSE  :	Plots ERP Scalp Maps
%
% FORMAT   :
%
% pop_scalplot( ERP, binArray, latencyArray, parameters );
%
%
% INPUTS     :
%
% ERP               - input ERPset
% binArray          - index(es) of bin(s) to plot. e.g [ 4:2:24]
% latencyArray      - index(es) of latency(ies) to plot in ms (300 or -100:10:0 or  120 400)
%
% The available parameters are as follows:
%
%         'Blc'              - Baseline Correction
%                                     -'none'
%                                     -'pre'
%                                     -'post'
%                                     -'all'
%         'Value'             - Value to plot
%                                     -'insta'           - Instantaneous amplitude (needs 1 latency value)
%                                     -'mean'            - Mean amplitude between two fixed latencies
%                                     -'area' or 'areat' - Total area between two fixed latencies (positive and negative areas.
%                                                          (negative areas are took as positive)
%                                     -'areap'           - Area under the positive values of the curve, between two latencies.
%                                                          (negatives' ignored)
%                                     -'arean'           - Area under the negative values of the curve, between two latencies.
%                                                          (positives' ignored)
%                                     -'ninteg'          - Numerical integration of the curve, between two latencies.
%                                                          (negative areas are substracted from positives').
%                                     -'instalapla'      - Instantaneous amplitude Laplacian (needs 1 latency value)
%                                     -'meanlapla'       - Mean amplitude Laplacian between two fixed latencies
%         'Maptype'           - '2D' or '3D'
%
%         'Mapstyle'          - 'map'      -> plot colored map only
%                               'contour'  -> plot contour lines only
%                               'both'     -> plot both colored map and contour lines
%                               'fill'     -> plot constant color between contour lines
%                               'blank'    -> plot electrode locations only {default: 'both'}
%
%         'Maplimit'          - 'maxmin', 'absmax', or [custom_min custom_max]- Enter own numbers for min and max
%         'Mapview'           - direction of nose or camera viewpoint in degrees [azimuth elevation]. default [143 18]
%                                       'back'      = [0 30]
%                                       'front'     = [180 30]
%                                       'left'      = [-90 30]
%                                       'right'     = [90 30]
%                                       'frontleft' =
%                                       'backright' =
%                                       'top'       = [0 90],
%                                        Can rotate with mouse.
%
%         'Animated'          - 'on'/'off'. Create Animated GIF
%         'Filename'          - pathname and name of file that AGIF will be saved in
%         'AdjustFirstFrame'  - when creating an animated GIF allows to adjust the size of the first frame.'on'/'off'
%         'Quality'           - when creating and AVI movie a number between 0 and 100. Higher quality numbers result in
%                               higher video quality and larger file sizes. Lower quality numbers result in lower video
%                               quality and smaller file sizes. Valid only for compressed movies.
%         'Compression'       - A text string specifying the compression codec to use. To create an uncompressed file, specify a value of 'None'.
%                               On UNIX operating systems, the only valid value is 'None'.On Windows systems, valid values include:'MSVC','RLE',
%                               'Cinepak' on 32-bit systems. 'Indeo3' or 'Indeo5' on 32-bit Windows XP systems. Alternatively, specify a custom
%                               compression codec on Windows systems using the four-character code that identifies the codec (typically included
%                               in the codec documentation). If MATLAB cannot find the specified codec, it returns an error.%
%         'Colorbar'          - display colorbar. 'on'/'off'
%         'FontSize'          - Font size for legends and labels
%         'FPS'               - Frames per second.
%         'Electrodes'        - display electrodes. 'on'/'off'
%         'Legend'            - 'bn-bd-me-lat'. bin number (bn), bin desc (bd), measure (me), latency (la)
%         'Maximize'          - maximize whole figure. 'on'/'off'
%         'Position'          - set figure's position
%         'Splinefile'        - name of spline file to save/read spline info into.
%
%
% OUTPUTS
%
% figure on the screen
%
%
% EXAMPLE :
%
% pop_scalplot( ERP,1,0:50 , 'Animated', 'on', 'Filename','C:\Users\Work\Documents\MATLAB\test.gif', 'Blc', 'pre',...
% 'Electrodes','on', 'FontSize',10, 'Legend', 'bn-la', 'Maplimit', 'maxmin', 'Maptype', '2D','Mapview', '+X', 'Value', 'instsa');
%
% See also scalplotGUI.m topoplot.m headplot.m pop_ploterps.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon % Sam London & Steve Luck
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

function [ERP, erpcom] = pop_scalplot(ERP, binArray, latencyArray, varargin)
erpcom = '';
if nargin < 1
        help pop_scalplot
        return
end
if nargin==1
        if isempty(ERP)
                ERP = preloadERP;
                if isempty(ERP)
                        msgboxText =  'No ERPset was found!';
                        title_msg  = 'ERPLAB: pop_scalplot() error:';
                        errorfound(msgboxText, title_msg);
                        return
                end
        end
        if ~isfield(ERP, 'bindata')
                msgboxText =  'Error: pop_scalplot cannot operate an empty ERP dataset';
                title_msg  = 'ERPLAB: pop_scalplot() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if isempty(ERP.bindata)
                msgboxText =  'Error: pop_scalplot cannot operate an empty ERP dataset';
                title_msg  = 'ERPLAB: pop_scalplot() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        %
        % Searching channel location
        %
        if isfield(ERP.chanlocs, 'theta') && ~isempty([ERP.chanlocs.theta])
                [ERP, serror] = borrowchanloc(ERP);
        else
                question = ['This averaged ERP has not channel location info.\n'...
                        'Would you like to load it now?'];
                title_msg   = 'ERPLAB: Channel location';
                button   = askquest(sprintf(question), title_msg);
                if ~strcmpi(button,'yes')
                        disp('User selected Cancel')
                        return
                else
                        [ERP, serror] = borrowchanloc(ERP);
                end
                if ~isempty(serror) && serror==0
                        ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
                end
        end
        if isempty(serror)
                disp('User selected Cancel')
                return
        end
        if serror~=0
                msgboxText = ['pop_scalplot could not find channel locations info.\n\n'...
                        'Hint: Identify channel(s) without location looking at '...
                        'command window comments (Channel lookup). Try again excluding this(ese) channel(s).'];
                tittle = 'pop_scalplot:  error:';
                errorfound(sprintf(msgboxText), tittle);
                return
        end
        
        %
        % Call GUI
        %
        [plotset, ERP] = scalplotGUI(ERP, ERP.chanlocs); %GUI
        
        if isempty(plotset.pscalp)
                disp('User selected Cancel')
                return
        elseif strcmpi(plotset.pscalp,'pdf')
                %erpcom2 = pop_fig2pdf;
                [ERP, erpcom2] = pop_exporterplabfigure(ERP);
                %                         if countp>0
                disp('pop_exporterplabfigure was called')
                %                         else
                %                                 disp('WARNING: Matlab figure(s) might have been generated during a previous round....')
                %                         end
                erpcom = [erpcom ' ' erpcom2];
                return
        elseif strcmpi(plotset.pscalp,'time')
                disp('User called pop_ploterps()')
                return
        end
        
        plotset.pscalp.binArray  = plotset.pscalp.binArray(plotset.pscalp.binArray<=ERP.nbin);
        
        if ~isfield(plotset.pscalp, 'posfig')
                plotset.pscalp.posfig = [];
        end
        
        findplot = findobj('Tag','Scalp_figure');
        
        if ~isempty(findplot)
                lastfig    = figure(findplot(1));
                posfx = get(lastfig,'Position');
                plotset.pscalp.posfig = [posfx(1)+10 posfx(2)-15 posfx(3) posfx(4) ];
        end
        
        %
        % read plotset into variables
        %
        binArray     = plotset.pscalp.binArray;
        latencyArray = plotset.pscalp.latencyArray;
        measurestr   = plotset.pscalp.measurement;
        baseline     = plotset.pscalp.baseline;
        maplimit     = plotset.pscalp.cscale;
        ismoviex     = plotset.pscalp.agif.value;
        FPS          = plotset.pscalp.agif.fps;
        fullgifname  = plotset.pscalp.agif.fname;
        posfig       = plotset.pscalp.posfig;
        mtype        = plotset.pscalp.mtype;   % map type: 2D or 3D
        smapstyle    = plotset.pscalp.smapstyle;   % map style: 'fill' 'both' 
        mapoutside   = plotset.pscalp.mapoutside;
        mapview      = plotset.pscalp.mapview;
        splineinfo   = plotset.pscalp.splineinfo;
        plegend      = plotset.pscalp.plegend;
        binleg       = plegend.binnum;         % show bin number at legend
        bindesc      = plegend.bindesc;        % show bin description at legend
        vtype        = plegend.type ;          % show type of measurement at legend
        vlatency     = plegend.latency;        % show latency(ies) at legend
        showelec     = plegend.electrodes;     % show electrodes on scalp
        elestyle     = plegend.elestyle  ;     %         
        elec3D       = plegend.elec3D;
        clrbar       = plegend.colorbar;       % show color bar
        ismaxim      = plegend.maximize;       % show color bar
        clrmap       = plegend.colormap;       % show color bar
        
        if strcmpi(mtype, '3d')
                %                 if isempty(ERP.splinefile)
                %                         if isempty(splineinfo.path)
                %                                 splinefile = fullfile(cd(), 'temp_splinefile');%default temp spline
                %                         else
                %                                 splinefile = splineinfo.path;
                %                         end
                %                 else
                %                         splinefile = ERP.splinefile;
                %                 end
                if isempty(ERP.splinefile) && isempty(splineinfo.path)
                        %disp('A')
                        msgboxText =  ['Current ERPset is not linked to any spline file.\n'...
                                'At the Scal plot GUI, use "spline file" button, under the Map type menu, to find/create one.'];
                        title_msg  = 'ERPLAB: pop_scalplot() missing info:';
                        errorfound(sprintf(msgboxText), title_msg);
                        return
                elseif isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        %if splineinfo.new==1
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        %        splineinfo.new = 0;
                        %plotset.pscalp.splineinfo = splineinfo;
                        %end
                        %if splineinfo.save
                        %        ERP.splinefile = splineinfo.path;
                        %        ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
                        %        erplab redraw
                        %        splineinfo.save = 0;
                        %        %plotset.pscalp.splineinfo = splineinfo;
                        %end
                        splinefile = splineinfo.path;
                        %disp('A2')
                elseif ~isempty(ERP.splinefile) && ~isempty(splineinfo.path)
                        headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        splinefile = splineinfo.path;
                        %disp('B')
                        
                        %                         if splineinfo.new==1
                        %                                 headplot('setup', ERP.chanlocs, splineinfo.path); %Builds the new spline file.
                        %                                 splineinfo.new = 0;
                        %                                 %plotset.pscalp.splineinfo = splineinfo;
                        %                         end
                        %                         if splineinfo.save
                        %                                 question = ['This ERPset already has spline file info.\n'...
                        %                                         'Would you like to replace it?'];
                        %                                 title_msg   = 'ERPLAB: spline file';
                        %                                 button   = askquest(sprintf(question), title_msg);
                        %
                        %                                 if ~strcmpi(button,'yes')
                        %                                         disp('User selected Cancel')
                        %                                         return
                        %                                 else
                        %                                         ERP.splinefile = splineinfo.path;
                        %                                         ERP = pop_savemyerp(ERP, 'gui', 'erplab', 'History', 'off');
                        %                                         erplab redraw
                        %                                 end
                        %                         end
                        %                         splinefile = splineinfo.path;
                else
                        %disp('C')
                        splinefile = ERP.splinefile;
                end
        else
                %splinefile = '';
                splinefile = ERP.splinefile;
                %disp('D')
        end
        
        %
        % save plotset at command window
        %
        assignin('base','plotset', plotset);
        
        if clrbar==1
                colorbari = 'on';
        else
                colorbari = 'off';
        end        
        if mapoutside==1   % 'plotrad',mplotrad,
                mplotrad = [];
        else
                mplotrad = 0.55;
        end
        
        %'jet|hsv|hot|cool|gray'
        switch clrmap
                case 1
                        cmap = 'jet';
                case 2
                        cmap = 'hsv';
                case 3
                        cmap = 'hot';
                case 4
                        cmap = 'cool';
                case 5
                        cmap = 'gray';
                otherwise
                        cmap = 'jet';
        end
        if ismoviex==0
                ismoviexx = 'off';
                aff     = 'off'; % adjust first frame (aff)
        else
                if ismoviex==1
                        aff = 'off'; % adjust first frame (aff)
                else
                        aff = 'on';
                end
                ismoviexx = 'on';
        end
        if binleg==1
                binlegx = 'on';
        else
                binlegx = 'off';
        end
        if showelec==1
                showelecx = elestyle;
        else
                showelecx = 'off';
        end
        if ismaxim==1
                maxim = 'on';
        else
                maxim = 'off';
        end
        
        % legend
        logstring = ['bn'*binleg '-'*binleg 'bd'*bindesc '-'*bindesc 'me'*vtype '-'*vtype 'la'*vlatency];
        logstring = nonzeros(logstring)';
        mapleg    = strtrim(char(logstring));
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_scalplot(ERP, binArray, latencyArray, 'Value', measurestr, 'Blc', baseline, 'Maplimit', maplimit, 'Colorbar', colorbari,...
                'Colormap', cmap,'Animated', ismoviexx, 'AdjustFirstFrame', aff, 'FPS', FPS, 'Filename', fullgifname, 'Legend', mapleg, 'Electrodes', showelecx,...
                'Position', posfig, 'Maptype', mtype, 'Mapstyle', smapstyle, 'Plotrad', mplotrad,'Mapview', mapview, 'Splinefile', splinefile,...
                'Maximize', maxim, 'Electrodes3d', elec3D,'History', 'gui');
        pause(0.1)
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP', @isstruct);
p.addRequired('binArray', @isnumeric);
p.addRequired('latencyArray', @isnumeric);
p.addParamValue('Value', 'insta', @ischar);
p.addParamValue('Blc', 'none');
p.addParamValue('Maplimit', 'maxmin');
p.addParamValue('Colorbar', 'on', @ischar);
p.addParamValue('Colormap', 'jet', @ischar);
p.addParamValue('FontSize', 10, @isnumeric);
p.addParamValue('FontName', 'Courier New', @ischar);
p.addParamValue('Animated', 'off', @ischar);
p.addParamValue('AdjustFirstFrame', 'off', @ischar);
p.addParamValue('FPS', 1, @isnumeric);
p.addParamValue('Filename', [], @ischar);
p.addParamValue('VideoIntro', 'erplab', @ischar);
p.addParamValue('Quality', 60, @isnumeric); % number between 1 and 100
p.addParamValue('Compression', 'none', @ischar);
p.addParamValue('Electrodes', 'on', @ischar);
p.addParamValue('Electrodes3d', 'off', @ischar);
p.addParamValue('Legend', 'bn-la', @ischar); % all -> 'bn-bd-me-lat' (at legend:bin number (bn), bin desc (bd), measure (me), latency (la))
p.addParamValue('Maximize', 'off', @ischar); % off | on
p.addParamValue('Position', [], @isnumeric);
p.addParamValue('Maptype', '2D', @ischar); % 
p.addParamValue('Mapstyle', 'both', @ischar); % 'fill' 'both'
p.addParamValue('Plotrad', 0.55, @isnumeric); % 'fill' 'both'
p.addParamValue('Mapview', '+X');
p.addParamValue('Splinefile', '', @ischar);
p.addParamValue('Chanlocfile', '', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(ERP, binArray, latencyArray, varargin{:});

datatype = checkdatatype(ERP);

if strcmpi(datatype, 'ERP')
        kktime = 1000;
        srate = ERP.srate;
else
        kktime = 1;
        srate = ERP.pnts/ERP.xmax;
end

%
% Searching channel location
%
serror = 0;
chanlocfile = p.Results.Chanlocfile;
if isempty(chanlocfile)
        if isfield(ERP.chanlocs, 'theta')
                [ERP, serror] = borrowchanloc(ERP);
        else
                msgboxText =  'No channel location found.';
                error(msgboxText);
        end
else
        [ERP, serror] = borrowchanloc(ERP, chanlocfile);
end
if serror~=0
        msgboxText = 'ERPLAB says: pop_scalplot could not load channel locations info.';
        error(msgboxText);
end
if length(latencyArray)>ERP.pnts
        msgboxText =  'ERPLAB says: latency array cannot be longer than number of points';
        error(msgboxText)
end
if max(binArray)>ERP.nbin
        msgboxText =  ['Bin(s) %g do(es) not exist within this erpset.\n'...
                'Please, check your bin list'];
        error(sprintf(msgboxText, chanArray(chanArray>ERP.nchan)));
end
if min(binArray)<1
        msgboxText =  ['Invalid bin indexing.\n'...
                'Bin index(ices) must be positive integer(s) but zero.'];
        error(sprintf(msgboxText, ERP.erpname));
end

measurestr  = p.Results.Value;
baseline    = p.Results.Blc;
maplimit    = p.Results.Maplimit;
colorbari   = p.Results.Colorbar;
cmap        = p.Results.Colormap;
ismoviexx   = p.Results.Animated;
FPS         = p.Results.FPS;
fullgifname = p.Results.Filename;
quality     = p.Results.Quality;
compression = p.Results.Compression;
vname       = p.Results.VideoIntro;

if strcmpi(colorbari,'on')
        clrbar = 1;
else
        clrbar = 0;
end
if strcmpi(ismoviexx,'on')
        ismoviex = 1;
        if strcmpi(p.Results.AdjustFirstFrame,'on')
                %ismoviex = 2;
                adj1frame = 1;
        else
                %ismoviex = 1;
                adj1frame = 0;
        end
        
        [pth, fn, ext] = fileparts(fullgifname);
        if strcmpi(ext,'.gif')
                movtype = 'gif';
        elseif strcmpi(ext,'.mat')
                movtype = 'mat';
        elseif strcmpi(ext,'.avi')
                movtype = 'avi';
        else
                error('invalid file format')
        end
else
        ismoviex  = 0;
        movtype   = '';
        adj1frame = 0;
end

elestyle   = p.Results.Electrodes;
elec3D     = p.Results.Electrodes3d;
% if strcmpi(showelecx,'on')
%         showelec = 1;
% else
%         showelec = 0;
% end
posfig      = p.Results.Position;
mtype       = lower(p.Results.Maptype);
smapstyle   = lower(p.Results.Mapstyle);
mapview     = lower(p.Results.Mapview);
mplotrad    = lower(p.Results.Plotrad);
splinefile  = p.Results.Splinefile;
fontsizel   = p.Results.FontSize;
fontnamel   = p.Results.FontName;

if strcmpi(p.Results.Maximize,'on')
        ismaxim = 1;
else
        ismaxim = 0;
end

legstr = p.Results.Legend;
aa = regexp(legstr, 'bn|bd|me|la', 'match');
bb = num2cell(ismember_bc2({'bn','bd','me','la'}, aa));
[binleg, bindesc, vtype, vlatency] = deal(bb{:});

if isempty(ERP.splinefile) && isempty(splinefile) && strcmpi(mtype, '3d')
        error('ERPLAB says: no spline file info was found.')
end

indxh   = find(latencyArray>ERP.xmax*kktime,1);
if ~isempty(indxh)
        msgboxText =  ['Latency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(ERP.xmax*kktime) ' msec!'];
        error(msgboxText);
end
indxl  = find(latencyArray<ERP.xmin*kktime,1);
if ~isempty(indxl)
        msgboxText =  ['Latency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(ERP.xmin*kktime) ' msec!'];
        error(msgboxText);
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
% Numeric map view, since headplot is not yet working with strings for view...
%
if ischar(mapview)
        switch mapview
                case {'front','f'}
                        mview = [-180,30];
                case {'back','b'}
                        mview = [0,30];
                case {'left','l'}
                        mview =  [-90,30];
                case {'right','r'}
                        mview =  [90,30];
                case {'frontright','fr'}
                        mview =  [135,30];
                case {'backright','br'}
                        mview =  [45,30];
                case {'frontleft','fl'}
                        mview =  [-135,30];
                case {'backleft','bl'}
                        mview =  [-45,30];
                case 'top'
                        mview =  [0,90];
                otherwise
                        mview =  [0,90];
        end
else
        % parsing is pending. JLC
        mview = mapview;
end

toffsa    = abs(round(ERP.xmin*srate))+1;
latArray  = round(latencyArray.*srate/kktime) + toffsa;   %sec to samples
nbin      = length(binArray);

if strcmp(measurestr, 'insta') || strcmp(measurestr, 'instalapla')
        nlat = size(latArray,2);  % only one row array should be defined. e.g. 120 or [0 50 120 350]
else
        nlat = size(latArray,1);  % couples of latencyes can be defined. e.g [50 100; 120 350; 400 600]
end
% if showelec==1
%         showe = 'on';
% else
%         showe = 'off';
% end

wi   = 0.9/nlat;
hi   = 0.9/nbin;
bdwidth = 30; topbdwidth = 30;
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
pos1    = [bdwidth, (1/3)*scnsize(4) + bdwidth, scnsize(3)/4 - 2*bdwidth, scnsize(4)/3 - (topbdwidth + bdwidth)];

%
% If there is a previous "scal map" figure open, then "steal" its dimensions, otherwise set it as default
%
find2 = findobj('Tag','Scalp_figure');
if ~isempty(find2)
        %fig2    = figure(find2(end));
        pos2 = get(find2,'Position');
        pos2 = pos2(1,:);
else
        pos2 = [bdwidth, (1/5)*scnsize(4) + bdwidth, scnsize(3)/2, 0.7*scnsize(4)];
end
if isempty(ERP.erpname)
        fnamet = 'none';
else
        [pathstrt, fnamet, extt] = fileparts(ERP.erpname) ;
end
if ismoviex==0
        if strcmpi(datatype, 'ERP')
                hsig = figure('Position',pos1, 'Name',['<< ' fnamet ' >>  Plot ERP map by Bins x latency'],...
                        'NumberTitle','on', 'Tag','Scalp_figure');erplab_figtoolbar(hsig, mtype);
        else % FFT
                hsig = figure('Position',pos1, 'Name',['<< ' fnamet ' >>  Plot ERP map by Bins x frequency'],...
                        'NumberTitle','on', 'Tag','Scalp_figure');erplab_figtoolbar(hsig, mtype);
        end
        
        if ~isempty(posfig)
                set(hsig, 'Position', posfig)
        end
        nadj = 1;
        if ismaxim == 1;
                maximize(hsig)
        end
else
        secondframe = 1;
        fra = 1;
        if adj1frame==1  % adjust first frame size
                nadj = 2;
        else
                nadj = 1;
        end
        
        hsig = figure('Position',pos2, 'Name',['<< Frame ' num2str(fra) ' >>'],...
                'NumberTitle','off', 'Tag','Scalp_figure');
        if ~isempty(posfig)
                set(hsig, 'Position', posfig)
        end
end
set(hsig,'Color', [1 1 1])
% set(hsig, 'Renderer', 'painters');
if ischar(cmap)  % 'jet|hsv|hot|cool|gray'
        switch lower(cmap)
                case 'jet'
                        clrmap = jet;
                case 'hsv'
                        clrmap = hsv;
                case 'hot'
                        clrmap = hot;
                case 'cool'
                        clrmap = cool;
                case 'gray'
                        clrmap = gray;
                otherwise
                        clrmap = jet;
        end
else
        clrmap = cmap; % cmap is an m-by-3 matrix of real numbers between 0.0 and 1.0.
end
if ischar(maplimit)
        clrbarcustom = 0; %
else
        clrbarcustom = 1; % for plotting just 1 colorbar when custom scale is specified
end

%
% Drawing loops
%
iadj = 1;
continueplot = 1;
while iadj<=nadj && continueplot
        ksub = 1;
        for ilat =1:nlat
                if ismoviex>0 && fra>secondframe
                        %disp('creando figura')
                        hsig  = figure('Position',pos2, 'Name',['<< Frame ' num2str(fra) ' >>'],...
                                'NumberTitle','off', 'Tag','Scalp_figure');
                        set(hsig,'Color', [1 1 1])
                        if ~isempty(posfig)
                                set(hsig, 'Position', posfig)
                        end
                        %set(hsig, 'Renderer', 'painters');
                end
                for ibin=1:nbin
                        if ismoviex>0
                                axes('position',[0.05  0.05+hi*(nbin-ibin)  0.9  hi])
                        else
                                axes('position',[0.05+wi*(ilat-1)  0.05+hi*(nbin-ibin)  wi  hi])
                        end
                        if nlat>=1 && ~strcmp(measurestr, 'insta') && ~strcmp(measurestr, 'instalapla')
                                latetitle = [num2str(latencyArray(ilat,1)) '-' num2str(latencyArray(ilat,2))];
                        else
                                latetitle = num2str(latencyArray(ilat));
                        end
                        if ~isnumeric(baseline)
                                if ismember_bc2(baseline, {'pre' 'post' 'all' 'none'})
                                        for c=1:ERP.nchan
                                                blv = blvalue(ERP, c, binArray(ibin), baseline);
                                                datap(c,:) = ERP.bindata(c,:,binArray(ibin)) - blv;
                                        end
                                else
                                        error(['ERPLAB says: error at pop_scalplot(). Invalid option: ' baselin])
                                end
                        else
                                if length(baseline)==2
                                        for c=1:ERP.nchan
                                                blv = blvalue(ERP, c, binArray(ibin), baseline);
                                                datap(c,:) = ERP.bindata(c,:,binArray(ibin)) - blv;
                                        end
                                else
                                        error(['ERPLAB says: error at pop_scalplot(). Invalid option: ' num2str(baseline)])
                                end
                        end
                        
                        %
                        % Measurement setting
                        %
                        switch measurestr
                                case 'insta'
                                        data2plot = datap(:,latArray(ilat));%   ERP.bindata(:,latArray(ilat),binArray(ibin));
                                case 'mean'
                                        data2plot = mean(datap(:,latArray(ilat,1):latArray(ilat,2)), 2);
                                case 'rms'
                                        data2plot = sqrt(mean(datap(:,latArray(ilat,1):latArray(ilat,2)).^2, 2));
                                case {'area','areat','areap','arean','ninteg'}
                                        data2plot = geterpvalues(ERP, [latArray(ilat,1) latArray(ilat,2)],...
                                                binArray(ibin), 1:ERP.nchan, measurestr, baseline, 1)';
                                case 'instalapla'
                                        data2plot = del2map( datap(:,latArray(ilat)), ERP.chanlocs);
                                case 'meanlapla'
                                        data2plot = mean(datap(:,latArray(ilat,1):latArray(ilat,2)), 2);
                                        data2plot = del2map(data2plot, ERP.chanlocs);
                        end
                        if ischar(maplimit)
                                if strcmpi(maplimit,'auto') && ilat==1
                                        maplimit = [min(data2plot) max(data2plot)];
                                end
                        end
                        
                        %
                        % Legend
                        %
                        titulo = titlemaker(ERP, binleg, bindesc, vtype, vlatency, binArray, measurestr, latetitle, ibin);
                        
                        %
                        % Plot head(s)
                        %
                        %                         try
                        if strcmpi(mtype, '3d')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %                  Plot 3D scalp map, at current latency, current bin                  %
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                if strcmpi(elestyle, 'off')
                                        auxelestyle = 'off';
                                        elclbls = 0;
                                else
                                        auxelestyle = 'on';
                                        switch elestyle
                                                case 'on'
                                                        elclbls = 0;
                                                case {'numbers','ptsnumbers'}
                                                        elclbls = 1;
                                                case {'labels','ptslabels'}
                                                        elclbls = 2;
                                                otherwise
                                                        elclbls = 0;                                                        
                                        end
                                        
                                end                                
                                
                                % colorbar and plot
                                cb3d = 0;
                                %
                                % Plot ERP on a 3D head
                                %
                                [HeadAxes(ksub), ColorbarHandle] = headplot_erp(data2plot, splinefile, 'electrodes', auxelestyle, 'view', mview,...
                                        'maplimits', maplimit, 'cbar', cb3d,'colormap', clrmap, 'title', titulo, 'electrodes3d', elec3D, 'labels', elclbls); %Plots the 3d scalp plot.                                
                                
                                
                                if clrbar==1 && clrbarcustom==1
                                        %colorbar('hide');
                                        erpsinglecolorbar(HeadAxes, ColorbarHandle, nlat)
                                        drawnow
                                elseif clrbar==0
                                        set(ColorbarHandle, 'Visible','off')
                                        set(get(ColorbarHandle, 'Children'), 'Visible','off')
                                        drawnow
                                end
                                
                                %
                                % Title
                                %
                                httle  = get(gca,'Title');
                                set(httle,'FontSize', fontsizel)
                                set(httle,'FontName', fontnamel)
                                %pttle = get(httle,'position');
                                %set(httle,'position',[pttle(1) pttle(2) pttle(3)]*0.9)
                                
                                %
                                % Copy object when click on axes
                                %
                                if ismoviex==0
                                        axcopy_modified(gca)
                                end
                        elseif strcmpi(mtype, '2d')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %                  Plot 2D scalp map, at current latency, current bin                     %
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                
                                %
                                % Plot ERP on a 2D map
                                %
                                mapnumcontour = 12;
                                mheadrad      = 0.5; 
                                topoplot( data2plot, ERP.chanlocs,...
                                       'style', smapstyle, 'plotrad',mplotrad, 'headrad', mheadrad,'emarker', {'.','k',[],1},...
                                       'numcontour', mapnumcontour, 'maplimits', maplimit, 'colormap', clrmap,'electrodes', elestyle, 'nosedir', mapview);
                                    
                                HeadAxes(ksub) = gca;
                                
                                % Color Bar
                                if clrbar==0 || (clrbar==1 && clrbarcustom==1)
                                        ColorbarHandle = [];
                                else
                                        clrpos = 'EastOutSide';
                                        ColorbarHandle = colorbar('location', clrpos);
                                        %set(ColorbarHandle,'Visible','off')
                                end
                                
                                %
                                % Axes Title (Position)
                                %
                                httle = title(titulo , 'FontSize', fontsizel, 'FontName', fontnamel); % Two line title
                                %set(httle,'Position', [-0.004 0.55 4]) % above
                                set(httle,'Position', [-0.004 -0.58 4]) % below
                                %set(httle,'Position', [-0.588 -0.004  4], 'rotation',90) % vertical left
                                %set(httle,'Position', [0.588 -0.004  4], 'rotation',90)  % vertical right
                                %set(httle,'Position', [-0.42 0.4  4], 'rotation',45)     % 45 deg
                                
                                if nbin>1 && nlat<=2 % shrink a little bit the haeds for minimizing the overlap with the title
                                        PP = get(HeadAxes(ksub), 'Position');
                                        set(HeadAxes(ksub), 'Position', [PP(1) PP(2) PP(3) PP(4)*0.9])
                                end
                                if ismoviex==0
                                        axcopy_modified(gca)
                                end
                        else
                                close(hsig)
                                msgboxText =  'pop_scalplot cannot plot a map in %s.';
                                title_msg = 'ERPLAB: pop_scalplot() error:';
                                errorfound(sprintf(msgboxText, upper(mtype)), title_msg);
                                return
                        end
                        %                         catch
                        %                                 close(hsig)
                        %                                 serr = lasterror;
                        %                                 msgboxText =  ['Something went wrong: \n\n'...
                        %                                         serr.message '\n'];
                        %                                 title_msg = 'ERPLAB: pop_scalplot() error:';
                        %                                 errorfound(sprintf(msgboxText), title_msg);
                        %                                 return
                        %                         end
                        
                        ksub = ksub + 1;
                end
                %set(gcf,'Color', [1 1 1])
                drawnow
                
                %
                % Stack for AGIF
                %
                if ismoviex>0
                        if  clrbar==1 && clrbarcustom==1 && strcmpi(mtype, '2d')
                                %
                                % When single colorbar is requiered (custom scale)
                                %
                                try
                                        if isempty(ColorbarHandle)
                                                ColorbarHandle = colorbar('Visible', 'off');
                                        end
                                        erpsinglecolorbar(HeadAxes(end), ColorbarHandle, 1)
                                catch
                                end
                                drawnow
                        end
                        if adj1frame==1 && iadj==1 % agif --> Adjust frame size
                                BackERPLABcolor = [1 0.9 0.3];    % yellow
                                question = 'Press OK when ready to continue.';
                                titlet   = 'Adjusting frame size';
                                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                                button   = questdlg(question, titlet,'OK', 'OK');
                                set(0,'DefaultUicontrolBackgroundColor', oldcolor)
                                
                                if ~strcmpi(button,'OK')
                                        disp('User selected Cancel')
                                        continueplot = 0;
                                        ismoviex = 0;
                                else
                                        findplot = findobj('Tag','Scalp_figure');
                                        if ~isempty(findplot)
                                                lastfig = figure(findplot(1));
                                                posfig   = get(lastfig,'Position');
                                                plotset = evalin('base', 'plotset');
                                                plotset.pscalp.posfig = posfig;
                                                assignin('base','plotset', plotset);
                                        end
                                        %fra = fra + 1;
                                end
                                secondframe = 0;
                                close(hsig)
                                HeadAxes = [];
                                break
                        end
                        if strcmpi(movtype,'gif') % gif
                                if fra==1
                                        f = getframe(hsig);
                                        pause(0.01)
                                        [im,map] = rgb2ind(f.cdata,256,'nodither');
                                        pause(0.01)
                                        im(1,1,1,nlat) = 0;
                                end
                                
                                fra = fra + 1;
                                f   = getframe(hsig);
                                pause(0.01)
                                im(:,:,1,fra) = rgb2ind(f.cdata, map,'nodither');
                                pause(0.02)
                                close(hsig)
                        else % movie
                                if fra==1
                                        % Preallocate movie structure.
                                        im(1:nlat) = struct('cdata', [],...
                                                'colormap', []);
                                        pause(0.01)
                                        im(1) = getframe(hsig);
                                        pause(0.01)
                                end
                                
                                fra = fra + 1;
                                im(fra) = getframe(hsig);
                                pause(0.01)
                                close(hsig)
                        end
                        HeadAxes = [];
                end
                %ksub = ksub + 1;
        end
        iadj = iadj+1;
        if  clrbar==1 && clrbarcustom==1 && ismoviex==0 && strcmpi(mtype, '2d')
                
                %
                % When single colorbar is requiered (custom scale)
                %
                if isempty(ColorbarHandle)
                        ColorbarHandle = colorbar('Visible', 'off');
                end
                erpsinglecolorbar(HeadAxes, ColorbarHandle, nlat)
                drawnow
        end
end

assignin('base','scalpicture', hsig);
binArraystr = vect2colon(binArray);
if size(latencyArray,1)==1
        latencystr  = vect2colon(latencyArray);
else
        latencystr  = mat2colon(latencyArray);
end
fprintf('Mapped Channels: ');
for j=1:ERP.nchan
        fprintf('%s - ', char(ERP.chanlocs(j).labels));
end
fprintf('\n');

%
% Create final Animation
%
if ismoviex>0
        if strcmpi(movtype,'gif')
                pause(0.1)
                imwrite(im, map, fullgifname,'DelayTime',1/FPS,'LoopCount',inf);% save animated gif file
        elseif strcmpi(movtype,'mat')
                pause(0.1)
                save(fullgifname, 'im', '-mat'); % save the MATLAB movie to a file
        elseif strcmpi(movtype,'avi')
                pause(0.1)
                movie2avi(im, fullgifname, 'compression', compression, 'fps', FPS, 'quality', quality, 'videoname', vname); % Create AVI file.
        else
                error('invalid file format')
        end
end

%
% History command
%
skipfields = {'ERP','binArray','latencyArray','History'};
if ismoviex==0
        skipfields = [skipfields {'FPS','Filename','Quality','Compression','VideoIntro'}];
end
if strcmpi(mtype, '2d')
        skipfields = [skipfields {'Electrodes3d'}];
end
fn = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_scalplot( %s, %s, %s ',  inputname(1), inputname(1), binArraystr, latencystr);

for q=1:length(fn)
        fn2com = fn{q}; % inputname
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com); %  input value
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        elseif iscell(fn2res)
                                nn = length(fn2res);
                                erpcom = sprintf( '%s, ''%s'', {''%s'' ', erpcom, fn2com, fn2res{1});
                                for ff=2:nn
                                        erpcom = sprintf( '%s, ''%s'' ', erpcom, fn2res{ff});
                                end
                                erpcom = sprintf( '%s}', erpcom);
                        else
                                if ~ismember_bc2(fn2com,{'Maplimit','Mapview'})
                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                                else
                                        xyscalestr = sprintf('[ %.1f %.1f  %s ]', fn2res(1), fn2res(2), vect2colon(fn2res(3:end),'Delimiter','off'));
                                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, xyscalestr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                % ERP = erphistory(ERP, [], erpcom, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end

%
% Completion statement
%
msg2end
return

%---------------------------------------------------------------------------------------------------
%-----------------base line mean value--------------------------------------------------------------
function blv = blvalue(ERP, chan, bin, bl)
if isfield(ERP, 'datatype')
        datatype = ERP.datatype;
else
        datatype = 'ERP';
end
if strcmpi(datatype, 'ERP')
        kktime = 1000;
        srate = ERP.srate;
else
        kktime = 1;
        srate  = ERP.pnts/ERP.xmax;
end
if isnumeric(bl)
        toffsa   = abs(round(ERP.xmin*srate))+1;
        baseline = round((bl/kktime)*srate) + toffsa; %msec to samples
        p1 = baseline(1);
        p2 = baseline(2);
else
        switch bl
                case 'none'
                        blv = 0;
                        return
                case 'pre'
                        p1=1;
                        p2  = find(ERP.times==0);    % zero-time locked sample
                case 'post'
                        p1  = find(ERP.times==0);    % zero-time locked sample
                        p2  =  ERP.pnts;
                case 'all'
                        p1  = 1;
                        p2  =  ERP.pnts;
        end
end

blv = mean(ERP.bindata(chan,p1:p2, bin));

%---------------------------------------------------------------------------------------------------
%-----------------       legend       --------------------------------------------------------------
function titulo = titlemaker(ERP, binleg, bindesc, vtype, vlatency, binArray, measurestr, latetitle, ibin)
if isfield(ERP, 'datatype')
        datatype = ERP.datatype;
else
        datatype = 'ERP';
end

strbinnum = ['Bin' num2str(binArray(ibin))];
strequal  = ' = ';
strbindes = ERP.bindescr{binArray(ibin)};
strbindes = strrep(strbindes,'_','\_'); % trick for dealing with '_'. JLC
strcomma1 = ',';
strvtype  = [''''  measurestr ''''];
strcomma2 = ',';
if strcmpi(datatype, 'ERP')
        strvlate  = [latetitle ' ms'];
else %FFT
        strvlate  = [latetitle ' Hz'];
end

t = [strbinnum*binleg  strequal*binleg*bindesc  strbindes*bindesc strcomma1*(vtype&(binleg|bindesc))...
        strvtype*vtype  strcomma2*(vlatency&(binleg|bindesc|vtype))  strvlate*vlatency];
t = nonzeros(t)';
titulo = strtrim(char(t));
