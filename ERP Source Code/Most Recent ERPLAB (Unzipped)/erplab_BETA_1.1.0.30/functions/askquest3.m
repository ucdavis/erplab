function button =askquest3(question, tittle)

button = ''; %#ok<NASGU>

if iscell(question)
        disp(question{1})
else
        disp(question)
end

BackERPLABcolor = [1 0.9 0.3]; %[ 0.65 0.68 .6];

oldcolor = get(0,'DefaultUicontrolBackgroundColor');
set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
button = questdlg(question, tittle,'Yes','Hold', 'Cancel','Yes');
set(0,'DefaultUicontrolBackgroundColor',oldcolor)
