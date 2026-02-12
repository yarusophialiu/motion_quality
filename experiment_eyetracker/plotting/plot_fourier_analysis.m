function plot_fourier_analysis(trial_record)

    px_to_deg = 43.6/2560;
    y_range = 3;
    
    
    t = (trial_record.Samples.time - trial_record.Samples.time(1)) / 1000;
    freqs = (1:length(t))/ t(end);
    freqs = freqs - freqs(floor(end/2)+1);
    
    
    
    posX_freq = fft(trial_record.Samples.posX * px_to_deg);
    posX_freq(1) = 0;
    posX_freq = fftshift(posX_freq);
    
    posx = trial_record.Samples.posXf;
    posx(isnan(posx)) = trial_record.Samples.target_cont_x(isnan(posx));
    
    delta_freq = fft((posx - trial_record.Samples.target_cont_x) * px_to_deg);
    delta_freq(1) = 0;
    delta_freq = fftshift(delta_freq);
    
    
    
    pos_target_cont_freq = fft(trial_record.Samples.target_cont_x * px_to_deg);
    pos_target_cont_freq(1) = 0;
    pos_target_cont_freq = fftshift(pos_target_cont_freq);
    
    plot(freqs, abs(delta_freq));
end