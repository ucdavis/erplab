%%This is subfunction of the  pop_ploteegset.m that is used to plot EEG wave


% *** This function is part of ERPLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% August 2023


function errmeg = f_ploteegwave(EEG,ChanArray,ICArray,Winlength,...
    AmpScale,ChanLabel,Submean,EventOnset,StackFlag,NormFlag,Startimes,...
    AmpIC,bufftobo,FigOutpos,FigureName)

errmeg = [];

if nargin<1
    help f_ploteegwave;
    return
end

if isempty(EEG)
    errmeg  = 'EEG is empty';
    return;
end
%%selected channels
nbchan = EEG.nbchan;
if nargin<2
    ChanArray = 1:nbchan;
end
if ~isempty(ChanArray) &&( min(ChanArray(:)) >nbchan || max(ChanArray(:))> nbchan||  min(ChanArray(:))<=0)
    ChanArray = 1:nbchan;
end

%%selected ICs
if nargin<3
    ICArray = [];
end
if isempty(EEG.icachansind)
    ICArray = [];
else
    nIC = numel(EEG.icachansind);
    if ~isempty(ICArray)
        if  min(ICArray(:))>nIC || max(ICArray(:)) >  nIC ||  min(ICArray(:))<=0
            ICArray = [];
        end
    end
end


%%Time range that is to display (1s or 5s)?
if nargin<4
    Winlength=5;
end
if isempty(Winlength) || numel(Winlength)~=1 || min(Winlength(:))<=0
    Winlength=5;
end

%%Vertical scale?
if nargin<5
    AmpScale = 50;
end
if isempty(AmpScale) || numel(AmpScale)~=1 || AmpScale==0
    AmpScale = 50;
end
OldAmpScale = AmpScale;

%%channe labels (name or number)
if nargin<6
    ChanLabel = 1;
end
if ~isempty(ChanLabel) && numel(ChanLabel)~=1
    ChanLabel = ChanLabel(1);
end
if isempty(ChanLabel) || numel(ChanLabel)~=1 || (ChanLabel~=0 && ChanLabel~=1)
    ChanLabel = 1;
end

%%remove DC?
if nargin<7
    Submean = 0;
end
if ~isempty(Submean) && numel(Submean)~=1
    Submean = Submean(1);
end
if isempty(Submean) || numel(Submean)~=1 || (Submean~=0 && Submean~=1)
    Submean = 0;
end


%%Display events?
if nargin<8
    EventOnset = 1;
end
if ~isempty(EventOnset) && numel(EventOnset)~=1
    EventOnset = EventOnset(1);
end
if isempty(EventOnset) ||  numel(EventOnset)~=1 || (EventOnset~=0 && EventOnset~=1)
    EventOnset = 1;
end


%%Stack?
if nargin<9
    StackFlag = 0;
end
if ~isempty(StackFlag) && numel(StackFlag)~=1
    StackFlag = StackFlag(1);
end
if isempty(StackFlag) || numel(StackFlag)~=1 || (StackFlag~=0&&StackFlag~=1)
    StackFlag = 0;
end

%%Norm?
if nargin<10
    NormFlag = 0;
end
if ~isempty(NormFlag) && numel(NormFlag)~=1
    NormFlag = NormFlag(1);
end
if isempty(NormFlag) ||numel(NormFlag)~=1 || (NormFlag~=0 && NormFlag~=1)
    NormFlag = 0;
end

%%start time for the displayed data
if nargin < 11
    if ndims(EEG.data) ==3
        Startimes=1;
    else
        Startimes=0;
    end
end
[ChanNum,Allsamples,tmpnb] = size(EEG.data);
Allsamples = Allsamples*tmpnb;
if ndims(EEG.data) > 2
    multiplier = size(EEG.data,2);
else
    multiplier = EEG.srate;
end

if isempty(Startimes) || Startimes<0 ||  Startimes>(ceil((Allsamples-1)/multiplier)-Winlength)
    if ndims(EEG.data) ==3
        Startimes=1;
    else
        Startimes=0;
    end
end

%%VERTICAL SCALE for ICs
if nargin<12
    AmpIC = 20;
end

if isempty(AmpIC) || numel(AmpIC)~=1 || AmpIC<=0
    AmpIC = 20;
end
OldAmpIC = AmpIC;


%%buffer at top and bottom
if nargin<13
    bufftobo = 100;
end
if isempty(bufftobo) || numel(bufftobo)~=1 || any(bufftobo(:)<=0)
    bufftobo = 100;
end




if nargin <14
    FigOutpos = [];
end
if numel(FigOutpos)~=2
    FigOutpos = [];
end

if nargin<15
    FigureName = '';
end

if isempty(FigureName)
    FigureName ='none';
end

if isempty(EEG.setname) || strcmp(EEG.setname,'')
    EEG.setname = 'still_not_saved!';
end
if isempty(EEG.setname)
    fname = 'none';
else
    [pathstr, fname, ext] = fileparts(EEG.setname);
end

% FigbgColor = [1 1 1];
extfig ='';
[pathstrfig, FigureName, extfig] = fileparts(FigureName) ;

if isempty(FigureName)
    fig_gui= figure('Name',['<< ' fname ' >> '],...
        'NumberTitle','on','color',[1 1 1]);
    %     fig_gui_wave = subplot(Numrows+1,1,[2:Numrows+1]);
    hbig= axes('Parent',fig_gui,'Box','on','FontWeight','normal', 'XTick', [], 'YTick', []);
    hold on
end

if ~isempty(FigureName)
    fig_gui= figure('Name',['<< ' FigureName ' >> '],...
        'NumberTitle','on','color',[1 1 1]);
    hbig= axes('Parent',fig_gui,'Color','none','Box','on','FontWeight','normal', 'XTick', [], 'YTick', []);
    hold on;
end
% drawnow;
try
    Pos = hbig.Position;
    hbig.Position = [Pos(1)*0.5,Pos(2)*0.95,Pos(3)*1.15,Pos(4)*0.95];
    outerpos = fig_gui.OuterPosition;
    higpos = hbig.Position;
    set(fig_gui,'outerposition',[1,1,(1.1/higpos(3))*FigOutpos(1) (1.1/higpos(4))*FigOutpos(2)])
catch
    set(fig_gui,'outerposition',get(0,'screensize'));%%Maximum figure
end

if ~isempty(extfig)
    set(fig_gui,'visible','off');
end
set(fig_gui, 'Renderer', 'painters');%%vector figure


%%determine the time range that will be dispalyed
lowlim = round(Startimes*multiplier+1);
highlim = round(min((Startimes+Winlength)*multiplier+1,Allsamples));


%%--------------------prepare event array if any --------------------------
Events = EEG.event;
if ~isempty(Events)
    if ~isfield(Events, 'type') || ~isfield(Events, 'latency'), Events = []; end
end
if ~isempty(Events)
    if ischar(Events(1).type)
        [Eventtypes tmpind indexcolor] = unique_bc({Events.type}); % indexcolor countinas the event type
    else [Eventtypes tmpind indexcolor] = unique_bc([ Events.type ]);
    end
    Eventcolors     = { 'r', [0 0.8 0], 'm', 'c', 'k', 'b', [0 0.8 0] };
    Eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
    Eventwidths     = [ 2.5 1 ];
    Eventtypecolors = Eventcolors(mod([1:length(Eventtypes)]-1 ,length(Eventcolors))+1);
    Eventcolors     = Eventcolors(mod(indexcolor-1               ,length(Eventcolors))+1);
    Eventtypestyle  = Eventstyle (mod([1:length(Eventtypes)]-1 ,length(Eventstyle))+1);
    Eventstyle      = Eventstyle (mod(indexcolor-1               ,length(Eventstyle))+1);
    
    % for width, only boundary events have width 2 (for the line)
    % -----------------------------------------------------------
    indexwidth = ones(1,length(Eventtypes))*2;
    if iscell(Eventtypes)
        for index = 1:length(Eventtypes)
            if strcmpi(Eventtypes{index}, 'boundary'), indexwidth(index) = 1; end
        end
    else
        %         if option_boundary99
        %             indexwidth = [ Eventtypes == -99 ];
        %         end
    end
    Eventtypewidths = Eventwidths (mod(indexwidth([1:length(Eventtypes)])-1 ,length(Eventwidths))+1);
    Eventwidths     = Eventwidths (mod(indexwidth(indexcolor)-1               ,length(Eventwidths))+1);
    
    % latency and duration of events
    % ------------------------------
    Eventlatencies  = [ Events.latency ]+1;
    if isfield(Events, 'duration')
        durations = { Events.duration };
        durations(cellfun(@isempty, durations)) = { NaN };
        Eventlatencyend   = Eventlatencies + [durations{:}]+1;
    else Eventlatencyend   = [];
    end
    %     EventOnset       = 1;
end

if isempty(Events)
    EventOnset  = 0;
end

chanNum = numel(ChanArray);

%%-------------------------------IC and original data----------------------
dataica = []; chaNum = 0;
if ~isempty(ICArray)
    ICdispFlag=1;
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)%%pop_eegplot from eeglab
        tmpdata = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        try
            dataica = tmpdata(ICArray,:);
        catch
            dataica = tmpdata(:,:);
            ICArray = [1:size(tmpdata,1)];
        end
    end
else
    ICdispFlag=0;
end

if ~isempty(ChanArray)
    EEGdispFlag=1;
    dataeeg = EEG.data(ChanArray,:);
    chaNum = numel(ChanArray);
else
    dataeeg =[];
    EEGdispFlag=0;
    chaNum = 0;
end

%%---------------------------Normalize-------------------------------------
if NormFlag==1
    %%Norm for origanal
    %     data2 = [];
    if ~isempty(dataeeg)
        datastd = std(dataeeg(:,1:min(1000,Allsamples)),[],2);%
        for i = 1:size(dataeeg,1)
            dataeeg(i,:,:) = dataeeg(i,:,:)/datastd(i);
            %             if ~isempty(data2)
            %                 data2(i,:,:) = data2(i,:,:)*datastd(i);
            %             end
        end
    end
    
    %%norm for IC data
    if ~isempty(dataica)
        dataicstd = std(dataica(:,1:min(1000,Allsamples)),[],2);
        for i = 1:size(dataica,1)
            dataica(i,:,:) = dataica(i,:,:)/dataicstd(i);
            %        if ~isempty(data2)
            %            data2(i,:,:) = data2(i,:,:)*dataicstd(i);
            %        end
        end
    end
end

% Removing DC for IC data?
% -------------------------
meandataica =[];ICNum = 0;
if ICdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray) && ~isempty(dataica)%%pop_eegplot from eeglab
        switch Submean % subtract the mean ?
            case 1
                meandataica = mean(dataica(:,lowlim:highlim)');
                if any(isnan(meandataica))
                    meandataica = nan_mean(dataica(:,lowlim:highlim)');
                end
            otherwise, meandataica = zeros(1,numel(ICArray));
        end
    end
    ICNum = numel(ICArray);
else
    ICNum = 0;
end

% Removing DC for original data?
% -------------------------
meandata = [];
if EEGdispFlag==1 && ~isempty(dataeeg)
    switch Submean % subtract the mean ?
        case 1
            meandata = mean(dataeeg(:,lowlim:highlim)');
            if any(isnan(meandata))
                meandata = nan_mean(dataeeg(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,numel(ChanArray));
    end
end

PlotNum = chaNum+ICNum;
if chaNum==0 && ICNum==0
    Ampscold = 0*[1:PlotNum]';
    if StackFlag==1
        Ampsc = 0*[1:PlotNum]';
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = 0;
    ylims = [0 (PlotNum+1)*AmpScale];
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
elseif ICNum==0 && chaNum~=0
    Ampscold = AmpScale*[1:PlotNum]';
    if  StackFlag==1
        Ampsc = ((Ampscold(end)+AmpScale)/2)*ones(1,PlotNum)';
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = AmpScale;
    ylims = [AmpScale*(100-bufftobo)/100 PlotNum*AmpScale+AmpScale*bufftobo/100];
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
elseif ICNum~=0 && chaNum==0
    Ampscold = AmpIC*[1:PlotNum]';
    if  StackFlag==1
        Ampsc = ((Ampscold(end)+AmpIC)/2)*ones(1,PlotNum)';
    else
        Ampsc = Ampscold;
    end
    ylims = [AmpIC*(100-bufftobo)/100 PlotNum*AmpIC+AmpIC*bufftobo/100];
    AmpScaleold = AmpIC;
    data = [dataeeg;dataica];
    meandata = [meandata,meandataica];
    AmpICNew = AmpIC;
elseif ICNum~=0 && chaNum~=0
    AmpICNew = (AmpScale*chaNum+AmpScale/2)/ICNum;
    Ampscold1 = AmpICNew*[1:ICNum]';
    Ampscold2 = Ampscold1(end)+AmpScale/2+AmpScale*[1:chaNum]';
    Ampscold = [Ampscold1;Ampscold2];
    if  StackFlag==1
        Ampsc = [(Ampscold1(end)/2)*ones(ICNum,1);((Ampscold2(end)+AmpScale+Ampscold2(1)+AmpIC)/2)*ones(chaNum,1)];
    else
        Ampsc = Ampscold;
    end
    AmpScaleold = AmpScale;
    ylims = [AmpICNew*(100-bufftobo)/100 Ampscold(end)+AmpScale*bufftobo/100];
    data = [dataeeg;(AmpICNew/AmpIC)*dataica];
    meandata = [meandata,(AmpICNew/AmpIC)*meandataica];
end


Colorgbwave = [];
%%set the wave color for each channel
if ~isempty(data)
    ColorNamergb = round([255 0 7;186 85 255;255 192 0;0 238 237;0 78 255;0 197 0]/255,3);
    Colorgb_chan = [];
    if ~isempty(ChanArray)
        chanNum = numel(ChanArray);
        if chanNum<=6
            Colorgb_chan = ColorNamergb(1:chanNum,:);
        else
            jj = floor(chanNum/6);
            Colorgb_chan = [];
            for ii = 1:jj
                Colorgb_chan = [Colorgb_chan; ColorNamergb];
            end
            if jj*6~=chanNum
                Colorgb_chan = [Colorgb_chan; ColorNamergb(1:chanNum-jj*6,:)];
            end
        end
    end
    
    %%colors for ICs
    Coloricrgb = round([180 0 0;127 68 127;228 88 44;15 175 175;0 0 0;9 158 74]/255,3);
    Colorgb_IC = [];
    if ~isempty(ICArray)
        ICNum = numel(ICArray);
        if ICNum<7
            Colorgb_IC = Coloricrgb(1:ICNum,:);
        else
            jj = floor(ICNum/6);
            for ii = 1:jj
                Colorgb_IC = [Colorgb_IC; Coloricrgb];
            end
            
            if jj*6~=ICNum
                Colorgb_IC = [Colorgb_IC; Coloricrgb(1:ICNum-jj*6,:)];
            end
            
        end
    end
    Colorgbwave = [Colorgb_chan;Colorgb_IC];
end


PlotNum =0;
if ICdispFlag==1 && EEGdispFlag==1
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)
        PlotNum = chanNum +numel(ICArray);
    else
        PlotNum = chanNum;
    end
elseif ICdispFlag==0 && EEGdispFlag==1
    PlotNum = chanNum;
elseif ICdispFlag==1 && EEGdispFlag==0
    if ~isempty(EEG.icaweights) && ~isempty(ICArray)
        PlotNum =  numel(ICArray);
    end
end
%%
EventOnsetdur =1;
Trialstag = size(EEG.data,2);
GapSize = ceil(numel([lowlim:highlim])/40);
if GapSize<=2
    GapSize=5;
end
% -------------------------------------------------------------------------
% -------------------------draw events if any------------------------------
% -------------------------------------------------------------------------

FonsizeDefault = f_get_default_fontsize();
if isempty(FonsizeDefault) || numel(FonsizeDefault)~=1|| any(FonsizeDefault(:)<=0)
    FonsizeDefault=10;
end

if EventOnset==1 && ~isempty(data)
    MAXEVENTSTRING = 75;
    if MAXEVENTSTRING<0
        MAXEVENTSTRING = 0;
    elseif MAXEVENTSTRING>75
        MAXEVENTSTRING=75;
    end
    %     AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
    %
    
    % find event to plot
    % ------------------
    event2plot    = find ( Eventlatencies >=lowlim & Eventlatencies <= highlim );
    if ~isempty(Eventlatencyend)
        event2plot2 = find ( Eventlatencyend >= lowlim & Eventlatencyend <= highlim );
        event2plot3 = find ( Eventlatencies  <  lowlim & Eventlatencyend >  highlim );
        event2plot  = setdiff(union(event2plot, event2plot2), event2plot3);
    end
    for index = 1:length(event2plot)
        %Just repeat for the first one
        if index == 1
            EVENTFONT = [' \fontsize{',num2str(FonsizeDefault),'} '];
        end
        
        % draw latency line
        % -----------------
        if ndims(EEG.data)==2
            tmplat = Eventlatencies(event2plot(index))-lowlim-1;
        else
            % -----------------
            tmptaglat = [lowlim:highlim];
            tmpind = find(mod(tmptaglat-1,Trialstag) == 0);
            tmpind = setdiff(tmpind,[1,numel(tmptaglat)]);
            alltaglat = setdiff(tmptaglat(tmpind),[1,tmptaglat(end)]);
            %%add gap between epochs if any
            if ~isempty(tmpind) && ~isempty(alltaglat) %%two or multiple epochs were displayed
                if length(alltaglat)==1
                    if Eventlatencies(event2plot(index)) >= alltaglat
                        Singlat = Eventlatencies(event2plot(index))+GapSize;
                    else
                        Singlat = Eventlatencies(event2plot(index));
                    end
                else
                    if  Eventlatencies(event2plot(index)) < alltaglat(1)%%check the first epoch
                        Singlat = Eventlatencies(event2plot(index));
                    else%%the other epochs
                        for ii  = 2:length(alltaglat)
                            if Eventlatencies(event2plot(index)) >= alltaglat(ii-1) && Eventlatencies(event2plot(index)) < alltaglat(ii)
                                Singlat = Eventlatencies(event2plot(index))+GapSize*(ii-1);
                                break;
                            elseif Eventlatencies(event2plot(index)) >= alltaglat(end)  %%check the last epoch
                                Singlat = Eventlatencies(event2plot(index))+GapSize*length(alltaglat);
                                break;
                            end
                        end
                    end
                end
                tmplat = Singlat-lowlim;%%adjust the latency if any
            else%%within one epoch
                tmplat = Eventlatencies(event2plot(index))-lowlim;%-1;
            end
            
        end
        tmph   = plot(hbig, [ tmplat tmplat ], ylims, 'color', Eventcolors{ event2plot(index) }, ...
            'linestyle', Eventstyle { event2plot(index) }, ...
            'linewidth', Eventwidths( event2plot(index) ) );
        
        % schtefan: add Event types text above event latency line
        % -------------------------------------------------------
        evntxt = strrep(num2str(Events(event2plot(index)).type),'_','-');
        if length(evntxt)>MAXEVENTSTRING, evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; end % truncate
        try,
            if tmplat>=0
                tmph2 = text(hbig, [tmplat], ylims(2)-0.005, [EVENTFONT evntxt], ...
                    'color', Eventcolors{ event2plot(index) }, ...
                    'horizontalalignment', 'left',...
                    'rotation',90,'FontSize',FonsizeDefault);
            end
        catch, end
        
        % draw duration is not 0
        % ----------------------
        %         if EventOnsetdur && ~isempty(Eventlatencyend) ...
        %                 && Eventwidths( event2plot(index) ) ~= 2.5 % do not plot length of boundary events
        %             tmplatend = Eventlatencyend(event2plot(index))-lowlim-1;
        %             if tmplatend ~= 0
        %                 tmplim = ylims;
        %                 tmpcol = Eventcolors{ event2plot(index) };
        %                 h = patch(hbig, [ tmplat tmplatend tmplatend tmplat ], ...
        %                     [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
        %                     tmpcol );  % this argument is color
        %                 set(h, 'EdgeColor', 'none')
        %             end
        %         end
    end
else % JavierLC
    MAXEVENTSTRING = 10; % default
    %     AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
end


if StackFlag==1
    AmpScale=0;
end
DEFAULT_GRID_SPACING =Winlength/5;

% -------------------------------------------------------------------------
% -----------------draw EEG wave if any------------------------------------
% -------------------------------------------------------------------------
leftintv = [];
%%Plot continuous EEG
tmpcolor = [ 0 0 0.4 ];
if EEG.trials==1
    if ~isempty(data) && PlotNum~=0
        
        for ii = size(data,1):-1:1
            try
                plot(hbig, (data(ii,lowlim:highlim)+ Ampsc(size(data,1)-ii+1)-meandata(ii))' , ...
                    'color', Colorgbwave(ii,:), 'clipping','on','LineWidth',0.5);%%
            catch
                plot(hbig, (data(ii,lowlim:highlim)+ Ampsc(size(data,1)-ii+1)-meandata(ii))', ...
                    'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
            end
        end
        set(hbig,'TickDir', 'in','LineWidth',1);
        %%xtick
        AmpScale = OldAmpScale;
        set(hbig, 'Xlim',[1 Winlength*multiplier+1],...
            'XTick',[1:multiplier*DEFAULT_GRID_SPACING:Winlength*multiplier+1]);
        set(hbig, 'XTickLabel', num2str((Startimes:DEFAULT_GRID_SPACING:Startimes+Winlength)'),'FontSize',FonsizeDefault);
        %%
        %%-----------------plot scale------------------
        leftintv = Winlength*multiplier+1;
    else
        set(hbig, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    end
end

%%------------------------------plot single-trial EEG----------------------
%%Thanks for the eeglab developers so that we can borrow their codes
isfreq = 0;
Limits = [EEG.times(1),EEG.times(end)];
Srate = EEG.srate;
Freqlimits = [];
if EEG.trials>1
    if ~isempty(data) && PlotNum~=0
        
        % plot trial limits
        % -----------------
        tmptag = [lowlim:highlim];
        tmpind = find(mod(tmptag-1,Trialstag) == 0);
        %         for index = tmpind
        %             plot(ax0, [tmptag(index)-lowlim tmptag(index)-lowlim], [0 1], 'b--');
        %         end
        alltag = tmptag(tmpind);
        if isempty(tmpind)
            epochNum = 0;
        else
            epochNum = numel(setdiff(tmpind,[0 1 numel(tmptag)]));
        end
        % compute epoch number
        % --------------
        alltag1 = alltag;
        if ~isempty(tmpind)
            tagnum = (alltag1-1)/Trialstag+1;
            for ii = 1:numel(tmpind)
                alltag1(ii)  = alltag1(ii)+(ii-1)*GapSize;
            end
            %      	set(hbig1,'XTickLabel', tagnum,'YTickLabel', [],...
            % 		 'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)],...
            % 		'XTick',alltag-lowlim+Trialstag/2, 'YTick',[],'xaxislocation', 'top');
            for ii = 1:numel(tagnum)
                text(hbig, [alltag1(ii)-lowlim+Trialstag/2],ylims(2)+1.1, [32,num2str(tagnum(ii))], ...
                    'color', 'k','FontSize',FonsizeDefault, ...
                    'horizontalalignment', 'left','rotation',90); %%
                set(hbig,'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)]);
            end
        end
        
        %%add the gap between epochs if any
        Epochintv = [];
        
        if ~isempty(tmpind)
            if (numel(tmpind)==1 && tmpind(end) == numel(tmptag)) || (numel(tmpind)==1 && tmpind(1) == 1)
                dataplot =   data(:,lowlim:highlim);
                Epochintv(1,1) =1;
                Epochintv(1,2) =numel(lowlim:highlim);
            else
                tmpind = unique(setdiff([0,tmpind, numel(tmptag)],1));
                dataplotold =    data(:,lowlim:highlim);
                dataplot_new = [];
                for ii = 2:numel(tmpind)
                    GapLeft = tmpind(ii-1)+1;
                    GapRight = tmpind(ii);
                    if GapLeft<1
                        GapLeft =1;
                    end
                    if GapRight > numel(tmptag)
                        GapRight =  numel(tmptag);
                    end
                    dataplot_new = [dataplot_new,dataplotold(:,GapLeft:GapRight),nan(size(dataplotold,1),GapSize)];
                    Epochintv(ii-1,1) = GapLeft+(ii-2)*GapSize;
                    Epochintv(ii-1,2) = GapRight+(ii-2)*GapSize;
                end
                if ~isempty(dataplot_new)
                    dataplot = dataplot_new;
                else
                    dataplot = dataplotold;
                end
            end
        end
        
        %%-----------plot background color for trias with artifact---------
        %%highlight waves with labels
        Value_adjust = floor(Startimes+1);
        if Value_adjust<1
            Value_adjust=1;
        end
        tagnum  = unique([Value_adjust,tagnum]);
        
        try trialsMakrs = EEG.reject.rejmanual(tagnum);catch trialsMakrs = zeros(1,numel(tagnum)) ; end
        try trialsMakrschan = EEG.reject.rejmanualE(:,tagnum);catch trialsMakrschan = zeros(EEG.nbchan,numel(tagnum)) ; end
        tmpcolsbgc = [1 1 0.783];
        if ~isempty(Epochintv) %%&& chaNum~=0
            for jj = 1:size(Epochintv,1)
                [xpos,~]=find(trialsMakrschan(:,jj)==1);
                if jj<= numel(trialsMakrs) && ~isempty(xpos)
                    if trialsMakrs(jj)==1
                        patch(hbig,[Epochintv(jj,1),Epochintv(jj,2),Epochintv(jj,2),Epochintv(jj,1)],...
                            [ylims(1),ylims(1),ylims(end),ylims(end)],tmpcolsbgc,'EdgeColor','none','FaceAlpha',.5);
                        %%highlight the wave if the channels that were
                        %%marked as artifacts
                        if chaNum~=0
                            ChanArray = reshape(ChanArray,1,numel(ChanArray));
                            [~,ypos1]=find(ChanArray==xpos);
                            if ~isempty(ypos1)
                                for kk = 1:numel(ypos1)
                                    dataChan = nan(1,size(dataplot,2));
                                    dataChan (Epochintv(jj,1):Epochintv(jj,2)) = dataplot(ypos1(kk),Epochintv(jj,1):Epochintv(jj,2));
                                    dataChan1= nan(1,size(dataplot,2));
                                    dataChan1 (1,Epochintv(jj,1):Epochintv(jj,1)) = dataplot(ypos1(kk),Epochintv(jj,1):Epochintv(jj,1));
                                    try
                                        plot(hbig, (dataChan+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))', ...
                                            'color', Colorgbwave(ypos1(kk),:), 'clipping','on','LineWidth',1.5);%%
                                        plot(hbig, (dataChan1+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))' , ...
                                            'color', Colorgbwave(ypos1(kk),:), 'clipping','on','LineWidth',1.5,'Marker' ,'s','MarkerSize',8,...
                                            'MarkerEdgeColor',Colorgbwave(ypos1(kk),:),'MarkerFaceColor',Colorgbwave(ypos1(kk),:));%%
                                    catch
                                        plot(hbig, (dataChan+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))', ...
                                            'color', tmpcolor, 'clipping','on','LineWidth',1.5);%%
                                        plot(hbig, (dataChan1+ Ampsc(size(dataplot,1)-ypos1(kk)+1)-meandata(ypos1(kk)))', ...
                                            'color', tmpcolor, 'clipping','on','LineWidth',1.5,'Marker' ,'s','MarkerSize',8,...
                                            'MarkerEdgeColor',Colorgbwave(ypos1(kk),:),'MarkerFaceColor',Colorgbwave(ypos1(kk),:));%%
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        for ii = size(dataplot,1):-1:1
            try
                plot(hbig, (dataplot(ii,:)+ Ampsc(size(dataplot,1)-ii+1)-meandata(ii))', ...
                    'color', Colorgbwave(ii,:), 'clipping','on','LineWidth',0.5);%%
            catch
                plot(hbig, (dataplot(ii,:)+ Ampsc(size(dataplot,1)-ii+1)-meandata(ii))', ...
                    'color', tmpcolor, 'clipping','on','LineWidth',0.5);%%
            end
        end
        
        %------------------------Xticks------------------------------------
        tagpos  = [];
        tagtext = [];
        if ~isempty(alltag)
            alltag = [alltag(1)-Trialstag alltag alltag(end)+Trialstag]; % add border trial limits
        else
            alltag = [ floor(lowlim/Trialstag)*Trialstag ceil(highlim/Trialstag)*Trialstag ]+1;
        end
        
        nbdiv = 20/Winlength; % approximative number of divisions
        divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
        [tmp indexdiv] = min(abs(nbdiv*divpossible-(Limits(2)-Limits(1)))); % closest possible increment
        incrementpoint = divpossible(indexdiv)/1000*Srate;
        
        % tag zero below is an offset used to be sure that 0 is included
        % in the absicia of the data epochs
        if Limits(2) < 0, tagzerooffset  = (Limits(2)-Limits(1))/1000*Srate+1;
        else                tagzerooffset  = -Limits(1)/1000*Srate;
        end
        if tagzerooffset < 0, tagzerooffset = 0; end
        
        for i=1:length(alltag)-1
            if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
                tagpos  = tagpos(1:end-1);
            end
            if ~isempty(Freqlimits)
                tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
            else
                if tagzerooffset ~= 0
                    tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
                else
                    tmptagpos = [];
                end
                tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
            end
        end
        
        % find corresponding epochs
        % -------------------------
        if ~isfreq
            tmplimit = Limits;
            tpmorder = 1E-3;
        else
            tmplimit =Freqlimits;
            tpmorder = 1;
        end
        tagtext = eeg_point2lat(tagpos, floor((tagpos)/Trialstag)+1, Srate, tmplimit,tpmorder);
        
        %%adjust xticks
        EpochFlag = floor((tagpos)/Trialstag)+1;%%
        
        EpochFlag = reshape(EpochFlag,1,numel(EpochFlag));
        xtickstr =  tagpos-lowlim+1;
        [xpos,ypos] = find(xtickstr>0);
        if ~isempty(ypos)
            EpochFlag =EpochFlag(ypos);
            xtickstr = xtickstr(ypos);
            tagtext = tagtext(ypos);
        end
        
        EpochFlagunique =unique(setdiff(EpochFlag,0));
        if  numel(EpochFlagunique)~=1
            for ii = 2:numel(EpochFlagunique)
                [xpos,ypos]=  find(EpochFlag==EpochFlagunique(ii));
                if ~isempty(ypos)
                    xtickstr(ypos) = xtickstr(ypos)+(EpochFlagunique(ii)-EpochFlagunique(1))*GapSize;%*(1000/Srate);
                end
            end
        end
        set(hbig,'XTickLabel', tagtext,...
            'Xlim',[1 (Winlength*multiplier+epochNum*GapSize)],...
            'XTick',xtickstr,...
            'FontWeight','normal',...
            'xaxislocation', 'bottom','FontSize',FonsizeDefault);
        XTickLabel = cellstr(hbig.XTickLabel);
        for Numofxtick = 1:length(XTickLabel)
            if strcmpi(XTickLabel{Numofxtick,:},'-0')
                XTickLabel{Numofxtick} = '0';
            end
        end
        set(hbig,'XTickLabel',XTickLabel);
        %%
        %%-----------------plot scale------------------
        leftintv = (Winlength*multiplier+epochNum*GapSize);
    else
        set(hbig, 'XTick', [], 'YTick', [],'Box','off', 'Color','none','xcolor','none','ycolor','none');
    end
end

%%
%%-----------------plot y scale------------------
if ~isempty(data) && PlotNum~=0  && ~isempty(leftintv)
    ytick_bottom = hbig.TickLength(1)*diff(hbig.XLim);
    leftintv = leftintv+ytick_bottom*2.5;
    rightintv = leftintv;
    if ICdispFlag~=0
        line(hbig,[leftintv,rightintv],[ylims(1) AmpICNew+ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        line(hbig,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(1) ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        line(hbig,[leftintv-ytick_bottom,rightintv+ytick_bottom],[AmpICNew+ylims(1) AmpICNew+ylims(1)],'color','k','LineWidth',1, 'clipping','off');
        text(hbig,leftintv,((ylims(2)-ylims(1))/43+AmpICNew+ylims(1)), [num2str(AmpIC),32,'\muV'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
        text(hbig,leftintv,((ylims(2)-ylims(1))/20+AmpICNew+ylims(1)), ['ICs'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
    end
    if EEGdispFlag~=0
        line(hbig,[leftintv,rightintv],[ylims(end)-OldAmpScale ylims(end)],'color','k','LineWidth',1, 'clipping','off');
        line(hbig,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(end)-OldAmpScale ylims(end)-OldAmpScale],'color','k','LineWidth',1, 'clipping','off');
        line(hbig,[leftintv-ytick_bottom,rightintv+ytick_bottom],[ylims(end) ylims(end)],'color','k','LineWidth',1, 'clipping','off');
        text(hbig,leftintv,(ylims(2)-ylims(1))/43+ylims(end), [num2str(OldAmpScale),32,'\muV'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
        text(hbig,leftintv,(ylims(2)-ylims(1))/20+ylims(end), ['Chans'],'HorizontalAlignment', 'center','FontSize',FonsizeDefault);
    end
    
    
    %%ytick ticklabels
    if chaNum==0
        ChanArray = [];
    end
    set(hbig, 'ylim',[ylims(1) ylims(end)],'YTick',[ylims(1) Ampscold']);
    [YLabels,chaName,ICName] = f_eeg_read_chan_IC_names(EEG.chanlocs,ChanArray,ICArray,ChanLabel);
    YLabels = flipud(char(YLabels,''));
    set(hbig,'YTickLabel',cellstr(YLabels),...
        'TickLength',[.005 .005],...
        'Color','none',...
        'XColor','k',...
        'YColor','k',...
        'FontWeight','normal',...
        'TickDir', 'in',...
        'LineWidth',0.5,'FontSize',FonsizeDefault);%%,'HorizontalAlignment','center'
    count=0;
    for ii = length(hbig.YTickLabel):-1:2
        count = count+1;
        hbig.YTickLabel{ii} = ['\color[rgb]{',num2str(Colorgbwave(count,:)),'}', strrep(hbig.YTickLabel{ii},'_','\_')];
    end
end

set(gcf,'color',[1 1 1]);
prePaperType = get(fig_gui,'PaperType');
prePaperUnits = get(fig_gui,'PaperUnits');
preUnits = get(fig_gui,'Units');
prePaperPosition = get(fig_gui,'PaperPosition');
prePaperSize = get(fig_gui,'PaperSize');
% Make changing paper type possible
set(fig_gui,'PaperType','<custom>');

% Set units to all be the same
set(fig_gui,'PaperUnits','inches');
set(fig_gui,'Units','inches');
% Set the page size and position to match the figure's dimensions
paperPosition = get(fig_gui,'PaperPosition');
position = get(fig_gui,'Position');
set(fig_gui,'PaperPosition',[0,0,position(3:4)]);
set(fig_gui,'PaperSize',position(3:4));

%%save figure  with different formats
if ~isempty(extfig)
    [C_style,IA_style] = ismember_bc2(extfig,{'.pdf','.svg','.jpg','.png','.tif','.bmp','.eps'});
    figFileName = fullfile(pathstrfig,FigureName);
    try
        switch IA_style
            case 1
                print(fig_gui,'-dpdf',figFileName);
            case 2
                print(fig_gui,'-dsvg',figFileName);
            case 3
                print(fig_gui,'-djpeg',figFileName);
            case 4
                print(fig_gui,'-dpng',figFileName);
                
            case 5
                print(fig_gui,'-dtiff',figFileName);
            case 6
                print(fig_gui,'-dbmp',figFileName);
            case 7
                print(fig_gui,'-depsc',figFileName);
            otherwise
                print(fig_gui,'-dpdf',figFileName);
        end
    catch
        print(fig_gui,'-dpdf',figFileName);
    end
end
return;