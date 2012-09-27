% I will restore this later
%                 u = vis_sovalues_drawimage();
%                 u.dimspec = {[0 0], [1, 2]};
%                 u.valuesfieldname = 'rates';
%                 u.clim = [];
%                 u.flag_logtake = 0;
%                 u.flag_transpose = 0;
%                 figure; u.use(sor); pause(.1); maximize_window(gcf(), 3);   


%> draws the figures and generates HTML for the Feature Extraction Design
classdef report_fearchsel < report_singlefile
    methods
        function o = report_fearchsel()
            o.pattern_exclude = 'fearchsel_fhana';
        end;
            
        function s = get_token(o)
            s = 'fearchsel';
        end;
        
        
        function s0 = process_item(o, item, fnprefix)
            sor = item.sovalues;

            s0 = '';
            
            if o.flag_images
                s0 = cat(2, s0, '<h3>Figures</h3>', 10);
%                 s0 = cat(2, s0, o.images3(fnprefix, sor));
                
                nd = ndims(sor.values);
                if nd == 3
                    s0 = cat(2, s0, o.images4(fnprefix, sor));
                else
                    s0 = cat(2, s0, o.images3(fnprefix, sor));
                end;
            end;

            if o.flag_tables
                s0 = cat(2, s0, '<h3>Specifications</h3>', 10);
                s0 = cat(2, s0, '<center>', sor.get_html_specs(), '</center>', 10);

            end;
            
            if o.flag_tables
                ot = sovaluestablereport();
                ot.flag_ptable = o.flag_ptable;

                s0 = cat(2, s0, '<h3>Comparison tables</h3>', ot.get_html(sor));
            end;
        end;
    end;
end