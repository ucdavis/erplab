%
% Author: Javier Lopez-Calderon & Stanley Huang
%

function changecd(pathname)

cdir = regexprep(cd,'/|\','');
ndir = regexprep(pathname,'/|\','');

if ~strcmp(cdir, ndir)
        question = ['Would you like to change your current directory to:\n\n'...
                    pathname];
        tittle      = 'ERPLAB: Change Current Directory';
        button      = askquest(sprintf(question), tittle);

        if strcmpi(button,'Yes')
                cdaux = cd;
                cd(pathname)
                fprintf('\nNOTE: Current directory was change from %s  to  %s\n\n', cdaux, pathname);
        end
end