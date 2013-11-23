% Usage: strMat = mat2colon(Matrix, options)
%
% Converts a matrix (row x col) into a string using MATLAB colon notation (single resolution).
%
% Options are:
%
% 'Delimiter'   -   'on','yes','off','no' {default on}  :  Including square brackets [] 
%                                     (or curly brackets {} when output's dimensions are not consistent)
%                                            'auto' by default.
% 'Sort'        -   'on','yes','off','no' {default off} :  Sort elements in ascending order
%                                            
% 'Precision'   -   'double','single' {default single}
%
% 'Repeat'      -   'on','yes','off','no' {default on}  :  Keep repeated elements 
%
% Same as vect2colon but matrix capability
%
% Example 1 
% 
% mat2colon([14 12 10 8 6 4 2;  34 -23 0 1 45 46 47; 5 5 5 5 5 5 5])
% ans =
% 
% [ 14:-2:2; 34 -23 0 1 45:47; 5 5 5 5 5 5 5]
% 
% Example 2
%
% mat2colon([14 12 10 8 6 4 2;  34 -23 0 1 45 46 47; 5 5 5 5 5 5 5], 'Repeat', 'no')
% ans =
% 
% {[ 14:-2:2];[ 34 -23 0 1 45:47];[ 5]}
%
%
% See also:  vect2colon, eval, str2num
%
% Author: Javier Lopez-Calderon
% 2011
%
% Feedback is appreciated.

function strMat = mat2colon(Matrix, varargin)

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('Matrix', @isnumeric);
p.addParamValue('Delimiter', 'on', @ischar);
p.addParamValue('Sort', 'off', @ischar);
p.addParamValue('Precision', 'single', @ischar);
p.addParamValue('Repeat', 'on', @ischar);
p.parse(Matrix, varargin{:});
strMat   = '';
if nargin<1
      help mat2colon
      return
end
if isempty(Matrix)
      if strcmp(p.Results.Delimiter,'yes') || strcmp(p.Results.Delimiter,'on')
            strMat = '[]';
      end
      return
end
[dime] = size(Matrix);
if length(dime)>2
      error('Error: mat2colon only works for row or column vector and matrix')
end
sortstr = p.Results.Sort;
precstr = p.Results.Precision;
repstr  = p.Results.Repeat;
nrow    = dime(1); u=zeros(1,nrow);
for i=1:nrow
      u(i) = length(unique_bc2(Matrix(i,:)));
end
if ismember_bc2({repstr},{'off','no'})
      if length(unique_bc2(u))~=1
            deli = 'on';
            gocell = 1;
      else
            deli = 'off';
            gocell = 0;
      end
else
      deli = 'off';
      gocell = 0;
end
for i=1:nrow
      strtemp = vect2colon(Matrix(i,:), 'Delimiter', deli, 'Sort', sortstr, 'Precision', precstr, 'Repeat', repstr);
      if i==1
            strMat = strtemp;
      else
            strMat = sprintf('%s;%s', strMat, strtemp);
      end
end
if ismember_bc2({p.Results.Delimiter},{'yes','on'})
      if gocell
            strMat = [ '{' strMat '}' ];
      else
            strMat = [ '[' strMat ']' ];
      end
      return
end


