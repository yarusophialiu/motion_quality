function errorbar_plot(results, field_name, x_axis_name, group_name)

    groups = unique(results.(group_name));
    for iG = 1:length(groups)
        if iscell(groups(iG))
            results_filt = results(strcmpi(results.(group_name), groups(iG)),:);
        else
            results_filt = results(results.(group_name)==groups(iG),:);
        end
        
        errorbar(results_filt.(x_axis_name), results_filt.(['mean_' field_name]), results_filt.(['std_' field_name]));
        hold on;
    end
    
    labels = cellfun(@(c) strrep(c,'ExperimentTrial_',' '), results.Row, 'UniformOutput', false);
    xlabel(strrep(x_axis_name, '_', ' '));
    ylabel(strrep(field_name, '_', ' '));
    
    %set(gca, 'YScale', 'log')
    %set(gca, 'XScale', 'log');
end