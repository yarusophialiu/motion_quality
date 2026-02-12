function record_table = process_add_sacc(record_table)

    saccs = zeros(size(record_table, 1),1);
    
    for ii=1:size(saccs, 1)
        saccs(ii) = record_table.object(ii).Events.sacc_count;
        % length(record_table.object(ii).Events.sacc.start);
    end
    record_table.saccades = saccs;
end

