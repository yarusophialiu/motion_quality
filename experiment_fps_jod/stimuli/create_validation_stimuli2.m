function stimuli = create_validation_stimuli2()
%CREATE_VALIDATION_STIMULI 2

    duration = 20;
    
    stimuli(1, 1) = Stimulus.create_panorama_stimulus(SumSinusoidsMotion(), 'danube', duration);
    stimuli(1, 1).motion.gain  = 0.024;

    
    
    stimuli = index_stimuli(stimuli);
end

