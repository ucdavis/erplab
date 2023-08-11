classdef o_EEGDAT < handle
    properties
        ALLEEG
        EEG
        CURRENTSET
        Count_EEG
        EEG_chan
        EEG_IC
        Count_currentEEG
        Process_messg_EEG
    end
    
    
    events
        ALLEEG_change
        EEG_change
        ceegchange
        Count_EEG_change
        EEG_chan_change
        EEG_IC_change
        Count_currentEEG_change
        Messg_EEG_change
    end
    
    
    methods
        function set.ALLEEG(obj,value)
            obj.ALLEEG = value;
            notify(obj,'ALLEEG_change');
        end
        function set.EEG(obj,value)
            obj.EEG = value;
            notify(obj,'EEG_change');
        end
        %%Modified CurrentERP
        function set.CURRENTSET(obj,value)
            obj.CURRENTSET = value;
            notify(obj,'ceegchange');
        end
        %%ERP Plotting panel
        function set.Count_EEG(obj,value)
            obj.Count_EEG = value;
            notify(obj,'Count_EEG_change');
        end
        %Modified channels of the selected ERP
        function set.EEG_chan(obj,value)
            obj.EEG_chan = value;
            notify(obj,'EEG_chan_change');
        end
        %Modified ICs of the selected ERP
        function set.EEG_IC(obj,value)
            obj.EEG_IC = value;
            notify(obj,'EEG_IC_change');
        end
        
        %Modified bins of the selected ERP
        function set.Count_currentEEG(obj,value)
            obj.Count_currentEEG = value;
            notify(obj,'Count_currentEEG_change');
        end
        
        
        %Modified bins of the selected ERP
        function set.Process_messg_EEG(obj,value)
            obj.Process_messg_EEG = value;
            notify(obj,'Messg_EEG_change');
        end
        
    end
end