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
function button = askquestpoly(question, tittle, buttonscell)

button = '';
if iscell(question)
        disp(question{1})
else
        disp(question)
end
TXCOLOR = [1 0.9 0.3];
oldcolor = get(0,'DefaultUicontrolBackgroundColor');
set(0,'DefaultUicontrolBackgroundColor', TXCOLOR)
if ~iscell(buttonscell)
        error('ERPLAB says:  error at askquestpoly(). Buttons name must be entered as cellstrings')
end
nbuttons = length(buttonscell);
if nbuttons>3
        error('ERPLAB says:  askquestpoly() only works until 3 buttons. Sorry')
end
if nbuttons==0
        error('ERPLAB says:  error at askquestpoly(). You must enter 1 button name at least!')
end
comcall = 'button = questdlg(question, tittle';
for i=1:nbuttons
        comcall = [comcall ', ''' buttonscell{i} '''' ];
end
comcall = [comcall ',''' buttonscell{1} ''');'];
eval(comcall)
set(0,'DefaultUicontrolBackgroundColor',oldcolor)
