%> @brief Carries subsets of features
classdef log_fselrepeater < irlog
    properties
        %> Extracted from data
        fea_x;
        %> Extracted from data
        xname;
        %> Extracted from data
        xunit;
        %> Array of log_as_fsel objects
        logs;
    end;        
    
    properties(Dependent)
        %> (Read-only) Cell containing the features selected at each repetition. This will be the base to build a histogram.
        %> @note This has to be a cell because the number of selected features may not be fixed at each repetition. For example, feature selection
        %>       methods that pick peaks of the grades curve may find the grades curve to have eventually more or less peaks.
        %>
        %> Dimensions [number of repetitions]; each element is a vector of dimension [o.as_fsel.nf_select (maximum)]
        subsets;
        %> Meaning (Number of features)x(rate);
        %> Dimensions [number of repetitions]x[o.as_fsel.nf_select]
        %> The numbers are the calculated "grades"
        nfxgrade;
        %> Maximum number of features selected
        nfmax;
    end;
    
    methods
        function o = log_fselrepeater()
            o.classtitle = 'Subsets log';
            o.moreactions = [o.moreactions, {'extract_dataset_nfxgrade', 'extract_dataset_stabilities'}];
        end;

        
        function n = get.nfmax(o)
            n = max(cellfun(@numel, o.subsets));
        end;
        
       
        %> @returns A cell of vectors
        function out = get.subsets(o)
            n = numel(o.logs);
            out = cell(1, n);
            for i = 1:n
                out{i} = o.logs(i).v;
            end;
        end;
        
        %> @returns A matrix [number of repetitions]x[number of features selected]
        function out = get.nfxgrade(o)
            n = numel(o.logs);
            nf = o.nfmax;
            out = NaN(n, nf);
            for i = 1:n
                temp = o.logs(i).nfxgrade;
                out(i, 1:numel(temp)) = temp;
            end;
        end;
    end;

    
    % *-*-*-*-*-*-* TOOLS
    methods
        %> Returns a (feature position)x(stability curve)
        %>
        %> @param type Type of stability measure (e.g., 'kun')
        %> @param type2 'uni' or 'mul'
        %>
        %> @sa featurestability.m
        function z = get_stabilities(o, type, type2)
            if ~isempty(o.pvt_z) && strcmp(o.pvt_type, type) && strcmp(o.pvt_type2, type2)
                z = o.pvt_z;
            else
                z = featurestability(o.subsets, numel(o.fea_x), type, type2);
            end;
        end;


        %> Extract dataset to visualize FFS progress
        %>
        %> Each row of the dataset shows the performance progression of a Forward Feature Selection (FFS) run.
        function out = extract_dataset_nfxgrade(o)
            if isempty(o.logs)
                irerror('Empty logs');
            end;
            if ~isprop(o.logs(1), 'nfxgrade')
                irerror(sprintf('Logs of wrong class: "%s"', class(o.logs(1))));
            end;
            
            out = irdata();
            out.X = o.nfxgrade;
            out.classlabels = {'Grade'};
            out.fea_x = 1:size(o.nfxgrade, 2);
            out.xname = 'Number of features';
            out.xunit = '';
            out.yname = 'Grade';
            out.yunit = '';
            out.title = 'Number of features X Grades';
            out = out.assert_fix();
        end;
        
        %> Extract dataset with one row containing stability measures
        %>
        %> @param type Type of stability measure (e.g. 'kun'). See @ref featurestability.m
        %> @param type2 'uni' or 'mul'. See @ref featurestability.m
        %>
        %> @sa featurestability.m
        function out = extract_dataset_stabilities(o, type, type2)
            if nargin < 3 || isempty(type)
                type = 'kun';
            end;
            if nargin < 3 || isempty(type2)
                type2 = 'uni';
            end;
            if isempty(o.logs)
                irerror('Empty logs');
            end;
            
            out = irdata();
            out.X = o.get_stabilities(type, type2);
            out.classlabels = {'Stability'};
            out.fea_x = 1:size(out.X, 2);
            out.xname = iif(type2 == 'uni', 'Feature rank', 'Number of features');
            out.xunit = '';
            out.yname = 'Stability';
            out.yunit = '';
            out.title = sprintf('Stabilities (''%s'', ''%s'')', type, type2);
            out = out.assert_fix();
        end;
    end;
    

    
    %> This system was set to speed up the report generation. Stability vectors won't have to be recalculated
    %>
    %> However, note that if o.subsets is reset, the following properties will get out of sync. So, use carefully.
    properties(Access=private)
        pvt_z;
        pvt_type;
        pvt_type2;
    end;
    
    methods
        %> @brief Stores stabilities vector to prevent frequent recalculation
        function o = calculate_stabilities(o, type, type2)
            o.pvt_z = o.get_stabilities(type, type2);
            o.pvt_type = type;
            o.pvt_type2 = type2;
        end;
    end;   
end
