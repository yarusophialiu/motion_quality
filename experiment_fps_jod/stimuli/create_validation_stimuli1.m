function stimuli = create_validation_stimuli1()
%CREATE_VALIDATION_STIMULI 

    duration = 20;
    
    stimuli(1, 1) = Stimulus();
    %{
    stimuli(1) = Stimulus.create_eyetracker_target_stimulus(SumSinusoidsMotion(), duration);
    stimuli(1).motion.gain = 0.046;
    %}
    
    stimuli(1) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'tery', duration);
    stimuli(2) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'stistvan', duration);
    %stimuli(3) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'rysy1', duration);    
    stimuli(3) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'danube', duration);
    stimuli(4) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'nhh', duration);
    %stimuli(6) = Stimulus.create_panorama_stimulus(ControlledMotion(), 'kiralyret1', duration);
    
    stimuli = index_stimuli(stimuli);
end

