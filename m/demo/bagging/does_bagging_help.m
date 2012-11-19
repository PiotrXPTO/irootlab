%> Tries bagging with an increasing number of classifiers, to see if classification improves.
%>@file
%>@ingroup demo
%>
%> @image html does_bagging_help_result.png
%> <center>Image obtained showing the number of classifiers \em versus classification rate.</center>
%>
%> In comparison:
%>@verbatim
%>Single classifier: specificity: 92.6267%; sensitivity: 90.4306%
%>@endverbatim
%> @sa aggr_bag


ddemo = load_data_she5trays;
ddemo = data_select_hierarchy(ddemo, 2); % N/T only

sp = sgs_randsub();
sp.flag_group = 1;
sp.flag_perclass = 1;
sp.type = 'balanced';
sp.bites = [.9, .1];

pie = data_split_sgs(ddemo, sp);
dstrain = pie(1);
dstest = pie(2); % Separates an independent set for testing


%--------
% Other stuff
%--------

lob = estlog_classxclass();
lob.estlabels = {'N', 'T'};
lob.testlabels = {'N', 'T'};


de = decider();
% de.decisionthreshold = 0;
de.decisionthreshold = 0.750000001;


%--------
% The classifier
%--------

o = clssr_d();
o = o.setbatch({'type', 'linear'});
clssr_d01 = o;

o = clssr_svm();
o.title = 'SVM - weighted';
o.c = 62;
o.gamma = 1.25; % these values were found through grid search
o.flag_weighted = 1;
clssr_svm01 = o;

clssr_mold = clssr_d01;


% SGS for the bagging classifier below
% It is basically a balanced randsub that will always select all the transformed colonies and the same amount of non-transformed colonies
o = sgs_randsub(); 
o.bites = .5; % 50%
o.type = 'balanced';
o.no_reps = 1;
o.randomseed = 0;
o.flag_perclass = 1;
o.flag_group = 1;
sgs_bag = o;

flag_hiesplit = 0;


esag01 = esag_linear1();
% esag01.threshold = 0.6000001;


o = aggr_bag;
o.title = 'Bag';
o.sgs = sgs_bag;
o.esag = esag01;
o.block_mold = clssr_mold;
o.flag_ests = 1;
aggr_bag = o;

clssr = aggr_bag;
clssr = clssr.boot();


%--------
% Almost there...
%--------

% Parameters for the get_insane_html() calls
pp.flag_discount_rejected = 1;
pp.flag_individual = 0;

%%
% Go!

n = 30; % Number of repetitions / final number of classifiers in the bag
specs = zeros(1, n); % specificities
senss = specs; % sensitivities
ii = 1;
for i = 1:n
    clssr = clssr.train(dstrain);
    
    est = clssr.use(dstest);
    est = de.use(est);
    
    ss = struct();
    ss.est = est;
    ss.ds_test = dstest;
    ss.clssr = clssr;
    lob = lob.allocate(1);
    lob = lob.record(ss);
    
    C = lob.get_C([], 1, 2, 1);
    specs(ii) = C(1, 2);
    senss(ii) = C(2, 3);
    ii = ii+1;
end;


%% Now train-tests using one classifier only to compare
clssr = clssr_mold.boot();
clssr = clssr.train(dstrain);
    
est = clssr.use(dstest);
est = de.use(est);

ss = struct();
ss.est = est;
ss.ds_test = dstest;
ss.clssr = clssr;
lob = lob.allocate(1);
lob = lob.record(ss);

C = lob.get_C([], 1, 2, 1);

fprintf('Single classifier: specificity: %g%%; sensitivity: %g%%\n', C(1, 2), C(2, 3));
fprintf('Bagging top: specificity: %g%%; sensitivity: %g%%\n', max(specs)*100, max(senss)*100);



%%
fig_assert();
nn = 1:n;
figure;
subplot(2, 1, 1);
plot(nn, specs*100, 'k', 'LineWidth', 4);
title('Specificity (correct classification of Non-transformed colonies)');
ylabel('%');
format_frank;
subplot(2, 1, 2);
plot(nn, senss*100, 'k', 'LineWidth', 4);
ylabel('%');
title('Sensitivity (correct classification of Transformed colonies)');
xlabel('Number of component classifiers');
format_frank;
