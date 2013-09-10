% PURPOSE: writes the string WARNING in red at the command window
%
% FORMAT:
%
% callwarning(option)
%
% option        - 1 or 2 strings. When 1 string is specified it will be located before the word WARNING.
%                 When 2 strings are specified, the first one will be located before the word WARNING,
%                 and the second one, after the word WARNING.
%
% OUTPUT:
%
% WARNING message at command window
%
%
% EXAMPLES: 
%
% >>callwarning
%  WARNING: >>
%  
% >>callwarning('hey')
%  WARNING:hey>>
%  
% >>callwarning('stop ','\n')
%  stop WARNING:
% >>
%
% See also cprintf.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function callwarning(varargin)

if nargin<1
        post = '';
        pre  = '';
elseif nargin==1
        post = varargin{1};
        pre = '';
elseif nargin==2
        post = varargin{2};
        pre = varargin{1};
else
        error('callwarning only deals up two inputs')
end
colorw = [0.8 0 0];
try cprintf(colorw, [pre 'WARNING:' post]);catch,fprintf([pre 'WARNING:' post]);end ;


