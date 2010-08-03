% >> pop_scalplot(ERP, binArray, latencyArray, measurestr, ...
%        exchanArray, baseline,  maplimit, isagif)
%
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
%
% Inputs:
%
%   ERP       - input dataset
%
%
% Outputs:
%
%   figure on the screen
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

function [erpcom] = pop_scalplot(ERP, binArray, latencyArray, measurestr, ...
      baseline,  maplimit, colorbari, isagif, DelayT, fullgifname, binleg, showelec, posfig)

erpcom = '';

if nargin < 1
      help pop_scalplot
      return
end
if isempty(ERP)
      msgboxText{1} =  'Error: cannot plot an empty ERP dataset';
      title_msg = 'ERPLAB: pop_scalplot() error:';
      errorfound(msgboxText, title_msg);
      return
end
if ~isfield(ERP, 'bindata')
      msgboxText{1} =  'Error: pop_scalplot cannot operate an empty ERP dataset';
      title_msg = 'ERPLAB: pop_scalplot() error:';
      errorfound(msgboxText, title_msg);
      return
end
if isempty(ERP.bindata)
      msgboxText{1} =  'Error: pop_scalplot cannot operate an empty ERP dataset';
      title_msg = 'ERPLAB: pop_scalplot() error:';
      errorfound(msgboxText, title_msg);
      return
end

%
% Searching channel location
%
if isfield(ERP.chanlocs, 'theta')
      ERP = borrowchanloc(ERP);
else
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

nvar = 1;

if nargin==nvar  %with GUI
      
      countp = 0;
      while 1
            erpcom  = '';
            plotset = scalplotGUI(ERP); %GUI
            
            if isempty(plotset.pscalp)
                  disp('User selected Cancel')
                  if countp>0
                        
                        isagifstr = num2str(isagif);
                        binArraystr = vect2colon(binArray,  'Delimiter','no');
                        
                        if size(latencyArray,1)==1
                              latencystr  = vect2colon(latencyArray, 'Delimiter','no');
                        else
                              for i=1:size(latencyArray,1)
                                    if i==1
                                          latencystr  = num2str(latencyArray(i,:));
                                    else
                                          latencystr  = [latencystr ';' num2str(latencyArray(i,:))];
                                    end
                              end
                        end
                        
                        if isnumeric(baseline)
                              baselinestr = ['[' num2str(baseline) ']'];
                        else
                              baselinestr = ['''' baseline ''''];
                        end
                        
                        if isnumeric(maplimit)
                              maplimitstr = ['[' num2str(maplimit) ']'];
                        else
                              maplimitstr = ['''' maplimit ''''];
                        end
                        
                        delaystr = num2str(DelayT);
                        
                        if isempty(delaystr)
                              delaystr = '[]';
                        end
                        
                        posfigstr = vect2colon(posfig);
                        
                        erpcom = sprintf( 'pop_scalplot( %s, [%s], [%s], ''%s'', %s, %s, ''%s'', %s, %s, ''%s'', %s);', inputname(1), binArraystr, latencystr,...
                              measurestr, baselinestr, maplimitstr, colorbari, isagifstr, delaystr, fullgifname, posfigstr);
                  end
                  try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end 
                  return
                  
            elseif strcmpi(plotset.pscalp,'pdf')
                  pop_fig2pdf;
                  return
            end
            
            plotset.pscalp.binArray  = plotset.pscalp.binArray(plotset.pscalp.binArray<=ERP.nbin);
            
            if ~isfield(plotset.pscalp, 'posfig')
                  plotset.pscalp.posfig = [];
            end
            
            findplot = findobj('Tag','Scalp');
            
            if ~isempty(findplot)
                  lastfig    = figure(findplot(1));
                  posfx = get(lastfig,'Position');
                  plotset.pscalp.posfig = [posfx(1)+10 posfx(2)-15 posfx(3) posfx(4) ];
            end
            
            assignin('base','plotset', plotset);
            binArray     = plotset.pscalp.binArray;
            latencyArray = plotset.pscalp.latencyArray;
            measurestr   = plotset.pscalp.measurement;
            baseline     = plotset.pscalp.baseline;
            maplimit     = plotset.pscalp.cscale;
            clrbar       = plotset.pscalp.colorbar;
            isagif       = plotset.pscalp.agif.value;
            DelayT       = plotset.pscalp.agif.delay;
            fullgifname  = plotset.pscalp.agif.fname;
            binleg       = plotset.pscalp.binleg;
            showelec     = plotset.pscalp.showelec;
            posfig       = plotset.pscalp.posfig;
            
            if clrbar==1
                  colorbari = 'on';
            else
                  colorbari = 'off';
            end
            
            pop_scalplot(ERP, binArray, latencyArray, measurestr, ...
                  baseline,  maplimit, colorbari, isagif, DelayT, fullgifname, binleg, showelec, posfig);
            pause(0.1)
            countp = countp + 1;
      end
      return
      
else %without GUI
      
      if nargin>13
            error('ERPLAB says: error at pop_scalplot, too many inputs!!!');
      end
      if nargin<13
            posfig = [];
      end
      if nargin<12
            showelec = 1;
      end
      if nargin<11
            binleg = 1;
      end
      if nargin<10
            fullgifname = '';
      end
      if nargin<9
            DelayT = 0;
      end
      if nargin<8
            isagif = 0;
      end
      if nargin<7
            colorbari = 'on';
      end
      if nargin<6
            maplimit = 'maxmin';
      end
      if nargin<5
            baseline = 'pre';
      end
      if nargin<4
            measurestr = 'insta';
      end
      if nargin<3
            error('ERPLAB says: error at pop_scalplot. You must enter 3 inputs at least!');
      end
      
      if strcmpi(colorbari, 'on')
            clrbar = 1;
      else
            clrbar = 0;
      end
end

indxh   = find(latencyArray>ERP.xmax*1000,1);

if ~isempty(indxh)
      msgboxText{1} =  ['Latency of ' num2str(latencyArray(indxh)) ' is greater than ERP.xmax = ' num2str(ERP.xmax*1000) ' msec!'];
      title_msg = 'ERPLAB: pop_scalplot() error:';
      errorfound(msgboxText, title_msg);
      pop_scalplot(ERP);
      return
end

indxl  = find(latencyArray<ERP.xmin*1000,1);

if ~isempty(indxl)
      msgboxText{3} =  ['Latency of ' num2str(latencyArray(indxl)) ' is lesser than ERP.xmin = ' num2str(ERP.xmin*1000) ' msec!'];
      title_msg = 'ERPLAB: pop_scalplot() error:';
      errorfound(msgboxText, title_msg);
      pop_scalplot(ERP);
      return
end

toffsa    = abs(round(ERP.xmin*ERP.srate))+1;
latArray  = round(latencyArray.*ERP.srate/1000) + toffsa;   %sec to samples
nbin      = length(binArray);

if strcmp(measurestr, 'insta')
      nlat = size(latArray,2);  % only one row array should be defined. e.g. 120 or [0 50 120 350]
else
      nlat = size(latArray,1);  % couples of latencyes can be defined. e.g [50 100; 120 350; 400 600]
end
if showelec==1
      showe = 'on';
else
      showe = 'off';
end
wi   = 0.9/nlat;
hi   = 0.9/nbin;
bdwidth = 30; topbdwidth = 30;
set(0,'Units','pixels')
scnsize = get(0,'ScreenSize');
pos1    = [bdwidth, (1/3)*scnsize(4) + bdwidth, scnsize(3)/4 - 2*bdwidth, scnsize(4)/3 - (topbdwidth + bdwidth)];

%
% If there is a previous "scal map" figure open, then "steal" its dimensions, otherwise set it as default
%

find2 = findobj('Tag','Scalp');

if ~isempty(find2)
      %fig2    = figure(find2(end));
      pos2 = get(find2,'Position');
else
      pos2 = [bdwidth, (1/5)*scnsize(4) + bdwidth, scnsize(3)/2, 0.7*scnsize(4)];
end

if isempty(ERP.erpname)
      fnamet = 'none';
else
      [pathstrt, fnamet, extt, versnt] = fileparts(ERP.erpname) ;
end

if isagif==0
      hsig    = figure('Position',pos1, 'Name',['<< ' fnamet ' >>  Plot ERP map by Bins x latency'],...
            'NumberTitle','off', 'Tag','Scalp');
      if ~isempty(posfig)
            set(hsig, 'Position', posfig)
      end
      nadj = 1;
else
      fra = 1;
      if isagif==2  % adjust first frame size
            nadj =2;
      else
            nadj = 1;
      end
end

%
% Drawing loops
%
iadj = 1;
continueplot = 1;

while iadj<=nadj && continueplot
      for ilat =1:nlat
            
            if isagif>0
                  hsig    = figure('Position',pos2, 'Name',['<< Frame ' num2str(fra) ' >>'],...
                        'NumberTitle','off', 'Tag','Scalp');
                  if ~isempty(posfig)
                        set(hsig, 'Position', posfig)
                  end
            end
            
            for ibin=1:nbin
                  
                  if isagif>0
                        axes('position',[0.05  0.05+hi*(nbin-ibin)  0.9  hi])
                  else
                        axes('position',[0.05+wi*(ilat-1)  0.05+hi*(nbin-ibin)  wi  hi])
                  end
                  
                  if nlat>=1 && ~strcmp(measurestr, 'insta')
                        latetitle = [num2str(latencyArray(ilat,1)) '-' num2str(latencyArray(ilat,2))];
                  else
                        latetitle = num2str(latencyArray(ilat));
                  end
                  
                  %
                  % Bin Legend
                  %
                  if binleg
                        title(['BIN:' num2str(binArray(ibin)) ' = '  ERP.bindescr{binArray(ibin)} ', MEA:'''  measurestr ''' LAT:' latetitle], 'FontSize', 10) % Two line title
                  else
                        title([ERP.bindescr{binArray(ibin)} ', MEA:'''  measurestr ''' LAT:' latetitle], 'FontSize', 10) % Two line title
                  end
                  
                  set(get(gca,'Title'),'Position', [-0.004 0.588 4])
                  
                  if ~isnumeric(baseline)
                        if ismember(baseline, {'pre' 'post' 'all' 'none'})
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
                        case 'area'
                              data2plot = geterpvalues(ERP, [latArray(ilat,1) latArray(ilat,2)],...
                                    binArray(ibin), 1:ERP.nchan, 'area', baseline, 1)';
                        case 'lapla'
                              data2plot = del2map( datap(:,latArray(ilat)), '/Users/javlopez/Desktop/AAAAAAAAAAAAAA.loc');
                  end
                  
                  if strcmpi(maplimit,'auto') && ilat==1
                        maplimit = [min(data2plot) max(data2plot)];
                  end
                  
                  try
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %                  Plot scalp map, at current latency, current bin                     %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        topoplot( data2plot, ERP.chanlocs,...
                              'style', 'fill', 'plotrad',0.53, 'headrad', 0.516, 'emarker', {'o','k',8,1},...
                              'numcontour',12, 'maplimits', maplimit, 'electrodes', showe);
                        set(gcf,'Color', [1 1 1])
                        
                        if isagif==0
                              axcopy(gca)
                        end
                  catch
                        msgboxText =  'Error: pop_scalplot cannot work with this channel locations info.';
                        title_msg = 'ERPLAB: pop_scalplot() error:';
                        errorfound(msgboxText, title_msg);
                        return
                  end
                  
                  %
                  % Color Bar
                  %
                  if clrbar==1
                        colorbar('location','EastOutSide');
                  end
            end
            
            drawnow
            
            %
            % Stack for AGIF
            %
            if isagif>0
                  
                  if isagif==2 && iadj==1 % agif --> Adjust frame size
                        
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
                              isagif = 0;
                        else
                              
                              findplot = findobj('Tag','Scalp');
                              
                              if ~isempty(findplot)
                                    lastfig = figure(findplot(1));
                                    posfig   = get(lastfig,'Position');
                                    plotset = evalin('base', 'plotset');
                                    plotset.pscalp.posfig = posfig;
                                    assignin('base','plotset', plotset);
                              end
                        end
                        close(hsig)
                        break
                  end
                  
                  %set(hsig,'nextplot','replacechildren','visible','off')
                  
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
                  im(:,:,1,fra) = rgb2ind(f.cdata,map,'nodither');
                  pause(0.02)
                  close(hsig)
            end
      end
      iadj = iadj+1;
end

assignin('base','scalpicture', hsig);
binArraystr = vect2colon(binArray,  'Delimiter','no');

if size(latencyArray,1)==1
      latencystr  = vect2colon(latencyArray, 'Delimiter','no');
else
      for i=1:size(latencyArray,1)
            if i==1
                  latencystr  = num2str(latencyArray(i,:));
            else
                  latencystr  = [latencystr ';' num2str(latencyArray(i,:))];
            end
      end
end

if isnumeric(baseline)
      baselinestr = vect2colon(baseline);
else
      baselinestr = ['''' baseline ''''];
end

if isnumeric(maplimit)
      maplimitstr = vect2colon(maplimit);
else
      maplimitstr = ['''' maplimit ''''];
end

delaystr = num2str(DelayT);

if isempty(delaystr)
      delaystr = '[]';
end

posfigstr = vect2colon(posfig);

isagifstr = num2str(isagif);
erpcom = sprintf( 'pop_scalplot( %s, [%s], [%s], ''%s'', %s, %s, %s, %s, ''%s'', %s);', inputname(1), binArraystr, latencystr,...
      measurestr, baselinestr, maplimitstr, isagifstr, delaystr, fullgifname, posfigstr);

fprintf('Mapped Channels: ');

for j=1:ERP.nchan
      fprintf('%s - ', char(ERP.chanlocs(j).labels));
end

fprintf('\n');

%
% Create final Animated GIF
%
if isagif>0
      pause(0.2)
      imwrite(im, map, fullgifname,'DelayTime',DelayT,'LoopCount',inf);
end
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end 
return

%---------------------------------------------------------------------------------------------------
%-----------------base line mean value--------------------------------------------------------------
function blv = blvalue(ERP, chan, bin, bl)

if isnumeric(bl)
      toffsa   = abs(round(ERP.xmin*ERP.srate))+1;
      baseline = round((bl/1000)*ERP.srate) + toffsa; %msec to samples
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
