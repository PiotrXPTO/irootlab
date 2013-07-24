%> @brief Visualization - All curves in dataset
classdef vis_alldata < vis
    methods
        function o = vis_alldata(o)
            o.classtitle = 'All curves in dataset';
            o.inputclass = 'irdata';
            o.flag_params = 0;
        end;
    end;
    
    methods(Access=protected)
        function out = do_use(o, obj);
            out = [];
            data_draw(obj);
            make_box();
            set_title(o.classtitle, obj);
        end;
    end;
end
