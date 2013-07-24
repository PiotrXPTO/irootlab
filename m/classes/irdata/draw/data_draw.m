%>@ingroup datasettools
%>@file
%>@brief Draws "all curves in dataset"
function data = data_draw(data)

pieces = data_split_classes(data);
h = [];
llabels = {};
for i = 1:length(pieces)
    if pieces(i).no > 0
        eh = zeros(1, size(pieces(i).X, 2));
        h_temp = plot(data.fea_x, pieces(i).X', 'Color', find_color(i), 'LineWidth', scaled(1));
        h(end+1) = h_temp(1);
        llabels{end+1} = data.classlabels{i};
        hold on;
    end;
end;
legend(h, llabels);

alpha(0);

format_xaxis(data);
format_yaxis(data);
format_ylim(data);
format_frank();
