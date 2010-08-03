%   >> pop_ploterps(ERP, binArray, chanArray, options)
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
% Inputs:
%
%   ERP       - input dataset
%   BinArray  - index(es) of bin(s) to plot  ( 1 2 3 ...)
%   chanArray   - index(es) of channel(s) to plot ( 1 2 3 ...)
%
% Options...........{default_value}...................................description
%
% 'Mgfp'............{[]}..............................................Channel array for mean global field power
% 'Blc'.............{'none'}..........................................base line correction (only for plotting)  'pre', 'post', 'all' or 2 values in ms
% 'xscale'..........{[round(ERP.xmin*1000) round(ERP.xmax*1000)]}.....[min max] ms for time scale
% 'yscale'..........{[-10 10]}........................................[min max] uVolts for amplitude scale
% 'LineWidth'.......{2}...............................................width line for curves
% 'YDir'............{'normal'}........................................direction of Y axis. 'normal' means positive up.
% 'FontSizeChan'....{10}..............................................font size for channel labels
% 'FontSizeLeg'.....{10}..............................................font size for bin legends
% 'Style'...........{'Matlab'}........................................plotting style: 'Matlab','ERP' or 'Topo'
% 'Std'.............{'off'}...........................................show standard deviation (under construction)
% 'Box'.............{sqrt(ERP.nchan)+1 sqrt(ERP.nchan)}...............row and columns for subplot
% 'HoldCh'..........{'off'}...........................................plot specified channels overlapped in 1 figure
% 'AutoYlim'........{'off'}...........................................automatic Y limits ('on' means yscale is ignored)
% 'BinNum'..........{'off'}...........................................show bin number on bin legends
% 'LegPos'..........{'bottom'}........................................bin legend position: 'bottom','right', or 'external'
% 'Maximize'........{'off'}...........................................maximize the plotted figuere (full screen)
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

function [erpcom] = pop_ploterps(ERP, binArray, chanArray, varargin)

erpcom = '';

if nargin < 1
      help pop_ploterps
      return
end

if ~isfield(ERP,'bindata') %(ERP.bindata)
      msgboxText{1} =  'Error: cannot plot an empty ERP dataset';
      title_msg = 'ERPLAB: pop_ploterps() error:';
      errorfound(msgboxText, title_msg);
      return
end

if nargin==1  %with GUI
      countp = 0;
      while 1
            
            plotset   = ploterpGUI;   % call GUI for plotting
            
            if isempty(plotset.ptime)
                  disp('User selected Cancel')
                  return
                  
            elseif strcmpi(plotset.ptime,'pdf')
                  
                  erpcom2 = pop_fig2pdf;
                  
                  if countp>0
                        disp('pop_fig2pdf was called')
                  else
                        disp('WARNING: Matlab figure(s) might have been generated during a previous round....')
                  end
                  erpcom = [erpcom ' ' erpcom2];
                  return
                  
            elseif strcmpi(plotset.ptime,'scalp')
                  disp('User called pop_scalplot()')
                  return
            end
            
            if plotset.ptime.istopo==1
                  %
                  % Searching channel location
                  %
                  if isfield(ERP.chanlocs, 'theta')
                        ERP = borrowchanloc(ERP);
                  else
                        question = cell(1);
                        question{1} = 'This averaged ERP has not channel location info.';
                        question{2} = 'Would you like to load it now?';
                        title_msg   = 'ERPLAB: Channel location';
                        button   = askquest(question, title_msg);
                        
                        if ~strcmpi(button,'yes')
                              disp('User selected Cancel')
                              return
                        else
                              ERP = borrowchanloc(ERP);
                        end
                  end
            end
            
            plotset.ptime.binArray  = plotset.ptime.binArray(plotset.ptime.binArray<=ERP.nbin);
            plotset.ptime.chanArray = plotset.ptime.chanArray(plotset.ptime.chanArray<=ERP.nchan);
            plotset.ptime.chanArray_MGFP = plotset.ptime.chanArray_MGFP(plotset.ptime.chanArray_MGFP<=ERP.nchan);
            
            if isempty(plotset.ptime.chanArray)
                  msgboxText =  'Specified channel(s) did not have a valid channel location.';
                  title_msg  = 'ERPLAB: pop_ploterps() missing info:';
                  errorfound(msgboxText, title_msg)
                  return
            end
            
            if plotset.ptime.xscale(1) < ERP.xmin*1000
                  plotset.ptime.xscale(1) = ERP.xmin*1000;
            end
            
            if plotset.ptime.xscale(2) > ERP.xmax*1000
                  plotset.ptime.xscale(2) = ERP.xmax*1000;
            end
            
            if ~isfield(plotset.ptime, 'posfig')
                  plotset.ptime.posfig = [];
            end
            
            findplot = findobj('Tag','Plotting_ERP');
            
            if ~isempty(findplot)
                  gofig = 1;
                  while gofig>0 && gofig<= length(findplot)
                        lastfig = figure(findplot(gofig));
                        posfx   = get(lastfig,'Position');
                        
                        if posfx(3)>=1 && posfx(4)>=1
                              plotset.ptime.posfig = [posfx(1)+10 posfx(2)-15 posfx(3) posfx(4) ];
                              gofig = 0;
                        else
                              gofig = gofig + 1;
                              
                        end
                  end
            end
            
            assignin('base','plotset', plotset);
            
            binArray      = plotset.ptime.binArray;
            chanArray     = plotset.ptime.chanArray;
            ichMGFP       = plotset.ptime.chanArray_MGFP;
            iblcorr       = plotset.ptime.blcorr;
            ixscale       = plotset.ptime.xscale;
            iyscale       = plotset.ptime.yscale;
            ilinewidth    = plotset.ptime.linewidth;
            iisiy         = plotset.ptime.isiy;
            ifschan       = plotset.ptime.fschan;
            ifslege       = plotset.ptime.fslege;
            imeap         = plotset.ptime.meap;
            ierrorstd     = plotset.ptime.errorstd;
            ibox          = plotset.ptime.box;
            %icounterwin   = plotset.ptime.counterwin;
            iholdch       = plotset.ptime.holdch;
            iyauto        = plotset.ptime.yauto;
            ibinleg       = plotset.ptime.binleg;
            
            ichanleg      = plotset.ptime.chanleg; % @@@@@@@@@@@@@@@@@@@
            
            %iisMGFP       = plotset.ptime.isMGFP;
            ilegepos      = plotset.ptime.legepos;
            iistopo       = plotset.ptime.istopo;
            ismaxim       = plotset.ptime.ismaxim;
            posfig        = plotset.ptime.posfig;
            axsize        = plotset.ptime.axsize;
            
            if iyauto==1
                  rAutoYlim = 'on';
            else
                  rAutoYlim = 'off';
            end
            
            if ibinleg==1
                  rBinNum = 'on';
            else
                  rBinNum = 'off';
            end
             
            if ichanleg==1 % @@@@@@@@@@
                  rchanlabel = 'on'; % show ch label
            else
                  rchanlabel = 'off'; % show ch number
            end         
            
            if iholdch==1
                  rHoldCh = 'on';
            else
                  rHoldCh = 'off';
            end
            if ilegepos==1
                  rLegPos = 'bottom';
            elseif ilegepos==2
                  rLegPos = 'right';
            else
                  rLegPos = 'external';
            end
            
            if ierrorstd==1
                  rStd = 'on';
            else
                  rStd = 'off';
            end
            if iistopo == 0;
                  if imeap==1
                        rStyle = 'Matlab';
                  else
                        rStyle = 'ERP';
                  end
            else
                  rStyle = 'Topo';
            end
            
            if iisiy==1
                  rYDir = 'reverse';
            else
                  rYDir = 'normal';
            end
            if ismaxim==1
                  rismaxim = 'on';
            else
                  rismaxim = 'off';
            end
            
            erpcom = pop_ploterps(ERP, binArray, chanArray, 'AutoYlim',rAutoYlim,'BinNum',rBinNum,'Blc',iblcorr,'Box',ibox,...
                  'FontSizeChan',ifschan,'FontSizeLeg',ifslege, 'HoldCh',rHoldCh,'LegPos',rLegPos,...
                  'LineWidth',ilinewidth,'Mgfp',ichMGFP,'Std',rStd,'Style',rStyle,'xscale',ixscale,'YDir',rYDir,...
                  'yscale',iyscale, 'Maximize', rismaxim, 'Position', posfig, 'axsize', axsize, 'ChLabel', rchanlabel); % @@@@@@@
            pause(0.1)
            countp = countp + 1;
      end
      
      return
      
else
      aa = round(sqrt(ERP.nchan));
      boxd = [aa+1 aa];
      
      p = inputParser;
      p.FunctionName  = mfilename;
      p.CaseSensitive = false;
      p.addRequired('ERP', @isstruct);
      p.addRequired('binArray', @isnumeric);
      p.addRequired('chanArray', @isnumeric);
      p.addParamValue('Mgfp', [], @isnumeric);
      p.addParamValue('Blc', 'none', @ischar);
      p.addParamValue('xscale', [round(ERP.xmin*1000) round(ERP.xmax*1000)], @isnumeric);
      p.addParamValue('yscale', [-10 10], @isnumeric);
      p.addParamValue('LineWidth', 2, @isnumeric);
      p.addParamValue('YDir', 'normal', @ischar); % normal | reverse
      p.addParamValue('FontSizeChan', 10, @isnumeric);
      p.addParamValue('FontSizeLeg', 10, @isnumeric);
      p.addParamValue('Style', 'Matlab', @ischar); %Matlab | ERP | Topo
      p.addParamValue('Std', 'off', @ischar);
      p.addParamValue('Box', boxd, @isnumeric);
      p.addParamValue('HoldCh', 'off', @ischar);
      p.addParamValue('AutoYlim', 'off', @ischar);
      p.addParamValue('BinNum', 'off', @ischar);
      
      p.addParamValue('ChLabel', 'on', @ischar); %@@@@@@@@@@@@@@@      
      
      p.addParamValue('LegPos', 'bottom', @ischar); % right | external
      p.addParamValue('Maximize', 'off', @ischar); % off | on
      p.addParamValue('Position', [], @isnumeric); % off | on
      p.addParamValue('Axsize', [], @isnumeric); % size ([w h] ) for each channel when topoplot is being used.
      
      p.parse(ERP, binArray, chanArray, varargin{:});
      
      qMgfp   = p.Results.Mgfp;
      qBlc    = p.Results.Blc;
      qxscale = p.Results.xscale;
      qyscale = p.Results.yscale;
      qBox    = p.Results.Box;
      qLineWidth    = p.Results.LineWidth;
      qFontSizeChan = p.Results.FontSizeChan;
      qFontSizeLeg  = p.Results.FontSizeLeg;
      qaxsize  = p.Results.Axsize;
      
      if strcmpi(p.Results.Style,'Topo')
            qistopo = 1;
            qmeap   = 1;
      else
            qistopo = 0;
            if strcmpi(p.Results.Style,'Matlab')
                  qmeap = 1;
            else
                  qmeap = 0;
            end
      end
      if strcmpi(p.Results.YDir,'reverse')
            qisiy = 1;
      else
            qisiy = 0;
      end
      if strcmpi(p.Results.Std,'on')
            qerrorstd = 1;
      else
            qerrorstd = 0;
      end
      if strcmpi(p.Results.HoldCh,'on')
            qholdch = 1;
      else
            qholdch = 0;
      end
      if strcmpi(p.Results.AutoYlim,'on')
            qyauto = 1;
      else
            qyauto = 0;
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
      else
            qlegepos = 3;
      end
      if strcmpi(p.Results.Maximize,'on')
            ismaxim = 1;
      else
            ismaxim = 0;
      end
      
      posfig = p.Results.Position;
end

if qistopo
      if ~isfield(ERP.chanlocs,'theta')
            msgboxText{1} =  ['Error: ' ERP.erpname ' has not channel location info.'];
            msgboxText{2} =  'Topographic plot will be terminated.';
            title_msg = 'ERPLAB: pop_ploterps() missing info:';
            errorfound(msgboxText, title_msg);
            return
      end
end

%
% Check & fix time range
%
if qxscale(1)/1000<ERP.xmin
      qxscale(1)=ERP.xmin*1000;
end
if qxscale(2)/1000>ERP.xmax
      qxscale(2)=ERP.xmax*1000;
end

plotset = evalin('base', 'plotset');
plotset.ptime.xscale = qxscale; % plotting memory for time window
assignin('base','plotset', plotset);
BinArraystr  = vect2colon(binArray, 'Sort','yes');
chanArraystr = vect2colon(chanArray);

%@@@@@@@@@@@@@@@@@@@@@@
ploterps(ERP, binArray, chanArray,  qistopo, qMgfp, qBlc, qxscale, qyscale,...
         qLineWidth, qisiy, qFontSizeChan, qFontSizeLeg, qmeap, qerrorstd,...
         qBox, qholdch, qyauto, qbinleg, qlegepos, ismaxim, posfig, qaxsize,...
         qchanleg)

%
% History command
%
fn = fieldnames(p.Results);
erpcom = sprintf( 'pop_ploterps( %s, %s, %s ',  inputname(1), BinArraystr, chanArraystr);

for q=1:length(fn)
      fn2com = fn{q};
      if ~ismember(fn2com,{'ERP','binArray','chanArray'})
            fn2res = p.Results.(fn2com);
            if ~isempty(fn2res)
                  if ischar(fn2res)
                        if ~strcmpi(fn2res,'off')
                              erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                        end
                  else
                        erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
                  end
            end
      end
end
erpcom = sprintf( '%s );', erpcom);
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
