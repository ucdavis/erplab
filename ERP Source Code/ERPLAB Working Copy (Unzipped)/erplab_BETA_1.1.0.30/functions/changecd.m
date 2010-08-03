%
% Author: Javier Lopez-Calderon & Stanley Huang
%

function changecd(pathname)

cdir = regexprep(cd,'/|\','');
ndir = regexprep(pathname,'/|\','');

if ~strcmp(cdir, ndir)
        question{1} = 'Would you like to change your current directory to:';
        question{2} = '';
        question{3} = pathname;
        tittle      = 'ERPLAB: Change Current Directory';
        button      = askquest(question, tittle);

        if strcmpi(button,'Yes')
                cdaux = cd;
                cd(pathname)
                fprintf('\nNOTE: Current directory was change from %s  to  %s\n\n', cdaux, pathname);
        end
end