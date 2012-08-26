%> @file
%> @ingroup globals setupgroup
%> @brief writes MATLAB M file irootlab_setup.m
%>
%> Writes several global variables into a MATLAB source file called <code>irootlab_setup.m</code>. This file can be later executed to restore
%> the setup conditions.
%>
%> The variables written are the graphics globals, database globals, and verbose globals.
%>
%> @sa verbose_assert.m, db_assert.m, fig_assert.m, path_assert.m

function setup_write()

s0 = [sprintf('verbose_assert();\ndb_assert();\nfig_assert();\npath_assert();\nmore_assert();\n')]; %#ok<NBRAK>
eval(s0);

convert_colors();

which = {'SCALE', 'COLORS', 'MARKERS', 'MARKERSIZES', 'FONT', 'FONTSIZE', 'LINESTYLES', ...
         'VERBOSE.minlevel', 'VERBOSE.flag_file', ...
         'DB.host', 'DB.name', 'DB.user', 'DB.pass', ...
         'PATH.data_load', 'PATH.data_save', 'PATH.data_spectra', 'PATH.doc', ...
         'MORE.pd_maxpeaks', 'MORE.pd_mindist_units', 'MORE.pd_minheight', 'MORE.pd_minaltitude', ...
         'MORE.ssp_stabilitythreshold', 'MORE.ssp_minhits_perc', 'MORE.ssp_nf4gradesmode', 'MORE.bc_halfheight', 'COLORS_STACKEDHIST'};

whichglobals = {};
for i = 1:numel(which)
    fi = find(which{i} == '.');
    if fi
        whichglobals{end+1} = which{i}(1:fi-1); %#ok<*AGROW>
    else
        whichglobals{end+1} = which{i};
    end;
end;
whichglobals = unique(whichglobals);

s1 = 'global ';
for i = 1:numel(whichglobals)
    if i > 1
        s1 = cat(2, s1, ' ');
    end;
    s1 = cat(2, s1, whichglobals{i});
end;
s1 = cat(2, s1, ';', 10);


eval(s1);


s2 = '';
for i = 1:numel(which)
    try
        syma = eval(which{i});
    catch ME
        irerror(sprintf('Problem trying to evaluate "%s": %s', which{i}, ME.message));
    end;
    s2 = cat(2, s2, which{i}, ' = ', convert_to_str(syma), ';', 10);
end;



ss = ['%      V V', 10, '%  vvvO8 8Ovvv', 10, '% IRootLab setup generated at ', datestr(now()), '.', 10, '% Please note that this file may be automatically re-generated by IRootLab.', 10, '% Do not add comments, as these will not be kept.', 10, s0, 10, s1, s2];

h = fopen('irootlab_setup.m', 'w');
fwrite(h, ss);
fclose(h);
irverbose('Wrote file "irootlab_setup.m"', 1);

%%%%%%%%%%
% Converts colors to 0-255 range
function convert_colors()
global COLORS COLORS_STACKEDHIST;

COLORS = convert_(COLORS);
COLORS_STACKEDHIST = convert_(COLORS_STACKEDHIST);

%%%%%%%%%%
function C = convert_(C)

% Converts to 0-1 if COLORS has values above 0-1
cc = cell2mat(C);
if all(cc(:) <= 1)
    C = cellfun(@(x) round(x*255), C, 'UniformOutput', 0);
end;
