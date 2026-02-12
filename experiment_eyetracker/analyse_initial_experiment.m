sacc_th_map = containers.Map({'pmh64', 'am2442'}, {2, 1.1});

if ~exist('data/initial_cache.mat', 'file')
    results = load_results('Initial', { 'am2442', 'gd355', 'pmh64', 'fz261'}, sacc_th_map); % 'am2442',, 'gd355'
    results = process_add_loc_diff(results);
    results = process_add_tau(results);
    results = process_add_v_diff(results);
    results = process_add_sacc(results);
    save('data/initial_cache.mat', 'results');
else
    dat = load('data/initial_cache.mat');
    results = dat.results;
end

refresh_rates = unique(results.refresh_rate);
figure(3);
errplot2(results);

for ii=1:length(refresh_rates)
    figure(ii+3);
    clf;
    errplot1(results(results.refresh_rate==refresh_rates(ii), :));
end


results_agg = grpstats(results, {'trial_name', 'refresh_rate'}, {'mean', 'std'}, 'DataVars', {'pos_x_mean', 'pos_x_var', 'saccades', 'vel_x_mean', 'vel_x_var', 'tau'});

results_agg_obs = grpstats(results, {'observer_id'}, {'mean', 'std'}, 'DataVars', {'pos_x_mean', 'pos_x_var', 'saccades', 'vel_x_mean', 'vel_x_var', 'tau'});

figure(1);
clf;
subplot(2,3,1);
errorbar_plot(results_agg, 'saccades', 'refresh_rate', 'trial_name');
subplot(2,3,2);
errorbar_plot(results_agg, 'pos_x_mean', 'refresh_rate', 'trial_name');
subplot(2,3,3);
errorbar_plot(results_agg, 'vel_x_mean', 'refresh_rate', 'trial_name');
subplot(2,3,4);
errorbar_plot(results_agg, 'tau', 'refresh_rate', 'trial_name');
subplot(2,3,5);
errorbar_plot(results_agg, 'pos_x_var', 'refresh_rate', 'trial_name');
subplot(2,3,6);
errorbar_plot(results_agg, 'vel_x_var', 'refresh_rate', 'trial_name');

subplot(2,3,2);
ylims = ylim;
a = results(strcmpi(results.trial_name, 'SumSinusoidsExperimentTrial'),:);
sumsin_mean_v = a.object(1).trial.get_velocity_stat * 2560;
xlims = xlim;
fpss = linspace(xlims(1), xlims(2), 100);
blur_fit = sumsin_mean_v ./ fpss + 70;
plot(fpss, blur_fit, '--');
ylim(ylims);

figure(2);
clf;
subplot(2,3,1);
bar_plot(results_agg_obs, 'saccades');
subplot(2,3,2);
bar_plot(results_agg_obs, 'pos_x_mean');
subplot(2,3,3);
bar_plot(results_agg_obs, 'vel_x_mean');
subplot(2,3,4);
bar_plot(results_agg_obs, 'tau');
subplot(2,3,5);
bar_plot(results_agg_obs, 'pos_x_var');
subplot(2,3,6);
bar_plot(results_agg_obs, 'vel_x_var');

