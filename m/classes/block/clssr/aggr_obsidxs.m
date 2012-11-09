%> @brief Pre-determined dataset splits
%>
%> The number of components and how their respective training data are obtained are pre-determined by the @ref obsidxs property.
%>
%> Allows multi-training but this is pointless unless the component classifiers are non-deterministic
%>
%> Not currently published in the GUI
classdef aggr_obsidxs < aggr
    properties
        %> must contain a block object that will be replicated as needed
        block_mold = [];
        %> Cell of vectors containing row indexes to a dataset. This is generated by some @ref sgs::get_obsidxs(). Such @ref sgs
        %> needs have one bite only. It will probably be a [no_reps]x[1] cell
        obsidxs;
    end;

    methods
        function o = aggr_obsidxs()
            o.classtitle = 'Fixed sub-sampling';
        end;
    end;
    
    methods(Access=protected)
        function o = do_boot(o)
        end;

        % Adds classifiers when new classes are presented
        function o = do_train(o, data)
            no_reps = size(o.obsidxs, 1);
            
            ipro = progress2_open('AGGR_OBSIDXS', [], 0, no_reps);
            for i_rep = 1:no_reps
                datasets = data.split_map(o.obsidxs(i_rep, 1));
                
                cl = o.block_mold.boot();
                cl = cl.train(datasets(1));
                o = o.add_clssr(cl);
                
                ipro = progress2_change(ipro, [], [], i_rep);
            end;
            progress2_close(ipro);
        end;
    end;
end