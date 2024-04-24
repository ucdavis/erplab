classdef o_ERPDAT < handle
    properties
        ALLERP
        ERP
        CURRENTERP
        Count_ERP
        ERP_chan
        ERP_bin
        Count_currentERP
        Process_messg
        two_panels_erp
        Reset_erp_paras_panel
    end
    
    
    events
        erpschange
        drawui_CB
        cerpchange
        Count_ERP_change
        ERP_chan_change
        ERP_bin_change
        Count_currentERP_change
        Messg_change
        two_panels_erp_change
        Reset_erp_panel_change
    end
    
    
    methods
        function set.ALLERP(obj,value)
            try
                warning('off');
                obj.ALLERP = value;
                notify(obj,'erpschange');
            catch
            end
            warning('on');
        end
        
        function set.ERP(obj,value)
            try
                warning('off');
                obj.ERP = value;
                notify(obj,'drawui_CB');
            catch
            end
            warning('on');
        end
        
        %%Modified CurrentERP
        function set.CURRENTERP(obj,value)
            try
                warning('off');
                obj.CURRENTERP = value;
                notify(obj,'cerpchange');
            catch
            end
            warning('on');
        end
        
        %%ERP Plotting panel
        function set.Count_ERP(obj,value)
            try
                warning('off');
                obj.Count_ERP = value;
                notify(obj,'Count_ERP_change');
            catch
            end
            warning('on');
        end
        
        %Modified channels of the selected ERP
        function set.ERP_chan(obj,value)
            try
                warning('off');
                obj.ERP_chan = value;
                notify(obj,'ERP_chan_change');
            catch
            end
            warning('on');
        end
        
        %Modified bins of the selected ERP
        function set.ERP_bin(obj,value)
            try
                warning('off');
                obj.ERP_bin = value;
                notify(obj,'ERP_bin_change');
            catch
            end
            warning('on');
        end
        
        
        %Modified bins of the selected ERP
        function set.Count_currentERP(obj,value)
            try
                warning('off');
                obj.Count_currentERP = value;
                notify(obj,'Count_currentERP_change');
            catch
            end
            warning('on');
        end
        
        
        
        %Modified bins of the selected ERP
        function set.Process_messg(obj,value)
            try
                warning('off');
                obj.Process_messg = value;
                notify(obj,'Messg_change');
            catch
            end
            warning('on');
        end
        
        
        
        %%two panels
        function set.two_panels_erp(obj_erp,values_erp)
            try
                warning('off');
                obj_erp.two_panels_erp = values_erp;
                notify(obj_erp,'two_panels_erp_change');
                warning('off');
            catch
                warning('off');
            end
        end
        
        
        
        %%two panels
        function set.Reset_erp_paras_panel(obj_erp,values_erp)
            try
                warning('off');
                obj_erp.Reset_erp_paras_panel = values_erp;
                notify(obj_erp,'Reset_erp_panel_change');
            catch
                warning('on');
            end
        end
        
        
    end
end