%>@brief carried a histogram
classdef log_hist < log_grades
    properties
        %> [number of selected features]x[nf (total number of features dataset)]. Individual hits.
        hitss;
        %> Number of selected features used to compose @c grades
        nf4grades;
    end;
    
    methods
        function o = log_hist()
            o.classtitle = 'Histogram';
            o.yname = 'Hits';
            o.yunit = '';
            o.flag_ui = 0;
        end;
    end;
    
    %======> DRAWING
    methods
        %>@brief Draws histograms
        %>
        %> Will generate subplots if @c idxs has more than one element
        %>
        %> @param idxs=all Indexes of feature orders to plot
        function o = draw_hists(o, idxs, data_hint, flag_group)
            if isempty(idxs)
                idxs = 1:size(o.hitss, 1);
            end;
            if any(idxs > size(o.hitss, 1))
                irverbose('Info: histograms index was trimmed');
                
                idxs(idxs > size(o.hitss, 1)) = [];
            end;
            
            if ~exist('flag_group', 'var')
                flag_group = 0;
            end;
            
            if nargin < 3 || isempty(data_hint)
                xhint = [];
                yhint = [];
            else
                xhint = data_hint.fea_x;
                yhint = mean(data_hint.X, 1);
            end;
            
            [nor, nf] = size(o.hitss); %#ok<NASGU>
            if nargin < 2
                idxs = 1:nor;
            end;
            
            if ~flag_group
                ni = numel(idxs);
                for i = 1:ni
                    idx = idxs(i);

                    if ni > 1
                        subplot(ni, 1, i);
                    end;

                    draw_loadings(o.fea_x, o.hitss(idx, :), xhint, yhint, [], 0, [], 0, 0, 0, 1, [], {find_color_stackedhist(idx)});
                    ylabel(sprintf('%s', int2ord(idx)));
                    if i < ni
                        set(gca, 'xtick', []);
                    end;
                end;
            else
                v = sum(o.hitss(idxs, :), 1);
                draw_loadings(o.fea_x, v, xhint, yhint, [], 0, [], 0, 0, 0, 1);
                title(sprintf('Histograms taken: %s', mat2str(idxs)));
            end;
        end;
        
        
        %>@brief Draws histograms Using stacked bars
        %>
        %> Note that this will work for Forward Feature Selection only
        %>
        %> @param data_hint Hint dataset
        %> @param no_inside Number of histograms that are considered "informative"
        %> @param colors =(default colors). Either a cell of 2 elements or 4 elements. If it is a cell of two elements,
        %> the non-informative and informative histograms will have gradients
        %> @param peakdetector Use it to mark peaks in the histogram
        function draw_stackedhists(o, data_hint, colors, peakdetector)
            if nargin < 2 || isempty(data_hint)
                xhint = [];
                yhint = [];
            else
                xhint = data_hint.fea_x;
                yhint = mean(data_hint.X, 1);
            end;
            
            if nargin < 3
                colors = [];
            end;
            
            if nargin < 4
                peakdetector = [];
            end;
            
            draw_stacked(o.fea_x, o.hitss, o.nf4grades, colors, xhint, yhint, peakdetector, 1, 1, 1, 1);
            format_xaxis(o);
            format_yaxis(o);
        end;
        
        %> Draws each per-feature-position histogram as a line
        function draw_as_lines(o)
            for i = 1:size(o.hitss, 1);
                plot(o.fea_x, o.hitss(i, :), 'LineWidth', scaled(2), 'Color', find_color_stackedhist(i));
                hold on;
            end;
            set(gca, 'Ylim', [0, max(o.hitss(:))*1.025]);
            format_xaxis(o);
            format_yaxis(o);
            format_frank();
        end;
    end;
end