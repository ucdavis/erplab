classdef o_EEGDAT < handle
    properties
        ALLEEG
        EEG
        CURRENTSET
        Count_currentEEG
        EEG_messg
        eeg_twopanels
        Reset_eeg_panel
    end
    
    events
        ALLEEG_change
        EEG_change
        ceegchange
        Count_currentEEG_change
        EEG_Process_messg_change
        eeg_twopanels_change
        Reset_eeg_panel_change
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
        
        %Modified bins of the selected ERP
        function set.Count_currentEEG(obj,value)
            obj.Count_currentEEG = value;
            notify(obj,'Count_currentEEG_change');
        end
        
        %message
        function set.EEG_messg(obj,value)
            obj.EEG_messg = value;
            notify(obj,'EEG_Process_messg_change');
        end
        
        %%Two panels
        function set.eeg_twopanels(obj,value)
            obj.eeg_twopanels = value;
            notify(obj,'eeg_twopanels_change');
        end
        
        %%reset each panel (default prameters)
        function set.Reset_eeg_panel(obj,value)
            obj.Reset_eeg_panel = value;
            notify(obj,'Reset_eeg_panel_change');
        end
        
    end
end