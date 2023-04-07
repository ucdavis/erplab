classdef v_ERPDAT < handle
    properties
        ALLERP
        ERP
        CURRENTERP
        Count_ERP
        ERP_chan
        ERP_bin
        Count_currentERP
        count_legend
        page_xyaxis
        Process_messg
        count_loadproper
    end
    
    events
        ALLERP_change
        ERP_change
        CURRENTERP_change
        Count_ERP_change
        ERP_chan_change
        ERP_bin_change
        v_currentERP_change
        count_legend_change
        page_xyaxis_change
        v_messg_change
        count_loadproper_change
    end
    
    methods
        %%m1
        function set.ALLERP(obj,value)
            obj.ALLERP = value;
            notify(obj,'ALLERP_change');
        end
        %%m2
        function set.ERP(obj,value)
            obj.ERP = value;
            notify(obj,'ERP_change');
        end
        
        %%m3
        %%Modified CurrentERP
        function set.CURRENTERP(obj,value)
            obj.CURRENTERP = value;
            notify(obj,'CURRENTERP_change');
        end
        
        %%m4
        %%ERP Plotting panel
        function set.Count_ERP(obj,value)
            obj.Count_ERP = value;
            notify(obj,'Count_ERP_change');
        end
        
        %%m5
        %Modified channels of the selected ERP
        function set.ERP_chan(obj,value)
            obj.ERP_chan = value;
            notify(obj,'ERP_chan_change');
        end
        
        %%m6
        %Modified bins of the selected ERP
        function set.ERP_bin(obj,value)
            obj.ERP_bin = value;
            notify(obj,'ERP_bin_change');
        end
        
        
        
        %%m7
        %Modified bins of the selected ERP
        function set.Count_currentERP(obj,value)
            obj.Count_currentERP = value;
            notify(obj,'v_currentERP_change');
        end
        
        %%m8
        %capture the changes of legend
        function set.count_legend(obj,value)
            obj.count_legend = value;
            notify(obj,'count_legend_change');
        end
        
        %%m9
        %Modify x/y axis based on the changed pages
        function set.page_xyaxis(obj,value)
            obj.page_xyaxis = value;
            notify(obj,'page_xyaxis_change');
        end

        %%%m10
        %Modified bins of the selected ERP
        function set.Process_messg(obj,value)
            obj.Process_messg = value;
            notify(obj,'v_messg_change');
        end
        
        
        %%%m11
        %Modified bins of the selected ERP
        function set.count_loadproper(obj,value)
            obj.count_loadproper = value;
            notify(obj,'count_loadproper_change');
        end

    end

end