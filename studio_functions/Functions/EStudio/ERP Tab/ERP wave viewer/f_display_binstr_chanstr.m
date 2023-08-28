% PURPOSE:  f_display_binstr_chanstr.m
%           display the names of channels and bins for the selected ERPsets

% Inputs:
%
%ALLERP           -ALLERPset
%ERPArray         -index of the selected ERPset/bin/channel(e.g., [1 4])
%diff_mark        -has two elements, 0/1; 0 represents channels/bins are
%                  the same across the selected ERPsets. 1 is differ from
%                  the selected ERPsets.


% *** This function is part of EStudio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023 July




function f_display_binstr_chanstr(ALLERP, ERPArray,diff_mark)
if nargin < 2
    help f_display_binstr_chanstr
    return;
end
if numel(ERPArray)==1
    help f_display_binstr_chanstr
    return;
end
if  min(ERPArray(:))<=0
    beep;
    disp('f_display_binstr_chanstr() error: Selected ERPsets should be positive values.')
    return;
end
if min(ERPArray(:))> length(ALLERP) ||  max(ERPArray(:))> length(ALLERP)
    beep;
    disp('f_display_binstr_chanstr() error: Selected ERPsets exceed the length of ALLERP.')
    return;
end
if isempty(diff_mark)
    diff_mark = [0 0];
end

%%------------------------display names for channel------------------------
if diff_mark(1)==1
    chanNameLength = 0;
    
    for Numoferpset = 1:length(ERPArray)
        chanNum(Numoferpset) = ALLERP(ERPArray(Numoferpset)).nchan;
        for ii = 1:ALLERP(ERPArray(Numoferpset)).nchan
            if length(char(ALLERP(ERPArray(Numoferpset)).chanlocs(ii).labels))>chanNameLength
                chanNameLength = length(char(ALLERP(ERPArray(Numoferpset)).chanlocs(ii).labels));
            end
        end
    end
    
    fprintf( ['\n',repmat('~',1,80) '\n']);
    fprintf([repmat('~',1,17),'Channel Names vary across the selected ERPsets',repmat('~',1,17) '\n'])
    fprintf( [repmat('~',1,80) '\n']);
    hdrdists = '\n';
    for  jj = 1:length(ERPArray)
        hdr{jj} = ['ERPset:',num2str(ERPArray(jj))];
        hdrdists =strcat(hdrdists,'%',num2str(chanNameLength),'s');
    end
    fprintf( [hdrdists,'\n'], hdr{:});
    
    for Numoflist = 1:max(chanNum(:))
        hdrdists = '\n';
        for  jj = 1:length(ERPArray)
            try
                hdr{jj} = char(ALLERP(ERPArray(jj)).chanlocs(Numoflist).labels);
            catch
                hdr{jj} = '';
            end
            hdrdists =strcat(hdrdists,'%',num2str(chanNameLength),'s');
        end
        fprintf( [hdrdists,'\n'], hdr{:});
    end
    fprintf( ['\n',repmat('~',1,80) '\n\n']);
end


%%-------------------display names for bin---------------------------------
if diff_mark(2)==1
    binNameLength = 0;
    for Numoferpset = 1:length(ERPArray)
        binNum(Numoferpset) = ALLERP(ERPArray(Numoferpset)).nbin;
        for ii = 1:ALLERP(ERPArray(Numoferpset)).nbin
            if length(char(ALLERP(ERPArray(Numoferpset)).bindescr{ii}))>binNameLength
                binNameLength = length(char(ALLERP(ERPArray(Numoferpset)).bindescr{ii}));
            end
        end
    end
    
    fprintf( ['\n',repmat('~',1,80) '\n']);
    fprintf([repmat('~',1,17),'Bin Names vary across the selected ERPsets',repmat('~',1,17) '\n'])
    fprintf( [repmat('~',1,80) '\n']);
    hdrdists = '\n';
    for  jj = 1:length(ERPArray)
        hdr{jj} = ['ERPset:',num2str(ERPArray(jj))];
        hdrdists =strcat(hdrdists,'%',num2str(binNameLength),'s');
    end
    fprintf( [hdrdists,'\n'], hdr{:});
    
    for Numoflist = 1:max(binNum(:))
        hdrdists = '\n';
        for  jj = 1:length(ERPArray)
            try
                hdr{jj} = char(ALLERP(ERPArray(jj)).bindescr{Numoflist});
            catch
                hdr{jj} = '';
            end
            hdrdists =strcat(hdrdists,'%',num2str(binNameLength),'s');
        end
        fprintf( [hdrdists,'\n'], hdr{:});
    end
    fprintf( ['\n',repmat('~',1,80) '\n\n']);
end
end