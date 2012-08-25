%> architecture optimization for the qdc classifier
%>
%>
classdef clarchsel_qdc < clarchsel_noarch
    methods
        function o = customize(o)
            o = customize@clarchsel_noarch(o);
            o.nfs = o.oo.clarchsel_qdc_nfs;
        end;

        function sos = get_sostage_cl(o)
            sos = sostage_cl_qdc();
            sos = o.setup_sostage_cl(sos, 1);
        end;
    end;
end
