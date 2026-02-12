function plot_retinal_location(trial_record)

    px_to_deg = 43.6/2560;
    y_range = 3;

    %valid_range = tial_record.Samples
    mask = logical(trial_record.Samples.mask);
    %plot(trial_record.Samples.time(mask), (trial_record.Samples.posX(mask) - trial_record.Samples.target_cont_x(mask)) * px_to_deg);
    %plot(trial_record.Samples.time(mask), (trial_record.Samples.posX(mask) - trial_record.Samples.target_cont_x(mask)) * px_to_deg);
    
    t = (trial_record.Samples.time - trial_record.Samples.time(1)) / 1000;
    
    area(t, (1 - trial_record.Samples.mask) * y_range, 'linestyle', 'none', 'facecolor', [1, 0, 0], 'FaceAlpha', 0.2); 
    hold on;
    area(t, (1 - trial_record.Samples.mask) * (-y_range), 'linestyle', 'none', 'facecolor', [1, 0, 0], 'FaceAlpha', 0.2); 
    
    plot(t, (trial_record.Samples.posX - trial_record.Samples.target_disp_x) * px_to_deg);
    plot(t, (trial_record.Samples.posX - trial_record.Samples.target_cont_x) * px_to_deg);
    ylim([-y_range, y_range]);
    
    xlabel('time (s)');
    hold off;
end