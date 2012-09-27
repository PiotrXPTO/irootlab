%> @brief Log generated as a result of an AS_CROSSC go()
%>
%> Allows one to extract elements:
%> @arg The average loadings matrix
%> @arg Each individually trained block and respective output dataset
%>
%> @sa as_crossc
classdef log_as_crossc < irlog
    properties
        sgs;
        data_out;
        blocks;
        obsidxs;
        %> This will be set at go() time and used subsequently to reorder
        %> the classlabels of extracted dataset(s)
        classlabels;
    end;

    methods
        function o = log_as_crossc()
            o.classtitle = 'Cross-Calculation';
            o.moreactions = [o.moreactions, {'extract_blocks', 'extract_block', 'extract_datasets', 'extract_dataset'}];
            o.flag_ui = 0;
        end;
    end;
    
    methods
        %> Extracts fold-wise blocks
        function out = extract_blocks(o)
            out = o.blocks;
        end;
        
        %> Extracts a linear transform whose loadings is the average from all blocks loadings
        function out = extract_block(o)
            nb = numel(o.blocks);
            L = 0;
            
            for i = 1:nb
                L = L+o.blocks{i}.L;
            end;
            L = L/nb;
            
            out = fcon_linear_fixed();
            out.L = L;
            out.L_fea_x = o.data_out(1).fea_x;
            out.xname = o.data_out(1).xname;
            out.xunit = o.data_out(1).xunit;
        end;
        
        %> Extracts datasets
        function out = extract_datasets(o)
            out = o.data_out;
        end;
        
        %> Extracts cross-calculated output dataset
        function out = extract_dataset(o)
            out = data_renumber_classes(data_merge_rows(o.data_out), o.classlabels);
        end;
    end;
end
