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
        Two_GUI
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
        Two_GUI_change
    end
    
    
    methods
        function set.ALLERP(obj,value)
            obj.ALLERP = value;
            notify(obj,'erpschange');
        end
        function set.ERP(obj,value)
            obj.ERP = value;
            notify(obj,'drawui_CB');
        end
        %%Modified CurrentERP
        function set.CURRENTERP(obj,value)
            obj.CURRENTERP = value;
            notify(obj,'cerpchange');
        end
        %%ERP Plotting panel
        function set.Count_ERP(obj,value)
            obj.Count_ERP = value;
            notify(obj,'Count_ERP_change');
        end
        %Modified channels of the selected ERP
        function set.ERP_chan(obj,value)
            obj.ERP_chan = value;
            notify(obj,'ERP_chan_change');
        end
        %Modified bins of the selected ERP
        function set.ERP_bin(obj,value)
            obj.ERP_bin = value;
            notify(obj,'ERP_bin_change');
        end
        
        %Modified bins of the selected ERP
        function set.Count_currentERP(obj,value)
            obj.Count_currentERP = value;
            notify(obj,'Count_currentERP_change');
        end
        
        
        %Modified bins of the selected ERP
        function set.Process_messg(obj,value)
            obj.Process_messg = value;
            notify(obj,'Messg_change');
        end
        
         %capture the change from main EStudio
        function set.Two_GUI(obj,value)
            obj.Two_GUI = value;
            notify(obj,'Two_GUI_change');
        end
        
        
    end
end