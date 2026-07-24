% test_str2html  - test script to run a simple and more complex tests
%
%  1st test will create a GUI which has 2 uicontrols with HTML format text
%      in this test each line has the same format
%  
%  2nd test will create a GUI with 3 uicontrols, where each line can have
%      a combination of html formatting
%
%   see also str2html
%
% Copyright Robert Cumming, rcumming @ matpi.com
% website:  www.matpi.com
%
% $Id: test_str2html.m 30 2014-05-26 18:32:02Z Bob $
function test_str2html ( varargin );
  if nargin == 1 && nargout == 0 && strcmp ( varargin{1}, '-version' )
    fprintf ( '%s Version: $Id: test_str2html.m 30 2014-05-26 18:32:02Z Bob $\n', mfilename );      
    return
  end
  home
  h = test_str2html_simpleFormatting;
  uiwait ( h );
  test_str2html_combinations;
  %%
  fprintf ( 'If you run: \n           str2html ( ''*default*'', ''bold'', true );\n\n  and then run this function again you will see the impact of changing the default settings\n\n' );
  
end
function hFig = test_str2html_simpleFormatting
  str{1} = str2html ( 'A list Box', 'color', 'green' );
  str{2} = str2html ( 'with different', 'color', 'red', 'bold', true );
  str{3} = str2html ( 'items which', 'bgcolor', 'yellow', 'underline', true );
  str{4} = str2html ( 'all have', 'italic', true );
  str{5} = str2html ( 'individual', 'fontsize', '-4' );
  str{6} = str2html ( 'formats', 'fontname', 'Courier New' );
  str{7} = '';
  str{8} = '';
  str{9} = str2html ( 'Hover over listbox to see tooltip', 'bold', 'true', 'color', 'blue' );

  tooltip = str2html ( 'HTML also has sub and superscript', 'subscript', 'Sub Script Here', 'superscript', 'Super Script Here' );
  hFig = dialog ( 'windowstyle', 'normal' );
  uicontrol ( 'parent', hFig, 'style', 'listbox', 'units', 'normalized', ...
    'position', [0.05 0.5 0.9 0.45], 'string', str, 'fontsize', 12, 'tooltipstr', tooltip );
  btnStr{1} = str2html ( 'A Button Can Also use HTML', 'color', 'green', 'bold', 1 );
  btnStr{2} = str2html ( 'RightClick to see context menu', 'color', 'blue' );
  
  uic = uicontextmenu('parent', hFig);
  uimenu ( 'parent', uic, 'label', str2html ( 'Menu 01', 'colour', 'red', 'superscript', 'SUPER' ) );
  uicontrol ( 'parent', hFig, 'style', 'pushbutton', 'units', 'normalized', ...
    'position', [0.05 0.05 0.9 0.35], 'string', str2html ( btnStr, '\n' ), 'fontsize', 12, 'UIContext', uic );
end
function test_str2html_combinations
    
  str{1} = str2html ( 'A Push Button containing', 'color', 'green' );
  line2{1} = str2html ( 'Multi-Line', 'bold', 1 );
  line2{2} = str2html ( 'HTML', 'underline', 1 );
  line2{3} = str2html ( 'with different' );
  line2{4} = str2html ( 'formatting', 'color', 'blue', 'italic', 1 );
  str{2} = str2html ( line2, ' ' );
  buttonstr = str2html ( str, '\n' );
  % create some other text to go in the tooltip
  str{1}    = str2html ( 'The tooltip can also have', 'color', 'green', 'fontname', 'Courier New', 'fontsize', '+2' );
  extras{1} = str2html ( 'HTML can also have super', 'superscript', 'script' );
  extras{2} = str2html ( 'and sub', 'subscript', 'script' );
  str{3} = str2html ( extras, ' ' );
  tooltip = str2html ( str, '\n' );
  % create the uicontrol and add the html format string to the button and tooltip
  hFig = dialog ( 'windowstyle', 'normal' );
  uicontrol ( 'parent', hFig, 'style', 'pushbutton', 'units', 'normalized', ...
    'position', [0.05 0.8 0.4 0.1], 'string', buttonstr, 'tooltipstr', tooltip );
  
  str{1} = str2html ( 'Pop/List box can have', 'color', 'green', 'fontname', 'Courier New', 'fontsize', '-2' );
  tooltip = str2html ( 'A list box can also have HTML', 'bgcolor', 'green', 'fontsize', 12 );
  uicontrol ( 'parent', hFig, 'style', 'listbox', 'units', 'normalized', ...
    'position', [0.05 0.3 0.7 0.3], 'string', str, 'tooltipstr', tooltip );
  
  tooltip = str2html ( 'A popup menu can also have HTML', 'bgcolor', 'green', 'fontsize', 12 );
  uicontrol ( 'parent', hFig, 'style', 'popupmenu', 'units', 'normalized', ...
    'position', [0.05 0.2 0.7 0.1], 'string', str, 'tooltipstr', tooltip );
  
  % add your own HTML tags - prefix and suffix, in this case its adding a bullet point.
  yourCode{1} = str2html ( 'Add your own HTML code:', 'prefix', '<li>', 'suffix', '</li>' );
  uicontrol ( 'parent', hFig, 'style', 'pushbutton', 'units', 'normalized', ...
    'position', [0.05 0.05 0.7 0.1], 'string', yourCode );
  
end