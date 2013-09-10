function C = textscanu(filename, encoding, del_sym, eol_sym, wb)

% C = textscanu(filename, encoding) reads Unicode 
% strings from a file and outputs a cell array of strings. 
% 
% Syntax:
% -------
% filename - string with the file's name and extension
%                 example: 'unicode.txt'
% encoding - encoding of the file
%                 default: UTF-16LE
%                 examples: UTF16-LE (little Endian), UTF8.
%                 See http://www.iana.org/assignments/character-sets
%                 MS Notepad saves in UTF-16LE ('Unicode'), 
%                 UTF-16BE ('Unicode big endian'), UTF-8 and ANSI.
% del_sym - column delimitator symbol in ASCII numeric code
%                 default: 9 (tabulator)
% eol_sym - end of line delimitator symbol in ASCII numeric code
%                 default: 13 (carriage return) [Note: line feed=10]
% wb          - displays a waitbar if wb = 'waitbar'
% 
% Example:
% -------
% C = textscanu('unicode.txt', 'UTF8', 9, 13);
% Reads the UTF8 encoded file 'unicode.txt', which has
% columns and lines delimited by tabulators, respectively 
% carriage returns. Shows a waitbar to make the progress 
% of the functions action visible.
%
% Note:
% -------
% Matlab's textscan function doesn't seem to handle 
% properly multiscript Unicode files. Characters 
% outside the ASCII range are given the \u001a or 
% ASCII 26 value, which usually renders on the 
% screen as a box.
% 
% Additional information at "Loren on the Art of Matlab":
% http://blogs.mathworks.com/loren/2006/09/20/
% working-with-low-level-file-io-and-encodings/#comment-26764
% 
% Bug:
% -------
% When inspecting the output with the Array Editor, 
% in the Workspace or through the Command Window,
% boxes might appear instead of Unicode characters.
% Type C{1,1} at the prompt: you will see the correct
% string. Also: in Array Editor click on C then C{1,1}.
% 
% Matlab version: starting with R2006b
%
% Revisions:
% -------
% 2009.06.13 - added option to display a waitbar
% 2008.02.27 - function creation
% 
% Created by: Vlad Atanasiu / atanasiu@alum.mit.edu
% Copyright (c) 2009, Vlad Atanasiu
% All rights reserved.

switch nargin
    case 5
        if strcmp(wb, 'waitbar') == 1;
            h = waitbar(0,''); % display waitbar
        end
    case 4
        h = 0;
    case 3
        h = 0;
        eol_sym = 13;
    case 2
        h = 0;
        eol_sym = 13;   % end of line symbol (CR=13, LF=10)
        del_sym = 9;    % column delimitator symbol (TAB=9)
    case 1
        h = 0;
        eol_sym = 13;
        del_sym = 9;
        encoding = 'UTF16-LE';
end
warning off MATLAB:iofun:UnsupportedEncoding;

% read input
fid = fopen(filename, 'r', 'l', encoding);
S = fscanf(fid, '%c');
fclose(fid);

% remove Byte Order Marker and add an 
% end of line mark at the end of the file
S = [S(2:end) char(eol_sym)]; 

% locates column delimitators and end of lines
del = find(abs(S) == del_sym); 
eol = find(abs(S) == eol_sym);

% get number of rows and columns in input
row = numel(eol);
col = 1 + numel(del) / row;
C = cell(row,col); % output cell array

% catch errors in file
if col - fix(col) ~= 0
    error(['Error: The file has an odd number of columns ',...
        'or line ends are malformed.'])
end

m = 1;
n = 1;
sos = 1;

% parse input
if col == 1
    % single column input
    for r = 1:row
        if h ~= 0
            waitbar( r/row, h, [num2str(r), '/', num2str(row)] )
        end
        eos = eol(n) - 1;
        C(r,col) = {S(sos:eos)};
        n = n + 1;
        sos = eos + 3;
    end
else
    % multiple column input
    for r = 1:row
        if h ~= 0
            waitbar( r/row, h, [num2str(r), '/', num2str(row)] )
        end
        for c = 1:col-1
            eos = del(m) - 1;
            C(r,c) = {S(sos:eos)};
            sos = eos + 2;
            m = m + 1;
        end
        % last string in the row
        sos = eos + 2;
        eos = eol(n) - 1;
        C(r,col) = {S(sos:eos)};
        n = n + 1;
        sos = eos + 3;
    end
end
close(h)
