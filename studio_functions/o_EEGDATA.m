classdef o_EEGDATA < handle
    
    properties
        ALLEEG
        EEG
        CURRENTSET
        count_current_eeg
        eeg_message_panel
        eeg_two_panels
        eeg_reset_def_paras
    end
    
    
    events
        alleeg_change
        eeg_change
        current_change
        count_current_eeg_change
        eeg_message_panel_change
        eeg_two_panels_change
        eeg_reset_def_paras_change
    end
    
    
    methods
        %%alleeg
        function set.ALLEEG(obj,values)
            obj.ALLEEG = values;
            notify(obj,'alleeg_change');
        end
        
        %%eeg
        function set.EEG(obj,values)
            obj.EEG = values;
            notify(obj,'eeg_change');
        end
        
        %%current eeg
        function set.CURRENTSET(obj,values)
            obj.CURRENTSET = values;
            notify(obj,'current_change');
        end
        
        %%count current eeg change
        function set.count_current_eeg(obj,values)
            obj.count_current_eeg = values;
            notify(obj,'count_current_eeg_change');
        end
        
        
        %%message
        function set.eeg_message_panel(obj,values)
            obj.eeg_message_panel = values;
            notify(obj,'eeg_message_panel_change');
        end
        
        %%two panels
        function set.eeg_two_panels(obj,values)
            obj.eeg_two_panels = values;
            notify(obj,'eeg_two_panels_change');
        end
        
        
        %%reset for the default parameters
        function set.eeg_reset_def_paras(obj,values)
            obj.eeg_reset_def_paras = values;
            notify(obj,'eeg_reset_def_paras_change');
        end
    end
    
end