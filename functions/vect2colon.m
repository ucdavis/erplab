% Usage: strvec = vect2colon(vec, options)
%
% Converts a vector into a string with its MATLAB colon notation (single resolution).
%
% Options are:
%
% 'Delimiter'   -   'yes'\'on'/'no'/'auto'   Including or not square brackets []
%                                            'auto' by default.
% 'Sort'        -   'yes'\'on'/'no'          yes: Sort elements in ascending order
%                                            no : display as it is ( but repeated elements )
%                                           'no' by default
% 'Class'       -   MATLAB classes
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
% See also:  eval, str2num
%
% Author: Javier Lopez-Calderon
% 2008
%
% Feedbacks are appreciated.

function strvec = vect2colon(vec, varargin)

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('vec', @isnumeric);
p.addParamValue('Delimiter', 'auto', @ischar);
p.addParamValue('Sort', 'no', @ischar);
p.addParamValue('Class', 'single', @ischar);
p.addParamValue('Repeat', 'off', @ischar);
p.parse(vec, varargin{:});

strvec   = '';

if nargin<1
        help vect2colon
        return
end
if isempty(vec)
        if strcmp(p.Results.Delimiter,'yes') || strcmp(p.Results.Delimiter,'on')
                strvec = '[]';
        end
        return
end

[dime] = size(vec);

if length(dime)>2
        error('Error: vect2colon only works for row or column vector')
else
        if dime(1)>=1 && dime(2)==1
                apo = '''';
        elseif dime(1)==1 && dime(2)>=1
                apo = '';
        else
                error('Error: vect2colon only works for row or column vector')
        end
end
if strcmpi(p.Results.Sort,'yes') || strcmpi(p.Results.Sort,'on')

        if strcmpi(p.Results.Repeat,'off')
                vecuni      = unique(vec);    % repeated numbers are not allowed...sorted
        else
                vecuni      = vec;            % repeated numbers are allowed
        end
else
        if strcmpi(p.Results.Repeat,'off')
                [v a b] = unique(vec', 'first');
                ia = sort(a);
                vecuni = vec(ia); % repeated numbers are not allowed...original sorting
        else
                vecuni = sort(vec);
        end
end

dvec     = single(diff(vecuni));
holdc    = 0;
iexpress = 0;
k = 1;

while k <= numel(vecuni)
        if k>1 && k <= numel(vecuni) - 1
                if dvec(k) ~=0 && dvec(k) == dvec(k-1) && ~holdc
                        holdc = 1;
                        iexpress = iexpress + 1; % group counter
                        if abs(dvec(k)) ~= 1
                                if dvec(k)==pi
                                        dvstr = 'pi'; % luxe
                                else
                                        dvstr = num2str(dvec(k));
                                end
                                strvec = [ strvec ':' dvstr ':' ];     % starts a group with step>1
                        else
                                strvec = [ strvec ':' ];               % starts a group with step=1
                        end                        
                elseif (dvec(k) ~= dvec(k-1) || (dvec(k)==0 && dvec(k) == dvec(k-1))) && ~holdc
                        strvec   = [ strvec ' ' num2str(vecuni(k)) ];   % discret element
                        iexpress = iexpress + 1;
                elseif dvec(k) ~= dvec(k-1) && holdc
                        strvec = [ strvec num2str(vecuni(k)) ];       % ends a group with step=1
                        iexpress = iexpress + 1;
                        holdc    = 0;
                        dvec(k)  = 0; % since repeated numbers are not allowed...
                end
        else
                if holdc
                        strvec = [ strvec num2str(vecuni(k)) ];      % last element
                else
                        strvec = [ strvec ' ' num2str(vecuni(k)) ];  % first(last) element (discrete)
                        iexpress = iexpress + 1;
                end
        end
        k = k + 1;
end

if strcmp(p.Results.Delimiter,'yes') || strcmp(p.Results.Delimiter,'on')
        strvec = [ '[' strvec ']' apo];
        return
end
if ((iexpress-1)>1 || ((iexpress-1)==1 && numel(vecuni)==2))...
                && (strcmp(p.Results.Delimiter,'auto'))
        strvec = [ '[' strvec ']' apo];
end
return