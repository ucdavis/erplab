%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

function showinfront(ERP, CURRENTERP)

W_MAIN     = findobj('parent', gcf, 'tag', 'Frame1');
g = [];
hh = findobj('parent', gcf);
for index = 1:length(hh)
        if ~isempty(get(hh(index), 'tag'))
                g = setfield(g, get(hh(index), 'tag'), hh(index));
        end;
end;

if CURRENTERP == 0
        strerpnum = '';
else
        strerpnum = ['@' int2str(CURRENTERP) ': '];
end;

maxchar = 28;

if ~isempty( ERP.erpname )
        if length(ERP.erpname) > maxchar+2
                set( g.win0, 'String', [strerpnum ERP.erpname(1:min(maxchar,length(ERP.erpname))) '...' ]);
        else set( g.win0, 'String', [strerpnum ERP.erpname ]);
        end;
else
        set( g.win0, 'String', [strerpnum '(no erpset name)' ] );
end

hh = findobj('parent', gcf, 'userdata', 'fullline');
set(hh, 'visible', 'off');

set( g.win2, 'String', 'Channels ');
set( g.win3, 'String', 'Samples per bin');
set( g.win4, 'String', 'Bins');
set( g.win5, 'String', '');
set( g.win6, 'String', 'Sampling rate (Hz)');
set( g.win7, 'String', 'ERP start (sec)');
set( g.win8, 'String', 'ERP end (sec)');
set( g.win9, 'String', 'Average reference');
set( g.win10, 'String', 'Channel locations');
set( g.win11, 'String', '');
set( g.win12, 'String', 'Dataset size (Mb)');
filename = ERP.filename;
if ~isempty(filename)
        
        fullerpfname = [ ERP.filepath filename];
        
        if length(fullerpfname) > 26
                set( g.win1, 'String', sprintf('Filename: ...%s\n', fullerpfname(max(1,length(fullerpfname)-26):end) ));
        else
                set( g.win1, 'String', sprintf('Filename: %s\n', fullerpfname));
        end;
else
        set( g.win1, 'String', sprintf('Filename: none\n'));
end;

set( g.val2, 'String', int2str(size(ERP.bindata,1)));
set( g.val3, 'String', int2str(ERP.pnts));
set( g.val4, 'String', int2str(ERP.nbin));
set( g.val5, 'String', '');
set( g.val6, 'String', int2str( round(ERP.srate)) );

if round(ERP.xmin) == ERP.xmin && round(ERP.xmax) == ERP.xmax
        set( g.val7, 'String', sprintf('%d\n', ERP.xmin));
        set( g.val8, 'String', sprintf('%d\n', ERP.xmax));
else
        set( g.val7, 'String', sprintf('%6.3f\n', ERP.xmin));
        set( g.val8, 'String', sprintf('%6.3f\n', ERP.xmax));
end;

set( g.val9, 'String', fastif(strcmpi(ERP.ref, 'averef'), 'Yes', 'No'));

if isempty(ERP.chanlocs)
        set( g.val10, 'String', 'No');
else
        if ~isfield(ERP.chanlocs, 'theta') || all(cellfun('isempty', { ERP.chanlocs.theta }))
                set( g.val10, 'String', 'No (labels only)');
        else
                set( g.val10, 'String', 'Yes');
        end;
end;

set( g.val11, 'String', '');
tmp = whos('ERP');
set( g.val12, 'String', num2str(round(tmp.bytes/1E6*10)/10));
