classdef o_EEGDATA < handle
    
    properties
        ALLEEG
        EEG
        CURRENTSET
        count_current_eeg
        eeg_panel_message
        eeg_two_panels
        eeg_reset_def_paras
    end
    
    
    events
        alleeg_change
        eeg_change
        current_change
        count_current_eeg_change
        eeg_panel_change_message
        eeg_two_panels_change
        eeg_reset_def_paras_change
    end
    
    
    methods
        %%alleeg
        function set.ALLEEG(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.ALLEEG = values_eeg;
                notify(obj_eeg,'alleeg_change');
            catch
                warning('on');
            end
        end
        
        %%eeg
        function set.EEG(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.EEG = values_eeg;
                notify(obj_eeg,'eeg_change');
            catch
                warning('on');
            end
        end
        
        %%current eeg
        function set.CURRENTSET(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.CURRENTSET = values_eeg;
                notify(obj_eeg,'current_change');
            catch
                warning('on');
            end
        end
        
        %%count current eeg change
        
        function set.count_current_eeg(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.count_current_eeg = values_eeg;
                notify(obj_eeg,'count_current_eeg_change');
            catch
            end
            warning('on');
        end
        
        
        
        %%message
        function set.eeg_panel_message(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.eeg_panel_message = values_eeg;
                notify(obj_eeg,'eeg_panel_change_message');
            catch
                 warning('on');
            end
           
        end
        
        %%two panels
        function set.eeg_two_panels(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.eeg_two_panels = values_eeg;
                notify(obj_eeg,'eeg_two_panels_change');
            catch
                warning('on');
            end
        end
        
        
        %%reset for the default parameters
        function set.eeg_reset_def_paras(obj_eeg,values_eeg)
            try
                warning('off');
                obj_eeg.eeg_reset_def_paras = values_eeg;
                notify(obj_eeg,'eeg_reset_def_paras_change');
            catch
                warning('on');
            end
        end
    end
    
end