% mvpch - history function for MVPCsets.

%Author: Guanghui ZHANG
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%2024



function str = mvpch( command);
str = '';
if nargin<1
    help mvpch
    return
end

if isempty( command )
    return;
end
try ALLMVPCCOM = evalin('base','ALLMVPCCOM');catch ALLMVPCCOM = []; end


if ischar( command ) || ( exist('isstring', 'builtin') && isstring( command ) )
    command = char(command);
    if ~isempty(ALLMVPCCOM) && isequal(ALLMVPCCOM{1}, command), return; end
    if isempty(ALLMVPCCOM)
        ALLMVPCCOM = { command };
    else
        ALLMVPCCOM = { command ALLMVPCCOM{:}};
    end
    LASTCOM  = command;
else
    if command == 0
        ALLMVPCCOM = [];
    else if command < 0
            ALLMVPCCOM = ALLMVPCCOM( -command+1:end ); % unstack elements
        else
            txt = ALLMVPCCOM{command};
            if length(txt) > 72
                fprintf('%s...\n', txt(1:70) );
            else
                fprintf('%s\n', txt );
            end
            %             evalin( 'base', ALLMVPCCOM{command} ); % execute element
            %             eegh( ALLMVPCCOM{command} );    % add to history
        end
    end
end
assignin('base','ALLMVPCCOM',ALLMVPCCOM);
assignin('base','MVPCCOM',command);
if nargout > 0
    str = strvcat(ALLMVPCCOM);
end
end