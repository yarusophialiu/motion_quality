max_res = 2560 * 1440;
max_refresh_rate = 165;
max_bandwidth = max_res * max_refresh_rate;


figure(3);
vs = linspace(0, 40, 100);
bandwidths = linspace(0.05, 0.75, 4) * max_bandwidth;
refresh_rates = zeros(size(vs));

rweights = [2, 2.5];
cols = lines();
for iW=1:length(rweights)
    for iB=1:length(bandwidths)
        for iV=1:length(vs)
            %refresh_rates(iV) = fminsearch(@(p) objective_function(50, p, bandwidths(iB), max_res, vs(iV)), 50);
            rrs = 50:1:165;
            vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), max_res, vs(iV), rweights(iW)), rrs);
            [~, i] = min(vals);
            refresh_rates(iV) = rrs(i);
        end
        plot(vs, refresh_rates, 'Color', cols(iB,:)); hold on;
    end
end
hold off;
xlabel('velocity');
ylabel('refresh rate');
legend(string(bandwidths / max_bandwidth));
grid on;

function e = objective_function(base_rr, rr, bandwidth, max_res, v, rweight)
    params = get_best_params();
    params(4) = params(4) * rweight;
    resolution_reduction_base = min(1, sqrt(bandwidth ./ (base_rr * max_res)));
    resolution_reduction = min(1, sqrt(bandwidth ./ (rr * max_res)));
    
    e = -model_predict_Q(rr, base_rr, v, 1, resolution_reduction, resolution_reduction_base, params);     
    % apply constraints
    e = e + max(20 - rr, 0) * 100 + max(rr - 165, 0) * 100;
    
    % promote higher refresh rates when flat
    e = e - (rr) * 0.00001;
end