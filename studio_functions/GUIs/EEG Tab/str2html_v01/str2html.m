%%dowload from https://www.mathworks.com/matlabcentral/fileexchange/46755-str2html?s_tid=srchtitle


%  str2html   Convert input str to html format for use in uicontrols/menus
%
%   uimenus and some uicontrols accept html format strings, e.g. pushbutton, 
%      listbox, popupmenu (this list is controlled by Mathworks)
%
%   This function allows you to easily create html strings to display in 
%     the controls.
%
%   The function works by passing in a str and arg pairs:
%
%      htmlStr = str2html ( yourChar, P-V pairs )
%
%          yourChar      'a valid char string';
%
%    Valid arg pairs are:
%
%          'bold'        true | ( false )   % bold format
%          'italic'      true | ( false )   % italic format
%          'underline'   true | ( false )   % underline format
%          'fontsize'    8                  % size in int
%          'fontsize'    '+2'               % increment size from default
%          'colour'      'black'            % colour of text $
%          'color'       'black'            % same as colour $
%          'fontname'    'MS Sans Serif'    % font name
%          'superscript' ''                 % any superscript text ^
%          'subscript'   ''                 % any subscript text   ^
%          'bgcolour'    'white'            % background colour $
%          'bgcolor'     'white'            % same as bgcolour  $
%          'prefix'      ''                 % add your own prefix hmtl*
%          'suffix'      ''                 % add your own suffix hmtl*
%          'userWarn'    true | false       % flag to display warnings
%          
%   $ Colour and color are the same thing - only the different spelling is
%       managed.  User can input colour as 'NAME' or as 'HEXCODE'
%
%   ^ If sub & super script are added - then the subscript is added first.
%
%   * The idea of prefix and suffix is to add your own start and end tags 
%      to the html code that is generated - if only one is added a warning
%      will be shown unless you add  'userWarn', false
%
%   For combing HTML format strings into one larger string, e.g. multi
%      format on one line or multiple lines use:
%
%      yourCell{1} = str2html ( 'line1', pararm, value.... );
%      yourCell{2} = str2html ( 'line2', pararm, value.... );
%      yourCell{N} = str2html ( 'line2', pararm, value.... );
%
%    htmlStr = str2html ( yourCell, joinFormat )
%
%       yourCell      cell array of HTML formatted strings
%       joinFormat     '\n' '\r' '<br>'  % html line break "<br>"
%                      ' '               % html space: "&nbsp"
%                      'yourString'      % any ohter string provided by you.
%
%  The code uses persistent variables so you can change the defaults
%     use following syntax.  Note : No output.
%
%       str2html ( '*default*', 'bold', true )
%       str2html ( '*default*', 'fontname', 'Courier New' );
%
%       Special case for colour codes. e.g change default orange too:
%       str2html ( '*default*', 'colour:orange', '#FFBF40' ); 
%
%   This will change the defaults for THIS MATLAB session ONLY.
%
%       Reset all the changes made by the user.
%       str2html ( '*reset*' )
%
%  Examples:
%
%  str = str2html ( 'YOUR TEXT', 'bold', 1, 'italic', 1, 'underline', 1, ...
%                   'fontsize', 5, 'colour', 'red', 'fontname', 'Courier New' )
%
%  str = str2html ( 'Change Background Colour', 'bgcolor', 'red', ...
%                     'superscript', 'SuperScript', 'subscript', 'SUB', ...
%                     'fontsize', '+2' )
%
%  % This adds a bullet point to your string.
%  str = str2html ( 'Add your own HTML code:', ...
%                   'prefix', '<li>', 'suffix', '</li>' );
%
%
%  For multi format lines or multiple lines use multiple calls:
%    line1{1} = str2html ( 'line #1', 'bold', 1, 'fontname', 'Courier New' );
%    line1{2} = str2html ( 'No format' );
%    line1{3} = str2html ( 'underline', 'underline', 1 );
%    line1{4} = str2html ( 'italic', 'italic', 1, 'subscript', 'mySub' );
%    line1{5} = str2html ( 'finish', 'colour', 'green', ...
%                          'superscript', 'mySuper!!' );
%    str{1} = str2html ( line1, ' ' )
%    str{2} = str2html ( 'line #2', 'italic', 1, 'color', 'red' );
%    str2 = str2html ( str, '\n' );
%    h = uicontrol ( 'style', 'listbox' );
%    set(h,'tooltipString', str2 );
%
%   see also  test_str2html
%
%   DEVELOPER NOTE: This file uses mlock
%
% Copyright Robert Cumming, rcumming @ matpi.com
% website:  www.matpi.com
%
%  $Id: str2html.m 30 2014-05-26 18:32:02Z Bob $

function output = str2html ( varargin )
  % lock the file so that persistent variable remains in memory.
  mlock
  
  if nargin == 1 && nargout == 0 && strcmp ( varargin{1}, '-version' )
    fprintf ( '%s Version: $Id: str2html.m 30 2014-05-26 18:32:02Z Bob $\n', mfilename );      
    return
  end
  
  % check for the special cases for changing defaults or resetting factory values
  if nargout == 0
    if strcmp ( varargin{1}, '*default*' )
      for ii=2:2:nargin
        GetDefaults ( varargin{ii}, varargin{ii+1} );
      end
    elseif strcmp ( varargin{1}, '*reset*' )
      GetDefaults ( '*reset*' );
    end
    return
  end
  
  % for combining multiple HTML together either on one line or on multiple lines
  if iscell ( varargin{1} )
    output = CombineStrings ( varargin{:} );
    return
  end
  
  % manage american/british spelling.... make all color and colour be colour....
  if nargin > 2
    index = strcmp ( varargin(2:2:end), 'color' );
    if any ( index )
      index = find ( index == 1 );
      if length ( index ) > 1
        error ( 'str2html:MultipleColour', 'User defined colour multiple times' );
      end
      varargin{index*2} = 'colour';
    end
    index = strcmp ( varargin(2:2:end), 'bgcolor' );
    if any ( index )
      index = find ( index == 1 );
      if length ( index ) > 1
        error ( 'str2html:MultipleBgColour', 'User defined bgcolour multiple times' );
      end
      varargin{index*2} = 'bgcolour';
    end
  end
  
  % process the input arguments
  [str, options] = ProcessInputArguments ( varargin{:} );
  
  % get the defaults.
  [defaults, defChanged, colCode] = GetDefaults();
  
  % start to build the output string
  output = '<HTML>';
  if ( options.bold );      output = sprintf ( '%s<b>', output ); end
  if ( options.underline ); output = sprintf ( '%s<u>', output ); end
  if ( options.italic );    output = sprintf ( '%s<i>', output ); end
  
  % section for including font formattting
  incFont = false;
  fontstr = '<FONT';
  % font name/style
  if ~strcmp ( defaults.fontname, options.fontname ) || isfield ( defChanged, 'fontname' )
    fontstr = sprintf ( '%s face="%s"', fontstr, options.fontname );
    incFont = true;
  end
  % font colour
  if ~strcmp ( defaults.colour, options.colour ) || isfield ( defChanged, 'colour' )
    if isfield ( colCode, options.colour )
      fontstr = sprintf ( '%s color="%s"', fontstr, colCode.(options.colour) );
    else
      fontstr = sprintf ( '%s color="%s"', fontstr, options.colour );
    end
    incFont = true;
  end
  % font background color
  if ~strcmp ( defaults.bgcolour, options.bgcolour )
    if isfield ( colCode, options.bgcolour )
      fontstr = sprintf ( '%s bgcolor="%s"', fontstr, colCode.(options.bgcolour) );
    else
      fontstr = sprintf ( '%s bgcolor="%s"', fontstr, options.bgcolour );
    end
    incFont = true;
  end
  % font size
  if ~isnumeric ( options.fontsize ) || ~isequal ( defaults.fontsize, options.fontsize ) || isfield ( defChanged, 'fontsize' )
    % user specified absolute size or "+#" increment
    if isnumeric ( options.fontsize )
      fontstr = sprintf ( '%s size="%i"', fontstr, options.fontsize );
    else
      fontstr = sprintf ( '%s size="%s"', fontstr, options.fontsize );
    end
    incFont = true;
  end
  % if any font not MATLAB default then add it to output str
  if incFont
    output = sprintf ( '%s%s>', output, fontstr );
  end
  
  if isempty ( options.prefix ) && isempty ( options.suffix ) || ...% no prefix or suffix
    ~isempty ( options.prefix ) && ~isempty ( options.suffix ) % no prefix or suffix
  else
    if options.userWarn
      warning ( 'str2html:prefixSuffixPair', 'User did not provided prefix and suffix pair' )
    end
  end
  
  if ~isempty ( options.prefix )
    output = sprintf ( '%s%s', output, options.prefix );
  end
  
  % add user string to the output
  output = sprintf ( '%s%s', output, str );
  
  % add any subscript to the END of the string (subscript first)
  if ~isempty ( options.subscript )
    output = sprintf ( '%s<sub>%s</sub>', output, options.subscript );
  end
  % add any superscript to the END of the string.
  if ~isempty ( options.superscript )
    output = sprintf ( '%s<sup>%s</sup>', output, options.superscript );
  end
  
  if ~isempty ( options.suffix )
    output = sprintf ( '%s%s', output, options.suffix );
  end
  
  % close font tag
  if incFont
    output = sprintf ( '%s</font>', output );
  end
  
  % close any other formatting
  if ( options.italic );    output = sprintf ( '%s</i>', output ); end
  if ( options.underline ); output = sprintf ( '%s</u>', output ); end
  if ( options.bold ); output = sprintf ( '%s</b>', output ); end
  % close html
  output = sprintf ( '%s</HTML>', output );
end
%--------------------------------------------------------------------------
% str2html defaults - includes persistent variable to remember between calls
%--------------------------------------------------------------------------
function [output, defChanged, colCode]= GetDefaults( force, item )
  persistent options defaultChanged colourCode
  % 1st time into function or when user "resets"
  if isempty ( options ) || nargin == 1 && strcmp ( force, '*reset*' )
    options.bold = false;
    options.underline = false;
    options.italic = false;
    options.colour = 'black';
    options.superscript = '';
    options.subscript = '';
    options.fontname = 'MS Sans Serif';
    options.fontsize = 8;
    options.bgcolour = 'white';
    options.prefix = '';
    options.suffix = '';
    options.userWarn = true;
    defaultChanged = struct;
    colourCode = struct;
  end
  % this for the user changing the internal defaults
  if nargin == 2
    if isfield ( options, force )
      options.(force) = item;
      defaultChanged.(force) = true;
    else
      % changing the default colour - e.g. change "orange" to be a HEX representation of that color
      if length ( force ) > 7 && strcmp ( force(1:7), 'colour:' )
        colourCode.(force(8:end)) = item;
      elseif length ( force ) > 6 && strcmp ( force(1:6), 'color:' )
        colourCode.(force(7:end)) = item;
      else
        error ( 'str2html:SetDefaults', 'User requested to set non-valid default value' );
      end
    end
  end
  % copy persistent variables to output
  output = options;
  defChanged = defaultChanged;
  colCode = colourCode;
end
%--------------------------------------------------------------------------
% Process the input arguments against the defaults
%--------------------------------------------------------------------------
function [str, options] = ProcessInputArguments ( varargin )
  options = GetDefaults();
  str = varargin{1};
  if mod(nargin,2) == 0
    error ( 'str2html:invalidArgsIn', 'user must input str and then arg pairs' );
  end
  for ii=2:2:nargin
    % check control is a valid option
    if ~isfield ( options, varargin{ii} )
      error ( 'str2html:invalidOption', 'User specifed invalid option %s', varargin{ii} );
    end
    options.(varargin{ii}) = varargin{ii+1};
  end
end
%--------------------------------------------------------------------------
% Function for combining multiple html strings together
%--------------------------------------------------------------------------
function output = CombineStrings ( varargin )
  nStr = length(varargin{1});
  for ii=1:nStr
    if length ( varargin{1}{ii} ) > 6 && ( strcmpi ( varargin{1}{ii}(1:6), '<HTML>' ) ) && ( strcmpi ( varargin{1}{ii}(end-6:end), '</HTML>' ) )
      if ii==1
        output = varargin{1}{ii}(1:end-7);
      elseif ii == nStr
        output = strcat ( output, varargin{1}{ii}(7:end) );
      else
        str = varargin{1}{ii};
        str(end-6:end) = [];
        str(1:6) = [];
        output = strcat ( output, str );
      end
    else
      error ( 'str2html:ConcatString', 'Input string not in HTML format' )
    end
    % if user specified a str join code and its not the last string - add it here.
    if nargin == 2 && ii ~= nStr
      switch varargin{2} 
        case { '\n' '\r', '<br>' }               % line break
          output = strcat ( output, '<br>' );    
        case ' '                                 % space
          output = strcat ( output, '&nbsp;' );
        otherwise                                % any other
          output = strcat ( output, varargin{2} );
      end
    end
  end
end