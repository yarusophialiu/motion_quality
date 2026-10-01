bandwidths = (10:1:608) * 1000000;
velocities = 3:1:50;
refresh_rate = zeros(length(bandwidths), length(velocities));

for iB=1:length(bandwidths)
    fprintf(1, 'processing iB %d out of %d\n', iB, length(bandwidths));
    for iV=1:length(velocities)
        %refresh_rates(iV) = fminsearch(@(p) objective_function(50, p, bandwidths(iB), max_res, vs(iV)), 50);
        rrs = 30:1:250;
        vals = arrayfun(@(p) objective_function(160, p, bandwidths(iB), max_res, velocities(iV), 0), rrs);
        [~, i] = min(vals);
        refresh_rate(iB, iV) = rrs(i);
    end
end

save('preds_3d', 'bandwidths', 'velocities', 'refresh_rate');
surf(refresh_rate);


function e = objective_function(base_rr, rr, bandwidth, max_res, v, pred)
    params = get_best_params();
    params(4) = params(2) * 1.5;
    resolution_reduction_base = min(1, sqrt(bandwidth ./ (base_rr * max_res)));
    resolution_reduction = min(1, sqrt(bandwidth ./ (rr * max_res)));
    
    e = -model_predict_Q(rr, base_rr, v, pred, resolution_reduction, resolution_reduction_base, params);     
    % apply constraints
    e = e + max(30 - rr, 0) * 100 + max(rr - 250, 0) * 100;
    
    % promote higher refresh rates when flat
    e = e - (rr) * 0.00001;
end