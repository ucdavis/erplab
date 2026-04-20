%%This function is used to check whether the fileds of MVPC are the same
%%across MVPCsets

% *** This function is part of ERPLAB Toolbox ***
% Author: Guanghui Zhang
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2025 Sep


function MVPC = f_checkmvpc_str(MVPC)

if nargin <1 || isempty(MVPC)
    help f_checkmvpc
    return
end
%%ADD one more parameter "AvgPerClass" since version 2 of MVPC
if length(MVPC)==1
    if MVPC.mvpc_version==1%% GH Sep. 2025
        MVPC.AvgPerClass = [];
        MVPC.TGM  = [];
        if  MVPC.chance >0
            MVPC.AvgPerClass = MVPC.nCrossfolds*ones(1,MVPC.nClasses);
            % MVPC.regularization = [];
        end
    else
        if ~isfield(MVPC, 'TGM')
            MVPC.TGM  = [];
        end
    end
else%%multiple MVPCsets
    for ii = 1:length(MVPC)
        if MVPC(ii).mvpc_version==1%% GH Sep. 2025
            MVPC(ii).AvgPerClass = [];
            MVPC(ii).TGM  = [];
            if  MVPC(ii).chance >0
                MVPC(ii).AvgPerClass = MVPC(ii).nCrossfolds*ones(1,MVPC(ii).nClasses);
                % MVPC(ii).regularization = [];
            end
        else
            if ~isfield(MVPC(ii), 'TGM')
                MVPC(ii).TGM  = [];
            end
        end
    end

end

end