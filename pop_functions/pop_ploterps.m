% PURPOSE  :	Plot ERP datasets
%
% FORMAT   :
%
% pop_ploterps(ERP, binArray, chanArray, parameters)
%
%
% INPUTS   :
%
% ERP               - input ERPset
% binArray          - index(es) of bin(s) to plot. e.g [ 4:2:24]
% chanArray         - index(es) of channel(s) to plot. e.g. [12 21 30:40]
%
% The available parameters are as follows:
%
%        'Mgfp'             - channel indices for calculatin Mean Global Field Power. e.g. [2:32]
%        'Blc'              - string or numeric interval for baseline correction
%                             reference window: 'no','pre','post','all', or a
%                             specific time window, for instance [-100 0]
%        'xscale'           - time window to plot: [t1 t2]. e.g. [-200 800]
%        'yscale'           - amplitude scale to plot: [a1 a2]. e.g. [-5 10]
%        'LineWidth'        - waveform line width
%        'YDir'             - {normal} | reverse. Direction of increasing values for Y axis. Normal is upward.
%        'FontSizeChan'     - font size for channel label
%        'FontSizeLeg'      - font size for Legends
%        'Style'            - Type of plotting. 'Matlab', 'Classic', or 'Topo'
%        'SEM'              - plot standard error of the mean (if available). 'on'/'off'
%        'Box'              - number of rows and columns for ploting ERP in a rectangular array. e.g. [3 6] asuming you have 18 channels or less.
%        'HoldCh'           - deprecated...
%        'AutoYlim'         - set Y limits automatic
%        'BinNum'           - display bin number at bin legend. 'on'/'off'
%        'ChLabel'          - display channel label. 'on'/'off'
%        'LegPos'           - Position for bin legend. 'bottom','right','external', or 'none'
%        'Maximize'         - maximize  whole figure
%        'Position'         - deprecated...
%        'Axsize'           - size ([w h] ) for each channel when topoplot is being used.
%        'MinorTicksX'      - display minor ticks for X axis. 'on'/'off'
%        'MinorTicksY'      -  display minor ticks for Y axis. 'on'/'off'
%        'Linespec'         - Line specification string syntax. e.g. {'-k' '--r' '-.b' '-g' ':c' '--m' '-.y'}
%
%
%
% OUTPUTS  :
%
% Figure on the screen
%
%
% EXAMPLE  :
%
% >> pop_ploterps(ERP)   - GUI will appear
%
% or
%
% >> pop_ploterps( ERP,1:3,1:16 , 'AutoYlim', 'on', 'Axsize', [ 0.05 0.08],'BinNum', 'on', 'Blc', 'pre', 'Box', [ 4 4], 'ChLabel', 'on',...
%                 'FontSizeChan',10, 'FontSizeLeg', 10, 'LegPos', 'bottom', 'Linespec', {'k-', 'r-'},'LineWidth', 1, 'Maximum', 'on',...
%                 'Position', [102.8 19.4615 109 35.3846],'Style', 'Matlab', 'xscale', [ -200.0 798.0 -100:170:750 ], 'YDir', 'normal',...
%                 'yscale', [ -10.0 10.0 -10:5:10 ] );
%
%
%
% See also ploterpGUI.m ploterps.m
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

function [ERP, erpcom] = pop_ploterps(ERP, binArray, chanArray, varargin)
erpcom = '';
if nargin < 1
        help pop_ploterps
        return
end
if nargin==1  %with GUI
        if isempty(ERP)
                ERP = preloadERP;
                if isempty(ERP)
                        msgboxText =  'No ERPset was found!';
                        title_msg  = 'ERPLAB: pop_ploterps() error:';
                        errorfound(msgboxText, title_msg);
                        return
                end
        end
        if ~iserpstruct(ERP)
                msgboxText =  'Invalid ERP structure!';
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if ~isfield(ERP,'bindata') %(ERP.bindata)
                msgboxText =  'Cannot plot an empty ERP dataset';
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        if isempty(ERP.bindata) %(ERP.bindata)
                msgboxText =  'Cannot plot an empty ERP dataset';
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        end
        
        datatype = checkdatatype(ERP);
        
        %
        % Call GUI for plotting
        %
        [plotset,  ERP] = ploterpGUI(ERP);

        if isempty(ERP)
                disp('User selected Cancel')
                return
        end
        if (isempty(plotset.ptime) && strcmpi(datatype, 'ERP')) || (isempty(plotset.pfrequ) && ~strcmpi(datatype, 'ERP'))
                disp('User selected Cancel')
                return   
        end
%         elseif strcmpi(plotset.ptime,'mini')                
%                 ansmini = mini_ploterpGUI;                
%                 if isempty(ansmini)
%                         disp('User selected Cancel')
%                         return
%                 end                
%                 [ERP, erpcom] = pop_ploterps(ERP);
%                 return                
        if (strcmpi(plotset.ptime,'pdf') && strcmpi(datatype, 'ERP')) || (strcmpi(plotset.pfrequ,'pdf') && ~strcmpi(datatype, 'ERP')) 
                [ERP, erpcom2] = pop_exporterplabfigure(ERP);
                %if countp>0
                disp('pop_exporterplabfigure was called')
                %else
                %        disp('WARNING: Matlab figure(s) might have been generated during a previous round....')
                %end
                erpcom = [erpcom ' ' erpcom2];
                return
        elseif (strcmpi(plotset.ptime,'scalp') && strcmpi(datatype, 'ERP')) || (strcmpi(plotset.pfrequ,'scalp') && ~strcmpi(datatype, 'ERP')) 
                disp('User called pop_scalplot()')
                return
        end
        if (isfield(plotset.ptime, 'pstyle') && plotset.ptime.pstyle==4 && strcmpi(datatype, 'ERP')) || (isfield(plotset.pfrequ, 'pstyle') && plotset.pfrequ.pstyle==4 && ~strcmpi(datatype, 'ERP'))% topo
                %
                % Searching channel location
                %
                if isfield(ERP.chanlocs, 'theta')
                        ERP = borrowchanloc(ERP);
                else
                        question = ['This averaged ERP has not channel location info.\n'...
                                    'Would you like to load it now?'];
                        title_msg = 'ERPLAB: Channel location';
                        button    = askquest(sprintf(question), title_msg);
                        
                        if ~strcmpi(button,'yes')
                                disp('User selected Cancel')
                                return
                        else
                                ERP = borrowchanloc(ERP);
                        end
                end
        end
        if strcmpi(datatype, 'ERP')
                plotset.ptime.binArray  = plotset.ptime.binArray(plotset.ptime.binArray<=ERP.nbin);
                plotset.ptime.chanArray = plotset.ptime.chanArray(plotset.ptime.chanArray<=ERP.nchan);
                plotset.ptime.chanArray_MGFP = plotset.ptime.chanArray_MGFP(plotset.ptime.chanArray_MGFP<=ERP.nchan);
                
                if isempty(plotset.ptime.binArray)
                        msgboxText =  'Invalid bin index(ices)';
                        title_msg  = 'ERPLAB: pop_ploterps() invalid info:';
                        errorfound(msgboxText, title_msg);
                        return
                end
                if isempty(plotset.ptime.chanArray)
                        msgboxText =  'Specified channel(s) did not have a valid channel location.';
                        title_msg  = 'ERPLAB: pop_ploterps() invalid info:';
                        errorfound(msgboxText, title_msg);
                        return
                end
                assignin('base','plotset', plotset);
                getplotset_time % call script (get values)
        else
                plotset.pfrequ.binArray  = plotset.pfrequ.binArray(plotset.pfrequ.binArray<=ERP.nbin);
                plotset.pfrequ.chanArray = plotset.pfrequ.chanArray(plotset.pfrequ.chanArray<=ERP.nchan);
                plotset.pfrequ.chanArray_MGFP = plotset.pfrequ.chanArray_MGFP(plotset.pfrequ.chanArray_MGFP<=ERP.nchan);
                
                if isempty(plotset.pfrequ.binArray)
                        msgboxText =  'Invalid bin index(ices)';
                        title_msg  = 'ERPLAB: pop_ploterps() invalid info:';
                        errorfound(msgboxText, title_msg);
                        return
                end
                if isempty(plotset.pfrequ.chanArray)
                        msgboxText =  'Specified channel(s) did not have a valid channel location.';
                        title_msg  = 'ERPLAB: pop_ploterps() invalid info:';
                        errorfound(msgboxText, title_msg);
                        return
                end
                assignin('base','plotset', plotset);
                getplotset_frequ % call script (get values)
        end        
        if yauto==1
                rAutoYlim = 'on';
        else
                rAutoYlim = 'off';
        end
        if binleg==1
                rBinNum = 'on';
        else
                rBinNum = 'off';
        end
        if chanleg==1 % @@@@@@@@@@
                rchanlabel = 'on'; % show ch label
        else
                rchanlabel = 'off'; % show ch number
        end
        if holdch==1
                rHoldCh = 'on';
        else
                rHoldCh = 'off';
        end
        if legepos==1
                rLegPos = 'bottom';
        elseif legepos==2
                rLegPos = 'right';
        elseif legepos==3
                rLegPos = 'external';
        else
                rLegPos = 'none';
        end
        if errorstd==1
                rSEM = 'on';
        elseif errorstd>1
                rSEM = num2str(errorstd); % for more than 1 stdev
        else
                rSEM = 'off';
        end
        if pstyle==1
                rStyle = 'Matlab1';
        elseif pstyle==2
                rStyle = 'Matlab2';
        elseif pstyle==3
                rStyle = 'Classic';
        else
                rStyle = 'Topo';
        end
        if isiy==1
                rYDir = 'reverse';
        else
                rYDir = 'normal';
        end
        if ismaxim==1
                rismaxim = 'on';
        else
                rismaxim = 'off';
        end
        if minorticks(1)
                mtxstr = 'on';
        else
                mtxstr = 'off';
        end
        if minorticks(2)
                mtystr = 'on';
        else
                mtystr = 'off';
        end
        
        linespeci = linespeci(1:length(binArray));
        
        if ibckground==1 % @@@@@@@@@@
                invbckg = 'on'; % show ch label
        else
                invbckg = 'off'; % show ch number
        end
        
        %
        % Somersault
        %
        [ERP, erpcom] = pop_ploterps(ERP, binArray, chanArray, 'AutoYlim', rAutoYlim, 'BinNum', rBinNum, 'Blc', blcorr,...
                'Box', pbox, 'FontSizeChan', fschan, 'FontSizeLeg', fslege, 'FontSizeTicks',fsaxtick,'HoldCh', rHoldCh,...
                'LegPos', rLegPos,'LineWidth', linewidth, 'Mgfp', chanArray_MGFP, 'SEM', rSEM, 'Transparency', stdalpha,...
                'Style', rStyle, 'xscale', xxscale,'YDir', rYDir, 'yscale', yyscale, 'Maximize', rismaxim, 'Position', posgui,...
                'axsize', axsize,'ChLabel', rchanlabel, 'MinorTicksX', mtxstr, 'MinorTicksY', mtystr,...
                'Linespec', linespeci,'ErrorMsg', 'popup', 'InvertBackground', invbckg,'History', 'gui');
        pause(0.1)
        return
end

%
% Parsing inputs
%
colordef = getcolorcellerps; %{'k' 'r' 'b' 'g' 'c' 'm' 'y' 'w'};% default colors
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ERP');
p.addRequired('binArray', @isnumeric);
p.addRequired('chanArray', @isnumeric);
% option(s)
p.addParamValue('Mgfp', [], @isnumeric);
p.addParamValue('Blc', 'none', @ischar);
p.addParamValue('xscale', [], @isnumeric);
p.addParamValue('yscale', [], @isnumeric);
p.addParamValue('LineWidth', 1, @isnumeric);
p.addParamValue('YDir', 'normal', @ischar); % normal | reverse
p.addParamValue('FontSizeChan', 10, @isnumeric);
p.addParamValue('FontSizeLeg', 12, @isnumeric);
p.addParamValue('FontSizeTicks', 10, @isnumeric);
p.addParamValue('Style', 'Matlab', @ischar);
p.addParamValue('SEM', 'off', @ischar); % standard error of the mean
p.addParamValue('Transparency', 1, @isnumeric); % transparency value for plotting SEM
p.addParamValue('Box', [], @isnumeric);
p.addParamValue('HoldCh', 'off', @ischar);
p.addParamValue('AutoYlim', 'on_default', @ischar);
p.addParamValue('BinNum', 'off', @ischar);
p.addParamValue('ChLabel', 'on', @ischar);
p.addParamValue('LegPos', 'bottom', @ischar);
p.addParamValue('Maximize', 'off', @ischar);
p.addParamValue('Position', [], @isnumeric);
p.addParamValue('Axsize', [], @isnumeric); % size ([w h] ) for each channel when topoplot is being used.
p.addParamValue('MinorTicksX', 'off', @ischar); % off | on
p.addParamValue('MinorTicksY', 'off', @ischar); % off | on
p.addParamValue('Linespec', colordef, @iscell);
p.addParamValue('ErrorMsg', 'cw', @ischar); % cw = command window
p.addParamValue('Tag', 'ERP_figure', @ischar); % figure tag
p.addParamValue('InvertBackground', 'off', @ischar); % figure tag
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ERP, binArray, chanArray, varargin{:});

if strcmpi(p.Results.ErrorMsg,'popup')
        errormsgtype = 1; % open popup window
else
        errormsgtype = 0; % error in red at command window
end
ftag = p.Results.Tag;
if strcmpi(p.Results.InvertBackground,'on')
        ibckground = 1; % invert
else
        ibckground = 0; % do not
end

filename4erp = '';

% check ERP
if isempty(ERP)
        msgboxText =  'No ERPset was found or it was empty.';
        if errormsgtype
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if ischar(ERP)
        if exist(ERP, 'file')~=2
                msgboxText =  'File (%s) was not found!';
                if errormsgtype
                        title_msg  = 'ERPLAB: pop_ploterps() error:';
                        errorfound(sprintf(msgboxText, ERP), title_msg);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], ERP);
                end
        end
        
        filename4erp = ERP;
        [patherp, nameerp, ext] = fileparts(ERP);
        
        if isempty(ext) || ~strcmpi(ext, '.erp')
                ext = '.erp';
        end
        ERP = pop_loaderp( 'filename', [nameerp ext], 'filepath', patherp );
end
if ~iserpstruct(ERP)
        msgboxText =  'Invalid ERP structure!';
        if errormsgtype
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if ~isfield(ERP,'bindata') %(ERP.bindata)
        msgboxText =  'Cannot plot an empty ERP dataset';
        if errormsgtype
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if isempty(ERP.bindata) %(ERP.bindata)
        msgboxText =  'Cannot plot an empty ERP dataset';
        if errormsgtype
                title_msg  = 'ERPLAB: pop_ploterps() error:';
                errorfound(msgboxText, title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if max(chanArray)>ERP.nchan
        msgboxText =  ['Channel(s) %s do(es) not exist within this erpset.\n'...
                'Please, check your channel list'];
        if errormsgtype
                title_msg = 'ERPLAB: pop_ploterps() invalid channel index';
                errorfound(sprintf(msgboxText, vect2colon(chanArray(chanArray>ERP.nchan))), title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText], vect2colon(chanArray(chanArray>ERP.nchan)));
        end
        
end
if min(chanArray)<1
        msgboxText =  ['Invalid channel indexing.\n'...
                'Channel index(ices) must be positive integer(s) but zero.'];
        if errormsgtype
                title_msg = 'ERPLAB: pop_ploterps() invalid channel index';
                errorfound(sprintf(msgboxText), title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end
if max(binArray)>ERP.nbin
        msgboxText =  ['Bin(s) %s do(es) not exist within this erpset.\n'...
                'Please, check your bin list'];
        if errormsgtype
                title_msg = 'ERPLAB: pop_ploterps() invalid bin index';
                errorfound(sprintf(msgboxText, vect2colon(binArray(binArray>ERP.nbin))), title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText], vect2colon(binArray(binArray>ERP.nbin)));
        end
end
if min(binArray)<1
        msgboxText =  ['Invalid bin indexing.\n'...
                'Bin index(ices) must be positive integer(s) but zero.'];
        if errormsgtype
                title_msg = 'ERPLAB: pop_ploterps() invalid bin index';
                errorfound(sprintf(msgboxText), title_msg);
                return
        else
                error('prog:input', ['ERPLAB says: ' msgboxText]);
        end
end

datatype = checkdatatype(ERP);

if strcmpi(datatype, 'ERP')
    kktime = 1000;
else
    kktime = 1;
end

qMgfp   = p.Results.Mgfp;
qBlc    = p.Results.Blc;
qxscale = p.Results.xscale;
qyscale = p.Results.yscale;
qBox    = p.Results.Box;
qLineWidth     = p.Results.LineWidth;
qFontSizeChan  = p.Results.FontSizeChan;
qFontSizeLeg   = p.Results.FontSizeLeg;
qFontSizeTicks = p.Results.FontSizeTicks;
qaxsize  = p.Results.Axsize;

if isempty(qxscale)
        qxscale = [round(ERP.xmin*kktime) round(ERP.xmax*kktime)];
end
if isempty(qBox)
        aa = round(sqrt(ERP.nchan));
        boxd = [aa+1 aa];
        qBox = boxd;
end
if strcmpi(p.Results.Style,'Matlab') || strcmpi(p.Results.Style,'Matlab1')
        qpstyle = 1;
elseif strcmpi(p.Results.Style,'Matlab2')
        qpstyle = 2;
elseif strcmpi(p.Results.Style,'Classic')
        qpstyle = 3;
elseif strcmpi(p.Results.Style,'Topo')
        qpstyle = 4;
else
        error('Unknown style for plotting.')
end
if strcmpi(p.Results.YDir,'reverse')
        qisiy = 1;
else
        qisiy = 0;
end
if strcmpi(p.Results.SEM,'on')
        qerrorstd = 1;
else
        if ~isempty(str2num(p.Results.SEM))
                qerrorstd = str2num(p.Results.SEM);
        else
                qerrorstd = 0;
        end
end
qstdalpha = 1-p.Results.Transparency; % Transparency for SEM
if strcmpi(p.Results.HoldCh,'on')
        qholdch = 1;
else
        qholdch = 0;
end


if strcmpi(p.Results.AutoYlim,'on_default')
    % If AutoYlim is on-by-default, then check yscale first - axs
    if isempty(qyscale)
        qyauto = 1;     % AutoYlim ON, when on-by-default AND no yscale specified.
    else
        qyauto = 0;     % AutoYlim OFF, when on-by-default AND a specific yscale requested
    end
    
    
elseif strcmpi(p.Results.AutoYlim,'off')
    % If AutoYlim is specified as 'off'
    qyauto = 0;


else   % take to be strcmpi(p.Results.AutoYlim,'on')
    % If AutoYlim is specified as 'on'
    qyauto = 1;
end


if strcmpi(p.Results.BinNum,'on')
        qbinleg = 1;
else
        qbinleg = 0;
end
if strcmpi(p.Results.ChLabel,'on') %@@@@@@@@@@@@@@@@@@@@@@
        qchanleg = 1;
else
        qchanleg = 0;
end
if strcmpi(p.Results.LegPos,'bottom')
        qlegepos = 1;
elseif strcmpi(p.Results.LegPos,'right')
        qlegepos = 2;
elseif strcmpi(p.Results.LegPos,'external')
        qlegepos = 3;
else
        qlegepos = 4; % none
end
if strcmpi(p.Results.Maximize,'on')
        ismaxim = 1;
else
        ismaxim = 0;
end
minorticks = [0 0];
if strcmpi(p.Results.MinorTicksX,'on')
        minorticks(1) = 1;
else
        minorticks(1) = 0;
end
if strcmpi(p.Results.MinorTicksY,'on')
        minorticks(2) = 1;
else
        minorticks(2) = 0;
end
%posgui    = p.Results.Position;
linespeci = p.Results.Linespec;
if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
while length(linespeci)<length(binArray)
        linespeci = [linespeci colordef];
end
if qpstyle==4 % topo
        if ~isfield(ERP.chanlocs,'theta')
                msgboxText =  ['%s  has not channel location info.\n'...
                        'Topographic plot will be terminated.'];
                if errormsgtype
                        title_msg = 'ERPLAB: pop_ploterps() missing info:';
                        errorfound(sprintf(msgboxText, ERP.erpname), title_msg);
                        return
                else
                        error('prog:input', ['ERPLAB says: ' msgboxText], ERP.erpname);
                end
        end
end
if strcmpi(datatype, 'ERP')
        try
                plotset = evalin('base', 'plotset');
                plotset.ptime.xscale = qxscale; % plotting memory for time window
                assignin('base','plotset', plotset);
        catch
                ptime  = [];
                plotset.ptime  = ptime;
                assignin('base','plotset', plotset);
        end
else
        try
                plotset = evalin('base', 'plotset');
                plotset.pfrequ.xscale = qxscale; % plotting memory for time window
                assignin('base','plotset', plotset);
        catch
                pfrequ  = [];
                plotset.pfrequ  = pfrequ;
                assignin('base','plotset', plotset);
        end
end

%
% Set new figure position
%
% if ~isfield(plotset.ptime, 'posfig')
%         plotset.ptime.posfig = [];
% end

if ismaxim==0
        findplot = sort(findobj('Tag','ERP_figure'));
        if ~isempty(findplot)
                lastfig = figure(findplot(end));
                posfx   = get(lastfig,'Position');
                scrsz = get(0,'ScreenSize');
                if posfx(3)>=scrsz(1,3) || posfx(4)>=scrsz(1,4)
                        posfx([3 4]) = [scrsz(3)/2 scrsz(4)/2];
                end
                posfig  = [posfx(1)+10 posfx(2)-15 posfx(3) posfx(4) ];
                
                %       gofig = 1;
                %       while gofig>0 && gofig<= length(findplot)
                %             lastfig = figure(findplot(gofig));
                %             posfx   = get(lastfig,'Position');
                %
                %             if posfx(3)>=1 && posfx(4)>=1
                %                   posfig = [posfx(1)+10 posfx(2)-15 posfx(3) posfx(4) ]
                %                   gofig = 0;
                %             else
                %                   gofig = gofig + 1;
                %             end
                %       end
        else
                posfig = [];
        end
        if strcmpi(datatype, 'ERP')
                plotset.ptime.posfig = posfig;
        else
                plotset.pfrequ.posfig = posfig;
        end
        assignin('base','plotset', plotset);
else
        if strcmpi(datatype, 'ERP')
                if isfield(plotset.ptime, 'posfig') % bug fixed apr 2013
                        posfig = plotset.ptime.posfig;
                else
                        posfig = [];
                end
        else
                if isfield(plotset.pfrequ, 'posfig') % bug fixed apr 2013
                        posfig = plotset.pfrequ.posfig;
                else
                        posfig = [];
                end
        end
end

%
% Call ploterps subroutine
%
BinArraystr  = vect2colon(binArray, 'Sort','yes');
chanArraystr = vect2colon(chanArray);
ploterps(ERP, binArray, chanArray,  qpstyle, qMgfp, qBlc, qxscale, qyscale, qLineWidth, qisiy, qFontSizeChan, qFontSizeLeg, qFontSizeTicks, qerrorstd,...
        qstdalpha, qBox, qholdch, qyauto, qbinleg, qlegepos, ismaxim, posfig, qaxsize, qchanleg, minorticks, linespeci, ftag, ibckground)

%
% History command
%
fn = fieldnames(p.Results);
if isempty(filename4erp) % first input was an ERP or a filename?
        firstinput = inputname(1);
else
        firstinput = filename4erp;
end

skipfields = {'ERP','binArray','chanArray', 'ErrorMsg','History'};
if qyauto
        skipfields = [skipfields 'yscale'];
end
erpcom     = sprintf( 'ERP = pop_ploterps( %s, %s, %s ',  firstinput, BinArraystr, chanArraystr);

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
                                if ~ismember_bc2(fn2com,{'xscale','yscale'})
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
        otherwise %off or none
                erpcom = '';
                return
end

%
% Completion statement
%
msg2end
return