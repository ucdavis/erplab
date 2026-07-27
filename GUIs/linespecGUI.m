% linespecGUI
% "Line specifications GUI" - lets the user reorder/reassign the default
% line colors and line styles used for per-bin ERP waveform plotting, and
% pick a line width. Reached from ploterpGUI's "LINE SPEC" button.
%
% NOTE: Migrated from GUIDE (.fig) to a programmatic uifigure-based classdef
% app. Original .fig archived outside ERPLAB.
% Migrated to .m: July 2026 by Kurt Winsler
%
% Calling convention unchanged from the original (modal - blocks until
% closed):
%   app = feval('linespecGUI', def, nbin, lwidth);
%   waitfor(app, 'Finishbutton', 1);
%   answer = app.output;   % {colorStyleStrings, lwidthIndex}, or [] if cancelled

classdef linespecGUI < matlab.apps.AppBase

    properties (Access = public)
        UIFigure           matlab.ui.Figure
        Panel1             matlab.ui.container.Panel
        Panel2             matlab.ui.container.Panel
        Panel3             matlab.ui.container.Panel
        ColorListTable     matlab.ui.control.Table
        StyleListbox       matlab.ui.control.ListBox
        ButtonColor        cell % 1x8 uibutton (color swatches)
        ButtonLine         cell % 1x4 uibutton (line style samples)
        ButtonTopColor     matlab.ui.control.Button
        ButtonUpColor      matlab.ui.control.Button
        ButtonDownColor    matlab.ui.control.Button
        ButtonDefaultColor matlab.ui.control.Button
        ButtonTopStyle     matlab.ui.control.Button
        ButtonUpStyle      matlab.ui.control.Button
        ButtonDownStyle    matlab.ui.control.Button
        ButtonDefaultStyle matlab.ui.control.Button
        DropdownLineWidth  matlab.ui.control.DropDown
        ButtonOK           matlab.ui.control.Button
        ButtonCancel       matlab.ui.control.Button
    end

    properties (Access = public)
        output       % {colorStyleStrings, lwidthIndex}, or [] if cancelled
        Finishbutton % Set to 1 when dialog closes (waitfor trigger)
    end

    properties (Access = private)
        COLORDATA
        STYLEDATA
        nbin
        defcolor
        defstyle
    end

    methods (Access = private)

        function startupFcn(app, varargin)
            try; def = varargin{1}; catch; def = []; end
            try; nbin = varargin{2}; catch; nbin = 1; end
            try; lwidth = varargin{3}; catch; lwidth = 1; end

            defs   = {'-' '-.' '--' ':'};
            defcol = getcolorcellerps;

            if isempty(def)
                defcolor = repmat(defcol, 1, length(defs));
                d = repmat(defs', 1, length(defcol));
                defstyle = reshape(d', 1, numel(d));
            else
                defcolor = regexp(def,'\w*','match');
                defcolor = [defcolor{:}];
                defstyle = regexp(def,'\W*','match');
                defstyle = [defstyle{:}];
                if isempty(defcolor)
                    defcolor = repmat(defcol, 1, nbin*length(defs));
                    d = repmat(defs', 1, nbin*length(defcol));
                    defstyle = reshape(d', 1, numel(d));
                end
                if isempty(defstyle)
                    d = repmat(defs', 1, nbin*length(defcol));
                    defstyle = reshape(d', 1, numel(d));
                end
            end

            app.COLORDATA = app.colores(defcolor);
            app.STYLEDATA = app.estilos(defstyle);
            app.DropdownLineWidth.Items = arrayfun(@num2str, 1:20, 'UniformOutput', false);
            app.DropdownLineWidth.ItemsData = 1:20;
            app.DropdownLineWidth.Value = lwidth;

            app.defcolor = defcolor;
            app.defstyle = defstyle;
            app.nbin = nbin;

            app.refreshColorList();
            app.refreshStyleList();

            for k = 1:length(defcol)
                cwrd = app.colorWord(defcol{k});
                app.ButtonColor{k}.UserData = cwrd;
                app.setColorButtonAppearance(k, cwrd);
            end
            for k = 1:length(defs)
                lwrd = app.styleWord(defs{k});
                app.ButtonLine{k}.Text = defs{k};
                app.ButtonLine{k}.UserData = lwrd;
            end

            app.output = [];
            app.Finishbutton = 0;
        end

        % --- shared list-rebuild helpers ---
        function refreshColorList(app)
            COLORDATA = app.COLORDATA;
            nbin = app.nbin;
            n = length(COLORDATA);
            maxdig = length(num2str(n))+1;
            items = cell(n,1);
            rgb = zeros(n,3);
            for i = 1:n
                numstr = num2str(i);
                if i<=nbin
                    tag = ['L' repmat('0',1,maxdig-length(numstr)) numstr ':'];
                else
                    tag = 'empty..:';
                end
                items{i} = sprintf('%s %s', tag, upper(COLORDATA(i).colorname));
                rgb(i,:) = COLORDATA(i).colorrgb;
            end
            app.ColorListTable.Data = items;
            removeStyle(app.ColorListTable);
            [uniqueRgb, ~, grp] = unique(rgb, 'rows');
            for g = 1:size(uniqueRgb,1)
                rows = find(grp==g);
                addStyle(app.ColorListTable, uistyle('FontColor', uniqueRgb(g,:)), 'row', rows);
            end
        end

        function refreshStyleList(app)
            STYLEDATA = app.STYLEDATA;
            nbin = app.nbin;
            n = length(STYLEDATA);
            maxdig = length(num2str(n))+1;
            items = cell(1,n);
            for i = 1:n
                numstr = num2str(i);
                if i<=nbin
                    tag = ['L' repmat('0',1,maxdig-length(numstr)) numstr ':'];
                else
                    tag = 'empty..:';
                end
                items{i} = sprintf('%s %s', tag, STYLEDATA(i).line);
            end
            app.StyleListbox.Items = items;
            app.StyleListbox.ItemsData = 1:n;
            if isempty(app.StyleListbox.Value) || app.StyleListbox.Value > n
                app.StyleListbox.Value = 1;
            end
        end

        function setColorButtonAppearance(app, ind, colorword)
            persistent iconCache
            try
                p = app.ButtonColor{ind}.Position;
                w = p(3); h = p(4);
                cachekey = sprintf('%s_%dx%d', colorword, w, h);
                if isfield(iconCache, cachekey)
                    imgbutton = iconCache.(cachekey);
                else
                    img = imread(['erplab_' colorword '.jpg']);
                    steprow = ceil(size(img,1)/(5*h));
                    stecolu = ceil(size(img,2)/(10*w));
                    imgbutton = img(1:steprow:end,1:stecolu:end,:);
                    iconCache.(cachekey) = imgbutton;
                end
                app.ButtonColor{ind}.Text = '';
                app.ButtonColor{ind}.Icon = imgbutton;
            catch
                app.ButtonColor{ind}.Text = lower(colorword(1:2));
            end
        end

        % --- Color swatch buttons (shared callback for all 8) ---
        function colorSwatchPushed(app, event)
            colorbtn = event.Source.UserData;
            currline = app.ColorListTable.Selection;
            if isempty(currline); return; end
            items = app.ColorListTable.Data;
            ind = find(contains(items, upper(colorbtn)), 1, 'last');
            COLORDATA = app.COLORDATA;
            ncolor = length(COLORDATA);
            if ~isempty(ind) && currline>=1 && currline<=ncolor
                aux = COLORDATA(currline);
                COLORDATA(currline) = COLORDATA(ind);
                COLORDATA(ind) = aux;
                app.COLORDATA = COLORDATA;
                app.refreshColorList();
            end
        end

        % --- Line style buttons (shared callback for all 4) ---
        function lineStylePushed(app, event)
            linebtn = event.Source.UserData;
            currline = app.StyleListbox.Value;
            if isempty(currline); return; end
            items = app.StyleListbox.Items;
            ind = find(contains(items, linebtn), 1, 'last');
            STYLEDATA = app.STYLEDATA;
            ncolor = length(STYLEDATA);
            if ~isempty(ind) && currline>=1 && currline<=ncolor
                aux = STYLEDATA(currline);
                STYLEDATA(currline) = STYLEDATA(ind);
                STYLEDATA(ind) = aux;
                app.STYLEDATA = STYLEDATA;
                app.refreshStyleList();
            end
        end

        % --- Color list reordering ---
        function moveColorUp(app, ~)
            currline = app.ColorListTable.Selection;
            if isempty(currline); return; end
            COLORDATA = app.COLORDATA;
            ncolor = length(COLORDATA);
            if currline>1 && currline<=ncolor
                aux = COLORDATA(currline);
                COLORDATA(currline) = COLORDATA(currline-1);
                COLORDATA(currline-1) = aux;
                app.COLORDATA = COLORDATA;
                app.refreshColorList();
                app.ColorListTable.Selection = currline-1;
            end
        end

        function moveColorDown(app, ~)
            currline = app.ColorListTable.Selection;
            if isempty(currline); return; end
            COLORDATA = app.COLORDATA;
            ncolor = length(COLORDATA);
            if currline>=1 && currline<ncolor
                aux = COLORDATA(currline);
                COLORDATA(currline) = COLORDATA(currline+1);
                COLORDATA(currline+1) = aux;
                app.COLORDATA = COLORDATA;
                app.refreshColorList();
                app.ColorListTable.Selection = currline+1;
            end
        end

        function moveColorTop(app, ~)
            currline = app.ColorListTable.Selection;
            if isempty(currline); return; end
            COLORDATA = app.COLORDATA;
            ncolor = length(COLORDATA);
            if currline>1 && currline<=ncolor
                aux = COLORDATA(currline);
                COLORDATA(currline) = [];
                COLORDATA = [aux COLORDATA];
                app.COLORDATA = COLORDATA;
                app.refreshColorList();
                app.ColorListTable.Selection = 1;
            end
        end

        function resetColorDefault(app, ~)
            app.COLORDATA = app.colores(app.defcolor);
            app.refreshColorList();
        end

        % --- Style list reordering ---
        function moveStyleUp(app, ~)
            currline = app.StyleListbox.Value;
            if isempty(currline); return; end
            STYLEDATA = app.STYLEDATA;
            ncolor = length(STYLEDATA);
            if currline>1 && currline<=ncolor
                aux = STYLEDATA(currline);
                STYLEDATA(currline) = STYLEDATA(currline-1);
                STYLEDATA(currline-1) = aux;
                app.STYLEDATA = STYLEDATA;
                app.refreshStyleList();
                app.StyleListbox.Value = currline-1;
            end
        end

        function moveStyleDown(app, ~)
            currline = app.StyleListbox.Value;
            if isempty(currline); return; end
            STYLEDATA = app.STYLEDATA;
            ncolor = length(STYLEDATA);
            if currline>=1 && currline<ncolor
                aux = STYLEDATA(currline);
                STYLEDATA(currline) = STYLEDATA(currline+1);
                STYLEDATA(currline+1) = aux;
                app.STYLEDATA = STYLEDATA;
                app.refreshStyleList();
                app.StyleListbox.Value = currline+1;
            end
        end

        function moveStyleTop(app, ~)
            currline = app.StyleListbox.Value;
            if isempty(currline); return; end
            STYLEDATA = app.STYLEDATA;
            ncolor = length(STYLEDATA);
            if currline>1 && currline<=ncolor
                aux = STYLEDATA(currline);
                STYLEDATA(currline) = [];
                STYLEDATA = [aux STYLEDATA];
                app.STYLEDATA = STYLEDATA;
                app.refreshStyleList();
                app.StyleListbox.Value = 1;
            end
        end

        function resetStyleDefault(app, ~)
            app.STYLEDATA = app.estilos(app.defstyle);
            app.refreshStyleList();
        end

        function cancelBtn(app, ~)
            app.output = [];
            app.Finishbutton = 1;
        end

        function okBtn(app, ~)
            lwidth = app.DropdownLineWidth.Value;
            COLORDATA = app.COLORDATA;
            STYLEDATA = app.STYLEDATA;
            n = length(COLORDATA);
            output = cell(1,n);
            for i = 1:n
                output{i} = [COLORDATA(i).colorchar STYLEDATA(i).style];
            end
            app.output = {output, lwidth};
            app.Finishbutton = 1;
        end
    end

    methods (Static, Access = private)
        function COLORDATA = colores(defcolor)
            for i = 1:length(defcolor)
                COLORDATA(i).colorchar = defcolor{i}; %#ok<AGROW>
                switch defcolor{i}
                    case 'k'; COLORDATA(i).colorname='black';   COLORDATA(i).colorrgb=[0 0 0];
                    case 'r'; COLORDATA(i).colorname='red';     COLORDATA(i).colorrgb=[1 0 0];
                    case 'b'; COLORDATA(i).colorname='blue';    COLORDATA(i).colorrgb=[0 0 1];
                    case 'g'; COLORDATA(i).colorname='green';   COLORDATA(i).colorrgb=[0 0.5647 0];
                    case 'c'; COLORDATA(i).colorname='cyan';    COLORDATA(i).colorrgb=[0 1 1];
                    case 'm'; COLORDATA(i).colorname='magenta'; COLORDATA(i).colorrgb=[1 0 1];
                    case 'y'; COLORDATA(i).colorname='yellow';  COLORDATA(i).colorrgb=[1 0.8431 0]; % gold, matches original #FFD700
                    case 'w'; COLORDATA(i).colorname='white';   COLORDATA(i).colorrgb=[0.6 0.6 0.6]; % gray for legibility against the table's white background; the actual line color stays true white ('w' in colorchar)
                    otherwise; COLORDATA(i).colorname='black';  COLORDATA(i).colorrgb=[0 0 0];
                end
            end
        end

        function STYLEDATA = estilos(defstyle)
            for i = 1:length(defstyle)
                switch defstyle{i}
                    case {'-',''}; STYLEDATA(i).line='solid';    STYLEDATA(i).style='-'; %#ok<AGROW>
                    case '-.';     STYLEDATA(i).line='dash-dot'; STYLEDATA(i).style='-.'; %#ok<AGROW>
                    case '--';     STYLEDATA(i).line='dashed';   STYLEDATA(i).style='--'; %#ok<AGROW>
                    case ':';      STYLEDATA(i).line='dotted';   STYLEDATA(i).style=':'; %#ok<AGROW>
                    otherwise;     STYLEDATA(i).line='dot';      STYLEDATA(i).style='-'; %#ok<AGROW>
                end
            end
        end

        function cwrd = colorWord(colorchar)
            switch colorchar
                case 'k'; cwrd = 'BLACK';
                case 'r'; cwrd = 'RED';
                case 'b'; cwrd = 'BLUE';
                case 'g'; cwrd = 'GREEN';
                case 'c'; cwrd = 'CYAN';
                case 'm'; cwrd = 'MAGENTA';
                case 'y'; cwrd = 'YELLOW';
                case 'w'; cwrd = 'WHITE';
                otherwise; error('color error...')
            end
        end

        function lwrd = styleWord(styleChar)
            switch styleChar
                case '-';  lwrd = 'solid';
                case '-.'; lwrd = 'dash-dot';
                case '--'; lwrd = 'dashed';
                case ':';  lwrd = 'dotted';
                otherwise; error('line error...')
            end
        end
    end

    % --- Component initialization ---
    methods (Access = private)

        function createComponents(app)
            % Layout positions below are on a 515x276 design grid, scaled by
            % SX/SY (same GUIDE character-unit auto-scale factor measured on
            % DQ_Table_GUI.m/DQ_Spectra_GUI.m, same machine -- verify live,
            % this is a different/smaller design canvas than those two so
            % the ratio isn't guaranteed to transfer exactly). FontSize is
            % NOT scaled -- it's an absolute value independent of the
            % layout grid.
            SX = 1010/758; SY = 770/641;
            P  = @(x,y,w,h) [round(x*SX) round(y*SY) round(w*SX) round(h*SY)];
            FIG_W = round(515*SX); FIG_H = round(276*SY);
            GRAY  = [0.94 0.94 0.94];

            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Position = [100 100 FIG_W FIG_H];
            app.UIFigure.Name = 'linespecGUI';
            app.UIFigure.Resize = 'off';
            app.UIFigure.Color = GRAY;

            % --- Panel1: colors ---
            app.Panel1 = uipanel(app.UIFigure);
            app.Panel1.Position = P(8, 12, 203, 255);
            app.Panel1.BackgroundColor = GRAY;

            app.ColorListTable = uitable(app.Panel1);
            app.ColorListTable.Position = P(8, 68, 157, 180);
            app.ColorListTable.ColumnName = {'Color'};
            app.ColorListTable.RowName = {};
            app.ColorListTable.ColumnWidth = {'auto'};
            app.ColorListTable.ColumnEditable = false;
            app.ColorListTable.SelectionType = 'row';
            app.ColorListTable.Multiselect = 'off';
            app.ColorListTable.FontSize = 11;

            app.ButtonColor = cell(1,8);
            colorYs = [222 191 160 129 97 66 35 4];
            for k = 1:8
                b = uibutton(app.Panel1, 'push');
                b.Position = P(172, colorYs(k), 24, 27);
                b.Text = '';
                b.ButtonPushedFcn = createCallbackFcn(app, @colorSwatchPushed, true);
                app.ButtonColor{k} = b;
            end

            app.ButtonTopColor = uibutton(app.Panel1, 'push');
            app.ButtonTopColor.Position = P(20, 5, 36, 60);
            app.ButtonTopColor.Text = 'Top';
            app.ButtonTopColor.FontSize = 9;
            app.ButtonTopColor.ButtonPushedFcn = createCallbackFcn(app, @moveColorTop, true);

            app.ButtonUpColor = uibutton(app.Panel1, 'push');
            app.ButtonUpColor.Position = P(58, 30, 45, 36);
            app.ButtonUpColor.Text = 'Up';
            app.ButtonUpColor.FontSize = 9;
            app.ButtonUpColor.ButtonPushedFcn = createCallbackFcn(app, @moveColorUp, true);

            app.ButtonDownColor = uibutton(app.Panel1, 'push');
            app.ButtonDownColor.Position = P(100, 30, 45, 36);
            app.ButtonDownColor.Text = 'Down';
            app.ButtonDownColor.FontSize = 9;
            app.ButtonDownColor.ButtonPushedFcn = createCallbackFcn(app, @moveColorDown, true);

            app.ButtonDefaultColor = uibutton(app.Panel1, 'push');
            app.ButtonDefaultColor.Position = P(57, 4, 86, 30);
            app.ButtonDefaultColor.Text = 'default';
            app.ButtonDefaultColor.FontSize = 9;
            app.ButtonDefaultColor.ButtonPushedFcn = createCallbackFcn(app, @resetColorDefault, true);

            % --- Panel2: styles ---
            app.Panel2 = uipanel(app.UIFigure);
            app.Panel2.Position = P(217, 12, 203, 255);
            app.Panel2.BackgroundColor = GRAY;

            app.StyleListbox = uilistbox(app.Panel2);
            app.StyleListbox.Position = P(8, 68, 157, 180);
            app.StyleListbox.FontSize = 11;

            app.ButtonLine = cell(1,4);
            lineYs = [216 185 153 122];
            for k = 1:4
                b = uibutton(app.Panel2, 'push');
                b.Position = P(170, lineYs(k), 24, 27);
                b.FontSize = 16;
                b.ButtonPushedFcn = createCallbackFcn(app, @lineStylePushed, true);
                app.ButtonLine{k} = b;
            end

            app.ButtonTopStyle = uibutton(app.Panel2, 'push');
            app.ButtonTopStyle.Position = P(16, 5, 36, 60);
            app.ButtonTopStyle.Text = 'Top';
            app.ButtonTopStyle.FontSize = 9;
            app.ButtonTopStyle.ButtonPushedFcn = createCallbackFcn(app, @moveStyleTop, true);

            app.ButtonUpStyle = uibutton(app.Panel2, 'push');
            app.ButtonUpStyle.Position = P(55, 29, 45, 36);
            app.ButtonUpStyle.Text = 'Up';
            app.ButtonUpStyle.FontSize = 9;
            app.ButtonUpStyle.ButtonPushedFcn = createCallbackFcn(app, @moveStyleUp, true);

            app.ButtonDownStyle = uibutton(app.Panel2, 'push');
            app.ButtonDownStyle.Position = P(97, 30, 45, 36);
            app.ButtonDownStyle.Text = 'Down';
            app.ButtonDownStyle.FontSize = 9;
            app.ButtonDownStyle.ButtonPushedFcn = createCallbackFcn(app, @moveStyleDown, true);

            app.ButtonDefaultStyle = uibutton(app.Panel2, 'push');
            app.ButtonDefaultStyle.Position = P(55, 3, 86, 30);
            app.ButtonDefaultStyle.Text = 'default';
            app.ButtonDefaultStyle.FontSize = 9;
            app.ButtonDefaultStyle.ButtonPushedFcn = createCallbackFcn(app, @resetStyleDefault, true);

            % --- Panel3: line width ---
            app.Panel3 = uipanel(app.UIFigure);
            app.Panel3.Title = 'Line width';
            app.Panel3.Position = P(422, 182, 90, 71);
            app.Panel3.BackgroundColor = GRAY;

            app.DropdownLineWidth = uidropdown(app.Panel3);
            app.DropdownLineWidth.Position = P(17, 15, 69, 29);
            app.DropdownLineWidth.FontSize = 10;

            app.ButtonCancel = uibutton(app.UIFigure, 'push');
            app.ButtonCancel.Position = P(422, 111, 90, 60);
            app.ButtonCancel.Text = 'Cancel';
            app.ButtonCancel.FontSize = 10;
            app.ButtonCancel.ButtonPushedFcn = createCallbackFcn(app, @cancelBtn, true);

            app.ButtonOK = uibutton(app.UIFigure, 'push');
            app.ButtonOK.Position = P(422, 42, 90, 60);
            app.ButtonOK.Text = 'Ok';
            app.ButtonOK.FontSize = 10;
            app.ButtonOK.ButtonPushedFcn = createCallbackFcn(app, @okBtn, true);

            app.UIFigure.Visible = 'on';
        end
    end

    % --- App creation and deletion ---
    methods (Access = public)

        function app = linespecGUI(varargin)
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
