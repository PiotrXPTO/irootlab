%> @brief Confusion matrix is Group versus Assigned class
%>
%> Classification rates don't make sense in this case because there is no way to determine whether the classifications are correct.
%> Therefore, these methods are not inherited (they remain as in @ref estlog).
classdef estlog_groupxclass < estlog
    properties
        %> All possible group codes. Assigned directly.
        groupcodes;
        %> All possible class labels in estimation datasets
        estlabels = {};
    end;

    methods
        function o = estlog_groupxclass()
            o.classtitle = 'Group X Class';
            o.flag_params = 1;
        end;
    end;
    
    methods(Access=protected)
        %> Returns the contents of the @c estlabels property.
        function z = get_collabels(o)
            z = o.estlabels;
        end;
        
        %> Returns the contents of the @c testlabels property.
        function z = get_rowlabels(o)
            z = o.groupcodes;
        end;

        function o = do_record(o, pars)
            est = pars.est;
            estclasses = renumber_classes(est.classes, est.classlabels, o.estlabels);
            dref = pars.dref;
            [drefgroupcodes, dummy, map] = unique(dref.groupcodes); % map contains information similar to crossvalind() output, i.e., repeated numbers mean same group.
            for i = 1:max(map)
                idxi = find(strcmp(drefgroupcodes{i}, o.groupcodes)); % Finds where current group sits in o.groupcodes
                if isempty(idxi)
                    irerror(sprintf('Group "%s" not found in groupcodes list!', drefgroupcodes{i}));
                end;
                
                rowidxs = map == i;
                sel = estclasses(rowidxs);
                if o.flag_support
                    supp = est.X(rowidxs, 1)';
                end;

                for j = 1:numel(o.estlabels)
                    idxidxbool = sel == j-1;
                    o.hits(idxi, j+1, o.t) = o.hits(idxi, j+1, o.t)+sum(idxidxbool);
                    if o.flag_support
                        o.supports{idxi, j+1, o.t} = supp(idxidxbool);
                    end;
                end;

                idxidxbool = sel == -1;
                o.hits(idxi, 1, o.t) = sum(idxidxbool); % Rejection count.
                if o.flag_support
                    o.supports{idxi, 1, o.t} = supp(idxidxbool); % Assumeed that est is the output of a decider block which produces a X with one feature only, which is the support.
                end;
            end;
        end;
    end;
end