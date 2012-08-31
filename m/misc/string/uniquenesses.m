%>@ingroup string
%> @file
%> @brief Extract unique part of each string within a cell
%>
%> Iterates through the strings to find a piece in the middle that is different in each string.
%>
%> @param cc Cell of strings
%> @return dd Cell of strings
function dd = replace_underscores(cc)

n = numel(cc);
nn = cellfun(@numel, cc);
bk = 1;
flag_break = 0;
while 1
    for i = 1:n
        if bk > nn(i)
            flag_break = 1;
            break;
        end;
        if i == 1
            ch = cc{i}(bk);
        else
            if cc{i}(bk) ~= ch
                flag_break = 1;
                break;
            end;
        end;
    end;
    if flag_break
        break;
    end;
    bk = bk+1;
end;


ck = 0;
flag_break = 0;
while 1
    for i = 1:n
        if nn(i)-ck < 1
            flag_break = 1;
            break;
        end;
        if i == 1
            try
            ch = cc{i}(end-ck);
            catch me
                sdfs;
            end;
        else
            if cc{i}(end-ck) ~= ch
                flag_break = 1;
                break;
            end;
        end;
    end;
    if flag_break
        break;
    end;
    ck = ck+1;
end;



for i = 1:n
    dd{i} = cc{i}(bk:end-ck);
end;