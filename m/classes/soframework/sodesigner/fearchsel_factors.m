%> architecture optimization for the ldc classifier
%>
%>
classdef fearchsel_factors < fearchsel
    properties
        nfs = NaN;
    end;

    methods(Abstract)
        %> The difference between descendants (PCA, PLS etc) is the sostage_fe that is used
        o = get_sostage_fe(o);
    end;
    

    methods(Access=protected)
        function out = do_design(o)
            item = o.input;
            dia = item.get_modifieddia();
            % Customizes diagnosissystem
            dia.sostage_fe = o.get_sostage_fe();
            ds = o.oo.dataloader.get_dataset();
            ds = dia.preprocess(ds);

            no_feature_s = o.nfs;
            no_feature_s(no_feature_s > rank(ds.X)) = [];
%             no_feature_s(no_feature_s) 
            
            
            % Makes column vector of blocks
            nfe = numel(no_feature_s);
            molds = cell(nfe, 1);
            for j = 1:nfe
                specs{j, 1} = sprintf('nf=%d', no_feature_s(j));
                dia.sostage_fe.nf = no_feature_s(j);
                molds{j, 1} = dia.get_fecl();
                sostages{j, 1} = dia.sostage_fe;
            end;
            
            r = o.go_cube(ds, molds, sostages, specs);
            
            r.ax(1) = raxisdata_nfs(no_feature_s);
            r.ax(2) = raxisdata_singleton();
            
            out = soitem_sostagechoice();
            out.sovalues = r;
            out.dia = item.get_modifieddia();
            out.dstitle = ds.title;
            out.title = [upper(class(o)), ': ', out.dia.get_sequencedescription()];
        end;
    end;
end
