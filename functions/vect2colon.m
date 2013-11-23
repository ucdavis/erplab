% Usage: strvec = vect2colon(vec, options)
%
% Converts a vector into a string using MATLAB colon notation (single resolution).
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
% MATLAB colon notation is a compact way to refer to ranges of matrix elements.
% It is often used in copy operations and in the creation of vectors and matrices.
% Colon notation can be used to create a vector as follows
%                           x = xbegin:dx:xend
%                                   or
%                          x2 = xbegin:xend
% where xbegin and xend are the range of values covered by elements of the x
% vector, and dx is the (optional) increment. If dx is omitted a value of 1
% (unit increment) is used. The numbers xbegin, dx, and xend need not be
% integers.
%
% Example 1:
% >> x = [  50 1000 1100 1200 2 3 4 5 6 10 20 30 40]
% >> vect2colon(x)
%
% ans =
%
% [ 50 1000:100:1200 2:6 10:10:40]
%
% or
%
% >> vect2colon(x, 'Sort', 'on')
%
% ans =
%
% [ 2:6 10:10:50 1000:100:1200]
%
% Example 2:
% >> x = [ 2 3 4 5 6 10 10.1 10.2 10.3 10.4 1000 1100 1200]
% >> s = vect2colon(x)
%
% s =
%
% [ 2:6 10:0.1:10.4 1000:100:1200 ]
%
% Example 3:
% >> x = [ 2 3 4 5 6 10 1000 1100 1200 10.1 10.2 10.3 10.4]
% >> s = vect2colon(x, 'Delimiter', 'no')
%
% s =
%
%  2:6 10 1000:100:1200 10.1:0.1:10.4
%
% See also:  mat2colon, eval, str2num
%
% Author: Javier Lopez-Calderon
% 2008-2011
%
% Feedback is appreciated.
% fixed bug where the increment is negative
% Checks numeric input
% Allows to keep repeated values

function strvec = vect2colon(vec, varargin)

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('vec', @isnumeric);
p.addParamValue('Delimiter', 'auto', @ischar);
p.addParamValue('Sort', 'off', @ischar);
p.addParamValue('Precision', 'single');
p.addParamValue('Repeat', 'on', @ischar);
p.parse(vec, varargin{:});
strvec   = '';
if nargin<1
        help vect2colon
        return
end
if isempty(vec)
        if ismember_bc2({lower(p.Results.Delimiter)},{'yes','on','auto'})
                strvec = '[]';
        end
        return
end
[dime] = size(vec); % input size
if length(dime)>2
        error('Error: vect2colon only works for row or column vector. Use mat2colon instead.')
else
        if dime(1)>1 && dime(2)==1 % feb 2011
                apo = '''';
        elseif dime(1)==1 && dime(2)>=1
                apo = '';
        else
                error('Error: vect2colon only works for row or column vector. Use mat2colon instead.')
        end
end
if ismember_bc2({lower(p.Results.Sort)},{'yes','on'})
        if strcmpi(p.Results.Repeat,'off')
                vecuni = unique_bc2(vec);    % repeated numbers are not allowed. sorted
        else
                vecuni = sort(vec);           % repeated numbers are allowed. sorted  --> previous bug
        end
else
        if ismember_bc2({lower(p.Results.Repeat)}, {'off','no'})
                [v, a, b] = unique_bc2(vec', 'first');
                ia = sort(a);
                vecuni = vec(ia); % repeated numbers are not allowed. no sorted
        else
                vecuni = vec; % repeated numbers are allowed. no sorted  --> previous bug
        end
end
precision = p.Results.Precision;
if ischar(precision)
        precnum = str2num(precision);
        if isempty(precnum)
                if strcmpi(precision,'single')
                        dvec = single(diff(vecuni));
                else
                        dvec = double(diff(vecuni));
                end
        else
                dvec = (round(diff(vecuni)*10^precnum))/10^precnum;
        end
        
else
        dvec = (round(diff(vecuni)*10^precision))/10^precision;
end
% basepnts = find(diff(dvec));
holdc    = 0;
iexpress = 0;
k = 1;
while k <= numel(vecuni)
        if k>1 && k <= numel(vecuni) - 1
                if dvec(k) ~=0 && dvec(k) == dvec(k-1) && ~holdc
                        holdc = 1;
                        iexpress = iexpress + 1; % group counter
                        if dvec(k) ~= 1  % march 2011
                                if abs(abs(dvec(k))-pi)<1e-6
                                        if dvec(k)<0
                                                dvstr = '-pi';
                                        else
                                                dvstr = 'pi';
                                        end
                                else
                                        dvstr = sprintf('%g', dvec(k));
                                end
                                %strvec = [ strvec ':' dvstr ':' ];     % starts a group with step>1
                                strvec = sprintf('%s:%s:',strvec, dvstr); %   [ strvec ':' dvstr ':' ];
                        else
                                %strvec = [ strvec ':' ];               % starts a group with step=1
                                strvec = sprintf('%s:',strvec);
                        end
                elseif (dvec(k) ~= dvec(k-1) || (dvec(k)==0 && dvec(k) == dvec(k-1))) && ~holdc
                        strvec = sprintf('%s %g', strvec, vecuni(k));
                        %strvec   = [ strvec ' ' num2str(vecuni(k)) ];   % discret element
                        iexpress = iexpress + 1;
                elseif dvec(k) ~= dvec(k-1) && holdc
                        strvec = sprintf('%s%g', strvec, vecuni(k));
                        %strvec = [ strvec num2str(vecuni(k)) ];       % ends a group with step=1
                        iexpress = iexpress + 1;
                        holdc    = 0;
                        dvec(k)  = 0; % since repeated numbers are not allowed...
                end
        else
                if holdc
                        %strvec = [ strvec num2str(vecuni(k)) ];      % last element
                        strvec = sprintf('%s%g', strvec, vecuni(k));
                else
                        strvec = sprintf('%s %g', strvec, vecuni(k));
                        %strvec = [ strvec ' ' num2str(vecuni(k)) ];  % first(last) element (discrete)
                        iexpress = iexpress + 1;
                end
        end
        k = k + 1;
end
% strvec = strtrim(strvec);
if ismember_bc2({lower(p.Results.Delimiter)},{'yes','on'})
        %strvec = [ '[' strvec ']' apo];
        strvec = sprintf('[%s]%s',strvec,apo);
        return
end
if ((iexpress-1)>1 || ((iexpress-1)==1 && numel(vecuni)==2))...
                && (strcmp(p.Results.Delimiter,'auto'))
        %strvec = [ '[' strvec ']' apo];
        strvec = sprintf('[%s]%s',strvec,apo);
end
return