%>@ingroup string htmlgen
%>@file
%>@brief Transforms matrix into HTML

%> @param CC confusion matrix (first column always represents "rejected" items)
%> @param rowlabels row labels
%> @param collabels=rowlabels column labels
%> @param flag_perc=0
%> @param flag_rejected=(auto-detect)
%> @param flag_color=1 Whether to use colors for cell background. If true, will paint the background with a red gradient which is
%> proportional to the square root of the number inside divided by the square root of the corresponding row sum.
function s = html_confusion(CC, rowlabels, collabels, flag_perc, flag_rejected, flag_color)

if ~exist('collabels', 'var') || isempty(collabels)
    collabels = rowlabels;
end;

if ~exist('flag_perc', 'var') || isempty(flag_perc)
    flag_perc = 0;
end;

[ni, nj] = size(CC);

if ~exist('flag_rejected', 'var') || isempty(flag_rejected)
    flag_rejected = any(CC(:, 1) > 0);
end;

if ~exist('flag_color', 'var') || isempty(flag_color)
    flag_color = 1;
end;

sperc = '';
if flag_perc
    sperc = '%';
    CC = round(CC*100)/100; % To make 2 decimal places only
end;


% Makes table header
c = {'&nbsp'};
if flag_rejected; c = [c, 'rejected']; end;
c = [c, collabels];
h = arrayfun(@(s) ['<td class="tdhe">', s{1}, '</td>'], c, 'UniformOutput', 0);
s = ['<table>', 10, '<tr>', strcat(h{:}), '</tr>', 10];

h = cell(1, nj);
for i = 1:ni
    if flag_perc
        ma = 100;
    else
        ma = sum(CC(i, :));
    end;

    k = 0; % graphics column (whereas j is the matrix column)
    for j = iif(flag_rejected, 1, 2):nj % column loop
        k = k+1;
        n = CC(i, j);
        if ~flag_color
            bgcolor = 'FFFFFF';
            fgcolor = '000000';
        else
            [bgcolor, fgcolor] = cellcolor(n, ma, 1);
        end;
        h{k} = ['<td class="tdnu" style="color: #', fgcolor, '; background-color: #', bgcolor, ';">', num2str(n), sperc, '</td>'];
    end;

    s = cat(2, s, ['<tr><td class="tdle">', rowlabels{i}, '</td>', strcat(h{:}), '</tr>', 10]);
end;
s = cat(2, s, '</table>', 10);
