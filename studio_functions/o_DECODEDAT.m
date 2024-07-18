classdef o_DECODEDAT < handle
    properties
        ALLBEST
        BEST
        CURRENTBEST
        Count_currentbest
        Process_messg
        Best_between_panels
        Reset_Best_paras_panel
        ALLMVPC
        MVPC
        CURRENTMVPC
        Count_currentMVPC
    end
    
    events
        allbest_changed
        best_changed
        currentbest_changed
        Count_currentbest_change
        Messg_change
        Best_between_panels_change
        Reset_best_panel_change
        ALLMVPC_changed
        MVPC_changed
        CURRENTMVPC_changed
        Count_currentMVPC_changed
    end
    
    
    methods
        function set.ALLBEST(obj,value)
            try
                warning('off');
                obj.ALLBEST = value;
                notify(obj,'allbest_changed');
            catch
            end
            warning('on');
        end
        
        function set.BEST(obj,value)
            try
                warning('off');
                obj.BEST = value;
                notify(obj,'best_changed');
            catch
            end
            warning('on');
        end
        
        %%Modified CurrentBEST
        function set.CURRENTBEST(obj,value)
            try
                warning('off');
                obj.CURRENTBEST = value;
                notify(obj,'currentbest_changed');
            catch
            end
            warning('on');
        end
        
        
        
        %Modified bins of the selected BEST
        function set.Count_currentbest(obj,value)
            try
                warning('off');
                obj.Count_currentbest = value;
                notify(obj,'Count_currentbest_change');
            catch
                warning('on');
            end
            
        end
        
        %Modified bins of the selected BEST
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
        function set.Best_between_panels(obj_BEST,values_BEST)
            try
                warning('off', 'all');
                obj_BEST.Best_between_panels = values_BEST;
                notify(obj_BEST,'Best_between_panels_change');
            catch
                warning('on');
            end
        end
        
        %%two panels
        function set.Reset_Best_paras_panel(obj_BEST,values_BEST)
            try
                warning('off');
                obj_BEST.Reset_Best_paras_panel = values_BEST;
                notify(obj_BEST,'Reset_best_panel_change');
            catch
                warning('on');
            end
        end
        %%
        %%two panels
        function set.ALLMVPC(obj_BEST,values_BEST)
            try
                warning('off');
                obj_BEST.ALLMVPC = values_BEST;
                notify(obj_BEST,'ALLMVPC_changed');
            catch
                warning('on');
            end
        end
        
        %%MVPC
        function set.MVPC(obj_BEST,values_BEST)
            try
                warning('off');
                obj_BEST.MVPC = values_BEST;
                notify(obj_BEST,'MVPC_changed');
            catch
                warning('on');
            end
        end
        
        
        %%MVPC
        function set.CURRENTMVPC(obj_BEST,values_BEST)
            try
                warning('off');
                obj_BEST.CURRENTMVPC = values_BEST;
                notify(obj_BEST,'CURRENTMVPC_changed');
            catch
                warning('on');
            end
        end
        
        %%MVPC
        function set.Count_currentMVPC(obj_BEST,values_BEST)
            try
                warning('off');
                obj_BEST.Count_currentMVPC = values_BEST;
                notify(obj_BEST,'Count_currentMVPC_changed');
            catch
                warning('on');
            end
        end
        
        
    end
end