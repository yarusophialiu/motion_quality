% load validation results
observers =  {'gd1', 'rk1', 'dy1', 'mj1', 'ny1', 'fz1', 'gd2', 'oy', 'aj1'};

current_path = fileparts(mfilename('fullpath'));

Results = load_validation_results(observers, 1);
Results_agg = grpstats(Results, {'bandwidth', 'frequency'}, 'mean', 'DataVars', {'chose_1'});
Results_agg.p_std = sqrt(Results_agg.mean_chose_1 .* (1 - Results_agg.mean_chose_1));
Results_agg.chose_1 = Results_agg.mean_chose_1 .* Results_agg.GroupCount;
Results_agg.chose_2 = Results_agg.GroupCount - Results_agg.chose_1;
Results_agg.var = Results_agg.GroupCount .* Results_agg.mean_chose_1 .* (1 - Results_agg.mean_chose_1);
Results_agg.std = sqrt(Results_agg.var);


bandwidths = unique(Results_agg.bandwidth);
freqs = [];
probs = [];
stds = [];
Qs = [];
for iB=1:length(bandwidths)
    R_f = Results_agg(Results_agg.bandwidth == bandwidths(iB),:);
    fct = length(R_f.frequency);
    freqs = [freqs; (R_f.frequency')];
    probs = [probs; (R_f.mean_chose_1')];
    M = zeros(fct+1, fct+1);
    M(1:fct, fct+1) = R_f.chose_2;
    M(fct+1, 1:fct) = R_f.chose_1;
%    Qs = [Qs; (pw_scale(M))'];
end
bar(probs);
xticklabels(arrayfun(@(b) sprintf('%2.0f MP/s', b / 1000000), bandwidths, 'UniformOutput', false));
xlabel('Bandwidth');
ylabel('P(Our technique)');
grid on;

save(sprintf('%s/validation_results', current_path), 'Results');
