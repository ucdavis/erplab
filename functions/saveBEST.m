function [BEST, serror, filenamex] = saveBEST(BEST,filenamex,modegui,warnop)

serror  = 0; 

if nargin < 1
    help saveBEST
    return
    
end

if nargin<4
        warnop = 0 ; % no warning for overwriting a file
end
if nargin<3
        modegui = 0; % no uiputfile
end


% Save MVPA file (save as)
BESTaux = BEST;
namef = filenamex; 

if modegui == 1 
    [pathstr, namedef, ext] = fileparts(char(namef));
    [bestfilename, bestpathname, indxs] = uiputfile({'*.best','BEST (*.best)'}, ...
        'Save BEST structure as',...
        namedef);
    
    if isequal(bestfilename,0)
        disp('User selected Cancel')
        serror = 1;
        return
    end
    
    [pathstr, bestfilename, ext] = fileparts(bestfilename) ;
    
    if indxs==1
        ext = '.best';
    elseif indxs==2
        ext = '.best';
    end
else %direct saving
    if isempty(filenamex)
        disp('User selected Cancel')
        serror =1;
        return
    end
    [bestpathname, bestfilename, ext] = fileparts(filenamex);
    ext = '.best'; 
    
end

disp(['Saving Bin-Epoched Single-Trial (BEST) Data Matrix (.mat) at ' bestpathname '...'] )

    
if isequal(bestfilename,0)
        disp('User selected Cancel')
        serror=1;
        return
else        
%         if isempty(ERP.erpname)
%                 ERP.erpname = erpfilename; % without extension
%         end
        
        BEST.filename = [bestfilename ext];
        BEST.filepath = bestpathname;
        BEST.saved ='yes';
        
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
        
        filenamex = fullfile(bestpathname, [bestfilename ext]);
        
        if exist(filenamex, 'file')~=0 && warnop==1
              msgboxText =  ['This Bin-Epoched Single-Trial (BEST) Data already exist.\n'...;
                    'Would you like to overwrite it?'];
              title  = 'ERPLAB: WARNING!';
              button = askquest(sprintf(msgboxText), title);
              if strcmpi(button,'no')
                    disp('User canceled')
                    BEST = BESTaux;
                    return
              end
        end      
        save(filenamex, 'BEST');
end


return
