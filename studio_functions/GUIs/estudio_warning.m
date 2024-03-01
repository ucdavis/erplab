



function estudio_warning(Messagestr,titleName)

if nargin<1
    help estudio_warning
    return
end
if nargin<2
    titleName = '';
end

if isempty(Messagestr)
    help estudio_warning
    return
end

FonsizeDefault = f_get_default_fontsize();
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;%%Get background color
catch
    ColorB_def = [0.95 0.95 0.95];
end
if isempty(ColorB_def)
    ColorB_def = [0.95 0.95 0.95];
end

mh = msgbox(Messagestr, ['Estudio:',32,titleName]);     %create msgbox
mh.Resize = 'on';
th = findall(mh, 'Type', 'Text');                   %get handle to text within msgbox
th.FontSize = FonsizeDefault;
deltaWidth = sum(th.Extent([1,3]))-mh.Position(3) + th.Extent(1);
deltaHeight = sum(th.Extent([2,4]))-mh.Position(4) + 10;
mh.Position([3,4]) = mh.Position([3,4]) + [deltaWidth, deltaHeight];

set(mh,'color',ColorB_def);
delete(findobj(mh,'string','OK'));
delete(findobj(mh,'style','frame'));
end