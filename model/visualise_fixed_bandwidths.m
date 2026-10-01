figure(1);
max_res = 2560 * 1440;
max_refresh_rate = 165;
max_bandwidth = max_res * max_refresh_rate;

vs = 0:3:35;

figure(1)

bandwidths = linspace(0.01, 1, 150) * max_bandwidth;
refresh_rates = zeros(size(bandwidths));
for iV=1:length(vs)
    for iB=1:length(bandwidths)
        %refresh_rates(iB) = fminsearch(@(p) objective_function(100, p, bandwidths(iB), max_res, vs(iV)), 30);
        rrs = 50:1:165;
        vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), max_res, vs(iV)), rrs);
        [~, i] = min(vals);
        refresh_rates(iB) = rrs(i);
    end
    resolution_reductions = sqrt(min(1, bandwidths ./ (refresh_rates * max_res)));
    
    figure(1);
    plot(bandwidths / max_bandwidth, refresh_rates); hold on;
    
    figure(2)
    plot(bandwidths / max_bandwidth, resolution_reductions); hold on;
end
figure(1)
hold off;
xlabel('bandwidth');
ylabel('refresh rate');
legend(string(vs));
figure(2)
xlabel('bandwidth');
ylabel('resolution');
bb = bandwidths / 1000000;
debattista_params = [6.349e-08, -3.621e-05, 0.0082,0.01738];
debattista_pred = debattista_params(1) * bb .^ 3 + debattista_params(2) * bb .^ 2 + debattista_params(3) * bb + debattista_params(4);
plot(bandwidths / max_bandwidth, min(1, debattista_pred), '--', 'color', 'black');
hold off;

figure(3);
vs = linspace(0, 80, 100);
bandwidths = linspace(0.1, 1, 8) * max_bandwidth;
refresh_rates = zeros(size(vs));
for iB=1:length(bandwidths)
    for iV=1:length(vs)
        %refresh_rates(iV) = fminsearch(@(p) objective_function(50, p, bandwidths(iB), max_res, vs(iV)), 50);
        rrs = 50:165;
        vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), max_res, vs(iV)), rrs);
        [~, i] = min(vals);
        refresh_rates(iV) = rrs(i);
    end
    plot(vs, refresh_rates); hold on;
end
hold off;
xlabel('velocity');
ylabel('refresh rate');
legend(string(bandwidths / max_bandwidth));


function e = objective_function(base_rr, rr, bandwidth, max_res, v)
    params = get_best_params();
    resolution_reduction_base = min(1, sqrt(bandwidth ./ (base_rr * max_res)));
    resolution_reduction = min(1, sqrt(bandwidth ./ (rr * max_res)));
    
    e = -model_predict_Q(rr, base_rr, v, 1, resolution_reduction, resolution_reduction_base, params);     
    % apply constraints
    e = e + max(20 - rr, 0) * 100 + max(rr - 165, 0) * 100;
    
    % promote higher refresh rates when flat
    e = e - (rr) * 0.00001;
end

