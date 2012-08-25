%> @ingroup as tentative
%> @brief Calculates grades as correlations with the "optimal score"
%>
%> @sa feasel_corr
classdef as_grades_corr < as_grades_data
    properties
        %> =10. Number of features to be selected
        nf_select = 10;
    end;
    
    methods
        function o = as_grades_corr()
            o.classtitle = 'Corr';
        end;

        function o = go(o)
            o.v = feasel_corr(o.data(1), o.nf_select);
            o.grades = zeros(1, o.data(1).nf);
            o.grades(o.v) = 1;
            o.fea_x = o.data(1).fea_x;
            o.xname = o.data(1).xname;
            o.xunit = o.data(1).xunit;
            o.yname = 'fsel-corr';
        end;
    end;   
end
