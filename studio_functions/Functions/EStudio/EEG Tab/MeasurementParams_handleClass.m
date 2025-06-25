classdef MeasurementParams_handleClass < handle
    properties
        mType = 'meanabl'; % type of measurement -> instabl, meanbl, peakampbl, peaklatbl, area, areaz,
        mIntFactor = 1; % interpolation factor -> int 1-10
        mPrecision = 3; % number of decimals in measure -> int 1-6
        mPeakPol ;% local peak polarity -> "positive" or "negative"
        mPeakSamples ; %
        mReplace ; % if no peak or area, replace -> 'abs' or 'NaN'
        % will add more meaure options as needed...

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