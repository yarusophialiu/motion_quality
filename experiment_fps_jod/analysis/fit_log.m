res = load('scaled_results');
if isfield(res, 'res')
    res = res.res;
end

res.log_p = ones(length(res.stimuli), 3);

rr2 = 50:5:165;

% use 3v scaled data where possible
all_jods = res.JODs;
all_jods(1:3,:) = res.JODs3(:,:);
for ii=1:length(res.stimuli)
    options = optimset();  %'Display','iter', 'PlotFcns',@optimplotfval 
    all_jods(ii,:) = all_jods(ii,:) - all_jods(ii,1); % normalise first point to 0
    [res.log_p(ii,:), e] = fminsearch(@(p)objfun(p, res.refresh_rates, all_jods(ii,:)), [1, 1, 0], options);
    res.log_p(ii,3) = res.log_p(ii,2) * 50 - 1;
    pred = pmod_log(rr2, res.log_p(ii,:));
    figure(1);
    subplot(2, ceil(length(res.stimuli)/2), ii);
    plot(res.refresh_rates, all_jods(ii,:)', 'x');hold on;
    plot(rr2, pred);hold off;
    ylim([0, 6]);
    xlim([min(rr2), max(rr2)]);
    xlabel('refresh rate (Hz)');
    ylabel('quality (JOD)');
    title(sprintf('Stimulus %d. E:%f', ii, e));
end

current_path = fileparts(mfilename('fullpath'));
save(sprintf('%s/scaled_results', current_path), 'res');



function e = objfun(p, refresh_rates, jods)
    pred = pmod_log(refresh_rates, [p(1), p(2), 50*p(2)-1]);
    e = sqrt(mean(( pred - jods).^2));
end