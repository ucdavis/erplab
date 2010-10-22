function button =askquest(question, tittle, defresp)

button = '';
if nargin<3
        defresp = 'Yes';
end

disp(char(question))
TXCOLOR = [1 0.9 0.3];
oldcolor = get(0,'DefaultUicontrolBackgroundColor');
set(0,'DefaultUicontrolBackgroundColor',TXCOLOR)
button = questdlg(question, tittle,'Yes','NO', defresp);
set(0,'DefaultUicontrolBackgroundColor',oldcolor)

