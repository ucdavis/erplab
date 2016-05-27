% UNDER CONSTRUCTION
%
%
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

function neoploterps(ALLERP, explist, varargin) 

% chMGFP,  blcorr, xlim, ylim, linew, isinvertedY, fschan, fslege, errorstd,...
%         box, holdch, yauto, binleg, legepos, ismaxim, posfig, axsize, chanleg, minorticks, linespec)

if nargin<1
        help ploterps
        return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLERP', @isstruct);
p.addRequired('explist', @isnumeric);

p.addParamValue('Mgfp', [], @isnumeric);
p.addParamValue('Blc', 'none', @ischar);
p.addParamValue('xscale', [round(ERP.xmin*1000) round(ERP.xmax*1000)], @isnumeric);
p.addParamValue('yscale', [-10 10], @isnumeric);
p.addParamValue('LineWidth', 1, @isnumeric);
p.addParamValue('YDir', 'normal', @ischar); % normal | reverse
p.addParamValue('FontSizeChan', 10, @isnumeric);
p.addParamValue('FontSizeLeg', 10, @isnumeric);
p.addParamValue('Style', 'Matlab', @ischar); %Matlab | ERP1 | ERP2 | Topo
p.addParamValue('Std', 'off', @ischar);
p.addParamValue('Box', boxd, @isnumeric);
p.addParamValue('HoldCh', 'off', @ischar);
p.addParamValue('AutoYlim', 'on', @ischar);
p.addParamValue('BinNum', 'off', @ischar);
p.addParamValue('ChLabel', 'on', @ischar);
p.addParamValue('LegPos', 'bottom', @ischar); % right | external
p.addParamValue('Maximize', 'off', @ischar); % off | on
p.addParamValue('Position', [], @isnumeric); % off | on
p.addParamValue('Axsize', [], @isnumeric); % size ([w h] ) for each channel when topoplot is being used.
p.addParamValue('MinorTicksX', 'off', @ischar); % off | on
p.addParamValue('MinorTicksY', 'off', @ischar); % off | on
p.addParamValue('Linespec', colordef, @iscell); % off | on

p.parse(ALLERP, explist, varargin{:});

Mgfp         = p.Results.Mgfp;
Blc          = p.Results.Blc;
xscale       = p.Results.xscale;
yscale       = p.Results.yscale;
Box          = p.Results.Box;
LineWidth    = p.Results.LineWidth;
FontSizeChan = p.Results.FontSizeChan;
FontSizeLeg  = p.Results.FontSizeLeg;
axsize       = p.Results.Axsize;

if strcmpi(p.Results.Style,'Matlab')
        pstyle = 1;
elseif strcmpi(p.Results.Style,'Classic')
        pstyle = 2;
elseif strcmpi(p.Results.Style,'Topo')
        pstyle = 3;
else
        error('Unknown style for plotting.')
end
if strcmpi(p.Results.YDir,'reverse')
        isiy = 1;
else
        isiy = 0;
end
if strcmpi(p.Results.Std,'on')
        errorstd = 1;
else
        if ~isempty(str2num(p.Results.Std))
                errorstd = str2num(p.Results.Std);
        else
                errorstd = 0;
        end
end
if strcmpi(p.Results.HoldCh,'on')
        holdch = 1;
else
        holdch = 0;
end
if strcmpi(p.Results.AutoYlim,'on')
        yauto = 1;
else
        yauto = 0;
end
if strcmpi(p.Results.BinNum,'on')
        binleg = 1;
else
        binleg = 0;
end
if strcmpi(p.Results.ChLabel,'on') %@@@@@@@@@@@@@@@@@@@@@@
        chanleg = 1;
else
        chanleg = 0;
end
if strcmpi(p.Results.LegPos,'bottom')
        legepos = 1;
elseif strcmpi(p.Results.LegPos,'right')
        legepos = 2;
elseif strcmpi(p.Results.LegPos,'external')
        legepos = 3;
else
        legepos = 4; % none
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
linespec = p.Results.Linespec;




















stop!


























if nargin<24
        %linespec = {'blue' 'green' 'red' 'cyan' 'magenta' 'yellow' 'black'}; % color for plotting
        defcolor = repmat({'k' 'r' 'b' 'g' 'c' 'm' 'y' },1, ERP.nbin);% sorted according 1st erplab's version
        defs     = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
        d = repmat(defs',1,length(defcolor));
        defstyle = reshape(d',1,length(defcolor)*length(defs));
        linespec = cellstr([char(defcolor') char(defstyle(1:length(defcolor))')])';
end
if nargin<23
        minorticks = [0 0]; % [x y] minor ticks option. 0 means do not show it
end
if nargin<22
        chanleg = 1; % 1 means show channel labels
end
if nargin<21
        axsize = [0.05 0.08]; % for topographic view only
end
if nargin<20
        posfig = []; % figure position
end
if nargin<19
        ismaxim = 1; %  maximize figure
end
if nargin<18
        legepos = 1;
end
if nargin<17
        binleg = 1;
end
if nargin<16
        yauto = 1;
end
if nargin<15
        holdch = 0;
end
if nargin<14
        aa = round(sqrt(ERP.nchan));
        box = [aa+1 aa];
end
if nargin<13
        errorstd = 0;
end
if nargin<12
        fslege = 10;
end
if nargin<11
        fschan = 10;
end
if nargin<10
        isinvertedY = 0;
end
if nargin<9
        linew = 2;
end
if nargin<8
        ylim = [-10 10];
end
if nargin<7
        xlim = [round(ERP.xmin*1000) round(ERP.xmax*1000)];
end
if nargin<6
        blcorr = 'pre';
end
if nargin<5
        chMGFP = 0;
end
if nargin<4
        pstyle = 1;
end
if nargin<3
        chArray = 1:ERP.nchan;
end
if nargin<2
        binArray = 1:ERP.nbin;
end
if isempty(chMGFP)
        isMGFP = 0;
else
        if chMGFP==0
                isMGFP = 0;
        else
                isMGFP = 1;
        end
end

nbin = length(binArray);
nch  = length(chArray);
fs   = ERP.srate;

% check for time-lock latency
ERP = checkerpzerolat(ERP);

%
% In case there is not channel labels, or chanleg =0 (do not show labels)
%

chanlocs = ERP.chanlocs;
if isempty(chanlocs) || chanleg==0
        for cc =1:ERP.nchan
                chanlocs(cc).labels = ['Ch' repmat('0',1, length(num2str(ERP.nchan))-length(num2str(cc))) num2str(cc)];
        end
end

%
% Read data
%
dataaux = ERP.bindata;

%
%  Fit Yaxis AUTO-SCALE
%
if yauto
      if xlim(1)<round(ERP.xmin*1000)
            aux_xlim(1) = round(ERP.xmin*1000);
      else
            aux_xlim(1) = xlim(1);
      end
      if xlim(2)>round(ERP.xmax*1000)
            aux_xlim(2) = round(ERP.xmax*1000);
      else
            aux_xlim(2) = xlim(2);
      end

      [p1 p2 checkw] = window2sample(ERP, aux_xlim(1:2) , fs, 'relaxed');
      
      if checkw==1
            error('ploterps() error: time window cannot be larger than epoch.')
      elseif checkw==2
            error('ploterps() error: too narrow time window')
      end
      
      %nstdev  = 25;
      datresh = reshape(dataaux(chArray,p1:p2,binArray), 1, (p2-p1+1)*nbin*nch);
      %yymean  = mean(datresh);
      %yystd   = std(datresh);
      yymax   = max(datresh);
      yymin   = min(datresh);      
      
      %         if yymax > yymean + nstdev*yystd
      %                 yymax = yymean + nstdev*yystd;
      %         end
      %         if yymin < yymean - nstdev*yystd
      %                 yymin = yymean - nstdev*yystd;
      %         end
      ylim(1:2) = [yymin*1.2 yymax*1.1]; % JLC. Sept 26, 2012
      plotset = evalin('base', 'plotset');
      plotset.ptime.yscale = ylim;
      assignin('base','plotset', plotset);
end

%
% Baseline Correction
%
if ~strcmpi(blcorr,'no') && ~strcmpi(blcorr,'none')
        
        if strcmpi(blcorr,'pre')
                indxtimelock = find(ERP.times==0) ;   % zero-time locked
                aa = 1;
        elseif strcmpi(blcorr,'post')
                indxtimelock = length(ERP.times);
                aa = find(ERP.times==0);
        elseif strcmpi(blcorr,'all')
                indxtimelock = length(ERP.times);
                aa = 1;
        else
                toffsa = abs(round(ERP.xmin*fs))+1;   % +1 October 2nd 2008
                blcnum = str2num(blcorr)/1000;               % from msec to secs  03-28-2009
                
                %
                % Check & fix baseline range
                %
                if blcnum(1)<ERP.xmin
                        blcnum(1) = ERP.xmin;
                end
                if blcnum(2)>ERP.xmax
                        blcnum(2) = ERP.xmax;
                end
                
                plotset = evalin('base', 'plotset');
                plotset.ptime.blcorr = sprintf('%.0f  %.0f',blcnum*1000); % plotting memory for baseline correction
                assignin('base','plotset', plotset);
                aa     = round(blcnum(1)*fs)+ toffsa; % in samples 12-16-2008
                indxtimelock = round(blcnum(2)*fs) + toffsa  ;    % in samples
        end
        kk=1;
        for i=1:nch
                for j=1:nbin
                        baseline(kk) = mean(ERP.bindata(chArray(i),aa:indxtimelock,binArray(j)));  % baseline mean
                        dataaux(chArray(i),:,binArray(j)) = ERP.bindata(chArray(i),:,binArray(j)) - baseline(kk);
                        kk=kk+1;
                end
        end
        if yauto % JLC. Sept 26, 2012
           [blmax indxblmax] = max(abs(baseline));
           blx = baseline(indxblmax);
           ylim(1:2) = [ylim(1)-blx ylim(2)-blx];
           plotset = evalin('base', 'plotset');
           plotset.ptime.yscale = ylim;
           assignin('base','plotset', plotset);
        end
end

%
% Mean Global Field Power
%
if isMGFP
        nch = nch + 1;
        for j=1:nbin
                MGFP_data = std(ERP.bindata(chMGFP,:,binArray(j)));
                data_MGFP(1,:,binArray(j)) = MGFP_data;
                ERP.binerror(ERP.nchan+1,:, j)   = zeros(1, ERP.pnts ); % Sept 12, 2012. JLC
        end
        chArray = [chArray ERP.nchan+1];
end
if legepos==1
        row    = box(1)+1;% legend at button
        col    = box(2);
elseif legepos==2
        row    = box(1);
        col    = box(2) + 1; % cause the legend
else
        row    = box(1);
        col    = box(2);
end

%
% Creates each figure (per channel)
%
if isempty(ERP.filename) || strcmp(ERP.filename,'')
        ERP.filename = 'still_not_saved!';
end
if isempty(ERP.erpname)
        fname = 'none';
else
    [pathstr, fname, ext] = fileparts(ERP.erpname) ;
end

%
% Create figure
%
hbig = figure('Name',['<< ' fname ' >>  Interactive (Click on figure for larger image)'],...
    'NumberTitle','on', 'Tag','Plotting_ERP');

%
% Maximize figure?
%
if ismaxim
        maximize(hbig) ;
else
        if ~isempty(posfig)
                set(hbig, 'Position', posfig)
        end
end

%
% White figure background
%
set(hbig, 'Color', [1 1 1])
opengl('OpenGLBitmapZbufferBug',1)

%
% COLOR & Style
%
defs       = {'-' '-.' '--' ':'};% sorted according 1st erplab's version
defcol     = {'k' 'r' 'b' 'g' 'c' 'm' 'y' };

colorDef = regexp(linespec,'\w*','match');
colorDef = [colorDef{:}];
styleDef = regexp(linespec,'\W*','match');
styleDef = [styleDef{:}];

if isempty(colorDef)
        colorDef  = repmat(defcol,1, nbin*length(defs));% sorted according 1st erplab's version
        d = repmat(defs',1, nbin*length(defcol));
        styleDef = reshape(d',1, numel(d));
end
if isempty(styleDef)
        d = repmat(defs',1, nbin*length(defcol));
        styleDef = reshape(d',1, numel(d));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    EEGLAB topo plotting interfaced      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if pstyle==3 % topo      
        if isinvertedY
                tydir = -1;
        else
                tydir = 1;
        end
        
        if xlim(1)<round(ERP.xmin*1000)
                aux_xlim(1) = round(ERP.xmin*1000);
        else
                aux_xlim(1) = xlim(1);
        end
        if xlim(2)>round(ERP.xmax*1000)
                aux_xlim(2) = round(ERP.xmax*1000);
        else
                aux_xlim(2) = xlim(2);
        end
        
        [tp1 tp2 checkw xlimc ] = window2sample(ERP, aux_xlim(1:2) , fs, 'relaxed');
        
        if checkw==1
                error('ploterps() error: time window cannot be larger than epoch.')
        elseif checkw==2
                error('ploterps() error: too narrow time window')
        end
        
        legendt = ERP.bindescr(binArray);
        options ={ 'chanlocs' chanlocs 'legend' legendt  'limits' [xlimc ylim(1:2)] ...
                'title' '' 'chans' chArray 'ydir' tydir 'colors' linespec 'geom' [0 0] 'axsize' axsize};
        plottopo_II( dataaux(:, tp1:tp2, binArray), options{:})
else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  ERPLAB rectangular plotting    %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hplot    = [];
        if holdch
                row = 1;
                col = 2;
        end
        
        pboxTotal = 1:row*col;
        
        if legepos==1
                corners = linspace(row*col-col+1,row*col,col);
        elseif legepos==2
                corners   = linspace(col,row*col,row);
        else
                corners   = [];
        end
        
        pboxplot  = setxor(pboxTotal, corners);
        
        for i=1:nch
                if holdch
                        ich = 1;
                        row = 1;
                        col = 2;
                        cobi=(i-1)*nbin;
                        
                        if i==1
                                labelch = chanlocs(chArray(i)).labels;
                        elseif i==nch
                                if isMGFP
                                        labelch = 'MGFP';
                                else
                                        labelch = [labelch ' & ' chanlocs(chArray(i)).labels];
                                end
                        else
                                labelch = [labelch ' & ' chanlocs(chArray(i)).labels];
                        end
                else
                        ich     = i;
                        cobi    = 0;
                        if i==nch && isMGFP
                                labelch = 'MGFP';
                        else
                                labelch = chanlocs(chArray(i)).labels;
                        end
                end
                
                labelch = strrep(labelch,'_','\_'); % trick for dealing with '_'. JLC
                
                sp(ich) = subplot(row, col, pboxplot(ich));
                
                if pstyle==1
                        colorpl = [.7 .9 .7]; % Original
                else
                        colorpl = [1 1 1];
                end
                if isMGFP && i==nch
                        set(gca,'ydir','normal');
                        yposlabel = 1.08*max(ylim(1:2));
                        data4plot = data_MGFP;
                        ylim(1) = -0.1;
                else
                        if isinvertedY
                                set(gca,'ydir','reverse');
                                yposlabel = 1.05*min(ylim(1:2));
                        else
                                set(gca,'ydir','normal');
                                yposlabel = 1.08*max(ylim(1:2));
                        end
                        data4plot = dataaux(chArray(i),:,:);
                end
                
                legendArray = {[]};
                for ibin=1:nbin
                        hold on
                        if holdch
                                hplot(ibin+cobi) = plot(ERP.times, data4plot(1,:,binArray(ibin)),...
                                        'LineWidth',linew, 'Color', colorDef{ibin+cobi}, 'LineStyle',styleDef{ibin+cobi});
                                if binleg
                                        set(hplot(ibin+cobi),'DisplayName',...
                                                [labelch '>> BIN' num2str(binArray(ibin)) ': ' ERP.bindescr{binArray(ibin)}]);
                                else
                                        set(hplot(ibin+cobi),'DisplayName',...
                                                [labelch '>> ' ERP.bindescr{binArray(ibin)}]);
                                end
                        else
                                hplot(ibin) = plot(ERP.times, data4plot(1,:,binArray(ibin)),...
                                        'LineWidth',linew, 'Color', colorDef{ibin+cobi}, 'LineStyle',styleDef{ibin+cobi});
                                
                                %
                                % pending...
                                %
                                if ~isempty(ERP.binerror) && errorstd>=1
                                        yt1 = data4plot(1,:,binArray(ibin)) - ERP.binerror(chArray(i),:,binArray(ibin)).*errorstd;
                                        yt2 = data4plot(1,:,binArray(ibin)) + ERP.binerror(chArray(i),:,binArray(ibin)).*errorstd;
                                        ciplot(yt1,yt2, ERP.times, colorDef{ibin+cobi}, 0.2);
                                end
                                if binleg                                        
                                        legendArray{ibin} = ['BIN' num2str(binArray(ibin)) ': ' ERP.bindescr{binArray(ibin)}];                                        
                                else
                                        legendArray{ibin} = ERP.bindescr{binArray(ibin)};
                                end    
                                legendArray{ibin} = strrep(legendArray{ibin},'_','\_'); % trick for dealing with '_'. JLC
                                set(hplot(ibin),'DisplayName', legendArray{ibin});  
                        end
                        
                        
                end
                
                %
                % Set X and Y axis
                %
                axis([xlim(1:2) ylim(1:2)])
                
                if length(xlim)>2
                        set(gca,'XTick', xlim(3:end))
                end
                if minorticks(1)
                        set(gca,'XMinorTick','on')
                end
                if length(ylim)>2
                      set(gca,'YTick', ylim(3:end))
                end
                if minorticks(2)
                      set(gca,'YMinorTick','on')
                end
                
                if pstyle==1 % Matlab figure and menues
                      neozeroaxes(0)
                      comax = ['set(newfig, ''''Tag'''', ''''copiedf'''');'...
                            'neozeroaxes(0);'...
                            'legend show;'...
                            'legend(''''boxoff'''','...
                            '''''Location'''',''''SouthEast''''',...
                            '''''FontSize'''', 8)'];
                else % classic
                      neozeroaxes(1)
                      comax = ['set(newfig, ''''Tag'''', ''''copiedf'''');'...
                            'neozeroaxes(1);'...
                            'legend show;'...
                            'legend(''''boxoff'''','...
                            '''''Location'''',''''SouthEast''''',...
                            '''''FontSize'''', 8)'];
                end
                
                text(0,yposlabel, labelch, 'FontSize',fschan,'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'BackgroundColor', colorpl);
                set(gcf,'Color',[1 1 1]);
                drawnow               
                axcopy(sp(ich), comax);
        end
        
        %
        % Legend
        %
        if legepos~=4
                switch legepos
                        case {1,2}
                                sh = subplot(row, col, corners);
                        case 3
                                pf  = get(hbig,'position');
                                figure('Name',['<< ' fname ' >>  BIN''s LEGEND'],'NumberTitle','on',...
                                        'MenuBar','none', 'Tag','Plotting_ERP', 'Color',[1 1 1],...
                                        'Position',[ pf(1) pf(2) pf(3)/2.5 pf(4)]);
                                sh = subplot(1, 1, 1);
                end
                p  = get(sh,'position');
                h_legend = legend(sh, hplot );
                set(h_legend, 'position', p);
                set(h_legend,'FontSize',fslege);
                legend(sh,'boxoff')
                %axcopy(h_legend, 'set(newfig, ''''Tag'''', ''''copiedf'''')'); % Tag for new pop-up figures (external legend)
                axis(sh,'off')
        end
        hold off
end
% if ismaxim
%       maximize(hbig) ;  %  If you want to maximize full figure automatically
% end
assignin('base','bigpicture', hbig);

% fprintf('ploterps.m : END\n');
