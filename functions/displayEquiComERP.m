function displayEquiComERP(xcom, nline2end)
if nargin<2
        nline2end = 140; % max line length
        nd = nline2end;        % number of dashed lines
end
fprintf([repmat('-', 1,nd) '\n']);
try
        cprintf([0.1333    0.5451    0.1333], '%%Equivalent command:\n');
catch
        fprintf('%%Equivalent command:\n');
end
if length(xcom)<nline2end
        fprintf('%s\n', xcom);
else
        zcom     = regexprep(xcom, '''(.*?)''', '${repmat(''X'',1,(length($1)+2))}'); % masks strings to avoid comma detection inside of them.
        indxcomx = strfind(zcom, ',');
        %indxcomx = indxcomx(indxcomx>nline2end)
        if isempty(indxcomx)
                fprintf('%s\n', xcom); % as it is...
        else
                N    = round((length(xcom)/nline2end));
                Npos = nline2end:nline2end:N*nline2end;
                Apos = unique_bc2(closest(indxcomx,Npos));
                if length(Apos)>1 && (length(xcom)-Apos(end-1))<=nline2end
                        Apos = Apos(1:end-1);
                elseif length(Apos)==1 && (length(xcom)-Apos)< 0.1*length(xcom)
                        fprintf('%s\n', xcom); % as it is...
                        fprintf([repmat('-', 1,nd) '\n']);
                        return
                end
                for kk=1:length(xcom)
                        if ~ismember_bc2(kk, Apos)
                                fprintf('%s', xcom(kk));
                        elseif ismember_bc2(kk, Apos) && kk<length(xcom)
                                fprintf(',...\n');
                        else
                                fprintf('\n');
                        end
                end
                if Apos(end)~=length(xcom)
                        fprintf('\n');
                end
        end
end
fprintf([repmat('-', 1,nd) '\n']);
disp('<a href="matlab:hheegh = findobj(0, ''tag'', ''EEGLAB''); figure(hheegh)">Go back to ERPLAB menu</a>');
fprintf('\n');