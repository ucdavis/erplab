%
% We need a very fancy data structure system. We've got an array of our
% 'pages'. Each page is a structure. Each page has a property 'data'. In order to graph effectively it's 2
% dimensional. It's a series of X by Y matrices compounded horizontally.
% Each column represents one line of data. Each 'chunk' (Length Y)
% represents one of three things: A bin, a channel, or an ERPset. If we
% were to look at one bin as a chunk, each column could either represent a
% channel or an ERPset.
%
% We can change to this system fairly easily. Replace 'nchan' with
% 'nlines', 'nbin' with 'nplots', etc. Then create a func to turn ERP
% structure into local data structure based on the 3 way intersection of
% channels, bins, and ERPsets.
%

% [ 1 2 3 1 2 3
%   1 2 3 1 2 3
%   1 2 3 1 2 3 ]

function varargout = mini_viewer(varargin)
    parent = uiextras.Empty();
    boxpan = uiextras.Empty();
    inpd = [];
    data = [];
    olddata = [];
    child_vs = {};
    floating = 0<1;
    havedat = 0<1;
    
    % Lines, Plots, Pages
    % 1 = Chans, 2 = Bins, 3 = ERPsets
    ord = [2 1 3];
    
    if nargin == 0
        havedat = 0>1;
    elseif nargin == 1
        fig = figure( 'Name', 'ERP Explorer', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'off');
        parent = fig;
        data = cell2mat(varargin(1));
    else
        data = cell2mat(varargin(1));
        parent = [varargin{2}];
        floating = 1<0;
    end
    erp_tabs = uiextras.TabPanel('Parent', parent, 'Padding', 5);
    
    olddata = data;
    
    data = erp2loc(data);
    
    data = data{:};
    
    drawUI()
    ret_v = struct('tabs', erp_tabs, 'data', olddata);
    varargout{1} = ret_v;
    
    function drawUI()
        
        havedat = numel(data)>0;
        
        delete(erp_tabs.Children);
        if havedat
            tabnames = cell(size(data));
            tabs = zeros(size(data));
            [~,a] = size(data);
            for i = 1:a
                tabs(i) = uix.HBoxFlex( 'Parent', erp_tabs, 'Spacing', 10 );
                dat = data(i);
                tabnames(i) = {dat.name};
            end
            
            erp_tabs.TabNames = tabnames;
            erp_tabs.SelectedChild = 1;
            erp_tabs.TabSize = 120;
            for tabn = 1:numel(tabs)
                TAB = tabs(tabn);
                cdat = data(tabn);
                hbox = uiextras.HBox('Parent', TAB);
                boxpan = uiextras.BoxPanel('Parent', hbox);
                [d1,d2,d3] = size(cdat.data);
                plot_erp_data = cdat.data;
%                 for i = 1:cdat.nlin
%                     ndata = 1:cdat.nplot;
%                     for i_bin = 1:numel(ndata)
%                         el_shown = 1:cdat.nlin;
%                         
%                         plot_erp_data(:,(i_bin+((i-1)*numel(ndata)))) = cdat.data(el_shown(i),1:d2,d3)'; % + (i+1)*S.display_offset;
%                     end
%                 end
                offset = (repmat(kron(1:cdat.nplot,ones(1,cdat.nlin)),[500 1])-1)*30;
                plot_erp_data = plot_erp_data + offset;
                drawERP(plot_erp_data,boxpan,cdat)
                vpanels = uiextras.VBox('Parent', hbox);
                dat_sel = uiextras.BoxPanel('Parent', vpanels,'Title','Data Selector');
                pl_ops = uiextras.BoxPanel('Parent', vpanels,'Title','Plotting Options');
                
                % Data Selector
                ds_vb = uiextras.VBox('Parent',dat_sel);
                ds_grid = uiextras.Grid('Parent',ds_vb);
                
                uicontrol('Style','text','String','Chans','Parent',ds_grid);
                cs = {cdat.channames};
                chan_sel = uicontrol('Style','listbox','Parent',ds_grid,'String',[{'ALL'}, cs{:}],'callback',@temp,'Max',2,'Min',0);
                
                uicontrol('Style','text','String','Bins','Parent',ds_grid);
                bs = cdat.binnames;
                bin_sel = uicontrol('Style','listbox','Parent',ds_grid,'String',[{'ALL'}, bs{:}],'callback',@temp,'Max',2,'Min',0);
                
                set( ds_grid, 'ColumnSizes', [-1 -1], 'RowSizes', [25, -1] );
                
                b_c = uicontrol('Style','popupmenu','Parent',ds_vb,'String',{'Channels by Bins','Bins by Channels'},'callback',@temp);
                
                set( ds_vb, 'Sizes', [-1, 20] );
                
                % Plotting Options
                pl_grid = uiextras.Grid('Parent',pl_ops);
                
                tr_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', tr_pn, 'Style','text','String','Range','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','Min');
                uicontrol('Parent',pl_grid,'Style','edit','String','0');
                uicontrol('Parent',pl_grid,'Style','text','String','Max');
                uicontrol('Parent',pl_grid,'Style','edit','String','1000');
                uiextras.Empty('Parent', pl_grid);
                uiextras.Empty('Parent', pl_grid);
                
                tt_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', tt_pn, 'Style','text','String','X Scale','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','Min');
                uicontrol('Parent',pl_grid,'Style','edit','String','0');
                uicontrol('Parent',pl_grid,'Style','text','String','Max');
                uicontrol('Parent',pl_grid,'Style','edit','String','1000');
                uicontrol('Parent',pl_grid,'Style','text','String','Step');
                uicontrol('Parent',pl_grid,'Style','edit','String','200');
                
                mc_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', mc_pn, 'Style','text','String','Misc.','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                
                if floating
                    uicontrol('Parent',pl_grid,'Style','text','String','a');
                    uicontrol('Parent',pl_grid,'Style','text','String','a');
                else
                    tn = tabn;
                    uicontrol('Parent',pl_grid,'Style','pushbutton','String','Detach','callback',{@detach,tabn});
                    uicontrol('Parent',pl_grid,'Style','pushbutton','String','Retach','callback',@retach);
                end
                
                set( pl_grid, 'ColumnSizes', [-1 -1 -1], 'RowSizes', [35 20 25 20 25 20 25] );
                
                set( vpanels, 'Sizes', [-1 190] );
                set( hbox, 'Sizes', [-1 200] );
            end
        else
            empty_tab = uix.HBoxFlex( 'Parent', erp_tabs, 'Spacing', 10 );
            erp_tabs.TabNames = {'Empty'};
            erp_tabs.TabSize = 120;
            erp_tabs.SelectedChild = 1;
            
            hbox = uiextras.HBox('Parent', empty_tab);
            boxpan = uiextras.BoxPanel('Parent', hbox);
            
            vpanels = uiextras.VBox('Parent', hbox);
                dat_sel = uiextras.BoxPanel('Parent', vpanels,'Title','Data Selector');
                pl_ops = uiextras.BoxPanel('Parent', vpanels,'Title','Plotting Options');
                
                % Data Selector
                ds_vb = uiextras.VBox('Parent',dat_sel);
                ds_grid = uiextras.Grid('Parent',ds_vb);
                
                uicontrol('Style','text','String','Chans','Parent',ds_grid);
                chan_sel = uicontrol('Style','listbox','Parent',ds_grid,'String',{'ALL'},'callback',@temp,'Max',2,'Min',0);
                
                uicontrol('Style','text','String','Bins','Parent',ds_grid);
                bin_sel = uicontrol('Style','listbox','Parent',ds_grid,'String',{'ALL'},'callback',@temp,'Max',2,'Min',0);
                
                set( ds_grid, 'ColumnSizes', [-1 -1], 'RowSizes', [25, -1] );
                
                b_c = uicontrol('Style','popupmenu','Parent',ds_vb,'String',{'Channels by Bins','Bins by Channels'},'callback',@temp);
                
                set( ds_vb, 'Sizes', [-1, 20] );
                
                % Plotting Options
                pl_grid = uiextras.Grid('Parent',pl_ops);
                
                tr_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', tr_pn, 'Style','text','String','Range','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','Min');
                uicontrol('Parent',pl_grid,'Style','edit','String','0');
                uicontrol('Parent',pl_grid,'Style','text','String','Max');
                uicontrol('Parent',pl_grid,'Style','edit','String','1000');
                uiextras.Empty('Parent', pl_grid);
                uiextras.Empty('Parent', pl_grid);
                
                tt_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', tt_pn, 'Style','text','String','X Scale','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','Min');
                uicontrol('Parent',pl_grid,'Style','edit','String','0');
                uicontrol('Parent',pl_grid,'Style','text','String','Max');
                uicontrol('Parent',pl_grid,'Style','edit','String','1000');
                uicontrol('Parent',pl_grid,'Style','text','String','Step');
                uicontrol('Parent',pl_grid,'Style','edit','String','200');
                
                mc_pn = uipanel('Parent',pl_grid);
                uicontrol('Parent', mc_pn, 'Style','text','String','Misc.','Position',[0 0 65 25]);
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','text','String','a');
                uicontrol('Parent',pl_grid,'Style','pushbutton','String','Detach','callback',@temp);
                uicontrol('Parent',pl_grid,'Style','pushbutton','String','Retach','callback',@retach);
                
                set( pl_grid, 'ColumnSizes', [-1 -1 -1], 'RowSizes', [35 20 25 20 25 20 25] );
                
                set( vpanels, 'Sizes', [-1 190] );
                set( hbox, 'Sizes', [-1 200] );
        end
    end
    
    function drawERP(dat,p,terp)
        ax = axes('Parent',p,'Color','none','Box','on');
        %set( ax, 'XLim', [min max] )
        ts = terp.times;
        [a,c,b] = size(dat);
        new_erp_data = zeros(a,b*c);
        for j = 1:b
            new_erp_data(:,((c*(j-1))+1):(c*j)) = dat(:,:,j);
        end
        this_plot = plot(ax,ts,new_erp_data);
        %boxpan
    end
    
    function detach(~,~,tabn)
        %tabn = erp_tabs.SelectedChild;
        ddat = data(tabn);
        data(tabn) = [];
        drawUI();
        child_vs(end+1) = {mini_viewer(ddat)};
    end

    function retach(~,~)
        for j = child_vs
            j = [j{1}];
            data(end+1) = j.data;
            delete(j.tabs.Parent);
        end
        drawUI();
        child_vs = {};
    end

    function loc = erp2loc(erps)
        news = nan(size(erps));
        nerps = numel(erps);
        
        cs = [erps(1).chanlocs.urchan];
        bs = 1:numel(erps(1).bindescr);
        es = {};
        [d1,d2,d3] = size(erps(1).bindata);
        for i = erps
            [td1,td2,td3] = size(i.bindata);
            if td1>d1
                d1=td1;
            end
            if td2>d2
                d2=td2;
            end
            if td3>d3
                d3=td3;
            end
        end
        ltdata = nan(d1,d2,d3,0);
        for i = erps
            for j = [i.chanlocs.urchan]
                if ~ismember(j,cs)
                    cs(end+1) = j;
                end
            end
            for j = 1:numel(i.bindescr)
                if ~ismember(j,bs)
                    bs(end+1) = j;
                end
            end
            es(end+1) = {i.erpname};
            t = i.bindata;
            try
                if t(d1,d2,d3) == 0
                    beep;
                end
            catch
                t(d1,d2,d3) = 0;
            end
            ltdata(:,:,:,end+1) = t;
        end
        
        nbs = {};
        for i = 1:numel(bs)
            tes = {};
            ttes = {};
            for j = 1:numel(erps)
                if erps(j).nbin >= i
                    ttes(end+1) = {erps(j)};
                    tes(end+1) = es(j);
                end
            end
            
            tcs = [];
            for j = ttes
                j1 = cell2mat(j);
                for k = 1:j1.nchan
                    if ~ismember(k,tcs)
                        tcs(end+1) = k;
                    end
                end
            end
            ttes1 = cell2mat(ttes(1));
            nbs(end+1) = {struct('e',{tes},'b',bs(i),'c',tcs,'n',cell2mat(ttes1.bindescr(i)))};
        end
        
        ncs = {};
        for i = 1:numel(cs)
            tes = {};
            ttes = {};
            for j = 1:numel(erps)
                if erps(j).nchan >= i
                    ttes(end+1) = {erps(j)};
                    tes(end+1) = es(j);
                end
            end
            
            tbs = [];
            for j = ttes
                j1 = cell2mat(j);
                for k = 1:j1.nbin
                    if ~ismember(k,tbs)
                        tbs(end+1) = k;
                    end
                end
            end
            ttes1 = cell2mat(ttes(1));
            tlb = {ttes1.chanlocs.labels};
            ncs(end+1) = {struct('e',{tes},'b',tbs,'c',cs(i),'n',cell2mat(tlb(i)))};
        end
        
        nes = {};
        for i = 1:numel(es)
            nes(end+1) = {struct('e',es(i),'b',1:erps(i).nbin,'c',1:erps(i).nchan,'n',es(i))};
        end
        
        % Take [chans bins erpsets] and apply a filter of [2 1 3] or
        % something to create desired permutation such as [bins chans
        % erpsets]. Now we have [lines plots pages]!
        nar = [numel(cs) numel(bs) numel(es)];
        nop = nar(ord);
        
        ar = {cs bs es};
        op = nar(ord);
        
        dar = {ncs nbs nes};
        dop = dar(ord);
        
        s = cell(1,nop(3));
        
        for i = 1:nop(3)
            % Iterate through all pages here
            
            % Our data will be
            %
            % [ a1 a2 a3 b1 b2 b3
            %   a1 a2 a3 b1 b2 b3
            %   a1 a2 a3 b1 b2 b3 ]
            %
            
            temp1 = dop(3);
            temp = temp1{:}{i};
            
            % WARN IF BIN OR CHAN DOES NOT EXIST FOR ERPSET
            todata = ltdata(temp.c,:,temp.b,find(strcmp(es,temp.e)));
            t_s = [0 0 0];
            t_s(ord) = [nop(1) nop(2) 1];
            t_ds_o = ones(1,4);
            t_ds = zeros(1,4);
            t_ds_o(1:numel(size(todata))) = size(todata);
            t_ds(1:numel(size(todata))) = size(todata);
            if t_s(1) ~= t_ds(1)
                ss = t_ds_o;
                ss(1) = t_s(1);
                todata(ss(1),ss(2),ss(3),ss(4)) = 0;
            end
            if t_s(2) ~= t_ds(3)
                ss = t_ds_o;
                ss(3) = t_s(2);
                todata(ss(1),ss(2),ss(3),ss(4)) = 0;
            end
            if t_s(3) ~= t_ds(4)
                ss = t_ds_o;
                ss(4) = t_s(3);
                todata(ss(1),ss(2),ss(3),ss(4)) = 0;
            end
            
            %if size(todata) ~= [ta tb tc ]
            ntdata = reshape(todata,numel(erps(1).times),nop(1)*nop(2));
            
            
            referp = dop(3);
            referp = [referp{:}];
            referp = referp{i};
            
            nerp = erps(1);
            for j = erps
                if j.nbin > nerp.nbin
                    nerp = j;
                end
            end
            
            cl = {nerp.chanlocs.labels};
            
            s(i) = {struct('nlin',nop(1),'nplot',nop(2),'data',ntdata,'name',temp.n,'channames',{cl(referp.c)},'binnames',{nerp.bindescr(referp.b)},'erpnames',{referp.e},'times',nerp.times)};
            clear cl nerp j temp1 t_s referp
        end
        
        loc = s;
    end

    function temp( src, ~ )
        beep;
    end
end