function bar_plot(results, field_name)
    bar(results.(['mean_' field_name]));
    hold on;
    errorbar(results.(['mean_' field_name]), results.(['std_' field_name]), '.k');
    
    labels = cellfun(@(c) strrep(c,'ExperimentTrial_',' '), results.Row, 'UniformOutput', false);
    xticklabels(labels)
    xtickangle(45);
    xlabel('trial');
    ylabel(strrep(field_name, '_', ' '));
end