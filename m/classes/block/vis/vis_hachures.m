%> Hachures showing intervals
classdef vis_hachures < vis
    methods
        function o = vis_hachures()
            o.classtitle = 'Class means with standard deviation';
            o.inputclass = 'irdata';
            o.flag_params = 0;
        end;
    end;
    
    methods(Access=protected)
        function [o, out] = do_use(o, obj)
            out = [];
            
            data_draw_hachures(obj);
        end;
    end;
end
