figure(1);
observers = {'am1', 'yn272', 'gd355', 'fz1', 'if1', 'dy1', 'aj1'}; %  'ph1',
results = load_results('Initial', observers);
predictable =  scale_results(results, @(r) strcmpi(r.motion, 'SinusoidMotion'), 'Predictable');
unpredictable = scale_results(results, @(r) strcmpi(r.motion, 'SumSinusoidsMotion'), 'Unpredictable');

techs = predictable.techs{1};
cols = lines(length(techs));
clf;
for iT=1:length(techs)
    mean_jod = cell2mat(cellfun(@(r) r(iT), predictable.jod, 'UniformOutput', false));
    jod_low = cell2mat(arrayfun(@(r) r.jod_low(iT), predictable.stats, 'UniformOutput', false));
    jod_high = cell2mat(arrayfun(@(r) r.jod_high(iT), predictable.stats, 'UniformOutput', false));
    errorbar((unpredictable.refresh_rate), mean_jod, mean_jod - jod_low, jod_high - mean_jod, 'Color', cols(iT,:)); hold on;
        
    mean_jod = cell2mat(cellfun(@(r) r(iT), unpredictable.jod, 'UniformOutput', false));
    jod_low = cell2mat(arrayfun(@(r) r.jod_low(iT), unpredictable.stats, 'UniformOutput', false));
    jod_high = cell2mat(arrayfun(@(r) r.jod_high(iT), unpredictable.stats, 'UniformOutput', false));
    errorbar((unpredictable.refresh_rate + 0.5), mean_jod, mean_jod - jod_low, jod_high - mean_jod, '--', 'Color', cols(iT,:)); hold on;
end
A = repmat(techs,2,1);
legend(A(:));
xlabel('refresh rate');
ylim([-2, 5]);
ylabel('Quality (JND)');
grid on;
title('motion blur vs judder in regular (solid) and unpredictible (dashed) motion');
