function stimuli = create_example_stimuli()
%CREATE_EXAMPLE_STIMULI a few example stimuli

    stimuli = [
        Stimulus.create_eyetracker_target_stimulus(SinusoidMotion(), 20.)
        Stimulus.create_discs_stimulus(SumSinusoidsMotion(), 20.)
    ];

    stimuli = index_stimuli(stimuli);
end

