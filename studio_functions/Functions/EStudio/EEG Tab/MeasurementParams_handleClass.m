classdef MeasurementParams_handleClass < handle
    properties
        type = 'meanabl';
        type_p1 = [];

        sets = []; % indeces

        eventCodes = 'ANY'; %

        binNums = 'ANY'; % 

        channels = 'all'; %

        windows = []; %

        points = []; %

        baseline = 'pre';

        output_path = cd;
    end

    methods
        % methods?
    end

end