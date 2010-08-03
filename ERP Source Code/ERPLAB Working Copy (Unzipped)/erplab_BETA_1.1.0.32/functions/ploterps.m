%   >> ploterps(ERP, binArray, chArray, blcorr, xlim, ylim, linew, isinvertedY, fschan, fslege, ismeap, errorstd, box)

%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
% Inputs:
%
%   ERP       - input dataset
%   binArray  - index(es) of bin(s) to plot  ( 1 2 3 ...)
%   chArray   - index(es) of channel(s) to plot ( 1 2 3 ...)
%   blcorr    - string or numeric interval for baseline correction
%               reference window: 'no','pre','post','all', or for
%               instance [-100 0]
%   xlim        - time window to plot: [t1 t2]. e.g. [-200 800]
%   ylim        - amplitude scale to plot: [a1 a2]. e.g. [-5 10]
%   linew        - waveform line width
%   isiy      - string. "Y" axis is inverted (-UP)?:  'yes', 'no'
%   fschan    - font size for channel labels
%   fslege    - font size for legends
%   ismeap      - string. 'yes'=toolbar on,  'no'=toolbar off and "zero x
%               axis plotting"
%   errorstd  - string. 'yes'=create a Standar Deviation Strucure of you ERP
%               'no'= do nothing.
%   box       - ditribution of plotting boxes in rows x columns.
%               Important Note: rows*columns >= length(chArray)
%
% Outputs:
%
%   figure on the screen
%
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

function ploterps(ERP, binArray, chArray, istopo, chMGFP,  blcorr, xlim,...
                  ylim, linew, isinvertedY, fschan, fslege, ismeap, errorstd,...
                  box, holdch, yauto, binleg, legepos, ismaxim, posfig, axsize,...
                  chanleg)

if nargin<1
        help ploterps
        return
end
if nargin<23
        chanleg = 1; % 1 means show channel labels
end
if nargin<22
        axsize = [0.05 0.08]; % for topographic view only
end
if nargin<21
        posfig = []; % figure position
end
if nargin<20
        ismaxim = 0; % no maximize figure
end
if nargin<19
        legepos = 1;
end
if nargin<18
        binleg = 1;
end
if nargin<17
        yauto = 1;
end
if nargin<16
        holdch = 0;
end
if nargin<15
        aa = round(sqrt(ERP.nchan));
        box = [aa+1 aa];
end
if nargin<14
        errorstd = 0;
end
if nargin<13
        ismeap = 1;
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
        istopo = 0;
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

fprintf('ploterps.m : START\n');

%
% In case there is not channel labels, or chanleg =0 (do not show labels)
%

chanlocs = ERP.chanlocs;
if isempty(chanlocs) || chanleg==0
        for cc =1:ERP.nchan
                chanlocs(cc).labels = ['Ch:' num2str(cc)];
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
        
        [p1 p2 checkw] = window2sample(ERP, xlim , fs);
        
        if checkw==1
                error('ploterps() error: time window cannot be larger than epoch.')
        elseif checkw==2
                error('ploterps() error: too narrow time window')
        end
        
        nstdev  = 25;
        datresh = reshape(dataaux(chArray,p1:p2,binArray), 1, (p2-p1+1)*nbin*nch);
        yymean  = mean(datresh);
        yystd   = std(datresh);
        
        yymax   = max(datresh);
        
        if yymax > yymean + nstdev*yystd
                yymax = yymean + nstdev*yystd;
        end
        
        yymin = min(datresh);
        
        if yymin < yymean - nstdev*yystd
                yymin = yymean - nstdev*yystd;
        end
        
        ylim = [yymin-1 yymax+1];
        plotset = evalin('base', 'plotset');
        plotset.ptime.yscale = ylim;
        assignin('base','plotset', plotset);
end

%
% Baseline Correction
%
if ~strcmpi(blcorr,'no') && ~strcmpi(blcorr,'none')
        
        if strcmpi(blcorr,'pre')
                indxtimelock = find(ERP.times==0);    % zero-time locked
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
        
        for i=1:nch
                for j=1:nbin
                        baseline = mean(ERP.bindata(chArray(i),aa:indxtimelock,binArray(j)));  % baseline mean
                        dataaux(chArray(i),:,binArray(j)) = ERP.bindata(chArray(i),:,binArray(j)) - baseline;
                end
        end
end
if isMGFP
        nch = nch + 1;
        for j=1:nbin
                MGFP_data = std(ERP.bindata(chMGFP,:,binArray(j)));
                data_MGFP(1,:,binArray(j)) = MGFP_data;
        end
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
        [pathstr, fname, ext, versn] = fileparts(ERP.erpname) ;
end
if ismeap
        hbig = figure('Name',['<< ' fname ' >>  Measuring Purpose (Click on figure for larger image)'],...
                'NumberTitle','on', 'Tag','Plotting_ERP');
        
else
        hbig = figure('Name',['<< ' fname ' >>  Printing Purpose (Non interactive)'],'NumberTitle','on',...
                'MenuBar','none', 'Tag','Plotting_ERP');
end
if ~isempty(posfig)
        set(hbig, 'Position', posfig)
end

%
% White figure background
%
set(hbig, 'Color', [1 1 1])

opengl('OpenGLBitmapZbufferBug',1)

%
% COLOR & Style
%
colorDef =['k  ';'r  ';'b  ';'g  ';'c  ';'m  '];
styleDef ={'- ';'- ';'- ';'- ';'- ';'- ';'-.';'-.';'-.';'-.';'-.';'-.';...
        '--';'--';'--';'--';'--';'--';': ';': ';': ';': ';': ';': '};
styleDef = repmat(styleDef, 7,1);  % Until 168 bins
colorDef = repmat(colorDef, 28,1); % Until 168 bins

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    EEGLAB topo plotting interfaced      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if istopo
        colstr = strrep(cellstr([colorDef char(styleDef)]),' ','')';
        
        if isinvertedY
                tydir = -1;
        else
                tydir = 1;
        end
        
        toffsa = abs(round(ERP.xmin*fs))+1;        % 
        tp1    = round(xlim(1)*fs/1000)+ toffsa;   % in samples 
        tp2    = round(xlim(2)*fs/1000) + toffsa;  % in samples
        
        legendt = ERP.bindescr(binArray);
        options ={ 'chanlocs' chanlocs 'legend' legendt  'limits' [xlim ylim] ...
                'title' '' 'chans' chArray 'ydir' tydir 'colors' colstr 'geom' [0 0] 'axsize' axsize};
        
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
        elseif legepos==3
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
                
                sp(ich) = subplot(row, col, pboxplot(ich));
                
                if ismeap
                        colorpl = [.7 .9 .7]; % Original
                else
                        colorpl = [1 1 1];
                end
                
                if isMGFP && i==nch
                        set(gca,'ydir','normal');
                        yposlabel = 1.08*max(ylim);
                        data4plot = data_MGFP;
                        ylim(1) = -0.1;
                else
                        if isinvertedY
                                set(gca,'ydir','reverse');
                                yposlabel = 1.05*min(ylim);
                        else
                                set(gca,'ydir','normal');
                                yposlabel = 1.08*max(ylim);
                        end
                        data4plot = dataaux(chArray(i),:,:);
                end
                
                for ibin=1:nbin
                        
                        hold on
                        if holdch
                                hplot(ibin+cobi) = plot(ERP.times, data4plot(1,:,binArray(ibin)),...
                                        'LineWidth',linew, 'Color', colorDef(ibin+cobi), 'LineStyle',styleDef{ibin+cobi});
                                if binleg
                                        set(hplot(ibin+cobi),'DisplayName',...
                                                [labelch '>> BIN' num2str(binArray(ibin)) ': ' ERP.bindescr{binArray(ibin)}]);
                                else
                                        set(hplot(ibin+cobi),'DisplayName',...
                                                [labelch '>> ' ERP.bindescr{binArray(ibin)}]);
                                end
                        else
                                hplot(ibin) = plot(ERP.times, data4plot(1,:,binArray(ibin)),...
                                        'LineWidth',linew, 'Color', colorDef(ibin+cobi), 'LineStyle',styleDef{ibin+cobi});
                                
                                %
                                % pending...
                                %
                                if ~isempty(ERP.binerror) && errorstd
                                        yt1 = data4plot(1,:,binArray(ibin)) - ERP.binerror(chArray(i),:,binArray(ibin));
                                        yt2 = data4plot(1,:,binArray(ibin)) + ERP.binerror(chArray(i),:,binArray(ibin));
                                        ciplot(yt1,yt2, ERP.times, colorDef(ibin+cobi), 0.2);
                                end
                                
                                if binleg
                                        set(hplot(ibin),'DisplayName', ...
                                                ['BIN' num2str(binArray(ibin)) ': ' ERP.bindescr{binArray(ibin)}]); %,...
                                else
                                        set(hplot(ibin),'DisplayName', ERP.bindescr{binArray(ibin)});
                                end
                        end
                end

                axis([xlim ylim])

                if ismeap
                        line(xlim,[0 0],'LineWidth',1,'Color',colorpl,'Marker','.','LineStyle','--','LineWidth',1);
                        line([0 0],ylim,'LineWidth',1,'Color',colorpl,'Marker','.','LineStyle','--','LineWidth',1);
                        axcopy(sp(ich), 'set(newfig, ''''Tag'''', ''''copiedf'''')'); % Tag for new pop-up figures
                else
                        zeroaxes
                end

                text(0,yposlabel, labelch, 'FontSize',fschan,'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'BackgroundColor',colorpl);
                set(gcf,'Color',[1 1 1]);
        end
        
        if legepos==3  % external
                pf  = get(hbig,'position');
                figure('Name',['<< ' fname ' >>  BIN''s LEGEND'],'NumberTitle','on',...
                        'MenuBar','none', 'Tag','Plotting ERP', 'Color',[1 1 1],...
                        'Position',[ pf(1) pf(2) pf(3)/2.5 pf(4)]);
                sh = subplot(1, 1, 1);
        else
                sh = subplot(row, col, corners);
        end
        p  = get(sh,'position');
        h_legend = legend(sh, hplot );
        set(h_legend, 'position', p);
        set(h_legend,'FontSize',fslege);
        legend(sh,'boxoff')
        axcopy(h_legend, 'set(newfig, ''''Tag'''', ''''copiedf'''')'); % Tag for new pop-up figures (external legend)
        axis(sh,'off')
        hold off
end

if ismaxim
        maximize(hbig) ;  %  If you want to maximize full figure automatically
end
assignin('base','bigpicture', hbig);

fprintf('ploterps.m : END\n');
