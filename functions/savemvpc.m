function [MVPC, filenamex, serror] = savemvpc(MVPC,filenamex,modegui,warnop)

serror  = 0; 

if nargin < 1
    help savemvpc
    return
    
end

if nargin<4
        warnop = 1 ; % no warning for overwriting a file
end
if nargin<3
        modegui = 0; % no uiputfile
end


% Save MVPA file (save as)
MVPCaux = MVPC;
namef = filenamex; 

if modegui == 1 
    [pathstr, namedef, ext] = fileparts(char(namef));
    [mvpcfilename, mvpcpathname, indxs] = uiputfile({'*.mvpc','MVPC (*.mvpc)'}, ...
        'Save MVPC structure as',...
        namedef);
    
    if isequal(mvpcfilename,0)
        disp('User selected Cancel')
        serror = 1;
        return
    end
    
    [pathstr, mvpcfilename, ext] = fileparts(mvpcfilename) ;
    
    if indxs==1
        ext = '.mvpc';
    elseif indxs==2
        ext = '.mvpc';
    end
else %direct saving
    if isempty(filenamex)
        disp('User selected Cancel')
        serror =1;
        return
    end
    [mvpcpathname, mvpcfilename, ext] = fileparts(filenamex);
    ext = '.mvpc'; 
    
end
try
disp(['Saving Multivariate Pattern Classification (MVPC) Data Matrix (.mvpc) at ' mvpcpathname{1} '...'] )
catch
disp(['Saving Multivariate Pattern Classification (MVPC) Data Matrix (.mvpc) at ' mvpcpathname '...'] )
end
    
if isequal(mvpcfilename,0)
    disp('User selected Cancel')
    serror=1;
    return
else
    %         if isempty(ERP.erpname)
    %                 ERP.erpname = erpfilename; % without extension
    %         end
    if numel(MVPC) == 1
        MVPC.filename = [mvpcfilename ext];
        MVPC.filepath = mvpcpathname;
        MVPC.saved ='yes';

    else
        for f = 1:length(MVPC)
            MVPC(f).filename = [mvpcfilename{f} ext];
            MVPC(f).filepath = mvpcpathname{f};
            MVPC(f).saved ='yes';
        end
    end
end
        
%         %checking = checkERP(ERP);
%         
%         if checking==0
%               msgboxText =  'Error: ERP structure has error.';
%               tittle = 'ERPLAB: pop_saveERP() error:';
%               errorfound(msgboxText, tittle);
%               serror = 1;
%               ERP = ERPaux;
%               return
%         end
%% SAVING
storeMVPC = MVPC; 
for f = 1:length(storeMVPC)
    MVPC = storeMVPC(f);
    try
        filenamex = fullfile(mvpcpathname{f}, [mvpcfilename{f} ext]);
    catch
        filenamex = fullfile(mvpcpathname, [mvpcfilename ext]);
    end
    if exist(filenamex, 'file')~=0 && warnop==1
        msgboxText =  ['This MVPC Data already exist.\n'...;
            'Would you like to overwrite it?'];
        title  = 'ERPLAB: WARNING!';
        button = askquest(sprintf(msgboxText), title);
        if strcmpi(button,'no')
            disp('User canceled')
            MVPC = MVPCaux;
            return
        end
    end
    save(filenamex, 'MVPC');
end

MVPC = storeMVPC; %reset the output to be the full set of multipe MVPC (if applicable)

return
