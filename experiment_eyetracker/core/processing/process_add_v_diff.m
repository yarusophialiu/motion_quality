function record_table = process_add_v_diff(record_table)

    means = zeros(size(record_table, 1),1);
    stds = zeros(size(record_table, 1),1);
    
    for ii=1:size(stds, 1)
        indices = find(record_table.object(ii).Samples.mask);
        v_ratio = abs(record_table.object(ii).Samples.target_cont_vx(indices) ./ record_table.object(ii).Samples.velX(indices));
        v_ratio(v_ratio==Inf)= nan;
        means(ii) = nanmean(v_ratio);
        stds(ii) = nanstd(v_ratio);
    end
    
    record_table.vel_x_mean = 1 ./ means;
    record_table.vel_x_var = stds .* stds;
end

