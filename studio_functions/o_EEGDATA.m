classdef o_EEGDATA < handle
    
    properties
        ALLEEG
        EEG
        CURRENTSET
        count_current_eeg
        eeg_panel_message
        eeg_two_panels
        Reset_eeg_paras_panel
    end
    
    
    events
        alleeg_change
        eeg_change
        current_change
        count_current_eeg_change
        eeg_panel_change_message
        eeg_two_panels_change
        Reset_eeg_panel_change
    end
    
    
    methods
        %%alleeg
        function set.ALLEEG(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.ALLEEG = values_eeg;
                notify(obj_eeg,'alleeg_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%eeg
        function set.EEG(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.EEG = values_eeg;
                notify(obj_eeg,'eeg_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%current eeg
        function set.CURRENTSET(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.CURRENTSET = values_eeg;
                notify(obj_eeg,'current_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%count current eeg change
        function set.count_current_eeg(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.count_current_eeg = values_eeg;
                notify(obj_eeg,'count_current_eeg_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%message
        function set.eeg_panel_message(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.eeg_panel_message = values_eeg;
                notify(obj_eeg,'eeg_panel_change_message');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%two panels
        function set.eeg_two_panels(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.eeg_two_panels = values_eeg;
                notify(obj_eeg,'eeg_two_panels_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
        
        %%reset for the default parameters
        function set.Reset_eeg_paras_panel(obj_eeg,values_eeg)
            ws = warning('off','all');
            try
                obj_eeg.Reset_eeg_paras_panel = values_eeg;
                notify(obj_eeg,'Reset_eeg_panel_change');
            catch
            end
            % restore previous warning state
            warning(ws);
        end
    end
    
end