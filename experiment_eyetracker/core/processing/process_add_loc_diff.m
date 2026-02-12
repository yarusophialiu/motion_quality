function record_table = process_add_loc_diff(record_table)

    means = zeros(size(record_table, 1),1);
    stds = zeros(size(record_table, 1),1);
    
    for ii=1:size(stds, 1)
        indices = find(record_table.object(ii).Samples.mask);
        dist = abs(record_table.object(ii).Samples.target_cont_x(indices) - record_table.object(ii).Samples.posX(indices));
        means(ii) = nanmean(dist);
        stds(ii) = nanstd(dist);
    end
    
    record_table.pos_x_mean = means;
    record_table.pos_x_var = stds .* stds;
end

