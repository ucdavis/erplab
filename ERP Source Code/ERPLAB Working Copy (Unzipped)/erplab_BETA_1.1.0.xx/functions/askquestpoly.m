function button =askquestpoly(question, tittle, buttonscell)

button = ''; %#ok<NASGU>

if iscell(question)
        disp(question{1})
else
        disp(question)
end

TXCOLOR = [1 0.9 0.3];

oldcolor = get(0,'DefaultUicontrolBackgroundColor');
set(0,'DefaultUicontrolBackgroundColor', TXCOLOR)

if ~iscell(buttonscell)
        error('buttons name must be entered as cellstrings')
end

nbuttons = length(buttonscell);

if nbuttons>3
        error('For now, askquestpoly() only works until 3 buttons. Sorry')
end
if nbuttons==0
        error('You must enter 1 button name at least!')
end


comcall = 'button = questdlg(question, tittle';

for i=1:nbuttons
        comcall = [comcall ', ''' buttonscell{i} '''' ];
end

comcall = [comcall ',''' buttonscell{1} ''');'];

eval(comcall)

set(0,'DefaultUicontrolBackgroundColor',oldcolor)
