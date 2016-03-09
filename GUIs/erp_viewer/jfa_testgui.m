function jfa_testgui( )
%JFA_TESTGUI Summary of this function goes here
%   Detailed explanation goes here

S.Window = figure( ...
    'Name'       , 'JFA Test GUI', ...
    'MenuBar'    , 'none', ...
    'Toolbar'    , 'none', ...
    'NumberTitle', 'off' );

panel = uix.VBox( 'Parent', S.Window);

num_elements = 5;
for ii = 1:num_elements
    uicontrol(...
        'Parent' , panel   , ...
        'String' , 'Hello' );
end

%% Scrollable panel
s = uicontrol(...
    'Style','Slider', ...
    'Parent',panel, ...
    'Units','normalized', ...
    'Position',[0.95 0 0.05 1],...
    'Value',1, ...
    'Callback',{@slider_callback1,panel});

% Callback function:

function slider_callback1(src,~,arg1)
    %# slider value
    offset = get(src,'Value');

    %# update panel position
    p = get(arg1, 'Position');  %# panel current position
    set(arg1, 'Position',[p(1) -offset p(3) p(4)])
end


end

