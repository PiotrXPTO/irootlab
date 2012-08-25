%> @brief IRoot TXT loader/saver
%>
%> This file type is recommended if you want to edit the dataset in e.g. Excel, it is capable of storing all the properties of the dataset.
%>
%> See Figure 1 for example.
%>
%> @image html dataformat_iroot.png
%> <center>Figure 1 - Example of IRoot TXT file open in a spreadsheet editing program.</center>
classdef dataio_txt_iroot < dataio
    properties(SetAccess=protected)
    end;
    methods
        function data = load(o)
            data = irdata();
            
            [no_cols, deli] = get_no_cols_deli(o.filename);
            mask = repmat('%s', 1, no_cols);
            
            fid = fopen(o.filename);
            flag_exp_header = 0;
            flag_exp_table = 0;
            fieldnames = [];
            fieldsfound = struct();
            
            while 1
                if flag_exp_table % expecting table
                    % reads everything, i.e., row fields
                    cc = textscan(fid, mask, 'Delimiter', deli, 'CollectOutput', 1); % Is this not quite slow?
                    cc = cc{1};
                    
                    for i = 1:length(fieldnames)
                        fn = fieldnames{i};
                        if fieldsfound.(fn).flag_cell
                            data.(fn) = cc(:, fieldsfound.(fn).idxs);
                        else
                            data.(fn) = str2double(cellfun(@strip_quotes, cc(:, fieldsfound.(fn).idxs), 'UniformOutput', 0));
                        end;
                    end;
                    break;
                else
                    % reads one line only
                    cc = textscan(fid, mask, 1, 'Delimiter', deli, 'CollectOutput', 1);
                    cc = cc{1};
                    if isempty(cc)
                        break;
                    end;
                end;
                
                if flag_exp_header
                    % goes through header to find which columns contain what
                    for i = 1:no_cols
                        for j = 1:length(data.rowfieldnames)
                            s = strip_quotes(cc{i});
                            if strcmp(s, data.rowfieldnames{j})
                                if ~isfield(fieldsfound, s)
                                    fieldsfound.(s) = struct('flag_cell', {data.flags_cell(j)}, 'idxs', {[]});
                                end;
                                fieldsfound.(s).idxs(end+1) = i;
                            end;
                        end;
                    end;
                    fieldnames = fields(fieldsfound);
                    flag_exp_header = 0;
                    flag_exp_table = 1;
                else
                    s = strip_quotes(cc{1});
                    if length(s) >= 7 && strcmp(s(1:7), 'IRoot')
                    elseif strcmp(s, 'classlabels')
                        data.classlabels = eval(strip_quotes(cc{2}));
                    elseif strcmp(s, 'fea_x')
                        % discards empty elements at the end of the cell
                        for i = length(cc):-1:1
                            if ~isempty(cc{i})
                                break;
                            end;
                        end;
                        cc = cc(2:i);
                        data.fea_x = str2double(cc);
                    elseif strcmp(s, 'table')
                        flag_exp_header = 1;
                    else
                        % Never mind
                    end;
                end;
            end;
            
            
            % Makes sure claslabels is correct
            ncc = max(data.classes)+1;
            if ncc > numel(data.classlabels)
                warning('Number of classlabels lower than number of classes');
                nl = data.get_no_levels();
                suffix = repmat('|1', 1, nl-1);
                for i = numel(data.classlabels)+1:ncc
                    data.classlabels{i} = ['Class ', int2str(i-1), suffix];
                end;
            end;
            
            data = data.eliminate_unused_classlabels();
                
            
            data.filename = o.filename;
            data.filetype = 'txt_iroot';
            data = data.make_groupnumbers();
        end;
    
        
        %------------------------------------------------------------------
        % Saver
        function o = save(o, data)

            h = fopen(o.filename, 'w');
            if h < 1
                irerror(sprintf('Could not create file ''%s''!', o.filename));
            end;

            fieldidxs = [];
            fieldcols = [];
            no_cols = 0;
            no_fields = 0;
            flag_table = 1; % Whether any of the data.rowfieldnames is in use, otherwise table part of file won't be saved

            % goes through possible fields to find which ones are being used, and to determine number of columns for CSV
            % file
            for i = 1:length(data.rowfieldnames)
                if ~isempty(data.(data.rowfieldnames{i}))
                    fieldidxs(end+1) = i;
                    fieldcols(end+1) = size(data.(data.rowfieldnames{i}), 2);
                    no_cols = no_cols+fieldcols(end);
                    no_fields = no_fields+1;
                end;
            end;
            if no_cols == 0
                flag_table = 0;
                no_cols = length(data.fea_x)+1;
                if no_cols < 2
                    no_cols = 2;
                end;
            end;
            
            tab = sprintf('\t');
            newl = sprintf('\n');
            
            fwrite(h, ['IRoot ' iroot_version() repmat(tab, 1, no_cols-1) newl]);
            fwrite(h, ['classlabels' tab cell2str(data.classlabels) repmat(tab, 1, no_cols-2) newl]);
            temp = sprintf(['%g' tab], data.fea_x);
            fwrite(h, ['fea_x' tab temp(1:end-1) repmat(tab, 1, no_cols-data.nf-1) newl]);
            fwrite(h, ['table' repmat(tab, 1, no_cols-1) newl]);
            
            

            if flag_table
                buflen = 1024; % writes every MB to disk
                buffer = repmat(' ', 1, buflen);
                ptr = 1;
                
                % table header
                for i = 1:no_fields
                    s = repmat([data.rowfieldnames{fieldidxs(i)} tab], 1, fieldcols(i));
                    buffer(ptr:ptr+length(s)-1) = s;
                    ptr = ptr+length(s);
                    if i == no_fields
                        ptr = ptr-1;% last tab won't count
                    end;
                end;
                buffer(ptr) = newl;
                ptr = ptr+1;
                flag_buffer = 1;
                
                rowptr = 1;
                flag_calc_len = 0;
                rowlen = 0; % average row length
                while 1
                    if rowptr > data.no
                        break;
                    end;
                    
                    % data row
                    ptr_save = ptr;
                    for i = 1:no_fields
                        if data.flags_cell(fieldidxs(i))
                            s = sprintf('%s\t', data.(data.rowfieldnames{fieldidxs(i)}){rowptr, :});
                        else
                            s = sprintf('%g\t', data.(data.rowfieldnames{fieldidxs(i)})(rowptr, :));
                        end;
                        buffer(ptr:ptr+length(s)-1) = s;
                        ptr = ptr+length(s);
                        if i == no_fields
                            ptr = ptr-1;% last tab won't count
                        end;
                    end;
                    buffer(ptr) = newl;
                    ptr = ptr+1;
                    rowlen = (rowlen*(rowptr-1)+(ptr-ptr_save))/rowptr;
                    flag_buffer = 1;

                    % tolerance of rowlen not to blow buffer
                    if ptr+2*rowlen > buflen
                        fwrite(h, buffer(1:ptr-1));
                        ptr = 1;
                        flag_buffer = 0;
                    end;
                    
                    rowptr = rowptr+1;
                end;
                
                if flag_buffer
                    fwrite(h, buffer(1:ptr-1));
                end;
            end;

            fclose(h);
            
            irverbose(sprintf('Just saved file "%s"', o.filename), 2);
        end;
    end
end
