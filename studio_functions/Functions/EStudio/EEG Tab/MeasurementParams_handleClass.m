classdef MeasurementParams_handleClass < handle
    properties
        %measurement parameters
        mType = 'meanabl'; % type of measurement -> instabl, meanbl, peakampbl, peaklatbl, area, areaz,
        mIntFactor = 1; % interpolation factor -> int 1-10
        mPrecision = 3; % number of decimals in measure -> int 1-6
        mPeakPol ;% local peak polarity -> "positive" or "negative"
        mPeakSamples ; %
        mReplace ; % if no peak or area, replace -> 'abs' or 'NaN'
        % will add more meaure options as needed...

        % other measurement options
        sets = []; % indeces

        eventCodes = 'ANY'; % 'ANY' or an array of codes

        binNums = 'ANY'; % 'ANY' or an array of bin numbers

        channels = 'all'; % 'all' or an array of channel numbers

        windows = []; % a single range (e.g. [100 200]) or a list of ranges (e.g. [[100 200] [200 300]])

        points = []; % a single point (e.g. 100) or a range of points (e.g. 100:4:200)

        baseline = 'pre'; % 'pre' 'post' 'full' or a custom range (e.g. [-100 0]), custom required for non-epoched data

        %output options
        oPath = cd; % directory as string
        oFilename = 'item_measures' %placeholder

        oFile_type = 'csv'; % or 'tsv' 'xls' 'mat'
        oChannels_asWide = false; %output channels as separate columns (wide format)
        oTimes_asWide = false; %output times as separate columns (wide format)

        oSet_labels = true; %output EEGset name labels as column
        oBin_labels = true; %output bin labels as column
        oChannel_labels = true; %output channel labels as column

        oChannelLocs = true; %output channel locations as column [X,Y,Z]
        oEventInstance_perSet = false; %output the instance number of that event number per eegset 
        oEventInstance_perSet_perEventcode = false; %output the instance number of that event number per eegset per event code
        oEventOnsetTime = false; %output the onset time for event in eegset (ms)
        oEventBins = false; %output the bin numbers that event is in e.g. "[1,3,4]"
        oBinRT = false; %output the bin RT for that event (if present)
        oFlags_user = false; %output user flags for event

        oReject_artifacts = true; % False = export all trials, ignore artifacts
        oFlags_artifacts = false; %output artifact flags for event


    end

    methods
        
        % Save current parameters to a .mat file
        function saveToFile(obj, filename)
            % Save only the properties of the object
            paramsStruct = struct();
            meta = metaclass(obj);
            for k = 1:length(meta.PropertyList)
                prop = meta.PropertyList(k);
                if ~prop.Dependent && prop.SetAccess == "public"
                    paramsStruct.(prop.Name) = obj.(prop.Name);
                end
            end
            save(filename, '-struct', 'paramsStruct');
        end

        % Load parameters from a .mat file into this object
        function loadFromFile(obj, filename)
            loadedParams = load(filename);
            fields = fieldnames(loadedParams);
            for i = 1:numel(fields)
                if isprop(obj, fields{i})
                    obj.(fields{i}) = loadedParams.(fields{i});
                end
            end
        end
    end

end