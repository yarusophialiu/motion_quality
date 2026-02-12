sacc_th_map = containers.Map({'pmh64', 'am2442'}, {2, 1.1});

if ~exist('data/60_120_cache.mat', 'file')
    results = load_results('FPS60vs120', { 'gd355', 'am2442' }, sacc_th_map); 
    results = process_add_loc_diff(results);
    results = process_add_tau(results);
    results = process_add_v_diff(results);
    results = process_add_sacc(results);
    save('data/60_120_cache.mat', 'results');
else
    dat = load('data/60_120_cache.mat');
    results = dat.results;
end

mv = zeros(size(results,1), 1);

for ir=1:size(results,1)
    [me, mi, ma] = get_velocity_stat(results.object(ir).trial);
    me = round((me * 43.6) / 2) * 2;
    
    if me == 26
        me = 28; % minor correction
    end
    
    mv(ir) = me;
end
results.v_mean = mv;

figure(3);
clf;
errplot1(results(results.refresh_rate == 60,:));

figure(4);
clf;
errplot1(results(results.refresh_rate == 120,:));

figure(5);
clf;
errplot1(results);

figure(6);
errplot2(results);

results_agg = grpstats(results, {'trial_name', 'refresh_rate', 'v_mean'}, {'mean', 'std'}, 'DataVars', {'pos_x_mean', 'pos_x_var', 'saccades', 'vel_x_mean', 'vel_x_var', 'tau'});
results_agg.cat = strcat(results_agg.trial_name, '_', num2str(results_agg.refresh_rate));

results_agg_obs = grpstats(results, {'observer_id'}, {'mean', 'std'}, 'DataVars', {'pos_x_mean', 'pos_x_var', 'saccades', 'vel_x_mean', 'vel_x_var', 'tau'});

figure(1);
clf;
subplot(2,3,1);
errorbar_plot(results_agg, 'saccades', 'v_mean', 'cat');
subplot(2,3,2);
errorbar_plot(results_agg, 'pos_x_mean', 'v_mean', 'cat');
subplot(2,3,3);
errorbar_plot(results_agg, 'vel_x_mean', 'v_mean', 'cat');
subplot(2,3,4);
errorbar_plot(results_agg, 'tau', 'v_mean', 'cat');
subplot(2,3,5);
errorbar_plot(results_agg, 'pos_x_var', 'v_mean', 'cat');
subplot(2,3,6);
errorbar_plot(results_agg, 'vel_x_var', 'v_mean', 'cat');
groups = unique(results_agg.cat);
legend(cellfun(@(c) strrep(c,'ExperimentTrial_',' '), groups, 'UniformOutput', false))

subplot(2,3,2);
ylims = ylim;
xlims = xlim;
vmeans = linspace(xlims(1), xlims(2), 100);
blur_fit = vmeans * 2560 / 43.6 / 9.8;
plot(vmeans, blur_fit, '--');
blur_fit = vmeans * 2560 / 43.6 / 22;
plot(vmeans, blur_fit, '--');
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
