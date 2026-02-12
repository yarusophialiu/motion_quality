function stimuli = create_initial_stimuli()
%CREATE_INITIAL_STIMULI 7 stimuli with a range of content/motion

    duration = 20;
    
    stimuli(7, 1) = Stimulus();
    
    % 3 different velocities of sinusoid movements (discs)
    for ii = 1:3
        stimuli(ii) = Stimulus.create_discs_stimulus(SinusoidMotion(), duration);
        stimuli(ii).motion.frequency = 0.2 * ii;
    end
    
    % eyetracker with predictable and unpredictable motion
    stimuli(4) = Stimulus.create_eyetracker_target_stimulus(SinusoidMotion(), duration);
    stimuli(5) = Stimulus.create_eyetracker_target_stimulus(SumSinusoidsMotion(), duration);
    stimuli(5).motion.gain = 0.046;
    
    % text and panorama
    stimuli(6) = Stimulus.create_text_stimulus(SinusoidMotion(), duration);
    stimuli(7) = Stimulus.create_panorama_stimulus(StepsMotion(), 'tery', duration);
    stimuli(7).motion.linear_velocity = 0.25;
    stimuli(7).motion.alternation_velocity = 3;

    stimuli = index_stimuli(stimuli);
end

