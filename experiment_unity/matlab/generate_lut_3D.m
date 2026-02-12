% general grid + add 3 sampling bandwidths
bandwidths = linspace(0.01, 1, 98) * 2560* 1440 * 165;
bandwidths = sort([bandwidths, 27648000, 55296000, 221184000]);

velocities = 0:0.5:50;

[bs, vs] = meshgrid(bandwidths, velocities);

refresh_rates_pred = zeros(size(bs));
refresh_rates_unpred = zeros(size(bs));

for iB=1:size(bs,1)
    for iV=1:size(bs, 2)
        rrs = 50:165;
        vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), 2560*1440, vs(iV), 1), rrs);
        [~, i] = min(vals);
        refresh_rates_pred(iV,iB) = rrs(i);
        
        vals = arrayfun(@(p) objective_function(150, p, bandwidths(iB), 2560*1440, vs(iV), 0), rrs);
        [~, i] = min(vals);
        refresh_rates_unpred(iV,iB) = rrs(i);
    end
    fprintf(',%d', iB);
end
fprintf('\n');

save('Asus', 'refresh_rates_pred', 'refresh_rates_unpred', 'velocities', 'bandwidths');

function e = objective_function(base_rr, rr, bandwidth, max_res, v, pred)
    params = get_best_params();
    params(4) = params(2) * 2.2;
    resolution_reduction_base = min(1, sqrt(bandwidth ./ (base_rr * max_res)));
    resolution_reduction = min(1, sqrt(bandwidth ./ (rr * max_res)));
    
    e = -model_predict_Q(rr, base_rr, v, pred, resolution_reduction, resolution_reduction_base, params);     
    % apply constraints
    e = e + max(20 - rr, 0) * 100 + max(rr - 165, 0) * 100;
    
    % promote higher refresh rates when flat
    e = e - (rr) * 0.00001;
end