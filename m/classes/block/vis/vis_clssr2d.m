%> @brief Classification Domain - classification regions etc
classdef vis_clssr2d < vis
    methods
        function o = vis_clssr2d(o)
            o.classtitle = 'Classification Domain';
            o.inputclass = 'clssr';
        end;
    end;
    
    methods(Access=protected)
        function out = do_use(o, obj)
            out = [];
            %> @todo still TODO
        end;
    end;
end