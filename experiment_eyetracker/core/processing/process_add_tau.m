function record_table = process_add_tau(record_table)

    taus = zeros(size(record_table, 1),1);
    
    for ii=1:size(taus, 1)
        taus(ii) = record_table.object(ii).tau;
    end
    
    record_table.tau = taus;
end

